#!/bin/bash

# --- Silent Auto-Update Check in Background ---
yt-dlp -U &>/dev/null &

# --- Force PATH for non-interactive launches ---
export PATH="$HOME/.deno/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# --- Nothing OS Aesthetic Palette ---
RED='\033[38;5;196m'        # Iconic Nothing Glyph Red
WHITE='\033[1;37m'          # Stark Dot-Matrix White
GRAY='\033[38;5;244m'         # Tech Gray
DARK_GRAY='\033[38;5;238m'    # Subtle Frame Gray
BOLD='\033[1m'
NC='\033[0m'
# --- Check required tools ---
if ! command -v ffmpeg &> /dev/null; then
    echo -e "${RED}[!] WARNING: ffmpeg is not installed. Video merging and audio conversion will fail.${NC}"
    sleep 2
fi

# --- Auto-detect Windows Downloads Path ---
WIN_PROFILE=$(cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r')
if [ -n "$WIN_PROFILE" ]; then
    DOWNLOAD_DIR="$(wslpath "$WIN_PROFILE")/Downloads/Media"
else
    DOWNLOAD_DIR="$HOME/Downloads/Media"
fi

mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR" || exit

# --- Engine Configuration Arrays ---
YTDLP_ARGS=(-N 8 --remote-components ejs:npm --js-runtimes deno)
GALLERY_ARGS=()
COOKIE_FILE=""

if [ -f "$DOWNLOAD_DIR/cookies.txt" ]; then
    COOKIE_FILE="$DOWNLOAD_DIR/cookies.txt"
elif [ -f "$HOME/cookies.txt" ]; then
    COOKIE_FILE="$HOME/cookies.txt"
fi

if [ -n "$COOKIE_FILE" ]; then
    YTDLP_ARGS+=(--cookies "$COOKIE_FILE")
    GALLERY_ARGS+=(--cookies "$COOKIE_FILE")
fi

# --- URL Decoding & Sanitization ---
RAW_INPUT="$1"
URL=""

if [ -n "$RAW_INPUT" ]; then
    # Decode percent-encoded URLs passed from browser
    URL=$(python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))" "$RAW_INPUT" 2>/dev/null || echo "$RAW_INPUT")
    URL="${URL#ytdl://}"
    URL="${URL#ytdl:}"
    if [[ "$URL" =~ ^https// ]]; then URL="https://${URL#https//}";
    elif [[ "$URL" =~ ^http// ]]; then URL="http://${URL#http//}";
    elif [[ ! "$URL" =~ ^https?:// ]] && [ -n "$URL" ]; then URL="https://$URL"; fi
fi

declare -a URL_LIST=()
if [ -n "$URL" ]; then
    URL_LIST+=("$URL")
fi

# --- Nothing OS Header Rendering ---
render_header() {
    clear
    echo -e "${RED}┌───────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${RED}│${NC} ${BOLD}${WHITE}T A N Z I M   U N I V E R S A L   D O W N L O A D E R${NC}             ${RED}│${NC}"
    echo -e "${RED}├───────────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${RED}│${NC} ${GRAY}STORAGE PATH  ::${NC} ${WHITE}$DOWNLOAD_DIR${NC}"
    
    if [ -n "$COOKIE_FILE" ]; then
        echo -e "${RED}│${NC} ${GRAY}COOKIES AUTH  ::${NC} ${WHITE}[${NC}${RED}●${NC}${WHITE}] ACTIVE (cookies.txt)${NC}"
    else
        echo -e "${RED}│${NC} ${GRAY}COOKIES AUTH  ::${NC} ${GRAY}[○] NONE DETECTED${NC}"
    fi

    if command -v deno &> /dev/null; then
        echo -e "${RED}│${NC} ${GRAY}JS ENGINE     ::${NC} ${WHITE}[●] DENO ENGINE${NC}"
    else
        echo -e "${RED}│${NC} ${GRAY}JS ENGINE     ::${NC} ${GRAY}[○] INACTIVE${NC}"
    fi

    # --- PASTE THE FFMPEG CHECK HERE ---
    if command -v ffmpeg &> /dev/null; then
        echo -e "${RED}│${NC} ${GRAY}FFMPEG        ::${NC} ${WHITE}[●] INSTALLED${NC}"
    else
        echo -e "${RED}│${NC} ${GRAY}FFMPEG        ::${NC} ${RED}[○] MISSING (AUDIO/CONVERSION DISABLED)${NC}"
    fi

    echo -e "${RED}│${NC} ${GRAY}ACCELERATION  ::${NC} ${WHITE}[●] ARIA2 MULTI-THREAD (8x)${NC}"
    
    if [ ${#URL_LIST[@]} -eq 1 ]; then
        echo -e "${RED}│${NC} ${GRAY}TARGET LINK   ::${NC} ${WHITE}${URL_LIST[0]:0:48}...${NC}"
    elif [ ${#URL_LIST[@]} -gt 1 ]; then
        echo -e "${RED}│${NC} ${GRAY}QUEUE COUNT   ::${NC} ${RED}[ ${#URL_LIST[@]} LINKS QUEUED ]${NC}"
    fi
    echo -e "${RED}└───────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

render_header

# --- Prompt for Links if Executed Manually or Bulk ---
if [ ${#URL_LIST[@]} -eq 0 ]; then
    echo -e "${BOLD}${WHITE}/// INPUT LINK(S)${NC} ${GRAY}(SINGLE LINK, SPACE-SEPARATED, OR TYPE 'bulk'):${NC}"
    read -rp "► " INPUT_LINK
    
    if [ "$INPUT_LINK" = "bulk" ]; then
        echo -e "\n${RED}[ BULK MODE ACTIVE ]${NC} ${GRAY}PASTE LINKS ONE PER LINE. PRESS ENTER WHEN FINISHED:${NC}"
        while true; do
            read -rp "  LINK #${#URL_LIST[@]}: " BULK_LINE
            [ -z "$BULK_LINE" ] && break
            URL_LIST+=("$BULK_LINE")
        done
    else
        for link in $INPUT_LINK; do
            clean_link="${link#ytdl://}"
            clean_link="${clean_link#ytdl:}"
            if [[ "$clean_link" =~ ^https// ]]; then clean_link="https://${clean_link#https//}"; fi
            if [[ ! "$clean_link" =~ ^https?:// ]] && [ -n "$clean_link" ]; then clean_link="https://$clean_link"; fi
            URL_LIST+=("$clean_link")
        done
    fi
fi

if [ ${#URL_LIST[@]} -eq 0 ]; then
    echo -e "${RED}[!] ERROR: NO LINKS PROVIDED. EXITING.${NC}"
    exit 1
fi

render_header

# --- Options Menu ---
echo -e "${BOLD}${WHITE}/// SELECT ACTION:${NC}"
echo -e "  ${RED}[01]${NC} ${WHITE}BEST QUALITY VIDEO${NC}   ${GRAY}(MAX RESOLUTION / ARIA2 8x)${NC}"
echo -e "  ${RED}[02]${NC} ${WHITE}1080p BALANCED${NC}       ${GRAY}(STORAGE SAVER / 1080p MAX)${NC}"
echo -e "  ${RED}[03]${NC} ${WHITE}720p FAST${NC}            ${GRAY}(LIGHTWEIGHT / 720p MAX)${NC}"
echo -e "  ${RED}[04]${NC} ${WHITE}AUDIO ONLY (MP3)${NC}     ${GRAY}(320kbps + COVER ART)${NC}"
echo -e "  ${RED}[05]${NC} ${WHITE}AUDIO ONLY (M4A)${NC}     ${GRAY}(HIGH QUALITY AAC)${NC}"
echo -e "  ${RED}[06]${NC} ${WHITE}VIDEO + SUBTITLES${NC}    ${GRAY}(AUTO-EMBED SUBTITLES)${NC}"
echo -e "  ${RED}[07]${NC} ${WHITE}GALLERY / PHOTOS${NC}     ${GRAY}(IMAGES / CAROUSELS)${NC}"
echo -e "  ${RED}[08]${NC} ${WHITE}BATCH PLAYLIST${NC}       ${GRAY}(PLAYLIST / CHANNEL ENGINE)${NC}"
echo -e "  ${RED}[09]${NC} ${RED}EXPAND BULK QUEUE${NC}    ${GRAY}(ADD MORE LINKS)${NC}"
echo -e "  ${RED}[10]${NC} ${WHITE}UPDATE ENGINES${NC}       ${GRAY}(UPDATE YT-DLP & GALLERY-DL)${NC}"
echo -e "  ${RED}[00]${NC} ${WHITE}CANCEL${NC}               ${GRAY}(ABORT & EXIT)${NC}"
echo ""
read -rp "OPTION [00-10] ► " choice

# Handle Cancel
if [ "$choice" = "0" ] || [ "$choice" = "00" ]; then
    echo -e "\n${RED}[!] OPERATION CANCELLED BY USER. EXITING.${NC}"
    exit 0
fi

# Handle Engine Updates
if [ "$choice" = "10" ]; then
    echo -e "\n${RED}[●] UPDATING YT-DLP & GALLERY-DL ENGINES...${NC}\n"
    yt-dlp -U
    if command -v gallery-dl &>/dev/null; then
        pip3 install -U gallery-dl || gallery-dl -U
    else
        pip3 install -U gallery-dl 2>/dev/null || true
    fi
    echo -e "\n${WHITE}[●] ENGINES UPDATED SUCCESSFULLY.${NC}"
    read -rp "PRESS ENTER TO EXIT."
    exit 0
fi

# Handle Bulk Queue Expansion
if [ "$choice" = "9" ] || [ "$choice" = "09" ]; then
    echo -e "\n${RED}[ ADDING LINKS ]${NC} ${GRAY}(ONE PER LINE, ENTER TO FINISH):${NC}"
    while true; do
        read -rp "  LINK #${#URL_LIST[@]}: " BULK_LINE
        [ -z "$BULK_LINE" ] && break
        URL_LIST+=("$BULK_LINE")
    done
    render_header
    echo -e "${BOLD}${WHITE}/// SELECT ACTION FOR ALL ${#URL_LIST[@]} QUEUED ITEMS:${NC}"
    echo -e "  ${RED}[01]${NC} BEST QUALITY VIDEO"
    echo -e "  ${RED}[02]${NC} 1080p BALANCED"
    echo -e "  ${RED}[03]${NC} 720p FAST"
    echo -e "  ${RED}[04]${NC} AUDIO ONLY (MP3)"
    echo -e "  ${RED}[05]${NC} AUDIO ONLY (M4A)"
    echo -e "  ${RED}[06]${NC} VIDEO + SUBTITLES"
    echo -e "  ${RED}[07]${NC} GALLERY / PHOTOS"
    echo -e "  ${RED}[08]${NC} BATCH PLAYLIST"
    echo -e "  ${RED}[00]${NC} CANCEL"
    echo ""
    read -rp "OPTION ► " choice
    if [ "$choice" = "0" ] || [ "$choice" = "00" ]; then
        echo -e "\n${RED}[!] OPERATION CANCELLED. EXITING.${NC}"
        exit 0
    fi
fi

echo ""
echo -e "${RED}[●] ENGINE STARTING...${NC}\n"

count=1
total=${#URL_LIST[@]}

# --- Download Loop ---
for target_url in "${URL_LIST[@]}"; do
    echo -e "${RED}┌── [ TASK $count / $total ] ──────────────────────────────────────────────┐${NC}"
    echo -e "${RED}│${NC} ${GRAY}URL ::${NC} ${WHITE}$target_url${NC}"
    echo -e "${RED}└───────────────────────────────────────────────────────────────────┘${NC}"

    case "$choice" in
        1|01)
            yt-dlp "${YTDLP_ARGS[@]}" --downloader aria2c --downloader-args "aria2c:-j 8 -s 8 -x 8 -k 1M" \
                   --embed-thumbnail --embed-metadata -o "%(title)s [%(resolution)s].%(ext)s" "$target_url"
            ;;
        2|02)
            yt-dlp "${YTDLP_ARGS[@]}" -f "bestvideo[height<=1080]+bestaudio/best[height<=1080]" \
                   --downloader aria2c --downloader-args "aria2c:-j 8 -s 8 -x 8 -k 1M" \
                   --embed-thumbnail --embed-metadata -o "%(title)s [1080p].%(ext)s" "$target_url"
            ;;
        3|03)
            yt-dlp "${YTDLP_ARGS[@]}" -f "bestvideo[height<=720]+bestaudio/best[height<=720]" \
                   --downloader aria2c --downloader-args "aria2c:-j 8 -s 8 -x 8 -k 1M" \
                   --embed-thumbnail --embed-metadata -o "%(title)s [720p].%(ext)s" "$target_url"
            ;;
        4|04)
            yt-dlp "${YTDLP_ARGS[@]}" -x --audio-format mp3 --audio-quality 0 \
                   --embed-thumbnail --embed-metadata -o "%(title)s.%(ext)s" "$target_url"
            ;;
        5|05)
            yt-dlp "${YTDLP_ARGS[@]}" -x --audio-format m4a \
                   --embed-thumbnail --embed-metadata -o "%(title)s.%(ext)s" "$target_url"
            ;;
        6|06)
            yt-dlp "${YTDLP_ARGS[@]}" --write-sub --sub-lang "en.*" --embed-subs \
                   --embed-thumbnail --embed-metadata -o "%(title)s.%(ext)s" "$target_url"
            ;;
        7|07)
            if command -v gallery-dl &>/dev/null; then
                gallery-dl "${GALLERY_ARGS[@]}" "$target_url"
            else
                yt-dlp "${YTDLP_ARGS[@]}" --write-all-thumbnails --skip-download "$target_url"
            fi
            ;;
        8|08)
            yt-dlp "${YTDLP_ARGS[@]}" --yes-playlist --embed-thumbnail --embed-metadata \
                   -o "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" "$target_url"
            ;;
        *)
            yt-dlp "${YTDLP_ARGS[@]}" --embed-thumbnail --embed-metadata "$target_url"
            ;;
    esac
    ((count++))
    echo ""
done

echo -e "${RED}┌───────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${RED}│${NC} ${WHITE}[●] PROCESS COMPLETE :: FILES SAVED TO DOWNLOADS/MEDIA${NC}              ${RED}│${NC}"
echo -e "${RED}└───────────────────────────────────────────────────────────────────┘${NC}"
read -rp "PRESS ENTER TO EXIT."
