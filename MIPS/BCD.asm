.text
sparse_matmul:
    li $t0, 0x0
    lw $s0, 0($t0)  # $s0: m
    lw $s1, 4($t0)  # $s1: n
    lw $s2, 8($t0)  # $s2: p
    lw $s3, 12($t0) # $s3: s
    
    addi $s4, $t0, 16 # $s4: values
    
    sll $s5, $s3, 2 
    add $s5, $s5, $s4 # $s5: col_indices
    
    sll $s6, $s3, 3
    add $s6, $s6, $s4 # row_ptr
    
    addi $s7, $s0, 1
    sll $s7, $s7, 2
    add $s7, $s7, $s6 # $s7: B
    
    # TODO
li $t3,0x90
move $t1,$zero
mul $t2,$s0,$s2

initial_loop:
beq $t1,$t2,count_outloop
sw $zero,0($t3)
addi $t3,$t3,4
addi $t1,$t1,1
move $t0,$zero 
j initial_loop

count_outloop:
beq $t0,$s0,exit
sll $t1, $t0, 2  
add $t1, $s6, $t1  
lw $t2, 0($t1)       
lw $t3, 4($t1)

move $t4,$t2
count_inloop1:
beq $t4,$t3,end_loop1
sll $t5,$t4,2
add $t5,$s5,$t5      
lw $t6,0($t5)        #t6Ϊk
sll $t5,$t4,2
add $t5,$s4,$t5      
lw $t7,0($t5)        #t7Ϊval

move $t8,$zero
count_inloop2:
beq $t8,$s2,end_loop2
    mul $t9, $t0, $s2    # i*p
    add $t9, $t9, $t8    # i*p + l
    sll $t9, $t9, 2 
    li $a0, 0x90
    add $a0, $a0, $t9

    mul $a1, $t6, $s2    # k*p
    add $a1, $a1, $t8    # k*p + l
    sll $a1, $a1, 2
    add $a1, $s7, $a1
    lw $a2, 0($a1)       # $a2 = B[k*p + l]

    lw $a3, 0($a0)
    mul $v0, $t7, $a2    # val * B[k*p + l]
    add $a3, $a3, $v0    # C[i*p + l] += val * B[k*p + l]
    sw $a3, 0($a0)

    addi $t8, $t8, 1     # l++
    j count_inloop2
end_loop2:

    addi $t4, $t4, 1     # j++
    j count_inloop1
end_loop1:

    addi $t0, $t0, 1     # i++
    j count_outloop
exit:

    # return m*p
    mul $v0, $s0, $s2
    


mul $s0 $s0 $s2  # totally m * p elements
addi $s3 $s0 -1
li $t0 0  # displaying i-th element
li $s1 0x90  # source target(base addr of matrix C)
li $s2 0x40000010  # target address(addr of BCD)

display_loop:
	sll $t1 $t0 2  # offset
	add $t1 $t1 $s1  # addr of current elemnt
	lw $t2 0($t1)  # current element

	li $t1 0  # 1s loop variable
time_1s_loop:
	sll $t3 $t1 30
	beq $t3 0x00000000 an0
	beq $t3 0x40000000 an1
	beq $t3 0x80000000 an2
	beq $t3 0xc0000000 an3
	
an0:
	li $t4 0x0100
	sll $t5 $t2 16
	srl $t5 $t5 28
	j show

an1:
	li $t4 0x0200
	sll $t5 $t2 20
	srl $t5 $t5 28
	j show

an2:
	li $t4 0x0400
	sll $t5 $t2 24
	srl $t5 $t5 28
	j show

an3:
	li $t4 0x0800
	sll $t5 $t2 28
	srl $t5 $t5 28
	j show

# $t5 is to be shown
show:
	beq $t5 0x0 is0
	beq $t5 0x1 is1
	beq $t5 0x2 is2
	beq $t5 0x3 is3
	beq $t5 0x4 is4
	beq $t5 0x5 is5
	beq $t5 0x6 is6
	beq $t5 0x7 is7
	beq $t5 0x8 is8
	beq $t5 0x9 is9
	beq $t5 0xa isa
	beq $t5 0xb isb
	beq $t5 0xc isc
	beq $t5 0xd isd
	beq $t5 0xe ise
	beq $t5 0xf isf

is0:
	li $t5 0x3f  # 0b00111111
	j light

is1:
	li $t5 0x06  # 0b00000110
	j light

is2:
	li $t5 0x5b  # 0b01011011
	j light

is3:
	li $t5 0x4f  # 0b01001111
	j light
	
is4:
	li $t5 0x66  # 0b01100110
	j light
	
is5:
	li $t5 0x6d  # 0b01101101
	j light

is6:
	li $t5 0x7d  # 0b01111101
	j light

is7:
	li $t5 0x07  # 0b00000111
	j light

is8:
	li $t5 0x7f  # 0b01111111
	j light
	
is9:
	li $t5 0x6f  # 0b01101111
	j light
	
isa:
	li $t5 0x77  # 0b01110111
	j light

isb:
	li $t5 0x7c  # 0b01111100
	j light

isc:
	li $t5 0x39  # 0b00111001
	j light

isd:
	li $t5 0x5e  # 0b01011110
	j light
	
ise:
	li $t5 0x79  # 0b01111001
	j light

isf:
	li $t5 0x71  # 0b01110001
	j light
	
light:
	add $t6 $t5 $t4
	sw $t6 0($s2)

	li $t7 0  # delay variabke
show_delay:
	beq $t7 1000 delay_end
	addi $t7 $t7 1
	j show_delay

delay_end:
	beq $t1 19999 time_1s_end
	addi $t1 $t1 1
	j time_1s_loop

time_1s_end:
	beq $t0 $s3 display_over
	addi $t0 $t0 1  # i++
	j display_loop

display_over:
	li $v1 1

	li $t6 0x0100  # an = 0001 bcd = 0b00000000 -> _ _ _ _
	sw $t6 0($s2)

	li $t0 0

delay_1:
	beq $t0 1000 delay_1_end
	addi $t0 $t0 1
	j delay_1

delay_1_end:
	li $t6 0x0279  # an = 0010 bcd = 0b01111001 -> _ E _ _
	sw $t6 0($s2)

	li $t0 0

delay_2:
	beq $t0 1000 delay_2_end
	addi $t0 $t0 1
	j delay_2

delay_2_end:
	li $t6 0x0454  # an = 0100 bcd = 0b01010100 -> _ _ n _
	sw $t6 0($s2)

	li $t0 0

delay_3:
	beq $t0 1000 delay_3_end
	addi $t0 $t0 1
	j delay_3

delay_3_end:
	li $t6 0x085e  # an = 1000 bcd = 0b01011110 -> _ _ _ d
	sw $t6 0($s2)

	li $t0 0

delay_4:
	beq $t0 1000 display_over
	addi $t0 $t0 1
	j delay_4
