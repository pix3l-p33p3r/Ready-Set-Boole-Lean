export ELAN_HOME ?= /goinfre/elel-yak/elan
export PATH := $(ELAN_HOME)/bin:$(PATH)

.PHONY: all build test clean

all: build

build:
	lake build

test: build
	bash ./test.sh

clean:
	lake clean
