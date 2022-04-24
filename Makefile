#### MainsailOS Build Chain
####
#### Written by Stephan Wendel aka KwadFan <me@stephanwe.de>
#### Copyright 2022
#### https://github.com/mainsail-crew/MainsailOS
####
#### This File is distributed under GPLv3
####

.PHONY: build clean cleanfix compress distclean get_latest get_legacy help inspect

WORKSPACE=$(PWD)/workspace

all: help

build:
	@if [ -f "${PWD}/workspace/input.img" ]; then \
	time docker run --rm --privileged \
	-v $(WORKSPACE):/CustoPiZer/workspace \
	-v $(WORKSPACE)/config.mainsail:/CustoPiZer/config.mainsail \
	-v $(WORKSPACE)/config.local:/CustoPiZer/config.local \
	ghcr.io/octoprint/custopizer:latest | tee $(WORKSPACE)/build.log; \
	else echo -e "input.img not found. Exiting!"; exit 1;fi

build64:
	@if [ -f "${PWD}/workspace/input.img" ]; then \
	time docker run --rm --privileged \
	-v $(WORKSPACE):/CustoPiZer/workspace \
	-v $(WORKSPACE)/config.mainsail:/CustoPiZer/config.mainsail \
	-v $(WORKSPACE)/config.64bit:/CustoPiZer/config.local \
	ghcr.io/octoprint/custopizer:latest | tee $(WORKSPACE)/build.log; \
	else echo -e "input.img not found. Exiting!"; exit 1;fi


clean:
	$(RM) -r $(WORKSPACE)/aptcache
	$(RM) -r $(WORKSPACE)/mount
	$(RM) $(WORKSPACE)/build.log

# workspace/* is blocked by file Permissions from Docker Container and you are not building as root user
cleanfix:
	@if [ -d "$(WORKSPACE)/aptcache" ]; then \
	sudo chmod -R 0777 workspace/aptcache; fi
	@if [ -d "$(WORKSPACE)/aptcache" ]; then \
	sudo chmod -R 0777 workspace/mount; fi

# compress image to *.xz and rename
compress:
	@$(PWD)/tools/compress_image.sh

# dist clean should contain clean as usual
distclean:
	$(MAKE) cleanfix
	$(MAKE) clean
	$(RM) workspace/*.zip
	$(RM) workspace/*.xz
	$(RM) workspace/*.sha256
	$(RM) workspace/*.img

get_latest:
	$(PWD)/tools/get_image latest

get_latest64:
	$(PWD)/tools/get_image latest64

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
	@echo "   get_latest64 Download Rasperry Pi OS latest (64bit)"
	@echo "   get_legacy   Download Rasperry Pi OS legacy"
	@echo "   build        builds image"
	@echo "   clean        cleans workspace cache from last build"
	@echo "   cleanfix     set permissions to 0777 of workspace"
	@echo "   compress     compress image to 'xz' and rename"
	@echo "   distclean    cleans workspace completly from last build"
	@echo ""

inspect:
	docker run --rm --privileged -it \
	-v $(WORKSPACE)/output.img:/image.img ghcr.io/octoprint/custopizer:latest \
	/CustoPiZer/enter_image /image.img
