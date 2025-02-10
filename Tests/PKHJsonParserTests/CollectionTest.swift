import Testing
@testable import PKHJsonParser

struct CollectionTest {
    @Test func safeSubscript() async throws {
        let array = [10, 20, 30, 40, 50]

        #expect(array[safe: 0] == 10)      // Valid index
        #expect(array[safe: 2] == 30)      // Valid index
        #expect(array[safe: 4] == 50)      // Last index
        #expect(array[safe: 5] == nil)     // Out-of-bounds
        #expect(array[safe: nil] == nil)   // Nil index
        #expect(array[safe: -1] == nil)    // Negative index
    }
}
