#!/bin/bash

# 優先從 PATH 中尋找 keytool
if command -v keytool &>/dev/null; then
    # 如果在 PATH 中找到 keytool，使用它
    keytool_path=$(command -v keytool)
else
    # 如果未在 PATH 中找到，從系統中尋找最新的 keytool
    keytool_path=$(find / -type f -name keytool 2>/dev/null | xargs ls -lt 2>/dev/null | head -n 1 | awk '{print $NF}')
fi

# 尋找 cacerts 檔案
cacerts_paths=$(find / -type f -name cacerts 2>/dev/null)

# 檢查是否找到 cacerts 檔案
if [ -z "$cacerts_paths" ]; then
  echo -e "\033[1;31m未找到 cacerts 檔案\033[0m"
  exit 1
fi

# 初始化變數，用來追蹤是否所有檔案都包含指定的證書資訊
all_certs_found=true

# 檢查每個找到的 cacerts 檔案
for cacerts_path in $cacerts_paths; do
  echo "正在檢查 cacerts 檔案: $cacerts_path"

  # 獲取證書資訊
  cert_info=$($keytool_path -list -v -storepass 'changeit' -keystore "$cacerts_path" 2>/dev/null | grep -iE 'O=Google Trust Services LLC|O=Amazon|O=Sectigo Limited')

  # 檢查是否包含三個指定的證書資訊
  if [[ "$cert_info" == *"O=Google Trust Services LLC"* ]] && \
     [[ "$cert_info" == *"O=Amazon"* ]] && \
     [[ "$cert_info" == *"O=Sectigo Limited"* ]]; then
    echo -e "\033[1;32m在檔案 $cacerts_path 中找到所有指定的證書資訊\033[0m"
  else
    echo -e "\033[1;31m檔案 $cacerts_path 中未找到所有指定的證書資訊\033[0m"
    all_certs_found=false
  fi
done

# 根據所有檔案的結果來決定是否成功
if [ "$all_certs_found" = true ]; then
  echo -e "\033[1;32m所有 cacerts 檔案中都包含指定的證書資訊\033[0m"
  exit 0
else
  echo -e "\033[1;31m並非所有 cacerts 檔案都包含指定的證書資訊\033[0m"
  exit 1
fi
