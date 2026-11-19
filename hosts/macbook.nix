{
  # このマシンが使う範囲を並べる
  imports = [
    ../modules/common.nix
    ../modules/darwin.nix
  ];

  home.username = "juc";
  home.homeDirectory = "/Users/juc";
}
