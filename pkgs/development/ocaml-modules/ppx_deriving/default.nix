{
  lib,
  fetchurl,
  buildDunePackage,
  ocaml,
  findlib,
  cppo,
  ppxlib,
  ppx_derivers,
  result,
  ounit,
  ounit2,
  ocaml-migrate-parsetree,
}:

let
  params =
    if lib.versionAtLeast ppxlib.version "0.20" then
      {
        version = "5.2.1";
        sha256 = "11h75dsbv3rs03pl67hdd3lbim7wjzh257ij9c75fcknbfr5ysz9";
      }
    else if lib.versionAtLeast ppxlib.version "0.15" then
      {
        version = "5.1";
        sha256 = "1i64fd7qrfzbam5hfbl01r0sx4iihsahcwqj13smmrjlnwi3nkxh";
      }
    else
      {
        version = "5.0";
        sha256 = "0fkzrn4pdyvf1kl0nwvhqidq01pnq3ql8zk1jd56hb0cxaw851w3";
      };
in

buildDunePackage rec {
  pname = "ppx_deriving";
  inherit (params) version;

  src = fetchurl {
    url = "https://github.com/ocaml-ppx/ppx_deriving/releases/download/v${version}/ppx_deriving-v${version}.tbz";
    inherit (params) sha256;
  };

  strictDeps = true;

  nativeBuildInputs = [ cppo ];
  buildInputs = [
    findlib
    ppxlib
  ];
  propagatedBuildInputs = lib.optional (lib.versionOlder version "5.2") ocaml-migrate-parsetree ++ [
    ppx_derivers
    result
  ];

  doCheck = lib.versionAtLeast ocaml.version "4.08" && lib.versionOlder ocaml.version "5.0";
  checkInputs = [
    (if lib.versionAtLeast version "5.2" then ounit2 else ounit)
  ];

  meta = with lib; {
    description = "deriving is a library simplifying type-driven code generation on OCaml >=4.02.";
    maintainers = [ maintainers.maurer ];
    license = licenses.mit;
  };
}
