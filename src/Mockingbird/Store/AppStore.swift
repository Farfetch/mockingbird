//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation
import ReSwift

private let logging: Middleware<StateType> = { _, _ in
    return { next in
        return { action in

            #if DEBUG
                _log(type: .debug, log: "\(action)")
            #endif

            return next(action)
        }
    }
}

final class AppStore {

    static let data = DataStore(reducer: DataReducer.reduce, state: nil, middleware: [ logging ])
    static let record = RecordStore(reducer: RecordReducer.reduce, state: nil, middleware: [ logging ])
    static let server = ServerStore(reducer: ServerReducer.reduce, state: nil, middleware: [ logging ])
    static let task = TaskStore(reducer: TaskReducer.reduce, state: nil, middleware: [ logging ])
    static let test = TestStore(reducer: TestReducer.reduce, state: nil, middleware: [ logging ])
}
