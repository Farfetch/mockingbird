//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation

extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}

extension String {
    var unescaped: String {
        let entities = ["\0", "\t", "\n", "\r", "\"", "\'", "\\"]
        var current = self
        for entity in entities {
            let descriptionCharacters = entity.debugDescription.dropFirst().dropLast()
            let description = String(descriptionCharacters)
            current = current.replacingOccurrences(of: description, with: entity)
        }
        return current
    }

    var minify: String {
        // http://stackoverflow.com/questions/8913138/
        // https://developer.apple.com/reference/foundation/nsregularexpression#//apple_ref/doc/uid/TP40009708-CH1-SW46
        let minifyRegex = "(\"(?:[^\"\\\\]|\\\\.)*\")|\\s+"

        if let regexMinify = try? NSRegularExpression(pattern: minifyRegex, options: .caseInsensitive) {

            let modString = regexMinify.stringByReplacingMatches(in: self,
                                                                 options: .withTransparentBounds,
                                                                 range: NSRange(location: 0, length: self.count),
                                                                 withTemplate: "$1")

            return modString
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: "\t", with: "")
                .replacingOccurrences(of: "\r", with: "")
        } else {
            return self
        }
    }
}

extension Decodable {

    init(data: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
}

extension Encodable {

    func jsonData() throws -> Data {

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
