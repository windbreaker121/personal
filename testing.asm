# Notes on the code
# $a0, takes a label, not a literal string object
# use move when copying integer to register $a
# 
# 
# 
# 
.data
# Starting labels
end: .asciiz "Finished Trial...\n"
start: .asciiz "Starting Trial...\n"
exiting: .asciiz "exiting\n"
new_line: .asciiz "\n"
separator: .asciiz "================\n"

# Stages Labels
stage1label: .ascii "Stage 1 inner loop------------\n"
stage2label: .ascii "Stage 2 basic condition------------\n"
stage3label: .ascii "Stage 3 multiple condition AND------------\n"
stage4label: .ascii "Stage 4 multiple condition OR------------\n"
stage5label: .ascii "Stage 5 nested condition------------\n"
stage6Label: .asciiz "Stage 6 Array and Stack pointer Memory...\n"
stage7label: .ascii "Stage 7 loop2------------\n"
stage8label: .ascii "Stage 8 procedure call, jr and jal------------\n"
stage9label: .ascii "Stage 9 saving and restoring callee registers state Including $ra and $sX registers------------\n"

# stage 1 labels:
stage0Inner1: .ascii "pass j instruction (fail)"
stage1Inner1: .ascii "current a: "
stage1Inner2: .ascii "a reached b Equal: "
stage1Inner3: .ascii "Exit loop...\n"

# stage 2 labels:
stage2Inner1: .ascii "a not less than b\nc = 0\n"
stage2Inner2: .ascii "a less than b\nc = 1\n"

# stage 3 labels:
stage3Inner1: .ascii "a > 0\n"
stage3Inner2: .ascii "b > 0\n c = 1"
stage3Inner3: .ascii "a and b <= 0\n c = 0"

# stage 4 labels:
stage4Inner1: .ascii "at least one is greater than zero, condition true\n c = 0"
stage4Inner2: .ascii "neither a or b are greater than zero\n c = 0"

# stage 5 labels:
stage5Inner1: .ascii "neither a or b are greater than zero\n c = 0"
stage5Inner2: .ascii "either a <= 0, or b <= 10\n c = 0"

# stage 6 labels:
stage6Inner1: .ascii "Retrieved Values\n"


.text
#===========================
# Stage-0 Start messages
#===========================
    li $v0, 4
    la $a0, separator;
    syscall
    la $a0, start;
    syscall    
    la $a0, separator;
    syscall
    la $a0, new_line;
    syscall 
    j stage1

    la $a0, stage1Inner1;
    syscall 

#===========================
# Stage-1 Loop and condition
#===========================
# beq, bne, blt, bgt, ble, bge
stage1:
    li $v0, 4
    la $a0, separator
    syscall
    la $a0, stage1label
    syscall
    la $a0, separator
    syscall

    li $t0, 1 # a
    li $t1, 10 # b
    j inner

        inner:
            li $v0, 4
            la $a0, stage1Inner1
            syscall
            li $v0, 1
            move $a0, $t0            
            syscall

            beq $t0, $t1, exit_loop
            addi $t0, $t0, 1
            j inner;

        exit_loop:
            li $v0, 4
            la $a0, stage0Inner2
            syscall
            li $v0, 1
            move $a0, $t0
            syscall

            li $v0, 4
            la $a0, stage0Inner3
            syscall
            j stage2

#===========================
# Stage-2
#===========================
stage2:
    li $v0, 4
    la $a0, separator
    syscall
    la $a0, stage2label
    syscall
    la $a0, separator
    syscall


    # if with else
    li $t0, 10
    li $t1, 20
    li $t2, 100
    j if

    if:
        blt $t0, $t1, else
        li $t2, 0
        li $v0, 4
        la $a0, stage2Inner1
        syscall
        j stage3

    else:
        li $t2, 1
        li $v0, 4
        la $a0, stage2Inner2
        syscall
        j stage3

#===========================
# Stage-3
#===========================
stage3:
# multiple condition
# if a > 0 and b > 0, do something
# in and condition, if at least one if false then all is false
    li $v0, 4
    la $a0, separator
    syscall
    la $a0, stage3label
    syscall
    la $a0, separator
    syscall

    li $t0, 1
    li $t1, 2

    # if even one is less or equal zero (false) break and go to end if
    ble $t0, $zero, endIf
    li $v0, 4
    la $a0, stage3Inner1
    syscall

    ble $t1, $zero, endIf
    li $t2, 1

    li $v0, 4
    la $a0, stage3Inner2
    syscall

    j stage4
    # reaching here means both are true

    endIf:
        li $t2, 0
        li $v0, 4
        la $a0, stage3Inner3
        syscall

        j stage4

#===========================
# Stage-4
#===========================
stage4:
# if a > 0 or b > 0
# put the actual condition
# not reversed
# if atleast one is true, go to body directly
# if body not executed then both are false
# end
    li $v0, 4
    la $a0, separator
    syscall
    la $a0, stage4label
    syscall
    la $a0, separator
    syscall

    bgt $t0, $zero, body # if true go directly without checking the next
    bgt $t1, $zero, body 

    j endIF2

    body:
        li $t2, 1
        li $v0, 4
        la $a0, stage4Inner1
        syscall
        j stage5

    endIF2:
        li $t2, 0
        li $v0, 4
        la $a0, stage4Inner2
        syscall
        j stage5

#===========================
# Stage-5
#===========================
stage5:
# nested condition
# as if and, both must be true to execute body
# if a > 0, if b > 10
    li $v0, 4
    la $a0, separator
    syscall
    la $a0, stage5label
    syscall
    la $a0, separator
    syscall
    li $t0, 2
    li $t1, 4

    # if first condition if false, then all is false end if
    ble $t0, 0, endIF3
    ble $t1, 10, endIF3
    # body since both passed
    li $v0, 4
    la $a0, stage5Inner1
    syscall
    j stage6


    endIF3:
    li $v0, 4
        la $a0, stage5Inner2
        syscall
        j stage6

#===========================
# Stage-6
#===========================
stage6:
# Array and stack memory
    li $v0, 4
    la $a0, separator
    syscall
    la $a0, stage6Label
    syscall
    la $a0, separator
    syscall

    # allocate memory on the stack
    # the stack grows downward, towards lower memory addresses

    # allocate: subtract from $sp
    # free: add to $sp
    # allocate 20 bytes
    # stack memory
    # sp + 16 word 4
    # sp + 12 word 3
    # sp + 8 word 2
    # sp + 4 word 1
    # sp + 0 word 0

    # storing and accessing values
    # sw $t0, 0($sp) store  word in 0($sp), take value from $t0
    # lw $t0, 0($sp) load from x($sp) to $t0
    # sb $t0, 0($sp) store byte in sp
    # lb $t0, 0($sp) load signed byte
    # lbu $t0, 0($sp) load unsigned byte

    addi $sp, $sp, -20
    # store words
    # 1, 2, 3, 4, 5
    li $t0, 1
    sw $t0, 0($sp)

    addi $t0, $t0, 1
    sw $t0, 4($sp)

    addi $t0, $t0, 1
    sw $t0, 8($sp)

    addi $t0, $t0, 1
    sw $t0, 12($sp)

    addi $t0, $t0, 1
    sw $t0, 16($sp)

    # retrieve
    # and print

    li $v0, 4
    la $a0, stage6Inner1
    syscall
    la $a0, new_line
    syscall

    li $v0, 1
    lw $t0, 0($sp)
    move $a0, $t0
    syscall  
    
    li $v0, 4
    la $a0, new_line
    syscall  
    
    li $v0, 1
    lw $t0, 4($sp)
    move $a0, $t0    
    syscall  

    li $v0, 4
    la $a0, new_line
    syscall

    li $v0, 1
    lw $t0, 8($sp)
    move $a0, $t0    
    syscall    

    li $v0, 4
    la $a0, new_line
    syscall

    li $v0, 1
    lw $t0, 12($sp)
    move $a0, $t0    
    syscall    

    li $v0, 4
    la $a0, new_line
    syscall

    li $v0, 1
    lw $t0, 16($sp)
    move $a0, $t0
    syscall  

    li $v0, 4
    la $a0, new_line
    syscall

    # when finished
    addi $sp, $sp, 20

    j stage7

#===========================
# Stage-7
#===========================
stage7:
    li $v0, 4
    la $a0, separator
    syscall
    la $a0, stage7label
    syscall
    la $a0, separator
    syscall
    # access array in loop
    addi $sp, $sp, -20
    

    li $t0, 0 # i = 0
    j loop

    loop:
        bge $t0, 5, endLoop # from 0 to 4

        sll $t1, $t0, 2 # i*4. next element
        add $t2, $sp, $t1 # add i*4 to sp, next element similar to 0($sp)
        sw $zero, 0($t2) # array[i] = 0

        addi $t0, $t0, 1
        j loop

    endLoop:
        addi $sp, $sp, 20
        j stage8

# procedure calls
# j label: jumps to a label, no return address saved
# jal: jumps to procedure and saves return address in $ra 
# jr:  jumps to address stored in $ra

#===========================
# Stage-8
#===========================
stage8:
    li $v0, 4
    la $a0, separator
    syscall
    la $a0, stage8label
    syscall
    la $a0, separator
    syscall

    li $a0, 10
    li $a1, 20

    jal addNumbers

    li $v0, 1 # this instruction is where the return address in $ra stored by jal points to
    # when jr $ra instruction is exeuted the cpu then executed this instruction
    # thats the only difference between j and jal, the return address
    # hence it can be used with recursion so each call returns to the very previous call
    # and we need to allocate memory to store all those return addresses
    # since $ra is just one register used once at a time
    move $a0, $t4
    syscall

    j stage9 

addNumbers:
    add $v0, $a0, $a1 # v0 = 30
    jr $ra # jump to the return address stored by jal
    # the return address stored by jal represents the very next instruction
    # after it directly which then is j stage 8;
    # so the whole code can only have one return address stored in $ra at a time
    # which represnts the next instruction to be executed after function termination

#===========================
# Stage-9
#===========================
stage9:
    li $v0, 4
    la $a0, separator
    syscall
    la $a0, stage9label
    syscall
    la $a0, separator
    syscall

    # saving registers in procedure calls
    # save and restore
    jal my_procedure
    
    # continue here
    j EXIT

my_procedure:
    addi $sp, $sp, -8

    sw $ra, 4($sp) # store return address in second place array[1]
    sw $s0, 0($sp) # store s0 in array[0]

    # body, do operations normally using any register
    li $s0, 100 # overwrite s0, but we saved it already so no worries

    # finished, restore old values
    lw $ra, 4($sp)
    lw $s0, 0($sp)

    addi $sp, $sp, 8
    jr $ra

EXIT:
    li $v0, 4
    la $t4, exiting
    move $a0, $t4
    syscall

	li $v0, 10
	syscall