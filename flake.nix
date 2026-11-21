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
        omarchy = "x86_64-linux";
      };

      mkHome =
        name: system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./hosts/${name}.nix
            {
              # このマシンがどの名前で反映されたかを残す。scripts/switch と scripts/check が読む
              xdg.configFile."dotfiles/host".text = name;

              # ユーザー名とホームの場所は、定義に書かず、実行したマシンの $USER と $HOME から読み取る。
              # どのユーザー名のマシンでも、同じ定義を使えるようにするためである。
              # 環境変数を読むには --impure が要る(scripts/ のコマンドは付けている)
              home.username = builtins.getEnv "USER";
              home.homeDirectory =
                let
                  home = builtins.getEnv "HOME";
                in
                if home == "" then
                  throw "$HOME を読めない。--impure を付けて実行する(scripts/switch、scripts/check、scripts/setup は付けている)"
                else
                  home;
            }
          ];
        };
    in
    {
      homeConfigurations = nixpkgs.lib.mapAttrs mkHome hosts;
    };
}
