;**************************************************************************
; SBM 2019. ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR
;**************************************************************************
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT
	crnl        db	10,13,"$"
    buff        db  26        ; numero maximo de caracteres
    nchars      db  ?         ; caracteres introducidos por el usuario
    in_str      db	26 dup(?)  ; string introducido por el usuario
    cod         db	"cod$"
    decod       db	"decod$"
    quit        db	"quit$"
    mode        db	10h        ; el modo predeterminado es cod
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
	
start:
; set segment registers:
    mov ax, DATOS
    mov ds, ax
    mov es, ax
    

    
bucle:
    ;; Leemos input del usuario
    lea dx, buff
    mov ah, 10
    int 21h
    
    ;; Le ponemos un $ al final
    mov al, nchars
    mov ah, 0
    mov si, ax
    mov in_str[si], "$" 
    
    ;; Salto de linea y retorno de carro
    lea dx, crnl
    mov ah, 9
    int 21h
    
    lea bx, cod
    call str_cmp
    cmp al, 0
    je opt_cod
    
    lea bx, decod
    call str_cmp
    cmp al, 0
    je opt_decod
    
    lea bx, quit
    call str_cmp
    cmp al, 0
    je salir
    
    lea dx, in_str
    mov ah, mode
    int 57h
    
    ;; Salto de linea y retorno de carro
    lea dx, crnl
    mov ah, 9
    int 21h
    
    jmp bucle
    
opt_cod:
    mov mode, 10h
    jmp bucle

opt_decod:
    mov mode, 11h
    jmp bucle    

salir:    
    mov ax, 4c00h ; exit to operating system.
    int 21h
INICIO ENDP

;;;;;;
;;
;; Compara la cadena almacenada en in_str con
;; la cadena almacenada en DS:BX, ambas acaba-
;; das en "$". Devuelve 0 en AL si las cadenas
;; son iguales y 1 si no lo son
;;
str_cmp proc near
    push si
    
    mov si, 0
b0: 
    mov al, ds:[bx][si]
    mov ah, in_str[si]
    cmp al, "$"
    je fin_b0
    
    inc si 
    cmp al, ah
    je b0
    
fin_b0:    
    sub al, ah
    
    pop si
    
    ret
 
    
str_cmp endp
; FIN DEL SEGMENTO DE CODIGO
CODE ENDS
END INICIO