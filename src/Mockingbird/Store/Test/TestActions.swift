//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import ReSwift

enum TestAction: Action {

    case initialize
    case select(id: String, selected: Bool)
    case unselectAll
}
