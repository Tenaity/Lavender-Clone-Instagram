//
//  Optional+Extensions.swift
//  Lavender
//
//  Created by Van Muoi on 7/16/22.
//

import Foundation

public extension Optional {
    var hasValue: Bool { self != nil }
    
    var convertToArray: [Wrapped] {
        guard let self = self else { return [] }
        return [self]
    }
}

extension Optional where Wrapped == String {
    public var isNilOrEmpty: Bool {
        return self?.trimmingCharacters(in: .whitespaces).isEmpty ?? true
    }

    /// Get substring array in string by regex pattern.
    ///
    /// - Parameters:
    ///   - pattern: Input pattern
    /// - Returns: The substring array
    public func findSubstrings(pattern: String) -> [String] {
        guard let selfStr = self else { return [String]() }
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue: 0))
            let nsstr = selfStr as NSString
            let all = NSRange(location: 0, length: nsstr.length)
            var matches: [String] = [String]()
            regex.enumerateMatches(in: selfStr, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: all) { (result: NSTextCheckingResult?, _, _) in
                if let r = result {
                    let result = nsstr.substring(with: r.range) as String
                    matches.append(result)
                }
            }
            return matches
        } catch {
            return [String]()
        }
    }
}
