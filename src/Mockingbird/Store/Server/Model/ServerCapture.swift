//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation

struct ServerCapture {

    let id: String = UUID().uuidString

    let url: String
    let urlPath: String
    let queryParams: String

    let requestMethod: String
    let requestFormatted: String

    let responseFormatted: String
    let responseStatusCode: Int

    let original: String
    let mocked: Bool
    let isMock: Bool
    let bytesString: String

    var filter: Bool = false
}
