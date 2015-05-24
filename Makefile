.PHONY: carthage doc

carthage:
	carthage build --no-skip-current
	carthage archive Stargate

doc:
	jazzy --podspec Stargate.podspec
