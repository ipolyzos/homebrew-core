class Comby < Formula
  desc "Tool for changing code across many languages"
  homepage "https://comby.dev"
  url "https://github.com/comby-tools/comby/archive/1.1.0.tar.gz"
  sha256 "c843c44dd75160454f49c9fad3785e840762e73ada35bd40adf394cb5933a505"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any, big_sur:     "b36a2c71ea7fce07482646776be5f4a380ddb7b8143a55350037d0576871cf2f"
    sha256 cellar: :any, catalina:    "8441273e383d1a79787cba483f9d27c78e03722596c4a80bd4bf636933226b69"
    sha256 cellar: :any, mojave:      "2630927aa177293db660deea99133bab70247c0f9c751c5e21d9a18c38f5a2c0"
    sha256 cellar: :any, high_sierra: "b7c4c8bf2817ec659a33f1fa8af1e049bba199e2f08bf246a99cbda036eba523"
  end

  depends_on "gmp" => :build
  depends_on "ocaml" => :build
  depends_on "opam" => :build
  depends_on "pcre"
  depends_on "pkg-config"

  uses_from_macos "m4"
  uses_from_macos "unzip"
  uses_from_macos "zlib"

  def install
    ENV.deparallelize
    opamroot = buildpath/".opam"
    ENV["OPAMROOT"] = opamroot
    ENV["OPAMYES"] = "1"

    system "opam", "init", "--no-setup", "--disable-sandboxing"
    system "opam", "config", "exec", "--", "opam", "install", ".", "--deps-only", "-y"

    ENV.prepend_path "LIBRARY_PATH", opamroot/"default/lib/hack_parallel" # for -lhp
    system "opam", "config", "exec", "--", "make", "release"

    bin.install "_build/default/src/main.exe" => "comby"
  end

  test do
    expect = <<~EXPECT
      --- /dev/null
      +++ /dev/null
      @@ -1,3 +1,3 @@
       int main(void) {
      -  printf("hello world!");
      +  printf("comby, hello!");
       }
    EXPECT

    input = <<~INPUT
      EOF
      int main(void) {
        printf("hello world!");
      }
      EOF
    INPUT

    match = 'printf(":[1] :[2]!")'
    rewrite = 'printf("comby, :[1]!")'

    assert_equal expect, shell_output("#{bin}/comby '#{match}' '#{rewrite}' .c -stdin -diff << #{input}")
  end
end
