include ../Makefile.common

ifeq ("no","$(CPP)")
$(warning "Ignoring cppinterface (CPP=no).")
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

IDAMDIR=$(HOME)/itmwork/IdamInstall
IDSDEF= ../xml/IDSDef.xml
INCDIR=`pkg-config blitz --cflags`  -I../lowlevel
LIBS=-L../lowlevel `pkg-config blitz --libs` -L$(IDAMDIR)/lib -lidam64 -limas
# LIBS_HDF5=   -L../lowlevel /afs/efda-itm.eu/project/switm/blitz/blitz-0.9_X86_64_GNU/lib/libblitz.a -limas_hdf5

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
		cp -v $$OBJECT $(INSTALL)/lib/$$OBJECT.$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO); \
		ln -svf $$OBJECT.$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO)  $(INSTALL)/lib/$$OBJECT.$(IMAS_MAJOR).$(IMAS_MINOR); \
		ln -svf $$OBJECT.$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO)  $(INSTALL)/lib/$$OBJECT.$(IMAS_MAJOR); \
		ln -svf $$OBJECT.$(IMAS_MAJOR).$(IMAS_MINOR).$(IMAS_MICRO)  $(INSTALL)/lib/$$OBJECT; \
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


libimas-cpp.so : UALMethods.o
	$(LD) $(LDFLAGS) -o $@ -Wl,-z,defs -shared -Wl,-soname,$@.$(IMAS_MAJOR).$(IMAS_MINOR)  UALMethods.o $(LIBS)

libimas-cpp.a : UALMethods.o
	ar rvs $@ $^

UALMethods.o: UALMethods.cpp UALClasses.h
	$(CXX) $(CXXFLAGS) -c $(INCDIR) UALMethods.cpp
	
UALClasses.h: IDSDef2CPPClasses.xsl $(IDSDEF)
	xsltproc IDSDef2CPPClasses.xsl $(IDSDEF) | $(BEAUTIFY) > UALClasses.h

UALMethods.cpp: IDSDef2CPPMethods.xsl $(IDSDEF)
ifeq (,$(SAXONICAJAR))
	$(error Invalid /path/to/saxon9he.jar in CLASSPATH. Forgot to load module?)
endif
	java net.sf.saxon.Transform -t -s:$(IDSDEF) -xsl:IDSDef2CPPMethods.xsl   | $(BEAUTIFY) > UALMethods.cpp

cpptest: cpptest.cpp
	$(CXX) -o $@ $(CXXFLAGS) $(INCDIR) $(LDFLAGS) libimas-cpp.so cpptest.cpp $(LIBS)

cpptest_hdf5: cpptest.cpp
	$(CXX) -o $@ -DHDF5 $(CXXFLAGS) $(INCDIR) $(LDFLAGS) libimas-cpp.so cpptest.cpp $(LIBS)

cpptest.cpp: IDSDef2CPPtests.xsl
	xsltproc IDSDef2CPPtests.xsl $(IDSDEF) | $(BEAUTIFY) > cpptest.cpp

PC_FILES = imas-cpp.pc
include ../Makefile.pkgconfig
endif # CPP=no?
