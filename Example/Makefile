.PHONY: all pod

all:
	xcodebuild -workspace StargateExample.xcworkspace \
		-scheme Stargate build
	xcodebuild -workspace StargateExample.xcworkspace \
		-scheme StargateExample build

pod:
	pod install --no-repo-update
