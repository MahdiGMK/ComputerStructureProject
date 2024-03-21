; Course : Computer Structure Architecture
; Instructor : Dr Jahangir
; Student : Mahdi Bahramian -- 401171593
;
; MatMul - ikj iteration algorithm sisd
; Usage Instruction : 
; Compile and run program to executable using the following command
; nasm -felf64 matmul_sisd.S -o matmul_sisd.o && gcc main.c matmul_sisd.o -o exec && ./exec
; Then input data as stdin with the following format
; n (n <= 512)
; a00 a01 ...
; a10 a11 ...
; ...
; b00 b01 ...
; b10 b11 ...
; ...
; And outputs data as stdout with the following format
; c00 c01 ...
; c10 c11 ...
; ...
global asm_main
%include "../src/asm_io.S"

section .text

%macro calc_dot 0 ;calculate [rsi] dot [rdi] as vector size : rcx*8 return xmm0
    movss       xmm0, [zero_v]
    calc_dot_loop:
        vmovaps     ymm1, [mat1 + rsi * 4]
        vmovaps     ymm2, [mat2 + rdi * 4]
        vdpps       ymm1, ymm1, ymm2, 0xF1
        vperm2f128  ymm2, ymm1, ymm1, 0x01
        addss       xmm1, xmm2
        addss       xmm0, xmm1
        add         rsi, 8
        add         rdi, 8
        loop        calc_dot_loop
    sub         rsi, 8
    sub         rdi, 8
%endmacro

asm_main:
    xor         rax, rax
    mov         al , spl
    sub         rsp, rax
    ;stack_align
    
    ; mov         rax, input_dim_message
    ; call        asm_write_str
    ; call        asm_flush

    ReadDIM:
    call        asm_read_uint
    
    cmp         rax, 512
    jle         OkDIM
    
    mov         rax, wrong_dim_error
    call        asm_write_str
    jmp         ReadDIM

    OkDIM:
    mov         qword[n], rax
    mov         bl , al
    shr         rax, 3
    and         bl , 0x07
    jz          OkNV
    inc         rax
    OkNV:
    mov         qword[nv], rax

    ; rsi = 0; // rsi == (i << 9) | j
    ; for(rbx = n ; rbx != 0 ; rbx-- , rsi = rsi + 512)
    ;   for(rcx = n ; rcx != 0 ; rcx-- , rsi++)
    ;       scanf("%f" , mat1 + rsi);

    ;; INPUT MAT1
    mov         rbx, qword[n]
    xor         rsi, rsi
    MAT1_i: ; rbx
        mov         rcx, qword[n]
        MAT1_j: ; rcx
            asm_read_float
            movss       [mat1 + rsi * 4], xmm0
            inc         rsi
            loop        MAT1_j
        dec         rsi
        and         si,  0xFE00
        add         rsi, 0x0200
        dec         rbx
        jnz         MAT1_i
    
    ;; INPUT MAT2
    mov         rbx, qword[n]
    xor         rsi, rsi
    MAT2_i: ; rbx
        mov         rcx, qword[n]
        MAT2_j: ; rcx
            asm_read_float
            movss       [mat2 + rsi * 4], xmm0
            inc         rsi
            loop        MAT2_j
        dec         rsi
        and         si,  0xFE00
        add         rsi, 0x0200
        dec         rbx
        jnz         MAT2_i

    ; i , k , j
    ; mat3[i][j..] = mat3[i][j..] + mat1[i][k] * mat2[k][j..]


    ; rsi {i , k}
    ; rdx {i , j}
    ; rdi {k , j}
    xor     rsi,rsi
    xor     rdx,rdx
    mov     r9, qword[n]
    i:
        xor     rdi,rdi
        mov     r8, qword[n]
        k:
            movss           xmm0, [mat1 + rsi * 4] ; load mat1[i][k]
            inc             si
            mov             rcx, qword[n]
            movss           xmm2, [mat2 + rdi * 4] ; load first mat2 cell(mat2[k][0])
            movss           xmm3, [mat3 + rdx * 4] ; load first mat3 cell(mat3[i][0])
            j:
                vmulss      xmm1, xmm0 , xmm2; xmm2 := mat1[i][k] * mat2[k][j]
                movss       xmm2, [mat2 + rdi * 4 + 4] ; load next mat2 cell
                addss       xmm1, xmm3 ; xmm2 := mat3[i][j] + mat1[i][k] * mat2[k][j]
                movss       xmm3, [mat3 + rdx * 4 + 4] ; load next mat3 cell
                movss       [mat3 + rdx * 4], xmm1 ; rdx = i * 0x0200 + j
                inc         di
                inc         dx
                loop        j
                
            dec         dx
            and         dx, 0xFE00

            dec         di
            and         di, 0xFE00
            add         rdi,0x0200
            dec         r8
            jg          k
        dec         si
        and         si, 0xFE00
        add         rsi,0x0200
        
        add         rdx,0x0200
        dec         r9
        jg          i

    ;; FAST NORMAL PRINT
    mov         rbx, qword[n]
    xor         rsi, rsi
    PRINT_i: ; rbx
        mov         rcx, qword[n]
        PRINT_j: ; rcx
            movss       xmm0, [mat3 + rsi * 4]
            asm_write_float
            mov         rax, ' '
            asm_write_char
            inc         rsi
            loop        PRINT_j
        dec         rsi
        and         si,  0xFE00
        add         rsi, 0x0200
        mov         rax, 10
        asm_write_char
        dec         rbx
        jnz         PRINT_i

    ; now we have mat1 and mat2

    End:
    call        flush
    mov         rax, 60
    xor         rdi, rdi
    syscall


section .data align=64
mat1:
    dd 0x40000 DUP(0.0)
mat2:
    dd 0x40000 DUP(0.0)
mat3:
    dd 0x40000 DUP(0.0)
tmp_v1: 
    dd 8 DUP(0.0)
tmp_v2: 
    dd 8 DUP(0.0)
zero_v:
    dd 8 DUP(0.0)
one_v:
    dd 8 DUP(1.0)

n: dq 0
nv: dq 0

section .rodata
input_dim_message: db "input dim of matrix (0 <= n <= 512) : "  , 0
wrong_dim_error: db "input a valid n (0 <= n <= 512)" , 10 , 0
