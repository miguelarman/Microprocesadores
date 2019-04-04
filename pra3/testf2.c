/*********************************************************************
 * pract3.c
 *
 * Sistemas Basados en Microprocesador
 * 2018-2019
 * Practica 3
 * Codigos de Barras
 *
 *********************************************************************/
 
#include <stdio.h>
#include <stdlib.h>


/***** Declaracion de funciones *****/

/* Ejercicio 1 */

void decodeBarCode(unsigned char* in_barCodeASCII, unsigned int* countryCode, unsigned int* companyCode, unsigned long* productCode, unsigned char* controlDigit);

//////////////////////////////////////////////////////////////////////////
///// -------------------------- MAIN ------------------------------ /////
//////////////////////////////////////////////////////////////////////////
int main(void) {
	char barCodeStr1[14] = "1234567890123";
	char barCodeStr2[14] = "1231234999990";
	unsigned char barCodeDigits[13];
	unsigned int  countryCode, companyCode;
	unsigned long productCode;	
	unsigned char controlDigitCheck, controlDigit;

	decodeBarCode(barCodeStr1, &countryCode, &companyCode, &productCode, &controlDigit);
	printf("Codigo de barras leido:\n");
	printf("- Codigo de Pais - %u -\n",countryCode);
	printf("- Codigo de Empresa - %u -\n",companyCode);
	printf("- Codigo de Producto - %lu -\n",productCode);
	printf("- Codigo de Control - %u -\n",controlDigit);
	
	printf("Analiza uno\n");

	decodeBarCode(barCodeStr2, &countryCode, &companyCode, &productCode, &controlDigit);
	printf("Codigo de barras leido:\n");
	printf("- Codigo de Pais - %u -\n",countryCode);
	printf("- Codigo de Empresa - %u -\n",companyCode);
	printf("- Codigo de Producto - %lu -\n",productCode);
	printf("- Codigo de Control - %u -\n",controlDigit);

	return;
}