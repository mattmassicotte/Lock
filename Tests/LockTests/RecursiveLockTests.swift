import Testing
import Lock

actor RecursiveReentrantActor {
	var value = 42
	let lock = AsyncRecursiveLock()

	func doThing() async {
		await lock.withLock {
			try! #require(self.value == 42)
			self.value = 0
			try! await Task.sleep(nanoseconds: 1_000_000)
			try! #require(self.value == 0)
			self.value = 42
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

	@Test
	func lockAndUnlock() async {
		let lock = AsyncLock()

		await lock.lock()
		lock.unlock()
	}

	@Test
	func serializesWithRecursiveLock() async {
		let actor = RecursiveReentrantActor()
		var tasks = [Task<Void, Never>]()

		for _ in 0..<1000 {
			let task = Task {
				await actor.doThing()
			}

			tasks.append(task)
		}

		for task in tasks {
			await task.value
		}
	}
}
