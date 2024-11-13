{
  lib,
  stdenv,

  fetchFromGitHub,

  cmake,
  ninja,

  gflags,
  glog,
  folly,
  fbthrift,
  fizz,
  wangle,
  apple-sdk_11,
  darwinMinVersionHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fb303";
  version = "2024.11.18.00";

  src = fetchFromGitHub {
    owner = "facebook";
    repo = "fb303";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-3zQLX42qeOE2bbFmu4Kuvu0Fvq2mBq8YgkVGpyfwaak=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs =
    [
      gflags
      glog
      folly
      fbthrift
      fizz
      wangle
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      apple-sdk_11
      (darwinMinVersionHook "11.0")
    ];

  cmakeFlags = [
    (lib.cmakeBool "PYTHON_EXTENSIONS" false)
  ];

  meta = {
    description = "Base Thrift service and a common set of functionality for querying stats, options, and other information from a service";
    homepage = "https://github.com/facebook/fb303";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ kylesferrazza ];
  };
})
