Code.require_file("test/mix_test_helper.exs")

defmodule Akd.Mix.Gen.HookTest do
  use ExUnit.Case

  import MixTestHelper

  @app_path Path.join([__DIR__, "..", "..", "..", "fixtures", "gentester"])
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

  describe "run/1" do
    test "with name creates the hook file" do
      refute File.exists?(@test_hook_path)
      {:ok, _} = mix("akd.gen.hook", ["TestHook"])
      assert File.exists?(@test_hook_path)
    end
  end
end
