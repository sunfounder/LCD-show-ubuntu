#!/bin/bash

CMDLINE_PATH="/boot/firmware/cmdline.txt"
CMDLINE_PATH_OLD="/boot/cmdline.txt"

# 检查是否以root权限运行
if [ "$(id -u)" -ne 0 ]; then
    echo "错误：需要root权限运行，请使用sudo"
    exit 1
fi

# 检查cmdline.txt是否存在
if [ ! -f "$CMDLINE_PATH" ]; then
  if [ -f "$CMDLINE_PATH_OLD" ]; then
    CMDLINE_PATH=$CMDLINE_PATH_OLD
  else
    echo "错误：未找到文件 $CMDLINE_PATH 和 $CMDLINE_PATH_OLD"
    exit 1
  fi
fi

BACKUP_PATH="${CMDLINE_PATH}.bak"

# 备份文件（仅在备份不存在时创建）
backup_file() {
    timestamp=$(date +%Y%m%d%H%M%S)
    cp -a "$CMDLINE_PATH" "cmdline-$timestamp.txt.bak"
    echo "已创建备份：cmdline-$timestamp.txt.bak"
}

# 查看参数（get命令）
cmd_get() {
    echo "当前 $CMDLINE_PATH 内容："
    echo "----------------------------------------"
    cat "$CMDLINE_PATH"
    echo -e "\n----------------------------------------"
    
    # 格式化显示参数列表
    echo -e "\n参数列表："
    cat "$CMDLINE_PATH" | tr ' ' '\n' | grep -v '^$' | sort
}

# 修改/添加参数（set命令）
cmd_set() {
    local key="$1"
    local value="$2"
    
    if [ -z "$key" ] || [ -z "$value" ]; then
        echo "错误：请指定参数名和值，格式：set <参数名> <参数值>"
        echo "示例：set fbcon map:20"
        exit 1
    fi

    # 备份文件
    backup_file

    # 读取当前内容
    local current=$(cat "$CMDLINE_PATH")
    
    # 检查参数是否已存在
    if echo "$current" | grep -qE "\b${key}="; then
        # 替换现有参数（使用正则确保完整匹配参数名）
        local new_content=$(echo "$current" | sed -E "s/\b${key}=[^ ]+/$(printf "%s=%s" "$key" "$value")/")
        echo "已更新参数：$key=$value"
    else
        # 添加新参数
        local new_content="${current} ${key}=${value}"
        echo "已添加参数：$key=$value"
    fi

    # 写入新内容（确保无换行）
    echo -n "$new_content" > "$CMDLINE_PATH"
}

# 删除参数（delete命令）
cmd_delete() {
    local key="$1"
    
    if [ -z "$key" ]; then
        echo "错误：请指定要删除的参数名，格式：delete <参数名>"
        echo "示例：delete fbcon"
        exit 1
    fi

    # 读取当前内容
    local current=$(cat "$CMDLINE_PATH")
    
    # 检查参数是否存在
    if ! echo "$current" | grep -qE "\b${key}="; then
        echo "错误：未找到参数 $key"
        exit 1
    fi

    # 备份文件
    backup_file

    # 删除包含该参数的部分（使用正则匹配整个参数）
    local new_content=$(echo "$current" | sed -E "s/\s*${key}=[^ ]+//")
    # 清理可能产生的多余空格（确保参数间只有一个空格）
    new_content=$(echo "$new_content" | tr -s ' ')
    
    echo "已删除参数：$key"
    echo -n "$new_content" > "$CMDLINE_PATH"
}

# 显示帮助
show_help() {
    echo "用法：$0 [命令] [参数]"
    echo "命令："
    echo "  get               查看当前cmdline.txt内容和参数列表"
    echo "  set <key> <value> 修改或添加参数（格式：key=value）"
    echo "  delete <key>      删除指定参数（仅需参数名）"
    echo "  help              显示帮助信息"
    echo "示例："
    echo "  $0 get                查看当前参数"
    echo "  $0 set fbcon map:20   设置fbcon=map:20"
    echo "  $0 delete fbcon       删除fbcon参数"
}

# 解析命令
case "$1" in
    get)
        cmd_get
        ;;
    set)
        cmd_set "$2" "$3"
        ;;
    delete)
        cmd_delete "$2"
        ;;
    help|--help)
        show_help
        ;;
    *)
        echo "未知命令：$1"
        show_help
        exit 1
        ;;
esac
