reload:
	-bash uninstall.sh
	-bash install.sh

install:
	bash install.sh

uninstall:
	bash uninstall.sh

.PHONY: reload install uninstall

