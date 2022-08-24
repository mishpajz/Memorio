# Memorio

Memorio is a journal app for iOS.

The app is completely written in Swift, with UI created in SwiftUI.

## About

Memorio was created by [me](https://github.com/mishpajz) in 2020. It was originally released on the App Store, but has since been deprecated and pulled.

Since then I have decided to make the source code available. Submission of any fork of Memorio to AppStore is prohibited.

Ⓒ Michal Dobes

## Features

<p align="center">
<img src="https://github.com/mishpajz/Memorio/blob/development/Assets/logo.png" width=120>
</p>

<p align="center">
Memorio, a new take on diary.
Preserve your precious moments.
</p>

Memorio is a diary app that allows you to store Memories (text, pictures, videos, activities, feelings, weather) in a calendar diary, and play them back. The Memories app will remind you after a given time.

Features:
- Quickly create multiple types of entries: photo/video, text, location, feeling, weather, activity
- Remember your Memories using Rewind.
- Password protection.
- See all your Memories in a calendar.

### Screenshots

##### iPhone
<p align="left">
<img src="https://github.com/mishpajz/Memorio/blob/development/Assets/iPhoneScreenshots/1.jpg" width=140>
<img src="https://github.com/mishpajz/Memorio/blob/development/Assets/iPhoneScreenshots/2.jpg" width=140>
<img src="https://github.com/mishpajz/Memorio/blob/development/Assets/iPhoneScreenshots/3.jpg" width=140>
<img src="https://github.com/mishpajz/Memorio/blob/development/Assets/iPhoneScreenshots/4.jpg" width=140>
<img src="https://github.com/mishpajz/Memorio/blob/development/Assets/iPhoneScreenshots/5.jpg" width=140>
<img src="https://github.com/mishpajz/Memorio/blob/development/Assets/iPhoneScreenshots/6.jpg" width=140>
</p>

##### iPad
<p align="left">
<img src="https://github.com/mishpajz/Memorio/blob/development/Assets/iPadScreenshots/1.jpg" width=140>
<img src="https://github.com/mishpajz/Memorio/blob/development/Assets/iPadScreenshots/2.jpg" width=140>
<img src="https://github.com/mishpajz/Memorio/blob/development/Assets/iPadScreenshots/3.jpg" width=140>
<img src="https://github.com/mishpajz/Memorio/blob/development/Assets/iPadScreenshots/4.jpg" width=140>
<img src="https://github.com/mishpajz/Memorio/blob/development/Assets/iPadScreenshots/5.jpg" width=140>
<img src="https://github.com/mishpajz/Memorio/blob/development/Assets/iPadScreenshots/6.jpg" width=140>
</p>

## Implementation

Technological challenges:
- Created custom camera, which allows for taking photos or videos and integrates into SwiftUI.
- Created custom player, for simple Instagram Story-like control.
- Enabled Snapchat-like adding text to photos and videos using AVFoundation and CoreGraphics.
- Fetched current weather using OpenWeather API.
- Converted MapView and TextView into SwiftUI component.
- Implemented persistent data storage using CoreData.
- Add SiriIntents for creating new Memories.
- Implemented an in-app purchase that unlocks an unlimited number of Memories per week (otherwise limited) -> Memorio+.
- Made app lock using PIN or FaceID in SwiftUI.
- Created custom SwiftUI calendar.

Dependencies:
  [KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess) and [SwiftyStoreKit](https://github.com/bizz84/SwiftyStoreKit).
