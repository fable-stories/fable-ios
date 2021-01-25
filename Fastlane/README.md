fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios codesign
```
fastlane ios codesign
```

### ios increment_build
```
fastlane ios increment_build
```
Increment the latest TestFlight build number fo the given Version.
### ios _increment_build
```
fastlane ios _increment_build
```

### ios patch_version
```
fastlane ios patch_version
```

### ios build
```
fastlane ios build
```
Simple build for the Fable scheme.
### ios test_and_build
```
fastlane ios test_and_build
```
Run tests and then Build!
### ios beta
```
fastlane ios beta
```
Build the Fable app for Firebase Distribution.
### ios deploy_beta
```
fastlane ios deploy_beta
```

### ios release
```
fastlane ios release
```
Archive the Fable app for TestFlight Distribution.
### ios deploy_release
```
fastlane ios deploy_release
```
Deploy the latest Fable archive for TestFlight Distribution.
### ios upload_dsyms
```
fastlane ios upload_dsyms
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
