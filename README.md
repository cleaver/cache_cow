# CacheCow

A simple implementation of caching using an Elixir GenServer.

## Installation

To install the application:

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Install Node.js dependencies with `npm install` inside the `assets` directory
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Benchmarking Fibonacci

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
