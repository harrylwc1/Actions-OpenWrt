#!/bin/bash

# 1. 建立一個陣列來安全地存放多檔案的 -F 參數
curl_args=()
for var in "$@"
do
    curl_args+=("-F" "files=@$var")
done

# 2. 設定共用的安全與速度（5M）優化參數
common_opts=(
  --limit-rate 5M
  --no-buffer
  --connect-timeout 10
  --max-time 600
  --progress-bar
  -u "$PASS"
  -w "\n\n======== 傳輸完成統計 ========\n目標伺服器: %{url_effective}\n總共花費時間: %{time_total} 秒\n平均上傳速度: %{speed_upload} 字節/秒\nHTTP 狀態碼: %{http_code}\n"
)

# 3. 組合伺服器網址（自動加上 :8080/upload）
# 如果環境變數中已經含有 http://，就直接用；如果沒有，會自動幫你補上 http://
URL1="${SERVER1}"
[[ $URL1 != http* ]] && URL1="http://${SERVER1}"
URL1="${URL1%:8080*}:8080/upload" # 確保連接埠一定是 8080

URL2="${SERVER2}"
[[ $URL2 != http* ]] && URL2="http://${SERVER2}"
URL2="${URL2%:8080*}:8080/upload"

# 4. 執行上傳（伺服器 1 失敗則自動嘗試伺服器 2）
echo "正在嘗試上傳至主要伺服器..."
curl "${common_opts[@]}" "${curl_args[@]}" "$URL1" || \
(echo "主要伺服器失敗，正在嘗試備用伺服器..." && curl "${common_opts[@]}" "${curl_args[@]}" "$URL2") || \
true

