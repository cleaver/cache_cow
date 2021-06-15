# CacheCow

[![Elixir Tests](https://github.com/cleaver/cache_cow/actions/workflows/ex-tests.yaml/badge.svg)](https://github.com/cleaver/cache_cow/actions/workflows/ex-tests.yaml)

<img src="./cache_cow.png" height="200" width="200" alt="a happy cow" />

A simple implementation of caching using an Elixir GenServer.

## Installation

To install the application:

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Install Node.js dependencies with `npm install` inside the `assets` directory
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Implementation notes

The goal of this project to provide a simple implementation of an in-memory key-value cache with considerations for:

- maintaining state while the application runs.
- concurrency - you don't want competing processes to corrupt the cache due to a race condition
- limited size - I've arbitrarily set it to just 5 slots.
- cache expiry - drop old cache values when it gets full.
- cache keys - can be any Elixir type supported by [Map](https://hexdocs.pm/elixir/1.12/Map.html#content).
- cache values - again, any supported Elixir type.
- benchmarks to test the effectiveness of the cache.
- a REST API for access from external processes. **(in progress)**

### Details

The key component used is [GenServer](https://hexdocs.pm/elixir/1.12/GenServer.html#content) - a core Elixir module for implementing a server interface. This maintains state and provides concurrency, protecting against race conditions. [See: GenServer implementation](./lib/cache_cow/gen_server/cache_server.ex).

Cache data is stored in a Struct consisting of an `index` Map to store the key-value data and an `expiry` List to represent how recently a cache item has been accessed. (The head of the list is most recent.) [See: cache storage implementation](./lib/cache_cow/gen_server/storage/cache_storage.ex).

To make it easier to use in Elixir code, a helper function `cached/2` has been defined for convenience.

For some operation:

```elixir
result = Some.Slow.calculation(x)
```

The cached version is now:

```elixir
import CacheCow.CacheHelper

result =
  cached(x, fn ->
    Some.Slow.calculation(x)
  end)
```

## Benchmarking with Fibonacci

A naive implementation of a Fibonacci function `f(n) -> f(n-2) + f(n-1)` is used as a benchmark.

To calculate Fibonacci numbers from 1 to 45, run:

```bash
mix naive_bench
```

To see the effect of caching on the execution, run:

```bash
mix cached_bench
```

Even though the cache server is limited to five items, this is still a best-case scenario, since the Fibonacci numbers are calculated in order. Considering this, only 2 items (for `f(n-2)` and `f(n-1)`) should be sufficient for the speedup.

For a more random execution of the cached Fibonacci calculation, the worst case should be O(n). Uncached, it is close to O(2<sup>n</sup>).
