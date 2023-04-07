RUN_DATETIME := $(shell date '+%Y%m%d_%H%M%S')

none:
	@echo "Please specify one or more targets."

all: zsh git

zsh:
	@.bin/init.zsh zsh "${RUN_DATETIME}"

git:
	@.bin/init.zsh git "${RUN_DATETIME}"

.PHONY: all zsh git
