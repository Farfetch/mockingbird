//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation
import SwiftGui

func ButtonSettings(_ title: String,
                    onTap: (() -> Void)? = nil) -> GuiView {

    Button(title, onTap: onTap)
        .backgroundColor(Color.lightGray)
        .textColor(Color.black)
}

func ButtonSelection(_ title: String,
                     selected: Bool,
                     active: Bool = false,
                     onTap: (() -> Void)? = nil) -> GuiView {

    if active {

        return ButtonGreen(title, onTap: onTap)
    }

    return Button(title, onTap: onTap)
        .backgroundColor(selected ? Color.lightGray : Color.darkGray)
        .hoveredColor(Color.gray)
        .textColor(selected ? Color.black : Color.white)
}

func ButtonRed(_ title: String,
               onTap: (() -> Void)? = nil) -> GuiView {

    Button(title, onTap: onTap)
        .backgroundColor(Color.red)
        .hoveredColor(Color.darkRed)
        .textColor(Color.white)
        .borderColor(Color.red)
}

func ButtonGreen(_ title: String,
                 onTap: (() -> Void)? = nil) -> GuiNode {

    Button(title, onTap: onTap)
        .backgroundColor(Color.green)
        .hoveredColor(Color.darkGreen)
        .textColor(Color.black)
        .borderColor(Color.green)
}

func ButtonWhite(_ title: String,
                 onTap: (() -> Void)? = nil) -> GuiView {

    Button(title, onTap: onTap)
        .backgroundColor(Color.white)
        .hoveredColor(Color.lightGray)
        .textColor(Color.black)
        .borderColor(Color.white)
}

func SmallButtonSelection(_ title: String,
                          selected: Bool,
                          onTap: (() -> Void)? = nil) -> GuiView {

    Button(title, type: .small, onTap: onTap)
        .backgroundColor(selected ? Color.lightGray : Color.darkGray)
        .hoveredColor(selected ? Color.lightGray : Color.darkGray)
        .textColor(selected ? Color.black : Color.white)
}

func LargeButton(_ title: String,
                 onTap: (() -> Void)? = nil) -> GuiView {

    Button(title, onTap: onTap)
        .size(GuiSize(width: 200, height: 100))
}

func MediumButton(_ title: String,
                  onTap: (() -> Void)? = nil) -> GuiView {

    Button(title, onTap: onTap)
        .size(GuiSize(width: 200, height: 50))
}

func ConfirmationPopup(id: String,
                       title: String,
                       no: (() -> Void)? = nil,
                       yes: (() -> Void)? = nil) -> GuiView {

    Popup {

        Text(title)

        HStack {

            Button("NO") {

                no?()
                Popup.close()
            }
            .size(GuiSize(width: 50, height: 30))

            Button("YES") {

                yes?()
                Popup.close()
            }
            .size(GuiSize(width: 50, height: 30))
            .backgroundColor(Color.red)
        }
    }
    .identifier(id)
}
