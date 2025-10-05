{ fetchFromGitHub }:

{
  dotnet-crypto = fetchFromGitHub {
    owner = "ProtonDriveApps";
    repo = "dotnet-crypto";
    rev = "5aac829ce0ab4b21f7ad61b4c5b348b168e94d9b";
    hash = "sha256-+YrM4ByfOZJr8rl+VV/j6I6+uvUVRUDTCH8xKBxkFYU=";
  };

  sdk-tech-demo = fetchFromGitHub {
    owner = "ProtonDriveApps";
    repo = "sdk-tech-demo";
    rev = "0e272b881590c70044b400b0d7be3ca6248ef954";
    hash = "sha256-OOhFQmWuhy8bJf9N3ZSyeTAoqAqZfLPr9FiZDloAGWM=";
  };

  unofficial-pdrive-cli = fetchFromGitHub {
    owner = "mat8913";
    repo = "unofficial-pdrive-cli";
    rev = "03670c7d28a55cd3305c37be6971f55634ef012e";
    hash = "sha256-rKlLIeLI3Oc524yf06lMtRz1o4/eP4mHLocoW5DP7e8=";
  };
}
