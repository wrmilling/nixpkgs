{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  cmake,
  makeWrapper,
  ninja,
  perl,
  brotli,
  openssl,
  libcap,
  libuv,
  wslay,
  zlib,
  withMruby ? true,
  bison,
  ruby,
  nixosTests,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "h2o";
  version = "2.3.0.20250417";

  src = fetchFromGitHub {
    owner = "h2o";
    repo = "h2o";
    rev = "a5f5c212bfbec54a6c098a21cf5f9c0b0b5d5895";
    sha256 = "sha256-+naLQWYx/nGOT24UbxzVl2UFW1sx9HksZkXahIm9byQ=";
  };

  outputs = [
    "out"
    "man"
    "dev"
    "lib"
  ];

  nativeBuildInputs =
    [
      pkg-config
      cmake
      makeWrapper
      ninja
    ]
    ++ lib.optionals withMruby [
      bison
      ruby
    ];

  buildInputs = [
    brotli
    openssl
    libcap
    libuv
    perl
    zlib
    wslay
  ];

  cmakeFlags = [
    "-DWITH_MRUBY=${if withMruby then "ON" else "OFF"}"
  ];

  postInstall = ''
    EXES="$(find "$out/share/h2o" -type f -executable)"
    for exe in $EXES; do
      wrapProgram "$exe" \
        --set "H2O_PERL" "${lib.getExe perl}" \
        --prefix "PATH" : "${lib.getBin openssl}/bin"
    done
  '';

  passthru = {
    tests = { inherit (nixosTests) h2o; };
  };

  meta = with lib; {
    description = "Optimized HTTP/1.x, HTTP/2, HTTP/3 server";
    homepage = "https://h2o.examp1e.net";
    license = licenses.mit;
    maintainers = with maintainers; [
      toastal
      thoughtpolice
    ];
    mainProgram = "h2o";
    platforms = platforms.linux;
  };
})
