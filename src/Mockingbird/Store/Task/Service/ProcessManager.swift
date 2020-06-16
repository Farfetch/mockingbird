//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation

struct ProcessObject {

    let type: ProcessType
    let script: String
    let ignoreReturn: Bool
}

enum ProcessType {

    case proxyOn
    case proxyWifiOn
    case proxyOff
    case mitmOn
    case mitmOff
    case ipInfo

    var command: ProcessObject {

        switch self {

        case .proxyOn: return ProcessObject(type: self, script: "proxy_on", ignoreReturn: true)
        case .proxyWifiOn: return ProcessObject(type: self, script: "proxy_wifi_on", ignoreReturn: true)
        case .proxyOff: return ProcessObject(type: self, script: "proxy_off", ignoreReturn: true)
        case .mitmOn: return ProcessObject(type: self, script: "mitm_on", ignoreReturn: false)
        case .mitmOff: return ProcessObject(type: self, script: "mitm_off", ignoreReturn: true)
        case .ipInfo: return ProcessObject(type: self, script: "ip_info", ignoreReturn: false)
        }
    }
}

final class ProcessManager {

    static let shared = ProcessManager()

    func execute(process: ProcessType) {

        self.executeInternal(process: process)
    }
}

private extension ProcessManager {

    @discardableResult
    func executeProcess(launch: String, arg: [String]?) -> Pipe {

        let process = Process()
        process.launchPath = launch

        if let arg = arg {

            process.arguments = arg
        }

        let outPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errorPipe
        process.launch()

        let error = errorPipe.fileHandleForReading.readDataToEndOfFile()
        if let errorText = String(data: error, encoding: .utf8),
            !errorText.isEmpty {

            _log(type: .error, log: "Task Error: \(errorText)")
        }

        return outPipe
    }

    func executeInternal(process: ProcessType) {

        DispatchQueue.global(qos: .background).async {

            if process == .mitmOn,
                let script = Bundle.main.path(forResource: process.command.script, ofType: "sh") {

                let pipe = self.executeProcess(launch: "/bin/sh", arg: [script, Default.Folder.mitm + "/proxy.py"])
                let data = pipe.fileHandleForReading.readDataToEndOfFile()

                if let output = String(data: data, encoding: .utf8) {

                    _log(type: .error, log: "MITM Error: \(output)")

                    AppStore.task.dispatch(TaskAction.stopMitm)
                }

            } else if let script = Bundle.main.path(forResource: process.command.script, ofType: "sh") {

                let pipe = self.executeProcess(launch: "/bin/sh", arg: [script, (script as NSString).deletingLastPathComponent])

                if !process.command.ignoreReturn {

                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    let output = String(data: data, encoding: .utf8)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

                        if process == .ipInfo,
                            let output = output {

                            AppStore.task.dispatch(TaskAction.updateIpInfo(info: output))
                        }
                    }
                }
            }
        }
    }
}
