defmodule CacheCow.Util.BenchmarkTest do
  use ExUnit.Case
  alias CacheCow.Util.Benchmark
  import ExUnit.CaptureIO

  test "generates expected result" do
    test_function = fn x -> x * 2 end

    assert capture_io(fn -> CacheCow.Util.Benchmark.time(test_function, [2]) end) =~ "Result: 4"
  end

  test "prints execution time" do
    test_function = fn x ->
      # 100 milliseconds
      :timer.sleep(100)
      x * x
    end

    output = capture_io(fn -> CacheCow.Util.Benchmark.time(test_function, [3]) end)
    %{"micros" => micros} = Regex.named_captures(~r/Time: (?<micros>\d+)/, output)

    # takes at least 100,000 microseconds
    assert String.to_integer(micros) >= 100_000
  end

  test "operates on a range" do
    test_function = fn x -> x * 2 end

    assert capture_io(fn -> CacheCow.Util.Benchmark.time_range(test_function, 1..3) end) =~
             ~r/Result: 2.+Result: 4 .+Result: 6/s
  end
end
