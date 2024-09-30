import Testing
@testable import Lock

actor ReentrantSensitiveState {
	var value = 42

	func doThing() async throws {
		try #require(self.value == 42)
		self.value = 0
		try await Task.sleep(nanoseconds: 1_000_000)
		try #require(self.value == 0)
		self.value = 42

	}
}

actor RecursiveReentrantActor {
	let state = ReentrantSensitiveState()
	let lock = AsyncRecursiveLock()

	func doThing() async throws {
		try await lock.withLock {
			try await state.doThing()
		}
	}
}

actor TwoLockRecursiveReentrantActor {
	let state = ReentrantSensitiveState()
	let lock1 = AsyncRecursiveLock()
	let lock2 = AsyncRecursiveLock()

	func holdBothLocks(with block: () async throws -> Void) async rethrows {
		try await lock1.withLock {
			try await lock2.withLock {
				try await block()
			}
		}
	}

	func doThing() async throws {
		try await lock2.withLock {
			try await state.doThing()
		}
	}
}

struct RecursiveLockTests {
	@Test
	func recursion() async {
		let lock = AsyncRecursiveLock()

		await lock.withLock {
			await lock.withLock {
			}
		}
	}

//	@Test
	func serializesWithRecursiveLock() async throws {
		let actor = RecursiveReentrantActor()
		var tasks = [Task<Void, any Error>]()

		for _ in 0..<1000 {
			let task = Task {
				try await actor.doThing()
			}

			tasks.append(task)
		}

		for task in tasks {
			try await task.value
		}
	}

//	@Test
	func serializesWithTwoLocks() async throws {
		let actor = TwoLockRecursiveReentrantActor()

		try await actor.holdBothLocks {
			var tasks = [Task<Void, any Error>]()

			for _ in 0..<1000 {
				let task = Task {
					try await actor.doThing()
				}

				tasks.append(task)
			}

			for task in tasks {
				try await task.value
			}
		}
	}
}
