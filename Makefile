REPO_ROOT = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

lint:
	docker run -i --rm -v $(REPO_ROOT):/work tmknom/markdownlint -f /work
