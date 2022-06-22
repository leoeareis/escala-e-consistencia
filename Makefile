##
# Project Title
#
# @file
# @version 0.1
SHELL := bash

all: public public/index.html

# Use local doom emacs if available.
# Use doom emacs container otherwise.
ifneq ($(wildcard ~/.doom.d/.*),)
EMACS=emacs
else
EMACS=docker run --rm --tty \
		--volume "$(shell pwd):$(shell pwd):ro" \
		--volume "$(shell pwd)/public:$(shell pwd)/public" \
		--workdir="$(shell pwd)" \
		--user "$(shell id -u):$(shell id -g)" \
		--env "HOME=/home/emacs" \
		--entrypoint emacs \
		rjfonseca/emacs:latest
endif

public: *.css img/*
	mkdir -p public
	cp -R presentation.css img public/

public/index.html: presentation.org | public ## Gera uma apresentação em HTML a partir do arquivo org.
	$(EMACS) \
	--no-window-system --no-splash --no-x-resources --no-desktop \
	--eval "(require 'org-re-reveal)" \
	--file $< \
	--eval "(org-re-reveal-export-to-html)" \
	--kill

.PHONY: bash
bash:
	docker run --rm -it \
		--volume "$(shell pwd):$(shell pwd)" \
		--workdir="$(shell pwd)" \
		--user "$(shell id -u):$(shell id -g)" \
		--entrypoint bash \
		rjfonseca/emacs:latest

.PHONY: edit
edit:
	docker run --rm -it \
		--volume "$(shell pwd):$(shell pwd)" \
		--workdir="$(shell pwd)" \
		--user "$(shell id -u):$(shell id -g)" \
		--entrypoint emacs \
		rjfonseca/emacs:latest \
		presentation.org
# end

clean:
	rm -rf public presentation.html
