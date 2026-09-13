install_apk() {
    local NAME=$1
    local URL=$2
    local TEMP_FILE="/sdcard/Download/temp_app.apk"

    echo -e "${CR}${C_CYAN}------------------------------------------${C_RESET}"
    echo -e "${CR}${C_YELLOW}📥 กำลังดาวน์โหลด: ${C_WHITE}$NAME${C_RESET}"
    
    rm -f "$TEMP_FILE"
    
    # ย้ายเข้าโฟลเดอร์ก่อน เพื่อตัด Path ยาวๆ ทิ้งให้เหลือแค่ชื่อไฟล์สั้นๆ
    cd /sdcard/Download 2>/dev/null || true
    wget -q --show-progress --progress=bar:force:noscroll -O temp_app.apk "$URL"
    local DL_STATUS=$?
    cd - >/dev/null 2>&1

    if [ $DL_STATUS -eq 0 ] && [ -f "$TEMP_FILE" ]; then
        local FILE_SIZE=$(du -k "$TEMP_FILE" | cut -f1)
        if [ "$FILE_SIZE" -gt 1024 ]; then
            chmod 777 "$TEMP_FILE" 2>/dev/null
            
            echo -e "${CR}${C_GREEN}⚡ กำลังดำเนินการติดตั้ง:${C_RESET} $NAME ..."
            
            if command -v su >/dev/null 2>&1 && su -c "true" >/dev/null 2>&1; then
                su -c "pm install -r \"$TEMP_FILE\"" >/dev/null 2>&1
                local PM_STATUS=$?
                stty sane 2>/dev/null
                
                if [ $PM_STATUS -eq 0 ]; then
                    echo -e "${CR}${C_GREEN}✅ ติดตั้งแอปเสร็จสมบูรณ์ลงในเครื่องแล้ว!${C_RESET}"
                else
                    echo -e "${CR}${C_RED}❌ ติดตั้งเบื้องหลังล้มเหลว เรียกหน้าต่างปกติ...${C_RESET}"
                    termux-open --content-type "application/vnd.android.package-archive" "$TEMP_FILE"
                    stty sane 2>/dev/null
                fi
            else
                termux-open --content-type "application/vnd.android.package-archive" "$TEMP_FILE"
                stty sane 2>/dev/null
                echo -e "${CR}${C_GREEN}✅ เรียกหน้าต่างติดตั้งแล้ว:${C_RESET} (กด 'ติดตั้ง' บนจอ)"
            fi
        else
            echo -e "${CR}${C_RED}❌ ไฟล์เสีย หรือลิงก์หมดอายุ (พบไฟล์ขนาด ${FILE_SIZE}KB)${C_RESET}"
            rm -f "$TEMP_FILE"
        fi
    else
        echo -e "${CR}${C_RED}❌ ดาวน์โหลดล้มเหลว (Error Code: $DL_STATUS)${C_RESET}"
    fi
    echo -e "${CR}${C_CYAN}------------------------------------------${C_RESET}"
}
