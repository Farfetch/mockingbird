//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation
import SwiftGui

public class HelpView {

    func body() -> GuiView {

        Tree("Help", options: .defaultOpen) {

            helpGroup()
        }
    }
}

private extension HelpView {

    func helpGroup() -> GuiView {

        Group {

            Text("Obs. In order to use this tool you need MITMProxy installed through Homebrew.", type: .wrapped)

            NewLine()

            self.helpWithMitm()
            self.helpWithIOS()
            self.helpWithAndroid()
            self.helpWithRecord()
            self.helpWithServerContext()
        }
    }

    func helpWithMitm() -> GuiView {

        Tree("Install MITMProxy") {

            Text("1 - Install Homebrew app on OSX", type: .bullet)
            Button("Open homebrew web link for more information") {

                Util.openURL(url: "https://brew.sh")
            }

            Text("2 - Type on terminal: brew install mitmproxy", type: .bullet)
            Button("Copy command to clipboard") {

                Util.saveToClipboard("brew install mitmproxy")
            }

            Text("done!", type: .bullet)
            NewLine()
        }
    }

    func helpWithIOS() -> GuiView {

        Tree("iOS") {

            Tree("Configuring device") {

                Text("1 - Go to Settings App", type: .bullet)
                Text("2 - Tap Wi-Fi menu", type: .bullet)
                Text("3 - Select the same network as computer", type: .bullet)
                Text("4 - Tap on the network item and tap on 'Configure Proxy'", type: .bullet)
                Text("5 - Select 'Manual'", type: .bullet)
                Text("6 - Set the Server Ip (computer Ip), Port: 8080 and tap Save", type: .bullet)
                Text("done!", type: .bullet)
                NewLine()
            }

            Tree("Installing certificate") {

                Text("1 - Follow the 'Configuring a device' steps", type: .bullet)
                Text("2 - Start the SERVER and PROXY", type: .bullet)
                Text("3 - Open the SAFARI browser at your device and go to: mitm.it", type: .bullet)
                Text("4 - Tap the target platform to install the certificate", type: .bullet)
                Text("5 - Go to 'GENERAL->PROFILE' to finish installation", type: .bullet)
                Text("6 - Go to 'GENERAL->ABOUT->CERTIFICATE TRUST SETTINGS', to enable it", type: .bullet)
                Text("done!", type: .bullet)
                NewLine()
            }
        }
    }

    func helpWithAndroid() -> GuiView {

        Tree("Android") {

            Tree("Configuring device") {

                Text("1 - Go to SETTINGS->CONNECTIONS", type: .bullet)
                Text("2 - Tap Wi-Fi menu", type: .bullet)
                Text("3 - Select the same network as computer", type: .bullet)
                Text("4 - Open the conection's config screen", type: .bullet)
                Text("5 - Select 'Advanced'", type: .bullet)
                Text("5 - Select 'Manual' on Proxy item", type: .bullet)
                Text("6 - Set the Server Ip (computer Ip), Port: 8080 and tap Save", type: .bullet)
                Text("done!", type: .bullet)
                NewLine()
            }

            Tree("Installing certificate") {

                Text("1 - Follow the 'Configuring a device' steps", type: .bullet)
                Text("2 - Start the SERVER and PROXY", type: .bullet)
                Text("3 - Open the browser at your device and go to: mitm.it", type: .bullet)
                Text("4 - Tap the target platform to install the certificate", type: .bullet)
                Text("5 - Set a certificate name and tap OK", type: .bullet)
                Text("done!", type: .bullet)
                NewLine()
            }
        }
    }

    func helpWithRecord() -> GuiView {

        Tree("Recording data") {

            Tree("How to record?") {

                Text("1 - Go to 'Capture' screen", type: .bullet)
                Text("2 - Start capture something", type: .bullet)
                Text("3 - Tap 'Save Record' and confirm the dialog", type: .bullet)
                Text("done!", type: .bullet)
                NewLine()
            }

            Tree("How to use?") {

                Text("1 - Go to 'Record' screen", type: .bullet)
                Text("2 - Tap any record on the list", type: .bullet)
                Text("done!", type: .bullet)
                NewLine()
            }

            Tree("How to import external recorded data?") {

                Text("1 - Go to 'Options' screen", type: .bullet)
                Text("2 - Tap 'Open Data Folder'", type: .bullet)
                Text("3 - Open the 'record' folder", type: .bullet)
                Text("4 - Copy the new folder with recorded files inside (ex. /record/folder_test/", type: .bullet)
                Text("5 - Go to 'Record' screen, tap 'Options->refresh screen'", type: .bullet)
                Text("done!", type: .bullet)
                NewLine()
            }
        }
    }

    func helpWithServerContext() -> GuiView {

        Tree("Server context") {

            Text("You can choose the server capture context, by choosing between 'All' and a custom definition", type: .wrapped)

            NewLine()

            Tree("What exactly this mean?", options: .defaultOpen) {

                Text("This will filter any transaction by an specific pattern", type: .bullet)
                Text("If you choose 'All', all decoded transactions will be captured", type: .bullet)
                Text("If you choose custom, will only be captured transactions with pattern declared in custom file", type: .bullet)
                NewLine()
            }

            Tree("How can I create a custom definition?", options: .defaultOpen) {

                Text("You should add/configure the context.json (see pattern on repo sample) file inside main folder", type: .bullet)
                Text("Every transaction containing anything declared on 'paths' will be recorded", type: .bullet)
                Text("Note: If you have a custom context, this will be configured as default", type: .bullet)
                NewLine()
            }
        }
    }
}
