class AgentTeam < Formula
  desc "Create and manage a team of AI agents"
  homepage "https://github.com/Agent-Team-Forge/homebrew-tap"
  version "0.2.10"
  license :cannot_represent

  on_macos do
    depends_on arch: :arm64
    depends_on macos: :sequoia
    url "https://github.com/stick109/agent-team-releases/releases/download/v0.2.10/agentteam-osx-arm64.tar.gz"
    sha256 "e3108bba2897af8df604aae80d1c45137c8238c3a0e23265898369ec7f08c115"
  end

  on_linux do
    depends_on "icu4c@78"
    depends_on "openssl@3"
    on_intel do
      url "https://github.com/stick109/agent-team-releases/releases/download/v0.2.10/agentteam-linux-x64.tar.gz"
      sha256 "59c0afe6b4f9b89a9a59cee3ec4a3c39eff49839598d0f8158621e24a3f1ee5e"
    end
    on_arm do
      url "https://github.com/stick109/agent-team-releases/releases/download/v0.2.10/agentteam-linux-arm64.tar.gz"
      sha256 "4bd8577aedcc21bb6d27ba20b7a8cc920b86975ebfdfffb36d8c55cc84812108"
    end
  end

  def install
    libexec.install Dir["*"]
    if OS.linux?
      (bin/"agent-team").write_env_script libexec/"agent-team",
        LD_LIBRARY_PATH: "#{Formula["icu4c@78"].opt_lib}:#{Formula["openssl@3"].opt_lib}"
    else
      bin.install_symlink libexec/"agent-team"
    end
  end

  def caveats
    <<~EOS
      Docker with Compose must be installed and running for agent-team create.
      On Windows, run this formula inside WSL2 with Docker Desktop WSL integration.
      Keep team files in the WSL Linux filesystem to preserve secret permissions.
      Start with: agent-team init my-team
      Edit my-team/agent-team.json, then run: agent-team create my-team
      Upgrading the CLI does not upgrade an existing team's deployment.
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/agent-team version").strip
    team = testpath/"team with spaces"
    system bin/"agent-team", "init", team
    assert_path_exists team/"agent-team.json"
    assert_equal 0700, (team/".agent-team/secrets").stat.mode & 0777
    %w[architect developer tester].each do |role|
      assert_path_exists team/"agents/#{role}/AGENTS.md"
      assert_equal 0600, (team/".agent-team/secrets/#{role}.bootstrap").stat.mode & 0777
    end
  end
end
