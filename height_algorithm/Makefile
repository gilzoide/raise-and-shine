CC = clang
DEBUG ?= 0
ifeq ($(DEBUG), 1)
	CFLAGS = -DDEBUG -g -O0
else
	CFLAGS = -DNDEBUG -O3
endif
BUILD_DIR = ../src/native

default: linux64


height_algorithm_%: height_algorithm.c
	$(CC) -o $(BUILD_DIR)/$@ $^ $(CFLAGS) -I. -Igodot-headers

height_algorithm_win32.dll: CFLAGS += -target i686-pc-windows-gnu -shared
height_algorithm_win64.dll: CFLAGS += -target x86_64-pc-windows-gnu -shared
height_algorithm_linux32.so: CFLAGS += -target i686-unknown-linux -fPIC -shared
height_algorithm_linux64.so: CFLAGS += -target x86_64-unknown-linux -fPIC -shared
height_algorithm_wasm32.wasm: CC = emcc
height_algorithm_wasm32.wasm: CFLAGS += -s SIDE_MODULE=1

win32: height_algorithm_win32.dll
win64: height_algorithm_win64.dll
linux32: height_algorithm_linux32.so
linux64: height_algorithm_linux64.so
wasm32: height_algorithm_wasm32.wasm

all: win32 win64 linux32 linux64 wasm32
