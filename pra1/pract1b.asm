;**************************************************************************
; SBM 2019. ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR
;**************************************************************************
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT

	;Reservar memoria para una variable, CONTADOR, de un byte de tamaño.
	CONTADOR 	DB	?		; Usamos DB para indicar que es un solo byte, y ? para reservar memoria sin inicializar

	;Reservar memoria para una variable, TOME, de dos bytes de tamaño, e inicializarla con el valor CAFEH
	TOME		DW	0CAFEH			; Usamos DW para indicar que son dos bytes y lo inicializamos
									; (con 0 delante de CAFEh para que lo entienda el compilador)
	
	;Reservar 100 bytes para una tabla llamada TABLA100
	TABLA100	DB	100 dup(?)		; Reservamos memoria, pero al usar el ? no lo inicializamos
	
	;Guardar en memoria la cadena de texto “Atención: Entrada de datos incorrecta.”, de nombre ERROR1,
	;para agilizar la salida de mensajes en un programa de corrección automática de prácticas.
	ERROR1		DB	"Atención: Entrada de datos incorrecta.", 13, 0Ah
					; Guardamos la cadena, y los caracteres 13 y 0Ah, que representan el final de cadena de caracteres

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

	; Copiar el tercer carácter de la cadena ERROR1 en la posición 63H de TABLA100
	MOV AL, DS:[ERROR1 + 2] ; El primer caracter está en el offset 0, y el tercero, como son bytes, en el offset 2
	MOV TABLA100[63H],  AL
	
	; Copiar el contenido de la variable TOME a partir de la posición 23H de TABLA100
	MOV AX, DS:[TOME]
	MOV WORD PTR TABLA100[23H], AX ; Hay que hacer casting, ya que los tamaños no son iguales
	
	; Copiar el byte más significativo de TOME a la variable CONTADOR
	MOV AX, DS:[TOME]			; Guardamos los dos bytes en AX, por lo que AL es el byte más significativo
	MOV CONTADOR, AL  			; No hay que hacer casting, ya que CONTADOR ya está definido con un solo byte


; FIN DEL PROGRAMA
MOV AX, 4C00H
INT 21H
INICIO ENDP
; FIN DEL SEGMENTO DE CODIGO
CODE ENDS
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END INICIO 