IDSDEF= ../../../xml/IDSDef.xml
#IDSDEF= /work/imas/core/installer/src/3.11.0/ual/3.6.2/xml/IDSDef.xml
TESTDIR = ../testsuite

CXX=g++
CXXFLAGS=-pthread -g -O0 #-fPIC
LDFLAGS= #-pthread #-g

INCDIR=`pkg-config blitz --cflags` -I$(IMAS_PREFIX)/include
LIBDIR=-L$(IMAS_PREFIX)/lib
#LIBS=-limas-cpp -limas -lTreeShr -lTdiShr -lMdsShr -lMdsIpShr -lXTreeShr  `pkg-config blitz --libs`

LIBS=-limas-cpp -limas `pkg-config blitz --libs`


ALL_PROGS=  TestSuite 

all:$(ALL_PROGS)

install:

clean:
	$(RM) $(ALL_PROGS) *~ *.o

clean-src: clean
	$(RM) TestSuite.cpp

TestSuite: helper.o TestSuite.o
	$(CXX) $(LDFLAGS) -o $@  $^ $(LIBDIR) $(LIBS)


helper.o: helper.cpp
	$(CXX) $(INCDIR) $(CXXFLAGS) -c $<

TestSuite.o: TestSuite.cpp
	$(CXX) $(INCDIR) $(CXXFLAGS) -c $<


TestSuite.cpp:
	xsltproc TestSuiteCPP.xsl $(IDSDEF)  > TestSuite.cpp
	
	
test:  TestSuite
	./TestSuite
	
#RULES
#.SUFFIXES: .cpp

#.cpp.o:
#	  $(CXX) $(INCDIR) $(CXXFLAGS) -c $<

