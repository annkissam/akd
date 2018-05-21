defmodule Akd.Generator.DockerfileTest do
  use ExUnit.Case

  @app_path Path.join([__DIR__, "..", "..", "fixtures", "gentester"])
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

  describe "gen/2" do
    test "gen without name produces a dockerfile with name Dockerfile" do
      refute File.exists?(@test_dockerfile_path)
      Akd.Generator.Dockerfile.gen(["Dockerfile"], [type: "base", os: "centos"])
      assert File.exists?(@test_dockerfile_path)
    end

    test "gen with name creates the docker file" do
      refute File.exists?(@test_dockerfile_path)
      Akd.Generator.Dockerfile.gen(["Dockerfile"], [type: "base", os: "centos"])
      assert File.exists?(@test_dockerfile_path)
    end
  end
end
