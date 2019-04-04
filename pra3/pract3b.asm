;**************************************************************************
;               SISTEMAS BASADOS EN MICROPROCESADORES - 2019			  ;
;                    PRÁCTICA 3: Diseño de programas					  ;
;                       utilizando C y ensamblador					  	  ;
;**************************************************************************
; Autores:																  ;
; 			- Miguel Arconada Manteca									  ;
;				(miguel.arconada@estudiante.uam.es)						  ;
; 			- Mario García Pascual										  ;
;				(mario.garciapascual@estudiante.uam.es)						  ;
;**************************************************************************
; Fecha:	4 de abril de 2019											  ;
;**************************************************************************
; Descripción:															  ;
;			En este fichero, realizamos una función que se puede ejecutar ;
;		desde un programa C: createBarCode								  ;
;																		  ;
;			En ella, se reciben los campos que forman cada campo del	  ;
;		código de barras como números, y se escribe una cadena de		  ;
;		caracteres que representa el código de barras como conjunción de  ;
;		estos campos: código de pais, código de empresa, código de		  ;
;		producto y dígito de control. Para ello, el programa principal	  ;
;		carga cada uno de los valores en DX:AX, especifica el número de   ;
;		dígitos y el offset para escribir en memoria, y llama a una		  ;
;		función auxiliar que realiza un bucle para cada dígito			  ;
;		implementando el  algoritmo de la división.						  ;
;**************************************************************************

DGROUP GROUP _DATA, _BSS				;; Se agrupan segmentos de datos en uno

_DATA SEGMENT WORD PUBLIC 'DATA' 		;; Segmento de datos DATA público

_DATA ENDS

_BSS SEGMENT WORD PUBLIC 'BSS'			;; Segmento de datos BSS público

_BSS ENDS

_TEXT SEGMENT BYTE PUBLIC 'CODE' 		;; Definición del segmento de código
ASSUME CS:_TEXT, DS:DGROUP, SS:DGROUP

PUBLIC _createBarCode
_createBarCode PROC FAR

	; Guarda los valores de los registros para no modificarlos
	PUSH BP
	
	; Guarda en BP el valor de SP
	MOV BP, SP
	
	; Guarda los registros para evitar modificaciones
	PUSH AX BX CX DX ES DI SI
	
	; Carga en ES:BX la dirección de la cadena de caracteres out_barCode
	LES BX, [BP + 16]
	
	MOV ES:BX[13], BYTE PTR 0	; Anadimos el \0 que necesita C para imprimir la cadena
	
	;;;;;;;;;;;;;;;;;;;;;
	; Dígito de control ;
	;;;;;;;;;;;;;;;;;;;;;
	
	; Guarda en AX el valor correspondiente al controlDigit (1 byte)
	MOV AL, [BP + 14]
	XOR AH, AH
	
	MOV CL, 10					; Queremos el último dígito si es más de uno
	DIV CL
	
	ADD AH, '0'					; Convertimos el valor (que será el resto en AH) a ascii
	
	MOV ES:BX[12], AH
	
	;;;;;;;;;;;;;;;;;;;;;;
	; Código de producto ;
	;;;;;;;;;;;;;;;;;;;;;;
	
	; Guarda en DX:AX el valor correspondiente al productCode (4 bytes)
	MOV AX, [BP + 10]
	MOV DX, [BP + 12]
	
	
	; Realizamos cinco pasos del algoritmo de la división para extraer 5 dígitos
	MOV SI, 5
	MOV DI, 7
	CALL ESCRIBIR_AUX

	;;;;;;;;;;;;;;;;;;;;;
	; Código de empresa ;
	;;;;;;;;;;;;;;;;;;;;;
	
	; Guarda en AX el valor correspondiente al companyCode (2 bytes)
	MOV AX, [BP + 8]
	
	; Inicializa DX a 0 para la división
	XOR DX, DX
	
	; Realizamos cuatro pasos del algoritmo de la división para extraer 4 dígitos
	MOV SI, 4
	MOV DI, 3
	CALL ESCRIBIR_AUX
	
	
	;;;;;;;;;;;;;;;;;;
	; Código de país ;
	;;;;;;;;;;;;;;;;;;
	
	; Guarda en AX el valor correspondiente al countryCode (2 bytes)
	MOV AX, [BP + 6]
	
	; Realizamos tres pasos del algoritmo de la división para extraer 3 dígitos
	MOV SI, 3
	MOV DI, 0
	CALL ESCRIBIR_AUX
	
	
	; Recupera los valores anteriores de los registros y termina
RETORNO:
	POP SI DI ES DX CX BX AX
	POP BP
	RET
	
_createBarCode ENDP



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Rutina auxiliar que escribe un cierto número de dígitos
; a una cierta posición de memoria
;
; Argumentos:
;	DX:AX	Valor a escribir
;	SI		Número de dígitos a escribir
;	DI		Offset para escribir en memoria
;	ES:BX	Dirección de memoria en la que escribir
;
; La primera posición para empezar a escribir será ES:BX[DI+SI-1]
;
; No retorna nada
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ESCRIBIR_AUX proc NEAR
	
	; Guarda los registros que va a modificar
	PUSH CX DI SI
	
	; Calcula el offset inicial para escribir
	ADD DI, SI
	DEC DI

BUCLE:
	MOV CX, 10
	DIV CX						; Dividimos entre 10 con 16 bits, luego el resto está en DX
	
	ADD DX, '0'					; Convertimos el resto de la división a ascii

	MOV ES:BX[DI], DL			; Escribe el dígito (entre 0 y 9, luego en un byte) en la posición de memoria
	
	XOR DX, DX					; Preparamos DX para la siguiente iteración, ya que el cociente está en AX

	DEC DI
	DEC SI						; Si ya ha escrito el número de dígitos especificado termina el bucle
	JNZ BUCLE
	
	; Recupera los valores anteriores de los registros que modifica
	POP SI DI CX
	RET

ESCRIBIR_AUX ENDP


_TEXT ENDS
END