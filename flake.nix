{
  description = "suckless dev shells (st, dmenu, dwm)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      mk_suckless_shell = { pc_names, extra_libs ? [ ], note ? "" }:
        let
          pc_pkg = name:
            {
              x11 = pkgs.xorg.libX11;
              xft = pkgs.xorg.libXft;
              xrender = pkgs.xorg.libXrender;
              xinerama = pkgs.xorg.libXinerama;
              xrandr = pkgs.xorg.libXrandr;
              freetype2 = pkgs.freetype;
              fontconfig = pkgs.fontconfig;
              harfbuzz = pkgs.harfbuzz;
              imlib2 = pkgs.imlib2;
              zlib = pkgs.zlib;
            }.${name};
          deps = builtins.map pc_pkg pc_names;
          pc_list = builtins.concatStringsSep " " pc_names;
          mk_incs = "${pkgs.pkg-config}/bin/pkg-config --cflags ${pc_list}";
          mk_libs = "${pkgs.pkg-config}/bin/pkg-config --libs   ${pc_list}";
          libs_suffix = builtins.concatStringsSep " " extra_libs;
        in
        pkgs.mkShell {
          packages = [ pkgs.pkg-config ] ++ deps;
          shellHook = ''
            export INCS="$(${mk_incs})"
            export LIBS="$(${mk_libs}) ${libs_suffix}"
            ${if note == "" then "" else "echo ${note}"}
          '';
        };

    in
    {
      devShells.${system} = {
        st = mk_suckless_shell {
          pc_names = [ "x11" "xft" "xrender" "xinerama" "freetype2" "harfbuzz" "imlib2" "zlib" ];
          extra_libs = [ "-lm" ];
          note = "st dev shell → run: make clean && make";
        };

        dmenu = mk_suckless_shell {
          pc_names = [ "x11" "xft" "xinerama" "freetype2" "fontconfig" ];
          note = "dmenu dev shell → run: make clean && make";
        };

        dwm = mk_suckless_shell {
          pc_names = [ "x11" "xft" "xinerama" "freetype2" "fontconfig" ];
          note = "dwm dev shell → run: make clean && make";
        };

        default = self.devShells.${system}.st;
      };
    };
}

