include ../../../Makefile.common

export IMAS_PREFIX=$(UAL)

ifeq (,$(wildcard $(IMAS_PREFIX)))
$(error $$IMAS_PREFIX is unset)
endif

IDSDEF= $(IMAS_PREFIX)/xml/IDSDef.xml
TESTDIR = ../testsuite

CXX=g++
LD=$(CXX)
CXXFLAGS=-std=gnu++11 -pthread -g -O0 -Wa,-mbig-obj -fPIC
LDFLAGS=-g #-pthread 

ifneq ("no","$(strip $(SYS_WIN))")
    INCDIR=-I$(BLITZ_HOME) -I$(IMAS_PREFIX)/include -I../../src
    LIBDIR=-L$(BLITZ_HOME)/lib/.libs -L$(IMAS_PREFIX)/lib -L$(IMAS_PREFIX)/cppinterface/lib
    LIBS=$(IMAS_PREFIX)/cppinterface/lib/libimas-cpp.lib -lblitz $(IMAS_PREFIX)/lib/libimas.lib
    LIBS+= $(MDSPLUS_HOME)/devtools/lib64/mingw/TreeShr.lib
    LIBS+= $(MDSPLUS_HOME)/devtools/lib64/mingw/TdiShr.lib
    LIBS+= $(MDSPLUS_HOME)/devtools/lib64/mingw/MdsShr.lib
    LIBS+= $(MDSPLUS_HOME)/devtools/lib64/mingw/XTreeShr.lib
    LIBS+= $(MDSPLUS_HOME)/devtools/lib64/mingw/MdsIpShr.lib
    LIBS+= $(MDSPLUS_HOME)/devtools/lib64/mingw/MdsObjectsCppShr.lib
	BINOUT=TestSuite.exe
    CFLAGS+= -DWIN32
    CXXFLAGS+= -DWIN32
else
    INCDIR=`pkg-config blitz --cflags` -I$(IMAS_PREFIX)/include
    LIBDIR=-L$(IMAS_PREFIX)/lib
    #LIBS=-limas-cpp -limas -lTreeShr -lTdiShr -lMdsShr -lMdsIpShr -lXTreeShr `pkg-config blitz --libs`
    LIBS=-limas-cpp -limas `pkg-config blitz --libs`
    BINOUT=TestSuite
endif

ALL_PROGS=$(BINOUT)

all:$(ALL_PROGS)

install:

clean:
	$(RM) $(ALL_PROGS) *~ *.o

clean-src: clean
	$(RM) TestSuite.cpp

$(BINOUT): helper.o TestSuite.o 
	$(LD) $(LDFLAGS) -o $@ $^ $(LIBDIR) $(LIBS)


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

