//
//  ProcessTask.swift
//  Mockingbird
//
//  Created by Erick Jung on 15/11/2020.
//  Copyright © 2020 Farfetch. All rights reserved.
//

import Foundation

protocol ProcessTaskCallback {

    func processStarted(_ process: ProcessType)
    func stdoutUpdated(_ process: ProcessType, text: String)
    func stderrUpdated(_ process: ProcessType, text: String)
    func processError(_ process: ProcessType, error: Error)
    func processEnded(_ process: ProcessType)
}

enum ProcessType {

    case proxyOn
    case proxyWifiOn
    case proxyOff
    case mitmOn(currentContext: ServerContextInfo?)
    case mitmOff
    case ipInfo

    var script: String {

        switch self {

        case .proxyOn: return "proxy_on"
        case .proxyWifiOn: return "proxy_wifi_on"
        case .proxyOff: return "proxy_off"
        case .mitmOn: return "mitm_on"
        case .mitmOff: return "mitm_off"
        case .ipInfo: return "ip_info"
        }
    }
}

class ProcessTask {

    static func launchSync(process: ProcessType, callback: ProcessTaskCallback?) {

        guard let script = Bundle.main.path(forResource: process.script, ofType: "sh") else { return }

        DispatchQueue.global(qos: .background).async {

            callback?.processStarted(process)

            let stdoutPipe = Pipe()
            let stderrPipe = Pipe()

            let task = Process()
            task.launchPath = "/bin/sh"
            task.arguments = [script, (script as NSString).deletingLastPathComponent]
            task.standardOutput = stdoutPipe
            task.standardError = stderrPipe

            task.launch()
            task.waitUntilExit()

            if let stdoutText = String(data: stdoutPipe.fileHandleForReading.readDataToEndOfFile(), encoding: String.Encoding.utf8),
               stdoutText.count > 0 {

                callback?.stdoutUpdated(process, text: stdoutText)
            }

            if let stderrText = String(data: stderrPipe.fileHandleForReading.readDataToEndOfFile(), encoding: String.Encoding.utf8),
               stderrText.count > 0 {

                callback?.stderrUpdated(process, text: stderrText)
            }

            callback?.processEnded(process)
        }
    }

    static func launchAsync(process: ProcessType,
                            callback: ProcessTaskCallback?) {

        guard let script = Bundle.main.path(forResource: process.script, ofType: "sh") else { return }

        DispatchQueue.global(qos: .background).async {

            callback?.processStarted(process)

            let stdoutPipe = Pipe()
            let stderrPipe = Pipe()

            var contextHosts = ""

            if case .mitmOn(let currentContext) = process {

                contextHosts = currentContext?.paths.joined(separator: "|") ?? ""
            }

            let task = Process()
            task.launchPath = "/bin/sh"
            task.arguments = [script, (script as NSString).deletingLastPathComponent, contextHosts]
            task.standardOutput = stdoutPipe
            task.standardError = stderrPipe

            let stdoutObserver = Self.addNotification(for: stdoutPipe.fileHandleForReading) { text in

                callback?.stdoutUpdated(process, text: text)
            }

            let stderrObserver = Self.addNotification(for: stderrPipe.fileHandleForReading) { text in

                callback?.stderrUpdated(process, text: text)
            }

            task.launch()
            task.waitUntilExit()

            NotificationCenter.default.removeObserver(stdoutObserver)
            NotificationCenter.default.removeObserver(stderrObserver)

            callback?.processEnded(process)
        }
    }

    @discardableResult
    private static func addNotification(for fileHandle: FileHandle,
                                        complete: @escaping (String) -> Void) -> NSObjectProtocol {

        let observer = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable,
                                                              object: fileHandle,
                                                              queue: nil) { notification in

            guard let handle = notification.object as? FileHandle else { return }

            if let text = String(data: handle.availableData, encoding: String.Encoding.utf8),
               text.count > 0 {

                complete(text)
            }

            handle.waitForDataInBackgroundAndNotify()
        }

        fileHandle.waitForDataInBackgroundAndNotify()

        return observer
    }
}
