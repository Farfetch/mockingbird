//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import XCTest
import Cocoa
@testable import Mockingbird

class UtilTests: XCTestCase {

    func testClipboard() {

        Util.saveToClipboard("testing")

        let pasteboard = NSPasteboard.general
        let currentText = pasteboard.string(forType: .string)
        XCTAssertEqual(currentText, "testing")
    }
}
