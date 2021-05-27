//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Cocoa

class Util {

    static func saveToClipboard(_ value: String?) {

        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        pasteboard.setString(value ?? "no data", forType: NSPasteboard.PasteboardType.string)
    }

    static func openFinder(with folder: String) {

        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: folder)
    }

    static func chooseFolder() -> String? {

        let dialog = NSOpenPanel()

        dialog.title = "Choose mocked data directory"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {

            let result = dialog.url
            return result?.path

        } else {

            return nil
        }
    }

    static func openURL(url: String) {

        if let url = URL(string: url) {

            NSWorkspace.shared.open(url)
        }
    }
}
