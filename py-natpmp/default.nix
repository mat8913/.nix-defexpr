{ lib
, buildPythonPackage
, fetchPypi
, setuptools
}:

buildPythonPackage rec {
  pname = "py-natpmp";
  version = "0.2.5";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-8aGXRZA5cHh7eW7bK+i/ipcUZzMiYFLFdEFmNMlQD4s=";
  };


  build-system = [
    setuptools
  ];
}
