//
// Copyright (c) 2020, Farfetch.
// All rights reserved.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

import Foundation
import SwiftGui

public class StatsView {

    func body(state: ServerState) -> GuiView {

        Group {

            Plot(type: .line, label: "", values: state.statsHistory)
                .size(CGSize(width: 0, height: 50))
                .snap()

            SubWindow {

                if state.stats.count > 0 {

                    Group {

                        Button("Clear") {

                            AppStore.server.dispatch(ServerAction.clearStats)
                        }

                        ForEach(state.stats) { val in

                            self.cell(stat: val)
                        }

                    }
                    .font(Font.medium)

                } else {

                    Text("no data")
                }

            }
            .identifier("##statsview")
        }
    }
}

private extension StatsView {

    private func cell(stat: ServerStatistic) -> GuiView {

        Group {

            TextLabel(label: "\(stat.count) - \(stat.bytesString)", value: stat.pattern)
            Divider()
        }
        .identifier(stat.pattern)
    }
}
