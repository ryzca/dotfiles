RUN_DATETIME := $(shell date '+%Y%m%d_%H%M%S')

define run
	@.bin/init.sh $(1) "${RUN_DATETIME}"
endef

none:
	@echo "Please specify one or more targets."

all: homebrew zsh git vim mise ghostty

homebrew:
	$(call run,homebrew)

zsh: misc
	$(call run,zsh)

git:
	$(call run,git)

vim:
	$(call run,vim)

mise:
	$(call run,mise)

ghostty:
	$(call run,ghostty)

misc:
	$(call run,misc)

.PHONY: all homebrew zsh git vim mise ghostty
