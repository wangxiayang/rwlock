CC=coqtop -compile

default: extraction 

extraction: mutex
	${CC} ExtractMutex

mutex:
	${CC} Mutex

clean:
	rm *.glob *.vo *.ml *.mli

.PHONY: default extraction mutex clean
