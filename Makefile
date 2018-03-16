include ../Makefile.common

ifeq ("no","$(strip $(IMAS_CPP))")
all sources sources_install install clean clean-src:
	$(warning "Ignoring cppinterface (IMAS_CPP=no).")
else

ifeq "$(strip $(CC))" "icc"
 CXX=icpc
 LD=$(CXX)
 CXXFLAGS=-g -fPIC -Wno-write-strings -Wno-deprecated -pthread -shared-intel
 LDFLAGS= -g -pthread
else
 CXX=g++
 LD=$(CXX)
 CXXFLAGS=-g -D__USE_XOPEN2K8 -fPIC -Wno-write-strings -Wno-deprecated -pthread
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

# Check that "saxon9he.jar" utility is set in CLASSPATH
SAXONICAJAR=$(wildcard $(filter %saxon9he.jar,$(subst :, ,$(CLASSPATH))))

all: $(SOURCES) $(TARGETS)

#################################################
#                 INIT: SOURCE GENERATION
#################################################
sources: $(SOURCES)

# Use an intermediate target to enforce nonparallel generation.
generate_sources:  IDSDef2CPPClasses.xsl IDSDef2CPPMethods.xsl  $(IDSDEF) saxonicajar
	@mkdir -p $(BUILD_DIR)
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

# Check that "saxon9he.jar" utility is set in CLASSPATH and exists
saxonicajar:
ifeq (,$(SAXONICAJAR))
	$(error Invalid /path/to/saxon9he.jar in CLASSPATH. Forgot to load module?)
endif

#################################################
#              BUILD
#################################################
$(LIB_DIR)/libimas-cpp.so : $(GENSOURCES) $(OBJ_FILES) $(IDS_OBJ_FILES)
	@mkdir -p $(LIB_DIR)
	$(LD) $(LDFLAGS) -o $@ -Wl,-z,defs -shared -Wl,-soname,$(notdir $@).$(IMAS_MAJOR).$(IMAS_MINOR) $(OBJ_FILES) $(IDS_OBJ_FILES) $(LIBS)

$(LIB_DIR)/libimas-cpp.a : $(GENSOURCES) $(OBJ_FILES) $(IDS_OBJ_FILES)
	@mkdir -p $(LIB_DIR)
	ar rvs $@ $(OBJ_FILES)

$(OBJ_FILES): $(BUILD_DIR)/%.o : $(SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) $(INCDIR) -c $< -o $(@)

$(IDS_OBJ_FILES): $(BUILD_DIR)/%.o : $(OBJ_FILES) $(IDS_SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) $(INCDIR) -c $(lastword $^) -o $(@)

#################################################
#              INSTALL
#################################################
install: all pkgconfig_install
	install -d $(INSTALL)/lib $(INSTALL)/include/ids
	$(foreach sofile,$(filter %.so,$(TARGETS)),\
		install -m644 $(sofile) $(INSTALL)/lib/$(notdir $(sofile)).$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO); \
		ln -svfT $(notdir $(sofile)).$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO) $(INSTALL)/lib/$(notdir $(sofile)).$(IMAS_MAJOR).$(IMAS_MINOR) ;\
		ln -svfT $(notdir $(sofile)).$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO) $(INSTALL)/lib/$(notdir $(sofile)).$(IMAS_MAJOR) ;\
		ln -svfT $(notdir $(sofile)).$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO) $(INSTALL)/lib/$(notdir $(sofile)) ;\
	)
	install -m644 $(SRC_DIR)/*.h $(INSTALL)/include
	install -m644 $(IDS_SRC_DIR)/*.h $(INSTALL)/include/ids

sources_install: $(SOURCES)
	install -d $(INSTALL)/share/src/cppinterface/ids
	install -m644 $(IDS_SRC_DIR)/*.* $(INSTALL)/share/src/cppinterface/ids
	install -m644 $(SRC_DIR)/*.* $(INSTALL)/share/src/cppinterface

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
include ../Makefile.pkgconfig
endif # IMAS_CPP=no?
