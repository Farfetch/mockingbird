//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation
import ReSwift

typealias TestStore = Store<TestState>

struct TestState: StateType {

    var currentTest: TestInfo?
    var tests: [TestInfo] = []
}
