include ../Makefile.common

# Library interface number (used as soname suffix)
# If any interfaces have been added, removed, or changed since the last update,
# increment this number. Do not increment if it is certain the changes retain
# ABI compatibility. This may be possible if the changes are only in the
# implementation and do not change any function signatures or data structures.
# N.B. this number is not tied to the AL major version number whatsoever.
SO_NUM=4


ifeq ("no","$(strip $(IMAS_CPP))")
all sources sources_install sources_uninstall install uninstall clean clean-src:
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

ifeq "$(strip $(CC))" "icc"
CXX=icpc
CXXFLAGS=-O0 -fPIC -Wno-write-strings -Wno-deprecated -pthread -shared-intel ${DBGFLAGS}
LDFLAGS=-pthread
else
ifneq ($(SYSTEM),MacOS)
CXX=g++
else
CXX=clang++
endif
CXXFLAGS=-O0 -std=c++11 -D__USE_XOPEN2K8 -fPIC -Wno-write-strings -Wno-deprecated -pthread ${DBGFLAGS}
LDFLAGS=-fPIC -pthread
endif

BUILD_DIR:=./build
LIB_DIR:=./lib
SRC_DIR:=./src
IDS_SRC_DIR:=$(SRC_DIR)/ids
INCDIR=-I$(SRC_DIR) -I$(IDS_SRC_DIR) -I../lowlevel

IDSDEF= ../xml/IDSDef.xml

# Check existence of the "indent" utility to get a clean C format

ifneq ($(SYSTEM),MacOS)
ifeq "$(shell which indent 2> /dev/null)" ""
BEAUTIFY = echo
else
BEAUTIFY = indent -kr --no-tabs -l1000
endif
else
ifeq "$(shell which gindent 2> /dev/null)" ""
BEAUTIFY = echo
else
BEAUTIFY = gindent -kr --no-tabs -l1000
endif
endif

# Sets a path where make will search for files
VPATH = $(SRC_DIR) $(IDS_SRC_DIR) build lib

# Get a list of IDS from IDSDEF file
IDSNAMES := $(shell sed '/<IDS name=/!d;s/.*name="\([^"]*\)".*/\1/' $(IDSDEF))
IDS_H_FILES = $(addsuffix _IDSBase.h,$(IDSNAMES))
IDS_CPP_FILES = $(IDS_H_FILES:.h=.cpp)

# Generated sources (excluding static sources)
GEN_H_FILES = $(addprefix $(IDS_SRC_DIR)/,$(IDS_H_FILES)) $(SRC_DIR)/UALClasses.h
GEN_CPP_FILES = $(addprefix $(IDS_SRC_DIR)/,$(IDS_CPP_FILES)) $(SRC_DIR)/UALMethods.cpp
GENSOURCES = $(GEN_H_FILES) $(GEN_CPP_FILES)
# Add static sources
SOURCES = $(GENSOURCES) $(addprefix $(SRC_DIR)/,IdsDef.cpp  IdsDef.h  UALDef.h)

# Compiled objects
IDS_OBJ_FILES = $(addprefix $(BUILD_DIR)/,$(IDS_CPP_FILES:.cpp=.o))
OBJ_FILES = $(addprefix $(BUILD_DIR)/,IdsDef.o UALMethods.o)

# Include OS-specific Makefile, if exists.
ifneq (,$(wildcard Makefile.$(SYSTEM)))
include Makefile.$(SYSTEM)
else
all sources_install sources_uninstall ssources_uninstall install uninstall:
	$(error No Makefile.$(SYSTEM) found for this system: $(UNAME_S))
endif

#################################################
#            INIT: SOURCE GENERATION
#################################################
sources: $(SOURCES) id_cpp_sources

# Use an intermediate target to enforce nonparallel generation.
# Gracefully skip generation of sources if not needed.
# Gracefully skip beautify of sources if not newly generated.
$(GEN_H_FILES): gen_h_files
	$(if $(wildcard $@~),@echo Correcting indentation of $@ ; $(BEAUTIFY) $@ && $(RM) $@~)
ifeq ($(SYSTEM),MacOS)
	$(shell sed -i '' -e 's/: /:/g' $@)
	$(shell sed -i '' -e 's/:<tab>/:/g' $@ )
endif
$(GEN_CPP_FILES): gen_cpp_files
	$(if $(wildcard $@~),@echo Correcting indentation of $@ ; $(BEAUTIFY) $@ && $(RM) $@~)
ifeq ($(SYSTEM),MacOS)
	$(shell sed -i '' -e 's/: /:/g' $@)
	$(shell sed -i '' -e 's/:<tab>/:/g' $@ )
endif
gen_h_files: IDSDef2CPPClasses.xsl $(IDSDEF) | saxonicajar $(BUILD_DIR)
	$(if $(call allnewerthan,$(GEN_H_FILES),$^),, xsltproc IDSDef2CPPClasses.xsl $(IDSDEF) && \
	  touch $(addsuffix ~,$(GEN_H_FILES)) )
gen_cpp_files: IDSDef2CPPMethods.xsl $(IDSDEF) | saxonicajar $(BUILD_DIR)
	$(if $(call allnewerthan,$(GEN_CPP_FILES),$^),,\
	  $(SAXON) -t -warnings:fatal DD_GIT_DESCRIBE=$(DD_GIT_DESCRIBE) UAL_GIT_DESCRIBE=$(UAL_GIT_DESCRIBE) -s:$(IDSDEF) -xsl:IDSDef2CPPMethods.xsl && \
	  touch $(addsuffix ~,$(GEN_CPP_FILES)) )

#################################################
#                    BUILD
#################################################

$(OBJ_FILES): $(BUILD_DIR)/%.o : $(SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) $(INCDIR) -c $< -o $(@)

$(IDS_OBJ_FILES): $(BUILD_DIR)/%.o : $(OBJ_FILES) $(IDS_SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) $(INCDIR) -c $(lastword $^) -o $(@)

#################################################
#                  INSTALL
#################################################

#################################################
#                    CLEAN
#################################################
clean: test-clean pkgconfig_clean id_cpp_clean
	$(RM) -r $(LIB_DIR) $(BUILD_DIR)

clean-src: clean id_cpp_clean-src
	$(RM) $(GENSOURCES)

#################################################
#                    TESTS
#################################################

test: all
	$(MAKE) -C tests/generator test

test-clean:
	$(MAKE) -C tests/generator clean

test-clean-src:
	$(MAKE) -C tests/generator clean-src

#----------------------- identifiers ---------------------
include ../Makefile.identifiers
PC_FILES_ALT = $(ID_cpp_PC_FILES_2)

PC_FILES = imas-cpp.pc
PC_FILES_VAR = imas-cpp-$(DD_GIT_DESCRIBE).pc
PC_FILES_VAR_PRE = %$(DD_GIT_DESCRIBE).pc:%DD_VERSION.pc.in
#----------------------- pkgconfig ---------------------
include ../Makefile.pkgconfig

#----------------------- classpath deps ---------------------
include ../Makefile.classpath

endif # IMAS_CPP=no?
