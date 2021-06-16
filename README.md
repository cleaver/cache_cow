# CacheCow

[![Elixir Tests](https://github.com/cleaver/cache_cow/actions/workflows/ex-tests.yaml/badge.svg)](https://github.com/cleaver/cache_cow/actions/workflows/ex-tests.yaml)

<img src="./cache_cow.png" height="200" width="200" alt="a happy cow" />

A simple implementation of caching using an Elixir GenServer.

Using: Elixir 1.12 / Phoenix 1.5.9.

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
- limited size - I've arbitrarily set it to just 5 slots for testing purposes.
- cache expiry - drop old cache values when it gets full.
- cache keys - can be any Elixir type supported by [Map](https://hexdocs.pm/elixir/1.12/Map.html#content).
- cache values - again, any supported Elixir type.
- benchmarks to test the effectiveness of the cache.
- a REST API for access from external processes. **(in progress)**

### Details

The key component used is [GenServer](https://hexdocs.pm/elixir/1.12/GenServer.html#content) - a core Elixir module for implementing a server interface. This maintains state and provides concurrency, protecting against race conditions. [See: GenServer implementation](./lib/cache_cow/gen_server/cache_server.ex).

The GenServer is automatically started a [Supervisor](https://hexdocs.pm/elixir/1.12/Supervisor.html), already provided by the Phoenix app.

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

## REST API

There is a RESTful interface to give access to the cache server over HTTP.

Notes:

- CORS headers are set to accept "\*".
- The REST API works for string data, although this could include JSON data in a string. Encoding and decoding is the responsibility of the client.
- Non-string data stored using the native Elixir API cannot be retrieve using the REST API.

### POST /api/cache

Create or replace a key/value pair in the cache.

Data (json):

- key - (string) - the unique key for the value to be written to cache.
- value - (string) - the value to be written to cache.

Example:

```bash
curl --location --request POST 'http://localhost:4000/api/cache' \
--header 'Content-Type: application/json' \
--data-raw '{"key": "2", "value": "two"}'
```

Result:

```json
{ "message": "success" }
```

### GET /api/cache/{key}

Retrieve a value from the cache by key.

Parameters:

- key - (string) - the key for the cache value to be retrieved

Example:

```bash
curl --location --request GET 'http://localhost:4000/api/cache/2'
```

Result:

```json
{ "data": "two" }
```

### DELETE /api/cache

Clear the entire cache.

Example:

```bash
curl --location --request DELETE 'http://localhost:4000/api/cache'
```

Result:

```json
{ "message": "cache cleared" }
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

### Benchmark results

| n   | naive f(n)    | μsec       | cached f(n)   | μsec |
| --- | ------------- | ---------- | ------------- | ---- |
| 1   | 1             | 1          | 1             | 1    |
| 2   | 1             | 0          | 1             | 1    |
| 3   | 2             | 0          | 2             | 17   |
| 4   | 3             | 0          | 3             | 10   |
| 5   | 5             | 0          | 5             | 12   |
| 6   | 8             | 0          | 8             | 17   |
| 7   | 13            | 0          | 13            | 20   |
| 8   | 21            | 0          | 21            | 20   |
| 9   | 34            | 1          | 34            | 24   |
| 10  | 55            | 1          | 55            | 15   |
| 11  | 89            | 1          | 89            | 12   |
| 12  | 144           | 2          | 144           | 11   |
| 13  | 233           | 3          | 233           | 12   |
| 14  | 377           | 4          | 377           | 14   |
| 15  | 610           | 6          | 610           | 12   |
| 16  | 987           | 11         | 987           | 16   |
| 17  | 1,597         | 19         | 1,597         | 19   |
| 18  | 2,584         | 30         | 2,584         | 20   |
| 19  | 4,181         | 68         | 4,181         | 19   |
| 20  | 6,765         | 84         | 6,765         | 19   |
| 21  | 10,946        | 172        | 10,946        | 37   |
| 22  | 17,711        | 243        | 17,711        | 19   |
| 23  | 28,657        | 350        | 28,657        | 17   |
| 24  | 46,368        | 804        | 46,368        | 13   |
| 25  | 75,025        | 854        | 75,025        | 11   |
| 26  | 121,393       | 1,314      | 121,393       | 14   |
| 27  | 196,418       | 2,057      | 196,418       | 11   |
| 28  | 317,811       | 3,151      | 317,811       | 11   |
| 29  | 514,229       | 5,042      | 514,229       | 26   |
| 30  | 832,040       | 9,605      | 832,040       | 12   |
| 31  | 1,346,269     | 13,507     | 1,346,269     | 10   |
| 32  | 2,178,309     | 20,858     | 2,178,309     | 11   |
| 33  | 3,524,578     | 30,286     | 3,524,578     | 11   |
| 34  | 5,702,887     | 49,588     | 5,702,887     | 15   |
| 35  | 9,227,465     | 76,306     | 9,227,465     | 19   |
| 36  | 14,930,352    | 122,527    | 14,930,352    | 18   |
| 37  | 24,157,817    | 197,623    | 24,157,817    | 12   |
| 38  | 39,088,169    | 319,863    | 39,088,169    | 10   |
| 39  | 63,245,986    | 518,161    | 63,245,986    | 10   |
| 40  | 102,334,155   | 838,999    | 102,334,155   | 11   |
| 41  | 165,580,141   | 1,371,160  | 165,580,141   | 15   |
| 42  | 267,914,296   | 2,208,220  | 267,914,296   | 20   |
| 43  | 433,494,437   | 3,562,755  | 433,494,437   | 11   |
| 44  | 701,408,733   | 5,821,718  | 701,408,733   | 11   |
| 45  | 1,134,903,170 | 10,813,388 | 1,134,903,170 | 11   |

## Next steps

_Cache storage_: This implementation has cached stored in native in-memory Elixir data types. It would be possible to plug in different cache storage, replacing `CacheCow.CacheStorage`. Possibilities include: ETS, filesystem, PostgreSQL, or other database.

_Scaling_: There is a single supervised GenServer. It would be possible to scale by dispatching the cache requests to multiple cache servers or even to multiple nodes. A dispatch function could send the request to the appropriate cache server based on the key. EG: a most basic dispatch on numeric key would be to send odd-numbered keys to cache server 1, and even-numbered keys to cache server 2.

_REST API_: At present this is fairly limited, restricted to string values. The controller could encode and decode JSON data, or other formats for better interoperability with the native Elixir API. A few issues would need to be overcome as there is not a 1:1 correspondence between Elixir data types and JSON notation. (EG: tuples don't translate directly to JSON.)

_Other_: Cleanup... The project was created with Ecto, anticipating that this could be used for either cache storage or a benchmarking example.
