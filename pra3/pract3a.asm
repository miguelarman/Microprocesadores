;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 			SBM 2016. Practica 3 - Ejemplo					;
;   Pareja													;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DGROUP GROUP _DATA, _BSS				;; Se agrupan segmentos de datos en uno

_DATA SEGMENT WORD PUBLIC 'DATA' 		;; Segmento de datos DATA público
	SUMA_TOTAL dw 0
	SUMA_IMPAR dw 0
	SUMA_PAR dw 0
_DATA ENDS

_BSS SEGMENT WORD PUBLIC 'BSS'			;; Segmento de datos BSS público

_BSS ENDS

_TEXT SEGMENT BYTE PUBLIC 'CODE' 		;; Definición del segmento de código
ASSUME CS:_TEXT, DS:DGROUP, SS:DGROUP
			

PUBLIC _computeControlDigit
_computeControlDigit PROC FAR

	; Guarda los valores de los registros para no modificarlos
	PUSH BP
	PUSH AX BX CX DX SI ES
	
	; Carga el registro para DGROUP
	MOV AX, DGROUP
	MOV DS, AX
	
	; Guarda en BP el valor de SP
	MOV BP, SP

	; Lee la direccion de la entrada
	LES BX, [BP + 6]				; BX contiene el offset del dato de entrada
									; ES contiene el segmento

	; Prepara los registros necesarios para el bucle
	MOV SI, 0

BUCLE_SUMA:
	MOV DX, ES:BX[SI]			; Carga en DX un digito del codigo de barras
	SUB DX, 30					; Convertimos de ascii a binario
	
	; Opera con el digito
	TEST SI, 00000001b			; Comprueba si es par (impar al empezar en cero)
	JNZ ES_PAR
	
	ADD SUMA_IMPAR, DX			; Es impar
	JMP CONTINUA_SUMA
ES_PAR:
	ADD SUMA_PAR, DX			; Es par
	
CONTINUA_SUMA:
	INC SI
	CMP SI, 12
	JNE BUCLE_SUMA
	
	; Sale del bucle. Calcula la suma
	MOV AX, 3
	MOV CX, SUMA_PAR
	MUL CX
	MOV DX, SUMA_IMPAR
	ADD AX, DX
	MOV SUMA_TOTAL, AX
	
	; Calcula el digito de control
	MOV AX, SUMA_TOTAL
	MOV DL, 10
	DIV DL					; AH contiene el resto
	
	MOV AL, 10				; Restamos el resto de 10, para ver el digito de control
	SUB AL , AH				; El digito de control está en AL
	XOR AH, AH				; El digito ocupa un byte (ponemos AH a cero)
	
	
	
	; Recupera los valores anteriores de los registros
	POP ES SI DX CX BX AX
	POP BP
	RET



_computeControlDigit ENDP



PUBLIC _decodeBarCode
_decodeBarCode PROC FAR
	RET
_decodeBarCode ENDP


_TEXT ENDS
END