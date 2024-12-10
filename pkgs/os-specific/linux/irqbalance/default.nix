{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  autoreconfHook,
  pkg-config,
  glib,
  ncurses,
  libcap_ng,
}:

stdenv.mkDerivation rec {
  pname = "irqbalance";
  version = "1.9.4";

  src = fetchFromGitHub {
    owner = "irqbalance";
    repo = "irqbalance";
    rev = "v${version}";
    sha256 = "sha256-7es7wwsPnDSF37uL5SCgAQB+u+qGWmWDHOh3JkHuXMs=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];
  buildInputs = [
    glib
    ncurses
    libcap_ng
  ];

  LDFLAGS = "-lncurses";

  postInstall = ''
    # Systemd service
    mkdir -p $out/lib/systemd/system
    grep -vi "EnvironmentFile" misc/irqbalance.service >$out/lib/systemd/system/irqbalance.service
    substituteInPlace $out/lib/systemd/system/irqbalance.service \
      --replace /usr/sbin/irqbalance $out/bin/irqbalance \
      --replace ' $IRQBALANCE_ARGS' ""
  '';

  meta = with lib; {
    homepage = "https://github.com/Irqbalance/irqbalance";
    changelog = "https://github.com/Irqbalance/irqbalance/releases/tag/v${version}";
    description = "A daemon to help balance the cpu load generated by interrupts across all of a systems cpus";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ moni ];
  };
}
