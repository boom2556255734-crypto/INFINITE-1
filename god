#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
# 1. ล้างแคช ป้องกันบัค และรีเซ็ตหน้าจอ
# ==========================================
hash -r 2>/dev/null
stty sane 2>/dev/null

# กำหนดรหัสสี
C_RESET="\033[0m"
C_CYAN="\033[1;36m"
C_GREEN="\033[1;32m"
C_YELLOW="\033[1;33m"
C_RED="\033[1;31m"
C_PURPLE="\033[1;35m"
C_BLUE="\033[1;34m"
C_WHITE="\033[1;37m"
CR="\r\033[K"

OWNER_NAME="Suphawat"
DISCORD_LINK="https://discord.gg/VCPAaUy46C"
VALID_PASSWORDS=("1688" "BIG49" "wiwatz")
MAX_ATTEMPTS=3

# ==========================================
# 2. ลูกเล่น: เอฟเฟกต์พิมพ์ดีด และ Boot Screen
# ==========================================
type_text() {
    local text="$1"
    local color="$2"
    echo -ne "${CR}${color}"
    for (( i=0; i<${#text}; i++ )); do
        echo -ne "${text:$i:1}"
        sleep 0.02
    done
    echo -e "${C_RESET}"
}

boot_sequence() {
    clear
    for i in {1..7}; do
        local HEX=$(head -c 4 /dev/urandom | xxd -p)
        echo -e "${CR}${C_GREEN}[+] Loading Core Module: 0x${HEX^^} ... OK${C_RESET}"
        sleep 0.1
    done
    sleep 0.3
}

# ==========================================
# 3. ตรวจสอบสิทธิ์และโปรแกรมเสริม (อุดรอยรั่ว 100%)
# ==========================================
check_dependencies() {
    local DEPS=("curl" "wget")
    for DEP in "${DEPS[@]}"; do
        if ! command -v $DEP >/dev/null 2>&1; then
            echo -e "${CR}${C_YELLOW}⚙️ กำลังติดตั้งคอมโพเนนต์ที่ขาดหาย: $DEP...${C_RESET}"
            pkg install $DEP -y >/dev/null 2>&1
        fi
    done
}
check_dependencies

if [ ! -d "/sdcard/Download" ] || ! touch "/sdcard/Download/.test_perm" 2>/dev/null; then
    clear
    echo -e "${CR}${C_YELLOW}⚠️ ระบบต้องการสิทธิ์เข้าถึงพื้นที่จัดเก็บข้อมูล...${C_RESET}"
    echo -e "${CR}${C_CYAN}กรุณากด 'อนุญาต (Allow)' ที่หน้าจอของคุณ${C_RESET}"
    termux-setup-storage
    sleep 3
fi
rm -f "/sdcard/Download/.test_perm" 2>/dev/null

# ==========================================
# 4. ฟังก์ชันคำนวณข้อมูลเครื่อง (Device HUD)
# ==========================================
get_device_info() {
    OS_VER=$(getprop ro.build.version.release 2>/dev/null || echo "?")
    ARCH=$(uname -m 2>/dev/null || echo "?")
    
    local RAM_KB=$(grep MemTotal /proc/meminfo 2>/dev/null | awk '{print $2}')
    if [ -n "$RAM_KB" ]; then
        RAM_GB=$(awk "BEGIN {printf \"%.1f\", $RAM_KB/1048576}" 2>/dev/null)" GB"
    else
        RAM_GB="?"
    fi
    
    local ROM_TOTAL=$(df -h /sdcard 2>/dev/null | awk 'NR==2 {print $2}')
    local ROM_FREE=$(df -h /sdcard 2>/dev/null | awk 'NR==2 {print $4}')
    if [ -n "$ROM_TOTAL" ]; then
        ROM_INFO="${ROM_TOTAL} (ว่าง ${ROM_FREE})"
    else
        ROM_INFO="?"
    fi
}

# ==========================================
# 5. ระบบความปลอดภัย (Login)
# ==========================================
check_password() {
    boot_sequence
    clear
    echo -e "${C_CYAN}╔════════════════════════════════════════╗${C_RESET}"
    echo -e "${C_CYAN}║${C_RESET}              ${C_YELLOW}INFINITE SHOP${C_RESET}             ${C_CYAN}║${C_RESET}"
    echo -e "${C_CYAN}╚════════════════════════════════════════╝${C_RESET}"
    
    local ATTEMPTS=0
    while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
        echo -ne "${CR}${C_GREEN}🔑 กรอกรหัสผ่านระบบ : ${C_WHITE}"
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
            type_text "✔ รหัสผ่านถูกต้อง! เข้าสู่ระบบสำเร็จ..." "$C_GREEN"
            sleep 0.5
            get_device_info
            return 0
        else
            echo -e "${CR}${C_RED}❌ รหัสผ่านไม่ถูกต้อง (เหลือโอกาส $((MAX_ATTEMPTS - ATTEMPTS - 1)) ครั้ง)${C_RESET}"
            ATTEMPTS=$((ATTEMPTS + 1))
        fi
    done
    echo -e "${CR}${C_RED}🚫 ใส่รหัสผิดเกินกำหนด ล็อกระบบชั่วคราว${C_RESET}"
    exit 1
}

# ==========================================
# 6. ระบบติดตั้งแอป (แอนิเมชันแบบ Spinner ไม่ตกขอบ)
# ==========================================
install_apk() {
    local NAME=$1
    local URL=$2
    local TEMP_FILE="/sdcard/Download/temp_app.apk"

    echo -e "${CR}${C_CYAN} ----------------------------------------${C_RESET}"
    rm -f "$TEMP_FILE"
    
    # โหลดไฟล์อยู่เบื้องหลังเพื่อดึงเวลามาแสดงแอนิเมชันหมุนโหลด
    curl -sL -A "Mozilla/5.0" "$URL" -o "$TEMP_FILE" &
    local PID=$!
    local SPINNER=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local i=0
    while kill -0 $PID 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        echo -ne "${CR} ${C_YELLOW}📥 กำลังดาวน์โหลด ${C_CYAN}${SPINNER[$i]} ${C_WHITE}$NAME${C_RESET}"
        sleep 0.05
    done
    wait $PID
    local DL_STATUS=$?
    echo -e "${CR} ${C_GREEN}📥 ดาวน์โหลดสำเร็จ!       ${C_RESET}"

    if [ $DL_STATUS -eq 0 ] && [ -f "$TEMP_FILE" ]; then
        local FILE_SIZE=$(du -k "$TEMP_FILE" | cut -f1)
        if [ "$FILE_SIZE" -gt 1024 ]; then
            chmod 777 "$TEMP_FILE" 2>/dev/null
            echo -e "${CR} ${C_YELLOW}⚡ กำลังติดตั้งแอป : ${C_WHITE}$NAME${C_RESET}"
            
            if command -v su >/dev/null 2>&1 && su -c "true" >/dev/null 2>&1; then
                su -c "pm install -r \"$TEMP_FILE\"" >/dev/null 2>&1
                local PM_STATUS=$?
                stty sane 2>/dev/null
                if [ $PM_STATUS -eq 0 ]; then
                    echo -e "${CR} ${C_GREEN}✅ ติดตั้งแอปเสร็จสมบูรณ์แบบพื้นหลัง!${C_RESET}"
                else
                    echo -e "${CR} ${C_RED}❌ ติดตั้งพื้นหลังล้มเหลว เรียกหน้าต่างปกติ..${C_RESET}"
                    termux-open --content-type "application/vnd.android.package-archive" "$TEMP_FILE"
                    stty sane 2>/dev/null
                fi
            else
                termux-open --content-type "application/vnd.android.package-archive" "$TEMP_FILE"
                stty sane 2>/dev/null
                echo -e "${CR} ${C_GREEN}✅ เรียกหน้าต่างติดตั้งแล้ว (กดติดตั้งบนจอ)${C_RESET}"
            fi
        else
            echo -e "${CR} ${C_RED}❌ ไฟล์เสีย หรือลิงก์หมดอายุ${C_RESET}"
            rm -f "$TEMP_FILE"
        fi
    else
        echo -e "${CR} ${C_RED}❌ ดาวน์โหลดล้มเหลว${C_RESET}"
    fi
}

process_selection() {
    local CATEGORY_NAME=$1
    shift
    local APPS=("$@")
    local TOTAL=${#APPS[@]}

    while true; do
        clear
        stty sane 2>/dev/null
        echo -e "${C_CYAN}╔════════════════════════════════════════╗${C_RESET}"
        echo -e "${C_CYAN}║${C_RESET} 📁 หมวดหมู่: ${C_YELLOW}$CATEGORY_NAME${C_RESET} \t\t ${C_CYAN}║${C_RESET}"
        echo -e "${C_CYAN}╚════════════════════════════════════════╝${C_RESET}"
        
        for i in "${!APPS[@]}"; do
            echo -e "${CR}  ${C_PURPLE}[$((i+1))]${C_RESET} ${C_BLUE}▸${C_RESET} $CATEGORY_NAME $((i+1))"
        done
        
        echo -e "${CR}${C_CYAN} ----------------------------------------${C_RESET}"
        echo -e "${CR} ${C_YELLOW}💡 พิมพ์ 1-${TOTAL} หรือแบบช่วง (เช่น 1-3)${C_RESET}"
        echo -e "${CR} ${C_WHITE}   (พิมพ์ 0 เพื่อกลับไปหน้าเมนูหลัก)${C_RESET}"
        echo -e "${CR}${C_CYAN} ----------------------------------------${C_RESET}"

        echo -ne "${CR}${C_GREEN}🎯 เลือกรายการ: ${C_RESET}"
        read INPUT_CHOICE
        echo ""

        if [ "$INPUT_CHOICE" == "0" ]; then
            return 0
        fi

        local SELECTED_INDICES=()
        local VALID_INPUT=0

        if [[ "$INPUT_CHOICE" == "all" || "$INPUT_CHOICE" == "ALL" ]]; then
            for i in "${!APPS[@]}"; do
                SELECTED_INDICES+=($i)
            done
            VALID_INPUT=1
        else
            for ITEM in $INPUT_CHOICE; do
                if [[ "$ITEM" =~ ^([0-9]+)-([0-9]+)$ ]]; then
                    local START=${BASH_REMATCH[1]}
                    local END=${BASH_REMATCH[2]}
                    
                    # สลับตัวเลขให้อัตโนมัติ ป้องกันลูกค้าพิมพ์กลับหลัง
                    if [ "$START" -gt "$END" ]; then
                        local TEMP_NUM=$START
                        START=$END
                        END=$TEMP_NUM
                    fi

                    for ((i=START; i<=END; i++)); do
                        if [ $((i-1)) -ge 0 ] && [ $((i-1)) -lt $TOTAL ]; then
                            SELECTED_INDICES+=($((i-1)))
                            VALID_INPUT=1
                        fi
                    done
                elif [[ "$ITEM" =~ ^[0-9]+$ ]]; then
                    if [ $((ITEM-1)) -ge 0 ] && [ $((ITEM-1)) -lt $TOTAL ]; then
                        SELECTED_INDICES+=($((ITEM-1)))
                        VALID_INPUT=1
                    fi
                fi
            done
        fi

        if [ $VALID_INPUT -eq 1 ]; then
            clear
            stty sane 2>/dev/null
            echo -e "${C_CYAN}╔════════════════════════════════════════╗${C_RESET}"
            echo -e "${C_CYAN}║${C_RESET}          ${C_GREEN}🚀 System Processing${C_RESET}          ${C_CYAN}║${C_RESET}"
            echo -e "${C_CYAN}╚════════════════════════════════════════╝${C_RESET}"

            for INDEX in "${SELECTED_INDICES[@]}"; do
                install_apk "$CATEGORY_NAME $((INDEX+1))" "${APPS[$INDEX]}"
            done
            
            echo -e "${CR}${C_CYAN} ----------------------------------------${C_RESET}"
            echo -ne "${CR}${C_YELLOW}✨ กด Enter เพื่อกลับไปหน้าเลือกแอป...${C_RESET}"
            read
        else
            echo -e "${CR}${C_RED}[!] ข้อมูลไม่ถูกต้อง กรุณาลองใหม่${C_RESET}"
            sleep 1
        fi
    done
}

DELTA_APPS=(
  "https://raw.githubusercontent.com/suphawatinf/INFINITESHOP/refs/heads/main/delta1.apk"
  "https://raw.githubusercontent.com/suphawatinf/INFINITESHOP/refs/heads/main/delta2.apk"
)

DELTA_LITE_APPS=(
  "https://raw.githubusercontent.com/suphawatinf/INFINITESHOP/refs/heads/main/delta_lite1.apk"
  "https://raw.githubusercontent.com/suphawatinf/INFINITESHOP/refs/heads/main/delta_lite2.apk"
)

ARCEUS_NORMAL_APPS=(
  "https://github.com/suphawatinf/INFINITESHOP/releases/download/V1.0/ArceusX.by.Suphawat.1_2.737.1584.apk"
  "https://github.com/suphawatinf/INFINITESHOP/releases/download/V1.0/ArceusX.by.Suphawat.2_2.737.1584.apk"
  "https://github.com/suphawatinf/INFINITESHOP/releases/download/V1.0/ArceusX.by.Suphawat.3_2.737.1584.apk"
  "https://github.com/suphawatinf/INFINITESHOP/releases/download/V1.0/ArceusX.by.Suphawat.4_2.737.1584.apk"
  "https://github.com/suphawatinf/INFINITESHOP/releases/download/V1.0/ArceusX.by.Suphawat.5_2.737.1584.apk"
  "https://github.com/suphawatinf/INFINITESHOP/releases/download/V1.0/ArceusX.by.Suphawat.6_2.737.1584.apk"
  "https://github.com/suphawatinf/INFINITESHOP/releases/download/V1.0/ArceusX.by.Suphawat.7_2.737.1584.apk"
  "https://github.com/suphawatinf/INFINITESHOP/releases/download/V1.0/ArceusX.by.Suphawat.8_2.737.1584.apk"
)

ARCEUS_LITE_APPS=(
  "https://github.com/suphawatinf/INFINITESHOP/releases/download/V1.0/ArceusX.lite.by.Suphawat.1_2.737.1584.apk"
  "https://github.com/suphawatinf/INFINITESHOP/releases/download/V1.0/ArceusX.lite.by.Suphawat.2_2.737.1584.apk"
  "https://github.com/suphawatinf/INFINITESHOP/releases/download/V1.0/ArceusX.lite.by.Suphawat.3_2.737.1584.apk"
  "https://github.com/suphawatinf/INFINITESHOP/releases/download/V1.0/ArceusX.lite.by.Suphawat.4_2.737.1584.apk"
  "https://github.com/suphawatinf/INFINITESHOP/releases/download/V1.0/ArceusX.lite.by.Suphawat.5_2.737.1584.apk"
  "https://github.com/suphawatinf/INFINITESHOP/releases/download/V1.0/ArceusX.lite.by.Suphawat.6_2.737.1584.apk"
  "https://github.com/suphawatinf/INFINITESHOP/releases/download/V1.0/ArceusX.lite.by.Suphawat.7_2.737.1584.apk"
  "https://github.com/suphawatinf/INFINITESHOP/releases/download/V1.0/ArceusX.lite.by.Suphawat.8_2.737.1584.apk"
)

# ==========================================
# 7. เริ่มรันระบบหลัก
# ==========================================
check_password

while true; do
    clear
    stty sane 2>/dev/null
    echo -e "${C_CYAN}╔════════════════════════════════════════╗${C_RESET}"
    echo -e "${C_CYAN}║${C_RESET}              ${C_YELLOW}INFINITE SHOP${C_RESET}             ${C_CYAN}║${C_RESET}"
    echo -e "${C_CYAN}╠════════════════════════════════════════╣${C_RESET}"
    echo -e "${C_CYAN}║${C_RESET} 👑 ${C_WHITE}Dev${C_RESET}  : $OWNER_NAME"
    echo -e "${C_CYAN}║${C_RESET} 💬 ${C_WHITE}Disc${C_RESET} : $DISCORD_LINK"
    echo -e "${C_CYAN}╠════════════════════════════════════════╣${C_RESET}"
    echo -e "${C_CYAN}║${C_RESET} 📱 ${C_GREEN}OS${C_RESET}   : Android $OS_VER | $ARCH"
    echo -e "${C_CYAN}║${C_RESET} 💾 ${C_GREEN}MEM${C_RESET}  : RAM $RAM_GB | ROM $ROM_INFO"
    echo -e "${C_CYAN}╚════════════════════════════════════════╝${C_RESET}"
    
    echo -e "${CR}  ${C_PURPLE}[1]${C_RESET} Delta        (${C_GREEN}${#DELTA_APPS[@]}${C_RESET} Apps)"
    echo -e "${CR}  ${C_PURPLE}[2]${C_RESET} Delta lite   (${C_GREEN}${#DELTA_LITE_APPS[@]}${C_RESET} Apps)"
    echo -e "${CR}  ${C_PURPLE}[3]${C_RESET} ArceusX      (${C_GREEN}${#ARCEUS_NORMAL_APPS[@]}${C_RESET} Apps)"
    echo -e "${CR}  ${C_PURPLE}[4]${C_RESET} ArceusX lite (${C_GREEN}${#ARCEUS_LITE_APPS[@]}${C_RESET} Apps)"
    echo -e "${CR}  ${C_RED}[0] ออกจากระบบ${C_RESET}"
    echo -e "${CR}${C_CYAN} ----------------------------------------${C_RESET}"
    echo -ne "${CR}${C_GREEN}🎯 เลือกหมวดหมู่ที่ต้องการ: ${C_RESET}"
    read MAIN_CHOICE
    echo ""

    case $MAIN_CHOICE in
        1) process_selection "Delta" "${DELTA_APPS[@]}" ;;
        2) process_selection "Delta lite" "${DELTA_LITE_APPS[@]}" ;;
        3) process_selection "ArceusX" "${ARCEUS_NORMAL_APPS[@]}" ;;
        4) process_selection "ArceusX lite" "${ARCEUS_LITE_APPS[@]}" ;;
        0) break ;;
        *) 
            echo -e "${CR}${C_RED}[!] กรุณาเลือกตัวเลขให้ถูกต้อง${C_RESET}" 
            sleep 1
            ;;
    esac
done

stty sane 2>/dev/null
clear
echo -e "${C_CYAN}╔════════════════════════════════════════╗${C_RESET}"
echo -e "${C_CYAN}║${C_RESET}         ${C_GREEN}✨ ออกจากระบบเรียบร้อย ✨${C_RESET}        ${C_CYAN}║${C_RESET}"
echo -e "${C_CYAN}╚════════════════════════════════════════╝${C_RESET}"
echo ""
