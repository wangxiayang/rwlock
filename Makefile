CC=coqtop -compile

default: extraction 

extraction: mymutex
	${CC} ExtractMutex

mymutex:
	${CC} MyMutex

clean:
	rm -f *.glob *.vo *.out *.cmi *.cmo *.cmx *.o *.mli

main:
	ocamlc MyMutex.mli
	ocamlc MyMutex.ml
	ocamlc -thread unix.cma threads.cma MyMutex.ml Main.ml

test1:
	ocamlc MyMutex.mli
	ocamlopt MyMutex.ml
	ocamlopt -thread unix.cmxa threads.cmxa MyMutex.cmx Test.ml

.PHONY: default extraction mymutex clean
