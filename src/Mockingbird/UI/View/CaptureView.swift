//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation
import SwiftGui

public class CaptureView {

    func body(state: ServerState) -> GuiView {

        Group {

            Column(count: 2)

            self.leftPane(state: state)

            ColumnNext()

            self.rightPane(state: state)

            self.updateTextIfNeeded(state: state)
        }
    }
}

private extension CaptureView {

    func cell(state: ServerState, capture: ServerCapture) -> GuiView {

        Group {

            if capture.isMock {

                ButtonGreen("\(capture.responseStatusCode): \(capture.requestMethod) \(capture.urlPath) - \(capture.bytesString)") {

                    AppStore.server.dispatch(ServerAction.setCurrent(capture: capture))
                }

            } else {

                if capture.responseStatusCode < 200 || capture.responseStatusCode > 299 {

                    ButtonRed("") {

                        AppStore.server.dispatch(ServerAction.setCurrent(capture: capture))
                    }

                    SameLine()
                }

                Button("\(capture.responseStatusCode): \(capture.requestMethod) \(capture.urlPath) - \(capture.bytesString)") {

                    AppStore.server.dispatch(ServerAction.setCurrent(capture: capture))
                }
                .hoveredColor(Color.gray)
            }
        }
        .identifier(capture.id)
    }

    func leftPane(state: ServerState) -> GuiView {

        SubWindow {

            Group {

                CollapsingHeader("options") {

                    ButtonSettings("backup capture") {

                        AppStore.server.dispatch(ServerAction.saveFiles(shouldPopupFolder: true))
                    }
                }
            }
            .identifier("##options_capture")

            Button("Clear") {

                AppStore.server.dispatch(ServerAction.clearCapture)
            }

            SameLine()

            Button("Save Record") {

                Popup.open("##capturedata")
            }

            ConfirmationPopup(id: "##capturedata",
                              title: "Really want to save capture?",
                              yes: {

                AppStore.server.dispatch(ServerAction.saveRecord)
            })

            SameLine()

            Text("context: \(state.currentContext?.context ?? "all")")

            Divider()

            List(buffer: state.captures, itemHeight: 20) { _, capture in

                return self.cell(state: state, capture: capture)
            }
            .identifier("##trans")

        }
        .font(Font.medium)
        .identifier("##left")
    }

    func rightPane(state: ServerState) -> GuiView {

        SubWindow {

            if state.currentCapture != nil {

                self.rightPaneTop(state: state)

                SmallButtonSelection("request", selected: state.isRequestSelected) {

                    AppStore.server.dispatch(ServerAction.select(selected: true))
                }

                SameLine()

                SmallButtonSelection("response (\(state.currentCapture?.responseStatusCode ?? 0))", selected: !state.isRequestSelected) {

                    AppStore.server.dispatch(ServerAction.select(selected: false))
                }

                TextEditor("data view")

            } else {

                Text("no data")
            }
        }
        .identifier("##right")
    }

    func rightPaneTop(state: ServerState) -> GuiView {

        Group {

            Button("copy") {

                AppStore.server.dispatch(ServerAction.saveCurrentToClipboard)

            }
            .font(Font.medium)

            SameLine()

            Text("\(state.currentCapture?.requestMethod ?? ""): \(state.currentCapture?.urlPath ?? "")", type: .wrapped)

            CollapsingHeader("Full URL") {

                Text(state.currentCapture?.url ?? "", type: .wrapped)

            }
            .font(Font.medium)
        }
    }

    func updateTextIfNeeded(state: ServerState) -> GuiView {

        Perform {

            if state.refreshView {

                TextEditor.setReadOnly(true)
                TextEditor.setColorizerEnable(false)

                let data = state.isRequestSelected ? (state.currentCapture?.requestFormatted ?? "no data") : (state.currentCapture?.responseFormatted ?? "no data")
                TextEditor.setText(data)

                AppStore.server.dispatch(ServerAction.clearRefresh)
            }

            return nil
        }
    }
}
