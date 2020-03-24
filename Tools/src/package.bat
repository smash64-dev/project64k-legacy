:: package.bat
@echo OFF

CD ..\..\
CALL git archive --format=zip --output=project64k-legacy-release.zip HEAD
