{
  lib,
  fetchFromGitHub,
  nix-update-script,
  php,
  phpunit,
  testers,
}:

php.buildComposerProject2 (finalAttrs: {
  pname = "phpunit";
  version = "11.5.2";

  src = fetchFromGitHub {
    owner = "sebastianbergmann";
    repo = "phpunit";
    rev = finalAttrs.version;
    hash = "sha256-0NVoaUFmmV4EtaErhaqLxJzCbD2WuMaVZC2OHG9+gSA=";
  };

  vendorHash = "sha256-EkTERk8jJWxCZCJnSHfg3Tnn//Ny2985qXJNX/gad58=";

  passthru = {
    updateScript = nix-update-script { };
    tests.version = testers.testVersion { package = phpunit; };
  };

  meta = {
    changelog = "https://github.com/sebastianbergmann/phpunit/blob/${finalAttrs.version}/ChangeLog-${lib.versions.majorMinor finalAttrs.version}.md";
    description = "PHP Unit Testing framework";
    homepage = "https://phpunit.de";
    license = lib.licenses.bsd3;
    mainProgram = "phpunit";
    maintainers = with lib.maintainers; [ onny ] ++ lib.teams.php.members;
  };
})
