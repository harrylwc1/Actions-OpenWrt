#!/bin/sh
# file upload using python uploadserver https://pypi.org/project/uploadserver/
# usage:
#   本機:      ./copy_file.sh file_name1 file_name2
#   GitHub:    ./copy_file.sh remote_server user:password file_name1 file_name2

# ===== 本機 hard-code（GitHub 使用時把這 2 行註解掉）=====

# ======================================================

# 1. 若第一個參數是網址，覆寫 SERVER1 / PASS，並 shift 2
#    本機用法：$1 是檔名，不會匹配，所以 shift 不執行
#    GitHub： $1 是網址，會匹配並覆寫
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

HOST2="${SERVER2#http://}"
HOST2="${HOST2#https://}"
HOST2="${HOST2%%/*}"
HOST2="${HOST2%%:*}"
URL2_FALLBACK="http://${HOST2}:2799/stup.py"
URL2_HEALTH="http://${HOST2}:8088/"

# 4c. 健康檢查參數
HEALTH_TIMEOUT="${HEALTH_TIMEOUT:-120}"
HEALTH_INTERVAL="${HEALTH_INTERVAL:-2}"
MARKER_FILE="${MARKER_FILE:-/tmp/uploadserver_ready.$$}"

# 成功紀錄
USED_SERVER=""
USED_STAGE=""
FALLBACK_LOG_1=""
FALLBACK_LOG_2=""

# 5. 時間戳函式
ts() {
    date '+%Y-%m-%d %H:%M:%S'
}

# 6. 上傳函式
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
        -u "$PASS" \
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

# 7. 觸發備援（帶時間戳）
trigger_fallback() {
    fb_url="$1"
    fb_slot="$2"

    t_start=$(ts)
    echo "[$t_start] 正在呼叫備援觸發器: $fb_url"

    code=$(curl --silent --show-error --connect-timeout 10 --max-time 60 \
        -o /dev/null -w "%{http_code}" "$fb_url" 2>/tmp/fallback_err)
    rc=$?
    t_end=$(ts)

    if [ $rc -ne 0 ]; then
        echo "[$t_end] 警告: 備援觸發器呼叫失敗 (curl exit=$rc)" >&2
        cat /tmp/fallback_err >&2 || true
        log_line="呼叫時間=$t_start, 回應時間=$t_end, curl_exit=$rc (失敗)"
    else
        echo "[$t_end] 備援觸發器 HTTP 狀態碼: $code"
        log_line="呼叫時間=$t_start, 回應時間=$t_end, HTTP=$code"
    fi

    if [ "$fb_slot" = "1" ]; then
        FALLBACK_LOG_1="$log_line"
    else
        FALLBACK_LOG_2="$log_line"
    fi
    return 0
}

# 8. 建立空檔案（marker）
touch_marker() {
    : > "$MARKER_FILE" 2>/dev/null || true
    echo "[$(ts)] 已建立等待標記檔: $MARKER_FILE"
}

# 9. 輪詢健康檢查
wait_for_uploadserver() {
    health_url="$1"
    elapsed=0

    echo "[$(ts)] 等待 uploadserver 就緒 (最多 ${HEALTH_TIMEOUT} 秒，每 ${HEALTH_INTERVAL} 秒檢查一次)..."

    while [ "$elapsed" -lt "$HEALTH_TIMEOUT" ]; do
        code=$(curl --silent --show-error \
            --connect-timeout 3 \
            --max-time 5 \
            -o /dev/null \
            -w "%{http_code}" \
            "$health_url" 2>/dev/null)

        case "$code" in
            000|"")
                ;;
            *)
                echo "[$(ts)] uploadserver 已就緒 (HTTP $code)，經過 ${elapsed} 秒。"
                return 0
                ;;
        esac

        sleep "$HEALTH_INTERVAL"
        elapsed=$((elapsed + HEALTH_INTERVAL))
        printf '.'
    done

    echo ""
    echo "[$(ts)] 等待逾時 (${HEALTH_TIMEOUT} 秒)，uploadserver 仍未就緒。"
    return 1
}

# 10. 清理 marker
cleanup_marker() {
    rm -f "$MARKER_FILE" 2>/dev/null || true
}

# 11. 完整嘗試流程
try_server() {
    label="$1"
    url="$2"
    fb_url="$3"
    health_url="$4"
    fb_slot="$5"

    echo "=========================================="
    echo "[$(ts)] 正在嘗試上傳至${label}伺服器: $url"
    echo "=========================================="
    do_upload "$url"
    rc=$?

    if [ $rc -eq 0 ]; then
        USED_SERVER="$url"
        USED_STAGE="${label}伺服器（首次嘗試）"
        return 0
    elif [ $rc -eq 2 ]; then
        echo "[$(ts)] ${label}伺服器認證失敗，不再重試。"
        return 1
    fi

    trigger_fallback "$fb_url" "$fb_slot"
    touch_marker

    if wait_for_uploadserver "$health_url"; then
        echo "[$(ts)] 正在重試${label}伺服器: $url"
        do_upload "$url"
        rc=$?
        cleanup_marker

        if [ $rc -eq 0 ]; then
            USED_SERVER="$url"
            USED_STAGE="${label}伺服器（觸發後重試成功）"
            return 0
        elif [ $rc -eq 2 ]; then
            echo "[$(ts)] ${label}伺服器重試認證失敗。"
            return 1
        fi

        echo "[$(ts)] ${label}伺服器重試仍失敗。"
        return 1
    else
        cleanup_marker
        echo "[$(ts)] ${label}伺服器未恢復。"
        return 1
    fi
}

# 12. 執行：先試 SERVER1，失敗再試 SERVER2
try_server "主要" "$URL1" "$URL1_FALLBACK" "$URL1_HEALTH" "1"
rc=$?

if [ $rc -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "[$(ts)] 總結: 上傳成功"
    echo "使用伺服器: $USED_SERVER"
    echo "成功階段  : $USED_STAGE"
    [ -n "$FALLBACK_LOG_1" ] && echo "觸發器紀錄: $FALLBACK_LOG_1"
    echo "=========================================="
    exit 0
fi

try_server "備用" "$URL2" "$URL2_FALLBACK" "$URL2_HEALTH" "2"
rc=$?

echo ""
echo "=========================================="
if [ $rc -eq 0 ]; then
    echo "[$(ts)] 總結: 上傳成功"
    echo "使用伺服器: $USED_SERVER"
    echo "成功階段  : $USED_STAGE"
    [ -n "$FALLBACK_LOG_1" ] && echo "主要觸發器紀錄: $FALLBACK_LOG_1"
    [ -n "$FALLBACK_LOG_2" ] && echo "備用觸發器紀錄: $FALLBACK_LOG_2"
    echo "=========================================="
    exit 0
else
    echo "[$(ts)] 總結: 上傳失敗"
    echo "主要伺服器: $URL1 （失敗）"
    [ -n "$FALLBACK_LOG_1" ] && echo "  觸發器: $FALLBACK_LOG_1"
    echo "備用伺服器: $URL2 （失敗）"
    [ -n "$FALLBACK_LOG_2" ] && echo "  觸發器: $FALLBACK_LOG_2"
    echo "=========================================="
    exit 1
fi
