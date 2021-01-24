

# Fable

## Installation

1. Install macOS package manager - [Homebrew](https://brew.sh/)
```
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install | ruby
```
2. Install Ruby dependencies - [Cocoapods](https://cocoapods.org/), [Bundler](https://bundler.io/)
```
sudo gem install cocoapods
sudo gem install bundler
```
3. Install Swift developer tools - [Sourcery](https://github.com/krzysztofzablocki/Sourcery), [Xcodegen](https://github.com/yonaskolb/XcodeGen), [Swiftformat](https://github.com/nicklockwood/SwiftFormat)
```
brew install sourcery
brew install xcodegen
brew install swiftformat
```

## Build the project

We use a Makefile to automate our developer process. It's just a wrapper for our scripts. Run this command to generate the project. 
```
make
```
This calls the required scripts to generate our xcworkspace with the given
configurations we want found in our `project.yml` file.

## Deploy to TestFlight
There are two main ways to create a Testflight build. The first is a manual build, which is done through Xcode. The second is using [Fastlane](https://fastlane.tools/), a set of tools that helps with iOS automation.

For each of these cases, you need to get the iOS Distribution Certificate.
This can be retrieved by asking an existing certificate holder to export it.
Once you click on the exported certificate and add it to the keychain,
you will be able to create builds for the App Store/Testflight.

### Manual Build
This method is built into Xcode so it requires minimal setup.

1. Increment the build number by 1
2. Select **Fable** in the schemes section
3. Switch to **Generic iOS Device**
4. Go to **Product -> Clean Build Folder**
5. Go to **Product -> Archive**
6. Once Archive is done, go to **Window -> Organizer**
7. Click on the build that was create and click **Distribute App**
8. Make sure **iOS App Store** is selected and click next
9. Make sure **Upload** is selected and click next
10. Make sure to **Uncheck** the **Upload your app's symbols to receive symbolicated reports from Apple** button and hit next
11. Make sure **Automatically Manage Signing** is selected and click next 
12. When you see the summary, click **Upload**
13. Once the app is uploaded, it takes a few minutes to process on Apple's servers.
14. Go to [App Store Connect](https://appstoreconnect.apple.com/)
15. Sign in
16. Go to **My Apps**
17. Click on **Fable - Interactive Stories**
18. Click on **Testflight**
19. Click on **iOS**
20. Click on the latest build number your created
21. Click the **+** button
22. Add the changes that were made in the build and hit **Submit**
23. **Done**

### Installing Fastlane

To install fastlane, you can do either of the following

```
# Using RubyGems
sudo gem install fastlane -NV

# Alternatively using Homebrew
brew cask install fastlane
```

This command increments Fable's build number, archives, then uploads to TestFlight.
```
bundle exec fastlane beta
```

## CI/CD Pipeline
The main idea of a CI Server is to have a seperate server that can run inspections, tests, and automatically build and deploy.

The current instructions in Fastlane for our server includes
1. Switch branches if needed
2. Ensure the git repository is clean
3. Increment the build number by 1
4. Build via Fastlane Gym
5. Grab the latest 15 commit messages
6. Save the messages to a textfile
7. Add a git tag to the current commit
8. Commit the updated incremented plist file
9. Connect the changelog to Fastlane Pilot
10. Upload via Fastlane Pilot
11. Run this every 7 days