defmodule Akd.Generator.TaskTest do
  use ExUnit.Case

  @app_path Path.join([__DIR__, "..", "..", "fixtures", "gentester"])
  @test_task_path Path.join([@app_path, "lib", "test_task.ex"])

  setup do
    old_dir = File.cwd!()
    File.cd!(@app_path)

    # Cleanup for the test
    {:ok, _} = File.rm_rf(@test_task_path)

    on_exit(fn ->
      # Cleanup after the tests
      {:ok, _} = File.rm_rf(@test_task_path)
      File.cd!(old_dir)
    end)

    []
  end

  describe "gen/2" do
    test "gen without name produces an error" do
      assert_raise FunctionClauseError, fn -> Akd.Generator.Task.gen([], []) end
    end

    test "gen with name creates the task file" do
      refute File.exists?(@test_task_path)
      Akd.Generator.Task.gen(["TestTask"], [])
      assert File.exists?(@test_task_path)
    end
  end
end
