import Foundation

actor URLSessionContentUpdateTransport: ContentUpdateTransport {
    private let session: URLSession

    init(session: URLSession? = nil) {
        if let session {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
            configuration.urlCache = nil
            configuration.timeoutIntervalForRequest = 20
            configuration.timeoutIntervalForResource = 120
            configuration.waitsForConnectivity = false
            self.session = URLSession(configuration: configuration)
        }
    }

    func fetchManifest(
        from url: URL,
        ifNoneMatch etag: String?,
        maximumBytes: Int
    ) async throws -> ContentManifestTransportResponse {
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("identity", forHTTPHeaderField: "Accept-Encoding")
        if let etag {
            request.setValue(etag, forHTTPHeaderField: "If-None-Match")
        }

        let (bytes, response) = try await session.bytes(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ContentUpdateFailure.invalidHTTPStatus
        }
        let finalURL = httpResponse.url ?? url
        guard httpResponse.statusCode == 200 else {
            return ContentManifestTransportResponse(
                statusCode: httpResponse.statusCode,
                data: Data(),
                etag: httpResponse.value(forHTTPHeaderField: "ETag"),
                finalURL: finalURL
            )
        }

        var data = Data()
        data.reserveCapacity(min(maximumBytes, 64 * 1_024))
        for try await byte in bytes {
            guard data.count < maximumBytes else {
                throw ContentUpdateFailure.manifestTooLarge
            }
            data.append(byte)
        }
        return ContentManifestTransportResponse(
            statusCode: httpResponse.statusCode,
            data: data,
            etag: httpResponse.value(forHTTPHeaderField: "ETag"),
            finalURL: finalURL
        )
    }

    func downloadFile(
        from url: URL,
        to destinationURL: URL,
        maximumBytes: Int
    ) async throws -> ContentFileTransportResponse {
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("identity", forHTTPHeaderField: "Accept-Encoding")

        let (bytes, response) = try await session.bytes(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ContentUpdateFailure.invalidHTTPStatus
        }
        let finalURL = httpResponse.url ?? url
        guard httpResponse.statusCode == 200 else {
            return ContentFileTransportResponse(
                statusCode: httpResponse.statusCode,
                bytesWritten: 0,
                finalURL: finalURL
            )
        }

        let parentURL = destinationURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: parentURL,
            withIntermediateDirectories: true
        )
        guard FileManager.default.createFile(atPath: destinationURL.path, contents: nil) else {
            throw CocoaError(.fileWriteUnknown)
        }

        let handle = try FileHandle(forWritingTo: destinationURL)
        defer { try? handle.close() }
        var buffer = Data()
        buffer.reserveCapacity(64 * 1_024)
        var byteCount = 0

        for try await byte in bytes {
            guard byteCount < maximumBytes else {
                throw ContentUpdateFailure.packageTooLarge
            }
            buffer.append(byte)
            byteCount += 1
            if buffer.count == 64 * 1_024 {
                try handle.write(contentsOf: buffer)
                buffer.removeAll(keepingCapacity: true)
            }
        }
        if !buffer.isEmpty {
            try handle.write(contentsOf: buffer)
        }

        return ContentFileTransportResponse(
            statusCode: httpResponse.statusCode,
            bytesWritten: byteCount,
            finalURL: finalURL
        )
    }
}
