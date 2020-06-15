//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation
import SwiftGui

public class ImportView {

    func body(frame: NSRect,
              onRefresh: @escaping (() -> Void)) -> GuiView {

        let sizeWidth = 200
        let positionX = CGFloat(frame.width / 2) - CGFloat(sizeWidth / 2)

        return Group {

            ForEach(1...10) { _ in

                NewLine()
            }

            SameLine(offsetX: GuiPoint(x: positionX, y: 0))
            MediumButton("IMPORT") {

                Util.openFinder(with: Default.Folder.main)
            }

            NewLine()
            SameLine(offsetX: GuiPoint(x: positionX, y: 0))
            MediumButton("REFRESH") {

                onRefresh()
            }
        }
    }
}
