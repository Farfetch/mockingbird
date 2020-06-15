//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import XCTest
@testable import Mockingbird

class TestStoreTests: XCTestCase {

    override func setUp() {

        DataHelper.prepareTest()
    }

    func testInitData() {

        let store = TestStore(reducer: TestReducer.reduce, state: nil, middleware: [])

        store.dispatch(TestAction.initialize)

        XCTAssertEqual(store.state.tests.count, 2)
    }

    func testDataSelection() {

        let store = TestStore(reducer: TestReducer.reduce, state: nil, middleware: [])

        store.dispatch(TestAction.initialize)

        XCTAssertEqual(store.state.tests.count, 2)
        XCTAssertEqual(store.state.tests[0].selected, false)

        store.dispatch(TestAction.select(id: store.state.tests[0].id, selected: true))

        XCTAssertEqual(store.state.tests[0].selected, true)

        store.dispatch(TestAction.select(id: store.state.tests[0].id, selected: false))

        XCTAssertEqual(store.state.tests[0].selected, false)

        store.dispatch(TestAction.unselectAll)

        XCTAssertEqual(store.state.tests[0].selected, false)
    }
}
