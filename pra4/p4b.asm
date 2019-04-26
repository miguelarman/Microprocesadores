;**************************************************************************
; SBM 2019. ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR
;**************************************************************************
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT
clear_pantalla		db	1BH,"[2","J$"

mensaje_inicial		db	"Informacion acerca de este programa:", 0Ah
					db	9h, "1- Muestra por pantalla la matriz polibia utilizada", 0Ah
					db	9h, "2- Codifica el mensaje de prueba prefijado", 0Ah
					db	9h, "3- Descodifica el mensaje de prueba prefijado", 0Ah
					db	"$"

mensaje_matriz		db	0Ah, "1- La matriz que hemos utilizado es la siguiente:", 0Ah, "$"
matriz				db	9h, "234567", 0Ah
					db	9h, "89ABCD", 0Ah
					db	9h, "EFGHIJ", 0Ah
					db	9h, "KLMNOP", 0Ah
					db	9h, "QRSTUV", 0Ah
					db	9h, "WXYZ01", 0Ah
					db	"$"
				
pmensaje			db	"2- El mensaje a cifrar es:", 0Ah, 9h, "$"
mensaje				db	"Mensaje predefinido$"

pmensaje_cifrado	db	0Ah, 0Ah, "3- El mensaje cifrado es:", 0Ah, 9h, "$"
mensaje_cifrado		db	32 dup ("C"), "$"

pmensaje_descifrado	db	0Ah, 0Ah, "4- El mensaje descifrado es:", 0Ah, 9h, "$"
mensaje_descifrado	db	32 dup ("D"), "$"
DATOS ENDS

;**************************************************************************
; DEFINICION DEL SEGMENTO DE PILA
PILA SEGMENT STACK "STACK"
DB 40H DUP (0) ;ejemplo de inicialización, 64 bytes inicializados a 0
PILA ENDS
;**************************************************************************
; DEFINICION DEL SEGMENTO EXTRA
EXTRA SEGMENT
;; Datos del segmento extra
EXTRA ENDS
;**************************************************************************

; DEFINICION DEL SEGMENTO DE CODIGO
CODE SEGMENT
	ASSUME CS: CODE, DS: DATOS, ES: EXTRA

; COMIENZO DEL PROCEDIMIENTO PRINCIPAL
INICIO PROC
	MOV AX, DATOS
	MOV DS, AX
	
	; COMIENZO DEL PROGRAMA
	
	call limpia_pantalla
	
	;Imprime mensaje inicial
	mov ah, 9
	mov dx, OFFSET mensaje_inicial
	int 21h
	
	; Imprime la matriz polibia utilizada
	mov ah, 9
	mov dx, OFFSET mensaje_matriz
	int 21h
	mov dx, OFFSET matriz
	int 21h
	
	; Muestra el mensaje original por pantalla
	mov ah, 9
	mov dx, OFFSET pmensaje
	int 21h
	mov dx, OFFSET mensaje
	int 21h
	
	; Codifica el mensaje original,
	; lo guarda en memoria
	; y lo muestra por pantalla
	
	mov ah, 9
	mov dx, OFFSET pmensaje_cifrado
	int 21h
	
	; TODO Codifica y guarda en mensaje_cifrado
		mov ah, 9
		mov dx, OFFSET mensaje_cifrado
		int 21h
	
	; Descodifica el mensaje obtenido
	; y lo muestra por pantalla
	
	mov ah, 9
	mov dx, OFFSET pmensaje_descifrado
	int 21h
	
	; TODO Decodifica el mensaje
		mov ah, 9
		mov dx, OFFSET mensaje_descifrado
		int 21h
	
	; FIN DEL PROGRAMA
	MOV AX, 4C00H
	INT 21H
INICIO ENDP

limpia_pantalla PROC
	push dx ax
	
	; Limpia la pantalla
	lea dx, clear_pantalla
	mov ah, 9
	INT 21H
	
	pop ax dx
	ret
limpia_pantalla ENDP


CODE ENDS
END INICIO