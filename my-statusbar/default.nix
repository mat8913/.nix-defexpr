{
  lib,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "my-statusbar";
  version = "1";
  pyproject = true;

  src = ./src;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    psutil
  ];
}
