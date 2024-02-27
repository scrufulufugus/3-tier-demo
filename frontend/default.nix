{ builder }:

builder rec {
  name = "frontend3Tier";
  pname = name;
  version = "1.0.0+1";
  src = ./.;
  autoPubspecLock = ./pubspec.lock;
}
