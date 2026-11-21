# 公式のインストーラで入れるツールの仕組み。
# 何を入れるかは、common.nix が dotfiles.installerTools に書く。全マシンで入れるのが基本である。
# Omarchy だけは、omarchy.nix で一覧を空にしている
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # 1 行に「名前、コマンドの場所、インストーラの URL、インストーラに渡す引数」をタブ区切りで書いた一覧
  installerToolsList = pkgs.writeText "installer-tools" (
    lib.concatMapStrings (
      t: "${t.name}\t${t.present}\t${t.url}\t${t.args or ""}\n"
    ) config.dotfiles.installerTools
  );
in
{
  options.dotfiles.installerTools = lib.mkOption {
    type = lib.types.listOf (lib.types.attrsOf lib.types.str);
    default = [ ];
    description = ''
      公式のインストーラで入れるツール。ツール自身が新しい版に更新するので、Nix で版を固定しない。
      反映のときに、present にコマンドがないものだけを入れる。
    '';
  };

  config = {
    # scripts/check が読む一覧
    xdg.configFile."dotfiles/installer-tools".source = installerToolsList;

    home.activation.installInstallerTools = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      # 一覧は 3 番の入力から読む。標準入力から読むと、インストーラが標準入力を読んだときに一覧を食べてしまう
      while IFS="$(printf '\t')" read -r -u 3 name present url args; do
        [ -x "$present" ] && continue
        echo "[INFO]  $name を公式のインストーラで入れる(ここからインストーラの出力)"
        if [[ -v DRY_RUN ]]; then
          echo "(dry run なので、実行しない: $url)"
          continue
        fi
        installer="$(mktemp)"
        # インストーラは curl や tar などを使うので、OS のコマンドを PATH に入れて実行する
        if ${pkgs.curl}/bin/curl -fsSL -o "$installer" "$url" && [ -s "$installer" ] \
          && env PATH="${pkgs.curl}/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH" ${pkgs.bash}/bin/bash "$installer" $args </dev/null; then
          echo "[INFO]  インストーラの出力はここまで"
        else
          echo "[WARN]  $name を入れられなかった。反映は続ける。scripts/check で確かめる"
        fi
        rm -f "$installer"
        [ -x "$present" ] || echo "[WARN]  $name のコマンドが $present にない"
      done 3< ${installerToolsList}
    '';
  };
}
