//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import XCTest

class MainScreen : BaseScreen {

    private var testTab: XCUICoordinate { return self.position(dx: 30, dy: 45) }
    private var dataTab: XCUICoordinate { return self.position(dx: 80, dy: 45) }
    private var recordTab: XCUICoordinate { return self.position(dx: 145, dy: 45) }
    private var captureTab: XCUICoordinate { return self.position(dx: 215, dy: 45) }
    private var statsTab: XCUICoordinate { return self.position(dx: 290, dy: 45) }
    private var settingsTab: XCUICoordinate { return self.position(dx: 390, dy: 45) }
    private var helpTab: XCUICoordinate { return self.position(dx: 460, dy: 45) }

    func goToTestScreen() {

        self.testTab.tap()
    }

    func goToDataScreen() {

        self.dataTab.tap()
    }

    func goToRecordScreen() {

        self.recordTab.tap()
    }

    func goToCaptureScreen() {

        self.captureTab.tap()
    }

    func goToStatsScreen() {

        self.statsTab.tap()
    }

    func goToSettingsScreen() {

        self.settingsTab.tap()
    }

    func goToHelpScreen() {

        self.helpTab.tap()
    }
}
