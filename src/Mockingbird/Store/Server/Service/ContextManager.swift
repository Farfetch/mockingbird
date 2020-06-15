//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation

final class ContextManager {

    static let shared = ContextManager()

    private(set) var currentContext: ServerContextInfo?

    var contexts: [ServerContextInfo] = [] {

        didSet {

            if self.contexts.count == 0 {

                self.contexts.insert(ServerContextInfo(context: "all", paths: []), at: 0)
            }
        }
    }

    public func setLocalContextIfPresent() {

        self.setContext(index: 1)
    }

    public func setContext(index: Int) {

        guard self.contexts.count > index else {
            return
        }

        self.currentContext = index == 0 ? nil : self.contexts[index]

        AppStore.server.dispatch(ServerAction.setContext(context: self.currentContext, index: index))
    }
}
