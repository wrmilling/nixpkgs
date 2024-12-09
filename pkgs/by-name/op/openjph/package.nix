{ lib, stdenv, fetchFromGitHub, cmake, validatePkgConfig, testers, nix-update-script }:

stdenv.mkDerivation (finalAttrs: {
  pname = "openjph";
  version = "0.18.1";

  src = fetchFromGitHub {
    owner = "aous72";
    repo = "openjph";
    rev = finalAttrs.version;
    hash = "sha256-cgJlgb4SrmVFqvmqGcG3+qMDteyVFlYzoy1IOo8BjA8=";
  };

  nativeBuildInputs = [ cmake validatePkgConfig ];

  outputs = [ "out" "dev" ];

  cmakeFlags = [
    (lib.cmakeBool "OJPH_ENABLE_TIFF_SUPPORT" false)
  ];

  strictDeps = true;

  passthru = {
    tests.pkg-config = testers.hasPkgConfigModules { package = finalAttrs.finalPackage; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Open-source implementation of JPEG2000 Part-15 (or JPH or HTJ2K)";
    homepage = "https://openjph.org/";
    maintainers = with lib.maintainers; [ abustany ];
    license = lib.licenses.bsd2;
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "openjph" ];
  };
})
