import Testing
import Lock

actor ReentrantActor {
	var value = 42
	let lock = AsyncLock()

	//	func doThing() async {
	//		await lock.withLock {
	//			try! #require(self.value == 42)
	//			self.value = 0
	//			try! await Task.sleep(nanoseconds: 1_000_000)
	//			try! #require(self.value == 0)
	//			self.value = 42
	//		}
	//	}

	func doThing() async {
		await lock.lock()

		try! #require(self.value == 42)
		self.value = 0
		try! await Task.sleep(nanoseconds: 1_000_000)
		try! #require(self.value == 0)
		self.value = 42

		await lock.unlock()
	}
}

struct LockTests {
	@Test
	func lockUnlock() async {
		let lock = AsyncLock()

		await lock.lock()
		await lock.unlock()
	}

	@Test
	func serializes() async {
		let actor = ReentrantActor()
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

	//	@Test
	//	func recursion() async {
	//		let lock = AsyncLock()
	//
	//		await lock.withLock {
	//			await lock.lock()
	//			await lock.withLock {
	//			}
	//			await lock.unlock()
	//		}
	//	}
}