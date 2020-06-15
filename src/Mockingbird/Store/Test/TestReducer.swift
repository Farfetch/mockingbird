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

class TestReducer {

    static func reduce(_ action: Action, state: TestState?) -> TestState {

        var state = state ?? TestState()

        guard let action = action as? TestAction else {
            return state
        }

        switch action {

        case .initialize:

            Self.initialize(with: &state)

        case .select(let id, let selected):

            Self.selectTest(with: &state, id: id, selected: selected)

        case .unselectAll:

            Self.unselectAll(with: &state)
        }

        return state
    }
}

private extension TestReducer {

    static func initialize(with state: inout TestState) {

        do {

            try FileManager.default.createDirectory(atPath: Default.Folder.test, withIntermediateDirectories: true, attributes: nil)

            state.tests.removeAll()

            let testFolder = try Folder(path: Default.Folder.test)

            testFolder.files.enumerated().forEach { _, file in

                if let fileData = try? file.readAsString() {

                    if let model = try? TestFile(fileData) {

                        state.tests.append(TestInfo(file: model, filePath: file.path))
                    }
                }
            }
        } catch {

            _log(type: .error, log: error.localizedDescription)
        }
    }

    static func selectTest(with state: inout TestState, id: String, selected: Bool) {

        if selected {

            if let row = state.tests.firstIndex(where: { $0.id == id }) {

                let isSelected = !state.tests[row].selected

                Self.unselectAll(with: &state)

                state.tests[row].selected = isSelected

                if isSelected {

                    state.currentTest = state.tests[row]

                    state.tests[row].file.tests.forEach { path in

                        AppStore.data.dispatch(DataAction.selectWithPath(path: path))
                    }
                }
            }

        } else {

            Self.unselectAll(with: &state)
        }
    }

    static func unselectAll(with state: inout TestState) {

        state.tests.indices.forEach { state.tests[$0].selected = false }
        state.currentTest = nil
    }

}
