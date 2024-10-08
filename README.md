<div align="center">

[![Build Status][build status badge]][build status]
[![Platforms][platforms badge]][platforms]
[![Matrix][matrix badge]][matrix]

</div>

# Lock
A lock for Swift concurrency

This package exposes two types: `AsyncLock` and `AsyncRecursiveLock`. These allow you to define **asynchronous** critical sections. Only one task can enter a critical section at a time. Unlike a traditional lock, you can safely make async calls while these locks are held.

This is a handy tool for dealing with actor reentrancy.

Some other concurrency packages you might find useful are [Queue][] and [Semaphore][].

## Integration

Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/mattmassicotte/Lock", branch: "main")
]
```

## Usage

These locks are **non-Sendable**. This is an intentional choice to disallow sharing the lock across isolation domains. If you want to do something like that, first think really hard about why and then check out [Semaphore][].

Note that trying to acquire an already-locked `AsyncLock` **will** deadlock your actor.

```swift
import Lock

actor MyActor {
  var value = 42
  let lock = AsyncLock()
  let recursiveLock = AsyncRecursiveLock()

  func hasCriticalSections() async {
    // no matter how many tasks call this method,
    // only one will be able to execute at a time
    await lock.lock()

    self.value = await otherObject.getValue()

    lock.unlock()
  }

  func hasCriticalSectionsBlock() async {
    await recursiveLock.withLock {
      // acquiring this multiple times within the same task is safe
      await recursiveLock.withLock {
        self.value = await otherObject.getValue()
      }
    }
  }
}
```

Unfortunately, I haven't quite figured out how to make `AsyncRecursiveLock` right yet, so it's currently not public.

## Contributing and Collaboration

I would love to hear from you! Issues or pull requests work great. Both a [Matrix space][matrix] and [Discord][discord] are also available for live help, but I have a strong bias towards answering in the form of documentation.

I prefer collaboration, and would love to find ways to work together if you have a similar project.

I prefer indentation with tabs for improved accessibility. But, I'd rather you use the system you want and make a PR than hesitate because of whitespace.

By participating in this project you agree to abide by the [Contributor Code of Conduct](CODE_OF_CONDUCT.md).

[build status]: https://github.com/mattmassicotte/Lock/actions
[build status badge]: https://github.com/mattmassicotte/Lock/workflows/CI/badge.svg
[platforms]: https://swiftpackageindex.com/mattmassicotte/Lock
[platforms badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmattmassicotte%2FLock%2Fbadge%3Ftype%3Dplatforms
[matrix]: https://matrix.to/#/%23chimehq%3Amatrix.org
[matrix badge]: https://img.shields.io/matrix/chimehq%3Amatrix.org?label=Matrix
[discord]: https://discord.gg/esFpX6sErJ
[Semaphore]: https://github.com/groue/Semaphore
[Queue]: https://github.com/mattmassicotte/Queue
