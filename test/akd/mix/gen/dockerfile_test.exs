Code.require_file("test/mix_test_helper.exs")

defmodule Akd.Mix.Gen.DockerfileTest do
  use ExUnit.Case

  import MixTestHelper

  @app_path Path.join([__DIR__, "..", "..", "..", "fixtures", "gentester"])
  @test_dockerfile_path Path.join([@app_path, "Dockerfile"])

  setup do
    old_dir = File.cwd!
    File.cd!(@app_path)

    # Cleanup for the test
    {:ok, _} = File.rm_rf(@test_dockerfile_path)

    on_exit fn ->
      # Cleanup after the tests
      {:ok, _} = File.rm_rf(@test_dockerfile_path)
      File.cd!(old_dir)
    end

    []
  end

  describe "run/1" do
    test "with name creates the dockerfile file" do
      refute File.exists?(@test_dockerfile_path)
      {:ok, _} = mix("akd.gen.dockerfile", ["Dockerfile"])
      assert File.exists?(@test_dockerfile_path)
    end

    test "with name creates the dockerfile file if ran from module" do
      refute File.exists?(@test_dockerfile_path)
      Mix.Tasks.Akd.Gen.Dockerfile.run(["Dockerfile"])
      assert File.exists?(@test_dockerfile_path)
    end
  end
end
