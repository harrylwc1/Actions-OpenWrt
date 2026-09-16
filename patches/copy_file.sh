#!/bin/bash

# 1. 判斷第一個參數是否為網址（允許 :port 或 /path 結尾）
if [[ "${1:-}" =~ \.(com|org)([:/].*)?$ ]]; then
    SERVER1="$1"
    PASS="$2"
    shift 2
fi

# 2. 必填檢查
if [[ -z "${SERVER1:-}" ]]; then
    echo "ERROR: SERVER1 is empty." >&2
    exit 1
fi

if [[ -z "${PASS:-}" ]]; then
    echo "ERROR: PASS is empty." >&2
    exit 1
fi

# SERVER2 optional -> default to SERVER1
SERVER2="${SERVER2:-$SERVER1}"

# 3. 建立 -F 參數
curl_args=()
for var in "$@"; do
    if [[ ! -f "$var" ]]; then
        echo "ERROR: file not found: [$var]" >&2
        exit 1
    fi
    curl_args+=("-F" "files=@$(realpath -- "$var")")
done

if [[ ${#curl_args[@]} -eq 0 ]]; then
    echo "ERROR: no files to upload." >&2
    exit 1
fi

# 4. 組合 URL（強制 :8088/upload）
URL1="${SERVER1}"
[[ $URL1 != http* ]] && URL1="http://${URL1}"
URL1="${URL1%:8088*}:8088/upload"

URL2="${SERVER2}"
[[ $URL2 != http* ]] && URL2="http://${URL2}"
URL2="${URL2%:8088*}:8088/upload"

# 5. 上傳函式
#    return 0 = 成功 (204)
#    return 1 = 可重試失敗
#    return 2 = 認證失敗 (401/403)
do_upload() {
    local url="$1"
    local http_code

    http_code=$(curl \
        --limit-rate 2M \
        --no-buffer \
        --connect-timeout 10 \
        --max-time 600 \
        --progress-bar \
        -u "$PASS" \
        -o /dev/null \
        -w "%{http_code}" \
        "${curl_args[@]}" \
        "$url")

    echo ""
    echo "======== 傳輸完成統計 ========"
    echo "目標伺服器: $url"
    echo "HTTP 狀態碼: $http_code"

    case "$http_code" in
        204)     echo "結果: 成功 (204)"; return 0 ;;
        401|403) echo "結果: 認證失敗 ($http_code)"; return 2 ;;
        *)       echo "結果: 失敗 (預期 204，實際 $http_code)"; return 1 ;;
    esac
}

# 6. 執行上傳
echo "正在嘗試上傳至主要伺服器: $URL1"
do_upload "$URL1"
rc=$?

if [[ $rc -eq 0 ]]; then
    exit 0
elif [[ $rc -eq 2 ]]; then
    exit 1
else
    echo "主要伺服器失敗，正在嘗試備用伺服器: $URL2"
    do_upload "$URL2"
    exit $?
fi
