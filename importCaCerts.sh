#!/bin/bash

# 檢查是否提供 cacerts 路徑參數
if [ -z "$1" ]; then
  echo "請提供 cacerts 路徑作為參數。"
  echo "使用方法: $0 <cacerts_path>"
  exit 1
fi

# 設定變數
CACERTS_PATH="$1"
STOREPASS="changeit"
CA_DIR="$HOME/ca"

# 檢查 cacerts 路徑是否存在
if [ ! -f "$CACERTS_PATH" ]; then
  echo "cacerts 路徑不存在或無效: $CACERTS_PATH"
  exit 1
fi

# 匯入目錄中的所有 .crt 檔案
for CERT_FILE in "$CA_DIR"/*.crt; do
  if [ -f "$CERT_FILE" ]; then
    # 取得檔案名稱（不含副檔名）
    ALIAS_NAME=$(basename "$CERT_FILE" .crt)

    echo "匯入憑證: $CERT_FILE"

    # 匯入憑證到 cacerts
    sudo keytool -importcert -alias "$ALIAS_NAME" -file "$CERT_FILE" -keystore "$CACERTS_PATH" -storepass "$STOREPASS" -noprompt

    # 檢查匯入是否成功
    if [ $? -eq 0 ]; then
      echo "憑證已成功匯入: $ALIAS_NAME"
    else
      echo "憑證匯入失敗: $ALIAS_NAME"
    fi
  else
    echo "未找到 .crt 檔案於 $CA_DIR"
  fi
done
