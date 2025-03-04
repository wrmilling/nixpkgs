{
  lib,
  fetchFromGitHub,
  php,
  versionCheckHook,
}:

php.buildComposerProject (finalAttrs: {
  pname = "phel";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "phel-lang";
    repo = "phel-lang";
    rev = "v${finalAttrs.version}";
    hash = "sha256-EITeApaQ1nmQb53/DrSidcmWUACapjTUuUYuJQDML0Y=";
  };

  vendorHash = "sha256-SDLpl2gBvtVjREfcy1WDFqsGRK1fKr2wKPuBkPhApNI=";

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  versionCheckProgramArg = [ "--version" ];
  doInstallCheck = true;

  meta = {
    changelog = "https://github.com/phel-lang/phel-lang/releases/tag/v${finalAttrs.version}";
    description = "Phel is a functional programming language that compiles to PHP. A Lisp dialect inspired by Clojure and Janet";
    homepage = "https://github.com/phel-lang/phel-lang";
    license = lib.licenses.mit;
    mainProgram = "phel";
    maintainers = with lib.maintainers; [ drupol ];
  };
})
