#!/data/data/com.termux/files/usr/bin/bash

CR="\r\033[K"

OWNER_NAME="Suphawat"
DISCORD_LINK="https://discord.gg/VCPAaUy46C"

VALID_PASSWORDS=("PREM1688" "BIG49")
MAX_ATTEMPTS=3

check_password() {
    clear
    echo -e "╔════════════════════════════════════════╗"
    echo -e "║            INFINITE SHOP               ║"
    echo -e "╚════════════════════════════════════════╝"
    
    local ATTEMPTS=0
    while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
        echo -ne "${CR}🔑 รหัสผ่าน: "
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
            return 0
        else
            echo -e "${CR}❌ รหัสผ่านไม่ถูกต้อง"
            ATTEMPTS=$((ATTEMPTS + 1))
        fi
    done
    echo -e "${CR}🚫 ล็อกระบบชั่วคราว"
    exit 1
}

install_apk() {
    local NAME=$1
    local URL=$2
    local TEMP_FILE="/data/data/com.termux/files/home/temp_app.apk"

    echo -e "${CR}------------------------------------------"
    echo -e "${CR}📥 กำลังดาวน์โหลด: $NAME"
    
    rm -f "$TEMP_FILE"
    curl -sL "$URL" -o "$TEMP_FILE"
    local CURL_STATUS=$?

    if [ $CURL_STATUS -eq 0 ] && [ -f "$TEMP_FILE" ]; then
        local FILE_SIZE=$(du -k "$TEMP_FILE" | cut -f1)
        if [ "$FILE_SIZE" -gt 1024 ]; then
            echo -e "${CR}⚡ กำลังติดตั้ง: $NAME ..."
            
            local INSTALL_OUTPUT
            INSTALL_OUTPUT=$(su -c "pm install -r -g '$TEMP_FILE'" 2>&1)
            local STATUS=$?

            if [ $STATUS -eq 0 ] && [[ "$INSTALL_OUTPUT" == *"Success"* ]]; then
                echo -e "${CR}✅ ติดตั้งสำเร็จ: $NAME"
            else
                echo -e "${CR}❌ ติดตั้งไม่สำเร็จ"
            fi
        else
            echo -e "${CR}❌ ไฟล์เสีย (ขนาดไฟล์เล็กเกินไป)"
        fi
        rm -f "$TEMP_FILE"
    else
        echo -e "${CR}❌ ดาวน์โหลดล้มเหลว"
    fi
    echo -e "${CR}------------------------------------------"
}

process_selection() {
    local CATEGORY_NAME=$1
    shift
    local APPS=("$@")
    local TOTAL=${#APPS[@]}

    clear
    echo -e "╔════════════════════════════════════════╗"
    echo -e "║        📂 หมวดหมู่: $CATEGORY_NAME      ║"
    echo -e "╚════════════════════════════════════════╝"
    
    for i in "${!APPS[@]}"; do
        echo -e "${CR}[$((i+1))] $CATEGORY_NAME $((i+1))"
    done
    
    echo -e "${CR}------------------------------------------"
    echo -e "${CR}💡 พิมพ์: 1-${TOTAL} หรือระบุตัวเลข (เช่น 1 3 5) หรือ all"
    echo -e "${CR}------------------------------------------"

    echo -ne "${CR}🎯 เลือกรายการ: "
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
    echo -e "╔════════════════════════════════════════╗"
    echo -e "║          🚀 กำลังดำเนินการติดตั้ง           ║"
    echo -e "╚════════════════════════════════════════╝"

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
echo -e "╔════════════════════════════════════════╗"
echo -e "║              INFINITE SHOP             ║"
echo -e "╚════════════════════════════════════════╝"
echo -e "${CR}👑 Developer : $OWNER_NAME"
echo -e "${CR}💬 Discord   : $DISCORD_LINK"
echo -e "${CR}------------------------------------------"
echo -e "${CR}[1] Delta        (${#DELTA_APPS[@]} Apps)"
echo -e "${CR}[2] ArceusX lite (${#ARCEUS_APPS[@]} Apps)"
echo -e "${CR}------------------------------------------"
echo -ne "${CR}🎯 เลือกหมวดหมู่ (1-2): "
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
        echo -e "${CR}[!] เลือกเมนูไม่ถูกต้อง"
        ;;
esac

echo -e "${CR}"
echo -e "${CR}------------------------------------------"
echo -e "${CR}         ✨ ทำงานเสร็จสิ้นเรียบร้อย! ✨        "
echo -e "${CR}------------------------------------------"
