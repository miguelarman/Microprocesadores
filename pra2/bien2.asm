; multi-segment executable file template.

data segment
    matriz db 9 dup(0)
    signo  db 0
    buff db 36
         db ?
    str  db 36 dup(0)
    bienvenida db "Introduzca los 9 datos separados SOLO por comas",
               db " (sin espacios), con un maximo de 2 digitos por",
               db " numero e indicando los numeros negativos con u",
               db "n - delante, por ejemplo ->1,-2,3,-4,11,-12,13,",
               db "-14,15[ENTER]. Ademas, los numeros introducidos",
               db " deberan estar en el rango [-16,15].", 10, 13, 10, 13, "$"
    perror1    db 10, 13, "Error: datos fuera de rango$"
    perror2    db 10, 13, "Error: datos insuficientes$"
    perror3    db 10, 13, "Error: formato incorrecto$"
ends

stack segment
    dw   128  dup(0)
ends

code segment
    assume ds:data
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax
    
    ; A partir de aqui empieza la rutina que lee la entrada del usuario	
	LEA DX, CLR_PANT
	MOV AH, 9
	INT 21H
	
	; Se pregunta al usuario si quiere introducir datos o probarlo con los datos
	; por defecto
	
	LEA DX, INICIO
	MOV AH, 9
	INT 21h
	
	MOV AH, 1
	INT 21h
	
	CMP AL, "y"
	JE INTRODUCIR
	RET   
    
    ; Da la bienvenida al usuario y le indica
    ; como introducir los datos
INTRODUCIR:

    LEA DX, CLR_PANT
	MOV AH, 9
	INT 21H
	
    
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
    mov al, str[si]
    cmp al, "-"
    jne else
    mov signo, 1
    inc si
    mov al, str[si]
    jmp both
else:
    mov signo, 0
both:
    sub al, "0"
    mov dl, str[si+1]
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
    
bucleaux:
    jmp bucle
        
    
write1:                 ; El numero a escribir esta en AL,
    cmp signo, 1        ; si es un numero negativo toma el
    jne j1              ; complemento a 2
    neg al

j1: cmp al, -16         ; Comprueba rangos y escribe
    jl error1
    cmp al, 15
    jg error1
    mov matriz[di], al
    
    inc di              ; Aumenta los indices
    add si, 2
    
    cmp dl, 13          ; Comprueba si el caracter siguiente 
    je finbucle         ; es de control (coma o retorno), actua
    cmp dl, ","         ; formato en caso contrario. Esta en DL 
    jne error3          ; en consecuencia y devuelve error de
                            
    cmp di, 9
    jl bucleaux
    jmp finbucle
    
write2:
    mov ah, 10          ; El digito alto del numero a escribir esta           
    mul ah              ; en AL y el bajo en DL, si es un numero
    add al, dl          ; negativo toma el complemento a dos
    cmp signo, 1
    jne j2
    neg al
    
j2: cmp al, -16         ; Comprueba rangos y escribe
    jl error1
    cmp al, 15
    jg error1
    mov matriz[di], al
    
    inc di              ; Aumenta los indices
    add si, 3
    
    mov dl, str[si-1]   ; Al aumentar 3 estamos posicionados en el
    cmp dl, 13          ; siguiente digito, por eso -1 para mirar atras.
    je finbucle         ; Comprueba si el caracter siguiente es de
    cmp dl, ","         ; control, devuelve error en caso contrario
    jne error3
        
    cmp di, 9
    jl bucleaux
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
    mov ah, 4ch
    int 21h    
    
exit:
    mov ah, 4ch ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
