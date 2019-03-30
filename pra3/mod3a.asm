;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 			SBM 2016. Practica 3 - Primeras dos funciones	;
;   Pareja													;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DGROUP GROUP _DATA, _BSS				;; Se agrupan segmentos de datos en uno

_DATA SEGMENT WORD PUBLIC 'DATA' 		;; Segmento de datos DATA público

_DATA ENDS

_BSS SEGMENT WORD PUBLIC 'BSS'			;; Segmento de datos BSS público

_BSS ENDS

_TEXT SEGMENT BYTE PUBLIC 'CODE' 		;; Definición del segmento de código
ASSUME CS:_TEXT, DS:DGROUP, SS:DGROUP


PUBLIC _computeControlDigit
_computeControlDigit PROC FAR

	; Guarda los valores de los registros para no modificarlos
	PUSH BP
	
	; Guarda en BP el valor de SP
	MOV BP, SP
	
	; Guarda los registros para evitar modificaciones (excepto AX pues se usa para devolver) 
	PUSH BX CX DX SI ES

	; Lee la direccion de la entrada del argumento
	LES BX, [BP + 6]		; BX contiene el offset del dato de entrada y ES contiene el segmento

	; Prepara los registros necesarios para el bucle
	MOV SI, 0				; SI servirá como índice del caracter leído
	MOV DL, 0				; DL guardará cada caracter leído
	MOV AL, 0				; AL guarda la suma de los números en posición par
	MOV CL, 0				; CL guarda la suma de los números en posición impar

BUCLE_SUMA:
	MOV DL, ES:BX[SI]		; Carga en DL un digito del codigo de barras
	SUB DL, '0'				; Convertimos de ascii a binario
	
	; Opera con el digito
	TEST SI, 00000001b		; Comprueba si es par (impar al empezar en cero)
	JNZ ES_PAR
	
	ADD CL, DL				; Es impar. Lo suma a CL
	JMP CONTINUA_SUMA
ES_PAR:
	ADD AL, DL				; Es par. Lo suma a AL
	
CONTINUA_SUMA:
	INC SI					; Actualiza el índice
	CMP SI, 12				; Si es 12 (ya se han leído los doce caracteres) sale del bucle
	JNE BUCLE_SUMA
	
	; Sale del bucle. Calcula la suma
	MOV BL, 3
	MUL BL					; AL ahora contiene la suma par multiplicada por tres
	ADD CL, AL				; CL tiene la suma total
	
	MOV AL, CL				; Guardamos la suma total en AX, por lo que ponemos AH a 0
	XOR AH, AH			
	
	; Calcula el digito de control
		
	MOV DX, 0
	MOV CX, 10				; Dividimos la suma total entre diez para ver el último dígito
	DIV CX					; DX contiene el resto
	
	MOV BX, 10				; Restamos el resto de 10, para ver el digito de control
	SUB BX, DX
	
	CMP BX, 10				; Comprobamos si la resta devuelve 10, cuando el último dígito es 0
	JE BL_ES_DIEZ
	
CONTINUA_RESTO:
	MOV AX, BX				; Guardamos el resultado de la resta en AX para devolverlo
	XOR AH, AH				; El digito ocupa un byte (ponemos AH a cero)
	
	; Recupera los valores anteriores de los registros
	POP ES SI DX CX BX
	POP BP
	RET

BL_ES_DIEZ:
	SUB BL, 10				; Restamos diez si el caracter de control sale 10 (debería ser 0)
	JMP CONTINUA_RESTO

_computeControlDigit ENDP



PUBLIC _decodeBarCode
_decodeBarCode PROC FAR
	RET
_decodeBarCode ENDP


_TEXT ENDS
END