_decodeBarCode proc FAR:
    push bp
    mov bp, sp
    push bx, cx, di, ax
    
    add bp, 2
    
    les bx, [bp+4]
    
    ; countryCode
    mov cx, 3
    call convertir_a_long
    lds di, [bp+8]
    mov ds:[di], ax
    add bx, 3
    
    ; companyCode
    mov cx, 4
    call convertir_a_long
    lds di, [bp+12]
    mov ds:[di], ax
    add bx, 4
    
    ; productCode
    mov cx, 5
    call convertir_a_long
    lds di, [bp+16]
    mov ds:[di], ax
    mov ds:[di+1], dx
    add bx, 5
    
    ; controlDigit
    mov cx, 1
    call convertir_a_long
    lds di, [bp+20]
    mov ds:[di], ax
    
     
    pop ax, di, cx, bx
    pop bp
    
    ret
    
_decodeBarCode endp

convertir_a_long proc FAR:
    push si, di
    
    mov ax, 0
    mov dx, 0
    mov si, 0    
    
bucle:
    mov di, 10
    mul di
    
    mov di, es:[bx][si] 
    and di, 00ffh
    sub di, "0"
    add ax, di
    
    jnc sin_acarreo
    inc dx

sin_acarreo:    
    inc si
    cmp si, cx
    jl bucle
    
    pop di, si
    
    ret
    
convertir_a_long endp