; Course : Computer Structure Architecture
; Instructor : Dr Jahangir
; Student : Mahdi Bahramian -- 401171593
;
; Convolution - matrix dotproduct sisd
; Usage Instruction : 
; Compile and run program to executable using the following command
; nasm -felf64 convolution_sisd.S -o convolution_sisd.o && gcc main.c convolution_sisd.o -o exec && ./exec
; Then input data as stdin with the following format
; n m (m <= n <= 1024)
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

; %macro calc_dot 0 ;calculate [rsi] dot [rdi] as vector size : rcx*8 return xmm0
;     movss       xmm0, [zero_v]
;     calc_dot_loop:
;         vmovaps     ymm1, [mat1 + rsi * 4]
;         vmovaps     ymm2, [mat2 + rdi * 4]
;         vdpps       ymm1, ymm1, ymm2, 0xF1
;         vperm2f128  ymm2, ymm1, ymm1, 0x01
;         addss       xmm1, xmm2
;         addss       xmm0, xmm1
;         add         rsi, 8
;         add         rdi, 8
;         loop        calc_dot_loop
;     sub         rsi, 8
;     sub         rdi, 8
; %endmacro

%macro mat_dot 0 ; takes rax as the index to top left location of mat1 matrix to be dotproducted with mat2 matrix and puts result in xmm0

    vmovss      xmm0 , [zero_v]
    xor         rsi, rsi ; rsi : (k , l) = k * 0x0400 + l
    ; rax : (i , j) = i * 0x0400 + j => rsi + rax = 0x0400 * (i+k) + j+l : (i+k , j+l)
    mov         r10, qword[m]
    k:
        mov     rcx, qword[m]
        lv:
            movss       xmm1 , [mat2 + rsi]; mat2[k][l] ; rsi = k * 0x0400 + l
            mulss       xmm1 , [mat1 + rsi + rax]; mat1[i+k][j+l]
            addss       xmm0 , xmm1
            add         si , 4
            loop        lv

        sub         si, 4
        and         si, 0xF000
        add         rsi,0x1000

        dec         r10
        jnz         k

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
            movss       [mat1 + rsi * 4], xmm0
            inc         rsi
            loop        MAT1_j
        dec         rsi
        and         si,  0xFC00
        add         rsi, 0x0400
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
            movss       [mat2 + rsi * 4], xmm0
            inc         rsi
            loop        MAT2_j
        dec         rsi
        and         si,  0xFC00
        add         rsi, 0x0400
        mov         rcx, rbx
        loop        MAT2_i

    xor         rax, rax ; rax : (i , j)
    mov         r8, qword[r]
    i:
        ;
        mov         r9, qword[r]
        j:

            mat_dot

            movss       [mat3 + rax] , xmm0 ; mat3[i][j]
            add         ax, 4

            dec         r9
            jnz         j

        sub         ax, 4
        and         ax, 0xF000
        add         rax,0x1000

        dec         r8
        jnz         i

    


    ;; FAST NORMAL PRINT
    ; mov         rax, qword[r]
    ; call        asm_write_uint
    ; mov         rax, 10
    ; call        asm_write_char
    mov         rcx, qword[r]
    xor         rsi, rsi
    PRINT_i: ; rbx
        mov         rbx, rcx
        mov         rcx, qword[r]
        PRINT_j: ; rcx
            movss       xmm0, [mat3 + rsi * 4]
            asm_write_float
            mov         rax, ' '
            call        asm_write_char
            inc         rsi
            loop        PRINT_j
        dec         rsi
        and         si,  0xFC00
        add         rsi, 0x0400
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
    dd 0x100000 DUP(0.0)
mat2:
    dd 0x100000 DUP(0.0)
mat3:
    dd 0x100000 DUP(0.0)
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
