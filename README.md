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

## link について

`link.sh` は `files/` 配下の設定ファイルをホームディレクトリへシンボリックリンクします。  
既に同名のファイルがある場合は `<ファイル名>.bak` として退避したうえでリンクを作成します。

リンク対象:
- `files/.zshrc` → `~/.zshrc`
- `files/.ssh/config` → `~/.ssh/config`
