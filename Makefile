include ../Makefile.common

ifeq ("no","$(IMAS_CPP)")
$(warning "Ignoring cppinterface (IMAS_CPP=no).")
all:
clean:
clean-src:
install:
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


# Sets a path where make will search for files
VPATH = $(SRC_DIR) $(IDS_SRC_DIR) build lib


IDS_H_FILES=$(wildcard $(IDS_SRC_DIR)/*.h)
IDS_GCH_FILES=$(notdir $(IDS_H_FILES:.h=.h.gch))


IDS_CPP_FILES=$(wildcard $(IDS_SRC_DIR)/*.cpp)

H_FILES:=$(IDS_H_FILES)
OBJ_H_FILES:=$(IDS_GCH_FILES)

CPP_FILES= IdsDef.cpp UALMethods.cpp $(IDS_CPP_FILES)
OBJ_FILES=$(patsubst %.cpp,$(BUILD_DIR)/%.o,$(notdir $(CPP_FILES)))

# Check that "saxon9he.jar" utility is set in CLASSPATH
SAXONICAJAR=$(wildcard $(filter %saxon9he.jar,$(subst :, ,$(CLASSPATH))))

# Check existence of the "indent" utility to get a clean C format
ifeq "$(shell which indent 2> /dev/null)" ""
 BEAUTIFY = echo
else
 BEAUTIFY = indent -kr --no-tabs -l1000
endif

ifeq ($(strip $(IDS_CPP_FILES)),)
all:  
	@echo "Error: Source files have been not created. Please run 'make sources' first"
	@exit 1	
else
all:  libimas-cpp.so libimas-cpp.a pkgconfig

endif

	
#################################################
#                 INIT: SOURCE GENERATION
#################################################
generate_sources:  IDSDef2CPPClasses.xsl IDSDef2CPPMethods.xsl  $(IDSDEF)
	@mkdir -p $(BUILD_DIR)

	xsltproc IDSDef2CPPClasses.xsl $(IDSDEF) 

ifeq (,$(SAXONICAJAR))
	$(error Invalid /path/to/saxon9he.jar in CLASSPATH. Forgot to load module?)
endif
	java net.sf.saxon.Transform -t -s:$(IDSDEF) -xsl:IDSDef2CPPMethods.xsl   

beautify: generate_sources
	@for i in $(IDS_SRC_DIR)/*; do \
		echo Correcting indentation of $$i; \
		$(BEAUTIFY) $$i; \
	done 

	rm $(IDS_SRC_DIR)/*~

sources: generate_sources beautify
#################################################
#              BUILD
#################################################
libimas-cpp.so : $(OBJ_FILES) 
	@mkdir -p $(LIB_DIR)
	$(LD) $(LDFLAGS) -o $(LIB_DIR)/$@ -Wl,-z,defs -shared -Wl,-soname,$@.$(IMAS_MAJOR).$(IMAS_MINOR)   $(LIBS) $(OBJ_FILES)

libimas-cpp.a : $(OBJ_FILES)  
	@mkdir -p $(LIB_DIR)
	ar rvs $(LIB_DIR)/$@ $^

$(BUILD_DIR)/IdsDef.o: IdsDef.cpp 
	$(CXX) $(CXXFLAGS) $(INCDIR) -c $< -o $(@)

$(BUILD_DIR)/%.o: %.cpp IdsDef.o 
	$(CXX) $(CXXFLAGS) $(INCDIR) -c $< -o $(@)

	
%.h.gch: %.h    
	$(CXX) $(CXXFLAGS) $(INCDIR) -c $< -o $@ 

#################################################
#              INSTALL
#################################################
install: all pkgconfig_install
	mkdir -p $(INSTALL)/lib $(INSTALL)/include $(INSTALL)/include/ids
	@cd $(LIB_DIR) && \
	for OBJECT in *.so ;do \
		cp -vT $$OBJECT $(INSTALL)/lib/$$OBJECT.$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO); \
		ln -svfT $$OBJECT.$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO)  $(INSTALL)/lib/$$OBJECT.$(IMAS_MAJOR).$(IMAS_MINOR); \
		ln -svfT $$OBJECT.$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO)  $(INSTALL)/lib/$$OBJECT.$(IMAS_MAJOR); \
		ln -svfT $$OBJECT.$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO)  $(INSTALL)/lib/$$OBJECT; \
	done

	cp $(SRC_DIR)/*.h $(INSTALL)/include
	cp $(IDS_SRC_DIR)/*.h $(INSTALL)/include/ids

#################################################
#              CLEAN
#################################################
clean: test-clean pkgconfig_clean
	rm -f *.o *.so *~ *.a
	rm -rf ./build/*
	rm -rf ./lib/*

clean-src: clean
	rm -f src/UALClasses.h src/UALMethods.cpp
	rm -rf src/ids

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
endif # CPP=no?
