source "https://rubygems.org"

gem "fastlane", '~> 2.172.0'
gem 'bundler', '~> 2.0', '>= 2.0.2'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
