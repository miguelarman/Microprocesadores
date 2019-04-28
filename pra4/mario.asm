; multi-segment executable file template.

datos SEGMENT
    hola        db "AB"
    table_ctop  db 48 dup(?,?)
                db "6566"
                db "111213141516"   
                db "2122"
                db 7 dup(?,?)
                db "23242526"
                db "313233343536"
                db "414243444546"
                db "515253545556"
                db "61626364"
    table_ptoc  db "234567"
                db "89ABCD"
                db "EFGHIJ"
                db "KLMNOP"
                db "QRSTUV"
                db "WXYZ01"
                
    out_str     db 200 dup(?)
    perror      db "Error: el servicio pedido no existe:"
                db " AH=10h para codificar,"
                db " AH=11h para decodificar$" 
    in_str      db "HOLAQUETAL03$"
    in_str2     db "344542235155315423426512$"
	str_acab	db "ALLCATSAREBEAUTIFUL$"
    
    
    pkey db "press any key...$"
datos ENDS

PILA SEGMENT STACK "STACK"
DB 40H DUP (0) ;ejemplo de inicialización, 64 bytes inicializados a 0
PILA ENDS

code segment
ASSUME CS: code, DS: datos
start:
; set segment registers:
    mov ax, datos
    mov ds, ax
    mov es, ax
    
    lea dx, str_acab
    mov ah, 10h
    
    ;; desde aqui es lo mio
    
    cmp ah, 10h
    je opt_encode
    
    cmp ah, 11h
    je opt_decode
    
    lea dx, perror
    mov ah, 9
    int 21h
    jmp salir
    
opt_encode:
    call encode_polibio
    jmp salir
    
opt_decode:
    call decode_polibio
    jmp salir
    
salir:    
    mov ax, 4c00h ; exit to operating system.
    int 21h    

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
    mov out_str[di], "$"
    lea dx, out_str
    mov ah, 9
    int 21h
    
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
    mov out_str[di], "$"
    lea dx, out_str
    mov ah, 9
    int 21h
    
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



code ends
end start ; set entry point and stop the assembler.
