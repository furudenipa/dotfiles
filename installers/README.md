# installers ガイド

`installers/` 配下のファイルは `setup.zsh` / `install.zsh` から `source` され、
`_install()` を呼ばれることを前提にします（直接実行しない）。

## 設計意図（なぜ `source` + `_install()` なのか）

- **同一シェルの文脈を共有したい**ため  
  `install.zsh` / `setup.zsh` で用意した `ROOT`、`info` / `fail`、`is_macos`、`set -e` などを
  installer 側でそのまま使えるようにする（`zsh installers/foo.zsh` だと別プロセスなので引き継がれない）。
- **読み込みと実行を分離したい**ため  
  `source` した瞬間に実行されるのを避け、`_install()` を呼ぶまで副作用を起こさない。
- **失敗ハンドリングを統一したい**ため  
  `_install()` の戻り値を `if ! _install; then ...` で一貫して扱える。  
  トップレベルで `return`/`exit` すると、`source` 自体がその時点で終了し、
  `return 1` は `source` の終了コードになり、`set -e` のもとでは
  **条件文に包まれていない `source` が非ゼロで終わると、その場でスクリプト全体が終了する**。  
  `exit` は `install.zsh` / `setup.zsh` 全体を終了させてしまうため、
  「失敗は拾って継続する／統一的に扱う」という制御が難しくなる。

## 必須ルール（既存実装準拠）

- 各 installer は必ず `_install()` を定義する
- `curl` / `brew` などは **存在する前提** で記述する（存在チェックは書かない）
- OS 分岐は `_install()` の **一番浅い場所** に `if` で書く
  - `is_macos` / `is_linux` を使う（`lib/env.zsh` 由来）
  - 分岐は `if ...; return; fi` の形で早期 return する

## 基本構成

- 先頭で `source "$ROOT/lib/log.zsh"` と `source "$ROOT/lib/env.zsh"` を読む
  - `lib/env.zsh` 内でも `lib/log.zsh` を読んでいるが、可読性のため明示しておく
  - `ROOT` は呼び出し元がセット済み
  - `set -euo pipefail` / `info` / `warn` / `fail` / OS 判定が有効になる
- 必要なら `source "$ROOT/lib/link.zsh"` を読み、`link_files` を使う
- 可能なら冪等（再実行で壊れない）にする

## 例（一般的な OS 分岐）

```zsh
source "$ROOT/lib/log.zsh"
source "$ROOT/lib/env.zsh"

_install() {
  if is_macos; then
    # macOS 向けの処理
    return 0
  fi

  if is_linux; then
    # Linux 向けの処理
    return 0
  fi

  fail "unsupported OS: $OS_NAME"
  return 1
}
```

## 例（macOS のみ対応）

```zsh
source "$ROOT/lib/log.zsh"
source "$ROOT/lib/env.zsh"

_install() {
  if is_macos; then
    # macOS 向けの処理
    return 0
  fi

  fail "supported on macOS only."
  return 1
}
```
