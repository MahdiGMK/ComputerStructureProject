; Course : Computer Structure Architecture
; Instructor : Dr Jahangir
; Student : Mahdi Bahramian -- 401171593
;
; Convolution - matrix dotproduct simd
; Usage Instruction : 
; Compile and run program to executable using the following command
; nasm -felf64 convolution.S -o convolution.o && gcc main.c convolution.o -o exec && ./exec
; Then input data as stdin with the following format
; n m (m <= n <= 1024)
; a00 a01 ...
; a10 a11 ...
; ...
; b00 b01 ...
; b10 b11 ...
; ...
; And outputs data as stdout with the following format
; r (r = n - m + 1)
; c00 c01 ...
; c10 c11 ...
; ...
global asm_main
%include "../src/asm_io.S"

section .text

MATSIZE: equ 0x1000000
ZEROJ: equ 0xF000
INCI:  equ 0x1000


%macro matdot 0 ; takes rax as the index to top left location of mat1 matrix to be dotproducted with mat2 matrix and puts result in xmm0

    vmovaps     ymm0 , [zero_v]
    xor         rsi, rsi
    mov         r10, qword[m]
    k:
        mov     rcx, qword[mv]
        lv:
            vmovaps     ymm1 , [mat2 + rsi]; mat2[k][l] ; rsi = k * 0x0400 + l
            vmulps      ymm1 , [mat1 + rsi + rax]; mat1[i+k][j+l] ; 
            vaddps      ymm0 , ymm1
            add         si , 32
            loop        lv

        sub         si, 32
        and         si, ZEROJ
        add         rsi,INCI

        dec         r10
        jnz         k

    vdpps       ymm0 , ymm0 , [one_v] , 0xF1
    vperm2f128  ymm1 , ymm0 , ymm0 , 0x01
    addss       xmm0 , xmm1

%endmacro

asm_main:
    xor         rax, rax
    mov         al , spl
    sub         rsp, rax
    ;stack_align

    ReadDIM:
    call        asm_read_uint
    mov         rbx, rax
    call        asm_read_uint
    
    cmp         rbx, 1024
    jg          WRONG
    cmp         rax, rbx
    jg          WRONG
    jmp         OkDIM
    
    WRONG:
    mov         rax, wrong_dim_error
    call        asm_write_str
    jmp         ReadDIM

    OkDIM:
    mov         qword[n], rbx
    mov         qword[m], rax
    mov         bl , al
    shr         rax, 3
    and         bl , 0x07
    jz          OkMV
    inc         rax
    OkMV:
    mov         qword[mv], rax

    mov         rbx, qword[n]
    sub         rbx, qword[m]
    inc         rbx
    mov         qword[r], rbx

    ;; INPUT MAT1
    mov         rcx, qword[n]
    xor         rsi, rsi
    MAT1_i: ; rbx
        mov         rbx, rcx
        mov         rcx, qword[n]
        MAT1_j: ; rcx
            asm_read_float
            movss       [mat1 + rsi], xmm0
            add         rsi, 4
            loop        MAT1_j
        dec         rsi
        and         si,  ZEROJ
        add         rsi, INCI
        mov         rcx, rbx
        loop        MAT1_i
    
    ;; INPUT MAT2
    mov         rcx, qword[m]
    xor         rsi, rsi
    MAT2_i: ; rbx
        mov         rbx, rcx
        mov         rcx, qword[m]
        MAT2_j: ; rcx
            asm_read_float
            movss       [mat2 + rsi], xmm0
            add         rsi, 4
            loop        MAT2_j
        dec         rsi
        and         si,  ZEROJ
        add         rsi, INCI
        mov         rcx, rbx
        loop        MAT2_i

    xor         rax, rax
    mov         r8, qword[r]
    i:
        ;
        mov         r9, qword[r]
        j:
            matdot
            movss       [mat3 + rax] , xmm0 ; mat3[i][j] ; rax = i * 0x0200 + l
            add         ax, 4

            dec         r9
            jnz         j

        sub         ax, 4
        and         ax, ZEROJ
        add         rax,INCI

        dec         r8
        jnz         i

    


    ;; FAST NORMAL PRINT
    mov         rax, qword[r]
    call        asm_write_uint
    mov         rax, 10
    call        asm_write_char
    mov         rcx, qword[r]
    xor         rsi, rsi
    PRINT_i: ; rbx
        mov         rbx, rcx
        mov         rcx, qword[r]
        PRINT_j: ; rcx
            movss       xmm0, [mat3 + rsi]
            asm_write_float
            mov         rax, ' '
            call        asm_write_char
            add         rsi, 4
            loop        PRINT_j
        dec         rsi
        and         si,  ZEROJ
        add         rsi, INCI
        mov         rax, 10
        call        asm_write_char
        mov         rcx, rbx
        loop        PRINT_i

    ; now we have mat1 and mat2

    End:
    call        flush
    mov         rax, 60
    xor         rdi, rdi
    syscall


section .data align=64
mat1:
    dd MATSIZE DUP(0.0)
mat2:
    dd MATSIZE DUP(0.0)
mat3:
    dd MATSIZE DUP(0.0)
tmp_v1: 
    dd 8 DUP(0.0)
tmp_v2: 
    dd 8 DUP(0.0)
zero_v:
    dd 8 DUP(0.0)
one_v:
    dd 8 DUP(1.0)

n: dq 0
m: dq 0
r: dq 0
mv: dq 0

section .rodata
wrong_dim_error: db "input a valid n,m (0 <= m <= n <= 1024)" , 10 , 0
