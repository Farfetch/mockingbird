//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation
import ReSwift
import Files

class RecordReducer {

    static func reduce(_ action: Action, state: RecordState?) -> RecordState {

        var state = state ?? RecordState()

        guard let action = action as? RecordAction else {
            return state
        }

        switch action {

        case .initialize:

            Self.initialize(with: &state)

        case .setCurrent(let record):

            state.currentRecord = record

        case .updateStats(let id):

            if let row = state.currentRecord?.items.firstIndex(where: { $0.id == id }) {

                state.currentRecord?.items[row].count += 1
            }

        case .updateActive(let id, let active):

            if let row = state.currentRecord?.items.firstIndex(where: { $0.id == id }) {

                state.currentRecord?.items[row].active = active
            }

        case .clearStats:

            if let currentRecord = state.currentRecord {

                currentRecord.items.indices.forEach { state.currentRecord?.items[$0].count = 0 }
            }

        case .refreshSelected:

            if let currentRecord = state.currentRecord {

                Self.selectRecord(with: &state, id: currentRecord.id, selected: true, isRefresh: true)
            }

        case .select(let id, let selected):

            Self.selectRecord(with: &state, id: id, selected: selected)

        case .selectReplayAndPop:

            state.isReplayAndPop.toggle()

        case .unselectAll:

            Self.unselectAll(with: &state)
        }

        return state
    }
}

private extension RecordReducer {

    static func initialize(with state: inout RecordState) {

        do {

            try FileManager.default.createDirectory(atPath: Default.Folder.record, withIntermediateDirectories: true, attributes: nil)

            state.currentRecord = nil
            state.records.removeAll()

            let recordFolder = try Folder(path: Default.Folder.record)

            recordFolder.subfolders.recursive.forEach { folder in

                var dataFiles: [RecordInfo] = []

                folder.files.enumerated().forEach { _, file in

                    if let fileData = try? file.readAsString() {

                        if let model = try? RecordFile(fileData) {

                            dataFiles.append(RecordInfo(file: model, filePath: file.path))
                        }
                    }
                }

                state.records.append(RecordGroupInfo(name: folder.name, items: dataFiles))
            }

            state.records = state.records.sorted { $0.name > $1.name }

        } catch {

            _log(type: .error, log: error.localizedDescription)
        }
    }

    static func selectRecord(with state: inout RecordState, id: String, selected: Bool, isRefresh: Bool = false) {

        if selected {

            AppStore.data.dispatch(DataAction.unselectAll)
            AppStore.test.dispatch(TestAction.unselectAll)

            if let row = state.records.firstIndex(where: { $0.id == id }) {

                let isReplayAndPopActive = state.isReplayAndPop
                var isSelected = selected

                if !isRefresh {

                    isSelected = !state.records[row].selected

                    Self.unselectAll(with: &state)

                    state.records[row].selected = isSelected

                } else {

                    Router.shared.clear()
                }

                if isSelected {

                    state.currentRecord = state.records[row]

                    state.records[row].items.forEach { item in

                        Router.shared.register(type: item.file.type,
                                               code: item.file.code,
                                               pattern: item.file.url) { _, _, values in

                            AppStore.record.dispatch(RecordAction.updateStats(id: item.id))

                            var adjustedData = item.file.payload

                            for queryItem in values {

                                adjustedData = adjustedData.replacingOccurrences(of: "<\(queryItem.key)>", with: "\(queryItem.value)")
                            }

                            if isReplayAndPopActive {

                                AppStore.record.dispatch(RecordAction.updateActive(id: item.id, active: false))
                                Router.shared.unregister(item.file.url)
                            }

                            return (item.file.code, adjustedData)
                        }
                    }
                }
            }

        } else {

            Self.unselectAll(with: &state)
        }
    }

    static func unselectAll(with state: inout RecordState) {

        state.records.indices.forEach { state.records[$0].selected = false }
        state.currentRecord = nil
        Router.shared.clear()
    }
}
