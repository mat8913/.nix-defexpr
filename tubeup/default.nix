{ python3Packages, youtubeDL, makeWrapper }:

python3Packages.buildPythonApplication rec {

  pname = "tubeup";
  version = "0.0.17";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "03yy2bd7bghamc00r2ym206abf54jprmb70y9a0ih9227h4qqq2g";
  };

  nativeBuildInputs = [ makeWrapper ];
  propagatedBuildInputs = [ youtubeDL python3Packages.internetarchive python3Packages.docopt ];

  makeWrapperArgs = youtubeDL.makeWrapperArgs;
}
