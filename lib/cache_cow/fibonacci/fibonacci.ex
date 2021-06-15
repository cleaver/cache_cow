defmodule CacheCow.Fibonacci do
  import CacheCow.CacheHelper

  @spec naive_fibonacci(pos_integer) :: pos_integer
  @doc """
  Calculate Fibonacci numbers using recursion.

  ## Examples

  iex> CacheCow.Fibonacci.naive_fibonacci(1)
  1

  iex> CacheCow.Fibonacci.naive_fibonacci(2)
  1

  iex> CacheCow.Fibonacci.naive_fibonacci(10)
  55

  """
  def naive_fibonacci(1), do: 1
  def naive_fibonacci(2), do: 1

  def naive_fibonacci(n) do
    naive_fibonacci(n - 2) + naive_fibonacci(n - 1)
  end

  @spec cached_fibonacci(pos_integer) :: pos_integer
  @doc """
  Calculate Fibonacci numbers using recursion plus caching (memoization).

  ## Examples

  iex> CacheCow.Fibonacci.cached_fibonacci(1)
  1

  iex> CacheCow.Fibonacci.cached_fibonacci(2)
  1

  iex> CacheCow.Fibonacci.cached_fibonacci(10)
  55

  """
  def cached_fibonacci(1), do: 1
  def cached_fibonacci(2), do: 1

  def cached_fibonacci(n) do
    cached(n, fn ->
      cached_fibonacci(n - 2) + cached_fibonacci(n - 1)
    end)
  end
end
