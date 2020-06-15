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

            Tree("Data Options", options: .defaultOpen) {

                LargeButton("OPEN DATA FOLDER") {

                    Util.openFinder(with: Default.Folder.main)
                }
            }
        }
    }
}
