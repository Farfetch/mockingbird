//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

final class Tracking {

    static func initialize() {

        MSAppCenter.start(Default.Token.tracking, withServices: [
            MSAnalytics.self,
            MSCrashes.self
        ])
    }
}
