class FernApi < Formula
  desc "Stripe-level SDKs and Docs for your API"
  homepage "https://buildwithfern.com/"
  url "https://registry.npmjs.org/fern-api/-/fern-api-0.56.3.tgz"
  sha256 "13aec57478658307d68088357383a75fcd574561980f0795f8042fcfccfbd339"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "65d6e42efb70180b55d98ded66725dce526b8835e7981cc09335644b197f3caf"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system bin/"fern", "init", "--docs", "--org", "brewtest"
    assert_path_exists testpath/"fern/docs.yml"
    assert_match "\"organization\": \"brewtest\"", (testpath/"fern/fern.config.json").read

    system bin/"fern", "--version"
  end
end
