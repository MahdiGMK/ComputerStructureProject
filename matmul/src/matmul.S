; Course : Computer Structure Architecture
; Instructor : Dr Jahangir
; Student : Mahdi Bahramian -- 401171593
;
; MatMul - ikj iteration algorithm simd
; Usage Instruction : 
; Compile and run program to executable using the following command
; nasm -felf64 matmul.S -o matmul.o && gcc main.c matmul.o -o exec && ./exec
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

MATSIZE : equ 0x40000
ZEROJ   : equ 0xFE00
NEXTI   : equ 0x0200

section .text


asm_main:
    xor         rax, rax ; در این چند خط stack را مضرب ۱۶ میکنیم چون صدا زدن توابع c به این شرط نیاز دارد
    mov         al , spl
    sub         rsp, rax ; در واقع داریم بایت اخر rsp را ۰ میکنیم که در نتیجه rsp مضرب ۲۵۶ میشود
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
    xor         rsi, rsi ; rsi : (i , j)
    MAT1_i: ; rbx
        mov         rcx, qword[n]
        MAT1_j: ; rcx
            asm_read_float ; read float from stdin to xmm0
            movss       [mat1 + rsi * 4], xmm0 ; mov xmm0 to mat1[i][j]
            inc         rsi 
            loop        MAT1_j
        dec         rsi
        and         si,  ZEROJ
        add         rsi, NEXTI
        dec         rbx
        jnz         MAT1_i
    
    ;; INPUT MAT2
    mov         rbx, qword[n]
    xor         rsi, rsi
    MAT2_i: ; rbx
        mov         rcx, qword[n]
        MAT2_j: ; rcx
            asm_read_float ; read float from stdin to xmm0
            movss       [mat2 + rsi * 4], xmm0 ; mov xmm0 to mat2[i][j]
            inc         rsi ; increment j in rsi
            loop        MAT2_j
        dec         rsi
        and         si,  ZEROJ ; zero j in rsi
        add         rsi, NEXTI ; increment i in rsi
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
            vbroadcastss    ymm0, [mat1 + rsi * 4]; load mat1[i][k] into all floats of ymm0
            inc         si
            mov         rcx, qword[nv]
            vmovaps         ymm2, [mat2 + rdi * 4]; load first mat2 cells(mat2[k][0],mat2[k][1],...,mat2[k][7])
            vmovaps         ymm3, [mat3 + rdx * 4]; load first mat3 cells(mat3[i][0],mat3[i][1],...,mat3[i][7])
            j:
                vmulps      ymm1, ymm0 , ymm2; ymm2 := mat1[i][k] * mat2[k][j+0...j+7]
                vmovaps     ymm2, [mat2 + rdi * 4 + 32]; load next set of mat2 cells
                vaddps      ymm1, ymm3 ; ymm2 := mat3[i][j+0...j+7] + mat1[i][k] * mat2[k][j+0...j+7]
                vmovaps     ymm3, [mat3 + rdx * 4 + 32]; load next set of mat3 cells
                vmovaps     [mat3 + rdx * 4], ymm1 ; rdx = i * 0x0200 + j
                add         di, 8
                add         dx, 8
                loop        j
                
            sub         dx, 8
            and         dx, ZEROJ

            sub         di, 8
            and         di, ZEROJ
            add         rdi,NEXTI
            dec         r8
            jg          k
        dec         si
        and         si, ZEROJ
        add         rsi,NEXTI
        add         rdx,NEXTI
        dec         r9
        jg          i

    ;; FAST NORMAL PRINT
    mov         rbx, qword[n]
    xor         rsi, rsi ; rsi = (i , j)
    PRINT_i: ; rbx
        mov         rcx, qword[n]
        PRINT_j: ; rcx
            movss       xmm0, [mat3 + rsi * 4] ; load mat3[i][j] to xmm0
            asm_write_float ; then print xmm0 (print mat3[i][j])
            mov         rax, ' '
            asm_write_char ; print space char
            inc         rsi
            loop        PRINT_j
        dec         rsi
        and         si,  ZEROJ ; zero j in rsi
        add         rsi, NEXTI ; increment i in rsi
        mov         rax, 10 
        asm_write_char ; print \n char
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
nv: dq 0

section .rodata
input_dim_message: db "input dim of matrix (0 <= n <= 512) : "  , 0
wrong_dim_error: db "input a valid n (0 <= n <= 512)" , 10 , 0
