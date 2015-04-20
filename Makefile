CC=coqtop -compile

default: extraction 

extraction: mymutex
	${CC} ExtractMutex

mymutex:
	${CC} MyMutex

clean:
	rm *.glob *.vo

main:
	ocamlc -thread unix.cma threads.cma Main.ml

.PHONY: default extraction mymutex clean
