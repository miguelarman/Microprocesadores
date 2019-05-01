;**************************************************************************
;               SISTEMAS BASADOS EN MICROPROCESADORES - 2019			  ;
;                    PRÁCTICA 4: Diseño de programas                      ;
;                              residentes                                 ;
;**************************************************************************
; Autores:																  ;
; 			- Miguel Arconada Manteca									  ;
;				(miguel.arconada@estudiante.uam.es)						  ;
; 			- Mario García Pascual										  ;
;				(mario.garciapascual@estudiante.uam.es)					  ;
;**************************************************************************
; Fecha:	2 de mayo de 2019											  ;
;**************************************************************************
; Descripción:															  ;
;			En este fichero, realizamos un programa en ensamblador para   ;
;		probar la instalación del driver creado en el fichero p4a.com.    ;
;       Para ello, ciframos y desciframos una cadena con la interrupción  ;
;       57h, para ver si funciona correctamente y el resultado final es   ;
;       igual a la cadena original, sea cual sea la cadena,               ;
;**************************************************************************

datos SEGMENT
; Comando para limpiar la pantalla
clear_pantalla		db	1BH,"[2","J$"

; Mensajes que se van a mostrar por la pantalla
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
mensaje				db	"ALLCATSAREBEAUTIFUL$"

pmensaje_cifrado	db	0Ah, 0Ah, "3- El mensaje cifrado es:", 0Ah, 9h, "$"

mensaje_cifrado		db	"23424225235453235231243123555435325542$"

pmensaje_descifrado	db	0Ah, 0Ah, "4- El mensaje descifrado es:", 0Ah, 9h, "$"

pmensaje_final		db	0Ah, 0Ah, "Si el mensaje descifrado es igual al mensaje inicial", 0Ah
					db	"entonces se puede comprobar que este programa funciona", 0Ah
					db	"correctamente"
					db	"$"
datos ENDS

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

code segment
	assume cs: code, ds: datos

inicio PROC
	mov ax, datos
	mov ds, ax
	
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
	
	; Codifica y guarda en mensaje_cifrado
	;con que el ds apunte a los datos y metas en dx el offset valdra
	mov ax, datos
	mov ds, ax
	mov dx, OFFSET mensaje
	mov ah, 10h
	int 57h
	
	; Descodifica el mensaje obtenido
	; y lo muestra por pantalla
	
	mov ah, 9
	mov dx, OFFSET pmensaje_descifrado
	int 21h
	
	; Decodifica el mensaje
	mov ax, datos
	mov ds, ax
	mov dx, OFFSET mensaje_cifrado
	mov ah, 11h
	int 57h
	
	; Imprime mensaje final
	mov ah, 9
	mov dx, OFFSET pmensaje_final
	int 21h
	
	; Fin del programa
	mov ax, 4C00h
	int 21h
inicio ENDP

limpia_pantalla PROC
	push dx ax
	
	; Limpia la pantalla
	lea dx, clear_pantalla
	mov ah, 9
	INT 21H
	
	pop ax dx
	ret
limpia_pantalla ENDP


code ENDS
END inicio