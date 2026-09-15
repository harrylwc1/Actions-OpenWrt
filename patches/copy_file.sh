#!/bin/bash

# 1. 判斷第一個參數是否為網址（以 .com 或 .org 結尾）
if [[ "$1" == *.com || "$1" == *.org ]]; then
    SERVER1="$1"
    PASS="$2"          # 格式：id:password
    shift 2            # $@ 只剩檔案
fi

# 2. 建立 -F 參數（使用絕對路徑，避免 cwd 問題）
curl_args=()
for var in "$@"; do
    if [[ ! -f "$var" ]]; then
        echo "ERROR: file not found: [$var]" >&2
        exit 1
    fi
    curl_args+=("-F" "files=@$(realpath -- "$var")")
done

# 3. 組合 URL（強制 :8088/upload）
URL1="${SERVER1}"
[[ $URL1 != http* ]] && URL1="http://${URL1}"
URL1="${URL1%:8088*}:8088/upload"

URL2="${SERVER2:-$SERVER1}"
[[ $URL2 != http* ]] && URL2="http://${URL2}"
URL2="${URL2%:8088*}:8088/upload"

# 4. 上傳函式
#    回傳值：
#      0 = 成功 (204)
#      1 = 可重試的失敗（連線錯誤、5xx、非預期 2xx/3xx...）
#      2 = 憑證錯誤 (401/403) → 不應重試備用伺服器
do_upload() {
    local url="$1"
    local http_code

    http_code=$(curl \
        --limit-rate 5M \
        --no-buffer \
        --connect-timeout 10 \
        --max-time 600 \
        --progress-bar \
        -u "$PASS" \
        -o /dev/null \
        -w "%{http_code}" \
        "${curl_args[@]}" \
        "$url")

    echo "" >&2
    echo "======== 傳輸完成統計 ========" >&2
    echo "目標伺服器: $url" >&2
    echo "HTTP 狀態碼: $http_code" >&2

    case "$http_code" in
        204)
            echo "結果: 成功 (204)" >&2
            return 0
            ;;
        401|403)
            echo "結果: 認證失敗 ($http_code)，密碼或權限錯誤，停止重試。" >&2
            return 2
            ;;
        *)
            echo "結果: 失敗 (預期 204，實際 $http_code)" >&2
            return 1
            ;;
    esac
}

# 5. 執行上傳
echo "正在嘗試上傳至主要伺服器: $URL1" >&2
do_upload "$URL1"
rc=$?

if [[ $rc -eq 0 ]]; then
    exit 0
elif [[ $rc -eq 2 ]]; then
    # 401/403：憑證問題，重試也一樣，直接結束
    exit 1
else
    echo "主要伺服器失敗，正在嘗試備用伺服器: $URL2" >&2
    do_upload "$URL2"
    exit $?
fi
