{ callPackage, fetchpatch2, openssl, python3, enableNpm ? true }:

let
  buildNodejs = callPackage ./nodejs.nix {
    inherit openssl;
    python = python3;
  };
in
buildNodejs {
  inherit enableNpm;
  version = "22.11.0";
  sha256 = "bbf0297761d53aefda9d7855c57c7d2c272b83a7b5bad4fea9cb29006d8e1d35";
  patches = [
    ./configure-emulator.patch
    ./configure-armv6-vfpv2.patch
    ./disable-darwin-v8-system-instrumentation-node19.patch
    ./bypass-darwin-xcrun-node16.patch
    ./node-npm-build-npm-package-logic.patch
    ./use-correct-env-in-tests.patch
    ./bin-sh-node-run-v22.patch

    # Fix for https://github.com/NixOS/nixpkgs/issues/355919
    # FIXME: remove after a minor point release
    (fetchpatch2 {
      url = "https://github.com/nodejs/node/commit/a094a8166cd772f89e92b5deef168e5e599fa815.patch?full_index=1";
      hash = "sha256-5FZfozYWRa1ZI/f+e+xpdn974Jg2DbiHbua13XUQP5E=";
    })
    (fetchpatch2 {
      url = "https://github.com/nodejs/node/commit/f270462c09ddfd770291a7c8a2cd204b2c63d730.patch?full_index=1";
      hash = "sha256-Err0i5g7WtXcnhykKgrS3ocX7/3oV9UrT0SNeRtMZNU=";
    })
    # fixes test failure, remove when included in release
    (fetchpatch2 {
      url = "https://github.com/nodejs/node/commit/b6fe731c55eb4cb9d14042a23e5002ed39b7c8b7.patch?full_index=1";
      hash = "sha256-KoKsQBFKUji0GeEPTR8ixBflCiHBhPqd2cPVPuKyua8=";
    })
  ];
}
