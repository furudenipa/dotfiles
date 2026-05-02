# About

初期設定について記したdotfiles

## 構成

files: 配置される設定ファイルをまとめたフォルダ

## files の構造

```
files/
├── .zshrc
└── .ssh/
    └── config
```

## zshrc 周辺のセットアップ

- `files/.zshrc`: Oh My Zsh 依存を外した zshrc（手動でプラグインを読み込む前提）
- `installers/zshrc.zsh`: `files/.zshrc` を `~/.zshrc` に symlink する installer
  - 既に同内容の symlink がある場合はスキップする
  - 既存の `~/.zshrc` を退避する場合は移動先をログに出す
- `installers/zshrc-plugins.zsh`: zshrc 用プラグイン（`zsh-autosuggestions` / `zsh-syntax-highlighting`）を
  固定バージョンで `~/.zsh/plugins/` に配置する installer

## link について

`lib/link.zsh` はシンボリックリンク作成用の関数を提供します。  
既に同名のファイルがある場合は `<ファイル名>.bak` として退避したうえでリンクを作成します。
既に `.bak` がある場合は `<ファイル名>.bak.<timestamp>` として退避します。

## installer を書かないといけないもの

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
