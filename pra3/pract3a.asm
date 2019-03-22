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
			

PUBLIC _computeControlDigit
_computeControlDigit PROC FAR

	; Guarda los valores de los registros para no modificarlos
	PUSH BP
	
	; Guarda en BP el valor de SP
	MOV BP, SP

	; Lee la direccion de la entrada

	; Prepara los registros necesarios para el bucle
	MOV SUMA_TOTAL, 0
	MOV SUMA_IMPAR, 0
	MOV SUMA_PAR, 0
	MOV CONTADOR, 0

BUCLE_SUMA:
	MOV U, CODIGO[CONTADOR]
	SUB U, 30				; Convertimos de ascii a binario
	
	; Opera con el digito
	TEST CONTADOR, 00000001b ; Comprueba si es par (impar al empezar en cero)
	JNZ ES_PAR
	
	ADD SUMA_IMPAR, U		; Es impar
	JMP CONTINUA_SUMA
ES_PAR:
	ADD SUMA_PAR, U			; Es par
	
CONTINUA_SUMA:
	INC CONTADOR
	CMP CONTADOR, 12
	JNE BUCLE_SUMA
	
	; Sale del bucle
	MUL SUMA_PAR, 3
	ADD SUMA_TOTAL, SUMA_PAR
	ADD SUMA_TOTAL, SUMA_IMPAR
	
	; Calcula el digito de control
	MOV AX, SUMA_TOTAL
	MOV DL, 10
	DIV DL					; AH contiene el resto
	
	MOV RESTO, AH
	MOV AX, 10
	SUB AX , RESTO
	
	; Guarda los valores de los registros para no modificarlo
	RET



_computeControlDigit ENDP



PUBLIC _decodeBarCode
_decodeBarCode PROC FAR
	RET
_decodeBarCode ENDP


_TEXT ENDS
END