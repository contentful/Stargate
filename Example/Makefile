.PHONY: all pod

all:
	xcodebuild -workspace StargateExample.xcworkspace \
		-scheme Stargate build CODE_SIGN_IDENTITY=-
	xcodebuild -workspace StargateExample.xcworkspace \
		-scheme StargateExample -sdk iphonesimulator build CODE_SIGN_IDENTITY=-

pod:
	pod install --no-repo-update
