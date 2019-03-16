;**************************************************************************
; SBM 2019. ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR
;**************************************************************************
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT
;-- rellenar con los datos solicitados
	; MATRIZ db 9 dup (?)
	MATRIZ db 1, 2, 3, 4, 5, 6, 7, 8, 1
	resultado dw ?
	
	CLR_PANT 		DB 	1BH,"[2","J$"
	DET_A db 1BH,"[4;1f|A| =  ",?,"$"
	
	OFFSET_INICIAL_LINEA dw 7
	
	PRIMERA_LINEA db 1BH,"[3;7f|", ?, ?, ?, " ", ?, ?, ?, " ", ?, ?, ?, "|$"
	SEGUNDA_LINEA db 1BH,"[4;7f|", ?, ?, ?, " ", ?, ?, ?, " ", ?, ?, ?, "|$"
	TERCERA_LINEA db 1BH,"[5;7f|", ?, ?, ?, " ", ?, ?, ?, " ", ?, ?, ?, "|$"
	
	IGUAL_RESULTADO db 1BH,"[4;20f = ", ?, ?, ?, ?, ?, "$"
	OFFSET_RESULTADO dw 10
	
	VALOR_IMPRIMIR 	DB "-XY"
	RESULTADO_IMPRIMIR 	DB "+ASDF"
	
DATOS ENDS
;**************************************************************************
; DEFINICION DEL SEGMENTO DE PILA
PILA SEGMENT STACK "STACK"
DB 40H DUP (0) ;ejemplo de inicialización, 64 bytes inicializados a 0
PILA ENDS
;**************************************************************************
; DEFINICION DEL SEGMENTO EXTRA
EXTRA SEGMENT
RESULT DW 0,0 ;ejemplo de inicialización. 2 PALABRAS (4 BYTES)
EXTRA ENDS
;**************************************************************************
; DEFINICION DEL SEGMENTO DE CODIGO
CODE SEGMENT
ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA
; COMIENZO DEL PROCEDIMIENTO PRINCIPAL
INICIO PROC
; INICIALIZA LOS REGISTROS DE SEGMENTO CON SU VALOR
MOV AX, DATOS
MOV DS, AX
MOV AX, PILA
MOV SS, AX
MOV AX, EXTRA
MOV ES, AX
MOV SP, 64 ; CARGA EL PUNTERO DE PILA CON EL VALOR MAS ALTO
; FIN DE LAS INICIALIZACIONES


; COMIENZO DEL PROGRAMA

; Lectura de la matriz por entrada
CALL LECTURA


; Cálculo del determinante

; Inicializa el resultado a cero
MOV resultado, 0
; Subrutinas que calculan los productos de cada diagonal
MOV CX, 0
CALL DIAG_POS
ADD resultado, AX
MOV CX, 1
CALL DIAG_POS
ADD resultado, AX
MOV CX, 2
CALL DIAG_POS
ADD resultado, AX

MOV CX, 2
CALL DIAG_NEG
SUB resultado, AX
MOV CX, 1
CALL DIAG_NEG
SUB resultado, AX
MOV CX, 0
CALL DIAG_NEG
SUB resultado, AX

; Impresión del resultado por pantalla
CALL IMPRESION


; FIN DEL PROGRAMA
MOV AX, 4C00H
INT 21H


; ------------------------------------
; SUBRUTINAS
; ------------------------------------


;_______________________________________________________________ 
; SUBRUTINA PARA LEER UNA MATRIZ 3X3 POR LA PANTALLA 
; ENTRADA NINGUNA
; SALIDA GUARDA EN MEMORIA LA MATRIZ 
;_______________________________________________________________
LECTURA PROC NEAR
	RET
LECTURA ENDP



;_______________________________________________________________ 
; SUBRUTINA PARA CALCULAR UNA DIAGONAL POSITIVA DE UNA MATRIZ 
; ENTRADA CX: VALOR INICIAL DE LA SEGUNDA COORDENADA
; SALIDA AX=RESULTADO 
;_______________________________________________________________ 

DIAG_POS PROC NEAR 
    MOV AX, 1
	
	MOV BX, 0
	MOV SI, CX
	MUL MATRIZ[BX][SI]
	
	ADD BX, 3
	INC SI
	; if (si == 3) then si = 0
	CMP SI, 3
	JE REINICIA_SI_1
CONTINUA_1:
	MUL MATRIZ[BX][SI]
	
	ADD BX, 3
	INC SI
	; if (si == 3) then si = 0
	CMP SI, 3
	JE REINICIA_SI_2
CONTINUA_2:
	MUL MATRIZ[BX][SI]
	
    RET

REINICIA_SI_1: 
    MOV SI, 0
	JMP CONTINUA_1
REINICIA_SI_2: 
    MOV SI, 0
	JMP CONTINUA_2

DIAG_POS ENDP


;_______________________________________________________________ 
; SUBRUTINA PARA CALCULAR UNA DIAGONAL NEGATIVA DE UNA MATRIZ 
; ENTRADA CX: VALOR INICIAL DE LA SEGUNDA COORDENADA
; SALIDA AX=RESULTADO 
;_______________________________________________________________ 

DIAG_NEG PROC NEAR 
    MOV AX, 1
	
	MOV BX, 0
	MOV SI, CX
	MUL MATRIZ[BX][SI]
	; if (si == 0) then si = 3
	CMP SI, 0
	JE REINICIA_SI_NEG_1
	
CONTINUA_NEG_1:
	ADD BX, 3
	DEC SI
	MUL MATRIZ[BX][SI]
	; if (si == 0) then si = 3
	CMP SI, 0
	JE REINICIA_SI_NEG_2
	
CONTINUA_NEG_2:
	ADD BX, 3
	DEC SI
	MUL MATRIZ[BX][SI]
 
    RET

REINICIA_SI_NEG_1: 
    MOV SI, 3
	JMP CONTINUA_NEG_1
REINICIA_SI_NEG_2: 
    MOV SI, 3
	JMP CONTINUA_NEG_2

DIAG_NEG ENDP

;_______________________________________________________________ 
; SUBRUTINA PARA IMPRIMIR EL DETERMINANTE CALCULADO POR PANTALLA 
; ENTRADA NINGUNA (ESTÁ EN MEMORIA)
; SALIDA NINGUNA
;_______________________________________________________________
IMPRESION PROC NEAR

	; BORRA LA PANTALLA
	MOV AH,9	; BORRA LA PANTALLA
	MOV DX, OFFSET CLR_PANT
	INT 21H
	
	MOV DX,OFFSET DET_A
	INT 21H
	
	; Guarda el ascii del resultado y lo imprime
	MOV BP, OFFSET_RESULTADO
	
	MOV CX, resultado
	CALL CONVERT_ASCII_5
	
	MOV AL, RESULTADO_IMPRIMIR[0]
	MOV IGUAL_RESULTADO[BP + 0], AL
	MOV AL, RESULTADO_IMPRIMIR[1]
	MOV IGUAL_RESULTADO[BP + 1], AL
	MOV AL, RESULTADO_IMPRIMIR[2]
	MOV IGUAL_RESULTADO[BP + 2], AL
	MOV AL, RESULTADO_IMPRIMIR[3]
	MOV IGUAL_RESULTADO[BP + 3], AL
	MOV AL, RESULTADO_IMPRIMIR[4]
	MOV IGUAL_RESULTADO[BP + 4], AL
	
	MOV DX,OFFSET IGUAL_RESULTADO
	INT 21H
	
	; _________________________________________________________________
	; Modifica los valores de la primera fila de la matriz y la imprime
	; _________________________________________________________________
	
	; Primer valor
	MOV BP, OFFSET_INICIAL_LINEA
	
	MOV CL, MATRIZ[0][0]
	CALL CONVERT_ASCII_3
	
	MOV AL, VALOR_IMPRIMIR[0]
	MOV PRIMERA_LINEA[BP + 0], AL
	MOV AL, VALOR_IMPRIMIR[1]
	MOV PRIMERA_LINEA[BP + 1], AL
	MOV AL, VALOR_IMPRIMIR[2]
	MOV PRIMERA_LINEA[BP + 2], AL
	
	
	; Segundo valor
	ADD BP, 4
	
	MOV CL, MATRIZ[0][1]
	CALL CONVERT_ASCII_3
	
	MOV AL, VALOR_IMPRIMIR[0]
	MOV PRIMERA_LINEA[BP + 0], AL
	MOV AL, VALOR_IMPRIMIR[1]
	MOV PRIMERA_LINEA[BP + 1], AL
	MOV AL, VALOR_IMPRIMIR[2]
	MOV PRIMERA_LINEA[BP + 2], AL
	
	
	; Tercer valor
	ADD BP, 4
	
	MOV CL, MATRIZ[0][2]
	CALL CONVERT_ASCII_3
	
	MOV AL, VALOR_IMPRIMIR[0]
	MOV PRIMERA_LINEA[BP + 0], AL
	MOV AL, VALOR_IMPRIMIR[1]
	MOV PRIMERA_LINEA[BP + 1], AL
	MOV AL, VALOR_IMPRIMIR[2]
	MOV PRIMERA_LINEA[BP + 2], AL
	
	; Imprime la linea
	MOV DX,OFFSET PRIMERA_LINEA
	INT 21H
	
	; _________________________________________________________________
	; Modifica los valores de la segunda fila de la matriz y la imprime
	; _________________________________________________________________
	
	; Primer valor
	MOV BP, OFFSET_INICIAL_LINEA
	
	MOV CL, MATRIZ[3][0]
	CALL CONVERT_ASCII_3
	
	MOV AL, VALOR_IMPRIMIR[0]
	MOV SEGUNDA_LINEA[BP + 0], AL
	MOV AL, VALOR_IMPRIMIR[1]
	MOV SEGUNDA_LINEA[BP + 1], AL
	MOV AL, VALOR_IMPRIMIR[2]
	MOV SEGUNDA_LINEA[BP + 2], AL
	
	
	; Segundo valor
	ADD BP, 4
	
	MOV CL, MATRIZ[3][1]
	CALL CONVERT_ASCII_3
	
	MOV AL, VALOR_IMPRIMIR[0]
	MOV SEGUNDA_LINEA[BP + 0], AL
	MOV AL, VALOR_IMPRIMIR[1]
	MOV SEGUNDA_LINEA[BP + 1], AL
	MOV AL, VALOR_IMPRIMIR[2]
	MOV SEGUNDA_LINEA[BP + 2], AL
	
	
	; Tercer valor
	ADD BP, 4
	
	MOV CL, MATRIZ[3][2]
	CALL CONVERT_ASCII_3
	
	MOV AL, VALOR_IMPRIMIR[0]
	MOV SEGUNDA_LINEA[BP + 0], AL
	MOV AL, VALOR_IMPRIMIR[1]
	MOV SEGUNDA_LINEA[BP + 1], AL
	MOV AL, VALOR_IMPRIMIR[2]
	MOV SEGUNDA_LINEA[BP + 2], AL
	
	; Imprime la linea
	MOV DX,OFFSET SEGUNDA_LINEA
	INT 21H
	
	; _________________________________________________________________
	; Modifica los valores de la tercera fila de la matriz y la imprime
	; _________________________________________________________________
	
	; Primer valor
	MOV BP, OFFSET_INICIAL_LINEA
	
	MOV CL, MATRIZ[6][0]
	CALL CONVERT_ASCII_3
	
	MOV AL, VALOR_IMPRIMIR[0]
	MOV TERCERA_LINEA[BP + 0], AL
	MOV AL, VALOR_IMPRIMIR[1]
	MOV TERCERA_LINEA[BP + 1], AL
	MOV AL, VALOR_IMPRIMIR[2]
	MOV TERCERA_LINEA[BP + 2], AL
	
	
	; Segundo valor
	ADD BP, 4
	
	MOV CL, MATRIZ[6][1]
	CALL CONVERT_ASCII_3
	
	MOV AL, VALOR_IMPRIMIR[0]
	MOV TERCERA_LINEA[BP + 0], AL
	MOV AL, VALOR_IMPRIMIR[1]
	MOV TERCERA_LINEA[BP + 1], AL
	MOV AL, VALOR_IMPRIMIR[2]
	MOV TERCERA_LINEA[BP + 2], AL
	
	
	; Tercer valor
	ADD BP, 4
	
	MOV CL, MATRIZ[6][2]
	CALL CONVERT_ASCII_3
	
	MOV AL, VALOR_IMPRIMIR[0]
	MOV TERCERA_LINEA[BP + 0], AL
	MOV AL, VALOR_IMPRIMIR[1]
	MOV TERCERA_LINEA[BP + 1], AL
	MOV AL, VALOR_IMPRIMIR[2]
	MOV TERCERA_LINEA[BP + 2], AL
	
	; Imprime la linea
	MOV DX,OFFSET TERCERA_LINEA
	INT 21H
	
	RET
IMPRESION ENDP


;_______________________________________________________________ 
; SUBRUTINA PARA CONVERTIR UN NUMERO A TRES DIGITOS ASCII (INCLUIDO SIGNO)
; ENTRADA CL: NUMERO A CONVERTIR
; SALIDA GUARDA EN VALOR_IMPRIMIR LOS TRES DIGITOS
;_______________________________________________________________ 

CONVERT_ASCII_3 PROC NEAR 
    RET
CONVERT_ASCII_3 ENDP


;_______________________________________________________________ 
; SUBRUTINA PARA CONVERTIR UN NUMERO A CINCO DIGITOS ASCII (INCLUIDO SIGNO)
; ENTRADA CX: NUMERO A CONVERTIR
; SALIDA GUARDA EN RESULTADO_IMPRIMIR LOS TRES DIGITOS
;_______________________________________________________________ 

CONVERT_ASCII_5 PROC NEAR 
    RET
CONVERT_ASCII_5 ENDP

INICIO ENDP
; FIN DEL SEGMENTO DE CODIGO
CODE ENDS
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END INICIO