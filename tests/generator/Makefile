include ../../../Makefile.common

export IMAS_PREFIX=$(UAL)

ifeq (,$(wildcard $(IMAS_PREFIX)))
$(error $$IMAS_PREFIX is unset)
endif

IDSDEF= $(IMAS_PREFIX)/xml/IDSDef.xml
TESTDIR = ../testsuite

ifeq "$(strip $(CC))" "icc"
CXX=icpc
LD=$(CXX)
CXXFLAGS=-g -O0 -fPIC -shared-intel
LDFLAGS=-g
else
CXX=g++
LD=$(CXX)
ifneq ("no","$(strip $(SYS_WIN))")
CXXFLAGS=-std=c++11 -pthread -g -O2 -Wa,-mbig-obj -fPIC
LDFLAGS=-g -pthread
else
CXXFLAGS=-std=c++11 -pthread -g -O0 -fPIC
LDFLAGS=-g -pthread
endif
endif

ifneq ("no","$(strip $(SYS_WIN))")
INCDIR= -I$(BLITZ_HOME)/include -I$(IMAS_PREFIX)/lowlevel -I../../src
LIBS= -L$(BLITZ_HOME)/lib -L$(IMAS_PREFIX)/lowlevel -L$(IMAS_PREFIX)/cppinterface/lib
LIBS+= $(IMAS_PREFIX)/cppinterface/lib/libimas-cpp.lib $(IMAS_PREFIX)/lowlevel/libimas.lib
LIBS+= $(BLITZ_HOME)/lib/libblitz.a
BINOUT=TestSuite.exe
CFLAGS+= -DWIN32
CXXFLAGS+= -DWIN32
else
INCDIR= `pkg-config blitz --cflags` -I$(IMAS_PREFIX)/lowlevel -I../../src
LIBS= -L$(IMAS_PREFIX)/lowlevel -L../../lib
LIBS+= -limas-cpp -limas `pkg-config blitz --libs`
BINOUT=TestSuite
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
LIBS+= -lssl -lcrypto
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


ALL_PROGS=$(BINOUT)

all:$(ALL_PROGS)

install:

clean:
	$(RM) $(ALL_PROGS) *~ *.o

clean-src: clean
	$(RM) TestSuite.cpp

$(BINOUT): helper.o TestSuite.o
	$(LD) $(LDFLAGS) -o $@ $^ $(LIBS)


helper.o: helper.cpp
	$(CXX) $(INCDIR) $(CXXFLAGS) -c $<

TestSuite.o: TestSuite.cpp
	$(CXX) $(INCDIR) $(CXXFLAGS) -c $<


TestSuite.cpp:
	xsltproc TestSuiteCPP.xsl $(IDSDEF)  > TestSuite.cpp
	
	
test: $(BINOUT)
	./$(BINOUT)

#RULES
#.SUFFIXES: .cpp

#.cpp.o:
#	  $(CXX) $(INCDIR) $(CXXFLAGS) -c $<

