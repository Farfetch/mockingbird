//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import XCTest
@testable import Mockingbird

class MockingbirdUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {

        self.continueAfterFailure = false

        self.app = XCUIApplication()
        self.app.launch()
    }

    func testNavigation() {

        let testExpectation = XCTestExpectation(description:"onboarding navigation")

        let mainScreen = MainScreen(app: self.app)

        mainScreen.goToDataScreen()
        mainScreen.goToRecordScreen()
        mainScreen.goToCaptureScreen()
        mainScreen.goToStatsScreen()
        mainScreen.goToSettingsScreen()
        mainScreen.goToHelpScreen()
        mainScreen.goToTestScreen()

        testExpectation.fulfill()

        self.wait(for: [testExpectation], timeout: 10)
    }
}
