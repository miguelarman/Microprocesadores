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
;			En este fichero, realizamos un programa en ensamblador en el  ;
;		que se realizan tres funciones:									  ;
;																		  ;
;			En primer lugar, definimos la rutina rsi, en la que           ;
;		ciframos o desciframos una cadena por el método Polibio según el  ;
;		valor de ah, estando pendiente del valor de la variable sec_cnt	  ;
;																		  ;
;			En segundo lugar, definimos otra rutina, que se va a ejecutar ;
;		con la interrupción periódica, y que incrementa sec_cnt 18 veces  ;
;		por segundo.
;																		  ;
;			Por otro lado, el programa principal, que se encarga de		  ;
;		varias tareas:													  ;
;			1- Si no recibe argumentos, imprime un mensaje de información,;
;			y comprueba si los drivers ya están instalados				  ;
;			2- Si recibe como argumentos /I, instala el driver de la	  ;
;			rutina rsi para la interrupción 57h y de la rutina periódica  ;
;			para la interrupción 1Ch									  ;
;			3- Si recibe /D, desinstala los drivers, y establece los que  ;
;			hubiera en el momento de la instalación						  ;
;			4- Si recibe otro argumento, imprime un mensaje de error	  ;
;**************************************************************************

codigo SEGMENT
	ASSUME cs : codigo
	ORG 256
	
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
out_str     							db	200 dup(?)
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
mensaje_informacion_instalador			db	"Se ha ejecutado el instalador$"
mensaje_informacion_desinstalador_57h	db	"Se ha ejecutado el desinstalador de 57h$"
mensaje_informacion_desinstalador_1Ch	db	0Ah, "Se ha ejecutado el desinstalador de 1Ch$"
mensaje_error_parametros_num_caracteres	db	"Error en los parametros: Escribe solo dos caracteres$"
mensaje_error_parametros_otro_caracter	db	"Error en los parametros: El parametro tiene que ser /I o /D$"
mensaje_error_parametros_sin_barra		db	"Error en los parametros: El parametro tiene que empezar por /$"
mensaje_debug							db	0Ah,"Debugueando$"
clear_pantalla							db	1BH,"[2","J$"
mensaje_instalado						db	0Ah,"El driver esta instalado$"
mensaje_no_instalado					db	0Ah,"El driver no esta instalado$"

; Variable acutalizada por la rutina 1Ch
sec_cnt									db	0

; Valores del vector de interrupcion antes de instalar
offset_anterior_57h						dw	?
segmento_anterior_57h					dw	?

; Valor para comprobar si el driver de 57h está instalado
firma									dw	0ABACh



; Rutina llamada por la interrupción 57h
rsi PROC FAR
	sti
	
	; Salva registros modificados
	push ax si ds dx
	
	; Decide por el valor en ah
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
    jmp imprimir_nuevo
    
opt_decode:
    call decode_polibio
    jmp imprimir_nuevo
    
imprimir:
    mov ax, cs
	mov ds, ax
    lea dx, out_str
    mov ah, 9
    int 21h
    jmp salir
    
imprimir_nuevo:
    mov si, 0
    mov ax, cs
	mov ds, ax
b0:
    mov dl, out_str[si]
    cmp dl, "$"
    je salir
    
	; Espera a que la interrupción 1Ch incremente la variable 18 veces (1 segundo)
    mov sec_cnt, 0
delay:
	cmp sec_cnt, 18
    jb delay
    
    mov ah, 2
    int 21h
    inc si
    jmp b0 
    
salir:
	; Recupera registros modificados
	pop dx ds si ax
	iret
	
;;;;;;
;;
;; Esta funcion recibe en DS:DX una cadena de
;; caracteres, la codifica en Polibio y la im-
;; prime por pantalla.
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
;; es corresponde al codificacion el poli-
;; bio de AL. Por ejemplo, si AL="A" y "A"
;; se codifica en "23" -> DL="2", DH="3" 
;;    
enc_char proc near
    push ax si
    
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
;; difica y la imprime por pantalla.
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
    
    mov ah, 6
    mul ah
    mov bh, 0
    xchg ax, bx
    mov si, ax
    mov dl, table_ptoc[bx][si]
    
    pop si bx ax
    
    ret     
dec_char endp

; Valores del vector de interrupcion antes de instalar
offset_anterior_1Ch		dw	?
segmento_anterior_1Ch	dw	?

; Valor para comprobar si el driver de 1Ch está instalado
firma_2					dw	0AAAAh

; Rutina llamada por la interrupción 1Ch 18 veces por segundo
rutina_periodica PROC
	; Guarda los registros que modifica
	push ax ds
	
	; Instrucciones del programa
	mov ax, cs
	mov ds, ax
	
	inc sec_cnt
	
	; Recupera los registros que modifica
	pop ds ax
	iret
rutina_periodica ENDP

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
	call rutina_desinstalador_57h
	call rutina_desinstalador_1Ch
	jmp fin_ejecucion_normal
	
instalador:
	call rutina_instalador
	
fin_ejecucion_normal:
	mov ax, 4C00h
	int 21h
rsi ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                RUTINAS AUXILIARES               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Rutina para instalar el driver de la interrupción 57h y 1Ch
rutina_instalador PROC
	; Limpia la pantalla
	call limpia_pantalla
	
	; Imprime el mensaje de informacion del desinstalador
	mov ah, 9
	mov dx, OFFSET mensaje_informacion_instalador
	int 21h
	
	; Bloquea la interrupcion
	in ax, 21h
	or ah, 1
	out 21h, ax
	
	; Instala el driver para la interrupcion 57h
	mov ax, 0
	mov es, ax
	mov ax, OFFSET rsi
	mov bx, cs
	
	mov cx, es:[57h*4]
	mov offset_anterior_57h, cx
	mov es:[57h*4], ax
	mov cx, es:[57h*4+2]
	mov segmento_anterior_57h, cx
	mov es:[57h*4+2], bx
	
	; Instala el driver para la interrupcion periodica (1Ch)
	mov ax, 0
	mov es, ax
	mov ax, OFFSET rutina_periodica
	mov bx, cs
	
	mov cx, es:[1Ch*4]
	mov offset_anterior_1Ch, cx
	mov es:[1Ch*4], ax
	mov cx, es:[1Ch*4+2]
	mov segmento_anterior_1Ch, cx
	mov es:[1Ch*4+2], bx
	
	; Desbloquea las interrupciones
	in ax, 21h
	and ax, 0FFFEh
	out 21h, ax
	
	mov dx, OFFSET lee_argumentos
	int 27h	; Acaba y deja residente
			; PSP, variables y rutina rsi.
rutina_instalador ENDP

; Rutina que imprime un mensaje de información y comprueba si el driver está instalado
rutina_informacion PROC
	push ax dx
	
	; Limpia la pantalla
	call limpia_pantalla
	
	; Imprime el mensaje de informacion
	mov ah, 9
	mov dx, OFFSET mensaje_informacion_general
	int 21h
	
	call rutina_mensaje_instalado_57h
	call rutina_mensaje_instalado_1Ch
	
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
	INT 21H
	
	; Imprime el mensaje de informacion
	mov ah, 9
	mov dx, OFFSET mensaje_error_parametros_sin_barra
	int 21h
	
	pop dx ax
	ret
rutina_error_parametros_sin_barra ENDP

; Rutina que desintala el driver para la
; interrupción 57h y restaura el anterior
rutina_desinstalador_57h PROC
	push ax bx cx dx ds es

	; Limpia la pantalla
	call limpia_pantalla
	
	; Imprime el mensaje de informacion del desinstalador
	mov ah, 9
	mov dx, OFFSET mensaje_informacion_desinstalador_57h
	int 21h
	
	; Comprueba el vector INT
	mov bx, ds ; Guardamos ds para poder imprimir
	mov cx, 0
	mov ds, cx
	cmp ds:[57h*4], WORD PTR 0
	jz no_instalado_desinstalar
	cmp ds:[57h*4+2], WORD PTR 0
	jz no_instalado_desinstalar
	
	; Comprueba si está instalado (firma)
	call comprueba_instalado_57h
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
	mov ds, bx
	call rutina_mensaje_instalado_57h
	
	final_desinstalador:
	pop es ds dx cx bx ax
	ret
rutina_desinstalador_57h ENDP

; Rutina que desintala el driver para la
; interrupción 1Ch y restaura el anterior
rutina_desinstalador_1Ch PROC
	push ax bx cx dx ds es
	
	; Imprime el mensaje de informacion del desinstalador
	mov ah, 9
	mov dx, OFFSET mensaje_informacion_desinstalador_1Ch
	int 21h
	
	; Comprueba el vector INT
	mov bx, ds ; Guardamos ds para poder imprimir
	mov cx, 0
	mov ds, cx
	cmp ds:[1Ch*4], WORD PTR 0
	jz no_instalado_desinstalar_1Ch
	cmp ds:[1Ch*4+2], WORD PTR 0
	jz no_instalado_desinstalar_1Ch
	
	; Comprueba si está instalado (firma)
	call comprueba_instalado_1Ch
	cmp ax, 0
	je no_instalado_desinstalar_1Ch
	
	; Desinstala el driver
	desinstalar_1Ch:
	mov cx, 0
	mov ds, cx				; Segmento de vectores interrupción
	mov es, ds:[1Ch*4+2]	; Lee segmento de RSI
	mov bx, es:[2Ch]		; Lee segmento de entorno del PSP de RSI
	mov ah, 49h
	int 21h					; Libera segmento de RSI (es)
	mov es, bx
	int 21h					; Libera segmento de variables de entorno de RSI
	
	cli
	mov ax, 0
	mov es, ax
	les bx, es:[1Ch*4]
	mov cx, es:[bx-6]
	mov dx, es:[bx-4]
	mov ds:[1Ch*4], cx
	mov ds:[1Ch*4+2], dx
	sti
	
	jmp final_desinstalador_1Ch
	
	no_instalado_desinstalar_1Ch:
	mov ds, bx
	call rutina_mensaje_instalado_1Ch
	
	final_desinstalador_1Ch:
	pop es ds dx cx bx ax
	ret
rutina_desinstalador_1Ch ENDP

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

; Rutina que imprime un mensaje sobre si el driver para
; la interrupción 57h está instalado
rutina_mensaje_instalado_57h PROC
	push ax
	call comprueba_instalado_57h
	
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
rutina_mensaje_instalado_57h ENDP

; Rutina que imprime un mensaje sobre si el driver para
; la interrupción 1Ch está instalado
rutina_mensaje_instalado_1Ch PROC
	push ax
	call comprueba_instalado_1Ch
	
	cmp ax, 1
	je imprime_mensaje_instalado_1Ch
	jmp imprime_mensaje_no_intalado_1Ch
	
	imprime_mensaje_instalado_1Ch:
	mov ah, 9
	mov dx, OFFSET mensaje_instalado
	int 21h
	
	pop ax
	ret
	
	imprime_mensaje_no_intalado_1Ch:
	mov ah, 9
	mov dx, OFFSET mensaje_no_instalado
	int 21h
	
	pop ax
	ret
rutina_mensaje_instalado_1Ch ENDP

; Rutina que comprueba si el driver para la
; interrupción 57h está instalado
comprueba_instalado_57h PROC
	push bx es ds
	
	mov ax, 0
	mov es, ax
	
	les bx, es:[57h*4]
	mov bx, es:[bx-2]
	
	mov ax, firma
	cmp ax, bx
	
	je iguales
	jmp distintos
	
	iguales:
	mov ax, 1
	jmp final_comprueba_instalado

	distintos:
	mov ax, 0
	jmp final_comprueba_instalado
	
	final_comprueba_instalado:
	pop ds es bx
	ret
	
comprueba_instalado_57h ENDP

; Rutina que comprueba si el driver para la
; interrupción 57h está instalado
comprueba_instalado_1Ch PROC
	push bx es ds
	
	mov ax, 0
	mov es, ax
	
	les bx, es:[1Ch*4]
	mov bx, es:[bx-2]
	
	mov ax, firma_2
	cmp ax, bx
	
	je iguales_1Ch
	jmp distintos_1Ch
	
	iguales_1Ch:
	mov ax, 1
	jmp final_comprueba_instalado_1Ch

	distintos_1Ch:
	mov ax, 0
	jmp final_comprueba_instalado_1Ch
	
	final_comprueba_instalado_1Ch:
	pop ds es bx
	ret
	
comprueba_instalado_1Ch ENDP

codigo ENDS
END inicio