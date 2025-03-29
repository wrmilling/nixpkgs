{
  lib,
  fetchFromGitHub,
  cmake,
  llvmPackages,
  git,
}:
llvmPackages.stdenv.mkDerivation rec {
  pname = "enzyme";
  version = "0.0.173";

  src = fetchFromGitHub {
    owner = "EnzymeAD";
    repo = "Enzyme";
    rev = "v${version}";
    hash = "sha256-Yyn0yWcOWb379rzaA+KW0KiLVg0nbIwJJQ8NhQAsuN8=";
  };

  postPatch = ''
    patchShebangs enzyme
  '';

  llvm = llvmPackages.llvm;
  clang = llvmPackages.clang-unwrapped;

  buildInputs = [
    cmake
    git
    llvm
    clang
  ];

  cmakeDir = "../enzyme";

  cmakeFlags = [
    "-DLLVM_DIR=${llvm.dev}"
    "-DClang_DIR=${clang.dev}"
  ];

  enableParallelBuilding = true;

  meta = {
    homepage = "https://enzyme.mit.edu/";
    description = "High-performance automatic differentiation of LLVM and MLIR";
    maintainers = with lib.maintainers; [ kiranshila ];
    platforms = lib.platforms.all;
    license = with lib.licenses; [
      asl20
      llvm-exception
    ];
  };
}
