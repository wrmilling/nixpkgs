{
  lib,
  stdenv,

  fetchFromGitHub,

  cmake,
  ninja,

  folly,
  fizz,
  openssl,
  glog,
  gflags,
  libevent,
  double-conversion,
  apple-sdk_11,
  darwinMinVersionHook,

  gtest,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wangle";
  version = "2024.11.18.00";

  src = fetchFromGitHub {
    owner = "facebook";
    repo = "wangle";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-4mqE9GgJP2f7QAykwdhMFoReE9wmPKOXqSHJ2MHP2G0=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs =
    [
      folly
      fizz
      openssl
      glog
      gflags
      libevent
      double-conversion
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      apple-sdk_11
      (darwinMinVersionHook "11.0")
    ];

  checkInputs = [
    gtest
  ];

  cmakeDir = "../wangle";

  cmakeFlags = [
    (lib.cmakeBool "BUILD_TESTS" finalAttrs.finalPackage.doCheck)
  ];

  env.GTEST_FILTER =
    "-"
    + lib.concatStringsSep ":" (
      [
        # these depend on example pem files from the folly source tree (?)
        "SSLContextManagerTest.TestSingleClientCAFileSet"
        "SSLContextManagerTest.TestMultipleClientCAsSet"
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        # flaky
        "BroadcastPoolTest.ThreadLocalPool"
        "Bootstrap.UDPClientServerTest"
      ]
    );

  __darwinAllowLocalNetworking = true;

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    ctest -j $NIX_BUILD_CORES --output-on-failure ${
      # Deterministic glibc abort 🫠
      lib.optionalString stdenv.hostPlatform.isLinux (
        lib.escapeShellArgs [
          "--exclude-regex"
          "^(BootstrapTest|BroadcastPoolTest)$"
        ]
      )
    }

    runHook postCheck
  '';

  meta = {
    description = "Open-source C++ networking library";
    longDescription = ''
      Wangle is a framework providing a set of common client/server
      abstractions for building services in a consistent, modular, and
      composable way.
    '';
    homepage = "https://github.com/facebook/wangle";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [
      pierreis
      kylesferrazza
    ];
  };
})
