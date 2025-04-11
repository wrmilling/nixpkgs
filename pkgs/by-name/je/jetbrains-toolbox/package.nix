{
  lib,
  stdenv,
  appimageTools,
  fetchzip,
  fetchurl,
  makeWrapper,
  icu,
  undmg,
}:

let
  pname = "jetbrains-toolbox";
  version = "2.5.4.38621";

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Jetbrains Toolbox";
    homepage = "https://jetbrains.com/";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ AnatolyPopov ];
    platforms = [
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-linux"
      "x86_64-darwin"
    ];
    mainProgram = "jetbrains-toolbox";
  };

  selectSystem =
    attrs:
    attrs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  linux = appimageTools.wrapAppImage rec {
    inherit
      pname
      version
      passthru
      meta
      ;

    src = appimageTools.extractType2 {
      inherit pname version;
      src =
        let
          arch = selectSystem {
            x86_64-linux = "";
            aarch64-linux = "-arm64";
          };
        in
        fetchzip {
          url = "https://download.jetbrains.com/toolbox/jetbrains-toolbox-${version}${arch}.tar.gz";
          hash = selectSystem {
            x86_64-linux = "sha256-rq0Hn9g+/u9C8vbEVH2mv62c1dvxr+t9tBhf26swQgI=";
            aarch64-linux = "sha256-52wFejaKBSg/eeJu3NDGl1AdZLsJdi/838YeROD4Loc=";
          };
        }
        + "/jetbrains-toolbox";
      postExtract = ''
        patchelf --add-rpath ${lib.makeLibraryPath [ icu ]} $out/jetbrains-toolbox
      '';
    };

    nativeBuildInputs = [ makeWrapper ];

    extraInstallCommands = ''
      install -Dm644 ${src}/jetbrains-toolbox.desktop $out/share/applications/jetbrains-toolbox.desktop
      install -Dm644 ${src}/.DirIcon $out/share/icons/hicolor/scalable/apps/jetbrains-toolbox.svg
      wrapProgram $out/bin/jetbrains-toolbox \
        --append-flags "--update-failed"
    '';
  };

  darwin = stdenv.mkDerivation (finalAttrs: {
    inherit
      pname
      version
      passthru
      meta
      ;

    src =
      let
        arch = selectSystem {
          x86_64-darwin = "";
          aarch64-darwin = "-arm64";
        };
      in
      fetchurl {
        url = "https://download.jetbrains.com/toolbox/jetbrains-toolbox-${finalAttrs.version}${arch}.dmg";
        hash = selectSystem {
          x86_64-darwin = "sha256-y0zXQEqY5lj/e440dRtyBfaw8CwqqgzO3Ujreb37Z/I=";
          aarch64-darwin = "sha256-9Bj5puG9NUHO53oXBRlB5DvX9jGTmrkDgjV2QPH9qg0=";
        };
      };

    nativeBuildInputs = [ undmg ];

    sourceRoot = "JetBrains Toolbox.app";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/Applications $out/bin
      cp -r . $out/Applications/"JetBrains Toolbox.app"
      ln -s $out/Applications/"JetBrains Toolbox.app"/Contents/MacOS/jetbrains-toolbox $out/bin/jetbrains-toolbox

      runHook postInstall
    '';
  });
in
if stdenv.hostPlatform.isDarwin then darwin else linux
