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
CXXFLAGS=-g -std=c++11 -D__USE_XOPEN2K8 -fPIC -Wno-write-strings -Wno-deprecated -pthread
LDFLAGS= -g -fPIC -pthread
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
LIBS+= $(MDSPLUS_DIR)/lib/TdiShr.a
LIBS+= $(MDSPLUS_DIR)/lib/TreeShr.a
LIBS+= $(MDSPLUS_DIR)/lib/MdsIpShr.a
LIBS+= $(MDSPLUS_DIR)/lib/MdsShr.a
LIBS+= -lxml2 -lws2_32 -ldl -liphlpapi
else
#LIBS+= -L$(MDSPLUS_DIR)/lib64 -L$(MDSPLUS_DIR)/lib
#LIBS+= -lMdsShr -lTreeShr -lTdiShr -lMdsLib -lMdsIpShr -lMdsObjectsCppShr -lXTreeShr
endif # SYS_WIN
endif # IMAS_MDSPLUS

ifneq ("no","$(strip $(IMAS_UDA))")
ifneq ("no","$(strip $(SYS_WIN))")
LIBS+= -L$(UDA_HOME)/lib
LIBS+= $(UDA_HOME)/lib/libuda_cpp.a
LIBS+= $(UDA_HOME)/lib/libportablexdr.a
LIBS+= -lws2_32 -lssl -lcrypto
else
#LIBS+= `pkg-config --libs uda-cpp`
#LIBS+= -lssl -lcrypto
endif # SYS_WIN
endif # IMAS_UDA

ifneq ("no","$(strip $(IMAS_HDF5))")
ifneq ("no","$(strip $(SYS_WIN))")
LIBS+= -L$(HDF5_HOME)/lib
LIBS+= $(HDF5_HOME)/lib/libhdf5.a -ldl -lz
else
#LIBS+= -L$(HDF5_HOME)/lib
#LIBS+= -lhdf5 -ldl -lz
endif # IMAS_HDF5
endif # SYS_WIN

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
GEN_H_FILES = $(addprefix $(IDS_SRC_DIR)/,$(IDS_H_FILES)) $(SRC_DIR)/UALClasses.h
GEN_CPP_FILES = $(addprefix $(IDS_SRC_DIR)/,$(IDS_CPP_FILES)) $(SRC_DIR)/UALMethods.cpp
GENSOURCES = $(GEN_H_FILES) $(GEN_CPP_FILES)
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

all: $(SOURCES) $(TARGETS) id_cpp_all

$(LIB_DIR) $(BUILD_DIR) $(libdir) $(includedir)/ids $(datadir)/src/cppinterface/ids:
	$(mkdir_p) $@

#################################################
#            INIT: SOURCE GENERATION
#################################################
sources: $(SOURCES) id_cpp_sources

# Use an intermediate target to enforce nonparallel generation.
# Gracefully skip generation of sources if not needed.
# Gracefully skip beautify of sources if not newly generated.
$(GEN_H_FILES): gen_h_files
	$(if $(wildcard $@~),@echo Correcting indentation of $@ ; $(BEAUTIFY) $@ && $(RM) $@~)
$(GEN_CPP_FILES): gen_cpp_files
	$(if $(wildcard $@~),@echo Correcting indentation of $@ ; $(BEAUTIFY) $@ && $(RM) $@~)
gen_h_files: IDSDef2CPPClasses.xsl $(IDSDEF) | saxonicajar $(BUILD_DIR)
	$(if $(call allnewerthan,$(GEN_H_FILES),$^),, xsltproc IDSDef2CPPClasses.xsl $(IDSDEF) && \
	  touch $(addsuffix ~,$(GEN_H_FILES)) )
gen_cpp_files: IDSDef2CPPMethods.xsl $(IDSDEF) | saxonicajar $(BUILD_DIR)
	$(if $(call allnewerthan,$(GEN_CPP_FILES),$^),,\
	  $(JAVA) net.sf.saxon.Transform -t -warnings:fatal -s:$(IDSDEF) -xsl:IDSDef2CPPMethods.xsl && \
	  touch $(addsuffix ~,$(GEN_CPP_FILES)) )

#################################################
#                    BUILD
#################################################
# Dynamic library
$(LIB_DIR)/libimas-cpp-$(DD_GIT_DESCRIBE).so.$(SO_NUM): $(OBJ_FILES) $(IDS_OBJ_FILES) | $(LIB_DIR)
	$(CXX) $(LDFLAGS) -o $@ -Wl,-z,defs -shared -Wl,-soname,$(@F) $^ $(LIBS)
$(LIB_DIR)/libimas-cpp-$(DD_GIT_DESCRIBE).so: %:%.$(SO_NUM)
	$(LN_S) $(<F) $@
$(LIB_DIR)/libimas-cpp.so:%.so:%-$(DD_GIT_DESCRIBE).so
	$(LN_S) $(<F) $@
$(LIB_DIR)/libimas-cpp.so_install: %.so_install:%-$(DD_GIT_DESCRIBE).so.$(SO_NUM) | $(libdir)
	$(INSTALL_DATA) $< $(libdir)
	$(LN_S) $(<F) $(libdir)/$(*F)-$(DD_GIT_DESCRIBE).so
	$(LN_S) $(<F) $(libdir)/$(*F).so

# Static library
$(LIB_DIR)/libimas-cpp-$(DD_GIT_DESCRIBE).a: $(OBJ_FILES) $(IDS_OBJ_FILES) | $(LIB_DIR)
	$(AR) rvs $@ $^
$(LIB_DIR)/libimas-cpp.a:%.a:%-$(DD_GIT_DESCRIBE).a
	$(LN_S) $(<F) $@
$(LIB_DIR)/libimas-cpp.a_install: %.a_install:%-$(DD_GIT_DESCRIBE).a | $(libdir)
	$(INSTALL_DATA) $< $(libdir)
	$(LN_S) $(<F) $(libdir)/$(*F).a

# Windows dynamic library
$(LIB_DIR)/libimas-cpp.dll: $(OBJ_FILES) $(IDS_OBJ_FILES) | $(LIB_DIR)
	$(CXX) $(LDFLAGS) -o $@ -shared -Wl,-soname,$(@F).$(SO_NUM) -Wl,--out-implib,$@.lib $^ $(LIBS)

# Windows static library
$(LIB_DIR)/libimas-cpp.lib: $(OBJ_FILES) $(IDS_OBJ_FILES) | $(LIB_DIR)
	$(AR) rcvsu $@ $^
	ranlib $@

$(OBJ_FILES): $(BUILD_DIR)/%.o : $(SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) $(INCDIR) -c $< -o $(@)

$(IDS_OBJ_FILES): $(BUILD_DIR)/%.o : $(OBJ_FILES) $(IDS_SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) $(INCDIR) -c $(lastword $^) -o $(@)

#################################################
#                  INSTALL
#################################################
ifeq ("no","$(strip $(SYS_WIN))")
install: all $(LIB_DIR)/libimas-cpp.so_install $(LIB_DIR)/libimas-cpp.a_install pkgconfig_install id_cpp_install | $(libdir) $(includedir)/ids
	$(INSTALL_DATA) $(SRC_DIR)/*.h $(includedir)
	$(INSTALL_DATA) $(IDS_SRC_DIR)/*.h $(includedir)/ids
else
install: all pkgconfig_install id_cpp_install
	$(mkdir_p) $(packagedir)/cppinterface/lib
	$(mkdir_p) $(packagedir)/cppinterface/include/ids
	$(mkdir_p) $(packagedir)/blitz/lib
	# Copy libraries
	for OBJECT in `find . -type f \( -name "*.lib" -or -name "*.dll" \)`; do \
		cp $$OBJECT $(packagedir)/cppinterface/lib; \
	done
	# Copy Blitz libraries
	cp $(BLITZ_HOME)/lib/libblitz.a $(packagedir)/blitz/lib
	# Copy includes
	cp $(SRC_DIR)/*.h $(packagedir)/cppinterface/include
	cp $(IDS_SRC_DIR)/*.h $(packagedir)/cppinterface/include/ids
endif

ifeq ("no","$(strip $(SYS_WIN))")
sources_install: $(SOURCES) id_cpp_sources_install | $(datadir)/src/cppinterface/ids
	$(INSTALL_DATA) $(IDS_SRC_DIR)/*.* $(datadir)/src/cppinterface/ids
	$(INSTALL_DATA) $(SRC_DIR)/*.* $(datadir)/src/cppinterface
else
sources_install: $(SOURCES)
endif

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
OBJECTCODE=cpp
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
