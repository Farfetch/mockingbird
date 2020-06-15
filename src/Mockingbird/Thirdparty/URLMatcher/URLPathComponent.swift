// The MIT License (MIT)
//
// Copyright (c) 2016 Suyeol Jeon (xoul.kr)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

enum URLPathComponent {
    case plain(String)
    case placeholder(type: String?, key: String)
}

extension URLPathComponent {
    init(_ value: String) {
        if value.hasPrefix("<") && value.hasSuffix(">") {
            let start = value.index(after: value.startIndex)
            let end = value.index(before: value.endIndex)
            let placeholder = value[start..<end] // e.g. "<int:id>" -> "int:id"
            let typeAndKey = placeholder.components(separatedBy: ":")
            if typeAndKey.count == 1 { // any-type placeholder
                self = .placeholder(type: nil, key: typeAndKey[0])
            } else if typeAndKey.count == 2 {
                self = .placeholder(type: typeAndKey[0], key: typeAndKey[1])
            } else {
                self = .plain(value)
            }
        } else {
            self = .plain(value)
        }
    }
}

extension URLPathComponent: Equatable {
    static func == (lhs: URLPathComponent, rhs: URLPathComponent) -> Bool {
        switch (lhs, rhs) {
        case let (.plain(leftValue), .plain(rightValue)):
            return leftValue == rightValue
            
        case let (.placeholder(leftType, leftKey), .placeholder(rightType, key: rightKey)):
            return (leftType == rightType) && (leftKey == rightKey)
            
        default:
            return false
        }
    }
}
