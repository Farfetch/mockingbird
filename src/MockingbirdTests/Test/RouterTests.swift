//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import XCTest
@testable import Mockingbird

class RouterTests: XCTestCase {

    func testRouter() {

        let expectation = XCTestExpectation(description:"testing router")

        let pattern = Router.shared.convertUrlToPattern("http://www.test.com/path1")

        XCTAssertEqual(pattern, "www.test.com/path1")

        Router.shared.register(type: "GET", code: 200, pattern: "/path1") { url, path, values in

            XCTAssertEqual(path, "/path1")
            XCTAssertNil(url.queryItems)
            XCTAssertEqual(values.count, 0)
            expectation.fulfill()

            return (200, "")
        }

        _ = Router.shared.handler(for: "http://www.test.com/path1", type: "GET")

        self.wait(for: [expectation], timeout: 1)
    }

    func testRouterWithQueryParameters() {

        let expectation = XCTestExpectation(description:"testing router with query parameters")

        Router.shared.register(type: "GET", code: 200, pattern: "/path2") { url, path, values in

            XCTAssertEqual(path, "/path2")
            XCTAssertEqual(url.queryItems?.count, 2)
            XCTAssertEqual(values.count, 0)
            expectation.fulfill()

            return (200, "")
        }

        _ = Router.shared.handler(for: "http://www.test.com/path2?query1=test1&query2=test2", type: "GET")

        self.wait(for: [expectation], timeout: 1)
    }

    func testRouterWithDynamicPath() {

        let expectation = XCTestExpectation(description:"testing router with dynamic path")

        Router.shared.register(type: "GET", code: 200, pattern: "/dyn1/<userid>/path4") { url, path, values in

            XCTAssertEqual(path, "/dyn1/1234/path4")
            XCTAssertEqual(url.queryItems?.count, 2)
            XCTAssertEqual(values.count, 1)
            XCTAssertNotNil(values["userid"])

            if let value = values["userid"] as? String {

                XCTAssertEqual(value, "1234")
            }

            expectation.fulfill()

            return (200, "")
        }

        _ = Router.shared.handler(for: "http://www.test.com/dyn1/1234/path4?query1=test1&query2=test2", type: "GET")

        self.wait(for: [expectation], timeout: 1)
    }

    func testRouterWithDynamicPathWithQuery() {

        let expectation = XCTestExpectation(description:"testing router with dynamic path")

        Router.shared.register(type: "GET", code: 200, pattern: "/dyn2/<userid>/path4?query1=test1") { url, path, values in

            XCTAssertEqual(path, "/dyn2/1234/path4")
            XCTAssertEqual(url.queryItems?.count, 2)
            XCTAssertEqual(values.count, 1)
            XCTAssertNotNil(values["userid"])

            if let value = values["userid"] as? String {

                XCTAssertEqual(value, "1234")
            }

            expectation.fulfill()

            return (200, "")
        }

        _ = Router.shared.handler(for: "http://www.test.com/dyn2/1234/path4?query1=test1&query2=test2", type: "GET")

        self.wait(for: [expectation], timeout: 1)
    }

    func testRouterWithQueryAsPriority() {

        let expectation = XCTestExpectation(description:"testing router with long query parameter")

        Router.shared.register(type: "GET", code: 200, pattern: "/path4?status=test1,test2&query1=test1&query2=test2") { _, _, _ in

            XCTAssertFalse(true)
            return (200, "")
        }

        Router.shared.register(type: "GET", code: 200, pattern: "/path4?status=test1") { _, _, _ in

            XCTAssertFalse(true)
            return (200, "")
        }

        Router.shared.register(type: "GET", code: 200, pattern: "/path4") { _, _, _ in

            XCTAssertFalse(true)
            return (200, "")
        }

        Router.shared.register(type: "GET", code: 200, pattern: "/path4?status=test1,test2,test3") { url, path, values in

            XCTAssertEqual(path, "/path4")
            XCTAssertEqual(url.queryItems?.count, 3)
            XCTAssertEqual(values.count, 0)
            expectation.fulfill()

            return (200, "")
        }

        Router.shared.register(type: "GET", code: 200, pattern: "/path4?status=test1,test2") { _, _, _ in

            XCTAssertFalse(true)
            return (200, "")
        }

        _ = Router.shared.handler(for: "http://www.test.com/path4?status=test1,test2,test3&query1=test1&query2=test2", type: "GET")

        self.wait(for: [expectation], timeout: 1)
    }

    func testRouterWithPathAsPriority() {

        let expectation = XCTestExpectation(description:"testing router with long query parameter")

        Router.shared.register(type: "GET", code: 200, pattern: "/path5?status=test4,test5&query1=test1&query2=test2") { _, _, _ in

            XCTAssertFalse(true)
            return (200, "")
        }

        Router.shared.register(type: "GET", code: 200, pattern: "/path5?status=test6") { _, _, _ in

            XCTAssertFalse(true)
            return (200, "")
        }

        Router.shared.register(type: "GET", code: 200, pattern: "/path5") { url, path, values in

            XCTAssertEqual(path, "/path5")
            XCTAssertEqual(url.queryItems?.count, 3)
            XCTAssertEqual(values.count, 0)
            expectation.fulfill()

            return (200, "")
        }

        Router.shared.register(type: "GET", code: 200, pattern: "/path5?status=test1,test3") { _, _, _ in

            XCTAssertFalse(true)
            return (200, "")
        }

        _ = Router.shared.handler(for: "http://www.test.com/path5?status=test1,test2,test3&query1=test1&query2=test2", type: "GET")

        self.wait(for: [expectation], timeout: 1)
    }

    func testRouterWithSamePath() {

        let expectation = XCTestExpectation(description:"testing router with same path and different type")

        Router.shared.register(type: "GET", code: 200, pattern: "/path6") { _, _, _ in

            XCTAssertFalse(true)
            return (200, "")
        }

        Router.shared.register(type: "PUT", code: 200, pattern: "/path6") { _, _, _ in

            XCTAssertFalse(true)
            return (200, "")
        }

        Router.shared.register(type: "POST", code: 200, pattern: "/path6") { _, _, _ in

            XCTAssertFalse(true)
            return (200, "")
        }

        Router.shared.register(type: "PATCH", code: 200, pattern: "/path6") { _, path, _ in

            XCTAssertEqual(path, "/path6")
            expectation.fulfill()

            return (200, "")
        }

        _ = Router.shared.handler(for: "http://www.test.com/path6", type: "PATCH")

        self.wait(for: [expectation], timeout: 1)
    }
}
