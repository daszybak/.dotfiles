reload:
	-bash uninstall.sh -y
	-bash install.sh -y

install:
	bash install.sh

uninstall:
	bash uninstall.sh

.PHONY: reload install uninstall

