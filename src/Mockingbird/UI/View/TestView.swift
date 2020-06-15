//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation
import SwiftGui

public class TestView {

    func body(state: TestState) -> GuiView {

        Group {

            Column(count: 2)
            ColumnWidth(index: 0, width: 350)

            self.leftPane(state: state)

            ColumnNext()

            self.rightPane(state: state)
        }
    }
}

private extension TestView {

    func cell(test: TestInfo) -> GuiView {

        Group {

            RadioButton(test.file.title, activeState: test.selected) {

                AppStore.record.dispatch(RecordAction.unselectAll)
                AppStore.data.dispatch(DataAction.unselectAll)
                AppStore.test.dispatch(TestAction.select(id: test.id, selected: !test.selected))
            }
            .activeColor(Color.green)
        }
        .identifier(test.id)
    }

    func leftPane(state: TestState) -> GuiView {

        SubWindow {

            Group {

                CollapsingHeader("options") {

                    ButtonSettings("refresh screen") {

                        AppStore.test.dispatch(TestAction.initialize)
                    }
                }
            }
            .identifier("##options_test")

            ForEach(state.tests) { item in

                self.cell(test: item)
            }

        }
        .font(Font.medium)
        .identifier("##left")
    }

    func rightPane(state: TestState) -> GuiView {

        SubWindow {

            if state.currentTest != nil {

                Tree("Details", options: .defaultOpen) {

                    Text(state.currentTest?.file.title ?? "", type: .wrapped)
                        .font(Font.medium)
                }

                Tree("Data Files", options: .defaultOpen) {

                    ForEach(state.currentTest?.file.tests ?? []) { item in

                        Text("-> \(item)")
                            .font(Font.medium)
                    }
                }

            } else {

                Text("no data")
            }
        }
        .identifier("##right")
    }
}
