#  WSL Media Downloader

A high-speed, multi-threaded universal media downloader built on top of WSL (Ubuntu), `yt-dlp`, `aria2`, `deno`, and `zsh`. Features a Nothing OS-inspired terminal interface, browser bookmarklet 1-click integration, dynamic YouTube challenge solvers, and bulk queueing capabilities.

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

## 🔑 Authentication & Cookie Support

For sites that require account logins (such as **Instagram**, **Facebook**, or **Age-Restricted YouTube videos**), the script automatically detects and loads a `cookies.txt` file.

### How to set up cookies:
1. Install the browser extension **Get cookies.txt LOCALLY** (Chrome / Firefox / Edge).
2. Log into the target site (e.g., Instagram) in your browser.
3. Click the extension icon and click **Export / Download** to save `cookies.txt`.
4. Place `cookies.txt` directly into your output directory (`Downloads/Media/cookies.txt`) or your home directory (`~/cookies.txt`).

> **Note:** `.gitignore` is pre-configured to ignore `cookies.txt` so your private session tokens are **never** accidentally pushed to GitHub.
