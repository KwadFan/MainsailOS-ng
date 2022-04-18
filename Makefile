#### MainsailOS Build Chain
####
#### Written by Stephan Wendel aka KwadFan <me@stephanwe.de>
#### Copyright 2022
#### https://github.com/mainsail-crew/MainsailOS
####
#### This File is distributed under GPLv3
####

.PHONY: build clean cleanfix distclean get_latest get_legacy help inspect


all: help

build:
	@if [ -f "${PWD}/workspace/input.img" ]; then \
	docker run --rm --privileged \
	-v $(PWD)/workspace:/CustoPiZer/workspace ghcr.io/octoprint/custopizer:latest; \
	else echo -e "input.img not found. Exiting!"; exit 1;fi

clean:
	rm -rf workspace/aptcache
	rm -rf workspace/mount

# workspace/* is blocked by file Permissions from Docker Container and you are not building as root user
cleanfix:
	sudo chmod -R 0777 workspace/*

# dist clean should contain clean as usual
distclean:
	$(MAKE) cleanfix
	$(MAKE) clean
	rm -f workspace/*.zip
	rm -f workspace/*.xz
	rm -f workspace/*.sha256
	rm -f workspace/*.img

get_latest:
	$(PWD)/tools/get_image latest

get_legacy:
	$(PWD)/tools/get_image legacy

help:
	@echo "This is intended for local builds using docker."
	@echo "Using the CustoPiZer Container, see:"
	@echo "https://github.com/OctoPrint/CustoPiZer"
	@echo ""
	@echo "Some Parts need 'sudo' privileges."
	@echo "You'll be asked for password, if needed."
	@echo ""
	@echo " Usage: make [action]"
	@echo ""
	@echo "  Available actions:"
	@echo ""
	@echo "   get_latest   Download Rasperry Pi OS latest"
	@echo "   get_legacy   Download Rasperry Pi OS legacy"
	@echo "   build        builds image"
	@echo "   clean        cleans workspace cache from last build"
	@echo "   cleanfix     set permissions to 0777 of workspace"
	@echo "   distclean    cleans workspace completly from last build"
	@echo ""

inspect:
	docker run --rm --privileged -it \
	-v $(PWD)/workspace/output.img:/image.img ghcr.io/octoprint/custopizer:latest \
	/CustoPiZer/enter_image /image.img
