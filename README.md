<div align="center">
  <img src="https://github.com/user-attachments/assets/b48cb18b-049d-4fb5-b15d-e69e3202b5e9" alt="title">
  <br><br>
  <a href="https://apps.apple.com/in/app/calcontrol/id6692630915"><img src="https://img.shields.io/badge/release-v1.1.1-blue" alt="App Release Version"></a>
  <a href="https://apps.apple.com/in/app/calcontrol/id6692630915"><img src="https://img.shields.io/badge/platform-iOS-green" alt="Platform iOS"></a>
  <a href="https://github.com/Eva0306/CalControl"><img src="https://img.shields.io/badge/language-Swift-orange" alt="Language Swift"></a>
  <a href="https://raw.githubusercontent.com/Eva0306/CalControl/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-black" alt="MIT License"></a>
  <br><br>
  <a> CalControl+ 是一款健康管理應用程式，幫助你輕鬆記錄每日卡路里攝取、管理健康狀況，並將資料以視覺畫圖表呈現</a>
</div>


## 功能
- 依據使用者個人數據規劃目標
- 記錄每日食物攝取
- 統計紀錄數據並視覺化圖表
- 使用 CoreML 技術辨識食物，以及 Vision 框架進行營養標示的文字辨識

## 安裝
1. 下載應用程式(可直接開始使用，不需以下配置)

   <div style="display: flex; align-items: center; gap: 30px;">
     <a href="https://apps.apple.com/in/app/calcontrol/id6692630915">
       <img src="https://github.com/user-attachments/assets/2eba769c-ce2e-4d75-8d71-7dd497846ec9" alt="MyProject Frame 2" height="40">
   </a>
   <a href="https://apps.apple.com/in/app/calcontrol/id6692630915">
       <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="Demo of the Nextcloud iOS files app" height="40">
   </a>
   </div>

2. 克隆此專案
   ```bash
   git clone https://github.com/Eva0306/CalControl.git
   ```
3. 配置 API Key
   
   - 在 CalControl 專案中，`APIKey` 的資料夾裡可以看到一個 `APIKey-Sample.plist`，這是範例檔。
   - 第一次開啟專案直接 Build 專案會自動建立 `APIKey.plist` 至該資料夾。
   - 手動將此 `APIKey.plist` 放進專案中並將對應 value 中 Demo 字樣改為 `YOUR-API-KEY`。
   - 或使用 Soruce Code 進行更改
     
     APIKey.plist
     ```xml
     <?xml version="1.0" encoding="UTF-8"?>
     <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
     <plist version="1.0">
     <dict>
        <key>translationAPIKey</key>
        <string>YOUR_GOOGLE_TRANSLATION_API_KEY</string>
        <key>nutritionAPIKey</key>
        <string>YOUR_EDAMAM_API_KEY</string>
     </dict>
     </plist>
     ```
     > 請將 YOUR_GOOGLE_TRANSLATION_API_KEY 替換成你從 [Google Cloud Translation](https://cloud.google.com/translate) 獲得的 API Key。
     > 將 YOUR_EDAMAM_API_KEY 替換成你從 [EDAMAM API](https://developer.edamam.com/edamam-nutrition-api) 獲得的 API Key。

4. 專案使用 Google Firebase 上傳資料

   - 本專案使用 Firebase Firestore 來存儲數據，因此需要配置 `GoogleService-Info.plist` 檔案。
   - 登入 [Firebase Console](https://console.firebase.google.com/)，選擇你的專案（如果還沒有專案，請創建一個新的專案）。
   - 進入「專案設定」並選擇「iOS 應用程式」，然後按照提示添加應用程式（如果還未添加）。
   - 下載生成的 `GoogleService-Info.plist` 檔案，並將其放置在你的 Xcode 專案目錄中。

## 使用方式

- 開啟應用程式後，使用 `Sign in with Apple` 進行登入，並填入基本資料。
  
- 點擊畫面下方正中間「＋」新增飲食紀錄。
  
- 三種方式簡單紀錄飲食：
  - 相簿選取
  - 即時拍照
  - 文字輸入：
    可點選右上角 ![takeoutbag and cup and straw](https://github.com/user-attachments/assets/26266d4e-86f5-4aff-aad1-9f6aec129315) 儲存常用項目。
  
- 拍攝/選擇完照片可選擇要辨識食物或是營養標示。
  
- 系統會自動同步主畫面數據及紀錄會呈現於對應餐期欄位中。
  
- **注意**：首次使用應用程式時，請確保允許應用程式訪問健康數據 (Apple Health)，才能自動同步你的運動紀錄。

## 螢幕截圖

<ul style="text-align: center; list-style-position: inside; margin-top: 5px; margin-bottom: 5px;">
    <li>主畫面為日分析數據呈現， Dashboard 則是週分析數據統計</li>
</ul>
<div style="display: flex; justify-content: flex-start; gap: 20px; margin-bottom: 10px;">
    <img src="https://github.com/user-attachments/assets/10e2705e-5e9c-4c84-bfe4-db160429d161" alt="Simulator Screenshot - 1" width="25%">
    <img src="https://github.com/user-attachments/assets/84ca0d1d-0bd6-4761-b054-d41d7dadce32" alt="Simulator Screenshot - 3" width="25%">
</div>
<br><br>
<ul style="text-align: center; font-weight: bold; margin-top: 5px; margin-bottom: 5px;">
    <li>飲食紀錄：選擇餐期、紀錄方式、營養分析呈現
</ul>
<div style="display: flex; justify-content: center; gap: 10px; margin-bottom: 10px;">
    <img src="https://github.com/user-attachments/assets/48c2e65b-925f-441b-adf8-32d4a9bfb554" alt="Simulator Screenshot - 2" width="25%">
    <img src="https://github.com/user-attachments/assets/a34185b6-3f99-4337-9c6e-e0f7a339fd8d" alt="Simulator Screenshot - 4" width="25%">
    <img src="https://github.com/user-attachments/assets/6fe8a3c5-1a94-4133-a74f-00634d12970a" alt="Simulator Screenshot - 5" width="25%">
</div>
<br><br>
<ul style="text-align: center; font-weight: bold; margin-top: 5px; margin-bottom: 5px;">
    <li>好友及個人設置頁面
</ul>
<div style="display: flex; justify-content: center; gap: 20px; margin-bottom: 10px;">
    <img src="https://github.com/user-attachments/assets/17525c4f-7d65-4d9a-862c-8793f2cc600e" alt="Simulator Screenshot - 7" width="25%">
    <img src="https://github.com/user-attachments/assets/e0b10f1e-1f3e-4b67-9041-ac677e32cf09" alt="Simulator Screenshot - 6" width="25%">
</div>

## 授權
本專案採用 [MIT License](https://raw.githubusercontent.com/Eva0306/CalControl/main/LICENSE) 授權。

## 聯絡方式
有任何問題，請聯絡我們：[eva890306@gmail.com](mailto:eva890306@gmail.com)
