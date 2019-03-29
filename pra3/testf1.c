#include <stdio.h>
#include <stdlib.h>


/***** Declaracion de funciones *****/

/* Ejercicio 1 */

unsigned char computeControlDigit(char* barCodeASCII);


//////////////////////////////////////////////////////////////////////////
///// -------------------------- MAIN ------------------------------ /////
//////////////////////////////////////////////////////////////////////////
int main( void ){
	char barCodeStr[12];
	unsigned char controlDigit = 0;

	printf("Introduzca nuevo codigo de barras de 12 digitos: ");
	scanf("%s", &barCodeStr);
	

	controlDigit = computeControlDigit(barCodeStr);

	
	printf("- Codigo de control calculado - %u -\n", controlDigit);
	
	
	return 0;
}