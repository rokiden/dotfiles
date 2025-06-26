INSTALL_BIN_DIR=/usr/local/bin
INSTALL_SUDOERS_DIR=/etc/sudoers.d

POWERCAP_SCRIPT=powercap.sh
POWERCAP_SUDOERS=sudoers_rokiden_powercap

LGLAPTOP_SCRIPT=lglaptop.sh
LGLAPTOP_SUDOERS=sudoers_rokiden_lglaptop

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

define install_sudoers
	$(call check_root)
	cp $(1) $(INSTALL_SUDOERS_DIR)/
endef

define uninstall_sudoers
	$(call check_root)
	-rm $(INSTALL_SUDOERS_DIR)/$(1)
endef

# PowerCap
.PHONY: install_powercap install_powercap_sudoers uninstall_powercap uninstall_powercap_sudoers

install_powercap: $(INSTALL_BIN_DIR)/$(POWERCAP_SCRIPT)
$(INSTALL_BIN_DIR)/$(POWERCAP_SCRIPT): $(POWERCAP_SCRIPT)
	$(call install_bin,$(POWERCAP_SCRIPT))

uninstall_powercap:
	$(call uninstall_bin,$(POWERCAP_SCRIPT))

install_powercap_sudoers: $(INSTALL_SUDOERS_DIR)/$(POWERCAP_SUDOERS)
$(INSTALL_SUDOERS_DIR)/$(POWERCAP_SUDOERS): $(POWERCAP_SUDOERS)
	$(call install_sudoers,$(POWERCAP_SUDOERS))

uninstall_powercap_sudoers:
	$(call uninstall_sudoers,$(POWERCAP_SUDOERS))

# LGLaptop
.PHONY: install_lglaptop uninstall_lglaptop install_lglaptop_sudoers uninstall_lglaptop_sudoers

install_lglaptop: $(INSTALL_BIN_DIR)/$(LGLAPTOP_SCRIPT)
$(INSTALL_BIN_DIR)/$(LGLAPTOP_SCRIPT): $(LGLAPTOP_SCRIPT)
	$(call install_bin,$(LGLAPTOP_SCRIPT))

uninstall_lglaptop:
	$(call uninstall_bin,$(LGLAPTOP_SCRIPT))

install_lglaptop_sudoers: $(INSTALL_SUDOERS_DIR)/$(LGLAPTOP_SUDOERS)
$(INSTALL_SUDOERS_DIR)/$(LGLAPTOP_SUDOERS): $(LGLAPTOP_SUDOERS)
	$(call install_sudoers,$(LGLAPTOP_SUDOERS))

uninstall_lglaptop_sudoers:
	$(call uninstall_sudoers,$(LGLAPTOP_SUDOERS))

# Global
install: install_powercap install_powercap_sudoers install_lglaptop install_lglaptop_sudoers
uninstall: uninstall_powercap uninstall_powercap_sudoers uninstall_lglaptop uninstall_lglaptop_sudoers
.PHONY: install uninstall

.DEFAULT_GOAL := install
