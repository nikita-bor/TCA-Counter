//
//  Created by Nikita Borodulin on 28.05.2024.
//

import Foundation
import ComposableArchitecture
import SwiftUI

struct CounterView: View {

    let store: StoreOf<CounterFeature>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("\(store.count)")
                    .padding()
                    .background(.black.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 10))
                HStack {
                    Button("-") {
                        store.send(.decrementButtonTapped)
                    }
                    .padding()
                    .background(.black.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 10))

                    Button("+") {
                        store.send(.incrementButtonTapped)
                    }
                    .padding()
                    .background(.black.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 10))
                }
            }
        }
    }
}

#Preview {
  CounterView(
    store: Store(initialState: CounterFeature.State()) {
      CounterFeature()
    }
  )
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
                    state.count -= 1
                    return .none
                case .incrementButtonTapped:
                    state.count += 1
                    return .none
            }
        }
    }
}
