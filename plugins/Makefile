#Adding DEBUG=yes to make command to print additional debug info
DBGFLAGS= -g
DBGFLAGS+= -DDEBUG

ifeq "$(strip $(CC))" "icc"
CXX=icpc
CXXFLAGS= -O0 -fPIC -shared-intel ${DBGFLAGS}
LDFLAGS=
else
CXX=g++
CXXFLAGS= -std=c++11 -pthread -O0 -fPIC ${DBGFLAGS}
#LDFLAGS= -shared -pthread -Wl,--no-undefined
LDFLAGS= -pthread
endif

#INCDIR= `pkg-config blitz --cflags` -I$(UAL_BUILD)/lowlevel -I$(UAL_BUILD)/cppinterface/src -I/work/imas/thermavip_4_imas/librir/src -I/work/imas/thermavip_4_imas/librir/src/Tools
INCDIR= `pkg-config blitz --cflags` -I$(UAL_BUILD)/lowlevel -I$(UAL_BUILD)/cppinterface/src -I/work/imas/thermavip_4_imas/librir
LIBS= -L$(UAL_BUILD)/lowlevel -L$(UAL_BUILD)/cppinterface/lib
LIBS+= -limas-cpp -limas `pkg-config blitz --libs` -L/work/imas/thermavip_4_imas/librir -lrir -lavcodec -lavfilter -lavutil -lavdevice -lavformat -lpostproc -lswresample -lswscale
#LIBS+= -limas-cpp -limas `pkg-config blitz --libs`
#LIBS+= -limas `pkg-config blitz --libs`
BINOUT=test_camera_plugin


GENSOURCES = test_camera_plugin.cpp

.PHONY: clean clean-src
all: $(BINOUT)
sources: $(GENSOURCES)
sources_install:
sources_uninstall:
install:
uninstall:
clean:
	$(RM) *.log *.o $(BINOUT)
clean-src: clean
	$(RM) $(GENSOURCES)


#  BUILD
$(BINOUT): test_camera_plugin.o
	$(CXX) $(LDFLAGS) -o $@ $^ $(LIBDIR) $(LIBS)
        
.SUFFIXES:.cpp
.cpp.o:
	$(CXX) $(INCDIR) $(CXXFLAGS) -c $< -o $@

