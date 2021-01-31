

# Fable

## Installation

1. Install macOS package manager - [Homebrew](https://brew.sh/)
```bash
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install | ruby
```
2. Install Ruby dependencies - [Cocoapods](https://cocoapods.org/), [Bundler](https://bundler.io/)
```bash
sudo gem install bundler
bundle installs
```
---
**NOTE**: If `bundle install` is giving you issues, it might be a ruby versioning issue. In this case install [rbenv](https://github.com/rbenv/rbenv) and configure your ruby environment to the latest version and run `bundle install` again. 

---
3. Install Swift developer tools - [Sourcery](https://github.com/krzysztofzablocki/Sourcery), [Xcodegen](https://github.com/yonaskolb/XcodeGen), [Swiftformat](https://github.com/nicklockwood/SwiftFormat)
```bash
brew install xcodegen
brew install swiftformat
```
4. Install the XcodeGen CLI - [XCGen](https://github.com/DrewKiino/XcodeGenCLI)
```bash
cd ~ && git clone git@github.com:DrewKiino/XcodeGenCLI.git && cd XcodeGenCLI && make build
```

## First Time Setup

We use `Cocoapods` and some `SPM` to set up dependencies. Make sure you followed the above steps and then run

## Build the project

We use a Makefile to automate our developer process. It's just a wrapper for our scripts. Run this command to generate the project. 
Checkout the `Makefile` to view all other commands.
```
make
```

## Disclosure

There are several scripts/commands in this project that are outdated, please let me know so I can clean them up. I also use
this project for experimentation and testing out new ideas. The steps outlined in this README are the latest.