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

        await store.receive(\.delegate.valueChanged)

        await store.send(.view(.factButtonTapped)) {
            $0.isLoading = true
        }

        await store.receive(\.factResponse) {
            $0.isLoading = false
            $0.fact = "1 is a good number"
        }
    }
}
