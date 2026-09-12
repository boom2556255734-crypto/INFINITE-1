#!/data/data/com.termux/files/usr/bin/bash

# กำหนดรหัสสีเพื่อความสวยงาม
C_RESET="\033[0m"
C_CYAN="\033[1;36m"
C_GREEN="\033[1;32m"
C_YELLOW="\033[1;33m"
C_RED="\033[1;31m"
C_PURPLE="\033[1;35m"
CR="\r\033[K"

OWNER_NAME="Suphawat"
DISCORD_LINK="https://discord.gg/VCPAaUy46C"

VALID_PASSWORDS=("1688" "BIG49")
MAX_ATTEMPTS=3

check_password() {
    clear
    echo -e "${C_CYAN}+----------------------------------------+${C_RESET}"
    echo -e "${C_CYAN}|${C_RESET}            ${C_YELLOW}INFINITE SHOP${C_RESET}               ${C_CYAN}|${C_RESET}"
    echo -e "${C_CYAN}+----------------------------------------+${C_RESET}"
    
    local ATTEMPTS=0
    while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
        echo -ne "${CR}${C_GREEN}🔑 กรอกรหัสผ่าน: ${C_RESET}"
        read -s USER_PASS
        echo ""
        
        USER_PASS=$(echo "$USER_PASS" | tr -d '[:space:]' | tr -d '\r')
        
        local IS_CORRECT=0
        for PASS in "${VALID_PASSWORDS[@]}"; do
            if [ "$USER_PASS" == "$PASS" ]; then
                IS_CORRECT=1
                break
            fi
        done
        
        if [ $IS_CORRECT -eq 1 ]; then
            echo -e "${C_GREEN}✔ รหัสผ่านถูกต้อง! กำลังเข้าสู่ระบบ...${C_RESET}"
            sleep 1
            return 0
        else
            echo -e "${CR}${C_RED}❌ รหัสผ่านไม่ถูกต้อง (ลองอีกครั้ง)${C_RESET}"
            ATTEMPTS=$((ATTEMPTS + 1))
        fi
    done
    echo -e "${CR}${C_RED}🚫 ใส่รหัสผิดเกินกำหนด ล็อกระบบชั่วคราว${C_RESET}"
    exit 1
}

install_apk() {
    local NAME=$1
    local URL=$2
    local TEMP_FILE="/sdcard/Download/temp_app.apk"

    echo -e "${CR}${C_CYAN}------------------------------------------${C_RESET}"
    echo -e "${CR}${C_YELLOW}📥 กำลังดาวน์โหลด:${C_RESET} $NAME"
    
    rm -f "$TEMP_FILE"
    curl -sL "$URL" -o "$TEMP_FILE"
    local CURL_STATUS=$?

    if [ $CURL_STATUS -eq 0 ] && [ -f "$TEMP_FILE" ]; then
        local FILE_SIZE=$(du -k "$TEMP_FILE" | cut -f1)
        if [ "$FILE_SIZE" -gt 1024 ]; then
            echo -e "${CR}${C_GREEN}⚡ กำลังติดตั้ง:${C_RESET} $NAME ..."
            
            termux-open "$TEMP_FILE"
            echo -e "${CR}${C_GREEN}✅ เปิดหน้าต่างติดตั้งสำเร็จ:${C_RESET} $NAME"
        else
            echo -e "${CR}${C_RED}❌ ไฟล์เสียหรือขนาดเล็กเกินไป${C_RESET}"
        fi
    else
        echo -e "${CR}${C_RED}❌ ดาวน์โหลดล้มเหลว (ตรวจสอบลิงก์)${C_RESET}"
    fi
    echo -e "${CR}${C_CYAN}------------------------------------------${C_RESET}"
}

process_selection() {
    local CATEGORY_NAME=$1
    shift
    local APPS=("$@")
    local TOTAL=${#APPS[@]}

    clear
    echo -e "${C_CYAN}------------------------------------------${C_RESET}"
    echo -e "${C_CYAN}|${C_RESET}       หมวดหมู่: ${C_YELLOW}$CATEGORY_NAME${C_RESET}       ${C_CYAN}|${C_RESET}"
    echo -e "${C_CYAN}------------------------------------------${C_RESET}"
    
    for i in "${!APPS[@]}"; do
        echo -e "${CR} ${C_PURPLE}[$((i+1))]${C_RESET} $CATEGORY_NAME $((i+1))"
    done
    
    echo -e "${C_CYAN}------------------------------------------${C_RESET}"
    echo -e "${C_YELLOW}💡 คำแนะนำ:${C_RESET} พิมพ์ 1-${TOTAL} หรือระบุ (เช่น 1 3) หรือ all"
    echo -e "${C_CYAN}------------------------------------------${C_RESET}"

    echo -ne "${C_GREEN}🎯 เลือกรายการที่ต้องการ: ${C_RESET}"
    read INPUT_CHOICE
    echo ""

    local SELECTED_INDICES=()

    if [[ "$INPUT_CHOICE" == "all" || "$INPUT_CHOICE" == "ALL" ]]; then
        for i in "${!APPS[@]}"; do
            SELECTED_INDICES+=($i)
        done
    else
        for ITEM in $INPUT_CHOICE; do
            if [[ "$ITEM" =~ ^([0-9]+)-([0-9]+)$ ]]; then
                START=${BASH_REMATCH[1]}
                END=${BASH_REMATCH[2]}
                for ((i=START; i<=END; i++)); do
                    SELECTED_INDICES+=($((i-1)))
                done
            elif [[ "$ITEM" =~ ^[0-9]+$ ]]; then
                SELECTED_INDICES+=($((ITEM-1)))
            fi
        done
    fi

    clear
    echo -e "${C_CYAN}------------------------------------------${C_RESET}"
    echo -e "${C_CYAN}|${C_RESET}         ${C_GREEN}🚀 กำลังดำเนินการติดตั้ง${C_RESET}         ${C_CYAN}|${C_RESET}"
    echo -e "${C_CYAN}------------------------------------------${C_RESET}"

    for INDEX in "${SELECTED_INDICES[@]}"; do
        if [ $INDEX -ge 0 ] && [ $INDEX -lt $TOTAL ]; then
            install_apk "$CATEGORY_NAME $((INDEX+1))" "${APPS[$INDEX]}"
        fi
    done
}

DELTA_APPS=(
  "https://raw.githubusercontent.com/suphawatinf/INFINITESHOP/refs/heads/main/delta1.apk"
  "https://raw.githubusercontent.com/suphawatinf/INFINITESHOP/refs/heads/main/delta2.apk"
)

ARCEUS_APPS=(
  "https://github.com/suphawatinf/INFINITESHOP/releases/download/V1.0/ArceusX.lite.by.Suphawat.1_2.737.1584.apk"
  "https://github.com/suphawatinf/INFINITESHOP/releases/download/V1.0/ArceusX.lite.by.Suphawat.2_2.737.1584.apk"
  "https://github.com/suphawatinf/INFINITESHOP/releases/download/V1.0/ArceusX.lite.by.Suphawat.3_2.737.1584.apk"
  "https://github.com/suphawatinf/INFINITESHOP/releases/download/V1.0/ArceusX.lite.by.Suphawat.4_2.737.1584.apk"
  "https://github.com/suphawatinf/INFINITESHOP/releases/download/V1.0/ArceusX.lite.by.Suphawat.5_2.737.1584.apk"
  "https://github.com/suphawatinf/INFINITESHOP/releases/download/V1.0/ArceusX.lite.by.Suphawat.6_2.737.1584.apk"
  "https://github.com/suphawatinf/INFINITESHOP/releases/download/V1.0/ArceusX.lite.by.Suphawat.7_2.737.1584.apk"
  "https://github.com/suphawatinf/INFINITESHOP/releases/download/V1.0/ArceusX.lite.by.Suphawat.8_2.737.1584.apk"
)

check_password

clear
echo -e "${C_CYAN}+----------------------------------------+${C_RESET}"
echo -e "${C_CYAN}|${C_RESET}              ${C_YELLOW}INFINITE SHOP${C_RESET}             ${C_CYAN}|${C_RESET}"
echo -e "${C_CYAN}+----------------------------------------+${C_RESET}"
echo -e "${C_CYAN}👑 Developer :${C_RESET} $OWNER_NAME"
echo -e "${C_CYAN}💬 Discord   :${C_RESET} $DISCORD_LINK"
echo -e "${C_CYAN}------------------------------------------${C_RESET}"
echo -e "${C_PURPLE}[1]${C_RESET} Delta        (${C_GREEN}${#DELTA_APPS[@]}${C_RESET} Apps)"
echo -e "${C_PURPLE}[2]${C_RESET} ArceusX lite (${C_GREEN}${#ARCEUS_APPS[@]}${C_RESET} Apps)"
echo -e "${C_CYAN}------------------------------------------${C_RESET}"
echo -ne "${C_GREEN}🎯 เลือกหมวดหมู่ที่ต้องการ (1-2): ${C_RESET}"
read MAIN_CHOICE
echo ""

case $MAIN_CHOICE in
    1)
        process_selection "Delta" "${DELTA_APPS[@]}"
        ;;
    2)
        process_selection "ArceusX lite" "${ARCEUS_APPS[@]}"
        ;;
    *)
        echo -e "${C_RED}[!] เลือกเมนูไม่ถูกต้อง กรุณาลองใหม่${C_RESET}"
        ;;
esac

echo -e "${C_CYAN}"
echo -e "${C_CYAN}------------------------------------------${C_RESET}"
echo -e "         ${C_GREEN}✨ ทำงานเสร็จสิ้นเรียบร้อย! ✨${C_RESET}        "
echo -e "${C_CYAN}------------------------------------------${C_RESET}"
