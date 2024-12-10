{
  lib,
  callPackage,
  fetchFromGitHub,
  rustPlatform,
  cmake,
  pkg-config,
  protobuf,
  elfutils,
}:

rustPlatform.buildRustPackage rec {
  pname = "router";
  version = "1.30.1";

  src = fetchFromGitHub {
    owner = "apollographql";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-mQtIjfXDcEy5HfZbWauL0NQLPneGq9EJt/yB8zMuhSU=";
  };

  cargoHash = "sha256-XCDU6cXw+Wf5MR6m+HCI8/VFRRylMywktZbd5k7Lcwo=";

  nativeBuildInputs = [
    cmake
    pkg-config
    protobuf
  ];

  buildInputs = [
    elfutils
  ];

  # The v8 package will try to download a `librusty_v8.a` release at build time to our read-only filesystem
  # To avoid this we pre-download the file and export it via RUSTY_V8_ARCHIVE
  RUSTY_V8_ARCHIVE = callPackage ./librusty_v8.nix { };

  cargoTestFlags = [
    "-- --skip=uplink::test::stream_from_uplink_error_no_retry"
  ];

  meta = with lib; {
    description = "A configurable, high-performance routing runtime for Apollo Federation";
    homepage = "https://www.apollographql.com/docs/router/";
    license = licenses.elastic20;
    maintainers = [ maintainers.bbigras ];
    knownVulnerabilities = [ "CVE-2023-45812" ];
  };
}
