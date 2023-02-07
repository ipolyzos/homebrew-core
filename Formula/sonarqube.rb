class Sonarqube < Formula
  desc "Manage code quality"
  homepage "https://www.sonarqube.org/"
  url "https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.0.65466.zip"
  sha256 "f5b3045ac40b99dfc2ab45c0990074f4b15e426bdb91533d77f3b94b73d3d411"
  license "LGPL-3.0-or-later"

  livecheck do
    url "https://www.sonarsource.com/products/sonarqube/downloads/"
    regex(/href=.*?sonarqube[._-]v?(\d+(?:\.\d+)+)\.zip/i)
  end

  bottle do
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "9c916beb8876dbfb418013585037698613b8b09bf80d25b211c35f986f1c3047"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "9c916beb8876dbfb418013585037698613b8b09bf80d25b211c35f986f1c3047"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "9c916beb8876dbfb418013585037698613b8b09bf80d25b211c35f986f1c3047"
    sha256 cellar: :any_skip_relocation, ventura:        "9c916beb8876dbfb418013585037698613b8b09bf80d25b211c35f986f1c3047"
    sha256 cellar: :any_skip_relocation, monterey:       "9c916beb8876dbfb418013585037698613b8b09bf80d25b211c35f986f1c3047"
    sha256 cellar: :any_skip_relocation, big_sur:        "9c916beb8876dbfb418013585037698613b8b09bf80d25b211c35f986f1c3047"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "199c84355c54cc7ed7ee9309921f5c44527fea01b10b618b2a89f7eab4f14757"
  end

  depends_on "openjdk@17"

  conflicts_with "sonarqube-lts", because: "both install the same binaries"

  def install
    platform = OS.mac? ? "macosx-universal-64" : "linux-x86-64"

    inreplace buildpath/"bin"/platform/"sonar.sh",
      %r{^PIDFILE="\./\$APP_NAME\.pid"$},
      "PIDFILE=#{var}/run/$APP_NAME.pid"

    inreplace "conf/sonar.properties" do |s|
      # Write log/data/temp files outside of installation directory
      s.sub!(/^#sonar\.path\.data=.*/, "sonar.path.data=#{var}/sonarqube/data")
      s.sub!(/^#sonar\.path\.logs=.*/, "sonar.path.logs=#{var}/sonarqube/logs")
      s.sub!(/^#sonar\.path\.temp=.*/, "sonar.path.temp=#{var}/sonarqube/temp")
    end

    libexec.install Dir["*"]
    env = Language::Java.overridable_java_home_env("17")
    env["PATH"] = "$JAVA_HOME/bin:$PATH"
    (bin/"sonar").write_env_script libexec/"bin"/platform/"sonar.sh", env
  end

  def post_install
    (var/"run").mkpath
    (var/"sonarqube/logs").mkpath
  end

  def caveats
    <<~EOS
      Data: #{var}/sonarqube/data
      Logs: #{var}/sonarqube/logs
      Temp: #{var}/sonarqube/temp
    EOS
  end

  service do
    run [opt_bin/"sonar", "console"]
    keep_alive true
  end

  test do
    port = free_port
    ENV["SONAR_WEB_PORT"] = port.to_s
    ENV["SONAR_EMBEDDEDDATABASE_PORT"] = free_port.to_s
    ENV["SONAR_SEARCH_PORT"] = free_port.to_s
    ENV["SONAR_PATH_DATA"] = testpath/"data"
    ENV["SONAR_PATH_LOGS"] = testpath/"logs"
    ENV["SONAR_PATH_TEMP"] = testpath/"temp"
    ENV["SONAR_TELEMETRY_ENABLE"] = "false"

    assert_match(/SonarQube.* is not running/, shell_output("#{bin}/sonar status", 1))
    pid = fork { exec bin/"sonar", "console" }
    begin
      sleep 15
      output = shell_output("#{bin}/sonar status")
      assert_match(/SonarQube is running \([0-9]*?\)/, output)
    ensure
      Process.kill 9, pid
      Process.wait pid
    end
  end
end
