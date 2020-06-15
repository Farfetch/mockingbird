//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation
import os.log

func _log(type: OSLogType, log: String) {

    os_log("%{public}@", type: type, log)
}
