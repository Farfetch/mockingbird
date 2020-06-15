//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation

final class Default {

    public enum Token {

        static let tracking = ""
    }

    public enum Server {

        static let port = 5000
        static let path = "/api/stream"
    }

    public enum Folder {

        static var main = "/Users/" + NSUserName() + "/.mockingbird"
        static var capture: String { main + "/capture" }
        static var data: String { main + "/data" }
        static var mitm: String { main + "/mitm" }
        static var record: String { main + "/record" }
        static var test: String { main + "/test" }
    }
}
