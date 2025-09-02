all: main

.PHONY: all clean
clean:
	rm -f main.d main.i main.s main.o main header.h.gch main
	# gcc -fdump-tree-all 

main.c: header.h.gch

main.d: main.c # dependency files (main.o main.d: main.c header.h.gch)
	echo "" > $@

main.s: main.d
	@# preprocessor
	cpp -E -dD main.c -o main.i
	@# assembly output. if you want to use gcc run `gcc -S main.i -o main.s`
	/usr/libexec/gcc/x86_64-pc-linux-gnu/14/cc1 main.i -o main.s

main.o: main.s # compilation (assembly)
	as -c $^ -o $@

main: main.o # linking
	@# /lib64/ld-linux-x86-64.so.2 $^ -o $@ -lc /lib64/crt1.o # says "only ET_DYN and ET_EXEC can be loaded"

	@#ld $^ -o $@ -lc /lib64/crt1.o    # this links but the dependencies have to be linked dynamically
	@#/lib64/ld-linux-x86-64.so.2 ./$@ # done like this

	@# while it is *possible* to statically link that isnt advised (dynamic then static demo)
	@# https://stackoverflow.com/questions/26304531
	ld $^ -o $@ -lc /lib64/crt1.o -dynamic-linker /lib64/ld-linux-x86-64.so.2
	@#ld -static /usr/lib64/crt1.o /usr/lib64/crti.o main.o -L/usr/lib/gcc/x86_64-pc-linux-gnu/14 -lc -lgcc -lgcc_eh /usr/lib64/crtn.o -o main -lc

%.h.gch: %.h
	gcc -c $^ -o $@

# -include *.d
