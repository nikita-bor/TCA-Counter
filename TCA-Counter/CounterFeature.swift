//
//  Created by Nikita Borodulin on 28.05.2024.
//

import Foundation
import ComposableArchitecture
import SwiftUI

@ViewAction(for: CounterFeature.self)
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
                        send(.decrementButtonTapped)
                    }
                    .padding()
                    .background(.black.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 10))

                    Button("+") {
                        send(.incrementButtonTapped)
                    }
                    .padding()
                    .background(.black.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 10))
                }
                Button("Fact") {
                    send(.factButtonTapped)
                }
                .padding()
                .background(.black.opacity(0.1))
                .cornerRadius(10)

                if store.isLoading {
                    ProgressView()
                } else if let fact = store.fact {
                    Text(fact)
                        .multilineTextAlignment(.center)
                        .padding()
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
    struct State: Equatable {
        var count = 0
        var fact: String?
        var isLoading = false
    }

    enum Action: ViewAction {
        case factResponse(String)
        case view(View)

        enum View {
            case decrementButtonTapped
            case factButtonTapped
            case incrementButtonTapped
        }
    }

    enum CancelID { case factRequest }

    @Dependency(\.numberFact) var numberFact

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .view(.decrementButtonTapped):
                    state.count -= 1
                    state.fact = nil
                    return .none
                case .view(.factButtonTapped):
                    state.fact = nil
                    state.isLoading = true
                    return .run { [count = state.count] send in
                        try await send(.factResponse(numberFact.fetch(count)))
                    }
                    .cancellable(id: CancelID.factRequest, cancelInFlight: true)
                case .factResponse(let fact):
                    state.fact = fact
                    state.isLoading = false
                    return .none
                case .view(.incrementButtonTapped):
                    state.count += 1
                    state.fact = nil
                    return .none
            }
        }
    }
}
