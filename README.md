<div align="center">
  <img src="https://github.com/user-attachments/assets/1ab3a800-1245-4d89-b3aa-9d2e0e646069" alt="title">
  <br><br>
  <a href="https://apps.apple.com/in/app/calcontrol/id6692630915"><img src="https://img.shields.io/badge/release-v1.1.1-blue" alt="App Release Version"></a>
  <a href="https://apps.apple.com/in/app/calcontrol/id6692630915"><img src="https://img.shields.io/badge/platform-iOS-green" alt="Platform iOS"></a>
  <a href="https://github.com/Eva0306/CalControl"><img src="https://img.shields.io/badge/language-Swift-orange" alt="Language Swift"></a>
  <a href="https://raw.githubusercontent.com/Eva0306/CalControl/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-black" alt="MIT License"></a>
  <br><br>
  <a> CalControl+ 是一款健康管理應用程式，幫助你輕鬆記錄每日卡路里攝取、管理健康狀況，並將資料以視覺畫圖表呈現</a>
  <br><br>
  <div>
    <a href="#中文版本">中文版本</a> |
    <a href="#english-version">English Version</a>
  </div>
</div>

<h2 id="中文版本">中文版本</h2>
<p>以下中文版本的內容。</p>

## 功能
- 依據使用者個人數據規劃目標
- 記錄每日食物攝取
- 統計紀錄數據並視覺化圖表
- 使用 CoreML 技術辨識食物，以及 Vision 框架進行營養標示的文字辨識

## 安裝
1. 下載應用程式(可直接開始使用，不需以下配置)

   <div style="display: flex; align-items: center; gap: 30px;">
     <a href="https://apps.apple.com/in/app/calcontrol/id6692630915">
       <img src="https://github.com/user-attachments/assets/f54f0a9d-28c8-4574-85a0-7427ecc621ff" alt="MyProject Frame 2" height="40">
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

---

<h2 id="english-version">English Version</h2>
<p>CalControl+ is a health management application that helps you easily track daily calorie intake, manage your health, and visualize data through charts.</p>

## Features
- Plan goals based on user's personal data
- Record daily food intake
- Generate statistical reports and visualize data in charts
- Use CoreML for food recognition and Vision framework for nutritional label text recognition

## Installation
1. Download the app (can be used directly, no configuration required)

   <div style="display: flex; align-items: center; gap: 30px;">
     <a href="https://apps.apple.com/in/app/calcontrol/id6692630915">
       <img src="https://github.com/user-attachments/assets/f54f0a9d-28c8-4574-85a0-7427ecc621ff" alt="MyProject Frame 2" height="40">
   </a>
   <a href="https://apps.apple.com/in/app/calcontrol/id6692630915">
       <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="Demo of the Nextcloud iOS files app" height="40">
   </a>
   </div>

2. Clone this project
   ```bash
   git clone https://github.com/Eva0306/CalControl.git

3. Configure the API Key
   - In the CalControl project, you will find an `APIKey-Sample.plist` file in the `APIKey` folder, which serves as a sample.
   - When you first open the project and build it, an `APIKey.plist` file will automatically be created in that folder.
   - Manually place this `APIKey.plist` in the project and replace the Demo strings in the value fields with `YOUR-API-KEY`.
   - Alternatively, modify the source code.
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
     > Please replace YOUR_GOOGLE_TRANSLATION_API_KEY with your own API key obtained from Google Cloud Translation.
     > Replace YOUR_EDAMAM_API_KEY with your API key from EDAMAM API.

4. The project uses Google Firebase to upload data
   - This project uses Firebase Firestore to store data, so you need to configure the `GoogleService-Info.plist` file.
   - Log in to Firebase Console, select your project (or create a new one if you don't have one).
   - Go to "Project Settings" and select "iOS App", then follow the prompts to add the app (if not added already).
   - Download the generated `GoogleService-Info.plist` file and place it in your Xcode project directory.
  
## Usage

- After launching the app, sign in using `Sign in with Apple` and fill in the basic information.

- Tap the "+" button in the center of the screen to add a new food record.

- Three simple ways to record your meals:
  - Select from the photo album
  - Take a photo
  - Text input: You can tap the icon in the top right corner ![takeoutbag and cup and straw](https://github.com/user-attachments/assets/26266d4e-86f5-4aff-aad1-9f6aec129315) to save frequently used items.

- After capturing/selecting a photo, choose to recognize the food or the nutritional label.

- The system will automatically sync the data on the main screen, and the records will be displayed in the appropriate meal section.

- **Note**: When using the app for the first time, ensure that you allow the app to access Health data (Apple Health) so that your activity records can be synced automatically.

## Screenshots

<ul style="text-align: center; list-style-position: inside; margin-top: 5px; margin-bottom: 5px;">
    <li>The main screen displays daily analysis data, while the Dashboard shows weekly analysis statistics</li>
</ul>
<div style="display: flex; justify-content: flex-start; gap: 20px; margin-bottom: 10px;">
    <img src="https://github.com/user-attachments/assets/10e2705e-5e9c-4c84-bfe4-db160429d161" alt="Simulator Screenshot - 1" width="25%">
    <img src="https://github.com/user-attachments/assets/84ca0d1d-0bd6-4761-b054-d41d7dadce32" alt="Simulator Screenshot - 3" width="25%">
</div>
<br><br>
<ul style="text-align: center; font-weight: bold; margin-top: 5px; margin-bottom: 5px;">
    <li>Meal records: Choose meal time, record method, and nutritional analysis display
</ul>
<div style="display: flex; justify-content: center; gap: 10px; margin-bottom: 10px;">
    <img src="https://github.com/user-attachments/assets/48c2e65b-925f-441b-adf8-32d4a9bfb554" alt="Simulator Screenshot - 2" width="25%">
    <img src="https://github.com/user-attachments/assets/a34185b6-3f99-4337-9c6e-e0f7a339fd8d" alt="Simulator Screenshot - 4" width="25%">
    <img src="https://github.com/user-attachments/assets/6fe8a3c5-1a94-4133-a74f-00634d12970a" alt="Simulator Screenshot - 5" width="25%">
</div>
<br><br>
<ul style="text-align: center; font-weight: bold; margin-top: 5px; margin-bottom: 5px;">
    <li>Friends and personal settings pages
</ul>
<div style="display: flex; justify-content: center; gap: 20px; margin-bottom: 10px;">
    <img src="https://github.com/user-attachments/assets/17525c4f-7d65-4d9a-862c-8793f2cc600e" alt="Simulator Screenshot - 7" width="25%">
    <img src="https://github.com/user-attachments/assets/e0b10f1e-1f3e-4b67-9041-ac677e32cf09" alt="Simulator Screenshot - 6" width="25%">
</div>

## License
This project is licensed under the [MIT License](https://raw.githubusercontent.com/Eva0306/CalControl/main/LICENSE).

## Contact
If you have any questions, please contact us at: [eva890306@gmail.com](mailto:eva890306@gmail.com)
