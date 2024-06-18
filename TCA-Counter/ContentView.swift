//
//  Created by Nikita Borodulin on 28.05.2024.
//

import ComposableArchitecture
import Foundation
import SwiftUI
import UIKit

@ViewAction(for: CountersFeature.self)
struct ContentView: View {

    let store: StoreOf<CountersFeature>

    var body: some View {
        WithPerceptionTracking {
            HStack {
                CounterView(store: store.scope(state: \.counter1, action: \.counter1))
                    .overlay(alignment: .top) {
                        if store.lastChangedCounter == .first {
                            marker
                                .offset(y: -20)
                        }
                    }
                CounterView(store: store.scope(state: \.counter2, action: \.counter2))
                    .overlay(alignment: .top) {
                        if store.lastChangedCounter == .second {
                            marker
                                .offset(y: -20)
                        }
                    }
            }
            .padding()
            .task {
                await send(.task).finish()
            }
        }
    }

    private var marker: some View {
        Capsule()
            .fill(Color.green)
            .frame(width: 100, height: 16)
    }
}

#Preview {
    ContentView(
        store: Store(
            initialState: CountersFeature.State(
                counter1: CounterFeature.State(),
                counter2: CounterFeature.State()
            )
        ) {
            CountersFeature()
        }
    )
}

@Reducer
struct CountersFeature {

    @ObservableState
    struct State: Equatable {

        enum Counter: Equatable {
            case first
            case second
        }

        var counter1: CounterFeature.State
        var counter2: CounterFeature.State
        var lastChangedCounter: Counter?
    }

    enum Action: ViewAction {
        case counter1(CounterFeature.Action)
        case counter2(CounterFeature.Action)
        case userDidTakeScreenshot
        case view(ViewAction)

        enum ViewAction {
            case task
        }
    }

    @Dependency(\.screenshots) var screenshots

    var body: some ReducerOf<Self> {
        Scope(state: \.counter1, action: \.counter1) {
            CounterFeature()
        }
        Scope(state: \.counter2, action: \.counter2) {
            CounterFeature()
        }
        Reduce { state, action in
            switch action {
                case .counter1(.delegate(.valueChanged)):
                    state.lastChangedCounter = .first
                    return .none
                case .counter1:
                    return .none
                case .counter2(.delegate(.valueChanged)):
                    state.lastChangedCounter = .second
                    return .none
                case .counter2:
                    return .none
                case .userDidTakeScreenshot:
                    state.lastChangedCounter = nil
                    return .merge(
                        CounterFeature().reduce(into: &state.counter1, action: .reset)
                            .map(Action.counter1),
                        CounterFeature().reduce(into: &state.counter2, action: .reset)
                            .map(Action.counter2)
                    )
                case .view(.task):
                    return .run { send in
                        for await _ in await screenshots() {
                            await send(.userDidTakeScreenshot)
                        }
                    }
            }
        }
    }
}

extension DependencyValues {
    var screenshots: @Sendable () async -> AsyncStream<Void> {
        get { self[ScreenshotsKey.self] }
        set { self[ScreenshotsKey.self] = newValue }
    }
}

private enum ScreenshotsKey: DependencyKey {
    static let liveValue: @Sendable () async -> AsyncStream<Void> = {
        await AsyncStream(
            NotificationCenter.default
                .notifications(named: UIApplication.userDidTakeScreenshotNotification)
                .map { _ in }
        )
    }
}
