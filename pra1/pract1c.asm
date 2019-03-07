;**************************************************************************
; SBM 2019. ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR
;**************************************************************************
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT
;-- rellenar con los datos solicitados
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

	;Suponiendo que DS=0535H, BX=0210H y DI=1011H, determinar las direcciones de memoria
	;a las cuales acceden cada una de las siguientes instrucciones:
	;a) MOV AL,DS:[1234H]
	;b) MOV AX,[BX]
	;c) MOV [DI],AL
	
	;Realizar un programa donde se pueda comprobar la respuesta desde el TD. La inicialización de
	;contenidos necesarios es libre. Indicar en comentarios la dirección real prevista. 

	; Inicializa los valores del enunciado
	MOV AX, 0535H
	MOV DS, AX
	
	MOV BX, 0210H
	
	MOV AX, 1011H
	MOV DI, AX
	
	
	;; Accede a esas posiciones
	MOV AL, DS:[1234H]			; Accede a 0535h + 1234h = 1769h
	MOV AX, [BX]				; Accede a 0535h + 0210h = 0745h
	MOV [DI], AL				; Accede a 0535h + 1011h = 1546h
	
	;; Cuando se accede a estas posiciones, desde el debugger se puede ver a qué direcciones se accede




; FIN DEL PROGRAMA
MOV AX, 4C00H
INT 21H
INICIO ENDP
; FIN DEL SEGMENTO DE CODIGO
CODE ENDS
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END INICIO 