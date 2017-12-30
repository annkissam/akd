defmodule Akd.Generator.HookTest do
  use ExUnit.Case

  @app_path Path.join([__DIR__, "..", "..", "fixtures", "gentester"])
  @test_hook_path Path.join([@app_path, "lib", "test_hook.ex"])

  setup do
    old_dir = File.cwd!
    File.cd!(@app_path)

    # Cleanup for the test
    {:ok, _} = File.rm_rf(@test_hook_path)

    on_exit fn ->
      # Cleanup after the tests
      {:ok, _} = File.rm_rf(@test_hook_path)
      File.cd!(old_dir)
    end

    []
  end

  describe "gen/2" do
    test "gen without name produces an error" do
      assert_raise FunctionClauseError, fn -> Akd.Generator.Hook.gen([], []) end
    end

    test "gen with name creates the hook file" do
      refute File.exists?(@test_hook_path)
      Akd.Generator.Hook.gen(["TestHook"], [])
      assert File.exists?(@test_hook_path)
    end
  end
end
