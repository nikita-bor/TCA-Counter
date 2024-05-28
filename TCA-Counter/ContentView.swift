//
//  Created by Nikita Borodulin on 28.05.2024.
//

import ComposableArchitecture
import SwiftUI

struct ContentView: View {
    var body: some View {
        CounterView(
            store: Store(initialState: CounterFeature.State()) {
                CounterFeature()
            }
        )
    }
}

#Preview {
    ContentView()
}
