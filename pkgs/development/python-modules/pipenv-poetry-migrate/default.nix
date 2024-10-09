{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pytestCheckHook,
  pythonOlder,
  poetry-core,
  tomlkit,
  typer,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pipenv-poetry-migrate";
  version = "0.5.10";
  format = "pyproject";

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "yhino";
    repo = "pipenv-poetry-migrate";
    rev = "refs/tags/v${version}";
    hash = "sha256-ROi5Yj4Ht91Go2jkm6BQZyaJWtBKHk4ar1ly8jAPGlc=";
  };

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    setuptools # for pkg_resources
    tomlkit
    typer
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  meta = with lib; {
    description = "This is simple migration script, migrate pipenv to poetry";
    mainProgram = "pipenv-poetry-migrate";
    homepage = "https://github.com/yhino/pipenv-poetry-migrate";
    changelog = "https://github.com/yhino/pipenv-poetry-migrate/blob/v${version}/CHANGELOG.md";
    license = licenses.asl20;
    maintainers = with maintainers; [ gador ];
  };
}
