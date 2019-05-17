# stats_rds_slowquery

RDS for MySQLのスロークエリログを取得し、mysqldumpslowでサマリーにした上でSlackに投げるスクリプトです。

## 使い方

cronに以下の様にセットしてください

```
# RDS(MySQL) slow_query log report
m h * * * cd /path/to && ./stats.sh INSTANCE_IDENTIFIER
```

INSTANCE_IDENTIFIER にはRDS(MySQL)のインスタンス識別子を指定します。Aurora MySQLにも対応しています。

### 設定

環境変数に下記を設定しておいてください。direnvを利用する場合は.direnv.sampleを参照してください。

|SLACK_TOKEN|Slack Appの `OAuth & Permissions` から取得して設定してください|
|SLACK_CHANNEL|SlackのチャンネルID (チャンネル名ではないので注意)|

また、以下のコマンドが動作する必要があります

* curl
* AWS CLI (RDSのRead権限を持つIAMユーザーが必要)
* mysqldumpslow (mysqlまたはmariadbに付属)

## その他

* スロークエリに含まれるTimeの行を意図的に捨てています。これはMySQL5.6と5.7で互換性を維持するためです（RDSはMySQL5.7互換だけどクライアントはMySQL5.6互換(mariadb)のようなケースに対応するため）。集計に影響があるかもしれません。
