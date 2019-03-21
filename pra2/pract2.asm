;**************************************************************************
;               SISTEMAS BASADOS EN MICROPROCESADORES - 2019			  ;
;                    PRÁCTICA 2: Juego de instrucciones					  ;
;**************************************************************************
; Autores:																  ;
; 			- Miguel Arconada Manteca									  ;
;				(miguel.arconada@estudiante.uam.es)						  ;
; 			- Mario García Pascual										  ;
;				(mario.garciap@estudiante.uam.es)						  ;
;**************************************************************************
; Fecha:	21 de marzo de 2019											  ;
;**************************************************************************
; Descripción:															  ;
;			En esta práctica se nos pide calcular el determinante de una  ;
;		matriz 3x3, e imprimirlo por pantalla, para familiarizarnos		  ;
;		con el juego de instrucciones del procesador 80x86, estudiado	  ;
;		en la asignatura.												  ;
;			Una vez realizado esto, se nos pide que añadamos el soporte	  ;
;		para que el usuario pueda introducir por terminal sus propios	  ;
;		valores de la matriz.											  ;
;**************************************************************************


; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT

	; Variables donde se guardan la matriz y su determinante
	MATRIZ					db -1, 2, -3, 0, -5, -12, 7, 8, 10
	RESULTADO				dw ?
	
	; Cadena que limpia la pantalla
	CLR_PANT				db 1BH,"[2","J$"
	
	; Cadena que se imprime la primera
	DET_A					db 1BH,"[4;21f|A| =  $"
	
	; Valores de las cadenas que vamos a usar para imprimir. Reservan espacio
	; para los valores que se van a calcular, esperando numeros en la matriz
	; de dos cifras (más signo) y 4 cifras de resultado (más signo).
	; Usamos este método porque al imprimir usamos "coordenadas" en cada
	; string, para que quede colocado en pantalla
	PRIMERA_LINEA			db 1BH,"[3;27f|", ?, ?, ?, " ", ?, ?, ?, " ", ?, ?, ?, "|$"
	SEGUNDA_LINEA			db 1BH,"[4;27f|", ?, ?, ?, " ", ?, ?, ?, " ", ?, ?, ?, "|$"
	TERCERA_LINEA			db 1BH,"[5;27f|", ?, ?, ?, " ", ?, ?, ?, " ", ?, ?, ?, "|$"	
	IGUAL_RESULTADO			db 1BH,"[4;40f = ", ?, ?, ?, ?, ?, "$"
	
	; Valores necesarios para escribir en el programa sobre las cadenas de caracteres anteriores
	OFFSET_INICIAL_LINEA	dw 8
	OFFSET_RESULTADO		dw 10

	; Variables en las que se guarda cada valor, antes de insertarlo en las variables anteriores
	VALOR_IMPRIMIR			db 3 dup (?), "$"
	RESULTADO_IMPRIMIR		db 5 dup (?), "$"
	
	; Esto se imprime para mover el cursor a la última línea de la terminal
	APARTA_CURSOR			db 1BH,"[23;1f$"
	
	; Variables necesarias para la lectura inicial
	signo  db 0
    buff db 36, ?
    string  db 36 dup(0)
    bienvenida db "Introduzca los 9 datos separados SOLO por comas",
               db " (sin espacios), con un maximo de 2 digitos por",
               db " numero e indicando los numeros negativos con u",
               db "n - delante, por ejemplo ->1,-2,3,-4,11,-12,13,",
               db "-14,15[ENTER]. Ademas, los numeros introducidos",
               db " deberan estar en el rango [-16,15].", 10, 13, 10, 13, "$"
    perror1    db 10, 13, "Error: datos fuera de rango$"
    perror2    db 10, 13, "Error: datos insuficientes$"
    perror3    db 10, 13, "Error: formato incorrecto$"
	
DATOS ENDS

;**************************************************************************
; DEFINICION DEL SEGMENTO DE PILA
PILA SEGMENT STACK "STACK"
	DB 40H DUP (0) ;ejemplo de inicialización, 64 bytes inicializados a 0
PILA ENDS

;**************************************************************************
; DEFINICION DEL SEGMENTO EXTRA
EXTRA SEGMENT

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

	; --------------------------------
	; Lectura de la matriz por entrada
	; --------------------------------
	CALL LECTURA

	; ------------------------
	; Cálculo del determinante
	; ------------------------

	; Inicializa el resultado a cero
	MOV RESULTADO, 0
	
	; Subrutinas que calculan los productos de cada diagonal positiva
	MOV CX, 0			; Empezando en la primera columna
	CALL DIAG_POS
	MOV CX, 1			; Empezando en la segunda columna
	CALL DIAG_POS
	MOV CX, 2			; Empezando en la tercera columna
	CALL DIAG_POS

	; Subrutinas que calculan los productos de cada diagonal negativa
	MOV CX, 2			; Empezando en la tercera columna
	CALL DIAG_NEG
	MOV CX, 1			; Empezando en la segunda columna
	CALL DIAG_NEG
	MOV CX, 0			; Empezando en la primera columna
	CALL DIAG_NEG

	; ------------------------------------
	; Impresión del resultado por pantalla
	; ------------------------------------
	CALL IMPRESION

	; FIN DEL PROGRAMA
	MOV AX, 4C00H
	INT 21H


; ------------------------------------;
;              SUBRUTINAS             ;
; ------------------------------------;


;-------------------------------------------------------------------------- 
; SUBRUTINA PARA LEER UNA MATRIZ 3X3 POR LA PANTALLA 
; ENTRADA NINGUNA
; SALIDA GUARDA EN MEMORIA LA MATRIZ 
;-------------------------------------------------------------------------- 
LECTURA PROC NEAR
	; A partir de aqui empieza la rutina,
    ; al final lo voy a hacer todo en una
    
    ; Da la bienvenida al usuario y le indica
    ; como introducir los datos
    lea dx, bienvenida
    mov ah, 9
    int 21h
    
    
    ; Coge el input del usuario
    mov ah, 10
    mov dx, offset buff  
    int 21h
    
    mov si, 0
    mov di, 0
    
bucle:
    mov al, string[si]
    cmp al, "-"
    jne else_jump
    mov signo, 1
    inc si
    mov al, string[si]
    jmp both
else_jump:
    mov signo, 0
both:
    sub al, "0"
    mov dl, string[si+1]
    cmp dl, ","
    je write1
    cmp dl, 13         ; 13 es el retorno de carro
    je write1
    sub dl, "0"
    jmp write2 
        
finbucle:              ; Si DI es distinto de 9 es que
    cmp di, 9          ; no se han almacenado suficientes
    jne error2         ; datos
    jmp retorno
        
    
write1:
    mov ah, 0           ; El numero a escribir esta en AL,
    cmp signo, 1        ; si es un numero negativo toma el
    jne j1              ; complemento a 2
    neg ax

j1: cmp ax, -16         ; Comprueba rangos y escribe
    jl error1
    cmp ax, 15
    jg error1
    mov matriz[di], ax
    
    inc di              ; Aumenta los indices
    add si, 2
    
    cmp dl, 13          ; Comprueba si el caracter siguiente 
    je finbucle         ; es de control (coma o retorno), actua
    cmp dl, ","         ; formato en caso contrario. Esta en DL 
    jne error3          ; en consecuencia y devuelve error de
                            
    cmp di, 9
    jl bucle
    jmp finbucle
    
write2:
    mov ah, 10          ; El digito alto del numero a escribir esta
    mov dh, 0           ; en AL y el bajo en DL, si es un numero
    mul ah              ; negativo toma el complemento a dos
    add ax, dx
    cmp signo, 1
    jne j2
    neg ax
    
j2: cmp ax, -16         ; Comprueba rangos y escribe
    jl error1
    cmp ax, 15
    jg error1
    mov matriz[di], ax
    
    inc di              ; Aumenta los indices
    add si, 3
    
    mov dl, string[si-1]   ; Al aumentar 3 estamos posicionados en el
    cmp dl, 13          ; siguiente digito, por eso -1 para mirar atras.
    je finbucle         ; Comprueba si el caracter siguiente es de
    cmp dl, ","         ; control, devuelve error en caso contrario
    jne error3
        
    cmp di, 9
    jl bucle
    jmp finbucle 
    
error1:
    lea dx, perror1
    mov ah, 9
    int 21h
    jmp exit
    
error2:
    lea dx, perror2
    mov ah, 9
    int 21h
    jmp exit
    
error3:
    lea dx, perror3
    mov ah, 9
    int 21h
    jmp exit
    
retorno: ; Esto seria el retorno del procedimiento que sea
    RET    
    
exit:
    mov ah, 4ch ; exit to operating system.
    int 21h
LECTURA ENDP



; ------------------------------------------------------------ 
; SUBRUTINA PARA CALCULAR UNA DIAGONAL POSITIVA DE UNA MATRIZ 
; ENTRADA CX: VALOR INICIAL DE LA SEGUNDA COORDENADA
; SALIDA: MODIFICA EN MEMORIA EL DETERMINANTE DE LA MATRIZ
; ------------------------------------------------------------ 

DIAG_POS PROC NEAR

	; Guarda los valores de los registros que modifica
	PUSH AX BX SI DX

	; Inicializa el resultado al elemento neutro de la operación
    MOV AX, 1
	
	; BX Indica la fila multiplicado por 3
	MOV BX, 0
	MOV SI, CX				; Carga la columna inicial en SI
	
	MOV DL, MATRIZ[BX][SI]	; Carga el siguiente valor en DX
	MOV DH, 0
	ADD DL, 0
	JS NEGATIVO_AUX
NEXT:
	IMUL DX					; Multiplica el resultado por el siguiente valor
	
	
	ADD BX, 3	; Accede a la siguiente fila
	INC SI		; Accede a la siguiente columna
	
	; Si la columna "se sale" de la matriz la vuelve a poner a cero
	CMP SI, 3
	JE REINICIA_SI_1
	
CONTINUA_1:
	MOV DL, MATRIZ[BX][SI]	; Carga el siguiente valor en DX
	MOV DH, 0
	ADD DL, 0
	JS NEGATIVO_AUX_1
NEXT_1:
	IMUL DX ; Multiplica el resultado por el siguiente valor
	
	
	ADD BX, 3	; Accede a la siguiente fila
	INC SI		; Accede a la siguiente columna
	
	; Si la columna "se sale" de la matriz la vuelve a poner a cero
	CMP SI, 3
	JE REINICIA_SI_2
CONTINUA_2:
	MOV DL, MATRIZ[BX][SI]	; Carga el siguiente valor en DX
	MOV DH, 0
	ADD DL, 0
	JS NEGATIVO_AUX_2
NEXT_2:
	IMUL DX ; Multiplica el resultado por el siguiente valor
	
	; Suma el valor de la diagonal al resultado anterior
	ADD RESULTADO, AX
	
	; Recupera los valores de los registros que ha modificado
	POP DX SI BX AX
    RET

REINICIA_SI_1: 
    MOV SI, 0		; Vuelve a poner la columna a cero
	JMP CONTINUA_1
REINICIA_SI_2: 
    MOV SI, 0		; Vuelve a poner la columna a cero
	JMP CONTINUA_2
NEGATIVO_AUX:
	MOV DH, 0FFh
	JMP NEXT
NEGATIVO_AUX_1:
	MOV DH, 0FFh
	JMP NEXT_1
NEGATIVO_AUX_2:
	MOV DH, 0FFh
	JMP NEXT_2

DIAG_POS ENDP


; ------------------------------------------------------------ 
; SUBRUTINA PARA CALCULAR UNA DIAGONAL NEGATIVA DE UNA MATRIZ 
; ENTRADA CX: VALOR INICIAL DE LA SEGUNDA COORDENADA
; SALIDA: MODIFICA EN MEMORIA EL DETERMINANTE DE LA MATRIZ
; ------------------------------------------------------------ 

DIAG_NEG PROC NEAR

	; Guarda los valores de los registros que modifica
	PUSH AX BX SI

    ; Inicializa el resultado al elemento neutro de la operación
    MOV AX, 1
	
	; BX Indica la fila multiplicado por 3
	MOV BX, 0
	MOV SI, CX			; Carga la columna inicial en SI
	
	MOV DL, MATRIZ[BX][SI]	; Carga el siguiente valor en DX
	MOV DH, 0
	ADD DL, 0
	JS NEGATIVO_AUX_N_1
NEXT_N_1:
	MUL DX	; Multiplica el resultado por el siguiente valor
	
	; Si la columna "se sale" de la matriz la vuelve a poner a cero
	CMP SI, 0
	JE REINICIA_SI_NEG_1
	
CONTINUA_NEG_1:
	ADD BX, 3			; Accede a la siguiente fila
	DEC SI				; Accede a la columna anterior
	MOV DL, MATRIZ[BX][SI]	; Carga el siguiente valor en DX
	MOV DH, 0
	ADD DL, 0
	JS NEGATIVO_AUX_N_2
NEXT_N_2:
	MUL DX	; Multiplica el resultado por el siguiente valor
	
	; Si la columna "se sale" de la matriz la vuelve a poner a cero
	CMP SI, 0
	JE REINICIA_SI_NEG_2
	
CONTINUA_NEG_2:
	ADD BX, 3			; Accede a la siguiente fila
	DEC SI				; Accede a la columna anterior
	MOV DL, MATRIZ[BX][SI]	; Carga el siguiente valor en DX
	MOV DH, 0
	ADD DL, 0
	JS NEGATIVO_AUX_N_3
NEXT_N_3:
	MUL DX	; Multiplica el resultado por el siguiente valor
	
	; Resta el valor de la diagonal del resultado anterior
	SUB RESULTADO, AX
	
	; Recupera los valores de los registros que ha modificado
	POP SI BX AX
    RET

REINICIA_SI_NEG_1: 
    MOV SI, 3			; Reinicia el contador de la columna
	JMP CONTINUA_NEG_1
REINICIA_SI_NEG_2: 
    MOV SI, 3			; Reinicia el contador de la columna
	JMP CONTINUA_NEG_2
NEGATIVO_AUX_N_1:
	MOV DH, 0FFh
	JMP NEXT_N_1
NEGATIVO_AUX_N_2:
	MOV DH, 0FFh
	JMP NEXT_N_2
NEGATIVO_AUX_N_3:
	MOV DH, 0FFh
	JMP NEXT_N_3

DIAG_NEG ENDP

; ---------------------------------------------------------------- 
; SUBRUTINA PARA IMPRIMIR EL DETERMINANTE CALCULADO POR PANTALLA 
; ENTRADA: NINGUNA (LEE DE MEMORIA)
; SALIDA: NINGUNA
; ---------------------------------------------------------------- 
IMPRESION PROC NEAR

	; Guarda los valores de los registros que modifica
	PUSH AX DX BP CX 

	; BORRA LA PANTALLA
	MOV AH,9
	MOV DX, OFFSET CLR_PANT
	INT 21H
	
	; Imprime |A| = 
	MOV DX, OFFSET DET_A
	INT 21H
	
	; Calcula el ascii del resultado y lo guarda en RESULTADO_IMPRIMIR
	MOV CX, RESULTADO
	CALL CONVERT_ASCII_5
	
	; Guarda el offset del resultado en la cadena para imprimirlo
	MOV BP, OFFSET_RESULTADO
	
	; Accede a cada uno de los "huecos" que se ha dejado en la cadena que
	; se imprime para inicializarlos con los caracteres del resultado (signo y cuatro cifras)
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
	
	; Imprime la cadena ya con el resultado
	MOV AH, 9
	MOV DX, OFFSET IGUAL_RESULTADO
	INT 21H
	
	; -----------------------------------------------------------------
	; Modifica los valores de la primera fila de la matriz y la imprime
	; -----------------------------------------------------------------
	
	; -------------
	; Primer valor
	; -------------
	
	; Convierte el siguiente elemento de la matriz a ascii y lo guarda en VALOR_IMPRIMIR
	MOV CL, MATRIZ[0][0]
	CALL CONVERT_ASCII_3
	
	; Inicializa BP con el offset en el que debe empezar a guardar los
	; caracteres en la string correspondiente
	MOV BP, OFFSET_INICIAL_LINEA
	
	; Guarda los tres caracteres del numero en la cadena correspondiente
	MOV AL, VALOR_IMPRIMIR[0]
	MOV PRIMERA_LINEA[BP + 0], AL
	MOV AL, VALOR_IMPRIMIR[1]
	MOV PRIMERA_LINEA[BP + 1], AL
	MOV AL, VALOR_IMPRIMIR[2]
	MOV PRIMERA_LINEA[BP + 2], AL
	
	; -------------
	; Segundo valor
	; -------------
	
	; Incrementa BP hasta el "hueco" para el siguiente numero
	ADD BP, 4
	
	; Convierte el siguiente elemento de la matriz a ascii y lo guarda en VALOR_IMPRIMIR
	MOV CL, MATRIZ[0][1]
	CALL CONVERT_ASCII_3
	
	; Guarda los tres caracteres del numero en la cadena correspondiente
	MOV AL, VALOR_IMPRIMIR[0]
	MOV PRIMERA_LINEA[BP + 0], AL
	MOV AL, VALOR_IMPRIMIR[1]
	MOV PRIMERA_LINEA[BP + 1], AL
	MOV AL, VALOR_IMPRIMIR[2]
	MOV PRIMERA_LINEA[BP + 2], AL
	
	; -------------
	; Tercer valor
	; -------------
	
	; Incrementa BP hasta el "hueco" para el siguiente numero
	ADD BP, 4
	
	; Convierte el siguiente elemento de la matriz a ascii y lo guarda en VALOR_IMPRIMIR
	MOV CL, MATRIZ[0][2]
	CALL CONVERT_ASCII_3
	
	; Guarda los tres caracteres del numero en la cadena correspondiente
	MOV AL, VALOR_IMPRIMIR[0]
	MOV PRIMERA_LINEA[BP + 0], AL
	MOV AL, VALOR_IMPRIMIR[1]
	MOV PRIMERA_LINEA[BP + 1], AL
	MOV AL, VALOR_IMPRIMIR[2]
	MOV PRIMERA_LINEA[BP + 2], AL
	
	
	; Imprime la linea
	MOV AH, 9
	MOV DX, OFFSET PRIMERA_LINEA
	INT 21H
	
	
	; -----------------------------------------------------------------
	; Modifica los valores de la segunda fila de la matriz y la imprime
	; -----------------------------------------------------------------
	
	; -------------
	; Primer valor
	; -------------
	
	; Convierte el siguiente elemento de la matriz a ascii y lo guarda en VALOR_IMPRIMIR
	MOV CL, MATRIZ[3][0]
	CALL CONVERT_ASCII_3
	
	; Inicializa BP con el offset en el que debe empezar a guardar los
	; caracteres en la string correspondiente
	MOV BP, OFFSET_INICIAL_LINEA
	
	; Guarda los tres caracteres del numero en la cadena correspondiente
	MOV AL, VALOR_IMPRIMIR[0]
	MOV SEGUNDA_LINEA[BP + 0], AL
	MOV AL, VALOR_IMPRIMIR[1]
	MOV SEGUNDA_LINEA[BP + 1], AL
	MOV AL, VALOR_IMPRIMIR[2]
	MOV SEGUNDA_LINEA[BP + 2], AL
	
	; -------------
	; Segundo valor
	; -------------
	
	; Incrementa BP hasta el "hueco" para el siguiente numero
	ADD BP, 4
	
	; Convierte el siguiente elemento de la matriz a ascii y lo guarda en VALOR_IMPRIMIR
	MOV CL, MATRIZ[3][1]
	CALL CONVERT_ASCII_3
	
	; Guarda los tres caracteres del numero en la cadena correspondiente
	MOV AL, VALOR_IMPRIMIR[0]
	MOV SEGUNDA_LINEA[BP + 0], AL
	MOV AL, VALOR_IMPRIMIR[1]
	MOV SEGUNDA_LINEA[BP + 1], AL
	MOV AL, VALOR_IMPRIMIR[2]
	MOV SEGUNDA_LINEA[BP + 2], AL
	
	; -------------
	; Tercer valor
	; -------------
	
	; Incrementa BP hasta el "hueco" para el siguiente numero
	ADD BP, 4
	
	; Convierte el siguiente elemento de la matriz a ascii y lo guarda en VALOR_IMPRIMIR
	MOV CL, MATRIZ[3][2]
	CALL CONVERT_ASCII_3
	
	; Guarda los tres caracteres del numero en la cadena correspondiente
	MOV AL, VALOR_IMPRIMIR[0]
	MOV SEGUNDA_LINEA[BP + 0], AL
	MOV AL, VALOR_IMPRIMIR[1]
	MOV SEGUNDA_LINEA[BP + 1], AL
	MOV AL, VALOR_IMPRIMIR[2]
	MOV SEGUNDA_LINEA[BP + 2], AL
	
	
	; Imprime la linea
	MOV AH, 9
	MOV DX, OFFSET SEGUNDA_LINEA
	INT 21H
	
	; -----------------------------------------------------------------
	; Modifica los valores de la tercera fila de la matriz y la imprime
	; -----------------------------------------------------------------
	
	; -------------
	; Primer valor
	; -------------
	
	; Convierte el siguiente elemento de la matriz a ascii y lo guarda en VALOR_IMPRIMIR
	MOV CL, MATRIZ[6][0]
	CALL CONVERT_ASCII_3
	
	; Inicializa BP con el offset en el que debe empezar a guardar los
	; caracteres en la string correspondiente
	MOV BP, OFFSET_INICIAL_LINEA
	
	; Guarda los tres caracteres del numero en la cadena correspondiente
	MOV AL, VALOR_IMPRIMIR[0]
	MOV TERCERA_LINEA[BP + 0], AL
	MOV AL, VALOR_IMPRIMIR[1]
	MOV TERCERA_LINEA[BP + 1], AL
	MOV AL, VALOR_IMPRIMIR[2]
	MOV TERCERA_LINEA[BP + 2], AL
	
	; -------------
	; Segundo valor
	; -------------
	
	; Incrementa BP hasta el "hueco" para el siguiente numero
	ADD BP, 4
	
	; Convierte el siguiente elemento de la matriz a ascii y lo guarda en VALOR_IMPRIMIR
	MOV CL, MATRIZ[6][1]
	CALL CONVERT_ASCII_3
	
	; Guarda los tres caracteres del numero en la cadena correspondiente
	MOV AL, VALOR_IMPRIMIR[0]
	MOV TERCERA_LINEA[BP + 0], AL
	MOV AL, VALOR_IMPRIMIR[1]
	MOV TERCERA_LINEA[BP + 1], AL
	MOV AL, VALOR_IMPRIMIR[2]
	MOV TERCERA_LINEA[BP + 2], AL
	
	; -------------
	; Tercer valor
	; -------------
	
	; Incrementa BP hasta el "hueco" para el siguiente numero
	ADD BP, 4
	
	; Convierte el siguiente elemento de la matriz a ascii y lo guarda en VALOR_IMPRIMIR
	MOV CL, MATRIZ[6][2]
	CALL CONVERT_ASCII_3
	
	; Guarda los tres caracteres del numero en la cadena correspondiente
	MOV AL, VALOR_IMPRIMIR[0]
	MOV TERCERA_LINEA[BP + 0], AL
	MOV AL, VALOR_IMPRIMIR[1]
	MOV TERCERA_LINEA[BP + 1], AL
	MOV AL, VALOR_IMPRIMIR[2]
	MOV TERCERA_LINEA[BP + 2], AL
	
	
	; Imprime la linea
	MOV AH, 9
	MOV DX, OFFSET TERCERA_LINEA
	INT 21H
	
	; Mueve el cursor al final de la pantalla para que no se vea junto
	MOV AH, 9
	MOV DX, OFFSET APARTA_CURSOR
	INT 21H
	
	
	; Recupera los valores de los registros que ha modificado
	POP CX BP DX AX 
	RET
	
IMPRESION ENDP


;-------------------------------------------------------------------------- 
; SUBRUTINA PARA CONVERTIR UN NUMERO A TRES DIGITOS ASCII (INCLUIDO SIGNO)
; ENTRADA CL: NUMERO A CONVERTIR
; SALIDA GUARDA EN VALOR_IMPRIMIR LOS TRES DIGITOS
;-------------------------------------------------------------------------- 

CONVERT_ASCII_3 PROC NEAR

	; Guarda los valores de los registros que modifica
	PUSH AX BX CX

	; Inicializa el primer caracter como +
	MOV VALOR_IMPRIMIR[0], "+"
	ADD CL, 0 ; No modifica el registro, pero puede comprobar si es negativo
	JS ES_NEGATIVO
	
	; A partir de aquí se desarrolla el algoritmo de la división para calcular
	; cada dígito del numero. Se hacen dos pasos, porque esta rutina es usada
	; solo para los numeros de la matriz, que ya comprobamos anteriormente
	; que estan el en rango [-16, 15]
CONTINUAR:
	MOV AL, CL ; Inicializa AX con el valor a convertir (1 byte)
	MOV AH, 0
	MOV BL, 10 ; Inicializa BL con 10, el valor por el que se divide
	
	DIV BL ; Realiza la division
	
	; AH almacena el resto de la operación, que es lo que nos interesa,
	; y le suma 30h, la diferencia para convertir un numero a ascii
	ADD AH, 30H
	MOV VALOR_IMPRIMIR[2], AH	; Guarda el primer resto (que será el último dígito)
	MOV CL, AL					; Guarda el cociente en CL, para hacer otro paso del algoritmo
	
	; Realiza otro paso del algoritmo. Como son dos pasos, hemos decidido
	; no utilizar bucles, que dificulten la comprensión del código. No volvemos
	; a explicar el algoritmo
	MOV AL, CL
	MOV AH, 0
	MOV BL, 10
	DIV BL
	ADD AH, 30H
	MOV VALOR_IMPRIMIR[1], AH
	MOV CL, AL
	
    ; Recupera los valores de los registros que ha modificado
	POP CX BX AX 
	RET

ES_NEGATIVO:
	NEG CL						; Calcula el complemento a 2 del número para que funcione el algoritmo
	MOV VALOR_IMPRIMIR[0], "-"	; Sobreescribe el signo como -
	JMP CONTINUAR
	
CONVERT_ASCII_3 ENDP


;-------------------------------------------------------------------------- 
; SUBRUTINA PARA CONVERTIR UN NUMERO A CINCO DIGITOS ASCII (INCLUIDO SIGNO)
; ENTRADA CX: NUMERO A CONVERTIR
; SALIDA GUARDA EN RESULTADO_IMPRIMIR LOS TRES DIGITOS
;-------------------------------------------------------------------------- 

CONVERT_ASCII_5 PROC NEAR
	
	; Guarda los valores de los registros que modifica
	PUSH AX BX CX DX
	
    ; Inicializa el primer caracter como +
	MOV RESULTADO_IMPRIMIR[0], "+"
	ADD CX, 0 ; No modifica el registro, pero puede comprobar si es negativo
	JS ES_NEGATIVO_5
	
	; A partir de aquí se desarrolla el algoritmo de la división para calcular
	; cada dígito del resultado. Se hacen cuatro pasos, porque esta rutina es usada
	; solo para el resultado de la matriz, que sabemos que no va a superar estos dígitos
CONTINUAR_5:
	MOV AX, CX	; Inicializa AX con el valor a convertir (2 byte)
	MOV DX, 0
	MOV BX, 10	; Inicializa BL con 10, el valor por el que se divide
	
	DIV BX ; Realiza la division
	
	; DX almacena el resto de la operación, que es lo que nos interesa,
	; y le suma 30h, la diferencia para convertir un numero a ascii
	ADD DX, 30H
	MOV RESULTADO_IMPRIMIR[4], DL	; Guarda el primer resto (que será el último dígito)
	MOV CX, AX						; Guarda el cociente en CL, para hacer otro paso del algoritmo
	
	; Realiza otro paso del algoritmo. Como son cuatro pasos, hemos decidido
	; no utilizar bucles, que dificulten la comprensión del código. No volvemos
	; a explicar el algoritmo
	MOV AX, CX
	MOV DX, 0
	MOV BX, 10	; Inicializa BL con 10, el valor por el que se divide
	
	DIV BX
	ADD DX, 30H
	MOV RESULTADO_IMPRIMIR[3], DL
	MOV CX, AX
	
	; Realiza otro paso del algoritmo. Como son cuatro pasos, hemos decidido
	; no utilizar bucles, que dificulten la comprensión del código. No volvemos
	; a explicar el algoritmo
	MOV AX, CX
	MOV DX, 0
	MOV BX, 10	; Inicializa BL con 10, el valor por el que se divide
	
	DIV BX
	ADD DX, 30H
	MOV RESULTADO_IMPRIMIR[2], DL
	MOV CX, AX
	
	; Realiza otro paso del algoritmo. Como son cuatro pasos, hemos decidido
	; no utilizar bucles, que dificulten la comprensión del código. No volvemos
	; a explicar el algoritmo
	MOV AX, CX
	MOV DX, 0
	MOV BX, 10	; Inicializa BL con 10, el valor por el que se divide
	
	DIV BX
	ADD DX, 30H
	MOV RESULTADO_IMPRIMIR[1], DL
	MOV CX, AX
	
    ; Recupera los valores de los registros que ha modificado
	POP DX CX BX AX 
	RET

ES_NEGATIVO_5:
	NEG CX							; Calcula el complemento a dos del número para seguir con el algoritmo
	MOV RESULTADO_IMPRIMIR[0], "-"	; Sobreescribe el signo del número como -
	JMP CONTINUAR_5
	
CONVERT_ASCII_5 ENDP

INICIO ENDP

; FIN DEL SEGMENTO DE CODIGO
CODE ENDS

; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END INICIO