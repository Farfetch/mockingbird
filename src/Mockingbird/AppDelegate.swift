//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Cocoa
import Sparkle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillTerminate(_:)),
                                               name: NSApplication.willTerminateNotification,
                                               object: nil)

        Tracking.initialize()

        AppStore.data.dispatch(DataAction.initialize)
        AppStore.record.dispatch(RecordAction.initialize)
        AppStore.test.dispatch(TestAction.initialize)
        AppStore.task.dispatch(TaskAction.initialize)
        ServerManager.shared.initialize()

        AppStore.task.dispatch(TaskAction.stopAll)
        ServerManager.shared.stop()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {

        NotificationCenter.default.post(name: NSApplication.willTerminateNotification, object: nil)

        return true
    }

    func applicationWillTerminate(_ aNotification: Notification) {

        ServerManager.shared.stop()
        AppStore.task.dispatch(TaskAction.stopAll)

        NSApp.terminate(self)
    }

    func applicationWillBecomeActive(_ aNotification: Notification) {
    }

    func applicationWillResignActive(_ aNotification: Notification) {
    }

    @IBAction func checkForUpdates(_ sender: Any) {
        SUUpdater.shared().checkForUpdates(nil)
    }
}
