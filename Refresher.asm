# Notes on the code
# $a0, takes a label, not a literal string object
# use move when copying integer to register $a
# asciiz: null terminated string, which $v0 = 4, expects in syscall
# no semicolumns
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
stage1label: .asciiz "Stage 1 inner loop------------\n"
stage2label: .asciiz "Stage 2 basic condition------------\n"
stage3label: .asciiz "Stage 3 multiple condition AND------------\n"
stage4label: .asciiz "Stage 4 multiple condition OR------------\n"
stage5label: .asciiz "Stage 5 nested condition------------\n"
stage6Label: .asciiz "Stage 6 Array and Stack pointer Memory...\n"
stage7label: .asciiz "Stage 7 loop2------------\n"
stage8label: .asciiz "Stage 8 procedure call, jr and jal------------\n"
stage9label: .asciiz "Stage 9 saving and restoring callee registers state Including $ra and $sX registers------------\n"
stage10label: .asciiz "Stage 10 bitwise operations------------\n"

# stage 1 labels:
stage1Inner1: .asciiz "pass j instruction (fail)"
stage1Inner2: .asciiz "current a: "
stage1Inner3: .asciiz "a reached b Equal: "
stage1Inner4: .asciiz "Exit loop...\n"

# stage 2 labels:
stage2Inner1: .asciiz "a not less than b\nc = 0\n"
stage2Inner2: .asciiz "a less than b\nc = 1\n"

# stage 3 labels:
stage3Inner1: .asciiz "a > 0\n"
stage3Inner2: .asciiz "b > 0\n c = 1"
stage3Inner3: .asciiz "a and b <= 0\n c = 0"

# stage 4 labels:
stage4Inner1: .asciiz "at least one is greater than zero, condition true\n c = 0"
stage4Inner2: .asciiz "neither a or b are greater than zero\n c = 0"

# stage 5 labels:
stage5Inner1: .asciiz "a > 0 and b > 10\nc = 1\n"
stage5Inner2: .asciiz "either a <= 0, or b <= 10\n c = 0"

# stage 6 labels:
stage6Inner1: .asciiz "Retrieved Values\n"

# stage 10 data
byte_value: .byte 250
.align 1
half_value: .half 60000
.align 2
word_value: .word 100000

.data
byte_destination: .space 1
.align 1
half_destination: .space 2
.align 2
word_destination: .space 4

.text
#===========================
# Stage-0 Start messages
#===========================
    li $v0, 4
    la $a0, separator
    syscall
    la $a0, start
    syscall    
    la $a0, separator
    syscall
    la $a0, new_line
    syscall 
    j stage1

    la $a0, stage1Inner1
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
            la $a0, stage1Inner2
            syscall
            li $v0, 1
            move $a0, $t0            
            syscall

            beq $t0, $t1, exit_loop
            addi $t0, $t0, 1
            j inner

        exit_loop:
            li $v0, 4
            la $a0, stage1Inner3
            syscall
            li $v0, 1
            move $a0, $t0
            syscall

            li $v0, 4
            la $a0, stage1Inner4
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
    li $t1, 11

    # if first condition if false, then all is false end if
    ble $t0, 0, endIF3
    ble $t1, 10, endIF3
    # body since both passed
    li $t2, 1
    li $v0, 4
    la $a0, stage5Inner1
    syscall
    j stage6


    endIF3:
        li $t2, 0
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

    # this instruction is where the return address in $ra stored by jal points to
    # when jr $ra instruction is exeuted the cpu then executed this instruction
    # thats the only difference between j and jal, the return address
    # hence it can be used with recursion so each call returns to the very previous call
    # and we need to allocate memory to store all those return addresses
    # since $ra is just one register used once at a time
    move $a0, $v0
    li $v0, 1
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
    j stage10

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

stage10:
    li $v0, 4
    la $a0, separator
    syscall
    la $a0, stage10label
    syscall
    la $a0, separator
    syscall

    # and, or, xor, nor, ori(ors with an immediate instead of register I-type)

    li $t0, 6 # 110
    li $t1, 1 # 001

    and $t2, $t0, $t1 
    li $v0, 1
    move $a0, $t2    
    syscall # 0    
    
    li $v0, 4
    la $a0, new_line
    syscall

    li $t0, 7 # 111
    li $t1, 1 # 001

    and $t2, $t0, $t1 
    li $v0, 1
    move $a0, $t2    
    syscall # 1
        
    li $v0, 4
    la $a0, new_line
    syscall

    li $t0, 5 # 101
    li $t1, 5 # 101

    and $t2, $t0, $t1 
    li $v0, 1
    move $a0, $t2    
    syscall # 101 > 5
        
    li $v0, 4
    la $a0, new_line
    syscall

    li $t0, 2 # 010
    li $t1, 4 # 100

    and $t2, $t0, $t1 
    li $v0, 1
    move $a0, $t2    
    syscall # 0
        
    li $v0, 4
    la $a0, new_line
    syscall

    li $t0, 7 # 111
    li $t1, 7 # 111

    and $t2, $t0, $t1 
    li $v0, 1
    move $a0, $t2    
    syscall # 111 > 7
        
    li $v0, 4
    la $a0, new_line
    syscall    
    
    li $v0, 4
    la $a0, new_line
    syscall

    # shifting
    # sll, srl, sra (shit left logical, shift right logical, shift right arithmetic)
    # mips stored numbers in 16 bit, anymore and shifting will drop bits

    # shift left
    # shift left by 1 = multiplying by 2
    # by 2 = by 4
    # by 3 = by 8
    li $t0, 7 # 111
    sll $t2, $t0, 1 # shift left by 1, store in $t2
    li $v0, 1
    move $a0, $t2    
    syscall # 111 > 1110 = 14 > 7*2
    
    li $v0, 4
    la $a0, new_line
    syscall

    sll $t2, $t0, 2 # shift left by 1, store in $t2
    li $v0, 1
    move $a0, $t2    
    syscall # 11100 = 28 > 7*4
    
    li $v0, 4
    la $a0, new_line
    syscall

    sll $t2, $t0, 3 # shift left by 1, store in $t2
    li $v0, 1
    move $a0, $t2    
    syscall # 111000 = 56 > 7*8
    
    li $v0, 4
    la $a0, new_line
    syscall    
    syscall

    # shift right
    # shift right by 1 = dividing by 2
    # by 2 = by 4
    # by 3 = by 8
    li $t0, 16 # 10000 (16, 8, 4, 2, 1)
    srl $t2, $t0, 1 # shift right by 1, store in $t2
    li $v0, 1
    move $a0, $t2    
    syscall # 10000 > 1000 = 16 /2 = 8
    
    li $v0, 4
    la $a0, new_line
    syscall

    srl $t2, $t0, 2 # shift right by 2, store in $t2
    li $v0, 1
    move $a0, $t2    
    syscall # 100 > 16 /4 = 4
    
    li $v0, 4
    la $a0, new_line
    syscall

    srl $t2, $t0, 3 # shift right by 3, store in $t2
    li $v0, 1
    move $a0, $t2    
    syscall # 10 > 16 /8 = 2    

    li $v0, 4
    la $a0, new_line
    syscall

    srl $t2, $t0, 4 # shift right by 4, store in $t2
    li $v0, 1
    move $a0, $t2    
    syscall # 1 > 16 /16 = 1

    li $v0, 4
    la $a0, new_line
    syscall

    srl $t2, $t0, 5 # shift right by 5, store in $t2
    li $v0, 1
    move $a0, $t2    
    syscall # 0 > 16 / 16*2(32) = 0
    
    li $v0, 4
    la $a0, new_line
    syscall
    # answer should be, 14, 28, 56. True
    # answer should be, 8, 4, 2, 1, 0  false, 8 4 2 2 2, why not 1, 0

    # sra
    # shift right arithmetic
    # others sll, and arl fills zero on the right and fills zero on the left respectivly
    # sra: replicates the sign bit on the left

    # how it handles signed negative numbers
    # 0 positive
    # 1 negative

    # for positive numbers
    # srl and sra produce the same output
    # since sra replicates the sign bit which is zero
    # and srl fills with zero too on the left
    li $t0, 16
    sra $t1, $t0, 2 # shift right arithmetic by 2, store in t1

    # for negative numbers
    # srl will fill zeros
    # sra will replicate the sign bit which is 1 then
    # so for example
    li $t0, -16
    srl $t1, $t0, 2 # 1073741820
    sra $t2, $t0, 2 # -4 , 

    # load and store
    # lb, lbu, lh, lhu, lw, sb, sh, sw
    # l: copies data from memory into a register
    # s: copy data from register into memory
    # General syntax:
    # lw $t0, offset($t1)
    # sw $t0, offset($t1)

    lb  $t0, byte_value # load the byte byte_value into t0, t0 = -6 (signed)
    lbu $t1, byte_value # load byte (unsigned) 250

    lh  $t2, half_value # -5536
    lhu $t3, half_value # 60000

    lw  $t4, word_value # 100000

    # explanation: load, lb, lbu
    # 250 in binary: 11111010
    # lb: treats the leftmost bit as sign bit, and extend with it filling 32 bit
    # this then represents -6
    # 11111111 11111111 11111111 11111010

    # lbu: extends with zero instead, always positive, so the value treated as unsigned integer
    # no 2's complement conversion
    # 00000000 00000000 00000000 11111010

    # explanation: store, sb, sh, sw
    # sb: 1 byte
    # sh: 2 byte halfword = 32/2 = 16 2bytes
    # sw: 4 byte

    li $t0, 100
    li $t1, 1000
    li $t2, 100000

    sb $t0, byte_destination # loads lower 8 bits of t0 into byte destination
    sh $t1, half_destination # lower 16 bits into half
    sw $t2, word_destination # all 32 bits of t2 into word_destination
    # sb: stores the lower 8 bits
    # sh: stores the lower 16 bits
    # sw: stores all 32 bits

    # register conventions
    # $a > arguments to syscall or procedure registers depending on context
    # $t > temp used by caller to store values to be modified, not important to save and restore old values
    # v > selects the syscall service and procedure return value.
    # $s > must save and restore its value, used by callee so its known that its value won't be changed
    # $sp, stack pointer, allocates memory on the stack
    # $ra, return address pointer, saved into it the address of the next instruction to be executed after the called function terminates

    j EXIT

EXIT:
    li $v0, 4
    la $t4, exiting
    move $a0, $t4
    syscall

	li $v0, 10
	syscall