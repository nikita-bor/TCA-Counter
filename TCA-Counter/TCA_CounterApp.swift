//
//  Created by Nikita Borodulin on 28.05.2024.
//

import ComposableArchitecture
import SwiftUI

@main
struct TCA_CounterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store(
                    initialState: CountersFeature.State(
                        counter1: CounterFeature.State(),
                        counter2: CounterFeature.State()
                    )
                ) {
                    CountersFeature()
                        ._printChanges()
                }
            )
        }
    }
}
