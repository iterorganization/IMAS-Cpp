include ../Makefile.common

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
	CXXFLAGS=-g -std=c++11 -D__USE_XOPEN2K8 -fPIC -Wno-write-strings -Wno-deprecated -pthread
	LDFLAGS= -g -pthread
endif

ifneq ("no","$(strip $(SYS_WIN))")
	JAVA = $(JAVA_HOME)/bin/java
	CFLAGS+= -DWIN32
	CXXFLAGS+= -DWIN32
else
	JAVA = java
endif

BUILD_DIR:=./build
LIB_DIR:=./lib
SRC_DIR:=./src
IDS_SRC_DIR:=$(SRC_DIR)/ids
INCDIR=-I$(SRC_DIR) -I$(IDS_SRC_DIR) -I../lowlevel

IDSDEF= ../xml/IDSDef.xml

ifneq ("no","$(strip $(SYS_WIN))")
	INCDIR+= -I$(BLITZ_HOME)/include
	LIBS+= $(BLITZ_HOME)/lib/libblitz.a ../lowlevel/libimas.lib
else
	INCDIR+= `pkg-config --cflags blitz`
	LIBS+= -L../lowlevel -limas `pkg-config blitz --libs`
endif

ifneq ("no","$(strip $(IMAS_MDSPLUS))")
	ifneq ("no","$(strip $(SYS_WIN))")
		LIBS+= -L$(MDSPLUS_DIR)/lib
		LIBS+= $(MDSPLUS_DIR)/lib/XTreeShr.a
		LIBS+= $(MDSPLUS_DIR)/lib/MdsObjectsCppShr.a
		LIBS+= $(MDSPLUS_DIR)/lib/MdsIpShr.a
		LIBS+= $(MDSPLUS_DIR)/lib/MdsLib.a
		LIBS+= $(MDSPLUS_DIR)/lib/TdiShr.a
		LIBS+= $(MDSPLUS_DIR)/lib/TreeShr.a
		LIBS+= $(MDSPLUS_DIR)/lib/MdsShr.a
		LIBS+= -lxml2 -lws2_32 -ldl -liphlpapi
	else
		LIBS+= -L$(MDSPLUS_DIR)/lib64 -L$(MDSPLUS_DIR)/lib
		LIBS+= -lMdsShr -lTreeShr -lTdiShr -lMdsLib -lMdsIpShr -lMdsObjectsCppShr -lXTreeShr
	endif
endif
ifneq ("no","$(strip $(IMAS_UDA))")
	ifneq ("no","$(strip $(SYS_WIN))")
		LIBS+= -L$(UDA_HOME)/lib
		LIBS+= $(UDA_HOME)/lib/libuda_cpp.a
		LIBS+= $(UDA_HOME)/lib/libportablexdr.a
		LIBS+= -lws2_32 -lssl -lcrypto
	else
		LIBS+= `pkg-config --libs uda-cpp`
	endif
endif
ifneq ("no","$(strip $(IMAS_HDF5))")
	ifneq ("no","$(strip $(SYS_WIN))")
		LIBS+= -L$(HDF5_HOME)/lib
		LIBS+= $(HDF5_HOME)/lib/libhdf5.a -ldl -lz
	else
		LIBS+= -L$(HDF5_HOME)/lib
		LIBS+= -lhdf5 -ldl -lz
	endif
endif

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
ifneq ("no","$(strip $(SYS_WIN))")
	TARGETS = $(addprefix $(LIB_DIR)/,libimas-cpp.lib libimas-cpp.dll)
else
	TARGETS = $(addprefix $(LIB_DIR)/,libimas-cpp.so libimas-cpp.a)
endif


all: $(SOURCES) $(TARGETS)

#################################################
#            INIT: SOURCE GENERATION
#################################################
sources: $(SOURCES)

# Use an intermediate target to enforce nonparallel generation.
generate_sources:  IDSDef2CPPClasses.xsl IDSDef2CPPMethods.xsl $(IDSDEF) | saxonicajar
	@$(mkdir_p) $(BUILD_DIR)
	xsltproc IDSDef2CPPClasses.xsl $(IDSDEF)
	$(JAVA) net.sf.saxon.Transform -t -warnings:fatal -s:$(IDSDEF) -xsl:IDSDef2CPPMethods.xsl

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
#                    BUILD
#################################################
$(LIB_DIR)/libimas-cpp.so : $(GENSOURCES) $(OBJ_FILES) $(IDS_OBJ_FILES)
	$(mkdir_p) $(LIB_DIR)
	$(CXX) $(LDFLAGS) -o $@ -Wl,-z,defs -shared -Wl,-soname,$(@F).$(IMAS_MAJOR).$(IMAS_MINOR) $(OBJ_FILES) $(IDS_OBJ_FILES) $(LIBS)

$(LIB_DIR)/libimas-cpp.a : $(GENSOURCES) $(OBJ_FILES) $(IDS_OBJ_FILES)
	$(mkdir_p) $(LIB_DIR)
	$(AR) rvs $@ $(OBJ_FILES)

$(LIB_DIR)/libimas-cpp.dll : $(GENSOURCES) $(OBJ_FILES) $(IDS_OBJ_FILES)
	$(mkdir_p) $(LIB_DIR)
<<<<<<< HEAD
<<<<<<< HEAD
	$(CXX) $(LDFLAGS) -o $@ -shared -Wl,-soname,$(@F).$(IMAS_MAJOR).$(IMAS_MINOR) -Wl,--out-implib,$@.lib $(OBJ_FILES) $(IDS_OBJ_FILES) $(LIBS)
=======
	$(CXX) $(LDFLAGS) -o $@ -shared -Wl,-soname,$(@F).$(IMAS_MAJOR).$(IMAS_MINOR) $(OBJ_FILES) $(IDS_OBJ_FILES) $(LIBS)
>>>>>>> First Windows commit
=======
	$(CXX) $(LDFLAGS) -o $@ -shared -Wl,-soname,$(@F).$(IMAS_MAJOR).$(IMAS_MINOR) -Wl,--out-implib,$@.lib $(OBJ_FILES) $(IDS_OBJ_FILES) $(LIBS)
>>>>>>> Fix to compile and execute correctly lowlevel with static and shared MDSplus libraries

$(LIB_DIR)/libimas-cpp.lib : $(GENSOURCES) $(OBJ_FILES) $(IDS_OBJ_FILES)
	$(mkdir_p) $(LIB_DIR)
	$(AR) rcvsu $@ $(OBJ_FILES) $(IDS_OBJ_FILES)
	ranlib $@

$(OBJ_FILES): $(BUILD_DIR)/%.o : $(SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) $(INCDIR) -c $< -o $(@)

$(IDS_OBJ_FILES): $(BUILD_DIR)/%.o : $(OBJ_FILES) $(IDS_SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) $(INCDIR) -c $(lastword $^) -o $(@)

#################################################
#                  INSTALL
#################################################
install: all pkgconfig_install
ifeq ("no","$(strip $(SYS_WIN))")
	$(mkdir_p) $(libdir) $(includedir)/ids
	# Copy libraries
	$(foreach sofile,$(filter %.so,$(TARGETS)),\
		$(INSTALL_DATA) -T $(sofile) $(libdir)/$(notdir $(sofile)).$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO); \
		ln -svfT $(notdir $(sofile)).$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO) $(libdir)/$(notdir $(sofile)).$(IMAS_MAJOR).$(IMAS_MINOR) ;\
		ln -svfT $(notdir $(sofile)).$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO) $(libdir)/$(notdir $(sofile)).$(IMAS_MAJOR) ;\
		ln -svfT $(notdir $(sofile)).$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO) $(libdir)/$(notdir $(sofile)) ;\
	)
	# Copy includes
	$(INSTALL_DATA) $(SRC_DIR)/*.h $(includedir)
	$(INSTALL_DATA) $(IDS_SRC_DIR)/*.h $(includedir)/ids
else
	$(mkdir_p) $(packagedir)/cppinterface/lib
	$(mkdir_p) $(packagedir)/cppinterface/include/ids
	# Copy libraries
	for OBJECT in `find . -type f \( -name "*.lib" -or -name "*.dll" \)`; do \
		cp $$OBJECT $(packagedir)/cppinterface/lib; \
	done
	# Copy includes
	cp $(SRC_DIR)/*.h $(packagedir)/cppinterface/include
	cp $(IDS_SRC_DIR)/*.h $(packagedir)/cppinterface/include/ids
endif

sources_install: $(SOURCES)
ifeq ("no","$(strip $(SYS_WIN))")
	$(mkdir_p) $(datadir)/src/cppinterface/ids
	$(INSTALL_DATA) $(IDS_SRC_DIR)/*.* $(datadir)/src/cppinterface/ids
	$(INSTALL_DATA) $(SRC_DIR)/*.* $(datadir)/src/cppinterface
endif

#################################################
#                    CLEAN
#################################################
clean: test-clean pkgconfig_clean
	$(RM) $(IDS_OBJ_FILES)
	$(RM) $(OBJ_FILES)
	$(RM) $(TARGETS)

clean-src: clean
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

PC_FILES = imas-cpp.pc
#----------------------- pkgconfig ---------------------
include ../Makefile.pkgconfig

#----------------------- classpath deps ---------------------
include ../Makefile.classpath

endif # IMAS_CPP=no?
