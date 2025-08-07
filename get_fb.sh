#!/bin/bash

# # 遍历所有可能的fb设备
# for i in {0..9}; do
#     fb_device="/sys/class/graphics/fb$i"
    
#     # 检查设备是否存在
#     if [ -d "$fb_device" ]; then
#         name_file="$fb_device/name"
        
#         # 检查name文件是否存在
#         if [ -f "$name_file" ]; then
#             # 获取name内容
#             name=$(cat "$name_file")
            
#             # 检查是否包含目标模式
#             if echo "$name" | grep -q "fb_ili9486"; then
#                 echo "fb$i"
#                 exit 0
#             fi
#         # 没有name文件，返回这个设备，并返回1作为警告
#         else
#             echo "fb$i"
#             exit 1
#         fi
#     fi
# done

# 通过/proc/fb获取fb设备列表，找到包含fb_ili9486的设备，如果找不到则猜测可能是最后一个fb设备+1
# 最后输出fb_ili9486设备号
fb_list=$(cat /proc/fb)
fb_ili9486=$(echo "$fb_list" | grep "fb_ili9486")
if [ -z "$fb_ili9486" ]; then
    # 猜测可能是最后一个fb设备+1
    id=$(echo "$fb_list" | tail -n 1 | awk '{print $1}')
    if [ -z "$id" ]; then
        id=0
    else
        id=$(($id + 1))
    fi
    echo "$id"
    exit 1
fi
id=$(echo "$fb_ili9486" | awk '{print $1}')
echo "$id"
exit 0
