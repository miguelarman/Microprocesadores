codigo SEGMENT
	ASSUME cs : codigo
	ORG 256
	
inicio: jmp lee_argumentos

; Variables globales
polibio						db	3, 4, 5, 6, 7, 8, 9, "ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0, 1, 2
cadena_aux					db	32 dup (?)
mensaje_informacion			db "Informacion$"
mensaje_error_parametros_num_caracteres	db	"Error en los parametros: Escribe solo dos caracteres$"
mensaje_error_parametros_otro_caracter	db	"Error en los parametros: El parametro tiene que ser /I o /D$"
mensaje_error_parametros_sin_barra	db	"Error en los parametros: El parametro tiene que empezar por /$"
clear_pantalla				db 1BH,"[2","J$"


; Rutina de servicio a la interrupción
rsi PROC FAR
	; Salva registros modificados
	; push ...
	
	; Instrucciones de la rutina
	; ...
	
	; Recupera registros modificados
	; pop ...
	iret
	
lee_argumentos:
	; Lee del PSP el tamaño en bytes de los parámetros del programa
	mov al, es:[80h]
	
	; Si recibe 0 caracteres, muestra información por pantalla
	cmp al, 0
	jz informacion
	
	; Si recibe argumentos, tienen que ser tres caracteres
	cmp al, 3
	jne error_parametros_num_caracteres
	
	; Parsea cada caracter de los parametros
	
	; El primero tiene que ser un "/"
	cmp BYTE PTR es:[80h+2], "/"
	jne error_parametros_sin_barra
	
	; Si el siguiente es un "I", llama al instalador
	cmp BYTE PTR es:[80h+3], "I"
	je instalador
	
	; Si el siguiente es un "D", llama al instalador
	cmp BYTE PTR es:[80h+3], "D"
	je desinstalador
	
	; Si es otro caracter, es uno no válido
	jmp error_parametros_otro_caracter
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

informacion:
	; Limpia la pantalla
	lea dx, clear_pantalla
	mov ah, 9
	int 21h
	
	; Imprime el mensaje de informacion
	mov ah, 9
	mov dx, OFFSET mensaje_informacion
	int 21h
	jmp fin_ejecucion_normal

error_parametros_num_caracteres:
	; Limpia la pantalla
	lea dx, clear_pantalla
	mov ah, 9
	INT 21H
	
	; Imprime el mensaje de informacion
	mov ah, 9
	mov dx, OFFSET mensaje_error_parametros_num_caracteres
	int 21h
	jmp fin_ejecucion_normal
	
error_parametros_otro_caracter:
	; Limpia la pantalla
	lea dx, clear_pantalla
	mov ah, 9
	INT 21H
	
	; Imprime el mensaje de informacion
	mov ah, 9
	mov dx, OFFSET mensaje_error_parametros_otro_caracter
	int 21h
	jmp fin_ejecucion_normal

error_parametros_sin_barra:
	; Limpia la pantalla
	lea dx, clear_pantalla
	mov ah, 9
	INT 21H
	
	; Imprime el mensaje de informacion
	mov ah, 9
	mov dx, OFFSET mensaje_error_parametros_sin_barra
	int 21h
	jmp fin_ejecucion_normal

desinstalador:
	jmp fin_ejecucion_normal
	
	
instalador:
	mov ax, 0
	mov es, ax
	mov ax, OFFSET rsi
	mov bx, cs
	cli
	mov es:[57h*4], ax
	mov es:[57h*4+2], bx
	sti
	mov dx, OFFSET instalador
	int 27h	; Acaba y deja residente
			; PSP, variables y rutina rsi.
	
fin_ejecucion_normal:
	mov ax, 4C00h
	int 21h
rsi ENDP

codigo ENDS
END inicio