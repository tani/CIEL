#!/bin/bash

# OSC 11 を使用して背景色を取得
get_bg_color() {
    # 背景色クエリを送信
    echo -ne "\033]11;?\007"
    # 応答を読み取る
    read -t 1 -s -d $'\a' response
    echo "$response"
}

# RGB値から明るさを判定
is_dark() {
    local response=$1
    if [[ $response =~ rgb:([0-9a-f]{4})/([0-9a-f]{4})/([0-9a-f]{4}) ]]; then
        local r=$((16#${BASH_REMATCH[1]}))
        local g=$((16#${BASH_REMATCH[2]}))
        local b=$((16#${BASH_REMATCH[3]}))
        # RGB値の合計が閾値より小さければdark
        local threshold=$((0xffff * 3 / 2))
        local sum=$((r + g + b))
        if [ $sum -lt $threshold ]; then
            return 0  # dark
        fi
    fi
    return 1  # light
}

# COLORFGBG環境変数をフォールバックとして使用
check_colorfgbg() {
    if [ -n "$COLORFGBG" ]; then
        case "$COLORFGBG" in
            *";0"*) return 0 ;;  # dark
            *";15"*) return 1 ;;  # light
        esac
    fi
    return 2  # 判定不能
}

# メイン処理
main() {
    local bg_response=$(get_bg_color)
    echo $bg_response
    if [ -n "$bg_response" ]; then
        if is_dark "$bg_response"; then
            echo "dark"
        else
            echo "light"
        fi
    elif check_colorfgbg; then
        echo "dark"
    else
        echo "light"
    fi
}

main

