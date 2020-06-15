//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation

public typealias URLHandler = (_ url: URLConvertible, _ path: String, _ values: [String: Any]) -> (Int?, String?)

struct RouterType {

    let type: String
    let code: Int
    let pattern: String
    let factory: URLHandler
    let query: String
}

class Router {

    static let shared = Router()

    private let matcher = URLMatcher()
    private var handlers = [RouterType]()
    private var handlersKeys = [String]()

    func clear() {

        self.handlers.removeAll()
        self.handlersKeys.removeAll()

        _log(type: .debug, log: ">> register cleared")
    }

    func retrieveQueryFrom(pattern: String) -> String {

        let components = pattern.components(separatedBy: "?")
        var query = ""
        if components.count > 1 {
            query = components[1]
        }
        return query.removingPercentEncoding ?? ""
    }

    func register(type: String, code: Int, pattern: String, _ factory: @escaping URLHandler) {

        _log(type: .debug, log: ">> register: \(pattern)")

        self.handlers.append(RouterType(type: type,
                                        code: code,
                                        pattern: self.matcher.normalizeURL(pattern).urlStringValue,
                                        factory: factory,
                                        query: retrieveQueryFrom(pattern: pattern)))
        self.handlersKeys.append(pattern)
    }

    func unregister(_ pattern: String) {

        _log(type: .debug, log: ">> unregister: \(pattern)")

        if let idx = self.handlers.firstIndex(where: { $0.pattern == pattern }) {

            self.handlers.remove(at: idx)
        }

        if let idx = self.handlersKeys.firstIndex(where: { $0 == pattern }) {

            self.handlersKeys.remove(at: idx)
        }
    }

    func handler(for url: URLConvertible) -> (Int?, String?) {

        let query = retrieveQueryFrom(pattern: url.urlStringValue).removingPercentEncoding ?? ""
        let path = URL(string: url.urlStringValue)?.path ?? ""

        if query.count > 0 {

            let registeredResults = self.matcher.matchResults(path, from: self.handlersKeys)

            for register in registeredResults {

                let registerQuery = retrieveQueryFrom(pattern: register.pattern)

                for handler in self.handlers.sorted(by: { $0.query.count > $1.query.count }) {

                    let queryComparison = handler.query.count > 0 ? query.contains(handler.query) : registerQuery == handler.query
                    let normalizedResult = self.matcher.normalizeURL(register.pattern).urlStringValue

                    if normalizedResult == handler.pattern && queryComparison {

                        return handler.factory(url, path, register.values)
                    }
                }
             }

        } else {

            guard let match = self.matcher.match(path, from: self.handlersKeys) else { return (nil, nil) }
            guard let handler = self.handlers.first(where: { $0.pattern == match.pattern }) else { return (nil, nil) }

            return handler.factory(url, path, match.values)
        }

        return (nil, nil)
    }

    func convertUrlToPattern(_ url: URLConvertible) -> String {
        return self.matcher.convertUrlToPattern(url)
    }
}
