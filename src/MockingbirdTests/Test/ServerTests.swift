//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import XCTest
import Starscream
@testable import Mockingbird

class ServerTests: XCTestCase {

    func testSetup() {

        let expectation = XCTestExpectation(description:"testing server")

        XCTAssertEqual(ServerManager.shared.start(), true)

        let testTransaction = "{\n   \"request\":{\n      \"method\":\"GET\",\n      \"url\":\"http://www.test.com/pp1\",\n      \"headers\":[],\n      \"body\":\"\"\n   },\n   \"response\":{\n      \"status_code\":200,\n      \"headers\":[],\n      \"body\":\"\"\n   }\n}"

        XCTAssertFalse(testTransaction.contains("500"))

        ContextManager.shared.contexts.removeAll()
        ContextManager.shared.setContext(index: 0)

        Router.shared.register(type: "GET", code: 200, pattern: "/pp1") { _, path, _ in

            XCTAssertEqual(path, "/pp1")
            return (500, "")
        }

        let socket = WebSocket(request: URLRequest(url: URL(string: "ws://localhost:5000/api/stream")!))

        socket.onEvent = { event in

            switch event {
            case .connected:

                socket.write(string: testTransaction)

            case .text(let string):

                XCTAssertTrue(string.contains("500"))
                expectation.fulfill()

            default:
                break
            }
        }

        socket.connect()

        self.wait(for: [expectation], timeout: 10)

        ServerManager.shared.stop()
    }
}
