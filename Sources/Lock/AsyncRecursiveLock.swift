// This thing doesn't quite work yet...
final class AsyncRecursiveLock {
	@TaskLocal private static var locked = false
	@TaskLocal private static var lockedSet = Set<ObjectIdentifier>()

	private let internalLock = AsyncLock()

	public init() {
	}

	public func withLock<T: Sendable>(
		isolation: isolated (any Actor)? = #isolation,
		_ block: () async throws -> T
	) async rethrows -> T {
		let id = ObjectIdentifier(self)
		var set = Self.lockedSet

		let (needsLock, _) = set.insert(id)

		print("state:", id, needsLock)

		if needsLock == false {
			return try await block()
		}

		return try await internalLock.withLock {
			try await Self.$lockedSet.withValue(set) {
				try await block()
			}
		}
	}

//	public func withLock<T: Sendable>(
//			isolation: isolated (any Actor)? = #isolation,
//			_ block: () async throws -> T
//		) async rethrows -> T {
//			if Self.locked {
//				return try await block()
//			}
//
//			await internalLock.lock()
//
//			do {
//				let value = try await Self.$locked.withValue(true) {
//					try await block()
//				}
//
//				internalLock.unlock()
//
//				return value
//			} catch {
//				internalLock.unlock()
//
//				throw error
//			}
//		}
}
