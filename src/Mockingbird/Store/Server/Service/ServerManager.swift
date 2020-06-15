//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation
import Swifter

final class ServerManager {

    static let shared = ServerManager()

    private let server = HttpServer()

    @discardableResult
    func start() -> Bool {

        do {

            self.initializeServer()

            try server.start(UInt16(Default.Server.port))

            AppStore.server.dispatch(ServerAction.start)

            return true

        } catch {

            _log(type: .error, log: error.localizedDescription)
        }

        return false
    }

    func stop() {

        self.server.stop()

        AppStore.server.dispatch(ServerAction.stop)
    }

    func initialize() {

        AppStore.server.dispatch(ServerAction.initialize)

        ContextManager.shared.setLocalContextIfPresent()
    }
}

private extension ServerManager {

    func initializeServer() {

        server[Default.Server.path] = websocket(text: { session, text in

            do {

                var transaction = try ServerTransaction(text)

                if let context = ContextManager.shared.currentContext {

                    let urlStr = transaction.request.url.absoluteString
                    let exist = context.paths.filter { urlStr.contains($0) }.count != 0

                    if !exist {

                        _log(type: .info, log: "blocked: \(urlStr)")
                        session.writeText(text)
                        return
                    }
                }

                let pattern = Router.shared.convertUrlToPattern(transaction.request.url)

                let (code, ret) = Router.shared.handler(for: transaction.request.url)

                if let code = code,
                    let ret = ret {

                    self.handle(transaction: transaction, pattern: pattern, mocked: true, isMock: false, original: text)

                    if transaction.response.statusCode != 200 {

                        transaction.response.headers.append(["Content-Type", "application/json; charset=utf-8"])
                        transaction.response.headers.append(["Content-Encoding", "gzip"])
                        transaction.response.headers.append(["Content-Language", "en-GB"])
                    }

                    let textMinify = ret.minify
                    transaction.response.statusCode = code
                    transaction.response.body = textMinify
                    transaction.response.headers.removeAll { $0[0] == "Content-Length" }
                    transaction.response.headers.append(["Content-Length", "\(ret.count)"])

                    self.handle(transaction: transaction, pattern: pattern, mocked: false, isMock: true, original: textMinify)

                    if let resp = try transaction.jsonString() {

                        session.writeText(resp)
                    }

                } else {

                    self.handle(transaction: transaction, pattern: pattern, mocked: false, isMock: false, original: text)

                    session.writeText(text)
                }

            } catch {

                _log(type: .error, log: error.localizedDescription)
            }

        }, binary: { session, binary in

            session.writeBinary(binary)
        })
    }

    func handle(transaction: ServerTransaction, pattern: String, mocked: Bool, isMock: Bool, original: String) {

        let reqLength = transaction.request.body.count
        let resLength = transaction.response.body.count
        let sizeString = ByteCountFormatter.string(fromByteCount: (Int64(reqLength + resLength)), countStyle: .file)

        let capture = ServerCapture(url: transaction.request.url.absoluteString.removingPercentEncoding ?? "",
                                    urlPath: transaction.request.url.path,
                                    queryParams: transaction.request.url.query?.removingPercentEncoding ?? "",
                                    requestMethod: transaction.request.method.padding(toLength: 4, withPad: " ", startingAt: 0),
                                    requestFormatted: transaction.request.body.data(using: .utf8)?.prettyPrintedJSONString as String? ?? "no data",
                                    responseFormatted: transaction.response.body.data(using: .utf8)?.prettyPrintedJSONString as String? ?? "no data",
                                    responseStatusCode: transaction.response.statusCode,
                                    original: original,
                                    mocked: mocked,
                                    isMock: isMock,
                                    bytesString: sizeString)

        AppStore.server.dispatch(ServerAction.addCapture(capture: capture))

        AppStore.server.dispatch(ServerAction.updateStats(pattern: pattern, stat: Float(reqLength + resLength)))
    }
}
