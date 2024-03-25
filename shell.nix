#################### DevShell ####################
#
# Custom shell for bootstrapping on new hosts, modifying nix-config, and secrets management

{ pkgs ? # If pkgs is not defined, instantiate nixpkgs from locked commit
  let
    lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
    nixpkgs = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
      sha256 = lock.narHash;
    };
  in
  import nixpkgs { overlays = [ ]; }
, ...
}: {
  default = pkgs.mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command flakes repl-flake";
    nativeBuildInputs = builtins.attrValues
      {
        inherit (pkgs)
          # NOTE: Required for building 'nixpkgs-fmt' pre-commit hook on Darwin
          # REF: <https://discourse.nixos.org/t/nix-shell-rust-hello-world-ld-linkage-issue/17381/4>
          libiconv

          # Bootstrap packages
          direnv
          home-manager
          nil
          nix
          nixpkgs-fmt
          pre-commit

          # Core utilities
          bat
          coreutils-full
          coreutils-prefixed
          curl
          delta
          eza
          fd
          fzf
          git
          htop
          jq
          just
          less
          man
          neovim
          ripgrep

          # sop-nix related
          age
          gnupg
          openssh
          sops
          ssh-to-age

          # Toolchains
          rustc
          cargo
          ;
      } ++ [
      pkgs.bat-extras.batdiff
      pkgs.bat-extras.batgrep
      pkgs.bat-extras.batman
      pkgs.bat-extras.batpipe
      pkgs.bat-extras.batwatch
      pkgs.bat-extras.prettybat
    ];
  };
}
