{
  stdenv,
  fetchFromGitHub,
  xcbuildHook,
  apple-sdk,
}:
stdenv.mkDerivation {
  pname = "AutoHyperlinks";
  version = "0.9";
  src = fetchFromGitHub {
    owner = "Codeux-Software";
    repo = "Auto-Hyperlinks";
    rev = "10c16555305ea775cd4600f0f21594d868b26d6e";
    hash = "sha256-GMENz84bT5CH8Hq9LxNCokXbSwyniL3Y5wbW9oTt5EQ=";
  };
  nativeBuildInputs = [ xcbuildHook ];
  __structuredAttrs = true;
  buildInputs = [ apple-sdk ];
  xcbuildFlags = [
    "-verbose"
    "-configuration"
    "Release"
    "-target"
    "AutoHyperlinks.framework"
    # "CLANG_ENABLE_MODULES=NO"
    # "OTHER_LDFLAGS=-framework Foundation -framework AppKit -framework ApplicationServices -framework CoreFoundation -framework CoreGraphics -framework CoreServices"
    # "OTHER_CFLAGS=$(inherited) -fno-modules -fno-implicit-modules"
  ];
  # with darwin.apple_sdk.frameworks; [
  # ColorSync
  # CoreFoundation
  # CoreServices
  # Foundation
  # ];
}
