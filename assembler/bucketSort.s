.data
newline:            .asciiz "\n"

.text
                    .globl  main

main:
    ori $t0 $zero 1
    j exit

    li      $s0,                    9                                   # s0 = p
    li      $s6,                    100                                 # s6 = n
    # Allocate space on stack for 9 floats (9 * 4 bytes = 36 bytes)
    addi    $sp,                    $sp,        -36                     # move stack pointer down

    # Load float constants into FPU registers and store them to stack
    li.s    $f0,                    0.1
    s.s     $f0,                    0($sp)

    li.s    $f0,                    0.1
    s.s     $f0,                    4($sp)

    li.s    $f0,                    0.8
    s.s     $f0,                    8($sp)

    li.s    $f0,                    0.3
    s.s     $f0,                    12($sp)

    li.s    $f0,                    0.5
    s.s     $f0,                    16($sp)

    li.s    $f0,                    0.69
    s.s     $f0,                    20($sp)

    li.s    $f0,                    0.42
    s.s     $f0,                    24($sp)

    li.s    $f0,                    0.7
    s.s     $f0,                    28($sp)

    li.s    $f0,                    0.99
    s.s     $f0,                    32($sp)

    move    $s2,                    $sp                                 # s2 = address of your float array in stack
    
make_buckets:
    # make n buckets

    mul     $t0,                    $s6,        4                       # t0 = n*4
    sub     $sp,                    $sp,        $t0                     # sp -= n*4
    move    $s3,                    $sp                                 # s3 = adr of start of bucket sizes

start_loop_buckets:                                                     # sp = start of value array, s0 = p, s1 = adr(n), s2 = adr(array)
    li      $t0,                    0                                   # t0 = iterator

loop_buckets:
    # run p times

    beq     $t0,                    $s0,        fill_buckets_start      # end loop

    # calculate n * array[i]
    mul     $t1,                    $t0,        4                       # t1 = i*4
    move    $t2,                    $s2                                 # t2 = adr(array)
    add     $t2,                    $t2,        $t1                     # t2 = adr(array[i])
    mtc1    $s6,                    $f1                                 # f1 = n(int)
    cvt.s.w $f1,                    $f1                                 # f1 = n(float)
    l.s     $f2,                    0($t2)                              # f2 = array[i]
    mul.s   $f2,                    $f2,        $f1                     # f2 = n * array[i]
    floor.w.s$f3,                   $f2                                 # f3 = floor(n*array[i])
    mfc1    $t3,                    $f3                                 # t3 = n*array[i]

    mul     $t3,                    $t3,        4                       # t3 = n*array[i]*4
    add     $t3,                    $sp,        $t3                     # t3 = adr(bucket(array[i]*n))
    lw      $t4,                    0($t3)                              # t4 = bucket(array[i]*n)
    addi    $t4,                    $t4,        1                       # t4++
    sw      $t4,                    0($t3)                              # save t4

    addi    $t0,                    $t0,        1                       #i++
    j       loop_buckets

fill_buckets_start:
    mul     $t0,                    $s0,        4                       # t0 = p*4
    sub     $sp,                    $s3,        $t0                     # so = adr of start of sorted array in buckets
    move    $s4,                    $sp                                 # s4 = adr of start of sorted array in buckets
    move    $t0,                    $s4                                 # t0 = adr of start of sorted array in buckets
    move    $t1,                    $s3                                 # t1 = adr of start of size buckets
    move    $t3,                    $s6                                 # t3 = n
    mul     $t3,                    $t3,        4                       # t3 = n*4
    sub     $sp,                    $s4,        $t3                     # sp = start of array of addresses
    move    $s5,                    $sp                                 # s5 = start of array of addresses
    move    $t2,                    $s5                                 # t2 = adr of start of array of addresses

fill_buckets_loop:                                                      # t0 = adr of start of sorted array in buckets, t1 = adr of start of size buckets, t2 = adr of start of array of addresses
    beq     $t0,                    $s3,        write_in_buckets_start  # end loop
    lw      $t3,                    0($t1)                              # t3 = size of bucket i
    sw      $t0,                    0($t2)                              # save t0
    addi    $t1,                    $t1,        4                       # t1+=4
    addi    $t2,                    $t2,        4                       # t2+=4
    mul     $t3,                    $t3,        4                       # t3 = size of bucket i * 4
    add     $t0,                    $t0,        $t3                     # t0 += size of bucket i * 4
    j       fill_buckets_loop

write_in_buckets_start:
    li      $t0,                    0                                   # t0 = iterator

write_in_buckets_loop:
    beq     $t0,                    $s0,        sort_start              # end loop

    mul     $t1,                    $t0,        4                       # t1 = i*4
    move    $t2,                    $s2                                 # t2 = adr(array)
    add     $t2,                    $t2,        $t1                     # t2 = adr(array[i])
    mtc1    $s6,                    $f1                                 # f1 = n(int)
    cvt.s.w $f1,                    $f1                                 # f1 = n(float)
    l.s     $f2,                    0($t2)                              # f2 = array[i]
    mul.s   $f2,                    $f2,        $f1                     # f2 =  n * array[i]
    floor.w.s$f3,                   $f2                                 # f3 = floor(n*array[i])
    mfc1    $t3,                    $f3                                 # t3 = n*array[i]

    mul     $t3,                    $t3,        4                       # t3 = n* array[i] * 4
    add     $t3,                    $s5,        $t3                     # t3 = adr of adr
    lw      $t4,                    0($t3)                              # t4 = adr
    lw      $t2,                    0($t2)                              # t2 = array[i]
    sw      $t2,                    0($t4)                              # write array[i] to it's corresponding bucket
    addi    $t4,                    $t4,        4                       # increment the bucket's current address
    sw      $t4,                    0($t3)                              # overwrite the old bucket's address

    addi    $t0,                    $t0,        1

    j       write_in_buckets_loop

sort_start:
    li      $a0,                    0                                   # a0 = iterator
    move    $a1,                    $s5                                 # a1 = base adr of adr
    move    $a2,                    $s3                                 # a2 = base adr(size array)

sort:
    beq     $a0,                    $s6,        print_all               # end loop

    lw      $a3,                    0($a1)                              # a3 = adr
    lw      $s7,                    0($a2)                              # s7 = size
    addi    $a2,                    $a2,        4                       # a2+=4
    addi    $a1,                    $a1,        4                       # a1+=4
    mul     $t0,                    $s7,        4                       # size*4
    sub     $a3,                    $a3,        $t0                     # fix adr

    addi    $a0,                    $a0,        1                       # i++
    j       sorter

print_all:
    li      $t0,                    0                                   # t0 = iterator
    la      $a0,                    newline                             # printing newline
    move    $t1,                    $s4                                 # t1 = adr of start of sorted array in buckets

print_loop:
    beq     $t0,                    $s0,        exit                    # end loop

    li      $v0,                    2                                   # system call code for print_float
    l.s     $f12,                   0($t1)                              # f12 = array[i]
    syscall

    li      $v0,                    4                                   # system call code for print_string
    syscall


    addi    $t1,                    $t1,        4                       # increment the address
    addi    $t0,                    $t0,        1                       # i++
    j       print_loop

exit:
    li      $v0,                    10
    syscall



sorter:
    li      $t1,                    1                                   # i = 1
outer_loop:
    beq     $t1,                    $s7,        end_sort                # if i >= n, exit
    beq     $s7,                    $zero,      end_sort                # if i >= n, exit

    mul     $t2,                    $t1,        4                       # offset = i * 4
    add     $t3,                    $a3,        $t2                     # address of array[i]
    l.s     $f0,                    0($t3)                              # key = array[i]

    add     $t4,                    $t1,        $zero                   # j = i
inner_loop:
    beq     $t4,                    $zero,      insert_key              # if j == 0, insert key

    mul     $t5,                    $t4,        4
    sub     $t5,                    $t5,        4                       # offset of array[j-1]
    add     $t6,                    $a3,        $t5
    l.s     $f1,                    0($t6)                              # f1 = array[j-1]

    c.lt.s  $f0,                    $f1                                 # if key < array[j-1]
    bc1f    insert_key                                                  # if not, break

    # array[j] = array[j-1]
    mul     $t7,                    $t4,        4                       # offset of array[j]
    add     $t8,                    $a3,        $t7
    s.s     $f1,                    0($t8)

    sub     $t4,                    $t4,        1                       # j--

    j       inner_loop

insert_key:
    mul     $t9,                    $t4,        4
    add     $t9,                    $a3,        $t9
    s.s     $f0,                    0($t9)                              # array[j] = key

    addi    $t1,                    $t1,        1                       # i++
    j       outer_loop

end_sort:
    j       sort
