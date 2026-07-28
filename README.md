#  WSL Media Downloader

A high-speed, multi-threaded universal media downloader built on top of WSL (Ubuntu), `yt-dlp`, `aria2`, `deno`, and `zsh`. Features a macOS-inspired terminal interface, browser bookmarklet 1-click integration, dynamic YouTube challenge solvers, and bulk queueing capabilities.

## ⚡ Features
- **Multi-threaded Acceleration:** Uses `aria2c` with 8 parallel connections for maximum bandwidth speeds.
- **Dynamic JS Runtime:** Leverages `deno` + `yt-dlp-ejs` to resolve YouTube signature challenges smoothly.
- **1-Click Browser Integration:** Launch downloads directly from your browser via a custom `ytdl://` web protocol.
- **Bulk Queue Support:** Batch paste single or multiple links directly into the terminal UI.
- **Universal Site Support:** YouTube, Twitter/X, Instagram, TikTok, Reddit, Twitch, and 1,000+ other platforms.
- **Direct File Bridge:** Automatically routes downloaded media straight into Windows `Downloads/Media`.

## 🚀 Setup Instructions

### 1. WSL Dependencies
Inside your WSL (Ubuntu) terminal, install required tools:
```bash
sudo apt update && sudo apt install aria2 unzip curl git -y
curl -fsSL [https://deno.land/install.sh](https://deno.land/install.sh) | sh
pip3 install -U "yt-dlp[default]"
