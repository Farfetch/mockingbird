//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import XCTest
@testable import Mockingbird

class DataStoreTests: XCTestCase {

    override func setUp() {

        DataHelper.prepareData()
    }

    func testInitData() {

        let store = DataStore(reducer: DataReducer.reduce, state: nil, middleware: [])

        store.dispatch(DataAction.initialize)

        XCTAssertEqual(store.state.datas.count, 3)

        store.dispatch(DataAction.clearItems)

        XCTAssertEqual(store.state.datas.count, 0)
    }

    func testValidSetCurrentData() {

        let store = DataStore(reducer: DataReducer.reduce, state: nil, middleware: [])

        let dataFile = DataFile(title: "titleTest",
                                group: "groupTest",
                                description: "descriptionTest",
                                type: "typeTest",
                                code: 1,
                                url: "urlTest",
                                payload: "payloadTest")

        let dataInfo = DataInfo(file: dataFile, filePath: "path")

        store.dispatch(DataAction.setCurrent(data: dataInfo))

        XCTAssertNotNil(store.state.currentData)
        XCTAssertEqual(store.state.currentData?.file.title, "titleTest")
        XCTAssertEqual(store.state.currentData?.file.group, "groupTest")
        XCTAssertEqual(store.state.currentData?.file.description, "descriptionTest")
        XCTAssertEqual(store.state.currentData?.file.type, "typeTest")
        XCTAssertEqual(store.state.currentData?.file.code, 1)
        XCTAssertEqual(store.state.currentData?.file.url, "urlTest")
        XCTAssertEqual(store.state.currentData?.file.payload, "payloadTest")
        XCTAssertEqual(store.state.currentData?.filePath, "path")
    }

    func testInvalidSetCurrentData() {

        let store = DataStore(reducer: DataReducer.reduce, state: nil, middleware: [])

        XCTAssertNil(store.state.currentData)

        store.dispatch(DataAction.setCurrent(data: nil))

        XCTAssertNil(store.state.currentData)
    }

    func testUpdateDataPayload() {

        let store = DataStore(reducer: DataReducer.reduce, state: nil, middleware: [])

        store.dispatch(DataAction.initialize)

        XCTAssertEqual(store.state.datas.count, 3)

        store.dispatch(DataAction.setCurrent(data: store.state.datas[0]))

        XCTAssertNotNil(store.state.currentData)
        XCTAssertEqual(store.state.currentData?.file.title, "Data01 title")
        XCTAssertEqual(store.state.currentData?.file.group, "Data01 group")
        XCTAssertEqual(store.state.currentData?.file.description, "Data01 description")
        XCTAssertEqual(store.state.currentData?.file.type, "GET")
        XCTAssertEqual(store.state.currentData?.file.code, 200)
        XCTAssertEqual(store.state.currentData?.file.url, "/data01/path")
        XCTAssertEqual(store.state.currentData?.file.payload, "{\"title\":\"data01 json\"}")

        store.dispatch(DataAction.updateDataPayload(payload: "newpayload"))

        XCTAssertEqual(store.state.datas[0].file.payload, "newpayload")
    }

    func testUpdateStats() {

        let store = DataStore(reducer: DataReducer.reduce, state: nil, middleware: [])

        store.dispatch(DataAction.initialize)

        XCTAssertEqual(store.state.datas.count, 3)
        XCTAssertEqual(store.state.datas[0].count, 0)

        store.dispatch(DataAction.updateStats(id: store.state.datas[0].id))

        XCTAssertEqual(store.state.datas[0].count, 1)

        store.dispatch(DataAction.clearStats)

        XCTAssertEqual(store.state.datas[0].count, 0)
    }

    func testDataSelection() {

        let store = DataStore(reducer: DataReducer.reduce, state: nil, middleware: [])

        store.dispatch(DataAction.initialize)

        XCTAssertEqual(store.state.datas.count, 3)
        XCTAssertEqual(store.state.datas[0].selected, false)

        store.dispatch(DataAction.select(id: store.state.datas[0].id, selected: true))

        XCTAssertEqual(store.state.datas[0].selected, true)

        store.dispatch(DataAction.select(id: store.state.datas[0].id, selected: false))

        XCTAssertEqual(store.state.datas[0].selected, false)

        store.dispatch(DataAction.selectWithPath(path: store.state.datas[0].filePath))

        XCTAssertEqual(store.state.datas[0].selected, true)

        store.dispatch(DataAction.unselectAll)

        XCTAssertEqual(store.state.datas[0].selected, false)
    }
}
