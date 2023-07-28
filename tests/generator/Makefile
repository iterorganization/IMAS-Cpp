# This Makefile expects you've got AL already built (using the installer), but not yet installed, so we're testing the current build.

include ../../../Makefile.common

ifeq (,$(AL_BUILD))
AL_BUILD=../../..
$(warning AL_BUILD variable unset, probably not running 'make al_test' from the Installer. Assuming AL_BUILD=$(AL_BUILD).)
endif

ifneq ("yes","$(strip $(IMAS_CPP))")
all sources sources_install sources_uninstall install uninstall clean clean-src check test:
	$(warning "Ignoring cppinterface (IMAS_CPP=no).")
else

## Adding DEBUG=yes to make command to print additional debug info
DBGFLAGS= -g
ifeq (${DEBUG},yes)
DBGFLAGS+= -DDEBUG
endif
ifeq (${STOPONEXCEPT},yes)
DBGFLAGS+= -DSOE
endif

# Include OS-specific Makefile, if exists.
ifneq (,$(wildcard Makefile.$(SYSTEM)))
include Makefile.$(SYSTEM)
endif

IDSDEF = $(AL_BUILD)/xml/IDSDef.xml
ids_path = $(realpath $(AL_BUILD)/models/mdsplus)

# Test environment (mimics loaded imas environment), write ids to tmp dir
test_ENV = IMAS_AL_PLUGINS=$(AL_BUILD)/plugins LD_LIBRARY_PATH=$(AL_BUILD)/cppinterface/lib:$(AL_BUILD)/lowlevel:$$LD_LIBRARY_PATH ids_path="$$PWD/tmp;$(ids_path)"

include Makefile.tests
endif # IMAS_CPP
