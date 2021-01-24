.PHONY: 
	all

all:
	@make build

deploy-beta:
	bundle exec fastlane beta --env fastlane

prod:
	@sh bin/generate.sh Prod
	@pod install 
	@open Fable.xcworkspace


update:
	@sh bin/carthage-build-static.sh update

test:
	@xcodebuild \
          -workspace Fable.xcworkspace \
          -scheme Fable \
          -sdk iphonesimulator \
          -destination 'platform=iOS Simulator,name=iPhone 8,OS=14.0' \
          test | xcpretty

clean:
	@make _clean -i

_clean:
	@echo 'Closing Xcode...'
	@killall Xcode
	@echo 'Deleting Derived Data...'
	@rm -rf ~/Library/Developer/Xcode/DerivedData/*
	@echo 'Deleting Fable.xcworkspace & Fable.xcodeproj...'
	@rm -rf Fable.xcworkspace
	@rm -rf Fable.xcodeproj
	@make build

build:
	@sh bin/generate.sh Dev
	@pod install 
	@open Fable.xcworkspace

initial_bootstrap:
	@curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install | ruby
	@gem install bundler
	@gem install cocoapods
	@integration_bootstrap

scratch_build:
	@brew install xcodegen 
	@brew install swiftformat 
	@make build

bitrise_build:
	@sh bin/generate.sh Prod

bitrise:
	@bitrise run primary

bazel:
	# @bazel clean
	@bazel build //Module/AppFoundation:AppFoundation --apple_platform_type=ios --cpu=darwin_x86_64 --ios_multi_cpus=x86_64 --verbose_failures

tulsi:
	@sh bin/tulsi.sh

clean_derived_data:
	@make _clean_derived_data -i

_clean_derived_data:
	@echo 'Deleting Derived Data...'
	@rm -rf ~/Library/Developer/Xcode/DerivedData/*

dep_graph:
	@xcodegen dump --type graphviz --file graph.dot
	@dot -Tpng graph.dot > output.png && open output.png
