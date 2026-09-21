#!/bin/sh

# 1. 判斷第一個參數是否為網址（POSIX 寫法，不用 =~）
case "${1:-}" in
    *.com|*.com:*|*.com/*|*.org|*.org:*|*.org/*)
        SERVER1="$1"
        PASS="$2"
        shift 2
        ;;
esac

# 2. 必填檢查
if [ -z "${SERVER1:-}" ]; then
    echo "ERROR: SERVER1 is empty." >&2
    exit 1
fi

if [ -z "${PASS:-}" ]; then
    echo "ERROR: PASS is empty." >&2
    exit 1
fi

# SERVER2 optional -> default to SERVER1
SERVER2="${SERVER2:-$SERVER1}"

# 3. 建立 -F 參數
CURL_ARGS=""
for var in "$@"; do
    if [ ! -f "$var" ]; then
        echo "ERROR: file not found: [$var]" >&2
        exit 1
    fi
    abs=$(realpath -- "$var" 2>/dev/null || readlink -f "$var")
    CURL_ARGS="$CURL_ARGS -F files=@$abs"
done

if [ -z "$CURL_ARGS" ]; then
    echo "ERROR: no files to upload." >&2
    exit 1
fi

# 4. 組合上傳 URL（強制 :8088/upload）
URL1="${SERVER1}"
case "$URL1" in
    http*) ;;
    *) URL1="http://${URL1}" ;;
esac
URL1="${URL1%:8088*}:8088/upload"

URL2="${SERVER2}"
case "$URL2" in
    http*) ;;
    *) URL2="http://${URL2}" ;;
esac
URL2="${URL2%:8088*}:8088/upload"

# 4b. 取出 host 組 fallback URL 與健康檢查 URL
HOST1="${SERVER1#http://}"
HOST1="${HOST1#https://}"
HOST1="${HOST1%%/*}"
HOST1="${HOST1%%:*}"
URL1_FALLBACK="http://${HOST1}:2799/stup.py"
URL1_HEALTH="http://${HOST1}:8088/"

# 4c. 預算 Basic Auth header
AUTH_B64=$(printf '%s' "$PASS" | base64 | tr -d '\n')
AUTH_HEADER="Authorization: Basic ${AUTH_B64}"

# 4d. 健康檢查參數（可透過環境變數覆寫）
HEALTH_TIMEOUT="${HEALTH_TIMEOUT:-120}"    # 最多等幾秒
HEALTH_INTERVAL="${HEALTH_INTERVAL:-2}"    # 每次間隔幾秒
MARKER_FILE="${MARKER_FILE:-/tmp/uploadserver_ready.$$}"

# 5. 上傳函式
#    return 0 = 成功 (204)
#    return 1 = 可重試失敗
#    return 2 = 認證失敗 (401/403)
do_upload() {
    url="$1"
    http_code=$(curl \
        --limit-rate 3M \
        --no-buffer \
        --connect-timeout 10 \
        --max-time 6000 \
        --progress-bar \
        -H "$AUTH_HEADER" \
        -o /dev/null \
        -w "%{stderr}\n\n======== 傳輸完成統計 ========\n目標伺服器: %{url_effective}\n總共花費時間: %{time_total} 秒\n平均上傳速度: %{speed_upload} 字節/秒\nHTTP 狀態碼: %{http_code}\n%{stdout}%{http_code}" \
        $CURL_ARGS \
        "$url")
    curl_rc=$?

    if [ $curl_rc -ne 0 ]; then
        echo "結果: curl 傳輸失敗 (exit=$curl_rc, HTTP=$http_code)"
        return 1
    fi

    case "$http_code" in
        204)     echo "結果: 成功 (204)"; return 0 ;;
        401|403) echo "結果: 認證失敗 ($http_code)"; return 2 ;;
        *)       echo "結果: 失敗 (預期 204，實際 $http_code)"; return 1 ;;
    esac
}

# 5b. 觸發備援
trigger_fallback() {
    fb_url="$1"
    echo "主要伺服器失敗，正在呼叫備援觸發器: $fb_url"
    code=$(curl --silent --show-error --connect-timeout 10 --max-time 60 \
        -o /dev/null -w "%{http_code}" "$fb_url" 2>/tmp/fallback_err)
    rc=$?
    if [ $rc -ne 0 ]; then
        echo "警告: 備援觸發器呼叫失敗 (curl exit=$rc)" >&2
        cat /tmp/fallback_err >&2 || true
    else
        echo "備援觸發器 HTTP 狀態碼: $code"
    fi
    return 0
}

# 5c. 建立空檔案（marker），象徵「等待就緒」
touch_marker() {
    : > "$MARKER_FILE" 2>/dev/null || true
    echo "已建立等待標記檔: $MARKER_FILE"
}

# 5d. 輪詢健康檢查，直到 8088 能連上或逾時
#     return 0 = 連上
#     return 1 = 逾時
wait_for_uploadserver() {
    health_url="$1"
    elapsed=0

    echo "等待 uploadserver 就緒 (最多 ${HEALTH_TIMEOUT} 秒，每 ${HEALTH_INTERVAL} 秒檢查一次)..."

    while [ "$elapsed" -lt "$HEALTH_TIMEOUT" ]; do
        # 只檢查 TCP + HTTP 是否回應；用 HEAD 或 GET 皆可，這裡用 GET，短 timeout
        code=$(curl --silent --show-error \
            --connect-timeout 3 \
            --max-time 5 \
            -o /dev/null \
            -w "%{http_code}" \
            "$health_url" 2>/dev/null)

        case "$code" in
            000|"")
                # 連不上，繼續等
                ;;
            *)
                # 收到任何 HTTP 狀態碼（200/401/…）代表 server 已上線
                echo "uploadserver 已就緒 (HTTP $code)，經過 ${elapsed} 秒。"
                return 0
                ;;
        esac

        sleep "$HEALTH_INTERVAL"
        elapsed=$((elapsed + HEALTH_INTERVAL))
        printf '.'
    done

    echo ""
    echo "等待逾時 (${HEALTH_TIMEOUT} 秒)，uploadserver 仍未就緒。"
    return 1
}

# 5e. 清理 marker
cleanup_marker() {
    rm -f "$MARKER_FILE" 2>/dev/null || true
}

# 6. 執行上傳
echo "正在嘗試上傳至主要伺服器: $URL1"
do_upload "$URL1"
rc=$?

if [ $rc -eq 0 ]; then
    exit 0
elif [ $rc -eq 2 ]; then
    exit 1
else
    # rc == 1 → 可重試失敗
    trigger_fallback "$URL1_FALLBACK"
    touch_marker

    if wait_for_uploadserver "$URL1_HEALTH"; then
        echo "正在重試主要伺服器: $URL1"
        do_upload "$URL1"
        rc=$?
        cleanup_marker

        if [ $rc -eq 0 ]; then
            exit 0
        elif [ $rc -eq 2 ]; then
            exit 1
        else
            echo "主要伺服器重試失敗，正在嘗試備用伺服器: $URL2"
            do_upload "$URL2"
            exit $?
        fi
    else
        cleanup_marker
        echo "主要伺服器未恢復，直接嘗試備用伺服器: $URL2"
        do_upload "$URL2"
        exit $?
    fi
fi
