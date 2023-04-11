RUN_DATETIME := $(shell date '+%Y%m%d_%H%M%S')

none:
	@echo "Please specify one or more targets."

all: zsh git vim

zsh:
	@.bin/init.zsh zsh "${RUN_DATETIME}"
	@$(MAKE) misc

git:
	@.bin/init.zsh git "${RUN_DATETIME}"

vim:
	@.bin/init.zsh vim "${RUN_DATETIME}"

misc:
	@.bin/init.zsh misc "${RUN_DATETIME}"

.PHONY: all zsh git vim
