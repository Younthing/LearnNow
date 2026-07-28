import Darwin
import Foundation
import LearnNowContentAuthoring
import LearnNowContentKit

@main
enum LearnNowContentCommand {
    static func main() {
        do {
            try run(arguments: Array(CommandLine.arguments.dropFirst()))
        } catch let error as ContentValidationError {
            for diagnostic in error.diagnostics {
                FileHandle.standardError.write(Data((diagnostic.description + "\n").utf8))
            }
            exit(EXIT_FAILURE)
        } catch let error as CLIError {
            FileHandle.standardError.write(Data(("error: \(error.message)\n\n\(usage)\n").utf8))
            exit(EXIT_FAILURE)
        } catch {
            FileHandle.standardError.write(Data(("error: \(error.localizedDescription)\n").utf8))
            exit(EXIT_FAILURE)
        }
    }

    private static func run(arguments: [String]) throws {
        guard let command = arguments.first else {
            throw CLIError("Missing command.")
        }
        let options = try Options(Array(arguments.dropFirst()))
        let cwd = URL(filePath: FileManager.default.currentDirectoryPath, directoryHint: .isDirectory)
        let source = options.url("source", default: cwd.appending(path: "ContentSource"))
        let compiler = ContentCompiler()

        switch command {
        case "lint":
            try options.requireOnly(["source"])
            let diagnostics = compiler.lint(sourceDirectory: source)
            if diagnostics.isEmpty {
                print("Content is valid: \(source.path)")
            } else {
                throw ContentValidationError(diagnostics: diagnostics)
            }
        case "build":
            try options.requireOnly(["source", "output"])
            let output = options.url(
                "output",
                default: cwd.appending(path: ".build/content")
            )
            let artifacts = try compiler.build(
                sourceDirectory: source,
                outputDirectory: output
            )
            printArtifacts(artifacts)
        case "preview":
            try options.requireOnly(["source", "output"])
            let output = options.url(
                "output",
                default: cwd.appending(path: ".build/content-preview")
            )
            let artifacts = try compiler.build(
                sourceDirectory: source,
                outputDirectory: output
            )
            print("Preview content package generated.")
            printArtifacts(artifacts)
        case "diff":
            try options.requireOnly([
                "source",
                "old",
                "new",
                "old-manifest",
                "new-manifest",
                "strict",
            ])
            guard let oldValue = options.value("old") else {
                throw CLIError("diff requires --old <CatalogV2.json>.")
            }
            let oldURL = resolve(oldValue, relativeTo: cwd)
            let oldCatalog = try DeterministicJSON.decode(
                CatalogDocumentV2.self,
                from: Data(contentsOf: oldURL)
            )
            let oldManifest = try options.value("old-manifest").map {
                try decodeManifest(at: resolve($0, relativeTo: cwd))
            }
            let newCatalog: CatalogDocumentV2
            let newManifest: ContentManifestV1?
            if let newValue = options.value("new") {
                newCatalog = try DeterministicJSON.decode(
                    CatalogDocumentV2.self,
                    from: Data(contentsOf: resolve(newValue, relativeTo: cwd))
                )
                newManifest = try options.value("new-manifest").map {
                    try decodeManifest(at: resolve($0, relativeTo: cwd))
                }
                if oldManifest != nil, newManifest == nil {
                    throw CLIError(
                        "diff with --old-manifest and --new requires --new-manifest."
                    )
                }
            } else {
                guard options.value("new-manifest") == nil else {
                    throw CLIError("--new-manifest is only valid together with --new.")
                }
                let result = try compiler.compile(sourceDirectory: source)
                newCatalog = result.catalog
                newManifest = oldManifest == nil
                    ? nil
                    : try compiler.makeManifest(for: result)
            }
            if oldManifest == nil, newManifest != nil {
                throw CLIError("--new-manifest requires --old-manifest.")
            }
            let report = ContentDiffer.diff(
                old: oldCatalog,
                new: newCatalog,
                oldManifest: oldManifest,
                newManifest: newManifest
            )
            FileHandle.standardOutput.write(try DeterministicJSON.encode(report))
            if options.contains("strict"), !report.passesStrictReleaseChecks {
                throw ContentValidationError(
                    diagnostics: report.strictViolations.map {
                        ContentDiagnostic(
                            severity: .error,
                            code: $0.code,
                            message: $0.message,
                            file: "content-diff"
                        )
                    }
                )
            }
        case "publish":
            try options.requireOnly(["source", "output", "private-key", "key-id"])
            guard ["1", "true", "yes"].contains(
                ProcessInfo.processInfo.environment["CI"]?.lowercased() ?? ""
            ) else {
                throw CLIError("publish is restricted to CI; use build for local artifacts.")
            }
            guard let keyValue = options.value("private-key"),
                  let keyID = options.value("key-id")
            else {
                throw CLIError("publish requires --private-key <path> and --key-id <id>.")
            }
            let keyData = try decodePrivateKey(
                Data(contentsOf: resolve(keyValue, relativeTo: cwd))
            )
            let output = options.url(
                "output",
                default: cwd.appending(path: ".build/content-publish")
            )
            let artifacts = try compiler.publish(
                sourceDirectory: source,
                outputDirectory: output,
                privateKeyRawRepresentation: keyData,
                keyID: keyID
            )
            print("Signed local content package generated; no upload was performed.")
            printArtifacts(artifacts)
        case "help", "--help", "-h":
            print(usage)
        default:
            throw CLIError("Unknown command '\(command)'.")
        }
    }

    private static func printArtifacts(_ artifacts: ContentBuildArtifacts) {
        print("Catalog: \(artifacts.catalogURL.path)")
        print("Manifest: \(artifacts.manifestURL.path)")
        print("Schema: \(artifacts.schemaURL.path)")
    }

    private static func decodePrivateKey(_ data: Data) throws -> Data {
        if data.count == 32 { return data }
        guard let text = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        else {
            throw CLIError("Private key must be 32 raw bytes, 64 hex characters, or base64.")
        }
        if text.count == 64,
           text.allSatisfy({ $0.isHexDigit })
        {
            var bytes = Data()
            var index = text.startIndex
            while index < text.endIndex {
                let next = text.index(index, offsetBy: 2)
                guard let byte = UInt8(text[index..<next], radix: 16) else {
                    throw CLIError("Private-key hex is invalid.")
                }
                bytes.append(byte)
                index = next
            }
            return bytes
        }
        if let decoded = Data(base64Encoded: text), decoded.count == 32 {
            return decoded
        }
        throw CLIError("Private key must decode to the 32-byte Curve25519.Signing raw representation.")
    }

    private static func resolve(_ value: String, relativeTo cwd: URL) -> URL {
        let expanded = NSString(string: value).expandingTildeInPath
        if expanded.hasPrefix("/") {
            return URL(filePath: expanded)
        }
        return cwd.appending(path: expanded)
    }

    private static let usage = """
    Usage:
      learnnow-content lint [--source <ContentSource>]
      learnnow-content build [--source <ContentSource>] [--output <directory>]
      learnnow-content preview [--source <ContentSource>] [--output <directory>]
      learnnow-content diff --old <CatalogV2.json>
          [--old-manifest <ContentManifest.json>]
          [--new <CatalogV2.json> --new-manifest <ContentManifest.json>
            | --source <ContentSource>] [--strict]
      learnnow-content publish --private-key <path> --key-id <id>
          [--source <ContentSource>] [--output <directory>]

    publish writes signed local artifacts only. The private key file may contain
    32 raw bytes, 64 hexadecimal characters, or base64 for a 32-byte
    Curve25519.Signing private-key raw representation.
    """

    private static func decodeManifest(at url: URL) throws -> ContentManifestV1 {
        try DeterministicJSON.decode(
            ContentManifestV1.self,
            from: Data(contentsOf: url)
        )
    }
}

private struct Options {
    private let values: [String: String]
    private let flags: Set<String>

    init(_ arguments: [String]) throws {
        var values: [String: String] = [:]
        var flags: Set<String> = []
        var index = 0
        while index < arguments.count {
            let argument = arguments[index]
            guard argument.hasPrefix("--"), argument.count > 2 else {
                throw CLIError("Unexpected argument '\(argument)'.")
            }
            let key = String(argument.dropFirst(2))
            guard values[key] == nil, !flags.contains(key) else {
                throw CLIError("Option '--\(key)' was provided more than once.")
            }
            if key == "strict" {
                flags.insert(key)
                index += 1
                continue
            }
            guard index + 1 < arguments.count else {
                throw CLIError("Missing value after '\(argument)'.")
            }
            values[key] = arguments[index + 1]
            index += 2
        }
        self.values = values
        self.flags = flags
    }

    func value(_ name: String) -> String? {
        values[name]
    }

    func contains(_ name: String) -> Bool {
        values[name] != nil || flags.contains(name)
    }

    func url(_ name: String, default defaultURL: URL) -> URL {
        guard let value = values[name] else { return defaultURL }
        let expanded = NSString(string: value).expandingTildeInPath
        if expanded.hasPrefix("/") {
            return URL(filePath: expanded, directoryHint: .isDirectory)
        }
        let cwd = URL(filePath: FileManager.default.currentDirectoryPath, directoryHint: .isDirectory)
        return cwd.appending(path: expanded, directoryHint: .isDirectory)
    }

    func requireOnly(_ allowed: Set<String>) throws {
        let unknown = Set(values.keys).union(flags).subtracting(allowed)
        if !unknown.isEmpty {
            throw CLIError("Unknown options: \(unknown.sorted().map { "--\($0)" }.joined(separator: ", ")).")
        }
    }
}

private struct CLIError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }
}
