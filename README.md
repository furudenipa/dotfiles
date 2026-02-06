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
  固定バージョンで `~/.zsh/plugins/` に配置するスクリプト

## link について

`lib/link.zsh` はシンボリックリンク作成用の関数を提供します。  
既に同名のファイルがある場合は `<ファイル名>.bak` として退避したうえでリンクを作成します。

## installer を書かないといけないもの

- uv
- go
- python

## installer のログ方針

- すでにインストール済み: `info "<name> is already installed."`
- OS が対象外: `fail "unsupported OS: $OS_NAME"`
- 未実装 OS (Linux など): `warn "<name> for Linux is not implemented yet."` の後に
  `fail "<name> installer for Linux is TODO."`

## 存在を前提とするもの

- curl
- brew
