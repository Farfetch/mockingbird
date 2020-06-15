//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation
import ReSwift
import Zip
import Files

class DataReducer {

    static func reduce(_ action: Action, state: DataState?) -> DataState {

        var state = state ?? DataState()

        guard let action = action as? DataAction else {
            return state
        }

        switch action {

        case .initialize:

            Self.initialize(with: &state)

        case .setCurrent(let data):

            state.currentData = data

        case .updateDataPayload(let payload):

            Self.updateCurrentData(with: &state, payload: payload)

        case .updateStats(let id):

            if let row = state.datas.firstIndex(where: { $0.id == id }) {
                state.datas[row].count += 1
            }

        case .clearStats:

            state.datas.indices.forEach { state.datas[$0].count = 0 }

        case .clearItems:

            state.datas.removeAll()

        case .select(let id, let selected):

            Self.selectData(with: &state, id: id, selected: selected)

        case .selectWithPath(let path):

            state.datas.forEach { data in

                if data.filePath.contains(path) {

                    Self.selectData(with: &state, id: data.id, selected: true)
                }
            }

        case .unselectAll:

            Self.unselectAll(with: &state)

        case .setDetailedInfo:

            state.detailedInfo.toggle()
        }

        return state
    }
}

private extension DataReducer {

    static func initialize(with state: inout DataState) {

        do {

            try FileManager.default.createDirectory(atPath: Default.Folder.data, withIntermediateDirectories: true, attributes: nil)

            state.currentData = nil
            state.datas.removeAll()

            let dataFolder = try Folder(path: Default.Folder.data)

            dataFolder.files.enumerated().forEach { _, file in

                if let fileData = try? file.readAsString() {

                    if let model = try? DataFile(fileData) {

                        state.datas.append(DataInfo(file: model, filePath: file.path))
                    }
                }
            }

        } catch {

            _log(type: .error, log: error.localizedDescription)
        }
    }

    static func selectData(with state: inout DataState, id: String, selected: Bool) {

        if let row = state.datas.firstIndex(where: { $0.id == id }) {

            if selected {

                state.datas[row].selected = true
                state.totalSelection += 1

                let currentInfo = state.datas[row]
                Self.handlingRegister(with: id, info: currentInfo)

            } else {

                state.datas[row].selected = false
                state.totalSelection -= 1
                Router.shared.unregister(state.datas[row].file.url)
            }
        }
    }

    static func updateCurrentData(with state: inout DataState, payload: String) {

        if let currenData = state.currentData,
            let row = state.datas.firstIndex(where: { $0.id == currenData.id }) {

            state.datas[row].file.payload = payload
            let currentInfo = state.datas[row]

            Router.shared.unregister(currentInfo.file.url)
            Self.handlingRegister(with: currenData.id, info: currentInfo)
        }
    }

    static func unselectAll(with state: inout DataState) {

        state.datas.indices.forEach { state.datas[$0].selected = false }
        state.totalSelection = 0
        Router.shared.clear()
    }

    static func handlingRegister(with id: String, info: DataInfo) {

        Router.shared.register(type: info.file.type,
                               code: info.file.code,
                               pattern: info.file.url) { _, _, values in

            AppStore.data.dispatch(DataAction.updateStats(id: id))

            var adjustedData = info.file.payload

            for queryItem in values {

                adjustedData = adjustedData.replacingOccurrences(of: "<\(queryItem.key)>", with: "\(queryItem.value)")
            }

            return (info.file.code, adjustedData)
        }
    }
}
