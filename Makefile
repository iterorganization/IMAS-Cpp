include ../Makefile.common

# Library interface number (used as soname suffix)
# If any interfaces have been added, removed, or changed since the last update,
# increment this number. Do not increment if it is certain the changes retain
# ABI compatibility. This may be possible if the changes are only in the
# implementation and do not change any function signatures or data structures.
# N.B. this number is not tied to the AL major version number whatsoever.
SO_NUM=4


ifeq ("no","$(strip $(IMAS_CPP))")
all sources sources_install install clean clean-src:
	$(warning "Ignoring cppinterface (IMAS_CPP=no).")
else

ifeq "$(strip $(CC))" "icc"
 CXX=icpc
 CXXFLAGS=-g -fPIC -Wno-write-strings -Wno-deprecated -pthread -shared-intel
 LDFLAGS= -g -pthread
else
 CXX=g++
 CXXFLAGS=-g -std=gnu++11  -D__USE_XOPEN2K8 -fPIC -Wno-write-strings -Wno-deprecated -pthread
 LDFLAGS= -g -pthread
endif

BUILD_DIR:=./build
LIB_DIR:=./lib
SRC_DIR:=./src
IDS_SRC_DIR:=$(SRC_DIR)/ids
INCDIR=-I$(SRC_DIR) -I$(IDS_SRC_DIR) `pkg-config --cflags blitz` -I../lowlevel

IDSDEF= ../xml/IDSDef.xml
LIBS=-L../lowlevel `pkg-config blitz --libs` -limas

# Check existence of the "indent" utility to get a clean C format
ifeq "$(shell which indent 2> /dev/null)" ""
 BEAUTIFY = echo
else
 BEAUTIFY = indent -kr --no-tabs -l1000
endif

# Sets a path where make will search for files
VPATH = $(SRC_DIR) $(IDS_SRC_DIR) build lib

# Get a list of IDS from IDSDEF file
IDSNAMES := $(shell sed '/<IDS name=/!d;s/.*name="\([^"]*\)".*/\1/' $(IDSDEF))
IDS_H_FILES = $(addsuffix _IDSBase.h,$(IDSNAMES))
IDS_CPP_FILES = $(IDS_H_FILES:.h=.cpp)

# Generated sources (excluding static sources)
GENSOURCES = $(addprefix $(IDS_SRC_DIR)/,$(IDS_H_FILES) $(IDS_CPP_FILES))
GENSOURCES += $(addprefix $(SRC_DIR)/,UALClasses.h UALMethods.cpp)
# Add static sources
SOURCES = $(GENSOURCES) $(addprefix $(SRC_DIR)/,IdsDef.cpp  IdsDef.h  UALDef.h)

# Compiled objects
IDS_OBJ_FILES = $(addprefix $(BUILD_DIR)/,$(IDS_CPP_FILES:.cpp=.o))
OBJ_FILES = $(addprefix $(BUILD_DIR)/,IdsDef.o UALMethods.o)
TARGETS = $(addprefix $(LIB_DIR)/,libimas-cpp.so libimas-cpp.a)

all: $(SOURCES) $(TARGETS)

$(LIB_DIR) $(BUILD_DIR) $(libdir) $(includedir)/ids $(datadir)/src/cppinterface/ids:
	$(mkdir_p) $@

#################################################
#                 INIT: SOURCE GENERATION
#################################################
sources: $(SOURCES)

# Use an intermediate target to enforce nonparallel generation.
generate_sources:  IDSDef2CPPClasses.xsl IDSDef2CPPMethods.xsl $(IDSDEF) | saxonicajar $(BUILD_DIR)
	xsltproc IDSDef2CPPClasses.xsl $(IDSDEF)
	java net.sf.saxon.Transform -t -warnings:fatal -s:$(IDSDEF) -xsl:IDSDef2CPPMethods.xsl

beautify: generate_sources
	@for i in $(IDS_SRC_DIR)/*; do \
		echo Correcting indentation of $$i; \
		$(BEAUTIFY) $$i; \
	done
	@$(RM) $(IDS_SRC_DIR)/*~

# Test if all generated sources are found to exist as files to
# gracefully skip generation if not needed.
ifeq ($(words $(GENSOURCES)), $(words $(wildcard $(GENSOURCES))))
$(GENSOURCES):
else
$(GENSOURCES): generate_sources beautify
endif


#################################################
#              BUILD
#################################################
# Dynamic library
$(LIB_DIR)/libimas-cpp-$(DD_GIT_DESCRIBE).so.$(SO_NUM): $(OBJ_FILES) $(IDS_OBJ_FILES) | $(LIB_DIR)
	$(CXX) $(LDFLAGS) -o $@ -Wl,-z,defs -shared -Wl,-soname,$(@F) $^ $(LIBS)
$(LIB_DIR)/libimas-cpp-$(DD_GIT_DESCRIBE).so: %:%.$(SO_NUM)
	ln -svfT $(<F) $@
$(LIB_DIR)/libimas-cpp.so:%.so:%-$(DD_GIT_DESCRIBE).so
	ln -svfT $(<F) $@
$(LIB_DIR)/libimas-cpp.so_install: %.so_install:%-$(DD_GIT_DESCRIBE).so.$(SO_NUM) | $(libdir)
	$(INSTALL_DATA) $< $(libdir)
	ln -svfT $(<F) $(libdir)/$(*F)-$(DD_GIT_DESCRIBE).so
	ln -svfT $(<F) $(libdir)/$(*F).so

# Static library
$(LIB_DIR)/libimas-cpp-$(DD_GIT_DESCRIBE).a: $(OBJ_FILES) $(IDS_OBJ_FILES) | $(LIB_DIR)
	$(AR) rvs $@ $^
$(LIB_DIR)/libimas-cpp.a:%.a:%-$(DD_GIT_DESCRIBE).a
	ln -svfT $(<F) $@
$(LIB_DIR)/libimas-cpp.a_install: %.a_install:%-$(DD_GIT_DESCRIBE).a | $(libdir)
	$(INSTALL_DATA) $< $(libdir)
	ln -svfT $(<F) $(libdir)/$(*F).a

$(OBJ_FILES): $(BUILD_DIR)/%.o : $(SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) $(INCDIR) -c $< -o $(@)

$(IDS_OBJ_FILES): $(BUILD_DIR)/%.o : $(OBJ_FILES) $(IDS_SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) $(INCDIR) -c $(lastword $^) -o $(@)

#################################################
#              INSTALL
#################################################
install: all $(LIB_DIR)/libimas-cpp.so_install $(LIB_DIR)/libimas-cpp.a_install pkgconfig_install | $(libdir) $(includedir)/ids
	$(INSTALL_DATA) $(SRC_DIR)/*.h $(includedir)
	$(INSTALL_DATA) $(IDS_SRC_DIR)/*.h $(includedir)/ids

sources_install: $(SOURCES) $(datadir)/src/cppinterface/ids
	$(INSTALL_DATA) $(IDS_SRC_DIR)/*.* $(datadir)/src/cppinterface/ids
	$(INSTALL_DATA) $(SRC_DIR)/*.* $(datadir)/src/cppinterface

#################################################
#              CLEAN
#################################################
clean: test-clean pkgconfig_clean
	$(RM) $(OBJ_FILES)
	$(RM) $(TARGETS)

clean-src: clean
	$(RM) $(GENSOURCES)

#################################################
#                 TESTS
#################################################

test: all
	$(MAKE) -C tests/generator test

test-clean:
	$(MAKE) -C tests/generator clean

test-clean-src:
	$(MAKE) -C tests/generator clean-src

PC_FILES = imas-cpp.pc
PC_FILES_VAR = imas-cpp-$(DD_GIT_DESCRIBE).pc
PC_FILES_VAR_PRE = %$(DD_GIT_DESCRIBE).pc:%DD_VERSION.pc.in
#----------------------- pkgconfig ---------------------
include ../Makefile.pkgconfig

#----------------------- classpath deps ---------------------
include ../Makefile.classpath
endif # IMAS_CPP=no?
