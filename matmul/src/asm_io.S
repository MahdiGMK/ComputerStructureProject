; Course : Computer Structure Architecture
; Instructor : Dr Jahangir
; Student : Mahdi Bahramian -- 401171593
;
; ASM_IO Library
extern read_float
extern read_uint
extern write_float
extern write_char
extern write_uint
extern write_str
extern flush
extern printf
; 
; convention : rbx , rcx , rdx , rsi , rdi => reserve for main code , rax => operational

section .text
asm_read_uint: ; read rax as uint
    sub     rsp, 0x28
    mov     qword[rsp]          , rsi
    mov     qword[rsp + 0x8]    , rbx
    mov     qword[rsp + 0x10]   , rcx
    ; mov     qword[rsp + 0x18]   , rdx
    ; mov     qword[rsp + 0x20]   , rdi

    call    read_uint
    
    mov     rsi, qword[rsp]
    mov     rbx, qword[rsp + 0x8]
    mov     rcx, qword[rsp + 0x10]
    ; mov     rdx, qword[rsp + 0x18]
    ; mov     rdi, qword[rsp + 0x20]
    add     rsp, 0x28
    ret

%macro asm_read_float 0; read xmm0 as float
    sub     rsp, 0x20
    mov     qword[rsp]          , rsi
    mov     qword[rsp + 0x8]    , rbx
    mov     qword[rsp + 0x10]   , rcx

    call    read_float
    
    mov     rsi, qword[rsp]
    mov     rbx, qword[rsp + 0x8]
    mov     rcx, qword[rsp + 0x10]
    add     rsp, 0x20
%endmacro

%macro asm_write_float 0; write xmm0 as float
    sub     rsp, 0x20
    mov     qword[rsp]          , rsi
    mov     qword[rsp + 0x8]    , rbx
    mov     qword[rsp + 0x10]   , rcx

    call    write_float
    
    mov     rsi, qword[rsp]
    mov     rbx, qword[rsp + 0x8]
    mov     rcx, qword[rsp + 0x10]
    add     rsp, 0x20
%endmacro

%macro asm_write_char 0; write rax as char
    sub     rsp, 0x20
    mov     qword[rsp]          , rsi
    mov     qword[rsp + 0x8]    , rbx
    mov     qword[rsp + 0x10]   , rcx

    mov     rdi, rax
    call    write_char
    
    mov     rsi, qword[rsp]
    mov     rbx, qword[rsp + 0x8]
    mov     rcx, qword[rsp + 0x10]
    add     rsp, 0x20
%endmacro

asm_write_uint: ; write rax as uint
    sub     rsp, 0x28
    mov     qword[rsp]          , rsi
    mov     qword[rsp + 0x8]    , rbx
    mov     qword[rsp + 0x10]   , rcx

    mov     rdi, rax
    call    write_uint
    
    mov     rsi, qword[rsp]
    mov     rbx, qword[rsp + 0x8]
    mov     rcx, qword[rsp + 0x10]
    add     rsp, 0x28
    ret

asm_write_str: ; write rax as char*
    sub     rsp, 0x28
    mov     qword[rsp]          , rsi
    mov     qword[rsp + 0x8]    , rbx
    mov     qword[rsp + 0x10]   , rcx

    mov     rdi, rax
    call    write_str
    
    mov     rsi, qword[rsp]
    mov     rbx, qword[rsp + 0x8]
    mov     rcx, qword[rsp + 0x10]
    add     rsp, 0x28
    ret

asm_flush: ; flush stdout
    sub     rsp, 0x28
    mov     qword[rsp]          , rsi
    mov     qword[rsp + 0x8]    , rbx
    mov     qword[rsp + 0x10]   , rcx

    call    flush
    
    mov     rsi, qword[rsp]
    mov     rbx, qword[rsp + 0x8]
    mov     rcx, qword[rsp + 0x10]
    add     rsp, 0x28
    ret

section .rodata
floatFormat: db "%f" , 0
