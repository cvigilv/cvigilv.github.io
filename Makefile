WEBSITE_URL := "cvigilv.github.io"
SRC_DIR := src
DST_DIR := dst

.PHONY: setup render deploy clean

help: ## Print this message
	@echo "usage: make [target] ..."
	@echo ""
	@echo "Available targets:"
	@grep --no-filename "##" $(MAKEFILE_LIST) | \
		grep --invert-match $$'\t' | \
		sed -e "s/\(.*\):.*## \(.*\)/ - \1:  \t\2/"

build: clean ## Render website locally for development
	@echo "Create output directory"
	mkdir -p $(DST_DIR)
	cp -r $(SRC_DIR)/media $(DST_DIR)/media
	cp -r $(SRC_DIR)/css $(DST_DIR)/css
	@echo "Create 'blog' page"
	echo "#+TITLE: Blog\n" > $(SRC_DIR)/blog.org
	grep "#+TITLE:" $(SRC_DIR)/posts/* | sed -E "s/$(SRC_DIR)\/posts\/(....)(..)(..)(.*)\.org:\#\+TITLE: (.*)/- [[file:\.\/posts\/\1\2\3\4.html][\1\.\2\.\3 --- \5]]/" | sort -r >> $(SRC_DIR)/blog.org
	@bash converter.sh

deploy: ## Deploy website to GitHub
	git branch -D gh-pages
	git checkout -b gh-pages
	git merge main
	$(MAKE) build
	rm -rf src
	mv dst/* .
	rm -rf dst/
	git add .
	git commit -m "chore: deploy"
	git push --set-upstream origin --force gh-pages
	git checkout main

clean: ## Remove virtualenv
	rm -f $(SRC_DIR)/blog.org
	rm -rf $(DST_DIR)
