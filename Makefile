CARTHAGE := $(shell command -v carthage 2> /dev/null)

bootstrap: check_carthage 
	# Make sure submodules handled by Carthage are up to date (as saved in Cartfile.resolved)
	$(CARTHAGE) bootstrap --project-directory BoxPreviewSDKSampleApp --platform iOS
	# Sometimes Carthage will create this, but it's safe to remove
	rm -f BoxPreviewSDKSampleApp/.gitmodules

update: check_carthage
	# Update Carthage-managed dependencies to the most recent available versions
	$(CARTHAGE) update --project-directory BoxPreviewSDKSampleApp --platform iOS
	# Sometimes Carthage will create this, but it's safe to remove
	rm -f BoxPreviewSDKSampleApp/.gitmodules

clean:
	# Remove Carthage products
	rm -rf BoxPreviewSDKSampleApp/Carthage/Build/*
	# Sometimes Carthage will create this, but it's safe to remove
	rm -f BoxPreviewSDKSampleApp/.gitmodules

cleanall: clean
	# Remove Carthage cached downloads
	rm -rf $(HOME)/Library/Caches/org.carthage.CarthageKit/

check_carthage:
ifndef CARTHAGE
	@echo "Carthage not found. Install with 'brew install carthage'"
	@exit 1
endif
