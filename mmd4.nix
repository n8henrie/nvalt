{
  stdenv,
  fetchFromGitHub,
  perl,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "MultiMarkdown-4";
  version = "4.7.1";
  src = fetchFromGitHub {
    owner = "fletcher";
    repo = "MultiMarkdown-4";
    rev = finalAttrs.version;
    hash = "sha256-LdkjvFM/h79yz8YB7fmZQ7YqOActFeCAT6WWLvyl6iI=";
    fetchSubmodules = true;
  };
  nativeBuildInputs = [ perl ];
  patchPhase = ''
    patchShebangs --build enumsToPerl.pl
  '';
  makeFlags = [ "prefix=$(out)" ];
})
