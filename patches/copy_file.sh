#!/bin/bash

# 1. 判斷第一個參數是否為網址（以 .com 或 .org 結尾）
if [[ "$1" == *.com* || "$1" == *.org* ]]; then
    # 狀況 A：第一個參數是網址
    SERVER1="$1"
    PASS="$2"
    
    # 移除前面兩個參數，讓 $@ 只剩下 $3, $4, $5 ... 之後的檔案
    shift 2
else
    # 狀況 B：第一個參數不是網址
    # 保持原樣：不變更環境變數中的 SERVER1 與 PASS，全部參數 $@ 都是檔案
    :
fi

# 2. 建立一個陣列來安全地存放多檔案的 -F 參數
curl_args=()
for var in "$@"
do
    curl_args+=("-F" "files=@$var")
done

# 3. 設定共用的安全與速度（5M）優化參數
common_opts=(
  --limit-rate 5M
  --no-buffer
  --connect-timeout 10
  --max-time 600
  --progress-bar
  -u "$PASS"
  -w "\n\n======== 傳輸完成統計 ========\n目標伺服器: %{url_effective}\n總共花費時間: %{time_total} 秒\n平均上傳速度: %{speed_upload} 字節/秒\nHTTP 狀態碼: %{http_code}\n"
)

# 4. 組合伺服器網址（自動加上 :8088/upload）
URL1="${SERVER1}"
[[ $URL1 != http* ]] && URL1="http://${SERVER1}"
URL1="${URL1%:8088*}:8088/upload" # 確保連接埠一定是 8088

URL2="${SERVER2}"
[[ $URL2 != http* ]] && URL2="http://${SERVER2}"
URL2="${URL2%:8088*}:8088/upload"

# 5. 執行上傳（伺服器 1 失敗則自動嘗試伺服器 2）
echo "正在嘗試上傳至主要伺服器..."
curl "${common_opts[@]}" "${curl_args[@]}" "$URL1" || \
(echo "主要伺服器失敗，正在嘗試備用伺服器..." && curl "${common_opts[@]}" "${curl_args[@]}" "$URL2") || \
true

