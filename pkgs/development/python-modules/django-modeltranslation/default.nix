{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pythonOlder,
  django,
  django-stubs,
  pytestCheckHook,
  pytest-cov-stub,
  pytest-django,
  parameterized,
}:
let
  # 0.18.12 was yanked from PyPI, it refers to this issue:
  # https://github.com/deschler/django-modeltranslation/issues/701
  version = "0.19.13";
in
buildPythonPackage {
  pname = "django-modeltranslation";
  inherit version;

  src = fetchFromGitHub {
    owner = "deschler";
    repo = "django-modeltranslation";
    tag = "v${version}";
    hash = "sha256-mn3dGSJbujULPT/PBAVvd1hlCukMItC4Z8dIZ+MWZ2w=";
  };

  disabled = pythonOlder "3.6";

  propagatedBuildInputs = [ django ];

  nativeCheckInputs = [
    django-stubs
    pytestCheckHook
    pytest-cov-stub
    pytest-django
    parameterized
  ];

  meta = with lib; {
    description = "Translates Django models using a registration approach";
    homepage = "https://github.com/deschler/django-modeltranslation";
    license = licenses.bsd3;
    maintainers = with maintainers; [ augustebaum ];
  };
}
