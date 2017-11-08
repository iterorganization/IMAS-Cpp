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
GENERATED_SRC_DIR:=$(SRC_DIR)/ids
INCDIR=-I$(SRC_DIR) -I$(GENERATED_SRC_DIR) `pkg-config --cflags blitz` -I../lowlevel

IDSDEF= ../xml/IDSDef.xml
LIBS=-L../lowlevel `pkg-config blitz --libs` -limas
# LIBS_HDF5=   -L../lowlevel /afs/efda-itm.eu/project/switm/blitz/blitz-0.9_X86_64_GNU/lib/libblitz.a -limas_hdf5

GENERATED_H_FILES=$(wildcard $(GENERATED_SRC_DIR)/*.h)
GENERATED_GCH_FILES=$(addprefix cpo/,$(notdir $(GENERATED_H_FILES:.h=.h.gch)))

GENERATED_CPP_FILES=$(wildcard $(GENERATED_SRC_DIR)/*.cpp)
GENERATED_OBJ_FILES=$(addprefix $(BUILD_DIR)/,$(notdir $(GENERATED_CPP_FILES:.cpp=.o)))

H_FILES:=$(GENERATED_H_FILES)
OBJ_H_FILES:=$(GENERATED_GCH_FILES)

CPP_FILES:=$(GENERATED_CPP_FILES)
OBJ_FILES:= $(BUILD_DIR)/UALDef.o $(GENERATED_OBJ_FILES) $(BUILD_DIR)/UALMethods.o
OBJ_FILES:=  $(GENERATED_OBJ_FILES) $(BUILD_DIR)/UALMethods.o

# Check existence of the "indent" utility to get a clean C format
ifeq "$(shell which indent 2> /dev/null)" ""
 BEAUTIFY = cat
else
 BEAUTIFY = indent -kr --no-tabs -l1000
endif

all : libimas-cpp.so libimas-cpp.a pkgconfig

# Check that "saxon9he.jar" utility is set in CLASSPATH
SAXONICAJAR=$(wildcard $(filter %saxon9he.jar,$(subst :, ,$(CLASSPATH))))

ifeq "$(strip $(HDF5))" "yes"
 tests: cpptest cpptest_hdf5
else
 tests: cpptest
endif
	
install: all pkgconfig_install
	mkdir -p $(INSTALL)/lib $(INSTALL)/include
	for OBJECT in *.so ;do \
		cp -vT $$OBJECT $(INSTALL)/lib/$$OBJECT.$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO); \
		ln -svfT $$OBJECT.$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO)  $(INSTALL)/lib/$$OBJECT.$(IMAS_MAJOR).$(IMAS_MINOR); \
		ln -svfT $$OBJECT.$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO)  $(INSTALL)/lib/$$OBJECT.$(IMAS_MAJOR); \
		ln -svfT $$OBJECT.$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO)  $(INSTALL)/lib/$$OBJECT; \
	done
	cp UALClasses.h $(INSTALL)/include
	cp UALDef.h $(INSTALL)/include
	cp IdsDef.h $(INSTALL)/include

clean: clean-tests pkgconfig_clean
	rm -f *.o *.so *~ *.a

clean-src: clean
	rm -f UALClasses.h UALMethods.cpp

clean-tests:
	rm -f cpptest*


libimas-cpp.so :$(OBJ_FILES) 
	@mkdir -p $(LIB_DIR)
	$(LD) $(LDFLAGS) -o $(LIB_DIR)/$@ -Wl,-z,defs -shared -Wl,-soname,$@.$(IMAS_MAJOR).$(IMAS_MINOR)  UALMethods.o $(LIBS)

libimas-cpp.a : $(OBJ_FILES)  
	@mkdir -p $(LIB_DIR)
	ar rvs $(LIB_DIR)/$@ $^

$(BUILD_DIR)/UALMethods.o: $(SRC_DIR)/UALMethods.cpp $(SRC_DIR)/UALClasses.h 
	$(CXX) $(CXXFLAGS) $(INCDIR) -c  $(SRC_DIR)/UALMethods.cpp -o $@
	



#################################################
#              BUILD
#################################################



$(BUILD_DIR)/UALDef.o: $(SRC_DIR)/UALDef.cpp $(SRC_DIR)/UALDef.h 
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) $(INCDIR) -c $(SRC_DIR)/UALDef.cpp -o $@

$(BUILD_DIR)/%.o: $(GENERATED_SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) $(INCDIR) -c $(GENERATED_SRC_DIR)/$*.cpp -o $@


	
	
#$(H_FILES) UALClasses.h:  CPODef2CPPClasses.xsl 
#	#xsltproc CPODef2CPPClasses.xsl $(CPODEF)
	
%.h.gch: %.h    
	$(CXX) $(CXXFLAGS) $(INCDIR) -o $@ -c $<

#$(SRC_DIR)/UALDef.cpp $(CPP_FILES) UALMethods.cpp: CPODef2CPPMethods.xsl

$(BUILD_DIR)/UALClasses.h: IDSDef2CPPClasses.xsl $(IDSDEF)
	xsltproc IDSDef2CPPClasses.xsl $(IDSDEF) 

$(BUILD_DIR)/UALMethods.cpp: IDSDef2CPPMethods.xsl $(IDSDEF)
ifeq (,$(SAXONICAJAR))
	$(error Invalid /path/to/saxon9he.jar in CLASSPATH. Forgot to load module?)
endif
	java net.sf.saxon.Transform -t -s:$(IDSDEF) -xsl:IDSDef2CPPMethods.xsl   

#################################################
#                 INIT
#################################################
init:  $(BUILD_DIR)/UALClasses.h $(BUILD_DIR)/UALMethods.cpp
	mkdir -p $(BUILD_DIR)
	@touch init.tmp

check_init:
ifeq ($(wildcard init.tmp),) 
	@echo "Error: Environment not initialized. Please run 'make init' first"
	@exit 1	
endif


#################################################
#                 TESTS
#################################################

test:
	  $(MAKE) -C tests/generator test

test-clean:
	  $(MAKE) -C tests/generator clean

test-clean-src:
	  $(MAKE) -C tests/generator clean-src

PC_FILES = imas-cpp.pc
include ../Makefile.pkgconfig
endif # CPP=no?
