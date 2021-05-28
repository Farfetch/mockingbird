//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation
import SwiftGui

public class OptionsView {

    func body(state: ServerState) -> GuiView {

        Group {

            Tree("Setup", options: .defaultOpen) {

                Text("Server Context")
                RadioButtonGroup(state.contextTitles, selectedIndexState: state.currentContextIndex) { val in

                    ContextManager.shared.setContext(index: val)
                }
                NewLine()

                Text("WORKING DIRECTORY: \(Default.Folder.workingDirectory)")
                LargeButton("CHANGE DIRECTORY") {

                    if let newDirectory = Util.chooseFolder() {

                        Default.Folder.savedWorkingDirectory = newDirectory

                        AppStore.data.dispatch(DataAction.initialize)
                        AppStore.test.dispatch(TestAction.initialize)
                    }
                }
                NewLine()
            }

            Divider()

            Tree("Options", options: .defaultOpen) {

                HStack {

                    LargeButton("OPEN DATA FOLDER") {

                        Util.openFinder(with: Default.Folder.main)
                    }

                    LargeButton("DOCUMENTATION") {

                        Util.openURL(url: "https://github.com/Farfetch/mockingbird/wiki")
                    }
                }
            }
        }
    }
}
