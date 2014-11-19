include ../Makefile.common

ifeq "$(strip $(CC))" "icc"
 CXX=icpc
 LD=$(CXX)
 CXXFLAGS=-g -fPIC -Wno-deprecated -pthread -shared-intel
 LDFLAGS= -g -pthread
else
 CXX=g++
 LD=$(CXX)
 CXXFLAGS=-g -fPIC -Wno-deprecated -pthread
 LDFLAGS= -g -pthread
endif

IDSDEF= ../xml/IDSDef.xml
INCDIR=-I$(BLITZ_DIR)/include -I$(BLITZ_DIR)  -I../lowlevel
LIBS=-L../lowlevel $(BLITZ_DIR)/lib/libblitz.a -lUALLowLevel
# LIBS_HDF5=   -L../lowlevel /afs/efda-itm.eu/project/switm/blitz/blitz-0.9_X86_64_GNU/lib/libblitz.a -lUALLowLevel_hdf5

# Check existence of the "indent" utiliy to get a clean C format
ifeq "$(shell which indent 2> /dev/null)" ""
 BEAUTIFY = cat
else
 BEAUTIFY = indent -kr --no-tabs -l1000
endif

all : libUALCPPInterface.so libUALCPPInterface.a

ifeq "$(strip $(HDF5))" "yes"
 tests: cpptest cpptest_hdf5
else
 tests: cpptest
endif
	
install: all
	cp *.so $(INSTALL)/lib
	cp UALClasses.h $(INSTALL)/include
	cp UALDef.h $(INSTALL)/include
	cp IdsDef.h $(INSTALL)/include

clean: clean-tests
	rm -f *.o *.so *~ *.a

clean-src: clean
	rm -f UALClasses.h UALMethods.cpp

clean-tests:
	rm -f cpptest*


libUALCPPInterface.so : UALMethods.o
	$(LD) $(LDFLAGS) -o $@ -shared  UALMethods.o $(LIBS_MDSPLUS)

libUALCPPInterface.a : UALMethods.o
	ar rvs $@ $^

UALMethods.o: UALMethods.cpp UALClasses.h
	$(CXX) $(CXXFLAGS) -c $(INCDIR) UALMethods.cpp
	
UALClasses.h: IDSDef2CPPClasses.xsl $(IDSDEF)
	xsltproc IDSDef2CPPClasses.xsl $(IDSDEF) | $(BEAUTIFY) > UALClasses.h

UALMethods.cpp: IDSDef2CPPMethods.xsl $(IDSDEF)
	xsltproc IDSDef2CPPMethods.xsl $(IDSDEF) | $(BEAUTIFY) > UALMethods.cpp

cpptest: cpptest.cpp
	$(CXX) -o $@ $(CXXFLAGS) $(INCDIR) $(LDFLAGS) libUALCPPInterface.so cpptest.cpp $(LIBS) -Wl,-rpath,../itmcatalog/lib

cpptest_hdf5: cpptest.cpp
	$(CXX) -o $@ -DHDF5 $(CXXFLAGS) $(INCDIR) $(LDFLAGS) libUALCPPInterface.so cpptest.cpp $(LIBS) -Wl,-rpath,../itmcatalog/lib

cpptest.cpp: IDSDef2CPPtests.xsl
	xsltproc IDSDef2CPPtests.xsl $(IDSDEF) | $(BEAUTIFY) > cpptest.cpp
