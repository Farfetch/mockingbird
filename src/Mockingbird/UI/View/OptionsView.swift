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

            Tree("Server Context", options: .defaultOpen) {

                RadioButtonGroup(state.contextTitles, selectedIndexState: state.currentContextIndex) { val in

                    ContextManager.shared.setContext(index: val)
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

            NewLine()

            Divider()

            Tree("WORKING DIRECTORY: \(Default.Folder.mockedDataDirectory)", options: .defaultOpen) {

                LargeButton("CHANGE DIRECTORY") {

                    if let newDirectory = Util.chooseFolder() {

                        Default.Folder.mockedDataDirectory = newDirectory
                    }
                }
            }
        }
    }
}
