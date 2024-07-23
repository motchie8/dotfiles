install: install-from-source

install-from-source: install-base-from-source install-taskwarrior

install-by-package-manager: install-base-by-package-manager install-taskwarrior

install-base-from-source:
	./bin/install_essentials.sh -b
	./bin/install_dev_env_libs.sh -b -t n
	./bin/setup_symbolic_links.sh

install-base-by-package-manager:
	./bin/install_essentials.sh
	./bin/install_dev_env_libs.sh -t n
	./bin/setup_symbolic_links.sh

install-taskwarrior: install-taskwarrior-from-source

install-taskwarrior-from-source:
	./bin/setup_taskwarrior.sh -b

install-taskwarrior-by-package-manager:
	./bin/setup_taskwarrior.sh

install-tasksync:
	./bin/setup_task_sync.sh

install-google-drive-fuse:
	./bin/setup_google_drive_ocamlfuse.sh

build: build-docker-image-build-from-source build-docker-image-using-package-manager

build-docker-image-build-from-source:
	docker build -f docker/ubuntu/Dockerfile --build-arg BUILD_FROM_SOURCE=true -t motchie8/dotfiles:build-from-source .

build-docker-image-using-package-manager:
	 docker build -f docker/ubuntu/Dockerfile --build-arg BUILD_FROM_SOURCE=false -t motchie8/dotfiles:use-package-manager .

lint:
	shellcheck bin/*.sh --external-sources

test:
	act -P ubuntu-latest=catthehacker/ubuntu:act-latest -W .github/workflows/build_and_push_docker_image.yml

auth-gdrive:
	./bin/setup_google_drive_ocamlfuse.sh -a

clean:	
	for rcfile_name in zlogin zlogout zpreztorc zprofile zshenv; do \
        if [ -L "$$HOME/.$$rcfile_name" ]; then \
            unlink "$$HOME/.$$rcfile_name"; \
        fi; \
    done
	for link_name in lua-language-server; do \
		if [ -L "$$HOME/bin/$$link_name" ]; then \
			unlink "$$HOME/bin/$$link_name"; \
		fi; \
	done
	rm -rf build
	./bin/setup_symbolic_links.sh -d

.PHONY: install install-from-source install-by-package-manager install-base-from-source install-base-by-package-manager install-taskwarrior-from-source install-taskwarrior-by-package-manager install-tasksync install-google-drive-fuse build build-docker-image-build-from-source build-docker-image-using-package-manager lint test clean install-taskwarrior auth-gdrive
