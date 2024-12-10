{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  libgit2,
  openssl,
  stdenv,
  darwin,
  git,
}:

rustPlatform.buildRustPackage rec {
  pname = "cargo-generate";
  version = "0.21.1";

  src = fetchFromGitHub {
    owner = "cargo-generate";
    repo = "cargo-generate";
    rev = "v${version}";
    sha256 = "sha256-Pza1MK5yWpuNfaaFAJy5/Pf+t0TN1Hzc5wKcpmMpEf0=";
  };

  cargoHash = "sha256-b6WfsDTAZgxA977JhdlafE+POPvMLl8Z7CzEf+L2+Us=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs =
    [
      libgit2
      openssl
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
    ];

  nativeCheckInputs = [ git ];

  # disable vendored libgit2 and openssl
  buildNoDefaultFeatures = true;

  preCheck = ''
    export HOME=$(mktemp -d) USER=nixbld
    git config --global user.name Nixbld
    git config --global user.email nixbld@localhost.localnet
  '';

  # Exclude some tests that don't work in sandbox:
  # - favorites_default_to_git_if_not_defined: requires network access to github.com
  # - should_canonicalize: the test assumes that it will be called from the /Users/<project_dir>/ folder on darwin variant.
  checkFlags =
    [
      "--skip=favorites::favorites_default_to_git_if_not_defined"
    ]
    ++ lib.optionals stdenv.isDarwin [
      "--skip=git::utils::should_canonicalize"
    ];

  env = {
    LIBGIT2_NO_VENDOR = 1;
  };

  meta = with lib; {
    description = "A tool to generate a new Rust project by leveraging a pre-existing git repository as a template";
    mainProgram = "cargo-generate";
    homepage = "https://github.com/cargo-generate/cargo-generate";
    changelog = "https://github.com/cargo-generate/cargo-generate/blob/v${version}/CHANGELOG.md";
    license = with licenses; [
      asl20 # or
      mit
    ];
    maintainers = with maintainers; [
      figsoda
      turbomack
      matthiasbeyer
    ];
  };
}
