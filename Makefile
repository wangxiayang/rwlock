CC=coqtop -compile

default: extraction 

extraction: mymutex
	${CC} ExtractMutex

mymutex:
	${CC} MyMutex

clean:
	rm *.glob *.vo

main:
	ocamlc MyMutex.mli
	ocamlc MyMutex.ml
	ocamlc -thread unix.cma threads.cma MyMutex.ml Main.ml

test1:
	ocamlopt MyMutex.ml
	ocamlopt -thread unix.cmxa threads.cmxa MyMutex.cmx Test.ml

.PHONY: default extraction mymutex clean
