//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Cocoa
import Metal
import MetalKit
import SwiftGui
import Swifter

class ViewController: MTKViewController {

    enum Views: String {

        case test
        case data
        case record
        case transaction
        case stats
        case options
    }

    private var navigation: Views = .test

    private let importView = ImportView()
    private let testView = TestView()
    private let dataView = DataView()
    private let recordView = RecordView()
    private let captureView = CaptureView()
    private let statsView = StatsView()
    private let optionsView = OptionsView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.renderer?.delegate = self
        self.renderer?.initializePlatform()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension ViewController: GuiRendererDelegate {

    func setup() {
        DefaultFontGroup().load()
        DarculaTheme().apply()
    }

    func statusServerView(serverState: ServerState, taskState: TaskState) -> GuiView {

        Group {

            if serverState.isRunning && taskState.isMitmEnabled {

                ButtonGreen("SERVER") {

                    ServerManager.shared.stop()
                    AppStore.task.dispatch(TaskAction.stopMitm)
                }

            } else {

                ButtonRed("SERVER") {

                    ServerManager.shared.start()
                    AppStore.task.dispatch(TaskAction.startMitm)
                }
            }
        }
    }

    func proxyOnView(state: TaskState) -> GuiView {

        HStack {

            Text("Proxy:")

            ButtonGreen(state.isProxyWifi ? " WI-FI " : "DEFAULT") {
                AppStore.task.dispatch(TaskAction.stopProxy)
            }
            .onHover {

                Tooltip {

                    Text(state.ipInfo)
                        .font(Font.large)
                        .textColor(Color.white)
                }
            }
        }
    }

    func proxyOffView() -> GuiView {

        HStack {

            Text("Proxy:")

            ButtonRed("DEFAULT") {

                AppStore.task.dispatch(TaskAction.startProxy(isWifi: false))
            }

            ButtonRed(" WI-FI ") {

                AppStore.task.dispatch(TaskAction.startProxy(isWifi: true))
            }
        }
    }

    func statusProxyView(state: TaskState) -> GuiView {

        Group {

            if state.isProxyEnabled {

                proxyOnView(state: state)

            } else {

                proxyOffView()
            }
        }
    }

    func statusPosition(state: TaskState) -> GuiView {

        let viewWidth = self.view.frame.width
        return SameLine(offsetX: CGPoint(x: state.isProxyEnabled ? viewWidth - 180 : viewWidth - 245, y: 0))
    }

    func statusView(serverState: ServerState, taskState: TaskState) -> GuiView {

        Group {

            self.statusPosition(state: taskState)

            HStack {

                statusServerView(serverState: serverState, taskState: taskState)
                statusProxyView(state: taskState)
            }
        }
        .font(Font.medium)
    }

    func buttonSelection(title: String, navigation: Views, active: Bool) -> GuiView {

        ButtonSelection(title, selected: self.navigation == navigation, active: active) {

            self.navigation = navigation

            if navigation == .transaction {

                AppStore.data.dispatch(DataAction.setCurrent(data: nil))

            } else if navigation == .data {

                AppStore.server.dispatch(ServerAction.setCurrent(capture: nil))
            }
        }
    }

    func navigationButton(title: String, navigation: Views) -> GuiView {

        if (navigation == .test && AppStore.test.state.currentTest != nil) ||
           (navigation == .data && AppStore.data.state.totalSelection > 0) ||
           (navigation == .record && AppStore.record.state.currentRecord != nil) {

            return self.buttonSelection(title: title, navigation: navigation, active: true)
        }

        return self.buttonSelection(title: title, navigation: navigation, active: false)
    }

    func topView(serverState: ServerState, taskState: TaskState) -> GuiView {

        Group {

            HStack {

                navigationButton(title: "Test", navigation: .test)
                navigationButton(title: "Data", navigation: .data)
                navigationButton(title: "Record", navigation: .record)
                navigationButton(title: "Capture", navigation: .transaction)
                navigationButton(title: "Stats", navigation: .stats)

                Spacing()
                Spacing()
                Spacing()
                Spacing()

                navigationButton(title: "Settings", navigation: .options)
            }

            statusView(serverState: serverState, taskState: taskState)

            Divider()
        }
    }

    func currentView() -> GuiView {

        switch self.navigation {

        case .test:

            guard AppStore.test.state.tests.count > 0 else {
                return self.importView.body(frame: self.view.frame) {
                    AppStore.test.dispatch(TestAction.initialize)
                }
            }

            return self.testView.body(state: AppStore.test.state)
        case .data:

            guard AppStore.data.state.datas.count > 0 else {
                return self.importView.body(frame: self.view.frame) {
                    AppStore.data.dispatch(DataAction.initialize)
                }
            }

            return self.dataView.body(state: AppStore.data.state)
        case .record:
            return self.recordView.body(state: AppStore.record.state)
        case .transaction:
            return self.captureView.body(state: AppStore.server.state)
        case .stats:
            return self.statsView.body(state: AppStore.server.state)
        case .options:
            return self.optionsView.body(state: AppStore.server.state)
        }
    }

    func mainView() -> GuiView {

        Window("Mockingbird", options: [.noTitleBar, .noMove, .noResize]) {

            topView(serverState: AppStore.server.state, taskState: AppStore.task.state)

            currentView()
        }
        .position(CGPoint(x: 0, y: 0), condition: .always)
        .size(CGSize(width: self.view.frame.width,
                     height: self.view.frame.height), condition: .always)
        .font(Font.xlarge)
    }

    func draw() {

        if !NSApplication.shared.isActive {

            // reducing cpu usage
            Thread.sleep(forTimeInterval: 0.05)
        }

        mainView().render()
    }
}
