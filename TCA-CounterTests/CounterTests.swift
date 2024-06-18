//
//  Created by Nikita Borodulin on 28.05.2024.
//

import ComposableArchitecture
@testable import TCA_Counter
import XCTest

final class CounterTests: XCTestCase {

    @MainActor
    func testCounter() async {
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        } withDependencies: {
            $0.numberFact.fetch = { "\($0) is a good number" }
        }

        await store.send(.view(.incrementButtonTapped)) {
            $0.count = 1
        }

        await store.send(.view(.factButtonTapped)) {
            $0.isLoading = true
        }

        await store.receive(\.factResponse) {
            $0.isLoading = false
            $0.fact = "1 is a good number"
        }
    }

    @MainActor
    func testCounters() async {
        let store = TestStore(initialState: CountersFeature.State(counter1: CounterFeature.State(), counter2: CounterFeature.State())) {
            CountersFeature()
        }

        await store.send(.counter1(.view(.incrementButtonTapped))) {
            $0.counter1.count = 1
        }

        await store.receive(\.counter1.delegate) {
            $0.lastChangedCounter = .first
        }

        await store.send(.counter2(.view(.decrementButtonTapped))) {
            $0.counter2.count = -1
        }

        await store.receive(\.counter2.delegate) {
            $0.lastChangedCounter = .second
        }
    }

    @MainActor
    func testCounters_nonExhaustive() async {
        let store = TestStore(initialState: CountersFeature.State(counter1: CounterFeature.State(), counter2: CounterFeature.State())) {
            CountersFeature()
        }

        store.exhaustivity = .off

        await store.send(.counter1(.view(.incrementButtonTapped)))

        await store.receive(\.counter1.delegate) {
            $0.lastChangedCounter = .first
        }

        await store.send(.counter2(.view(.decrementButtonTapped)))

        await store.receive(\.counter2.delegate) {
            $0.lastChangedCounter = .second
        }
    }
}
