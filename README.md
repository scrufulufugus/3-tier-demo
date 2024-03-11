# ThreeTier Demo Application

A simple shopping application built as a 3-tier architecture using Flutter, FastAPI, and SQLite.

## Building

### The Proper Way

This application uses nix to manage dependencies and building. If you do not already have nix installed with flakes enabled follow [this guide](https://zero-to-nix.com/start/install).

After nix is installed this program can be built by running the following:

``` sh
nix build
```

The resulting build can then be found in `./result`.

### Without Nix

The individual components of this project can be built without nix if necessary. Ensure that [flutter](https://docs.flutter.dev/get-started/install) and [poetry](https://python-poetry.org/) are installed, then follow the build instructions in the README of each component.

## Running

After building `./result/bin` will contain three executables:

- `db_helper`: Creates an example database
- `middleware`: Runs the FastAPI-based middleware
- `frontend`: Runs the Flutter-based frontend

`db_helper` Should be run before `middleware` and `middleware` must be running when `frontend` starts:

``` sh
MID_DATABASE=data.db ./result/bin/db_helper
MID_DATABASE=data.db ./result/bin/middleware
```

And in a new terminal:

``` sh
./result/bin/frontend
```
