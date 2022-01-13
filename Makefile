SYMFORMAT=dwarf
FORMAT=elf
CFILE=gcd.c

gcdASM: gcdasm.o
	gcc -m32 -g -nostartfiles -o gcdASM gcdasm.o 

gcdasm.o: gcdasm.asm
	nasm -f $(FORMAT) -g -F $(SYMFORMAT) gcdasm.asm ;\
	gcc $(CFILE) -o gcdC

clean:
	rm -f gcdasm.o gcd.o gcdASM gcdC

