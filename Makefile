#### MainsailOS Build Chain
####
#### Written by Stephan Wendel aka KwadFan <me@stephanwe.de>
#### Copyright 2022
#### https://github.com/mainsail-crew/MainsailOS
####
#### This File is distributed under GPLv3
####

.PHONY: build clean cleanfix distclean get_latest get_legacy inspect


all: build

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

inspect:
	docker run --rm --privileged -it \
	-v $(PWD)/workspace/output.img:/image.img ghcr.io/octoprint/custopizer:latest \
	/CustoPiZer/enter_image /image.img

