//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation

struct ServerRequest: Codable {

    let method: String
    let url: URL
    var headers: [[String]]
    let body: String
}

struct ServerResponse: Codable {

    var statusCode: Int
    var headers: [[String]]
    var body: String

    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case headers, body
    }
}

struct ServerTransaction: Codable {

    var request: ServerRequest
    var response: ServerResponse
}
