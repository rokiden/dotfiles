INSTALL_BIN_DIR=/usr/local/bin
INSTALL_SUDOERS_DIR=/etc/sudoers.d

POWERCAP_NAME=powercap.sh
SUDOERS_NAME=sudoers_rokiden_waybar_scripts

define check_root
	@[ $$(id -u) -eq 0 ] || { echo "You must run as root"; exit 1; }
endef

define install_bin
	$(call check_root)
	cp $(1) $(INSTALL_BIN_DIR)/
	chmod 755 $(INSTALL_BIN_DIR)/$(1)
	chown 0:0 $(INSTALL_BIN_DIR)/$(1)
endef

define uninstall_bin
	$(call check_root)
	-rm $(INSTALL_BIN_DIR)/$(1)
endef

install_powercap: $(INSTALL_BIN_DIR)/$(POWERCAP_NAME)
$(INSTALL_BIN_DIR)/$(POWERCAP_NAME): $(POWERCAP_NAME)
	$(call install_bin,$(POWERCAP_NAME))

uninstall_powercap:
	$(call uninstall_bin,$(POWERCAP_NAME))

install_sudoers: $(INSTALL_SUDOERS_DIR)/$(SUDOERS_NAME)
$(INSTALL_SUDOERS_DIR)/$(SUDOERS_NAME): $(SUDOERS_NAME)
	$(call check_root)
	cp $(SUDOERS_NAME) $(INSTALL_SUDOERS_DIR)
	
uninstall_sudoers:
	$(call check_root)
	-rm $(INSTALL_SUDOERS_DIR)/$(SUDOERS_NAME)
	
install: install_powercap install_sudoers
uninstall: uninstall_powercap uninstall_sudoers
.PHONY: install install_powercap install_sudoers uninstall uninstall_powercap uninstall_sudoers
.DEFAULT_GOAL := install
