import Testing
import Lock

actor ReentrantActor {
	let state = ReentrantSensitiveState()
	let lock = AsyncLock()

	func doThingUsingWithLock() async throws {
		try await lock.withLock {
			try await state.doThing()
		}
	}

	func doThingUsingLockUnlock() async throws {
		await lock.lock()
		defer { lock.unlock() }

		try await state.doThing()
	}
}

struct LockTests {
	@Test
	func lockUnlock() async {
		let lock = AsyncLock()

		await lock.lock()
		lock.unlock()
	}

	@Test
	func serializes() async throws {
		let actor = ReentrantActor()
		var tasks = [Task<Void, any Error>]()

		for _ in 0..<1000 {
			let task = Task {
				try await actor.doThingUsingLockUnlock()
			}

			tasks.append(task)
		}

		for task in tasks {
			try await task.value
		}
	}

	@Test
	func serializesWithLock() async throws {
		let actor = ReentrantActor()
		var tasks = [Task<Void, any Error>]()

		for _ in 0..<1000 {
			let task = Task {
				try await actor.doThingUsingWithLock()
			}

			tasks.append(task)
		}

		for task in tasks {
			try await task.value
		}
	}
}
