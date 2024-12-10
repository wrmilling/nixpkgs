{
  lib,
  stdenv,
  fetchurl,
  m4,
  perl,
  help2man,
}:

# Note: this package is used for bootstrapping fetchurl, and thus
# cannot use fetchpatch! All mutable patches (generated by GitHub or
# cgit) that are needed here should be included directly in Nixpkgs as
# files.

stdenv.mkDerivation rec {
  pname = "bison";
  version = "3.8.2";

  src = fetchurl {
    url = "mirror://gnu/${pname}/${pname}-${version}.tar.gz";
    sha256 = "sha256-BsnhO99+sk1M62tZIFpPZ8LH5yExGWREMP6C+9FKCrs=";
  };

  # gnulib relies on --host= to detect iconv() features on musl().
  # Otherwise tests fail due to incorrect unicode symbol oconversion.
  configurePlatforms = [
    "build"
    "host"
  ];

  # there's a /bin/sh shebang in bin/yacc which when no strictDeps is patched with the build stdenv shell
  # however when cross-compiling it would still be patched with the build stdenv shell which would be wrong
  # cannot add bash to buildInputs due to infinite recursion
  strictDeps = stdenv.hostPlatform != stdenv.buildPlatform;

  nativeBuildInputs = [
    m4
    perl
  ] ++ lib.optional stdenv.hostPlatform.isSunOS help2man;
  propagatedBuildInputs = [ m4 ];

  enableParallelBuilding = true;

  # Normal check and install check largely execute the same test suite
  doCheck = false;
  doInstallCheck = true;

  meta = {
    homepage = "https://www.gnu.org/software/bison/";
    description = "Yacc-compatible parser generator";
    license = lib.licenses.gpl3Plus;

    longDescription = ''
      Bison is a general-purpose parser generator that converts an
      annotated context-free grammar into an LALR(1) or GLR parser for
      that grammar.  Once you are proficient with Bison, you can use
      it to develop a wide range of language parsers, from those used
      in simple desk calculators to complex programming languages.

      Bison is upward compatible with Yacc: all properly-written Yacc
      grammars ought to work with Bison with no change.  Anyone
      familiar with Yacc should be able to use Bison with little
      trouble.  You need to be fluent in C or C++ programming in order
      to use Bison.
    '';

    platforms = lib.platforms.unix;
  };

  passthru = {
    glrSupport = true;
  };
}
