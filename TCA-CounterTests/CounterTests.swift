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
        }

        await store.send(.incrementButtonTapped) {
            $0.count = 1
        }

        await store.send(.factButtonTapped) {
            $0.isLoading = true
        }

        await store.receive(\.factResponse, timeout: .seconds(1)) {
              $0.isLoading = false
              $0.fact = "???"
        }
    }
}
