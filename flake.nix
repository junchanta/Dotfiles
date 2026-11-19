{
  description = "dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      # home-manager が使う nixpkgs を、上の nixpkgs と同じ版に揃える
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      # マシン 1 台分の設定を作る。system はそのマシンの CPU と OS の組
      mkHome =
        { system, modules }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          inherit modules;
        };
    in
    {
      # マシンを増やすときは、hosts/ に 1 ファイル足してここに 1 行足す
      homeConfigurations = {
        macbook = mkHome {
          system = "aarch64-darwin";
          modules = [ ./hosts/macbook.nix ];
        };
      };
    };
}
