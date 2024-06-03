install:
	./bin/setup_deb_libs.sh
	./bin/install.sh -b -t n

install-tasksync:
	./bin/setup_task_sync.sh

install-google-drive-fuse:
	./bin/setup_google_drive_ocamlfuse.sh

build:
	 docker build -f docker/ubuntu/Dockerfile -t motchie8/dotfiles:master .

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

.PHONY: install update build clean install-tasksync install-google-drive-fuse
