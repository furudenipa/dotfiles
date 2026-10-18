# dotfiles

自分の端末で使うツールと設定をまとめたリポジトリ。

## 初回セットアップ

Git・zsh・curlが使える状態で、リポジトリをcloneする。macOSではHomebrewも用意する。

```sh
git clone https://github.com/furudenipa/dotfiles.git ~/src/github.com/furudenipa/dotfiles
cd ~/src/github.com/furudenipa/dotfiles
```

以降のコマンドは、このディレクトリで実行する。

### 1. 端末に合う構成を選ぶ

`profiles/` から端末の用途に合うファイルを選び、実行前に内容を確認する。
`PROFILE_LAYERS` に、まとめて導入したいレイヤーを実行順に指定する。

| プロファイル | 用途 | 読み込むレイヤー |
| --- | --- | --- |
| `private-dev-mac` | 個人の開発用Mac | `core` → `dev` → `dev-personal` → `macos` |
| `work` | 仕事用Mac | `core` → `dev` → `dev-work` → `macos` |
| `private-dev-ubuntu` | 個人の開発用Ubuntu | `core` → `dev` → `dev-personal` |
| `private-ubuntu-server` | 個人のUbuntuサーバー | `core` → `infra` |

```sh
# プライベート開発用Mac
zsh setup.zsh -P private-dev-mac

# 仕事用Mac
zsh setup.zsh -P work

# プライベート開発用Ubuntu
zsh setup.zsh -P private-dev-ubuntu

# プライベートUbuntuサーバー
zsh setup.zsh -P private-ubuntu-server

```

各レイヤーの内容は次のとおり。具体的なツール一覧は `layers/` の各ファイルで確認できる。

| レイヤー | 内容 |
| --- | --- |
| `core` | 端末の用途を問わず使う、シェルや表示環境の基本設定・ツール |
| `dev` | ソースコードの編集、リポジトリ管理、検索、データ処理など、開発に共通して使うツール |
| `dev-personal` | 個人の開発環境で追加して使う、開発支援や日常作業のためのツール |
| `dev-work` | 仕事の開発環境で追加して使う設定・ツール（現在は空） |
| `macos` | ターミナルやクリップボード連携など、macOS固有の設定・ツール |
| `infra` | サーバー管理やインフラ運用に使う設定・ツール（現在は空） |

実行後はログの失敗表示も確認する。途中のツールが導入に失敗しても、後続へ進む場合がある。

### 2. zshの設定を配置する

`.zshrc` の配置は一括セットアップに含まれないため、別途実行する。

```sh
zsh install.zsh zshrc
```

新しいターミナルを開くと設定が読み込まれる。
現在の `.zshrc` はAtuinを読み込むため、`work` などAtuinを含まない構成では、先に追加する。

```sh
zsh install.zsh atuin
```

### 3. 機密情報のチェックを有効にする

このリポジトリをcloneした端末ごとに、後述の `pre-commit install` を実行する。
ツールを導入しただけでは、コミット時のチェックは有効にならない。

## 必要なツールだけ追加する

```sh
zsh install.zsh jq
zsh install.zsh ghostty

# zshのプラグインだけ導入する場合
zsh install.zsh zshrc-plugins

# ルートディレクトリ内ではinstallコマンドで書ける
install jq
```

## 設定ファイルの場所

普段編集する設定は `files/` にある。
以下はシンボリックリンクで配置されるため、リポジトリ内のファイルを編集すると配置先にも反映される。
設定を読み直すタイミングは各アプリによる。

| 編集するファイル | 配置先 | 配置するコマンド |
| --- | --- | --- |
| `files/.zshrc` | `~/.zshrc` | `zsh install.zsh zshrc` |
| `files/.config/ghostty/config` | `~/.config/ghostty/config` | `zsh install.zsh ghostty` |
| `files/.config/fastfetch/config.jsonc` | `~/.config/fastfetch/config.jsonc` | `zsh install.zsh fastfetch` |
| `files/.config/fastfetch/logo.txt` | `~/.config/fastfetch/logo.txt` | `zsh install.zsh fastfetch` |

配置先に既存のファイルがある場合は、同じ場所に `.bak` を付けて退避する。
すでに `.bak` があれば日時などを付けて残す。同じファイルへのリンクがある場合はそのまま使う。
リンク先として使い続けるため、cloneしたディレクトリは配置後も残しておく。

`files/.ssh/config` と `files/com.googlecode.iterm2.plist` は保管されているが、自動配置の対象にはなっていない。
また、`iterm2` の導入コマンドが配置するのはシェル連携スクリプトで、iTerm2本体やこのplistではない。

## 普段使うコマンド

このリポジトリの `.zshrc` で使えるショートカット。

| コマンド | 使い方 |
| --- | --- |
| `cr` / `cr 検索語` | ghq管理のリポジトリをfzfで選んで移動する（ghq・fzfが必要） |
| `qr "文字列"` | ターミナルにQRコードを表示する（qrencodeが必要） |
| `qrr` | クリップボード画像の最初のQRコードを読み、内容を表示してコピーする（macOS。pngpaste・zxing-cpp・jqが必要） |
| `k` / `kg` / `kd` | `kubectl` / `kubectl get` / `kubectl describe` の省略形（kubectlは別途導入） |
| `cd ~src` | `~/src` へ移動する |
| `cd ~furudenipa` | `~/src/github.com/furudenipa` へ移動する |

## 機密情報の誤コミット防止

Gitleaksとpre-commitで、コミット時に機密情報をチェックする。
macOSでは `dev` レイヤーに含まれる。個別に導入する場合は次を実行する。
Linux用のinstallerは現在未実装のため、両ツールは別途導入する。

```sh
zsh install.zsh gitleaks
zsh install.zsh pre-commit

# このリポジトリ内で、cloneした各端末ごとに必ず実行
pre-commit install

# 初回は既存のGit履歴も確認
gitleaks git . --redact --log-opts="--all"
```

APIキーなど、zshで使う秘密の環境変数はリポジトリに書かず、
`~/.config/secrets/zsh.env` に保存する。このファイルは `.zshrc` から自動で読み込まれる。
権限は `chmod 600 ~/.config/secrets/zsh.env` にする。

## 構成を変えたいとき

- 設定を変える：`files/` の対象ファイルを編集する。
- まとめて導入するツールを変える：`layers/` の対象ファイルを編集する。1行に1つ、installer名を記載する。
- 端末ごとの組み合わせを変える：`profiles/` の `PROFILE_LAYERS` を編集する。

その後、必要な個別導入コマンド、または一括セットアップを再実行する。
レイヤーから名前を削除しても、インストール済みのツールは削除されない。
