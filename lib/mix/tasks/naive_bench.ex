defmodule Mix.Tasks.NaiveBench do
  use Mix.Task
  import CacheCow.Fibonacci
  import CacheCow.Util.Benchmark

  def run(_args) do
    Mix.Task.run("app.start")

    time_range(&naive_fibonacci/1, 1..45)
  end
end
