//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation
import SwiftGui

public class RecordView {

    func body(state: RecordState) -> GuiView {

        Group {

            Column(count: 2)

            self.leftPane(state: state)

            ColumnNext()

            self.rightPane(state: state)
        }
    }
}

private extension RecordView {

    func cellNormal(record: RecordInfo) -> GuiView {

        HStack {

            Text("\(record.count)")
                .textColor(Color.yellow)
                .font(Font.medium)

            Text(record.file.url, type: .wrapped)
                .textColor(record.count > 0 ? Color.yellow : Color.white)
        }
    }

    func cellReplayAndPop(record: RecordInfo) -> GuiView {

        Text(record.file.url, type: .wrapped)
            .textColor(record.active ? Color.white : Color.red)
    }

    func cell(state: RecordState, record: RecordInfo) -> GuiView {

        Group {

            if state.isReplayAndPop {

                cellReplayAndPop(record: record)

            } else {

                cellNormal(record: record)
            }
        }
        .identifier(record.id)
    }

    func cellTree(record: RecordGroupInfo) -> GuiView {

        Group {

            RadioButton(record.name, activeState: record.selected) {

                if record.selected {
                    AppStore.data.dispatch(DataAction.unselectAll)
                }

                AppStore.record.dispatch(RecordAction.select(id: record.id, selected: !record.selected))
            }
            .activeColor(Color.green)
        }
        .identifier(record.id)
    }

    func leftPane(state: RecordState) -> GuiView {

        SubWindow {

            Group {

                CollapsingHeader("options") {

                    HStack {

                        ButtonSettings("refresh screen") {

                            AppStore.record.dispatch(RecordAction.initialize)
                        }

                        ButtonSettings("clear stats") {

                            AppStore.record.dispatch(RecordAction.clearStats)
                        }
                    }
                }
            }
            .identifier("##options_record")

            ButtonSelection("Replay & Pop", selected: state.isReplayAndPop, active: state.isReplayAndPop) {

                AppStore.record.dispatch(RecordAction.selectReplayAndPop)
                AppStore.record.dispatch(RecordAction.refreshSelected)
            }

            Divider()

            ForEach(state.records) { record in

                self.cellTree(record: record)
            }

        }
        .font(Font.medium)
        .identifier("##left")
    }

    func rightPane(state: RecordState) -> GuiView {

        SubWindow {

            if state.currentRecord != nil {

                ForEach(state.currentRecord?.items ?? []) { item in

                    self.cell(state: state, record: item)
                }

            } else {

                Text("no data")
            }
        }
        .identifier("##right")
    }
}
