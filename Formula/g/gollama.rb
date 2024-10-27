class Gollama < Formula
  desc "Go manage your Ollama models"
  homepage "https://smcleod.net"
  url "https://github.com/sammcj/gollama/archive/refs/tags/v1.27.14.tar.gz"
  sha256 "a899b57dab7ae5a382807402a917dbc23a36cf69a7a4b7e2f552d9ccab6cc409"
  license "MIT"
  head "https://github.com/sammcj/gollama.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0d397db7b239ce68618509ba4efeb77001177e67c1e4be173cc235be6ad04571"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "bbf661b2c171c3285a5c91617f538975d2292f47e75d9299ef080dd25635c72b"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "d04ec6817abe7601284fb8a740b5c20fbaec069de977795ee03c5cff79919574"
    sha256 cellar: :any_skip_relocation, sonoma:        "3c206b0a1b5002f9b59043ae0642a1aef1416822dc3fefd3b82257b0abd6f619"
    sha256 cellar: :any_skip_relocation, ventura:       "dddcf2687207fbc2ed94cd44a08b4e862f943d45ed3e2fea59a8211535425d31"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "e374fe689e32afeb793976573683312651e138d5410c3378db0781baabaab829"
  end

  depends_on "go" => :build
  depends_on "ollama" => :test

  def install
    ldflags = %W[
      -s -w
      -X main.Version=#{version}
    ]
    system "go", "build", *std_go_args(ldflags:)
  end

  test do
    assert_match version.to_s, shell_output(bin/"gollama -v")

    port = free_port
    ENV["OLLAMA_HOST"] = "localhost:#{port}"

    pid = fork { exec "#{Formula["ollama"].opt_bin}/ollama", "serve" }
    sleep 3
    begin
      assert_match "No matching models found.",
        shell_output(bin/"gollama -h http://localhost:#{port} -s chatgpt")
    ensure
      Process.kill "SIGTERM", pid
    end
  end
end
