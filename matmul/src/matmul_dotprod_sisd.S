; Course : Computer Structure Architecture
; Instructor : Dr Jahangir
; Student : Mahdi Bahramian -- 401171593
;
; MatMul - dotproduct algorithm sisd
; Usage Instruction : 
; Compile and run program to executable using the following command
; nasm -felf64 matmul_dotprod_sisd.S -o matmul_dotprod_sisd.o && gcc main.c matmul_dotprod_sisd.o -o exec && ./exec
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

%macro calc_dot 0 ;calculate [rsi] dot [rdi] as vector size : rcx return xmm0
    movss       xmm0, [zero_v]
    calc_dot_loop:
        movss       xmm1, [mat1 + rsi * 4]
        movss       xmm2, [mat2 + rdi * 4]
        mulss       xmm1, xmm2
        addss       xmm0, xmm1
        inc         rsi
        inc         rdi
        loop        calc_dot_loop
    dec         rsi
    dec         rdi
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

    ;; FAST NORMAL ITERATION
    mov         rcx, qword[n]
    xor         rsi, rsi
    MAT1_i: ; rbx
        mov         rbx, rcx
        mov         rcx, qword[n]
        MAT1_j: ; rcx
            asm_read_float
            movss       [mat1 + rsi * 4], xmm0
            inc         rsi
            loop        MAT1_j
        dec         rsi
        and         si,  0xFE00
        add         rsi, 0x0200
        mov         rcx, rbx
        loop        MAT1_i
    
    ;; FAST TRANSPOSE ITERATION
    mov         rcx, qword[n]
    xor         rsi, rsi
    MAT2_i: ; rbx
        mov         rbx, rcx
        mov         rcx, qword[n]
        MAT2_j: ; rcx
            asm_read_float
            movss       [mat2 + rsi * 4], xmm0
            add         rsi, 0x200
            loop        MAT2_j
        and         rsi, 0x1FF
        inc         rsi
        mov         rcx, rbx
        loop        MAT2_i

    mov         rcx, qword[n]
    xor         rax, rax
    xor         rsi, rsi
    MAT3_i: ; rbx
        mov         rbx, rcx
        mov         rcx, qword[n]
        xor         rdi, rdi
        MAT3_j: ; rcx
            mov         r8, rcx
            mov         rcx, qword[n]
            calc_dot
            mov         rcx, r8
            movss       [mat3 + rax * 4], xmm0
            inc         rax
            and         di, 0xFE00
            and         si, 0xFE00
            add         rdi, 0x0200
            loop        MAT3_j
        dec         rax
        and         ax,  0xFE00
        add         rax, 0x0200
        mov         rcx, rbx
        add         rsi, 0x0200
        dec         rcx
        jnz         MAT3_i

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
