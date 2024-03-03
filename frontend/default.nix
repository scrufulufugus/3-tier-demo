{ builder }:

builder rec {
  name = "frontend3Tier";
  pname = name;
  version = "1.0.0+1";

  # To build for the Web, use the targetFlutterPlatform argument.
  #targetFlutterPlatform = "web";

  src = ./.;
  autoPubspecLock = ./pubspec.lock;
}
