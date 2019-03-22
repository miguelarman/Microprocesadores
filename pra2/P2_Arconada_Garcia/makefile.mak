all: pract2.exe

pract2.exe: pract2.obj
	tlink /v pract2
pract2.obj: pract2.asm 
	tasm /zi /m2 pract2.asm,,pract2.lst