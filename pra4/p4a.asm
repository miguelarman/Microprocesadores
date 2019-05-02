;**************************************************************************
;			   SISTEMAS BASADOS EN MICROPROCESADORES - 2019			  
;					PRÁCTICA 4: Diseño de programas					  
;							  residentes								 
;**************************************************************************
; Autores:																  
; 			- Miguel Arconada Manteca									  
;				(miguel.arconada@estudiante.uam.es)						  
; 			- Mario García Pascual										  
;				(mario.garciapascual@estudiante.uam.es)					  
;**************************************************************************
; Fecha:	2 de mayo de 2019											  
;**************************************************************************
; Descripción:															  
;			En este fichero, realizamos un programa en ensamblador en el  
;		que se realizan dos funciones:									  
;																		  
;			En primer lugar, definimos la rutina rsi, en la que		   
;		ciframos o desciframos una cadena por el método Polibio según el  
;		valor de ah.													  
;																		  
;			Por otro lado, el programa principal, que se encarga de		  
;		varias tareas:													  
;			1- Si no recibe argumentos, imprime un mensaje de información,
;			y comprueba si el driver ya está instalado					  
;			2- Si recibe como argumentos /I, instala el driver de la	  
;			rutina rsi para la interrupción 57h							  
;			3- Si recibe /D, desinstala el driver, y establece el que	  
;			hubiera en el momento de la instalación						  
;			4- Si recibe otro argumento, imprime un mensaje de error	  
;**************************************************************************

codigo SEGMENT
	assume cs : codigo
	org 256

; Establece dónde debe empezar la ejecución del programa
inicio: jmp lee_argumentos

; Variables usadas por la rutina para cifrar y descifrar
table_ctop								db	48 dup(?,?)
										db	"6566"
										db	"111213141516"
										db	"2122"
										db	7 dup(?,?)
										db	"23242526"
										db	"313233343536"
										db	"414243444546"
										db	"515253545556"
										db	"61626364"
table_ptoc								db	"234567"
										db	"89ABCD"
										db	"EFGHIJ"
										db	"KLMNOP"
										db	"QRSTUV"
										db	"WXYZ01"
; Mensajes que se muestan por pantalla
perror									db	"Error: el servicio pedido no existe:"
										db	" AH=10h para codificar,"
										db	" AH=11h para decodificar$"
out_str	 								db	200 dup(?)
mensaje_informacion_general				db	"Informacion acerca de este programa:", 0Ah
										db	9h, "Llamar a esta funcion con el argumento /I para instalar el driver", 0Ah
										db	9h, "Llamar a esta funcion con el argumento /D para desinstalar el driver", 0Ah
										db	9h, "Una vez instalado, este programa gestiona la interrupcion 57h,", 0Ah
										db	9h, "cifrando o descifrando con Polibio dependiendo del valor en AH", 0Ah
										db	9h, "(10h para cifrar y 11h para descifrar)", 0Ah
										db	0Ah, "Numero de pareja:", 9h, "9", 0Ah
										db	0Ah, "Ejercicio desarrollado por:", 0Ah
										db	9h, "Miguel Arconada", 0Ah
										db	9h, "Mario Garcia", 0Ah
										db	"$"
mensaje_informacion_instalador			db "Se ha ejecutado el instalador$"
mensaje_informacion_desinstalador		db "Se ha ejecutado el desinstalador$"
mensaje_error_parametros_num_caracteres	db	"Error en los parametros: Escribe solo dos caracteres$"
mensaje_error_parametros_otro_caracter	db	"Error en los parametros: El parametro tiene que ser /I o /D$"
mensaje_error_parametros_sin_barra		db	"Error en los parametros: El parametro tiene que empezar por /$"
mensaje_debug							db	0Ah,"Debugueando$"
clear_pantalla							db	1BH,"[2","J$"
mensaje_instalado						db	0Ah,"El driver esta instalado$"
mensaje_no_instalado					db	0Ah,"El driver no esta instalado$"

; Valores del vector de interrupcion antes de instalar
offset_anterior_57h						dw	?
segmento_anterior_57h					dw	?

; Valor para comprobar si el driver está instalado
firma									dw	0ACABh

; Rutina llamada por la interrupción 57h
rsi PROC FAR
	; Salva registros modificados
	push ax dx ds

	; Analiza el valor en ah
	cmp ah, 10h
	je opt_encode

	cmp ah, 11h
	je opt_decode

	; Imprime mensaje de error
	lea dx, perror
	mov ah, 9
	int 21h
	jmp salir

opt_encode:
	call encode_polibio
	jmp imprimir

opt_decode:
	call decode_polibio
	jmp imprimir

imprimir:
	mov ax, cs
	mov ds, ax
	lea dx, out_str
	mov ah, 9
	int 21h

salir:
	; Recupera registros modificados
	pop ds dx ax
	iret

;;;;;;
;;
;; Esta funcion recibe en DS:DX una cadena de
;; caracteres, la codifica en Polibio y la guarda
;; en out_str terminada en $
;;
encode_polibio proc near
	push ax bx dx si di ds

	mov bx, dx

	mov si, 0
b1:
	mov al, ds:[bx][si]
	cmp al, "$"
	je end_b1

	call enc_char
	mov di, si
	sal di, 1
	mov word ptr out_str[di], dx
	inc si
	jmp b1

end_b1:
	mov di, si
	sal di, 1
	mov ax, cs
	mov ds, ax
	mov out_str[di], "$"

	pop ds di si dx bx ax

	ret
encode_polibio endp

;;;;;;
;;
;; Esta funcion recibe en AL un caracter y
;; devuelve en DX los dos caracteres que
;; se corresponden a la codificacion en poli-
;; bio de AL. Por ejemplo, si AL="A" y "A"
;; se codifica en "23" -> DL="2", DH="3"
;;
enc_char proc near
	push ax si
	
	;; Accede a la posicion del codigo
	;; ascii del caracter que se le pasa
	;; en table_ctop
	mov ah, 2
	mul ah
	mov si, ax
	mov dx, word ptr table_ctop[si]

	pop si ax

	ret
enc_char endp

;;;;;;
;;
;; Esta funcion recibe en DS:DX una cadena de
;; caracteres codificada en Polibio, la deco-
;; difica y la guarda en out_str terminada en
;; $
;;
decode_polibio proc near
	push ax bx dx si di ds

	mov bx, dx

	mov di, 0
b2:
	mov si, di
	sal si, 1
	mov ax, word ptr ds:[bx][si]
	cmp al, "$"
	je end_b2

	call dec_char
	mov out_str[di], dl
	inc di
	jmp b2

end_b2:
	mov ax, cs
	mov ds, ax
	mov out_str[di], "$"

	pop ds di si dx bx ax

	ret
decode_polibio endp

;;;;;;
;;
;; Esta funcion recibe en AX un par de chars
;; que se corresponden a un char codificado
;; en Polibio y devuelve la decodificacion
;; en DL. Por ejemplo, si AL="2", AH="3" y
;; el char correspondiente a "23" es "A",
;; devuelve DL="A"
;;
dec_char proc near
	push ax bx si

	mov bl, ah

	sub al, "0"
	dec al
	sub bl, "0"
	dec bl

	;; Si la codificacion es "23", accede a
	;; la fila 1 columna 2 de table_ptoc
	mov ah, 6
	mul ah
	mov bh, 0
	xchg ax, bx
	mov si, ax
	mov dl, table_ptoc[bx][si]

	pop si bx ax

	ret
dec_char endp

; Rutina principal del programa. Analiza los argumentos escritos
; al llamar al programa
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
	call rutina_informacion
	jmp fin_ejecucion_normal

error_parametros_num_caracteres:
	call rutina_error_parametros_num_caracteres
	jmp fin_ejecucion_normal

error_parametros_otro_caracter:
	call rutina_error_parametros_otro_caracter
	jmp fin_ejecucion_normal

error_parametros_sin_barra:
	call rutina_error_parametros_sin_barra
	jmp fin_ejecucion_normal

desinstalador:
	call rutina_desinstalador
	jmp fin_ejecucion_normal

	; Código para instalar el driver de la interrupción 57h
instalador:

	; Limpia la pantalla
	call limpia_pantalla

	; Imprime el mensaje de informacion del desinstalador
	mov ah, 9
	mov dx, OFFSET mensaje_informacion_instalador
	int 21h

	; Inicializa registros
	mov ax, 0
	mov es, ax
	mov ax, OFFSET rsi
	mov bx, cs

	; Modifica los valores de vectores de interrupción y guarda los anteriores
	cli
	mov cx, es:[57h*4]
	mov offset_anterior_57h, cx
	mov es:[57h*4], ax
	mov cx, es:[57h*4+2]
	mov segmento_anterior_57h, cx
	mov es:[57h*4+2], bx
	sti

	mov dx, OFFSET lee_argumentos
	int 27h	; Acaba y deja residente
			; PSP, variables y rutina rsi.

fin_ejecucion_normal:
	mov ax, 4C00h
	int 21h
rsi ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;				RUTINAS AUXILIARES			   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Rutina que imprime un mensaje de información y comprueba si el driver está instalado
rutina_informacion PROC
	push ax dx

	; Limpia la pantalla
	call limpia_pantalla

	; Imprime el mensaje de informacion
	mov ah, 9
	mov dx, OFFSET mensaje_informacion_general
	int 21h

	call rutina_mensaje_instalado

	pop dx ax
	ret
rutina_informacion ENDP

; Rutina que imprime un mensaje de error
rutina_error_parametros_num_caracteres PROC
	push ax dx

	; Limpia la pantalla
	call limpia_pantalla

	; Imprime el mensaje de informacion
	mov ah, 9
	mov dx, OFFSET mensaje_error_parametros_num_caracteres
	int 21h

	pop dx ax
	ret
rutina_error_parametros_num_caracteres ENDP

; Rutina que imprime un mensaje de error
rutina_error_parametros_otro_caracter PROC
	push ax dx

	; Limpia la pantalla
	call limpia_pantalla

	; Imprime el mensaje de informacion
	mov ah, 9
	mov dx, OFFSET mensaje_error_parametros_otro_caracter
	int 21h

	pop dx ax
	ret
rutina_error_parametros_otro_caracter ENDP

; Rutina que imprime un mensaje de error
rutina_error_parametros_sin_barra PROC
	push ax dx

	; Limpia la pantalla
	lea dx, clear_pantalla
	mov ah, 9
	int 21h

	; Imprime el mensaje de informacion
	mov ah, 9
	mov dx, OFFSET mensaje_error_parametros_sin_barra
	int 21h

	pop dx ax
	ret
rutina_error_parametros_sin_barra ENDP

; Rutina que desintala el driver y restaura el anterior
rutina_desinstalador PROC
	push ax bx cx dx ds es

	; Limpia la pantalla
	call limpia_pantalla

	; Imprime el mensaje de informacion del desinstalador
	mov ah, 9
	mov dx, OFFSET mensaje_informacion_desinstalador
	int 21h

	; Comprueba el vector INT
	mov cx, 0
	mov ds, cx
	cmp ds:[57h*4], WORD PTR 0
	jz no_instalado_desinstalar
	cmp ds:[57h*4+2], WORD PTR 0
	jz no_instalado_desinstalar

	; Comprueba si está instalado (firma)
	call comprueba_instalado
	cmp ax, 0
	je no_instalado_desinstalar

	; Desinstala el driver
	desinstalar_57h:
	mov cx, 0
	mov ds, cx				; Segmento de vectores interrupción
	mov es, ds:[57h*4+2]	; Lee segmento de RSI
	mov bx, es:[2Ch]		; Lee segmento de entorno del PSP de RSI
	mov ah, 49h
	int 21h					; Libera segmento de RSI (es)
	mov es, bx
	int 21h					; Libera segmento de variables de entorno de RSI

	; Reestablece el vector de interrupción 57h
	cli
	mov ax, 0
	mov es, ax
	les bx, es:[57h*4]
	mov cx, es:[bx-6]
	mov dx, es:[bx-4]
	mov ds:[57h*4], cx
	mov ds:[57h*4+2], dx
	sti

	jmp final_desinstalador

	no_instalado_desinstalar:
	pop ds
	call rutina_mensaje_instalado

	final_desinstalador:
	pop es ds dx cx bx ax
	ret
rutina_desinstalador ENDP

; Rutina que limpia la pantalla
limpia_pantalla PROC
	push dx ax

	; Limpia la pantalla
	lea dx, clear_pantalla
	mov ah, 9
	INT 21H

	pop ax dx
	ret
limpia_pantalla ENDP

; Rutina que imprime un mensaje sobre si el driver está instalado
rutina_mensaje_instalado PROC
	push ax
	call comprueba_instalado

	cmp ax, 1
	je imprime_mensaje_instalado
	jmp imprime_mensaje_no_intalado

	imprime_mensaje_instalado:
	mov ah, 9
	mov dx, OFFSET mensaje_instalado
	int 21h

	pop ax
	ret

	imprime_mensaje_no_intalado:
	mov ah, 9
	mov dx, OFFSET mensaje_no_instalado
	int 21h

	pop ax
	ret
rutina_mensaje_instalado ENDP

; Rutina que comprueba si el driver está instalado
comprueba_instalado PROC
	push bx es ds

	mov ax, 0
	mov es, ax

	les bx, es:[57h*4]
	mov bx, es:[bx-2]

	mov ax, firma
	cmp ax, bx

	je iguales
	jmp distintos

	ret

	iguales:
	mov ax, 1
	jmp final_comprueba_instalado

	distintos:
	mov ax, 0
	jmp final_comprueba_instalado

	final_comprueba_instalado:
	pop ds es bx
	ret

comprueba_instalado ENDP

codigo ENDS
END inicio
