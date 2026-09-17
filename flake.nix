{
  description = "C++ project template flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        projectName = "cplusplus-template";
        version = "0.1.0";

        devDeps = with pkgs; [
          cmake
          gnumake
          gcc13
          gdb
          valgrind
          clang
          clang-tools
          cppcheck
          cmake-format
          pkg-config
        ];

        runtimeDeps = with pkgs; [

        ];

        myApp = pkgs.stdenv.mkDerivation {
          pname = projectName;
          version = version;

          src = ./.;

          nativeBuildInputs = with pkgs; [ cmake gnumake gcc13 ];
          buildInputs = runtimeDeps;

          buildPhase = ''
            mkdir -p build
            cd build
            cmake .. -DCMAKE_INSTALL_PREFIX=$out
            make
          '';

          installPhase = ''
            cd build
            make install
          '';

          cmakeFlags = [
            "-DCMAKE_CXX_STANDARD=17"
            "-DCMAKE_BUILD_TYPE=Release"
          ];
        };

      in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = devDeps ++ runtimeDeps;

            shellHook = ''
            export PROJECT_ROOT=$(pwd)
            export PS1="(nix-cpp) $PS1"
            echo "🚀 Entering C++ development environment"
            echo "📦 GCC version: $(g++ --version | head -n1)"
            echo "🔨 CMake version: $(cmake --version | head -n1)"
            echo ""
            echo "Available commands:"
            echo "  - configure: Configure CMake build"
            echo "  - build:     Build the project"
            echo "  - test:      Run tests"
            echo "  - run:       Run the application"
            echo "  - debug:     Run with GDB"
            echo "  - valgrind:  Run with Valgrind"
            
            # Helper functions for the dev shell
            configure() {
              mkdir -p build && cd build
              cmake .. -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
              cd ..
            }
            build() {
              cmake --build build -- -j$(nproc)
            }
            
            test() {
              cd build && ctest --output-on-failure
              cd ..
            }
            
            run() {
              ./build/bin/${projectName}
            }
            
            debug() {
              gdb ./build/bin/${projectName}
            }
            
            valgrind() {
              valgrind --leak-check=full ./build/bin/${projectName}
            }
            
            clean() {
              rm -rf build
            }
            
            export -f configure build test run debug valgrind clean
          '';
            
          };

          packages = {
            default = myApp;
            app = myApp;

            debug = pkgs.stdenv.mkDerivation {
              pname = "${projectName}-debug";
              version = version;

              src = ./.;

              nativeBuildInputs = with pkgs; [ cmake gnumake gcc13 ];

              buildInputs = runtimeDeps;

            buildPhase = ''
              mkdir -p build
              cd build
              cmake .. -DCMAKE_INSTALL_PREFIX=$out -DCMAKE_BUILD_TYPE=Debug
              make
            '';

            installPhase = ''
              cd build
              make install
            '';

            cmakeFlags = [
              "-DCMAKE_CXX_STANDARD=17"
              "-DCMAKE_BUILD_TYPE=Debug"
              "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
            ];
            
            };
          };

          # running with nix run
          apps.default = {
            type = "app";
            program = "${myApp}/bin/${projectName}";
          };

          checks = {
            build = self.packages.${system}.default;
            debug-build = self.packages.${system}.debug;
          };
        });
}
