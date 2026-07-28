import Foundation

/// The release ordering shared by authored content and the remote update protocol.
///
/// Versions are one or more dot-separated, unsigned 64-bit decimal components.
/// Trailing zero components compare equal, matching the client's anti-rollback
/// behavior (`1.2`, `1.2.0`, and `1.2.0.0` have the same precedence).
public struct ContentReleaseVersion: Comparable, Sendable {
    public let source: String
    public let components: [UInt64]

    public init?(_ source: String) {
        let parts = source.split(separator: ".", omittingEmptySubsequences: false)
        guard !parts.isEmpty else { return nil }

        var parsed: [UInt64] = []
        parsed.reserveCapacity(parts.count)
        for part in parts {
            guard !part.isEmpty,
                  part.allSatisfy({ $0 >= "0" && $0 <= "9" }),
                  let value = UInt64(part)
            else {
                return nil
            }
            parsed.append(value)
        }

        while parsed.count > 1, parsed.last == 0 {
            parsed.removeLast()
        }
        self.source = source
        self.components = parsed
    }

    public static func < (
        lhs: ContentReleaseVersion,
        rhs: ContentReleaseVersion
    ) -> Bool {
        let count = max(lhs.components.count, rhs.components.count)
        for index in 0..<count {
            let left = index < lhs.components.count ? lhs.components[index] : 0
            let right = index < rhs.components.count ? rhs.components[index] : 0
            if left != right { return left < right }
        }
        return false
    }

    public static func == (
        lhs: ContentReleaseVersion,
        rhs: ContentReleaseVersion
    ) -> Bool {
        lhs.components == rhs.components
    }
}
