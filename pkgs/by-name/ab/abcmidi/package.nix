{
  fetchFromGitHub,
  lib,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "abcmidi";
  version = "2025.02.16";

  src = fetchFromGitHub {
    owner = "sshlien";
    repo = "abcmidi";
    tag = finalAttrs.version;
    hash = "sha256-/woeQ5JyoEfDxMclWNeiqHR/I/iWocp1MWXwB3cvxbo=";
  };

  meta = {
    homepage = "https://abc.sourceforge.net/abcMIDI/";
    downloadPage = "https://ifdo.ca/~seymour/runabc/top.html";
    license = lib.licenses.gpl2Plus;
    description = "Utilities for converting between abc and MIDI";
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})
