{
  lib,
  stdenv,
  llvm_meta,
  release_version,
  buildLlvmTools,
  monorepoSrc,
  runCommand,
  cmake,
  ninja,
  libxml2,
  libllvm,
  version,
  doCheck ?
    (
      !stdenv.hostPlatform.isx86_32 # TODO: why
    )
    && (!stdenv.hostPlatform.isMusl),
  devExtraCmakeFlags ? [ ],
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mlir";
  inherit version doCheck;

  # Blank llvm dir just so relative path works
  src = runCommand "${finalAttrs.pname}-src-${version}" { inherit (monorepoSrc) passthru; } (
    ''
      mkdir -p "$out"
    ''
    + lib.optionalString (lib.versionAtLeast release_version "14") ''
      cp -r ${monorepoSrc}/cmake "$out"
    ''
    + ''
      cp -r ${monorepoSrc}/mlir "$out"
      cp -r ${monorepoSrc}/third-party "$out/third-party"

      mkdir -p "$out/llvm"
    ''
  );

  sourceRoot = "${finalAttrs.src.name}/mlir";

  patches = [
    ./gnu-install-dirs.patch
  ];

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    libllvm
    libxml2
  ];

  cmakeFlags =
    [
      "-DLLVM_BUILD_TOOLS=ON"
      # Install headers as well
      "-DLLVM_INSTALL_TOOLCHAIN_ONLY=OFF"
      "-DMLIR_TOOLS_INSTALL_DIR=${placeholder "out"}/bin/"
      "-DLLVM_ENABLE_IDE=OFF"
      "-DMLIR_INSTALL_PACKAGE_DIR=${placeholder "dev"}/lib/cmake/mlir"
      "-DMLIR_INSTALL_CMAKE_DIR=${placeholder "dev"}/lib/cmake/mlir"
      "-DLLVM_BUILD_TESTS=${if finalAttrs.finalPackage.doCheck then "ON" else "OFF"}"
      "-DLLVM_ENABLE_FFI=ON"
      "-DLLVM_HOST_TRIPLE=${stdenv.hostPlatform.config}"
      "-DLLVM_DEFAULT_TARGET_TRIPLE=${stdenv.hostPlatform.config}"
      "-DLLVM_ENABLE_DUMP=ON"
      "-DLLVM_TABLEGEN_EXE=${buildLlvmTools.tblgen}/bin/llvm-tblgen"
      "-DMLIR_TABLEGEN_EXE=${buildLlvmTools.tblgen}/bin/mlir-tblgen"
      (lib.cmakeBool "LLVM_BUILD_LLVM_DYLIB" (!stdenv.hostPlatform.isStatic))
    ]
    ++ lib.optionals stdenv.hostPlatform.isStatic [
      # Disables building of shared libs, -fPIC is still injected by cc-wrapper
      "-DLLVM_ENABLE_PIC=OFF"
      "-DLLVM_BUILD_STATIC=ON"
      "-DLLVM_LINK_LLVM_DYLIB=OFF"
    ]
    ++ devExtraCmakeFlags;

  outputs = [
    "out"
    "dev"
  ];

  meta = llvm_meta // {
    # Very broken since the dependencies aren't propagating at all with tblgen through the CMake.
    broken = lib.versionAtLeast release_version "20";
    homepage = "https://mlir.llvm.org/";
    description = "Multi-Level IR Compiler Framework";
    longDescription = ''
      The MLIR project is a novel approach to building reusable and extensible
      compiler infrastructure. MLIR aims to address software fragmentation,
      improve compilation for heterogeneous hardware, significantly reduce
      the cost of building domain specific compilers, and aid in connecting
      existing compilers together.
    '';
  };
})
