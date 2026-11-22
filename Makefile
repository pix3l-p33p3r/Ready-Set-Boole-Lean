export ELAN_HOME ?= /goinfre/elel-yak/elan
export PATH := $(ELAN_HOME)/bin:$(PATH)

.PHONY: all build test clean

all: build

build:
	lake build

test: build
	@echo "== ex00 =="; .lake/build/bin/ex00 2 3
	@echo "== ex01 =="; .lake/build/bin/ex01 7 8
	@echo "== ex02 =="; .lake/build/bin/ex02 8
	@echo "== ex03 =="; .lake/build/bin/ex03 '10&'
	@echo "== ex04 =="; .lake/build/bin/ex04 'AB&C|'
	@echo "== ex05 =="; .lake/build/bin/ex05 'AB&!'
	@echo "== ex06 =="; .lake/build/bin/ex06 'AB&!'
	@echo "== ex07 =="; .lake/build/bin/ex07 'AB|'
	@echo "== ex08 =="; .lake/build/bin/ex08
	@echo "== ex09 =="; .lake/build/bin/ex09
	@echo "== ex10 =="; .lake/build/bin/ex10 0 0
	@echo "== ex11 =="; .lake/build/bin/ex11 0

clean:
	lake clean
