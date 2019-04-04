;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 			SBM 2016. Practica 3 - Ejemplo					;
;   Pareja													;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
	MOV DI, 0

BUCLE_PRODUCT_CODE:
	MOV CX, 10
	DIV CX						; Dividimos entre 10 con 16 bits, luego el resto está en DX
	
	ADD DX, '0'					; Convertimos el resto de la división a ascii

	MOV SI, 11					; Calculamos el índice de la cadena en la que debe escribir
	SUB SI, DI
	MOV ES:BX[SI], DL
	
	XOR DX, DX					; Preparamos DX para la siguiente iteración, ya que el cociente está en AX

	INC DI						; Si ya ha escrito cinco dígitos termina el bucle
	CMP DI, 5
	JNE BUCLE_PRODUCT_CODE

	;;;;;;;;;;;;;;;;;;;;;
	; Código de empresa ;
	;;;;;;;;;;;;;;;;;;;;;
	
	; Guarda en AX el valor correspondiente al companyCode (2 bytes)
	MOV AX, [BP + 8]
	
	; Inicializa DX a 0 para la división
	XOR DX, DX
	
	; Realizamos cuatro pasos del algoritmo de la división para extraer 4 dígitos
	MOV DI, 0
	
BUCLE_COMPANY_CODE:
	MOV CX, 10
	DIV CX						; Dividimos entre 10 con 16 bits, luego el resto está en DX
	
	ADD DX, '0'					; Convertimos el resto de la división a ascii

	MOV SI, 6					; Calculamos el índice de la cadena en la que debe escribir
	SUB SI, DI
	MOV ES:BX[SI], DL
	
	XOR DX, DX					; Preparamos DX para la siguiente iteración, ya que el cociente está en AX

	INC DI						; Si ya ha escrito cuatro dígitos termina el bucle
	CMP DI, 4
	JNE BUCLE_COMPANY_CODE
	
	
	;;;;;;;;;;;;;;;;;;
	; Código de país ;
	;;;;;;;;;;;;;;;;;;
	
	; Guarda en AX el valor correspondiente al countryCode (2 bytes)
	MOV AX, [BP + 6]
	
	; Realizamos tres pasos del algoritmo de la división para extraer 3 dígitos
	MOV DI, 0
	
BUCLE_COUNTRY_CODE:
	MOV CX, 10
	DIV CX						; Dividimos entre 10 con 16 bits, luego el resto está en DX
	
	ADD DX, '0'					; Convertimos el resto de la división a ascii

	MOV SI, 2					; Calculamos el índice de la cadena en la que debe escribir
	SUB SI, DI
	MOV ES:BX[SI], DL
	
	XOR DX, DX					; Preparamos DX para la siguiente iteración, ya que el cociente está en AX

	INC DI						; Si ya ha escrito tres dígitos termina el bucle
	CMP DI, 3
	JNE BUCLE_COUNTRY_CODE
	
	
	; Recupera los valores anteriores de los registros y termina
RETORNO:
	POP SI DI ES DX CX BX AX
	POP BP
	RET
	
_createBarCode ENDP
_TEXT ENDS
END