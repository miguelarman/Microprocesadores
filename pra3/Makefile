all: pract3.exe testf1.exe testf2.exe testf3.exe

pract3.exe: pract3.obj pract3a.obj pract3b.obj
	tcc -v -ml -Lc:\compila\tc\lib pract3.obj pract3a.obj pract3b.obj
pract3.obj: pract3.c
	tcc -c -v -ml -Ic:\compila\tc\include pract3.c
pract3a.obj: pract3a.asm
	tasm /zi /ml pract3a,,pract3a
pract3b.obj: pract3b.asm
	tasm /zi /ml pract3b,,pract3b
	
testf1.exe: testf1.obj pract3a.obj
	tcc -v -ml -Lc:\compila\tc\lib testf1.obj pract3a.obj
testf1.obj: testf1.c
	tcc -c -v -ml -Ic:\compila\tc\include testf1.c
	
testf2.exe: testf2.obj pract3a.obj
	tcc -v -ml -Lc:\compila\tc\lib testf2.obj pract3a.obj
testf2.obj: testf2.c
	tcc -c -v -ml -Ic:\compila\tc\include testf2.c

testf3.exe: testf3.obj pract3b.obj
	tcc -v -ml -Lc:\compila\tc\lib testf3.obj pract3b.obj
testf3.obj: testf3.c
	tcc -c -v -ml -Ic:\compila\tc\include testf3.c

clean:
	del *.obj
	del *.exe
	del *.lst
	