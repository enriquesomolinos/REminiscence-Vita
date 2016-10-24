VERSION = 0.4.1
TARGET = REminiscence
TITLE_ID = SOMO00001
PSVITAIP = 192.168.0.199
SRCS = \
	main.cpp collision.cpp cutscene.cpp file.cpp fs.cpp game.cpp graphics.cpp  menu.cpp \
	mixer.cpp mod_player.cpp piege.cpp resource.cpp scaler.cpp seq_player.cpp sfx_player.cpp \
	staticres.cpp systemstub_sdl.cpp unpack.cpp util.cpp video.cpp ogg_player.cpp resource_aba.cpp
	
OBJS = $(SRCS:.cpp=.o)

INCDIR =-I/include -I/local/vitasdk/$(PREFIX)/include/vita2d  -I/local/vitasdk/$(PREFIX)/include/SDL2


SDL_CFLAGS = `sdl-config --cflags`
SDL_LIBS = `sdl-config --libs`

LIBS +=  -lSDL2  -lvita2d \
	     -lSceKernel_stub -lSceGxm_stub -lSceDisplay_stub -lSceCtrl_stub -lSceAudio_stub \
		 -lSceSysmodule_stub -lScePgf_stub -lSceCommonDialog_stub \
		 -lScePower_stub -lfreetype -lpng -ljpeg -lz -lm -lc
		 
PREFIX   = arm-vita-eabi
CC       = $(PREFIX)-gcc
CXX      = $(PREFIX)-g++
CFLAGS   =  $(INCDIR) -fpermissive  -Wl,-q -Wall -O3  -Wno-unused-variable -Wno-unused-but-set-variable -DPSVITA
CXXFLAGS = $(CFLAGS)  -std=c++11
ASFLAGS  = $(CFLAGS)


all: $(TARGET)-$(VERSION).vpk

%.vpk: eboot.bin
	vita-mksfoex  -s TITLE_ID=$(TITLE_ID) "$(TARGET)" param.sfo
	vita-pack-vpk -s param.sfo -b eboot.bin \
		--add pkg/sce_sys/icon0.png=sce_sys/icon0.png \
		--add pkg/sce_sys/livearea/contents/bg.png=sce_sys/livearea/contents/bg.png \
		--add pkg/sce_sys/livearea/contents/startup.png=sce_sys/livearea/contents/startup.png \
		--add pkg/sce_sys/livearea/contents/template.xml=sce_sys/livearea/contents/template.xml \
	$(TARGET)-$(VERSION).vpk
	
eboot.bin: $(TARGET).velf
	vita-make-fself -s $< $@
	
%.velf: %.elf	
	vita-elf-create $< $@

$(TARGET).elf: $(OBJS)
	$(CXX) $(CXXFLAGS) $^ $(LIBS) -o $@

%.o: %.png
	$(PREFIX)-ld -r -b binary -o $@ $^
%.o: %.txt
	$(PREFIX)-ld -r -b binary -o $@ $^

%.o : %.cpp
	$(CXX) -c $(CXXFLAGS) -o $@ $<
	
	
vpksend: $(TARGET)-$(VERSION).vpk
	curl -T $(TARGET)-$(VERSION).vpk ftp://$(PSVITAIP):1337/ux0:/
	@echo "Sent."
send: eboot.bin
	curl -T eboot.bin ftp://$(PSVITAIP):1337/ux0:/app/$(TITLE_ID)/
	@echo "Sent."
clean:
	@rm -rf *.velf *.elf *.vpk eboot.bin param.sfo *.o
