public final class AsyncLock {
	@TaskLocal private static var locked: Bool = false

	private enum State {
		typealias Continuation = CheckedContinuation<Void, Never>

		case unlocked
		case locked([Continuation])

		mutating func addContinuation(_ continuation: Continuation) {
			guard case var .locked(continuations) = self else {
				fatalError("Continuations cannot be added when unlocked")
			}

			continuations.append(continuation)

			self = .locked(continuations)
		}

		mutating func resumeNextContinuation() {
			guard case var .locked(continuations) = self else {
				fatalError("Continuations cannot be added when unlocked")
			}

			if continuations.isEmpty {
				self = .unlocked
				return
			}

			let continuation = continuations.removeFirst()

			continuation.resume()

			self = .locked(continuations)
		}
	}

	private var state = State.unlocked

	public init() {
	}

	public func lock(isolation: isolated (any Actor)? = #isolation) async {
		if Self.locked == true {
			return
		}

		switch state {
		case .unlocked:
			self.state = .locked([])
		case .locked:
			await withCheckedContinuation { continuation in
				self.state.addContinuation(continuation)
			}
		}
	}

	public func unlock(isolation: isolated (any Actor)? = #isolation) async {
		if Self.locked == true {
			return
		}

		self.state.resumeNextContinuation()
	}

	// this currently crashes the compiler
	//	public func withLock<T>(
	//		isolation: isolated (any Actor)? = #isolation,
	//		@_inheritActorContext _ block: @isolated(any) @escaping () async throws -> sending T
	//	) async rethrows -> sending T {
	//		if Self.locked == true {
	//			return try await block()
	//		}
	//
	//		return await lock()
	//
	//		do {
	//			let value = try await Self.$locked.withValue(true) {
	//				try await block()
	//			}
	//
	//			await unlock()
	//
	//			return value
	//		} catch {
	//			throw error
	//		}
	//	}
}

