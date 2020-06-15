//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import XCTest
@testable import Mockingbird

class ServerStoreTests: XCTestCase {

    func testInitServer() {

        DataHelper.prepareServer()

        let store = ServerStore(reducer: ServerReducer.reduce, state: nil, middleware: [])

        store.dispatch(ServerAction.initialize)

        XCTAssertEqual(ContextManager.shared.contexts.count, 2)
        XCTAssertEqual(store.state.contextTitles.count, 2)
    }

    func testStartStopServer() {

        let store = ServerStore(reducer: ServerReducer.reduce, state: nil, middleware: [])

        store.dispatch(ServerAction.start)

        XCTAssertEqual(store.state.isRunning, true)

        store.dispatch(ServerAction.stop)

        XCTAssertEqual(store.state.isRunning, false)
    }

    func testValidSetCurrentCapture() {

        let store = ServerStore(reducer: ServerReducer.reduce, state: nil, middleware: [])

        let capture = ServerCapture(url: "www.test.com",
                                    urlPath: "/test",
                                    queryParams: "query1=1234",
                                    requestMethod: "GET",
                                    requestFormatted: "no data",
                                    responseFormatted: "no data",
                                    responseStatusCode: 1,
                                    original: "no data",
                                    mocked: false,
                                    isMock: false,
                                    bytesString: "1234")

        store.dispatch(ServerAction.setCurrent(capture: capture))

        XCTAssertNotNil(store.state.currentCapture)
        XCTAssertEqual(store.state.currentCapture?.url, "www.test.com")
        XCTAssertEqual(store.state.currentCapture?.urlPath, "/test")
        XCTAssertEqual(store.state.currentCapture?.queryParams, "query1=1234")
        XCTAssertEqual(store.state.currentCapture?.requestMethod, "GET")
        XCTAssertEqual(store.state.currentCapture?.requestFormatted, "no data")
        XCTAssertEqual(store.state.currentCapture?.responseFormatted, "no data")
        XCTAssertEqual(store.state.currentCapture?.responseStatusCode, 1)
        XCTAssertEqual(store.state.currentCapture?.original, "no data")
        XCTAssertEqual(store.state.currentCapture?.mocked, false)
        XCTAssertEqual(store.state.currentCapture?.isMock, false)
        XCTAssertEqual(store.state.currentCapture?.bytesString, "1234")
    }

    func testInvalidSetCurrentCapture() {

        let store = ServerStore(reducer: ServerReducer.reduce, state: nil, middleware: [])

        XCTAssertNil(store.state.currentCapture)

        store.dispatch(ServerAction.setCurrent(capture: nil))

        XCTAssertNil(store.state.currentCapture)
    }

    func testAddingCapture() {

        DataHelper.prepareServer()

        let store = ServerStore(reducer: ServerReducer.reduce, state: nil, middleware: [])

        let capture = ServerCapture(url: "www.test.com",
                                    urlPath: "/test",
                                    queryParams: "query1=1234",
                                    requestMethod: "GET",
                                    requestFormatted: "no data",
                                    responseFormatted: "no data",
                                    responseStatusCode: 1,
                                    original: "no data",
                                    mocked: false,
                                    isMock: false,
                                    bytesString: "1234")

        XCTAssertEqual(store.state.captures.count, 0)

        store.dispatch(ServerAction.addCapture(capture: capture))

        XCTAssertEqual(store.state.captures.count, 1)

        store.dispatch(ServerAction.saveFiles(shouldPopupFolder: false))
        store.dispatch(ServerAction.saveRecord)

        store.dispatch(ServerAction.clearCapture)

        XCTAssertEqual(store.state.captures.count, 0)
    }

    func testUpdateStats() {

        let store = ServerStore(reducer: ServerReducer.reduce, state: nil, middleware: [])

        XCTAssertEqual(store.state.statsHistory.count, 0)
        XCTAssertEqual(store.state.stats.count, 0)

        store.dispatch(ServerAction.updateStats(pattern: "/test", stat: 10))

        XCTAssertEqual(store.state.statsHistory.count, 1)
        XCTAssertEqual(store.state.stats.count, 1)
        XCTAssertEqual(store.state.stats[0].bytes, 10)

        store.dispatch(ServerAction.updateStats(pattern: "/test", stat: 20))

        XCTAssertEqual(store.state.statsHistory.count, 2)
        XCTAssertEqual(store.state.stats.count, 1)
        XCTAssertEqual(store.state.stats[0].bytes, 30)

        store.dispatch(ServerAction.clearStats)

        XCTAssertEqual(store.state.statsHistory.count, 0)
        XCTAssertEqual(store.state.stats.count, 0)
    }

    func testGeneralStats() {

        let store = ServerStore(reducer: ServerReducer.reduce, state: nil, middleware: [])

        XCTAssertEqual(store.state.statsHistory.count, 0)
        XCTAssertEqual(store.state.stats.count, 0)

        store.dispatch(ServerAction.saveCurrentToClipboard)
        store.dispatch(ServerAction.clearRefresh)

        XCTAssertEqual(store.state.isRequestSelected, true)

        store.dispatch(ServerAction.select(selected: false))

        XCTAssertEqual(store.state.isRequestSelected, false)
    }
}
