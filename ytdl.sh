#!/bin/bash

# --- Silent Auto-Update Check in Background ---
yt-dlp -U &>/dev/null &

# --- Force PATH for non-interactive launches ---
export PATH="$HOME/.deno/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# --- macOS SF-Style Color Palette ---
BLUE='\033[38;5;39m'
GRAY='\033[38;5;243m'
WHITE='\033[1;37m'
GREEN='\033[38;5;78m'
YELLOW='\033[38;5;221m'
PURPLE='\033[38;5;141m'
RED='\033[38;5;203m'
BOLD='\033[1m'
NC='\033[0m'

# --- Auto-detect Windows Downloads Path ---
WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
if [ -z "$WIN_USER" ]; then
    DOWNLOAD_DIR="$HOME/Downloads/Media"
else
    DOWNLOAD_DIR="/mnt/c/Users/$WIN_USER/Downloads/Media"
fi

mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR" || exit

# --- Universal Speed & Security Flags ---
FLAGS="-N 8 --remote-components ejs:npm --js-runtimes deno"
if [ -f "$DOWNLOAD_DIR/cookies.txt" ]; then
    FLAGS="$FLAGS --cookies $DOWNLOAD_DIR/cookies.txt"
elif [ -f "$HOME/cookies.txt" ]; then
    FLAGS="$FLAGS --cookies $HOME/cookies.txt"
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

# --- macOS Header Rendering ---
render_header() {
    clear
    echo -e "${BLUE}╭───────────────────────────────────────────────────────────────────╮${NC}"
    echo -e "${BLUE}│${NC} ${BOLD}${WHITE}  Media Downloader${NC} ${GRAY}│ WSL macOS Engine${NC}                           ${BLUE}│${NC}"
    echo -e "${BLUE}├───────────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${BLUE}│${NC} ${GRAY}Output Folder:${NC} ${YELLOW}$DOWNLOAD_DIR${NC}"
    
    if [[ "$FLAGS" == *"--cookies"* ]]; then
        echo -e "${BLUE}│${NC} ${GRAY}Cookies Status:${NC} ${GREEN}✔ Loaded cookies.txt${NC}"
    else
        echo -e "${BLUE}│${NC} ${GRAY}Cookies Status:${NC} ${RED}✘ No cookies.txt found${NC}"
    fi

    if command -v deno &> /dev/null; then
        echo -e "${BLUE}│${NC} ${GRAY}JS Engine:${NC}      ${GREEN}✔ Deno Active${NC}"
    else
        echo -e "${BLUE}│${NC} ${GRAY}JS Engine:${NC}      ${RED}✘ Deno Inactive${NC}"
    fi

    echo -e "${BLUE}│${NC} ${GRAY}Acceleration:${NC}   ${PURPLE}⚡ Aria2 Multi-threaded (8x Speeds)${NC}"
    
    if [ ${#URL_LIST[@]} -eq 1 ]; then
        echo -e "${BLUE}│${NC} ${GRAY}Target Link:${NC}    ${WHITE}${URL_LIST[0]:0:50}...${NC}"
    elif [ ${#URL_LIST[@]} -gt 1 ]; then
        echo -e "${BLUE}│${NC} ${GRAY}Target Queue:${NC}   ${PURPLE}${#URL_LIST[@]} links queued for download${NC}"
    fi
    echo -e "${BLUE}╰───────────────────────────────────────────────────────────────────╯${NC}"
    echo ""
}

render_header

# --- Prompt for Links if Executed Manually or Bulk ---
if [ ${#URL_LIST[@]} -eq 0 ]; then
    echo -e "${BOLD}${WHITE}Paste Link(s)${NC} ${GRAY}(paste a single link, space-separated links, or type 'bulk'):${NC}"
    read -rp "➜ " INPUT_LINK
    
    if [ "$INPUT_LINK" = "bulk" ]; then
        echo -e "\n${PURPLE}Bulk Mode Active.${NC} ${GRAY}Paste links one per line. Press Enter on an empty line when finished:${NC}"
        while true; do
            read -rp "  Link #${#URL_LIST[@]}: " BULK_LINE
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
    echo -e "${RED}Error: No links provided. Exiting.${NC}"
    exit 1
fi

render_header

# --- Options Menu ---
echo -e "${BOLD}${WHITE}Select Action:${NC}"
echo -e "  ${BLUE}1)${NC} ${WHITE}Best Quality Video${NC} ${GRAY}(Max Resolution / Multi-threaded)${NC}"
echo -e "  ${BLUE}2)${NC} ${WHITE}1080p Video${NC} ${GRAY}(Balanced / Storage Saver)${NC}"
echo -e "  ${BLUE}3)${NC} ${WHITE}720p Video${NC} ${GRAY}(Fast Download)${NC}"
echo -e "  ${BLUE}4)${NC} ${WHITE}Audio Only${NC} ${GRAY}(MP3 320kbps + Album Art)${NC}"
echo -e "  ${BLUE}5)${NC} ${WHITE}Audio Only${NC} ${GRAY}(High Quality M4A / AAC)${NC}"
echo -e "  ${BLUE}6)${NC} ${WHITE}Video + Subtitles${NC} ${GRAY}(Auto-embed Subtitles)${NC}"
echo -e "  ${BLUE}7)${NC} ${WHITE}Download Playlist / Channel${NC} ${GRAY}(Batch Processing)${NC}"
echo -e "  ${BLUE}8)${NC} ${PURPLE}Add More Links to Bulk Queue${NC}"
echo ""
read -rp "Option [1-8]: " choice

if [ "$choice" = "8" ]; then
    echo -e "\n${PURPLE}Paste additional links (one per line, empty line to finish):${NC}"
    while true; do
        read -rp "  Link #${#URL_LIST[@]}: " BULK_LINE
        [ -z "$BULK_LINE" ] && break
        URL_LIST+=("$BULK_LINE")
    done
    render_header
    echo -e "${BOLD}${WHITE}Select Action for all ${#URL_LIST[@]} queued items:${NC}"
    echo -e "  ${BLUE}1)${NC} Best Quality Video"
    echo -e "  ${BLUE}2)${NC} 1080p Video"
    echo -e "  ${BLUE}3)${NC} 720p Video"
    echo -e "  ${BLUE}4)${NC} Audio Only (MP3)"
    echo -e "  ${BLUE}5)${NC} Audio Only (M4A)"
    echo -e "  ${BLUE}6)${NC} Subtitled Video"
    echo -e "  ${BLUE}7)${NC} Playlist Processing"
    echo ""
    read -rp "Option [1-7]: " choice
fi

echo ""
echo -e "${GREEN}⚡ Acceleration Engine Active. Starting downloads...${NC}\n"

count=1
total=${#URL_LIST[@]}

# --- Download Loop ---
for target_url in "${URL_LIST[@]}"; do
    echo -e "${BLUE}╭─ [ Processing $count of $total ] ─────────────────────────────────────────╮${NC}"
    echo -e "  ${GRAY}URL:${NC} $target_url"
    echo -e "${BLUE}╰──────────────────────────────────────────────────────────────────╯${NC}"

    case "$choice" in
        1)
            yt-dlp $FLAGS --downloader aria2c --downloader-args "aria2c:-j 8 -s 8 -x 8 -k 1M" \
                   --embed-thumbnail --embed-metadata -o "%(title)s [%(resolution)s].%(ext)s" "$target_url"
            ;;
        2)
            yt-dlp $FLAGS -f "bestvideo[height<=1080]+bestaudio/best[height<=1080]" \
                   --downloader aria2c --downloader-args "aria2c:-j 8 -s 8 -x 8 -k 1M" \
                   --embed-thumbnail --embed-metadata -o "%(title)s [1080p].%(ext)s" "$target_url"
            ;;
        3)
            yt-dlp $FLAGS -f "bestvideo[height<=720]+bestaudio/best[height<=720]" \
                   --downloader aria2c --downloader-args "aria2c:-j 8 -s 8 -x 8 -k 1M" \
                   --embed-thumbnail --embed-metadata -o "%(title)s [720p].%(ext)s" "$target_url"
            ;;
        4)
            yt-dlp $FLAGS -x --audio-format mp3 --audio-quality 0 \
                   --embed-thumbnail --embed-metadata -o "%(title)s.%(ext)s" "$target_url"
            ;;
        5)
            yt-dlp $FLAGS -x --audio-format m4a \
                   --embed-thumbnail --embed-metadata -o "%(title)s.%(ext)s" "$target_url"
            ;;
        6)
            yt-dlp $FLAGS --write-sub --sub-lang "en.*" --embed-subs \
                   --embed-thumbnail --embed-metadata -o "%(title)s.%(ext)s" "$target_url"
            ;;
        7)
            yt-dlp $FLAGS --yes-playlist --embed-thumbnail --embed-metadata \
                   -o "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" "$target_url"
            ;;
        *)
            yt-dlp $FLAGS --embed-thumbnail --embed-metadata "$target_url"
            ;;
    esac
    ((count++))
    echo ""
done

echo -e "${BLUE}╭───────────────────────────────────────────────────────────────────╮${NC}"
echo -e "${GREEN}│  ✔ All tasks finished! Saved to Downloads/Media                   │${NC}"
echo -e "${BLUE}╰───────────────────────────────────────────────────────────────────╯${NC}"
read -rp "Press Enter to close."
