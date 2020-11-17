//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation
import ReSwift
import Files

let ServerQueue = DispatchQueue(label: "com.mockingbird.queue.server")

class ServerReducer {

    static func reduce(_ action: Action, state: ServerState?) -> ServerState {

        var state = state ?? ServerState()

        guard let action = action as? ServerAction else {
            return state
        }

        switch action {

        case .initialize:

            Self.initialize(with: &state)

        case .start:

            state.isRunning = true
            state.isProcessingCommand = true

        case .stop:

            state.isRunning = false
            state.isProcessingCommand = true

        case .processed:

            state.isProcessingCommand = false

        case .setCurrent(let capture):

            state.currentCapture = capture
            state.refreshView = true

        case .addCapture(let capture):

            state.captures.insert(capture, at: 0)

        case .clearCapture:

            state.captures.removeAll()
            state.currentCapture = nil

        case .updateStats(let pattern, let stat):

            Self.updateStats(with: &state, pattern: pattern, stat: stat)

        case .clearStats:

            state.stats.removeAll()
            state.statsHistory.removeAll()

        case .saveFiles(let shouldPopupFolder):

            Self.saveFiles(with: state, popupFolder: shouldPopupFolder)

        case .setContext(let context, let index):

            state.currentContext = context
            state.currentContextIndex = index

        case .select(let selected):

            state.isRequestSelected = selected
            state.refreshView = true

        case .saveCurrentToClipboard:

            Self.saveToClipboard(with: state)

        case .saveRecord:

            Self.saveToRecord(with: state)

        case .clearRefresh:

            state.refreshView = false
        }

        return state
    }
}

private extension ServerReducer {

    static func initialize(with state: inout ServerState) {

        do {

            try FileManager.default.createDirectory(atPath: Default.Folder.capture, withIntermediateDirectories: true, attributes: nil)

            ContextManager.shared.contexts.removeAll()

            if let file = try? File(path: "\(Default.Folder.main)/context.json"),
                let fileData = try? file.readAsString(),
                let model = try? ServerContextInfo(fileData) {

                ContextManager.shared.contexts.append(model)

            } else {

                ContextManager.shared.contexts = []
            }

            state.contextTitles.removeAll()
            state.contextTitles.append(contentsOf: ContextManager.shared.contexts.compactMap({ $0.context }))

        } catch {

            _log(type: .error, log: error.localizedDescription)
        }
    }

    static func saveFiles(with state: ServerState, popupFolder: Bool) {

        ServerQueue.async { [state] in

            do {

                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd_H-m-ss.SSSS"

                let transactionFolderPath = Default.Folder.capture + "/\(df.string(from: Date()))"

                try FileManager.default.createDirectory(atPath: transactionFolderPath, withIntermediateDirectories: true, attributes: nil)

                state.captures.forEach { capture in

                    do {

                        let folder = try Folder(path: transactionFolderPath)
                        let file = try folder.createFile(named: "\(capture.urlPath)_\(UUID().hashValue).json")
                        let data = capture.original.data(using: .utf8)?.prettyPrintedJSONString as String? ?? "no data"
                        try file.write(data)

                    } catch {

                        _log(type: .error, log: error.localizedDescription)
                    }
                }

                if popupFolder {

                    Util.openFinder(with: transactionFolderPath)
                }

            } catch {

                _log(type: .error, log: error.localizedDescription)
            }
        }
    }

    static func saveToClipboard(with state: ServerState) {

        ServerQueue.async {

            if let capture = state.currentCapture {

                let data = capture.original.data(using: .utf8)?.prettyPrintedJSONString as String? ?? "no data"
                Util.saveToClipboard(data)
            }
        }
    }

    static func saveToRecord(with state: ServerState) {

        ServerQueue.async {

            do {

                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd_H-m-ss.SSSS"

                let transactionFolderPath = Default.Folder.record + "/\(df.string(from: Date()))"

                try FileManager.default.createDirectory(atPath: transactionFolderPath, withIntermediateDirectories: true, attributes: nil)

                let folder = try Folder(path: transactionFolderPath)

                state.captures.reversed().enumerated().forEach { (index, capture) in

                    do {

                        if !capture.mocked {

                            let fileName = capture.urlPath.replacingOccurrences(of: "/", with: "_")
                            let file = try folder.createFile(named: "\(String(format: "%04d", index))_\(fileName)_\(UUID().hashValue).json")

                            let data = capture.queryParams.count > 0 ? "\(capture.urlPath)?\(capture.queryParams)" : capture.urlPath
                            let model = RecordFile(type: capture.requestMethod,
                                                   code: capture.responseStatusCode,
                                                   url: data, payload: capture.responseFormatted.minify)

                            try file.write(model.jsonString() ?? "no data")
                        }

                        ServerQueue.asyncAfter(deadline: .now() + 0.5) {

                            AppStore.record.dispatch(RecordAction.initialize)
                        }

                    } catch {

                        _log(type: .error, log: error.localizedDescription)
                    }
                }

            } catch {

                _log(type: .error, log: error.localizedDescription)
            }
        }
    }

    static func updateStats(with state: inout ServerState, pattern: String, stat: Float) {

        state.statsHistory.append(stat)

        if let row = state.stats.firstIndex(where: { $0.pattern == pattern }) {

            state.stats[row].update(bytes: Int(stat))

        } else {

            let serverStat = ServerStatistic(pattern: pattern,
                                             bytes: Int(stat),
                                             bytesString: ByteCountFormatter.string(fromByteCount: Int64(stat), countStyle: .file))

            state.stats.append(serverStat)
        }

        state.stats = state.stats.sorted { $0.bytes > $1.bytes }
    }
}
