#!/bin/bash

# 遍历所有可能的fb设备
for i in {0..9}; do
    fb_device="/sys/class/graphics/fb$i"
    
    # 检查设备是否存在
    if [ -d "$fb_device" ]; then
        name_file="$fb_device/name"
        
        # 检查name文件是否存在
        if [ -f "$name_file" ]; then
            # 获取name内容
            name=$(cat "$name_file")
            
            # 检查是否包含目标模式
            if echo "$name" | grep -q "fb_ili9486"; then
                echo "fb$i"
                exit 0
            fi
        fi
    fi
done

echo "[ERROR]: not found fb device with name fb_ili9486"
exit 1
