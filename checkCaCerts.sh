#!/bin/bash

#尋找可用keytool
latest_keytool=$(find / -type f -name keytool 2>/dev/null | xargs ls -lt 2>/dev/null | head -n 1 | awk '{print $NF}')

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
  echo "未找到 cacerts 檔案"
  exit 1
fi

# 檢查每個找到的 cacerts 檔案
for cacerts_path in $cacerts_paths; do
  echo "找到 cacerts 檔案: $cacerts_path"

  # 獲取證書資訊
  cert_info=$($keytool_path -list -v -storepass 'changeit' -keystore "$cacerts_path" 2>/dev/null | grep -iE 'O=Google Trust Services LLC|O=Amazon|O=Sectigo Limited')

  # 檢查是否包含三個指定的證書資訊
  if [[ "$cert_info" == *"O=Google Trust Services LLC"* ]] && \
     [[ "$cert_info" == *"O=Amazon"* ]] && \
     [[ "$cert_info" == *"O=Sectigo Limited"* ]]; then
    echo "在檔案 $cacerts_path 中找到所有指定的證書資訊"
    exit 0
  fi
done

# 如果沒有找到所有指定的證書資訊
echo false
exit 1
