# Dotfiles 自作管理ツール（薄い chezmoi 風）仕様書（AI Coding Agent 向け）

## 目的
- `zsh setup.zsh -P <profile>` で **環境一式のセットアップ**ができる
- `zsh install.zsh <installer>` で **任意の installer を単体実行**できる
- **MacOS / Linux 両対応**
- **会社PC(work) / 個人PC(private)** のプロファイル分岐に対応
- `run_once` の記録やファイル差分検知は **実装しない**
- OS分岐が散らばらないように、OS差は **installers に閉じ込める**

---

## 使い方（CLI）

### 1) セットアップ（プロファイル指定）
```sh
zsh setup.zsh -P work
zsh setup.zsh -P private-dev-mac
```

### 2) installer 単体実行
```sh
zsh install.zsh uv
zsh install.zsh go
```

---

## 全体設計

### 設計方針
- `setup.zsh` は **layer リストを回して installers を直接呼ぶ**ドライバ
- `install.zsh` は `installers/<installer>.zsh` をロードして `_install()` を実行するだけ
- OS判定・共通関数は `lib/env.zsh` に集約
- layer（installer の集合）定義は `layers/*` に置く
- 会社/個人の差分は `layers/work, private` で表現する

---

## ディレクトリ構成

```txt
dotfiles/
  setup.zsh
  install.zsh

  lib/
    env.zsh            # OS判定 / profile読込 / 共通関数
    log.zsh            # Log出力

  layers/
    core               # どの環境でも入れる
    work               # 会社PC用追加
    private            # 個人PC用追加

  profiles/
    work               # 会社PC用の変数定義（任意）
    private            # 個人PC用の変数定義（任意）

  installers/
    uv.zsh
    go.zsh
    git.zsh
    # 必要に応じて追加
```

---

## 仕様詳細

### 1) `lib/env.zsh`（共通関数）
要件:
- `uname -s` はここで **1回だけ**呼び、結果をキャッシュ
- OS判定関数 `is_macos`, `is_linux` を提供

実装:
```zsh
# lib/env.zsh
set -euo pipefail

OS_NAME="$(uname -s)"

is_macos() { [[ "$OS_NAME" == "Darwin" ]]; }
is_linux() { [[ "$OS_NAME" == "Linux"  ]]; }
```

---

### 2) `lib/log.zsh`（共通関数）

ユーザーとのやり取りにlog.zshを使用する

info(), user(), success(), warn(), fail()を使用する

- `fail()` は **ログ出力のみ**（exitしない）
- 終了するかどうかは **呼び出し側で判断**する


---

### 3) `install.zsh`（単体インストールの入口）
要件:
- `install.zsh <installer>` を受け取る
- `installers/<installer>.zsh` を `source`
- `_install()` 関数を呼ぶ
- `installers/<installer>.zsh` が無ければエラー
- `-P <profile>` が渡された場合は `load_profile` を実行する（失敗なら終了）

実装:
```zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
source "$ROOT/lib/env.zsh"

profile=""

while getopts "P:" opt; do
  case "$opt" in
    P) profile="$OPTARG" ;;
    *) fail "usage: install.zsh [-P <profile>] <installer>"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

installer_name="${1:-}"
if [[ -z "$installer_name" ]]; then
  fail "usage: install.zsh [-P <profile>] <installer>"
  exit 1
fi

if [[ -n "$profile" ]]; then
  if ! load_profile "$profile"; then
    fail "profile load failed: $profile"
    exit 1
  fi
fi

installer_path="$ROOT/installers/${installer_name}.zsh"
if [[ ! -f "$installer_path" ]]; then
  fail "installer not found: $installer_name"
  exit 1
fi

# installers の中で _install() を定義する
source "$installer_path"
if ! _install; then
  fail "install failed: $installer_name"
  exit 1
fi
```

---

### 4) `setup.zsh`（セットアップ入口）
要件:
- `setup.zsh -P <profile>` を受け取る
- `PROFILE_LAYERS` を **その順序で layer を読み込む**
- コメント行 (`#`) と空行を除外して、1行ずつ `installer` として読み込む
- `installers/<installer>.zsh` を **直接 source して _install() を呼ぶ**
- `_install()` が失敗した場合は **fail を出して継続**する
- 読み込み順序は `PROFILE_LAYERS` に記述した順（各ファイル内は上から）

実装:
```zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
source "$ROOT/lib/env.zsh"

profile=""

while getopts "P:" opt; do
  case "$opt" in
    P) profile="$OPTARG" ;;
    *) fail "usage: setup.zsh -P <profile>"; exit 1 ;;
  esac
done

if [[ -z "$profile" ]]; then
  fail "usage: setup.zsh -P <profile>"
  exit 1
fi

if ! load_profile "$profile"; then
  fail "profile load failed: $profile"
  exit 1
fi

layers=()
if ! (( ${+PROFILE_LAYERS} )); then
  fail "PROFILE_LAYERS is not defined."
  exit 1
fi
if (( ${#PROFILE_LAYERS[@]} == 0 )); then
  fail "PROFILE_LAYERS is empty."
  exit 1
fi
layers=("${PROFILE_LAYERS[@]}")

for layer in "${layers[@]}"; do
  layer_file="$ROOT/layers/${layer}"
  if [[ ! -f "$layer_file" ]]; then
    fail "layer file not found: $layer"
    exit 1
  fi

  while IFS= read -r installer_name; do
    [[ -z "$installer_name" ]] && continue
    info "install: $installer_name"
    installer_path="$ROOT/installers/${installer_name}.zsh"
    if [[ ! -f "$installer_path" ]]; then
      fail "installer not found: $installer_name"
      continue
    fi
    source "$installer_path"
    if ! _install; then
      fail "install failed: $installer_name"
      continue
    fi
    success "install: $installer_name"
  done < <(sed '/^\s*#/d;/^\s*$/d' "$layer_file")
done
```

---

## installers 仕様（installer 個別インストーラ）

### ルール
- `installers/<name>.zsh` は `_install()` 関数を必ず定義する
- OS分岐は installers 内で行う（`is_macos`, `is_linux` を利用）
- installer 内で `ROOT` を参照するために `source "$ROOT/lib/env.zsh"` を推奨
- installer から `load_profile` は **呼ばない**（profile は `setup.zsh` / `install.zsh` で読む）
- 再実行しても壊れない（可能なら idempotent を意識）
- `lib/` と `installers/` は **source で読み込む前提**（直接実行しない）

### 例：`installers/uv.zsh`
```zsh
# installers/uv.zsh
source "$ROOT/lib/env.zsh"

_install() {
  if is_macos; then
    command -v brew >/dev/null || fail "brew not found"
    brew install uv
  elif is_linux; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
  else
    fail "unsupported OS: $OS_NAME"
  fi
}
```

### 例：`installers/go.zsh`
```zsh
# installers/go.zsh
source "$ROOT/lib/env.zsh"

_install() {
  if is_macos; then
    command -v brew >/dev/null || fail "brew not found"
    brew install go
  elif is_linux; then
    sudo apt-get update
    sudo apt-get install -y golang
  else
    fail "unsupported OS: $OS_NAME"
  fi
}
```

---

## layers 仕様（インストール対象リスト）

### ルール
- layer は installer の集合
- ファイル名は拡張子なし（例: `layers/core`）
- 1行に1 installer 名
- 空行と `#` コメント行は無視される
- 行の値は `installers/<installer>.zsh` に対応する必要がある
- 読み込み順序は上から（複数 layer は先に指定したものから）

### 例：`layers/core`
```txt
# core layer
git
uv
go
```

### 例：`layers/work`
```txt
# work only layer
# kubectl
# k9s
```

### 例：`layers/private`
```txt
# private only layer
# yt-dlp
# ffmpeg
```

---

## profiles 仕様（work/private の変数定義）

### ルール
- `profiles/<profile>` を `source` する（zsh で読み込み可能な記述）
- 変数の代入のみ（基本的に if 文などは書かない）
- 変数名は `PROFILE_` で始める
- これらの変数は、主に各種 installer が使用する
- `PROFILE_LAYERS` には layer の配列を記述する（記述した順に読み込む）
- `PROFILE_LAYERS` の要素数は多くとも 4, 5 程度を想定
- プロファイルファイルが存在しない場合は **fail して終了**
- profile file に拡張子はない

### 例：`profiles/work`
```zsh
PROFILE_LAYERS=(core dev dev-work macos)
PROFILE_GIT_UNAME="Your Name"
PROFILE_GIT_UEMAIL="work@example.com"
```

### 例：`profiles/private`
```zsh
PROFILE_LAYERS=(core dev macos)
PROFILE_GIT_UNAME="Your Name"
PROFILE_GIT_UEMAIL="private@example.com"
```

### 読み取りAPI（`lib/env.zsh` に実装）
- `load_profile <profile>`: `profiles/<profile>` を `source` する
  - **同一プロファイルが既に読み込まれている場合は即 return（再読み込みしない）**
  - **別プロファイルが既に読み込まれている場合は fail を出して return 1**
- `profile_get <KEY> [default]`: 値が無ければ default（省略時は空文字）を返す
- `profile_require <KEY>`: 値が無ければ **lib/log の fail() を使ってログ出力して return 1**、値があれば **それを返す**

実装イメージ:
```zsh
PROFILE_NAME=""

load_profile() {
  local profile="$1"
  local file="$ROOT/profiles/${profile}"

  if [[ -n "$PROFILE_NAME" ]]; then
    if [[ "$PROFILE_NAME" == "$profile" ]]; then
      return 0
    fi
    fail "profile already loaded: $PROFILE_NAME (cannot load: $profile)"
    return 1
  fi

  PROFILE_NAME="$profile"

  if [[ ! -f "$file" ]]; then
    fail "profile not found: $file"
    return 1
  fi

  source "$file"
}

profile_get() {
  local key="$1"
  local def="${2-}"
  local var="PROFILE_${key}"
  if typeset -p "$var" >/dev/null 2>&1; then
    print -r -- "${(P)var}"
    return 0
  fi
  print -r -- "$def"
}

profile_require() {
  local key="$1"
  local var="PROFILE_${key}"
  if ! typeset -p "$var" >/dev/null 2>&1; then
    fail "profile key missing: $key"
    return 1
  fi
  print -r -- "${(P)var}"
}
```

---

## config テンプレ仕様（削除予定）

- `config/*.tmpl` と `bin/apply-config.sh` は撤廃予定とする

---

## 実装上の注意点（最小で壊れないために）
- `ROOT` は `setup.zsh` と `install.zsh` の先頭で `pwd` 解決して設定する
- `installers` 内では `brew` / `apt` が無い場合にわかりやすく `fail` する
- 会社PCで不要なもの（例: yt-dlp, ffmpeg）は `layers/private` にのみ書く
- `envsubst` 方式は `${VAR}` の置換だけ対応（高度な if/loop はやらない）
- `curl` や `brew` など外部コマンドの失敗は、`_install()` の戻り値で判断して呼び出し側で扱う
  - 例: `curl -fsSL ...` のように失敗時に非0で返るオプションを使う

---

## 将来的な拡張（非必須）
- `layers/` を `core/dev/entertain` に分割
- `installers` の中で `command -v` を使って “すでにインストール済みならスキップ” する
