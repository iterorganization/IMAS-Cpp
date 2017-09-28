IDSDEF= ../../../xml/IDSDef.xml
TESTDIR = ../testsuite

CXX=g++
LD=$(CXX)
CXXFLAGS=-g -O0 -D__USE_XOPEN2K8 -fPIC -pthread
LDFLAGS= -g -pthread

INCDIR=`pkg-config blitz --cflags` -I$(IMAS_PREFIX)/include
LIBDIR=-L$(MDSPLUS_DIR)/lib64 -L$(MDSPLUS_DIR)/lib -L$(IMAS_PREFIX)/lib
LIBS=-limas-cpp -limas -lTreeShr -lTdiShr -lMdsShr -lMdsIpShr -lXTreeShr  `pkg-config blitz --libs`

ALL_PROGS=  TestSuite 

all:$(ALL_PROGS)

install:

clean:
	  rm -f $(ALL_PROGS) *~ *.o

clean-src:
	rm -f TestSuite.cpp

TestSuite: helper.o TestSuite.o 
	  $(LD) $(LDFLAGS) $@.o -o $@ $(LIBDIR) $(LIBS)

#RULES
.SUFFIXES: .cpp

.cpp.o:
	  $(CXX) $(INCDIR) $(CXXFLAGS) -c $<

