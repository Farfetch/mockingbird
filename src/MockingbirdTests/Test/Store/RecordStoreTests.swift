//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import XCTest
@testable import Mockingbird

class RecordStoreTests: XCTestCase {

    override func setUp() {

        DataHelper.prepareRecord()
    }

    func testInitData() {

        let store = RecordStore(reducer: RecordReducer.reduce, state: nil, middleware: [])

        store.dispatch(RecordAction.initialize)

        XCTAssertTrue(store.state.records.count > 0)
        XCTAssertEqual(store.state.records[0].items.count, 2)
    }

    func testValidSetCurrentRecord() {

        let store = RecordStore(reducer: RecordReducer.reduce, state: nil, middleware: [])

        let recordFile = RecordFile(type: "typeTest",
                                    code: 1,
                                    url: "urlTest",
                                    payload: "payloadTest")

        let record = RecordInfo(file: recordFile, filePath: "path")
        let recordGroup = RecordGroupInfo(name: "recordGroupTest", items: [record])

        store.dispatch(RecordAction.setCurrent(record: recordGroup))

        XCTAssertNotNil(store.state.currentRecord)
        XCTAssertEqual(store.state.currentRecord?.items.count, 1)

        let checkFile = store.state.currentRecord?.items[0].file
        XCTAssertEqual(checkFile?.type, "typeTest")
        XCTAssertEqual(checkFile?.code, 1)
        XCTAssertEqual(checkFile?.url, "urlTest")
        XCTAssertEqual(checkFile?.payload, "payloadTest")

        store.dispatch(RecordAction.refreshSelected)
        let checkFileRefresh = store.state.currentRecord?.items[0].file
        XCTAssertEqual(checkFileRefresh?.type, "typeTest")
        XCTAssertEqual(checkFileRefresh?.code, 1)
        XCTAssertEqual(checkFileRefresh?.url, "urlTest")
        XCTAssertEqual(checkFileRefresh?.payload, "payloadTest")
    }

    func testInvalidSetCurrentRecord() {

        let store = RecordStore(reducer: RecordReducer.reduce, state: nil, middleware: [])

        XCTAssertNil(store.state.currentRecord)

        store.dispatch(RecordAction.setCurrent(record: nil))

        XCTAssertNil(store.state.currentRecord)
    }

    func testUpdateStats() {

        let store = RecordStore(reducer: RecordReducer.reduce, state: nil, middleware: [])

        store.dispatch(RecordAction.initialize)

        XCTAssertTrue(store.state.records.count > 0)
        XCTAssertEqual(store.state.records[0].items.count, 2)

        store.dispatch(RecordAction.setCurrent(record: store.state.records[0]))

        XCTAssertNotNil(store.state.currentRecord)

        store.dispatch(RecordAction.updateStats(id: store.state.currentRecord?.items[0].id ?? ""))

        XCTAssertEqual(store.state.currentRecord?.items[0].count, 1)

        store.dispatch(RecordAction.clearStats)

        XCTAssertEqual(store.state.currentRecord?.items[0].count, 0)
    }

    func testActiveRecord() {

        let store = RecordStore(reducer: RecordReducer.reduce, state: nil, middleware: [])

        store.dispatch(RecordAction.initialize)

        XCTAssertTrue(store.state.records.count > 0)
        XCTAssertEqual(store.state.records[0].items.count, 2)

        store.dispatch(RecordAction.setCurrent(record: store.state.records[0]))

        XCTAssertNotNil(store.state.currentRecord)

        store.dispatch(RecordAction.updateActive(id: store.state.currentRecord?.items[0].id ?? "", active: false))

        XCTAssertEqual(store.state.currentRecord?.items[0].active, false)

        store.dispatch(RecordAction.updateActive(id: store.state.currentRecord?.items[0].id ?? "", active: true))

        XCTAssertEqual(store.state.currentRecord?.items[0].active, true)
    }

    func testSelectRecord() {

        let store = RecordStore(reducer: RecordReducer.reduce, state: nil, middleware: [])

        store.dispatch(RecordAction.initialize)

        XCTAssertTrue(store.state.records.count > 0)
        XCTAssertEqual(store.state.records[0].items.count, 2)

        store.dispatch(RecordAction.setCurrent(record: store.state.records[0]))

        XCTAssertNotNil(store.state.currentRecord)

        XCTAssertEqual(store.state.currentRecord?.selected, false)

        store.dispatch(RecordAction.select(id: store.state.currentRecord!.id, selected: true))

        XCTAssertEqual(store.state.currentRecord?.selected, true)
    }
}
