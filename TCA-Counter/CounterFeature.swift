//
//  Created by Nikita Borodulin on 28.05.2024.
//

import Foundation
import ComposableArchitecture
import SwiftUI

struct CounterView: View {

    let store: StoreOf<CounterFeature>

    var body: some View {
        EmptyView()
    }
}

@Reducer
struct CounterFeature {

    @ObservableState
    struct State {
        var count = 0
    }

    enum Action {
        case decrementButtonTapped
        case incrementButtonTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .decrementButtonTapped:
                    return .none
                case .incrementButtonTapped:
                    return .none
            }
        }
    }
}
