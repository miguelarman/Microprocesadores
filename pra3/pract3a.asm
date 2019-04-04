;**************************************************************************
;               SISTEMAS BASADOS EN MICROPROCESADORES - 2019			  ;
;                    PRÁCTICA 3: Diseño de programas					  ;
;                       utilizando C y ensamblador					  	  ;
;**************************************************************************
; Autores:																  ;
; 			- Miguel Arconada Manteca									  ;
;				(miguel.arconada@estudiante.uam.es)						  ;
; 			- Mario García Pascual										  ;
;				(mario.garciapascual@estudiante.uam.es)					  ;
;**************************************************************************
; Fecha:	4 de abril de 2019											  ;
;**************************************************************************

DGROUP GROUP _DATA, _BSS				;; Se agrupan segmentos de datos en uno

_DATA SEGMENT WORD PUBLIC 'DATA' 		;; Segmento de datos DATA público

_DATA ENDS

_BSS SEGMENT WORD PUBLIC 'BSS'			;; Segmento de datos BSS público

_BSS ENDS

_TEXT SEGMENT BYTE PUBLIC 'CODE' 		;; Definición del segmento de código
ASSUME CS:_TEXT, DS:DGROUP, SS:DGROUP


;;;;;
;
; computeControlDigit
;
; Esta funcion realiza el computo automatico del digito de control del codigo
; de barras. Recibe un puntero a la cadena completa de caracteres ASCII y 
; retorna el valor decimal del digito de control.
;
;;;;;

PUBLIC _computeControlDigit
_computeControlDigit PROC FAR

	; Guarda los valores de los registros para no modificarlos
	PUSH BP
	
	; Guarda en BP el valor de SP
	MOV BP, SP
	
	; Guarda los registros para evitar modificaciones (excepto AX pues se usa para devolver) 
	PUSH BX CX DX SI ES

	; Lee la direccion de la entrada del argumento
	LES BX, [BP + 6]		; BX contiene el offset del dato de entrada y ES contiene el segmento

	; Prepara los registros necesarios para el bucle
	MOV SI, 0				; SI servirá como índice del caracter leído
	MOV DL, 0				; DL guardará cada caracter leído
	MOV AL, 0				; AL guarda la suma de los números en posición par
	MOV CL, 0				; CL guarda la suma de los números en posición impar

BUCLE_SUMA:
	MOV DL, ES:BX[SI]		; Carga en DL un digito del codigo de barras
	SUB DL, '0'				; Convertimos de ascii a binario
	
	; Opera con el digito
	TEST SI, 00000001b		; Comprueba si es par (impar al empezar en cero)
	JNZ ES_PAR
	
	ADD CL, DL				; Es impar. Lo suma a CL
	JMP CONTINUA_SUMA
ES_PAR:
	ADD AL, DL				; Es par. Lo suma a AL
	
CONTINUA_SUMA:
	INC SI					; Actualiza el índice
	CMP SI, 12				; Si es 12 (ya se han leído los doce caracteres) sale del bucle
	JNE BUCLE_SUMA
	
	; Sale del bucle. Calcula la suma
	MOV BL, 3
	MUL BL					; AL ahora contiene la suma par multiplicada por tres
	ADD CL, AL				; CL tiene la suma total
	
	MOV AL, CL				; Guardamos la suma total en AX, por lo que ponemos AH a 0
	XOR AH, AH			
	
	; Calcula el digito de control
		
	MOV DX, 0
	MOV CX, 10				; Dividimos la suma total entre diez para ver el último dígito
	DIV CX					; DX contiene el resto
	
	MOV BX, 10				; Restamos el resto de 10, para ver el digito de control
	SUB BX, DX
	
	CMP BX, 10				; Comprobamos si la resta devuelve 10, cuando el último dígito es 0
	JE BL_ES_DIEZ
	
CONTINUA_RESTO:
	MOV AX, BX				; Guardamos el resultado de la resta en AX para devolverlo
	XOR AH, AH				; El digito ocupa un byte (ponemos AH a cero)
	
	; Recupera los valores anteriores de los registros
	POP ES SI DX CX BX
	POP BP
	RET

BL_ES_DIEZ:
	SUB BL, 10				; Restamos diez si el caracter de control sale 10 (debería ser 0)
	JMP CONTINUA_RESTO

_computeControlDigit ENDP

;;;;;
;
; decodeBarCode
;
; Esta funcion lee los 13 caracteres del codigo de barras y obtiene cada campo almacenado
; en los parametros de entrada-salida correspondientes al codigo de pais, el codigo de
; empresa, el codigo de producto y el digito de control.
;
;;;;;

PUBLIC _decodeBarCode
_decodeBarCode PROC FAR
    PUSH BP
    MOV BP, SP
    PUSH BX CX DI AX ES DS  ; Metemos en la pila todos los registros que usamos
    
    ADD BP, 2				; Con esto nos saltamos el primer push de BP
    
    LES BX, [BP+4]			; Guardamos en ES el segmento de la cadena de caracteres
    						; y en BX el offset 
    ; COUNTRYCODE
    MOV CX, 3
    CALL CONVERTIR_A_LONG
    LDS DI, [BP+8]
    MOV DS:[DI], AX
    ADD BX, 3
    
    ; COMPANYCODE			; Los demas campos son iguales, salvo tamaño de lo que se lee y se guarda
    MOV CX, 4				; Se guarda en CX el numero de caracteres que hay que leer
    CALL CONVERTIR_A_LONG 	; Se guarda en DX:AX el entero largo correspondiente al numero leido
    LDS DI, [BP+12]			; Se guarda en DS:[DI] la direccion donde hay que guardar el numero
    MOV DS:[DI], AX 		; Se guarda el numero en la direccion de memoria
    ADD BX, 4 				; Se incrementa el puntero de la cadena tanto como caracteres leidos
    
    ; PRODUCTCODE
    MOV CX, 5
    CALL CONVERTIR_A_LONG
    LDS DI, [BP+16]
    MOV DS:[DI], AX
    MOV DS:[DI+2], DX
    ADD BX, 5
    
    ; CONTROLDIGIT
    MOV CX, 1
    CALL CONVERTIR_A_LONG
    LDS DI, [BP+20]
    MOV DS:[DI], AL
    
    POP DS ES AX DI CX BX
    POP BP
    RET
    
_DECODEBARCODE 

;;;;;
;
; convertir_a_long
;
; Esta funcion auxiliar recibe en CX el numero de caracteres que se
; tienen que leer de ES:[BX] para convertirlos al valor numérico
; que representan. Por la manera que esta implementado, no se reco-
; mienda utilizarla con más de 5 caracteres por posibles problemas
; con el acarreo
;
;;;;;

CONVERTIR_A_LONG PROC NEAR
    PUSH SI DI
    
    MOV AX, 0
    MOV DX, 0
    MOV SI, 0    
    
BUCLE:
    MOV DI, 10
    MUL DI
    
    MOV DI, ES:[BX][SI]		; Indexamos con SI
    AND DI, 00FFH
    SUB DI, "0"				; Convertimos a digito numerico
    ADD AX, DI
    
    JNC SIN_ACARREO			; Si ha habido un problema de acarreo, incrementamos 1
    INC DX					; a DX. Esto funciona porque esto solo puede pasar 
    						; en la quinta interacion, que en el caso de ocurrir
SIN_ACARREO:    			; sera la ultima, y por tanto no le da tiempo a la
    INC SI 					; multiplicacion AX * 10 --> DX:AX a sobreescribir 
    CMP SI, CX				; DX
    JL BUCLE 				; Si el indice es menor igual que CX, continuamos
    
    POP DI SI
    
    RET
    
CONVERTIR_A_LONG ENDP


_TEXT ENDS
END