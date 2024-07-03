# deploybot

岡大電算研の ogenki サーバーから定期的にデプロイを行うシステムです。

# Installation

1. このリポジトリをクローン後、以下のコマンドでセットアップを行います。

```
$ cd deploybot
$ ./setup
```

2. `~/.bashrc`に以下を記述して、dpbコマンドを登録します。

```
dpb() {
    args=()
    for arg in "$@"; do
        if [ -e "$arg" ]; then
            args+=("$(realpath "$arg")")
        else
            args+=("$arg")
        fi
    done
    (cd ~/deploybot && carton exec -- ./dpb ${args[@]})
}
```
※最後から2行目の`~/deploybot`は、自身がクローンしたdeploybotのバスに置き換えてください。

3. 以下のコマンドでdpbコマンドのバージョンが表示されれば成功です。

```
$ dpb -v
```

# Tutorial

デプロイを行うターゲットは Git リポジトリで管理されている必要があります。

1. ターゲットのディレクトリ直下に `run.sh` を作成し、起動方法を記述します。

2. サーバーにターゲットのリポジトリをクローンし、稼働させるブランチにチェックアウトします。

3. `set-log` コマンドで Discord の Webhook URL を設定します。
```
# deploybot の INFOログ の送信先
dpb set-log https://discord.com/api/webhooks/00000/xxxxx 1

# deploybot の ERRORログ の送信先
dpb set-log https://discord.com/api/webhooks/00000/xxxxx 2

# ターゲット の INFOログ の送信先 (run.shの第1引数で渡される)
dpb set-log https://discord.com/api/webhooks/00000/xxxxx 3

# ターゲット の ERRORログ の送信先 (run.shの第2引数で渡される)
dpb set-log https://discord.com/api/webhooks/00000/xxxxx 4

# default は 標準(エラー)出力 を表します
dpb set-log default 4

# 設定した内容を確認します
dpb log
```

4. 以下のコマンドで稼働を開始します。
```
dpb run ターゲットのディレクトリパス
```

- 10分ごとにチェエクアウトしているブランチのリモートリポジトリの更新を確認し、更新があればプルとターゲットの再起動を行います。
- 確認を行う間隔は `-i` オプションで変更も可能です。(以下は30分にした例)
```
dpb run ターゲットのディレクトリパス -i 30
```
