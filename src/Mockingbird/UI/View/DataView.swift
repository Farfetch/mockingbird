//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation
import SwiftGui

public class DataView {

    func body(state: DataState) -> GuiView {

        Group {

            Column(count: 2)

            self.leftPane(state: state)

            ColumnNext()

            self.rightPane(state: state)
        }
    }
}

private extension DataView {

    func cell(state: DataState, data: DataInfo) -> GuiView {

        Group {

            HStack {

                CheckBox(selectedState: data.selected) { selected in

                    AppStore.test.dispatch(TestAction.unselectAll)
                    AppStore.data.dispatch(DataAction.select(id: data.id, selected: selected))
                }
                .activeColor(Color.green)

                ButtonSelection(data.file.title,
                                selected: state.currentData?.id == data.id) {

                    AppStore.data.dispatch(DataAction.setCurrent(data: data))

                    self.setText(text: data.file.payload)
                }

                if data.count > 0 {

                    Text("\(data.count)")
                        .textColor(Color.yellow)
                        .font(Font.large)
                }
            }

            if state.detailedInfo {

                Text(self.dataDetails(data: data))
                    .font(Font.small)

                Divider()
            }
        }
        .identifier(data.id)
    }

    func leftPane(state: DataState) -> GuiView {

        SubWindow {

            Group {

                CollapsingHeader("options") {

                    HStack {

                        ButtonSettings("refresh screen") {

                            AppStore.data.dispatch(DataAction.initialize)
                        }

                        ButtonSettings("clear stats") {

                            AppStore.data.dispatch(DataAction.clearStats)
                        }

                        ButtonSettings("detailed") {

                            AppStore.data.dispatch(DataAction.setDetailedInfo)
                        }
                    }
                }
            }
            .identifier("##options_data")

            ForEach(state.datas) { item in

                self.cell(state: state, data: item)
            }
        }
        .font(Font.medium)
        .identifier("##left")
    }

    func rightPane(state: DataState) -> GuiView {

        SubWindow {

            if state.currentData != nil {

                Text(self.dataDetails(data: state.currentData), type: .wrapped)
                    .font(Font.medium)

                TextEditor("data edit") { text in

                    AppStore.data.dispatch(DataAction.updateDataPayload(payload: text))
                }

            } else {

                Text("no data")
            }
        }
        .identifier("##right")
    }

    func dataDetails(data: DataInfo?) -> String {

        guard let data = data else {
            return ""
        }

        return "\(data.file.code): \(data.file.type) \(data.file.url)"
    }

    func setText(text: String) {

        TextEditor.setReadOnly(false)
        TextEditor.setColorizerEnable(true)
        TextEditor.setText(text)
    }
}
