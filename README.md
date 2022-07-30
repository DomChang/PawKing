# PawKing

<p align="center">
  <img src="https://user-images.githubusercontent.com/61193318/181259392-5b4c7c57-47f3-4b9b-8ee7-7420a15aee5f.png" width="130" height="130"/>
</p>


<p align="center">
    <a href="https://apps.apple.com/tw/app/pawking/id1630664227"><img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg"></a>
</p>

<p align="center">
	<img src="https://img.shields.io/badge/Swift-5.0-yellow.svg?style=flat">
    <img src="https://img.shields.io/badge/license-MIT-informational">
    <img src="https://img.shields.io/badge/release-v1.0.3-orange">
</p>

<p align="left">
PawKing is a social network devoted to the pets of its owners. Users can discover and connect with neighboring pets' owners, and locate friends who are walking their pets and consider joining them. <br> <b>PawKing enables users to keep in touch with their furry pals to make their pets life joyful.</b>
</p>

## Features
#### Home
- Record tracks of your daily pet walk and make some notes for memory.
- Find out friends' real-time pet walks' locations.
- Discover new users' pets that are located nearby.

<img src="https://github.com/DomChang/PawKing/blob/main/Screenshots/Track.gif" width = "200" height = "433"/> <img src="https://github.com/DomChang/PawKing/blob/main/Screenshots/Friend%20location.gif" width = "200" height = "433"/> <img src="https://github.com/DomChang/PawKing/blob/main/Screenshots/Strangers.gif" width = "200" height = "433"/>

#### Explore
- Discover photos of lovely pets from around the world.

<img src="https://github.com/DomChang/PawKing/blob/main/Screenshots/Explore.png" width = "200" height = "433"/> <img src="https://github.com/DomChang/PawKing/blob/main/Screenshots/Photo%20post.png" width = "200" height = "433"/>

#### Chat
- Keep in touch with friends through live messaging.

<img src="https://github.com/DomChang/PawKing/blob/main/Screenshots/Chat.gif" width = "200" height = "433"/>

#### Publish
- Share photos of your pets with the world.

<img src="https://github.com/DomChang/PawKing/blob/main/Screenshots/Publish.gif" width = "200" height = "433"/>

#### Profile
- Check out uploaded tracks, photos and personal profile.

<img src="https://github.com/DomChang/PawKing/blob/main/Screenshots/Profile.gif" width = "200" height = "433"/>

## Technical Highlights
- Used <b>OOP</b> and <b>MVC</b> as design pattern.
- Used <b>CLLocationManager</b> with <b>Firebase snapshot listener</b> to accomplish updating users’ location.
- Implemented <b>MapKit</b> to enable track sketching and display custom annotation views to deliver exceptional user experience.
- Used <b>Dispatch Semaphore</b> and Firebase batched writes for asynchronous background fetches and writes to ensure data delivery completed without loss.
- Built user interfaces programmatically with Auto Layout to make the application compatible for different screen sizes.
- Implemented <b>Singleton</b> to ensure that all objects access the unique model manager instance.
- Implemented Apple and e-mail authentication to facilitate sign up / sign in for users.
- Applied weak references for <b>ARC</b> and removed unnecessary Firebase listeners to avoid memory leak.
- Created diverse collectionview with <b>CompositionalLayout</b>.

## Libraries
- SwiftLint
- Lottie
- Firebase
- Kingfisher
- IQKeyboardManager
- Crashlytics

## Requirements
- Xcode 13 or later</br>
- iOS 15.0 or later</br>

## Version
- 1.0.3

## Release Notes
| Version | Notes |
| :-----: | ----- |
| 1.0.3   | Fix bugs |
| 1.0.2   | Optimize UI |
| 1.0.1   | New:  Track dashboard<br>Fix: Optimize UI and user experience |
| 1.0.0   | 	Launched in App Store |

## Contact
Dom Chang</br>
- email: <chunkaichangx@gmail.com>


## License
PawKing is released under the MIT license. See [LICENSE](./LICENSE.md) for details.
