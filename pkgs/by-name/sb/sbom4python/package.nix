{
  lib,
  python3Packages,
  fetchFromGitHub,
  sbom2dot,
  sbom4files,
  versionCheckHook,
}:

python3Packages.buildPythonApplication rec {
  pname = "sbom4python";
  version = "0.12.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "anthonyharrison";
    repo = "sbom4python";
    tag = "v${version}";
    hash = "sha256-H96M/X6WKSrA3zs0uLUHqY2zmsXLNZ8OtekC1MDfF1s=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    importlib-metadata
    lib4package
    lib4sbom
    sbom2dot
    sbom4files
    setuptools # for pkg_resources
    toml
  ];

  nativeCheckInputs = [
    versionCheckHook
  ];
  versionCheckProgramArg = [ "--version" ];

  pythonImportsCheck = [
    "sbom4python"
  ];

  meta = {
    changelog = "https://github.com/anthonyharrison/sbom4python/releases/tag/${src.tag}";
    description = "A tool to generate a SBOM (Software Bill of Materials) for an installed Python module";
    homepage = "https://github.com/anthonyharrison/sbom4python";
    license = lib.licenses.asl20;
    mainProgram = "sbom4python";
    maintainers = with lib.maintainers; [ drupol ];
  };
}
