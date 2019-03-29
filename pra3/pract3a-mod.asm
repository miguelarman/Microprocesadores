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
	
	
	; Guarda los registros
	PUSH BX CX DX SI ES

	; Lee la direccion de la entrada
	LES BX, [BP + 6]				; BX contiene el offset del dato de entrada
									; ES contiene el segmento

	; Prepara los registros necesarios para el bucle
	MOV SI, 0
	MOV AL, 0
	MOV CL, 0

BUCLE_SUMA:
	MOV DL, ES:BX[SI]			; Carga en DX un digito del codigo de barras
	SUB DL, '0'					; Convertimos de ascii a binario
	
	; Opera con el digito
	TEST SI, 00000001b			; Comprueba si es par (impar al empezar en cero)
	JNZ ES_PAR
	
	ADD CL, DL					; Es impar. CL guarda la suma impar
	JMP CONTINUA_SUMA
ES_PAR:
	ADD AL, DL					; Es par. AL guarda la suma par
	
CONTINUA_SUMA:
	INC SI
	CMP SI, 12
	JNE BUCLE_SUMA
	
	; Sale del bucle. Calcula la suma
	MOV BL, 3
	MUL BL				; AL tiene la suma par por tres
	ADD CL, AL			; CL tiene la suma total
	
	MOV AL, CL
	XOR AH, AH			; AX tiene ahora la suma total
	
	; Calcula el digito de control
		
	MOV DX, 0
	MOV CX, 10
	DIV CX					; DX contiene el resto
	
	MOV BL, 10				; Restamos el resto de 10, para ver el digito de control
	SUB BL, DL
	CMP BL, 10
	JE BL_ES_DIEZ
CONTINUA_RESTO:
	MOV AL, BL				; Guardamos el resultado en AX para devolverlo
	XOR AH, AH				; El digito ocupa un byte (ponemos AH a cero
	
	; Recupera los valores anteriores de los registros
	POP ES SI DX CX BX
	POP BP
	RET

BL_ES_DIEZ:
	SUB BL, 10
	JMP CONTINUA_RESTO

_computeControlDigit ENDP



PUBLIC _decodeBarCode
_decodeBarCode PROC FAR
	RET
_decodeBarCode ENDP


_TEXT ENDS
END