all: pract3.exe testf1.exe

pract3.exe: pract3.obj pract3a.obj pract3b.obj
	tcc -v -ml -Lc:\compila\tc\lib pract3.obj pract3a.obj pract3b.obj
pract3.obj: pract3.c
	tcc -c -v -ml -Ic:\compila\tc\include pract3.c
pract3a.obj: pract3a.asm
	tasm /zi /ml pract3a,,pract3a
pract3b.obj: pract3b.asm
	tasm /zi /ml pract3b,,pract3b

mod3a.obj: mod3a.asm
	tasm /zi /ml mod3a,,mod3a
testf1.exe: testf1.obj mod3a.obj
	tcc -v -ml -Lc:\compila\tc\lib testf1.obj mod3a.obj
testf1.obj: testf1.c
	tcc -c -v -ml -Ic:\compila\tc\include testf1.c

clean:
	del *.obj
	del *.exe
	del *.lst
	