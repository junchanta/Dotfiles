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
      # マシンの一覧。名前は hosts/<名前>.nix と対応し、値はそのマシンの CPU と OS の組。
      # マシンを増やすときは、hosts/ に 1 ファイル足してここに 1 行足す
      hosts = {
        macbook = "aarch64-darwin";
      };

      mkHome =
        name: system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./hosts/${name}.nix
            # このマシンがどの名前で反映されたかを残す。scripts/switch と scripts/check が読む
            { xdg.configFile."dotfiles/host".text = name; }
          ];
        };
    in
    {
      homeConfigurations = nixpkgs.lib.mapAttrs mkHome hosts;
    };
}
