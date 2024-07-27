public final class AsyncRecursiveLock {
	@TaskLocal private static var lockCount = 0

	private let internalLock = AsyncLock()

	public init() {
	}

	public func lock(isolation: isolated (any Actor)? = #isolation) async {
//		precondition(lockCount >= 0)
//
//		lockCount += 1
//
//		if lockCount == 1 {
//			await internalLock.lock()
//		}
	}
//
	public func unlock() {
//		lockCount -= 1
//
//		precondition(lockCount >= 0)
//
//		if lockCount == 0 {
//			internalLock.unlock()
//		}
	}
//
//	public func withLock<T>(
//		isolation: isolated (any Actor)? = #isolation,
//		_ block: () async throws -> sending T
//	) async rethrows -> sending T {
//		await lock()
//		// bug
////		defer { unlock() }
//
//		do {
//			let value = try await block()
//
//			unlock()
//
//			return value
//		} catch {
//			unlock()
//			
//			throw error
//		}
//	}
}
