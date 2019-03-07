;**************************************************************************
; SBM 2019. ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR
;**************************************************************************
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT
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


	; Cargar 15H en AX
	MOV AX, 15h		; Cargas de valores a registro

	; Cargar BBH en BX
	MOV BX, 0BBh
	
	; Cargar 3412H en CX
	MOV CX, 3412h
	
	; Cargar el contenido de CX en DX
	MOV DX, CX		; Simple asignación de registros
	
	; Cargar en BH el contenido de la posición de memoria 65536H y en BL en contenido de la posición 65537H
	MOV AX, 6553H			;;; Ponemos 6553h y no 6553Xh, porque al sumarse el segmento para calcular la dirreción se desplaza cuatro bits a la izquierda
	MOV DS, AX
	MOV BH, DS:[6H]
	MOV BL, DS:[7H]
	
	; Cargar en la posición de memoria 50005H el contenido de CH
	MOV AX, 5000h 			; En este caso, el valor de DS va a ser 5000h y el offset 5h
	MOV DS, AX
	MOV CH, DS:[5H]
	
	; Cargar en AX el contenido de la dirección de memoria apuntada por SI
	MOV AX, 0h				; Ahora DS se guarda a 0, para que las direcciones sean solamente el offset
	MOV DS, AX
	MOV AX, DS:[SI]
	
	; Cargar en BX el contenido de la dirección de memoria que está 10 bytes por encima de la dirección apuntada por BP
	MOV AX, 0h
	MOV SS, AX
	MOV BX, SS:[BP + 10] ; El offset es BP sumado 10 posiciones (bytes)


; FIN DEL PROGRAMA
MOV AX, 4C00H
INT 21H
INICIO ENDP
; FIN DEL SEGMENTO DE CODIGO
CODE ENDS
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END INICIO 