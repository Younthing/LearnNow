import CryptoKit
import Foundation

public enum DeterministicJSON {
    public static func encode<T: Encodable>(_ value: T, prettyPrinted: Bool = true) throws -> Data {
        let encoder = JSONEncoder()
        var formatting: JSONEncoder.OutputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        if prettyPrinted {
            formatting.insert(.prettyPrinted)
        }
        encoder.outputFormatting = formatting
        var data = try encoder.encode(value)
        if prettyPrinted {
            data.append(0x0A)
        }
        return data
    }

    public static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try JSONDecoder().decode(type, from: data)
    }
}

public enum ContentDigest {
    public static func sha256Hex(of data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    public static func sha256Hex(ofFileAt url: URL) throws -> String {
        sha256Hex(of: try Data(contentsOf: url))
    }
}

public enum ContentManifestSigner {
    public static func sign(
        _ manifest: ContentManifestV1,
        privateKeyRawRepresentation: Data,
        keyID: String
    ) throws -> ContentManifestV1 {
        let keyedManifest = ContentManifestV1(
            schemaVersion: manifest.schemaVersion,
            releaseVersion: manifest.releaseVersion,
            compilerVersion: manifest.compilerVersion,
            locale: manifest.locale,
            minAppBuild: manifest.minAppBuild,
            requiredCapabilities: manifest.requiredCapabilities,
            publishedAt: manifest.publishedAt,
            files: manifest.files,
            retiredIDs: manifest.retiredIDs,
            keyID: keyID
        )
        let payload = try DeterministicJSON.encode(keyedManifest, prettyPrinted: false)
        let privateKey = try Curve25519.Signing.PrivateKey(rawRepresentation: privateKeyRawRepresentation)
        let signature = try privateKey.signature(for: payload)
        return ContentManifestV1(
            schemaVersion: manifest.schemaVersion,
            releaseVersion: manifest.releaseVersion,
            compilerVersion: manifest.compilerVersion,
            locale: manifest.locale,
            minAppBuild: manifest.minAppBuild,
            requiredCapabilities: manifest.requiredCapabilities,
            publishedAt: manifest.publishedAt,
            files: manifest.files,
            retiredIDs: manifest.retiredIDs,
            keyID: keyID,
            signature: signature.base64EncodedString()
        )
    }

    public static func verify(
        _ manifest: ContentManifestV1,
        publicKeyRawRepresentation: Data
    ) throws -> Bool {
        guard let encodedSignature = manifest.signature,
              Data(base64Encoded: encodedSignature) != nil
        else {
            return false
        }
        let payload = try DeterministicJSON.encode(manifest.unsigned(), prettyPrinted: false)
        let publicKey = try Curve25519.Signing.PublicKey(rawRepresentation: publicKeyRawRepresentation)
        return publicKey.isValidSignature(Data(base64Encoded: encodedSignature)!, for: payload)
    }
}
