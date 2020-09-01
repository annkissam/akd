Code.require_file("test/mix_test_helper.exs")

defmodule Akd.Mix.Gen.TaskTest do
  use ExUnit.Case

  import MixTestHelper

  @app_path Path.join([__DIR__, "..", "..", "..", "fixtures", "gentester"])
  @test_task_path Path.join([@app_path, "lib", "mix", "tasks", "akd", "test_task.ex"])

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

  describe "run/1" do
    test "with name creates the task file" do
      refute File.exists?(@test_task_path)
      {:ok, _} = mix("akd.gen.task", ["TestTask"])
      assert File.exists?(@test_task_path)
    end

    test "with name creates the task file and other switches" do
      refute File.exists?(@test_task_path)
      {:ok, _} = mix("akd.gen.task", ["TestTask", "-f Akd.Fetcher.Git", "-w"])
      assert File.exists?(@test_task_path)
    end

    test "with name creates the task file from the task module" do
      refute File.exists?(@test_task_path)
      Mix.Tasks.Akd.Gen.Task.run(["TestTask"])
      assert File.exists?(@test_task_path)
    end

    test "with name creates the task file and other switches from the task module" do
      refute File.exists?(@test_task_path)
      Mix.Tasks.Akd.Gen.Task.run(["TestTask", "-f Akd.Fetcher.Git", "-w"])
      assert File.exists?(@test_task_path)
    end
  end
end
