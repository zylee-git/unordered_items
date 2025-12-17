.data
    C: .space 120
    buffer: .space 332
    in_file: .asciiz "exp2-1.input"
    out_file: .asciiz "exp2-1.out"

.text
    la $a0, in_file
    li $a1, 0
    li $a2, 0
    li $v0, 13
    syscall
    move $a0, $v0
    la $a1, buffer
    li $a2, 332
    li $v0, 14
    syscall
    li $v0, 16
    syscall
    
    jal sparse_matmul
    
    move $s0, $v0
    la $a0, out_file
    li $a1, 1
    li $a2, 0
    li $v0, 13
    syscall
    move $a0, $v0
    la $a1, C
    sll $a2, $s0, 2
    li $v0, 15
    syscall
    li $v0, 16
    syscall
    li $a0, 0
    li $v0, 17
    syscall

sparse_matmul:
    la $t0, buffer
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
la $t3,C
move $t1,$zero
mul $t2,$s0,$s2
#初始化C矩阵为全零
initial_loop:
beq $t1,$t2,count_outloop
sw $zero,0($t3)
addi $t3,$t3,4
addi $t1,$t1,1
move $t0,$zero  #第一层循环变量
j initial_loop

count_outloop:
beq $t0,$s0,exit
sll $t1, $t0, 2     # 计算偏移量：i * 4（每个元素占4字节）
add $t1, $s6, $t1    # row_ptr的地址：$s6（基地址） + i*4
lw $t2, 0($t1)       # $t2 = row_ptr[i]（即start）
lw $t3, 4($t1)       # $t3 = row_ptr[i+1]（即end）

move $t4,$t2         #第二层循环变量
count_inloop1:
beq $t4,$t3,end_loop1
sll $t5,$t4,2
add $t5,$s5,$t5      
lw $t6,0($t5)        #t6为k
sll $t5,$t4,2
add $t5,$s4,$t5      
lw $t7,0($t5)        #t7为val

move $t8,$zero       #第三层循环变量
count_inloop2:
beq $t8,$s2,end_loop2
    # 计算C[i*p + l] 的地址
    mul $t9, $t0, $s2    # i*p
    add $t9, $t9, $t8    # i*p + l
    sll $t9, $t9, 2      # 转换为字节偏移
    la $a0, C            # C的基地址
    add $a0, $a0, $t9    # C[i*p + l]的地址

    # 计算B[k*p + l] 的值
    mul $a1, $t6, $s2    # k*p
    add $a1, $a1, $t8    # k*p + l
    sll $a1, $a1, 2      # 转换为字节偏移
    add $a1, $s7, $a1    # B[k*p + l]的地址
    lw $a2, 0($a1)       # $a2 = B[k*p + l]

    # 计算 val * B[k*p + l] 并累加到C[i*p + l]
    lw $a3, 0($a0)       # 当前C[i*p + l]的值
    mul $v0, $t7, $a2    # val * B[k*p + l]
    add $a3, $a3, $v0    # C[i*p + l] += val * B[k*p + l]
    sw $a3, 0($a0)       # 写回内存

    addi $t8, $t8, 1     # l++
    j count_inloop2
end_loop2:

    addi $t4, $t4, 1     # j++
    j count_inloop1
end_loop1:

    addi $t0, $t0, 1     # i++
    j count_outloop
exit:

    # 返回结果矩阵元素数 m*p
    mul $v0, $s0, $s2
    jr $ra
