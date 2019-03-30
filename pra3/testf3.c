#include <stdio.h>
#include <stdlib.h>


/***** Declaracion de funciones *****/

/* Ejercicio 1 */

void createBarCode(int countryCode, unsigned int companyCode, unsigned long productCode, unsigned char controlDigit, char* out_barCodeASCII);

//////////////////////////////////////////////////////////////////////////
///// -------------------------- MAIN ------------------------------ /////
//////////////////////////////////////////////////////////////////////////

int main( void ){
	char barCodeStr[14] = {0};
	unsigned int countryCode = 4333;
	unsigned int companyCode = 54444;
	unsigned long productCode = 655555;
	unsigned char controlDigit = 21;
	
	createBarCode(countryCode, companyCode, productCode, controlDigit, barCodeStr);
	
	printf("Codigo de barras creado: %s\n", barCodeStr);
	
	
	return 0;
}