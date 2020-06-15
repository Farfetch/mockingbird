//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import XCTest

class BaseScreen {

    let app: XCUIApplication
    let normalizedCoordinate: XCUICoordinate

    required init(app: XCUIApplication) {

        self.app = app
        self.normalizedCoordinate = self.app.windows.element(boundBy: 0).coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
    }

    func position(dx: CGFloat, dy: CGFloat) -> XCUICoordinate {

        return normalizedCoordinate.withOffset(CGVector(dx: dx, dy: dy))
    }
}
