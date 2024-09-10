#!/bin/bash

# 檢查是否提供 alias 參數
if [ -z "$1" ]; then
  echo "請提供 alias 名稱作為參數。"
  echo "使用方法: $0 <alias>"
  exit 1
fi

# 設定變數
ALIAS_NAME="$1"
KEYSTORE_PATH="/usr/share/logstash/jdk/lib/security/cacerts"
STOREPASS="changeit"
OUTPUT_DIR="$HOME/ca"
CERT_FILE="$OUTPUT_DIR/$ALIAS_NAME.crt"

# 確保目錄存在
mkdir -p "$OUTPUT_DIR"

# 匯出指定的 alias 憑證
keytool -exportcert -alias "$ALIAS_NAME" -keystore "$KEYSTORE_PATH" -storepass "$STOREPASS" -file "$CERT_FILE"

# 檢查匯出是否成功
if [ $? -eq 0 ]; then
  echo "憑證已成功匯出到: $CERT_FILE"
else
  echo "匯出失敗。請檢查 alias 是否正確。"
  exit 1
fi

# 驗證憑證是否可以被正確識別
echo "驗證匯出的憑證..."
keytool -printcert -file "$CERT_FILE"

# 檢查驗證是否成功
if [ $? -eq 0 ]; then
  echo "憑證驗證成功。"
else
  echo "憑證驗證失敗。"
fi
