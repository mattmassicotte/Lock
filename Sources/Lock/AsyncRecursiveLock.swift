public final class AsyncRecursiveLock {
	@TaskLocal private static var locked = false

	private let internalLock = AsyncLock()

	public init() {
	}

	public func withLock<T: Sendable>(
		isolation: isolated (any Actor)? = #isolation,
		_ block: () async throws -> T
	) async rethrows -> T {
		if Self.locked {
			return try await block()
		}

		await internalLock.lock()

		do {
			let value = try await Self.$locked.withValue(true) {
				try await block()
			}

			internalLock.unlock()

			return value
		} catch {
			internalLock.unlock()

			throw error
		}
	}
}
