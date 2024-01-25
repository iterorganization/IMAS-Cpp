# This Makefile expects you've got AL already built (e.g. using the installer), but not yet installed, so we're testing the current build.

include ../../Makefile.common

ifneq ("yes","$(strip $(IMAS_CPP))")
all sources sources_install sources_uninstall install uninstall clean clean-src check test:
	$(warning "Ignoring examples/cpp (IMAS_CPP=no).")
else

ifeq (,$(AL_BUILD))
AL_BUILD=../..
$(warning AL_BUILD variable unset, probably not running 'make al_examples' from the Installer. Assuming AL_BUILD=$(AL_BUILD).)
endif

# Include OS-specific Makefile, if exists.
ifneq (,$(wildcard Makefile.$(SYSTEM)))
include Makefile.$(SYSTEM)
endif

IDSDEF = $(AL_BUILD)/xml/IDSDef.xml
ids_path = $(realpath $(AL_BUILD)/models/mdsplus)

# Test environment (mimics loaded imas environment), write ids to tmp dir
TMPDIR = tmp

test_with_plugins_ENV = IMAS_AL_ENABLE_PLUGINS=TRUE IMAS_AL_PLUGINS=${IMAS_AL_PLUGINS} LD_LIBRARY_PATH=$(AL_BUILD)/cppinterface/lib:$(AL_BUILD)/lowlevel:$$LD_LIBRARY_PATH ids_path="$(abspath $(TMPDIR));$(ids_path)"
test_without_plugins_ENV = IMAS_AL_ENABLE_PLUGINS=FALSE  IMAS_AL_PLUGINS=$(IMAS_AL_PLUGINS) LD_LIBRARY_PATH=$(AL_BUILD)/cppinterface/lib:$(AL_BUILD)/lowlevel:$$LD_LIBRARY_PATH ids_path="$(abspath $(TMPDIR));$(ids_path)"

include Makefile.tests
endif # IMAS_CPP
