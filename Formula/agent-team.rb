class AgentTeam < Formula
  desc "Create and manage a team of AI agents"
  homepage "https://github.com/Agent-Team-Forge/homebrew-tap"
  version "0.2.46"
  license :cannot_represent

  on_macos do
    depends_on arch: :arm64
    depends_on macos: :sequoia
    url "https://github.com/stick109/agent-team-releases/releases/download/v0.2.46/agentteam-osx-arm64.tar.gz"
    sha256 "1ebb8626cb5d4267ab261c5171a1d2b4b505774d58d8842d03f8b94ffe855568"
  end

  on_linux do
    depends_on "icu4c@78"
    on_intel do
      url "https://github.com/stick109/agent-team-releases/releases/download/v0.2.46/agentteam-linux-x64.tar.gz"
      sha256 "abbb258c2d8c013336c4eccb5c4352b5a766d28704c8d5bf5af15128aff78eb9"
    end
    on_arm do
      url "https://github.com/stick109/agent-team-releases/releases/download/v0.2.46/agentteam-linux-arm64.tar.gz"
      sha256 "9c32280ac800a46e8c4c05410b49ca800ba3b4a4662b0b8ca43d180b1ec62938"
    end
  end

  def install
    libexec.install Dir["*"]
    if OS.linux?
      # Use the distribution's OpenSSL with the binary's system glibc loader.
      # Homebrew's OpenSSL can require a newer glibc than Ubuntu 22.04 provides.
      (bin/"agent-team").write_env_script libexec/"agent-team",
        LD_LIBRARY_PATH: "#{Formula["icu4c@78"].opt_lib}"
    else
      bin.install_symlink libexec/"agent-team"
    end
  end

  def caveats
    <<~EOS
      Docker with Compose must be installed and running for agent-team create.
      On Windows, run this formula inside WSL2 with Docker Desktop WSL integration.
      On Linux, install the distribution's OpenSSL 3 runtime (Ubuntu 22.04: libssl3;
      Ubuntu 24.04: libssl3t64). The CLI uses system OpenSSL, not Homebrew OpenSSL.
      Keep team files in the WSL Linux filesystem to preserve secret permissions.
      Start with: agent-team init my-team
      Edit my-team/agent-team.json, then run: agent-team create my-team
      Upgrading the CLI does not upgrade an existing team's deployment.
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/agent-team version").strip
    team = testpath/"parent with spaces"/"team"
    system bin/"agent-team", "init", team
    assert_path_exists team/"agent-team.json"
    assert_equal 0700, (team/".agent-team/secrets").stat.mode & 0777
    %w[architect developer tester].each do |role|
      assert_path_exists team/"agents/#{role}/AGENTS.md"
      assert_equal 0600, (team/".agent-team/secrets/#{role}.bootstrap").stat.mode & 0777
    end

    # A legacy lock forces SHA-256 inside the packaged CLI before confirmation.
    # `version` and `init` alone do not exercise .NET's OpenSSL loader.
    require "digest"
    require "json"
    project = "agent-team-team-#{Digest::SHA256.hexdigest(team.to_s)[0, 10]}"
    release_lock = team/".agent-team-release-lock.json"
    lock_contents = JSON.generate({ "ProjectName" => project })
    release_lock.write lock_contents
    configuration = (team/"agent-team.json").read
    output = pipe_output("#{(bin/"agent-team").to_s.shellescape} delete #{team.to_s.shellescape}", "no\n", 0)
    assert_match "Type 'yes' and press Enter to continue:", output
    assert_match "Deletion cancelled; no resources were changed.", output
    assert_equal lock_contents, release_lock.read
    assert_equal configuration, (team/"agent-team.json").read
  end
end
