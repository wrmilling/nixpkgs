{ lib, stdenv, fetchurl, pkg-config, bison, flex
, asciidoc, libxslt, findXMLCatalogs, docbook_xml_dtd_45, docbook_xsl
, libmnl, libnftnl, libpcap
, gmp, jansson
, autoreconfHook
, withDebugSymbols ? false
, withCli ? true, libedit
, withXtables ? true, iptables
, nixosTests
, gitUpdater
}:

stdenv.mkDerivation rec {
  version = "1.1.1";
  pname = "nftables";

  src = fetchurl {
    url = "https://netfilter.org/projects/nftables/files/${pname}-${version}.tar.xz";
    hash = "sha256-Y1iDDzpk8x45sK1CHX2tzSQLcjQ97UjY7xO4+vIEhlo=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config bison flex
    asciidoc docbook_xml_dtd_45 docbook_xsl findXMLCatalogs libxslt
  ];

  buildInputs = [
    libmnl libnftnl libpcap
    gmp jansson
  ] ++ lib.optional withCli libedit
    ++ lib.optional withXtables iptables;

  configureFlags = [
    "--with-json"
    (lib.withFeatureAs withCli "cli" "editline")
  ] ++ lib.optional (!withDebugSymbols) "--disable-debug"
    ++ lib.optional withXtables "--with-xtables";

  enableParallelBuilding = true;

  passthru.tests = {
    inherit (nixosTests) firewall-nftables;
    lxd-nftables = nixosTests.lxd.nftables;
    nat = { inherit (nixosTests.nat.nftables) firewall standalone; };
  };

  passthru.updateScript = gitUpdater {
    url = "https://git.netfilter.org/nftables";
    rev-prefix = "v";
  };

  meta = with lib; {
    description = "Project that aims to replace the existing {ip,ip6,arp,eb}tables framework";
    homepage = "https://netfilter.org/projects/nftables/";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ izorkin ] ++ teams.helsinki-systems.members;
    mainProgram = "nft";
  };
}
