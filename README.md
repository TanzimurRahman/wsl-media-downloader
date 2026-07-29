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
## Quick Access Setup

To make using this tool more convenient, you can set up quick access shortcuts on your Windows desktop and inside your web browser. Follow the instructions below based on your preference.

### 1. Pinning to the Windows Taskbar

You can create a dedicated shortcut for the tool and pin it directly to your Windows taskbar for one-click access:

1. **Create a Shortcut:** Right-click anywhere on your Windows Desktop, select **New**, and then click **Shortcut**.
2. **Set the Target:** Browse for the tool's executable or batch file, select it, and click **Next**.
3. **Name the Shortcut:** Give your shortcut a recognizable name and click **Finish**.
4. **Customize the Icon (Optional):** Right-click the new shortcut, go to **Properties**, click **Change Icon**, and select a custom icon. Click **Apply** and **OK**.
5. **Pin to Taskbar:** Finally, right-click the shortcut on your desktop and select **Pin to taskbar** (or simply drag and drop the shortcut onto your taskbar). You can now safely delete the desktop shortcut if you prefer a clean workspace.

### 2. Adding the Downloader to Browser Bookmarks (Bookmarklet)

For quick downloads directly from your web browser, you can add the downloader script to your Bookmarks/Favorites bar:

1. **Show the Bookmarks Bar:** Ensure your browser's bookmarks bar is visible (usually `Ctrl + Shift + B` on Windows).
2. **Create a New Bookmark:** Right-click anywhere on the empty space of the bookmarks bar and select **Add Page** or **Add Bookmark**.
3. **Configure the Bookmark:**
   - **Name:** Enter a memorable name (e.g., "Run Downloader").
   - **URL/Location:** Paste your specific downloader URL or JavaScript payload into the URL field. 
4. **Save:** Click **Save**. 
5. **Usage:** Whenever you are on a page where you want to trigger the downloader, simply click this new bookmark in your browser bar.
