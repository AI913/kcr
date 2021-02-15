PRODUCT_NAME := JobOrder
WORKSPACE_NAME := ${PRODUCT_NAME}.xcworkspace
SCHEME_NAME := ${PRODUCT_NAME}
UI_TESTS_TARGET_NAME := ${PRODUCT_NAME}UITests

TEST_SDK := iphonesimulator
TEST_CONFIGURATION := Debug
TEST_PLATFORM := iOS Simulator
TEST_DEVICE ?= iPhone 11
TEST_OS ?= 13.5
TEST_DESTINATION := 'platform=${TEST_PLATFORM},name=${TEST_DEVICE},OS=${TEST_OS}'
COVERAGE_OUTPUT := html_report
RUBY_VERSION ?= 2.7.1

MODULE_TEMPLATE_NAME ?= clean_architecture

.DEFAULT_GOAL := help

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?# .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":[^#]*? #| #"}; {printf "%-42s%s\n", $$1 $$3, $$2}'

.PHONY: all
all: # Initial setup
	$(MAKE) config
	$(MAKE) setup

.PHONY: config
config: # Install package manager
	$(MAKE) install-homebrew
	$(MAKE) install-brew
	$(MAKE) install-rbenv
	$(MAKE) install-bundler-gem

.PHONY: setup
setup: # Install dependencies and prepared development configuration
	$(MAKE) install-bundler
	$(MAKE) install-templates
	$(MAKE) install-mint
	$(MAKE) install-carthage
	$(MAKE) install-cocoapods
	$(MAKE) generate-licenses
	$(MAKE) open

.PHONY: update
update: # Update dependencies and prepared development configuration
	$(MAKE) update-bundler
	$(MAKE) update-carthage
	$(MAKE) update-cocoapods

.PHONY: prepare-ci
prepare-ci: # Install dependencies and prepared development configuration in CI service
	brew update # https://github.com/Homebrew/homebrew-bundle/issues/835
	$(MAKE) install-brew
	$(MAKE) install-templates
	$(MAKE) install-mint

.PHONY: install-homebrew
install-homebrew: # Install Homebrew
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install | ruby

.PHONY: install-brew
install-brew: # Install Homebrew dependencies
	brew bundle

.PHONY: install-rbenv
install-rbenv: # Install a specific version of Ruby
	rbenv install $(RUBY_VERSION)
	rbenv global $(RUBY_VERSION)

.PHONY: update-gem
update-gem: # Update Gem
	sudo gem update --system

.PHONY: install-bundler-gem
install-bundler-gem: # Install Bundler
	gem install bundler

.PHONY: install-bundler
install-bundler: # Install Bundler dependencies
	bundle config path vendor/bundle
	bundle install --jobs 4 --retry 3

.PHONY: update-bundler
update-bundler: # Update Bundler dependencies
	bundle config path vendor/bundle
	bundle update --jobs 4 --retry 3

.PHONY: install-mint
install-mint: # Install Mint dependencies
	mint bootstrap

.PHONY: install-cocoapods
install-cocoapods: # Install CocoaPods dependencies and generate workspace
	bundle exec pod install

.PHONY: update-cocoapods
update-cocoapods: # Update CocoaPods dependencies and generate workspace
	bundle exec pod update

.PHONY: install-carthage
install-carthage: # Install Carthage dependencies
	mint run carthage carthage bootstrap --platform iOS --cache-builds --use-xcframeworks
	$(MAKE) show-carthage-dependencies

.PHONY: update-carthage
update-carthage: # Update Carthage dependencies
	mint run carthage carthage update --platform iOS --use-xcframeworks
	$(MAKE) show-carthage-dependencies

.PHONY: show-carthage-dependencies
show-carthage-dependencies:
	@echo '*** Resolved dependencies:'
	@cat 'Cartfile.resolved'

.PHONY: install-templates
install-templates: # Install Generamba templates
	bundle exec generamba template install

.PHONY: generate-licenses
generate-licenses: # Generate licenses with LicensePlist and regenerate project
	mint run LicensePlist license-plist \
		--output-path ${PRODUCT_NAME}/Resources/Settings.bundle \
		--package-path ${PRODUCT_NAME}.xcworkspace/xcshareddata/swiftpm/Package.resolved
#	$(MAKE) generate-xcodeproj

.PHONY: generate-module
generate-module: # Generate module with Generamba and regenerate project # MODULE_NAME=[module name]
	bundle exec generamba gen ${MODULE_NAME} ${MODULE_TEMPLATE_NAME}
	$(MAKE) generate-xcodeproj

.PHONY: generate-xcodeproj
generate-xcodeproj: # Generate project with XcodeGen
	mint run xcodegen xcodegen generate
	$(MAKE) install-cocoapods
	$(MAKE) open

.PHONY: generate-documents-release
generate-documents-release: # Generate document with Jazzy
	sh jazzy.sh Release

.PHONY: generate-documents-adhoc
generate-documents-adhoc: # Generate document with Jazzy
	sh jazzy.sh AdHoc

.PHONY: lint
lint: # Lint with SwiftLint
	mint run swiftlint swiftlint autocorrect --format
	mint run swiftlint swiftlint

.PHONY: open
open: # Open workspace in Xcode
	open ./${WORKSPACE_NAME}

.PHONY: clean
clean: # Delete cache
	rm -rf ./build
	rm -rf ./Pods
	rm -rf ./Carthage
	rm -rf ./vendor
	rm -rf ./Templates
	rm -rf ./docs
	xcodebuild clean -alltargets

.PHONY: build-debug
build-debug: # Xcode build for debug
	set -o pipefail && \
	xcodebuild \
	-sdk ${TEST_SDK} \
	-configuration ${TEST_CONFIGURATION} \
	-workspace ${WORKSPACE_NAME} \
	-scheme ${SCHEME_NAME} \
	build \
	| bundle exec xcpretty

.PHONY: test
test: # Xcode test # TEST_DEVICE=[device] TEST_OS=[OS]
	set -o pipefail && \
	xcodebuild \
	clean test \
	-workspace ${WORKSPACE_NAME} \
	-scheme ${SCHEME_NAME} \
	-destination ${TEST_DESTINATION} \
	-resultBundlePath build/output/ResultBundle.xcresult \
	| bundle exec xcpretty --report html

.PHONY: get-coverage
get-coverage: # Get code coverage
	bundle exec slather coverage --html --output-directory ${COVERAGE_OUTPUT}

.PHONY: show-devices
show-devices: # Show devices
	instruments -s devices
