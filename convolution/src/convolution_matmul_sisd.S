; Course : Computer Structure Architecture
; Instructor : Dr Jahangir
; Student : Mahdi Bahramian -- 401171593
;
; Convolution - matrix multiplication sisd
; Usage Instruction : 
; Compile and run program to executable using the following command
; nasm -felf64 convolution_matmul_sisd.S -o convolution_matmul_sisd.o && gcc main.c convolution_matmul_sisd.o -o exec && ./exec
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

%macro matmul 0 ; calculate matrix cross product of A(x*y) and B(y*1) which will be C(x*1)

    ; normal matmul algo
    ;for i = 0..(n-m+1)2:
    ;    for k = 0..m2:
    ;       C[i][1] += A[i][k] * B[k][1]
    ; => the thing that is implemented
    ; what is implemented
    ;for i = 0..(n-m+1)2:
    ;   C[i] = 0;
    ;   for j = 0..m2:
    ;       C[i] += A[i][k] * B[k]
    ; psudo assembly
    ;for i = 0..(n-m+1)2:
    ;   xmm0 = 0
    ;   for j = 0..m2:
    ;       xmm1 = A[i][k]
    ;       xmm1 = xmm1 * B[k]
    ;       xmm0 += xmm1

    

    xor     rsi, rsi
    xor     rax, rax
    mov     rbx, qword[r2]
    matmul_i:
        xor     rdi, rdi
        mov     rcx, qword[m2]
        movss   xmm0, [zero_v]
        matmul_k:
            movss   xmm1, [Amat + rsi]
            mulss   xmm1, [Bmat + rdi]
            addss   xmm0, xmm1
            add     rsi, 4 ; rsi : (i , k)
            add     rdi, 4 ; rdi : (k)
            loop    matmul_k
        movss   [Cmat + rax * 4], xmm0
        sub     rsi, 4
        and     si, 0xF000
        add     rsi,0x1000
        inc     rax ; rax : (i)
        dec     rbx
        jnz     matmul_i

%endmacro

section .data align=64
Amat:
    dd 0x100000 DUP(0.0)
Bmat:
    dd 0x100000 DUP(0.0)
Cmat:
    dd 0x100000 DUP(0.0)
section .text

asm_main:
    xor         rax, rax
    mov         al , spl
    sub         rsp, rax
    ;stack_align

    ReadDIM:
    call        asm_read_uint
    mov         rbx, rax
    call        asm_read_uint
    
    cmp         rbx, 32
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
    
    mov         rdi, qword[m]
    imul        rdi, rdi
    mov         qword[m2], rdi
    mov         rdi, qword[r]
    imul        rdi, rdi
    mov         qword[r2], rdi
    

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
        and         sil, 0xE0
        add         rsi, 0x20
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
            movss       [Bmat + rsi * 4], xmm0
            inc         rsi
            loop        MAT2_j
        mov         rcx, rbx
        loop        MAT2_i

    ; make Amat :
    ;
    ; ai = 0 =>> r12
    ; for i: =>> r8
    ;   for j: =>> r9
    ;       aj = 0 =>> r13
    ;       for k: =>> r10
    ;           for l: =>> r11
    ;               Amat[ai][aj] = mat1[i + k][j + l]
    ;               aj++
    ;       ai++

    xor     r8, r8
    xor     r12, r12
    i: ; r8
        xor     r9, r9
        j: ; r9
            xor     r10, r10
            xor     r13, r13
            k: ; r10
                xor     r11, r11
                l: ; r11
                    mov     rax, r12
                    shl     rax, 10
                    or      rax, r13
                    ;; rax = (ai , aj)
                    mov     rbx, r8
                    add     rbx, r10
                    shl     rbx, 5
                    or      rbx, r9
                    add     rbx, r11
                    ;; rbx = (i+k , j+l)
                    movss   xmm0, [mat1 + rbx * 4]
                    movss   [Amat + rax * 4], xmm0

                    inc     r13
                    inc     r11
                    cmp     r11, qword[m]
                    jl      l
                inc     r10
                cmp     r10, qword[m]
                jl      k
            inc     r12
            inc     r9
            cmp     r9, qword[r]
            jl      j
        inc     r8
        cmp     r8, qword[r]
        jl      i



    matmul

    ; xor         rax, rax
    ; mov         r8, qword[r]
    ; i:
    ;     ;
    ;     mov         r9, qword[r]
    ;     j:
    ;         matdot
    ;         movss       [mat3 + rax] , xmm0 ; mat3[i][j] ; rax = i * 0x0200 + l
    ;         add         ax, 4
    ;
    ;         dec         r9
    ;         jnz         j
    ;
    ;     sub         ax, 4
    ;     and         ax, 0xF000
    ;     add         rax,0x1000
    ;
    ;     dec         r8
    ;     jnz         i

    


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
            movss       xmm0, [Cmat + rsi * 4]
            asm_write_float
            mov         rax, ' '
            call        asm_write_char
            inc         rsi
            loop        PRINT_j
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
r2: dq 0
m2: dq 0
mv: dq 0

section .rodata
wrong_dim_error: db "input a valid n,m (0 <= m <= n <= 32)" , 10 , 0
