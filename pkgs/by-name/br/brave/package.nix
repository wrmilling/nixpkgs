# Expression generated by update.sh; do not edit it by hand!
{ stdenv, callPackage, ... }@args:

let
  pname = "brave";
  version = "1.74.51";

  allArchives = {
    aarch64-linux = {
      url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-browser_${version}_arm64.deb";
      hash = "sha256-rsoZ5AKdYGyg6zt6k/HlBfK+FNvVZdL5VjNMNYqpKls=";
    };
    x86_64-linux = {
      url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-browser_${version}_amd64.deb";
      hash = "sha256-ZlpKfTvsJKDmzpTCnPBqzCCvBKGJJCvOKi65KdEFGlI=";
    };
    aarch64-darwin = {
      url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-v${version}-darwin-arm64.zip";
      hash = "sha256-VKpxOffAg5+IereL3fLfDa8MSxVDmTKvf6VNbDuibhw=";
    };
    x86_64-darwin = {
      url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-v${version}-darwin-x64.zip";
      hash = "sha256-NrU/J7+7kS6w93bjbp56nviju33gR8tHBOwbNibG3vY=";
    };
  };

  archive =
    if builtins.hasAttr stdenv.system allArchives then
      allArchives.${stdenv.system}
    else
      throw "Unsupported platform.";

in
callPackage ./make-brave.nix (removeAttrs args [ "callPackage" ]) (
  archive
  // {
    inherit pname version;
  }
)
