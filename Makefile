REPO_ROOT = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

lint:
	docker run -i --rm -v $(REPO_ROOT):/work tmknom/markdownlint -f /work

check:
	docker run --rm -p 127.0.0.1:8000:8000 -v $(REPO_ROOT):/docs squidfunk/mkdocs-material build --strict

server:
	docker run --rm -p 127.0.0.1:8000:8000 -v $(REPO_ROOT):/github/workspace squidfunk/mkdocs-material serve -f /github/workspace/mkdocs.yml