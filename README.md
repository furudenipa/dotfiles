# About

初期設定について記したdotfiles

## 構成

files: 配置される設定ファイルをまとめたフォルダ

## files の構造

```
files/
├── .zshrc
├── .zshrc_new
└── .ssh/
    └── config
```

## zshrc 周辺のセットアップ

- `files/.zshrc_new`: Oh My Zsh 依存を外した zshrc（手動でプラグインを読み込む前提）
- `install-zshrc-plugins.zsh`: zshrc 用プラグイン（`zsh-autosuggestions` / `zsh-syntax-highlighting`）を
  固定バージョンで `~/.zsh/` に配置するスクリプト

## link について

`link.zsh` は `files/` 配下の設定ファイルをホームディレクトリへシンボリックリンクします。  
既に同名のファイルがある場合は `<ファイル名>.bak` として退避したうえでリンクを作成します。

リンク対象:
- `files/.zshrc` → `~/.zshrc`
- `files/.ssh/config` → `~/.ssh/config`
