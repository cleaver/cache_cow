defmodule CacheCow.Util.Benchmark do
  def time(function, args) do
    {time, result} = :timer.tc(function, [args])
    IO.puts("Args: #{args} Result: #{result}   Time: #{time} μs")
  end

  def time_range(function, range) do
    Enum.to_list(range)
    |> Enum.each(fn elem -> time(function, elem) end)
  end
end
