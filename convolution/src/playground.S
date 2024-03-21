global asm_main
%include "src/asm_io.S"

section .text

calc_dot: ;calculate [rsi] dot [rdi] as vector size : rcx*8 return xmm0
    movss       xmm0, [zero]
    calc_dot_loop:
        vmovaps     ymm1, [rsi]
        vmovaps     ymm2, [rdi]
        vdpps       ymm1, ymm1, ymm2, 0xF1
        vperm2f128  ymm2, ymm1, ymm1, 0x01
        addss       xmm1, xmm2
        addss       xmm0, xmm1
        add         rsi, 0x20
        add         rdi, 0x20
        loop        calc_dot_loop

    ret
    
    

asm_main:
    xor         rax, rax
    mov         al , spl
    sub         rsp, rax
    ;stack_align


    mov         cx, 5
    sub         cx, 8
    js          asm_main
    
    MAT3_i:
    

    End:
    call        flush
    mov         rax, 60
    xor         rdi, rdi
    syscall
asdad
section .data align=64
vec1: 
    dd 1.0 , 2.0 , 3.0 , 4.0 , 5.0 , 6.0 , 7.0 , 8.0
vec2: 
    dd 1.0 , 2.0 , 3.0 , 4.0 , 5.0 , 6.0 , 7.0 , 8.0
vec3: 
    dd 1.0 , 2.0 , 3.0 , 4.0 , 5.0 , 6.0 , 7.0 , 8.0
zero: 
    dd 0.0
one_v:
    dd 8 DUP(1.0)
n: dq 0

section .rodata
input_dim_message: db "input dim of matrix (0 <= n <= 512) : "  , 0
wrong_dim_error: db "input a valid n (0 <= n <= 512)" , 10 , 0
f1: dd 123.23
f2: dd 0.0

