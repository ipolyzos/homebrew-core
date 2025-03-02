class Cryptography < Formula
  desc "Cryptographic recipes and primitives for Python"
  homepage "https://cryptography.io/en/latest/"
  url "https://files.pythonhosted.org/packages/cd/25/4ce80c78963834b8a9fd1cc1266be5ed8d1840785c0f2e1b73b8d128d505/cryptography-44.0.2.tar.gz"
  sha256 "c63454aa261a0cf0c5b4718349629793e9e634993538db841165b3df74f37ec0"
  license any_of: ["Apache-2.0", "BSD-3-Clause"]
  head "https://github.com/pyca/cryptography.git", branch: "main"

  bottle do
    sha256 cellar: :any,                 arm64_sequoia: "e173728579ed2c369fa1415a5eeca18457773a07e54e6a193cfa2bf2cd530e62"
    sha256 cellar: :any,                 arm64_sonoma:  "2124464c22c21076446a8beaa8eeeaef9d1f8e1b34a2100c3df593ca18295c8a"
    sha256 cellar: :any,                 arm64_ventura: "65c02ccacc7c53d6eb28ed715f1a22f118ad03e0e4e139410f9cbf2544d36a78"
    sha256 cellar: :any,                 sonoma:        "cfe89646f340f1bddf44c5dd3200aff6f09c96a309039b489805fb2b32332944"
    sha256 cellar: :any,                 ventura:       "cb1f0e5b4d8161c9aeb1c26bc90eef9775df3e659a060a8c1e685c917c2b25f2"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "4ed89d148fff15c9a40b7e6418195e4528cb241844e086a9510ac33fc90471a6"
  end

  depends_on "maturin" => :build
  depends_on "pkgconf" => :build
  depends_on "python-setuptools" => :build
  depends_on "python@3.12" => [:build, :test]
  depends_on "python@3.13" => [:build, :test]
  depends_on "rust" => :build
  depends_on "cffi"
  depends_on "openssl@3"

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.start_with?("python@") }
        .map { |f| f.opt_libexec/"bin/python" }
  end

  def install
    # TODO: Avoid building multiple times as binaries are already built in limited API mode
    pythons.each do |python3|
      system python3, "-m", "pip", "install", *std_pip_args, "."
    end
  end

  test do
    (testpath/"test.py").write <<~PYTHON
      from cryptography.fernet import Fernet
      key = Fernet.generate_key()
      f = Fernet(key)
      token = f.encrypt(b"homebrew")
      print(f.decrypt(token))
    PYTHON

    pythons.each do |python3|
      assert_match "b'homebrew'", shell_output("#{python3} test.py")
    end
  end
end
