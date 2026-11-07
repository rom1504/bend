p113d_FID_36_112_49_55_51_115_99_99_46_48_:
	endbr64
	pushq %rbp
	movq %rsp, %rbp
	subq $376, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movq 48(%rbp), %rax
	movq 40(%rbp), %rbx
	movq 32(%rbp), %r15
	movq 24(%rbp), %r14
	movq 16(%rbp), %r13
	movq %r9, %r12
	xchgq %rcx, %rdx
	xchgq %rax, %rcx
	movq %rsi, -96(%rbp)
	movq %rbx, %rsi
	movq %r8, %rbx
	cmpq $0, %rax
	setz %r8b
	movzbl %r8b, %r8d
	cmpl $0, %r8d
	jz .Lbb2866
	movq %rbx, %r15
	movq %rdi, %rbx
	movq %r12, %r14
	movq %r13, %r12
	movq %rdx, %r13
	jmp .Lbb2883
.Lbb2866:
	cmpq $1, %rax
	jnz .Lbb2868
	movq %r12, %rax
	movq %r14, %r12
	movq %rbx, %r14
	movq %rdi, %rbx
	xchgq %rdx, %r15
	jmp .Lbb2887
.Lbb2868:
	cmpq $2, %rax
	jnz .Lbb2870
	movq %rdx, %rax
	movq %rbx, %r15
	movq %rdi, %rbx
	xchgq %r12, %r14
	jmp .Lbb2891
.Lbb2870:
	cmpq $3, %rax
	jnz .Lbb2872
	movq %rbx, %rax
	movq %rdi, %rbx
	movq %r12, %r15
	movq %rdx, %r12
	xchgq %r13, %r14
	jmp .Lbb2919
.Lbb2872:
	cmpq $4, %rax
	jnz .Lbb2874
	movq %r12, %rax
	movq %r13, %rcx
	movq %r14, %r13
	movq %rbx, %r14
	movq %rdi, %rbx
	movq %r15, %r12
	movq %rdx, %r15
	jmp .Lbb2930
.Lbb2874:
	cmpq $5, %rax
	jnz .Lbb2876
	movq %rbx, %r15
	movq %rdi, %rbx
	xchgq %r12, %r13
	movq %r14, %rax
	movq %rdx, %r14
	jmp .Lbb2946
.Lbb2876:
	cmpq $6, %rax
	jnz .Lbb2878
	movq %rdx, %rax
	movq %rbx, -16(%rbp)
	movq %rdi, %rbx
	movq %r13, -8(%rbp)
	movq %r14, %r13
	movq %r12, %r14
	movq %r15, %r12
	movq %rsi, %r15
	jmp .Lbb2895
.Lbb2878:
	cmpq $7, %rax
	jnz .Lbb2880
	movq %rdx, %rax
	movq %rbx, -48(%rbp)
	movq %rdi, %rbx
	movq %r12, -40(%rbp)
	movq %r13, -24(%rbp)
	movq %r14, %r12
	movq %r15, %r13
	movq %rsi, %r14
	jmp .Lbb2899
.Lbb2880:
	movq %rdx, %r15
	xchgq %r12, %r13
	movq %r14, %rax
	movq %rbx, %r14
	movq %rdi, %rbx
.p2align 4
.Lbb2881:
	movq %rax, -176(%rbp)
	movq %r15, -168(%rbp)
	leaq -176(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r15
	xchgq %r14, %r15
	xchgq %r12, %r13
.p2align 4
.Lbb2883:
	movq %r15, %rax
	shrq $40, %rax
	andq $65535, %rax
	cmpq $17, %rax
	jz .Lbb2954
	cmpq $18, %rax
	jnz .Lbb2952
	leaq -360(%rbp), %rdx
	movq %r15, %rsi
	movq %rbx, %rdi
	callq p125_rt_take2
	movq -360(%rbp), %r15
	movq -352(%rbp), %rax
	movl %r12d, %ecx
	cmpq $0, %rcx
	setz %cl
	movzbl %cl, %ecx
	movl %ecx, %ecx
	xchgq %r13, %r15
	xchgq %r12, %rax
	movq %rcx, %rdx
.Lbb2887:
	cmpq $1, %rdx
	setz %cl
	movzbl %cl, %ecx
	shrq $40, %rdx
	andq $8388607, %rdx
	cmpq $65538, %rdx
	setz %dl
	movzbl %dl, %edx
	orl %edx, %ecx
	jnz .Lbb2950
	xorl $1, %ecx
	jz .Lbb2948
	movl %eax, %eax
	subl $1, %eax
	movl %eax, %eax
	xchgq %r13, %rax
	xchgq %r12, %r13
.Lbb2891:
	movq %rax, %rcx
	shrq $40, %rcx
	andq $65535, %rcx
	cmpq $166, %rcx
	jz .Lbb2917
	cmpq $167, %rcx
	jnz .Lbb2915
	leaq -344(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take3
	movq -344(%rbp), %rcx
	movq -336(%rbp), %rdx
	movq -328(%rbp), %rax
	movq %r15, -16(%rbp)
	movq %r12, -8(%rbp)
	movq %rdx, %r12
	movq %rax, %r15
	movq %r14, %rax
	movq %r13, %r14
	movq %rcx, %r13
.Lbb2895:
	movq %rax, %rcx
	shrq $40, %rcx
	andq $65535, %rcx
	cmpq $17, %rcx
	jz .Lbb2913
	cmpq $18, %rcx
	jnz .Lbb2911
	leaq -216(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take2
	movq %r15, %rax
	movq -16(%rbp), %r15
	movq -8(%rbp), %rdx
	movq -216(%rbp), %rcx
	movq -208(%rbp), %rsi
	movq %rsi, -48(%rbp)
	movq %r15, -40(%rbp)
	movq %r14, -24(%rbp)
	movq %rax, %r14
	movq %r12, %rax
	movq %rdx, %r12
.Lbb2899:
	movq %rcx, %r15
	movq %rax, %rcx
	shrq $40, %rcx
	andq $65535, %rcx
	cmpq $17, %rcx
	jz .Lbb2908
	cmpq $18, %rcx
	jnz .Lbb2906
	leaq -200(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take2
	movq %r15, %rcx
	movq %r14, %rax
	movq %rax, %r14
	movq -24(%rbp), %rax
	movq -200(%rbp), %rdx
	movq -192(%rbp), %rsi
	movq %rsi, -32(%rbp)
	movq %rdx, -200(%rbp)
	movq %rcx, %r15
	movq $1099511627775, %rcx
	cmpq %rcx, %rdx
	jbe .Lbb2903
	leaq -200(%rbp), %rdx
	movl $166, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor1
	movq %r15, %rcx
	movq %rax, %r15
	movq %r14, %rax
	movq -24(%rbp), %r14
	jmp .Lbb2905
.Lbb2903:
	xchgq %rax, %r14
	movq %r15, %rcx
	movq $72240112968138752, %rsi
	movq %rdx, %r15
	orq %rsi, %r15
.Lbb2905:
	movq %rcx, -200(%rbp)
	movq %rax, -192(%rbp)
	leaq -200(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r13, %rdx
	movq -32(%rbp), %rcx
	movq -40(%rbp), %r13
	movq %rdx, -200(%rbp)
	movq %rcx, -192(%rbp)
	movq %rax, -184(%rbp)
	leaq -200(%rbp), %rdx
	movl $167, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor3
	movq %rax, %rcx
	movq %r14, %rax
	movq -48(%rbp), %r14
	movq %rcx, -200(%rbp)
	movq %rax, -192(%rbp)
	leaq -200(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r15, -200(%rbp)
	movq %rax, -192(%rbp)
	leaq -200(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r15
	jmp .Lbb2883
.Lbb2906:
	movq %rbx, %rdi
	movq -96(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb2956
.Lbb2908:
	movq %r14, %rax
	movq %r13, %r14
	movq -24(%rbp), %r13
	movq %r15, %rcx
	movq -40(%rbp), %r15
	movq %rcx, -200(%rbp)
	movq %rax, -192(%rbp)
	leaq -200(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %rsi
	movq $72076285735600128, %rdx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_110_116_95_114_101_118_101_114_115_101_
	movq %rax, %r8
	movq %r14, %rax
	movq -48(%rbp), %r14
	movq %rax, %rcx
	movq %r15, %rdx
	leaq -160(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_101_109_105_116_
	movq %r13, %rax
	movq -160(%rbp), %r13
	movq -152(%rbp), %r15
	xchgq %r12, %r13
	xchgq %r14, %r15
	xchgq %rax, %r14
	jmp .Lbb2881
.Lbb2911:
	movq %rbx, %rdi
	movq -96(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb2956
.Lbb2913:
	movq %r14, %rdx
	movq %r15, %rsi
	movq -16(%rbp), %r15
	movq %rbx, %rdi
	movq %rsi, %r14
	movq %rdx, %rsi
	movq %rdi, %rbx
	callq p111_rt_sink
	movq %r14, %rsi
	movq %rbx, %rdi
	movq -96(%rbp), %rbx
	movq %rsi, %r14
	movq %r13, %rsi
	movq %rdi, %r13
	callq p111_rt_sink
	movq %r14, %rsi
	movq %r13, %rdi
	movq %rsi, %r13
	movq %r12, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r13, %rsi
	movq %r12, %rdi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r15, %rsi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_102_97_105_108_
	movq %rax, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb2956
.Lbb2915:
	movq %rbx, %rdi
	movq -96(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb2956
.Lbb2917:
	leaq -344(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take1
	movq -344(%rbp), %rax
	xchgq %r15, %r12
	xchgq %r13, %r15
.Lbb2919:
	movq %rax, %rcx
	shrq $40, %rcx
	andq $65535, %rcx
	cmpq $150, %rcx
	jz .Lbb2928
	cmpq $151, %rcx
	jz .Lbb2926
	cmpq $152, %rcx
	jnz .Lbb2924
	movl $5, %ecx
	leaq -320(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_take
	movq -320(%rbp), %rdi
	movq -312(%rbp), %rsi
	movq -304(%rbp), %rdx
	movq -296(%rbp), %rcx
	movq -288(%rbp), %rax
	movq %rdi, -320(%rbp)
	movq %rsi, -312(%rbp)
	movq %rdx, -304(%rbp)
	movq %rcx, -296(%rbp)
	movq %rax, -288(%rbp)
	movl $5, %ecx
	leaq -320(%rbp), %rdx
	movl $163, %esi
	movq %rbx, %rdi
	callq p111_rt_ctor
	movq %r15, %rcx
	movq %r12, %r15
	movq %r13, %r12
	movq %r14, %r13
	movq %rax, %r14
	movq $72076285735600128, %rax
	jmp .Lbb2930
.Lbb2924:
	movq %rbx, %rdi
	movq -96(%rbp), %rbx
	movq %r12, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb2956
.Lbb2926:
	movl $8, %ecx
	leaq -320(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_take
	movq -320(%rbp), %r9
	movq -312(%rbp), %r8
	movq -304(%rbp), %rdi
	movq -296(%rbp), %rax
	movq %rax, -56(%rbp)
	movq -288(%rbp), %rsi
	movq -280(%rbp), %rdx
	movq -272(%rbp), %rcx
	movq -264(%rbp), %rax
	movq %r9, -320(%rbp)
	movq %r8, -312(%rbp)
	movq %rdi, -304(%rbp)
	movq %rsi, -296(%rbp)
	movq %rdx, -288(%rbp)
	movq %rcx, -280(%rbp)
	movq %rax, -272(%rbp)
	movl $7, %ecx
	leaq -320(%rbp), %rdx
	movl $162, %esi
	movq %rbx, %rdi
	callq p111_rt_ctor
	movq %rax, %rcx
	movq -56(%rbp), %rax
	xchgq %r14, %r13
	xchgq %rcx, %r14
	xchgq %r15, %rcx
	xchgq %r12, %r15
	jmp .Lbb2930
.Lbb2928:
	movl $8, %ecx
	leaq -320(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_take
	movq -320(%rbp), %r9
	movq -312(%rbp), %r8
	movq -304(%rbp), %rdi
	movq -296(%rbp), %rsi
	movq -288(%rbp), %rax
	movq %rax, -64(%rbp)
	movq -280(%rbp), %rdx
	movq -272(%rbp), %rcx
	movq -264(%rbp), %rax
	movq %r9, -320(%rbp)
	movq %r8, -312(%rbp)
	movq %rdi, -304(%rbp)
	movq %rsi, -296(%rbp)
	movq %rdx, -288(%rbp)
	movq %rcx, -280(%rbp)
	movq %rax, -272(%rbp)
	movl $7, %ecx
	leaq -320(%rbp), %rdx
	movl $161, %esi
	movq %rbx, %rdi
	callq p111_rt_ctor
	movq %rax, %rcx
	movq -64(%rbp), %rax
	xchgq %r14, %r13
	xchgq %rcx, %r14
	xchgq %r15, %rcx
	xchgq %r12, %r15
.Lbb2930:
	movq %rcx, -80(%rbp)
	movq %rax, %rdx
	shrq $40, %rdx
	andq $65535, %rdx
	cmpq $17, %rdx
	jz .Lbb2943
	movq %rdx, %rcx
	cmpq $18, %rcx
	jnz .Lbb2941
	leaq -256(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take2
	movq -80(%rbp), %rcx
	movq -256(%rbp), %rdx
	movq -248(%rbp), %rax
	movq %rax, -72(%rbp)
	movq %rdx, -256(%rbp)
	movq $1099511627775, %rsi
	cmpq %rsi, %rdx
	jbe .Lbb2936
	leaq -256(%rbp), %rdx
	movl $166, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor1
	movq %r14, %rcx
	movq %rax, %r14
	movq -72(%rbp), %rax
	movq %r14, %rdx
	movq -80(%rbp), %r14
	movq %rdx, -88(%rbp)
	jmp .Lbb2939
.Lbb2936:
	xchgq %r14, %rcx
	movq $72240112968138752, %rsi
	orq %rsi, %rdx
	movq %rdx, -88(%rbp)
.Lbb2939:
	movq %rcx, -256(%rbp)
	movq %rax, -248(%rbp)
	movq $72076285735600128, %rax
	movq %rax, -240(%rbp)
	leaq -256(%rbp), %rdx
	movl $167, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor3
	movq %rax, %rcx
	movq %r14, %rax
	movq -88(%rbp), %r14
	movq %rcx, -256(%rbp)
	movq %rax, -248(%rbp)
	leaq -256(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r14, -256(%rbp)
	movq %rax, -248(%rbp)
	leaq -256(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r14
	xchgq %r15, %r13
	xchgq %r14, %r15
	jmp .Lbb2883
.Lbb2941:
	movq %rbx, %rdi
	movq -96(%rbp), %rbx
	movq %r15, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r14, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb2956
.Lbb2943:
	movq %r14, %rax
	movq %rcx, %r14
	movq $72076285735600128, %r8
	movq %rax, %rcx
	movq %r15, %rdx
	leaq -160(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_101_109_105_116_
	movq -160(%rbp), %r15
	movq -152(%rbp), %rax
	xchgq %r13, %r15
	xchgq %r12, %r13
.Lbb2946:
	movq %rax, -232(%rbp)
	movq %r15, -224(%rbp)
	leaq -232(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r15
	xchgq %r14, %r15
	xchgq %r12, %r13
	jmp .Lbb2883
.Lbb2948:
	movq %rbx, %rdi
	movq -96(%rbp), %rbx
	movq %r15, %rsi
	movq %rdi, %r15
	callq p111_rt_sink
	movq %r15, %rdi
	movq %r14, %rsi
	movq %rdi, %r14
	callq p111_rt_sink
	movq %r14, %rdi
	movq %r13, %rsi
	movq %rdi, %r13
	callq p111_rt_sink
	movq %r13, %rdi
	movq %r12, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb2956
.Lbb2950:
	movq %rbx, %rdi
	movq -96(%rbp), %rbx
	movq %r14, %rsi
	movq %rdi, %r14
	callq p111_rt_sink
	movq %r14, %rdi
	movq %r13, %rsi
	movq %rdi, %r13
	callq p111_rt_sink
	movq %r13, %rdi
	movq %r12, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r15, %rsi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_102_97_105_108_
	movq %rax, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb2956
.Lbb2952:
	movq %rbx, %rdi
	movq -96(%rbp), %rbx
	movq %r13, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb2956
.Lbb2954:
	movq %r14, %rdx
	movq %rbx, %rdi
	movq -96(%rbp), %rbx
	movq %r13, %rcx
	leaq -160(%rbp), %rsi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_109_97_116_99_104_95_49_
	movq -160(%rbp), %rcx
	movq -152(%rbp), %rax
	movq %rcx, (%rbx)
	movq %rax, 8(%rbx)
	movl $0, %eax
.Lbb2956:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type p113d_FID_36_112_49_55_51_115_99_99_46_48_, @function
.size p113d_FID_36_112_49_55_51_115_99_99_46_48_, .-p113d_FID_36_112_49_55_51_115_99_99_46_48_

p113d_FID_36_112_49_55_51_115_99_99_46_56_:
	endbr64
	pushq %rbp
	movq %rsp, %rbp
	subq $456, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movq 72(%rbp), %r10
	movq 64(%rbp), %rbx
	movq 56(%rbp), %r11
	movq 48(%rbp), %r12
	movq 40(%rbp), %rax
	movq 32(%rbp), %r15
	movq 24(%rbp), %r14
	movq 16(%rbp), %r13
	xchgq %r8, %rbx
	xchgq %rcx, %rdx
	xchgq %r12, %rcx
	xchgq %r9, %r12
	movq %rsi, -176(%rbp)
	movq %r11, %rsi
	cmpq $0, %r9
	setz %r11b
	movzbl %r11b, %r11d
	cmpl $0, %r11d
	jz .Lbb2511
	movq %rbx, %r15
	movq %rdi, %rbx
	movq %r12, %r14
	movq %r13, %r12
	movq %rdx, %r13
	jmp .Lbb2536
.Lbb2511:
	cmpq $1, %r9
	jnz .Lbb2513
	movq %r12, %rax
	movq %r14, %r12
	movq %rbx, %r14
	movq %rdi, %rbx
	xchgq %rdx, %r15
	jmp .Lbb2540
.Lbb2513:
	cmpq $2, %r9
	jnz .Lbb2515
	movq %rdx, %rax
	movq %rbx, %r15
	movq %rdi, %rbx
	xchgq %r12, %r14
	jmp .Lbb2544
.Lbb2515:
	cmpq $3, %r9
	jnz .Lbb2517
	movq %rdx, %r15
	movq %rbx, %rax
	movq %rdi, %rbx
	xchgq %r12, %r14
	jmp .Lbb2569
.Lbb2517:
	cmpq $4, %r9
	jnz .Lbb2519
	movq %rdx, %r15
	xchgq %r12, %r13
	movq %r14, %rax
	movq %rbx, %r14
	movq %rdi, %rbx
	jmp .Lbb2571
.Lbb2519:
	cmpq $5, %r9
	jnz .Lbb2521
	movq %rbx, %rcx
	movq %rdi, %rbx
	xchgq %r13, %r15
	xchgq %r12, %rax
	jmp .Lbb2574
.Lbb2521:
	cmpq $6, %r9
	jnz .Lbb2523
	movq %rax, -136(%rbp)
	movq %rdx, %rax
	movq %r13, %rdx
	movq %r15, %r13
	movq %r12, %r15
	movq %rbx, %r12
	movq %rdi, %rbx
	movq %rcx, %rsi
	jmp .Lbb2576
.Lbb2523:
	cmpq $7, %r9
	jnz .Lbb2525
	movq %rdx, -168(%rbp)
	movq %rbx, %rdx
	movq %rdi, %rbx
	xchgq %r12, %rcx
	xchgq %rax, %r12
	xchgq %r14, %rax
	xchgq %r13, %r14
	xchgq %r15, %r13
	jmp .Lbb2580
.Lbb2525:
	cmpq $8, %r9
	jnz .Lbb2527
	movq %rbx, -80(%rbp)
	movq %rdi, %rbx
	movq %r12, -64(%rbp)
	movq %r13, -88(%rbp)
	movq %r15, -72(%rbp)
	movq %r14, %r15
	movq %rax, %r13
	movq %rdx, %rax
	movq %rcx, %r12
	movq %rsi, %r14
	jmp .Lbb2548
.Lbb2527:
	cmpq $9, %r9
	jnz .Lbb2529
	movq %r12, -120(%rbp)
	movq %r13, %r12
	movq %rdx, %r13
	movq %r15, -104(%rbp)
	movq %rbx, %r15
	movq %rdi, %rbx
	movq %rax, -112(%rbp)
	movq %rcx, -96(%rbp)
	movq %rsi, %rax
	movq %r8, %rcx
	jmp .Lbb2552
.Lbb2529:
	movq %rdx, -56(%rbp)
	movq %rbx, -32(%rbp)
	movq %rdi, %rbx
	movq %r12, -40(%rbp)
	movq %r13, -48(%rbp)
	movq %r15, %rdx
	movq %rax, %r13
	movq %rcx, %r15
	movq %r14, %rcx
	movq %rsi, %r12
.p2align 4
.Lbb2530:
	movq %r8, %r14
	movq %rcx, -8(%rbp)
	movq %rdx, -16(%rbp)
	movq %r10, -280(%rbp)
	movq $1099511627775, %rax
	cmpq %rax, %r10
	jbe .Lbb2532
	leaq -280(%rbp), %rdx
	movl $168, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor1
	movq %r15, %rcx
	movq %rax, %r15
	movq %r12, %rax
	movq -8(%rbp), %r12
	movq -16(%rbp), %rdx
	jmp .Lbb2534
.Lbb2532:
	movq %r12, %rax
	movq %rcx, %r12
	movq %r15, %rcx
	movq $72242311991394304, %rsi
	movq %r10, %r15
	orq %rsi, %r15
.Lbb2534:
	movl %edx, %edx
	addl $1, %edx
	movl %edx, %edx
	movq %rdx, -24(%rbp)
	movq %rax, -280(%rbp)
	movq %rcx, -272(%rbp)
	leaq -280(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r12, %rsi
	movq -32(%rbp), %r12
	movq -40(%rbp), %rcx
	movq -48(%rbp), %rdi
	movq -24(%rbp), %rdx
	movq %rdi, -280(%rbp)
	movq %rsi, -272(%rbp)
	movq %rdx, -264(%rbp)
	movq %r13, -256(%rbp)
	movq %rax, -248(%rbp)
	movq %rcx, %r13
	movl $5, %ecx
	leaq -280(%rbp), %rdx
	movl $169, %esi
	movq %rbx, %rdi
	callq p111_rt_ctor
	movq %r13, %rcx
	movq -56(%rbp), %r13
	movq %rax, -280(%rbp)
	movq %rcx, -272(%rbp)
	leaq -280(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r15, -280(%rbp)
	movq %rax, -272(%rbp)
	leaq -280(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r14, %rcx
	movq %rax, %r14
	movq %r14, %r15
	movq %r13, %r14
	movq %rcx, %r13
.p2align 4
.Lbb2536:
	movq %r15, %rax
	shrq $40, %rax
	andq $65535, %rax
	cmpq $17, %rax
	jz .Lbb2600
	cmpq $18, %rax
	jnz .Lbb2598
	leaq -448(%rbp), %rdx
	movq %r15, %rsi
	movq %rbx, %rdi
	callq p125_rt_take2
	movq -448(%rbp), %r15
	movq -440(%rbp), %rax
	movl %r12d, %ecx
	cmpq $0, %rcx
	setz %cl
	movzbl %cl, %ecx
	movl %ecx, %ecx
	xchgq %r13, %r15
	xchgq %r12, %rax
	movq %rcx, %rdx
.Lbb2540:
	cmpq $1, %rdx
	setz %cl
	movzbl %cl, %ecx
	shrq $40, %rdx
	andq $8388607, %rdx
	cmpq $65538, %rdx
	setz %dl
	movzbl %dl, %edx
	orl %edx, %ecx
	jnz .Lbb2596
	xorl $1, %ecx
	jz .Lbb2594
	movl %eax, %eax
	subl $1, %eax
	movl %eax, %eax
	xchgq %r13, %rax
.Lbb2544:
	movq %rax, %rcx
	shrq $40, %rcx
	andq $65535, %rcx
	cmpq $168, %rcx
	jz .Lbb2567
	cmpq $169, %rcx
	jnz .Lbb2565
	movl $5, %ecx
	leaq -432(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_take
	movq -432(%rbp), %rax
	movq -424(%rbp), %rcx
	movq -416(%rbp), %rdx
	movq -408(%rbp), %rsi
	movq -400(%rbp), %rdi
	movq %r15, -80(%rbp)
	movq %r13, -64(%rbp)
	movq %r12, -88(%rbp)
	movq %rax, %r15
	movq %r14, %rax
	movq %rcx, -72(%rbp)
	movq %rdx, %r13
	movq %rsi, %r12
	movq %rdi, %r14
.Lbb2548:
	movq %rax, %rcx
	shrq $40, %rcx
	andq $65535, %rcx
	cmpq $17, %rcx
	jz .Lbb2563
	cmpq $18, %rcx
	jnz .Lbb2561
	leaq -312(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take2
	movq -80(%rbp), %rcx
	movq -64(%rbp), %rsi
	movq -88(%rbp), %rax
	movq -72(%rbp), %rdx
	movq -312(%rbp), %rdi
	movq -304(%rbp), %r8
	movl %r13d, %r10d
	movl %r12d, %r9d
	cmpq %r9, %r10
	setz %r9b
	movzbl %r9b, %r9d
	movl %r9d, %r10d
	movq %rsi, -120(%rbp)
	movq %rdx, -104(%rbp)
	movq %r13, -112(%rbp)
	movq %rcx, %r13
	movq %r12, -96(%rbp)
	movq %rax, %r12
	movq %r14, %rax
	movq %r15, %r14
	movq %r8, %r15
	movq %rdi, %rcx
.Lbb2552:
	movq %r15, -128(%rbp)
	cmpq $1, %r10
	setz %dl
	movzbl %dl, %edx
	movq %r10, %rsi
	shrq $40, %rsi
	andq $8388607, %rsi
	cmpq $65538, %rsi
	setz %sil
	movzbl %sil, %esi
	orl %esi, %edx
	jz .Lbb2555
	movq %rcx, -296(%rbp)
	movq %rax, -288(%rbp)
	leaq -296(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %rsi
	movq $72076285735600128, %rdx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_110_116_95_114_101_118_101_114_115_101_
	movq %rax, %rdx
	movq %r14, %rax
	movq -120(%rbp), %r14
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_115_104_97_112_101_95_116_101_114_109_
	movq %rax, -296(%rbp)
	movq %r15, -288(%rbp)
	leaq -296(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r15
	xchgq %r15, %r14
	xchgq %r12, %r15
	jmp .Lbb2536
.Lbb2555:
	xchgq %r13, %rax
	movq %rcx, %r15
	movq -104(%rbp), %rcx
	movl %edx, %esi
	movq -112(%rbp), %rdx
	xorl $1, %esi
	jz .Lbb2559
	movq %rcx, %rsi
	movl %ecx, %ecx
	movl %edx, %edx
	addl %edx, %ecx
	movl %ecx, %ecx
	movq %rax, %rdx
	leaq -240(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_101_100_103_101_
	movq %r15, %rcx
	movq %r13, %rax
	movq -128(%rbp), %r15
	movq -120(%rbp), %r13
	movq -104(%rbp), %rsi
	movq -112(%rbp), %rdx
	movq -96(%rbp), %rdi
	movq -240(%rbp), %r8
	movq -232(%rbp), %r10
	movq %r15, -56(%rbp)
	movq %r13, -32(%rbp)
	movq %r12, -40(%rbp)
	movq %r14, -48(%rbp)
	movq %rdi, %r13
	movq %rax, %r15
	movq %rcx, %r12
	movq %rsi, %rcx
	jmp .Lbb2530
.Lbb2559:
	movq %rbx, %rdi
	movq %rax, %rsi
	movq %rdi, %rbx
	callq p111_rt_sink
	movq %r12, %rdx
	movq %rbx, %rdi
	movq %rdx, %r12
	movq -128(%rbp), %rdx
	movq %rdx, %rsi
	movq %rdi, %rbx
	callq p111_rt_sink
	movq %rbx, %rdi
	movq -176(%rbp), %rbx
	movq %r12, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r14, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r13, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r15, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb2602
.Lbb2561:
	movq %rbx, %rdi
	movq -176(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb2602
.Lbb2563:
	movq -80(%rbp), %r13
	movq -88(%rbp), %rax
	movq %rbx, %rdi
	movq -176(%rbp), %rbx
	movq %rax, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r15, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r14, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r13, %rcx
	movq %r12, %rdi
	movq %rcx, %rsi
	movq %rdi, %r12
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_102_97_105_108_
	movq %r12, %rdi
	movq %rax, %r12
	movq $144142675917973550, %rsi
	callq p113d_FID_36_100_105_114_101_99_116_46_97_116_111_109_
	movq %r12, (%rbx)
	movq %rax, 8(%rbx)
	movl $0, %eax
	jmp .Lbb2602
.Lbb2565:
	movq %rbx, %rdi
	movq -176(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb2602
.Lbb2567:
	leaq -432(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take1
	movq -432(%rbp), %rax
	xchgq %r14, %r13
	xchgq %r12, %r14
.Lbb2569:
	movq %rax, %rcx
	movq %r15, %rdx
	leaq -240(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_110_111_100_101_
	movq -240(%rbp), %r15
	movq -232(%rbp), %rax
	xchgq %r14, %r15
	xchgq %r13, %r14
	xchgq %r12, %r13
.Lbb2571:
	movq %rax, %rcx
	shrq $40, %rcx
	andq $65535, %rcx
	cmpq $164, %rcx
	jnz .Lbb2592
	leaq -392(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take3
	movq -392(%rbp), %rax
	movq -384(%rbp), %rcx
	movq -376(%rbp), %rdx
	xchgq %r14, %rax
	xchgq %r15, %rcx
	xchgq %r13, %r15
	xchgq %r12, %rdx
.Lbb2574:
	movl %r12d, %esi
	cmpq $0, %rsi
	setz %sil
	movzbl %sil, %esi
	movl %esi, %esi
	xchgq %rax, %r15
	xchgq %rdx, %rax
	movq %r12, -136(%rbp)
	movq %rcx, %r12
.Lbb2576:
	movq %rdx, -144(%rbp)
	cmpq $1, %rsi
	setz %cl
	movzbl %cl, %ecx
	shrq $40, %rsi
	andq $8388607, %rsi
	cmpq $65538, %rsi
	setz %sil
	movzbl %sil, %esi
	orl %esi, %ecx
	jnz .Lbb2589
	xorl $1, %ecx
	jz .Lbb2587
	movq %r13, %rcx
	movq %rax, %rdx
	leaq -240(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_101_100_103_101_
	movq %r14, %rax
	movq -144(%rbp), %r14
	movq -136(%rbp), %rcx
	movq -240(%rbp), %rdx
	movq -232(%rbp), %rsi
	movq %r12, -168(%rbp)
	xchgq %r14, %rcx
	xchgq %rax, %r14
	xchgq %r13, %rax
	movq %rdx, %r12
	movq %r15, %rdx
	movq %rsi, %r15
.Lbb2580:
	movq %rdx, -152(%rbp)
	movq %rcx, -160(%rbp)
	movq %r15, -352(%rbp)
	movq $1099511627775, %rsi
	cmpq %rsi, %r15
	jbe .Lbb2583
	movq %rax, %r15
	leaq -352(%rbp), %rdx
	movl $168, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor1
	movq %r15, %rcx
	movq %r14, %rdx
	movq %rax, %r15
	movq %r13, %rax
	movq -152(%rbp), %r14
	movq -160(%rbp), %r13
	jmp .Lbb2585
.Lbb2583:
	xchgq %rdx, %r14
	xchgq %rcx, %r13
	xchgq %rax, %rcx
	movq $72242311991394304, %rsi
	orq %rsi, %r15
.Lbb2585:
	movq %rdx, -352(%rbp)
	movq %rcx, -344(%rbp)
	movq $1, -336(%rbp)
	movq %rax, -328(%rbp)
	movq $72076285735600128, %rax
	movq %rax, -320(%rbp)
	movl $5, %ecx
	leaq -352(%rbp), %rdx
	movl $169, %esi
	movq %rbx, %rdi
	callq p111_rt_ctor
	movq %rax, %rcx
	movq -168(%rbp), %rax
	movq %rcx, -352(%rbp)
	movq %rax, -344(%rbp)
	leaq -352(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r15, -352(%rbp)
	movq %rax, -344(%rbp)
	leaq -352(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r15
	xchgq %r12, %r13
	jmp .Lbb2536
.Lbb2587:
	movq %rbx, %rdi
	movq -176(%rbp), %rbx
	movq %rax, %rsi
	movq %rdi, %r13
	callq p111_rt_sink
	movq %r13, %rdi
	movq %r12, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r15, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r14, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb2602
.Lbb2589:
	movq %rax, %r13
	movq %r14, %rax
	movq %rdx, %r14
	movq $72076285735600128, %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_115_104_97_112_101_95_116_101_114_109_
	movq %rax, -368(%rbp)
	movq %r15, -360(%rbp)
	leaq -368(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r15
	xchgq %r15, %r14
	xchgq %r12, %r15
	jmp .Lbb2536
.Lbb2592:
	movq %rbx, %rdi
	movq -176(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb2602
.Lbb2594:
	movq %rbx, %rdi
	movq -176(%rbp), %rbx
	movq %r15, %rsi
	movq %rdi, %r15
	callq p111_rt_sink
	movq %r15, %rdi
	movq %r14, %rsi
	movq %rdi, %r14
	callq p111_rt_sink
	movq %r14, %rdi
	movq %r13, %rsi
	movq %rdi, %r13
	callq p111_rt_sink
	movq %r13, %rdi
	movq %r12, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb2602
.Lbb2596:
	movq %rbx, %rdi
	movq -176(%rbp), %rbx
	movq %r14, %rsi
	movq %rdi, %r14
	callq p111_rt_sink
	movq %r14, %rdi
	movq %r13, %rsi
	movq %rdi, %r13
	callq p111_rt_sink
	movq %r13, %rdi
	movq %r12, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r15, %rsi
	movq %rdi, %r12
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_102_97_105_108_
	movq %r12, %rdi
	movq %rax, %r12
	movq $144142675917973550, %rsi
	callq p113d_FID_36_100_105_114_101_99_116_46_97_116_111_109_
	movq %r12, (%rbx)
	movq %rax, 8(%rbx)
	movl $0, %eax
	jmp .Lbb2602
.Lbb2598:
	movq %rbx, %rdi
	movq -176(%rbp), %rbx
	movq %r13, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb2602
.Lbb2600:
	movq %r14, %rdx
	movq %rbx, %rdi
	movq -176(%rbp), %rbx
	movq %r13, %rcx
	leaq -240(%rbp), %rsi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_109_97_116_99_104_95_50_
	movq -240(%rbp), %rcx
	movq -232(%rbp), %rax
	movq %rcx, (%rbx)
	movq %rax, 8(%rbx)
	movl $0, %eax
.Lbb2602:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type p113d_FID_36_112_49_55_51_115_99_99_46_56_, @function
.size p113d_FID_36_112_49_55_51_115_99_99_46_56_, .-p113d_FID_36_112_49_55_51_115_99_99_46_56_

p113d_FID_36_112_49_55_51_115_99_99_46_55_:
	endbr64
	pushq %rbp
	movq %rsp, %rbp
	subq $168, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movq 40(%rbp), %rax
	movq 32(%rbp), %r10
	movq 24(%rbp), %r15
	movq 16(%rbp), %r14
	movq %r9, %r12
	movq %r8, %rbx
	movq %rax, %r8
	movq %rcx, %r13
	movq %rdx, %rax
	movq %rsi, -32(%rbp)
	cmpq $0, %rax
	setz %cl
	movzbl %cl, %ecx
	cmpl $0, %ecx
	jz .Lbb3158
	movq %rbx, %r15
	movq %rdi, %rbx
	xchgq %r12, %r14
	jmp .Lbb3177
.Lbb3158:
	cmpq $1, %rax
	jnz .Lbb3160
	movq %r15, %rax
	movq %r13, %r15
	movq %rbx, %r13
	movq %rdi, %rbx
	jmp .Lbb3181
.Lbb3160:
	cmpq $2, %rax
	jnz .Lbb3162
	movq %r15, %rax
	movq %r13, %r15
	movq %r12, %r13
	movq %r14, %r12
	movq %rbx, %r14
	movq %rdi, %rbx
	jmp .Lbb3185
.Lbb3162:
	cmpq $3, %rax
	jnz .Lbb3164
	movq %rbx, %rax
	movq %rdi, %rbx
	xchgq %r13, %r15
	xchgq %r14, %r13
	xchgq %r12, %r14
	jmp .Lbb3188
.Lbb3164:
	cmpq $4, %rax
	jz .Lbb3166
	movq %r14, %rcx
	movq %r15, %rax
	movq %r12, %r15
	movq %rbx, %r12
	movq %rdi, %rbx
	jmp .Lbb3169
.Lbb3166:
	movq %r13, -24(%rbp)
	movq %r15, %r13
	movq %rbx, %r15
	movq %rdi, %rbx
.p2align 4
.Lbb3167:
	movq %r12, %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %r12
	movq %r12, %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_115_104_97_112_101_95_116_97_103_
	movq %rax, %rsi
	movq $144142675917963794, %rdx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq %rax, %r10
	movq -24(%rbp), %rax
	movq %r15, %rcx
	movq %rax, %r15
	movq %r12, %rax
	movq %r13, %r12
	movq %r14, %r13
.Lbb3169:
	cmpq $1, %r10
	setz %dl
	movzbl %dl, %edx
	movq %r10, %rsi
	shrq $40, %rsi
	andq $8388607, %rsi
	cmpq $65538, %rsi
	setz %sil
	movzbl %sil, %esi
	movl %edx, %r14d
	orl %esi, %r14d
	movl %ecx, %ecx
	subl $1, %ecx
	movl %ecx, %ecx
	movq %rcx, -16(%rbp)
	cmpl $0, %r14d
	jnz .Lbb3174
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_sink
	movl %r14d, %eax
	movq -16(%rbp), %r14
	xorl $1, %eax
	jz .Lbb3172
	xchgq %r15, %r14
	xchgq %r12, %r15
	jmp .Lbb3177
.Lbb3172:
	movq %rbx, %rdi
	movq -32(%rbp), %rbx
	movq %r13, %rsi
	movq %rdi, %r13
	callq p111_rt_sink
	movq %r13, %rdi
	movq %r12, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r15, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3200
.Lbb3174:
	movq %rcx, %r14
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_115_104_97_112_101_95_110_97_109_101_
	movq %rax, -112(%rbp)
	movq %r15, -104(%rbp)
	leaq -112(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r15
	xchgq %r15, %r14
	xchgq %r12, %r15
.Lbb3177:
	movq %r15, %rax
	shrq $40, %rax
	andq $65535, %rax
	cmpq $17, %rax
	jz .Lbb3198
	cmpq $18, %rax
	jnz .Lbb3196
	leaq -152(%rbp), %rdx
	movq %r15, %rsi
	movq %rbx, %rdi
	callq p125_rt_take2
	movq -152(%rbp), %r15
	movq -144(%rbp), %rax
	movl %r12d, %ecx
	cmpq $0, %rcx
	setz %cl
	movzbl %cl, %ecx
	movl %ecx, %r10d
	xchgq %r14, %r12
	xchgq %r13, %r15
	xchgq %rax, %r13
.Lbb3181:
	cmpq $1, %r10
	setz %cl
	movzbl %cl, %ecx
	movq %r10, %rdx
	shrq $40, %rdx
	andq $8388607, %rdx
	cmpq $65538, %rdx
	setz %dl
	movzbl %dl, %edx
	orl %edx, %ecx
	jnz .Lbb3194
	xorl $1, %ecx
	jz .Lbb3192
	movq %rax, %rcx
	movq %r15, %rdx
	leaq -96(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_110_111_100_101_
	movq -96(%rbp), %r15
	movq -88(%rbp), %rax
	xchgq %r13, %r15
	xchgq %r14, %r13
	xchgq %r12, %r14
.Lbb3185:
	movq %rax, %rcx
	shrq $40, %rcx
	andq $65535, %rcx
	cmpq $164, %rcx
	jnz .Lbb3190
	leaq -136(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take3
	movq -136(%rbp), %rax
	movq -128(%rbp), %r10
	movq -120(%rbp), %r8
	xchgq %r15, %rax
	xchgq %r12, %r15
.Lbb3188:
	movq %rax, %r9
	movq %r10, %rcx
	movq %r15, %rdx
	leaq -96(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_112_117_115_104_95_101_100_103_101_115_
	movq -96(%rbp), %r15
	movq -88(%rbp), %rax
	movq %r14, -24(%rbp)
	movq %r15, %r14
	movq %r13, %r15
	movq %rax, %r13
	jmp .Lbb3167
.Lbb3190:
	movq %rbx, %rdi
	movq -32(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3200
.Lbb3192:
	movq %rbx, %rdi
	movq -32(%rbp), %rbx
	movq %r15, %rsi
	movq %rdi, %r14
	callq p111_rt_sink
	movq %r14, %rdi
	movq %r13, %rsi
	movq %rdi, %r13
	callq p111_rt_sink
	movq %r13, %rdi
	movq %r12, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3200
.Lbb3194:
	movq %rbx, %rdi
	movq -32(%rbp), %rbx
	movq %r13, %rsi
	movq %rdi, %r13
	callq p111_rt_sink
	movq %r13, %rdi
	movq %r12, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r15, %rsi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_102_97_105_108_
	movq %rax, (%rbx)
	movq $72076285735600128, %rax
	movq %rax, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3200
.Lbb3196:
	movq %rbx, %rdi
	movq -32(%rbp), %rbx
	movq %r13, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3200
.Lbb3198:
	movq %rbx, %rdi
	movq -32(%rbp), %rbx
	movq $72076285735600128, %rdx
	movq %r14, %rsi
	callq p113d_FID_36_100_105_114_101_99_116_46_110_116_95_114_101_118_101_114_115_101_
	movq %r13, (%rbx)
	movq %rax, 8(%rbx)
	movl $0, %eax
.Lbb3200:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type p113d_FID_36_112_49_55_51_115_99_99_46_55_, @function
.size p113d_FID_36_112_49_55_51_115_99_99_46_55_, .-p113d_FID_36_112_49_55_51_115_99_99_46_55_

p113d_FID_36_112_49_55_51_115_99_99_46_53_:
	endbr64
	pushq %rbp
	movq %rsp, %rbp
	subq $1160, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movq 112(%rbp), %rax
	movq %rax, -16(%rbp)
	movq 104(%rbp), %r11
	movq %r11, -24(%rbp)
	movq 96(%rbp), %rax
	movq %rax, -32(%rbp)
	movq 88(%rbp), %rbx
	movq %rbx, -40(%rbp)
	movq 80(%rbp), %rax
	movq %rax, -8(%rbp)
	movq 72(%rbp), %r10
	movq 64(%rbp), %r11
	movq 56(%rbp), %r12
	movq 48(%rbp), %rbx
	movq 40(%rbp), %rax
	movq 32(%rbp), %r15
	movq 24(%rbp), %r14
	movq 16(%rbp), %r13
	xchgq %r9, %r12
	xchgq %rcx, %rdx
	xchgq %rax, %rcx
	movq %rsi, -464(%rbp)
	movq %rbx, %rsi
	movq %r8, %rbx
	movq -8(%rbp), %r8
	xchgq %rbx, %r12
	xchgq %rdi, %rbx
	xchgq %rax, %rdi
	xchgq %rcx, %r9
	xchgq %r15, %rcx
	xchgq %r14, %r15
	xchgq %r13, %r14
	xchgq %rdx, %r13
	movq %r11, -272(%rbp)
	movq %r8, -216(%rbp)
	movsd -40(%rbp), %xmm15
	movsd %xmm15, -280(%rbp)
	movsd -32(%rbp), %xmm15
	movsd %xmm15, -224(%rbp)
	movsd -24(%rbp), %xmm15
	movsd %xmm15, -232(%rbp)
	movsd -16(%rbp), %xmm15
	movsd %xmm15, -200(%rbp)
.p2align 4
.Lbb3719:
	movq %rax, -456(%rbp)
	movq %rcx, -384(%rbp)
	movq %r9, -424(%rbp)
	movq %rsi, -416(%rbp)
	movq %rdx, -208(%rbp)
	movq %r10, -240(%rbp)
	cmpq $0, %rdi
	setz %r11b
	movzbl %r11b, %r11d
	movl %r14d, %r8d
	cmpq $0, %r8
	setz %r8b
	movzbl %r8b, %r8d
	movl %r8d, %r8d
	movq %r8, -56(%rbp)
	cmpl $0, %r11d
	jnz .Lbb3999
	cmpq $1, %rdi
	setz %r8b
	movzbl %r8b, %r8d
	movq %rcx, %r11
	shrq $40, %r11
	cmpl $0, %r8d
	jnz .Lbb3990
	cmpq $2, %rdi
	setz %r8b
	movzbl %r8b, %r8d
	movl %r8d, -48(%rbp)
	movq %r13, %r8
	shrq $40, %r8
	movq %r8, -80(%rbp)
	andq $65535, %r8
	movq %r8, -64(%rbp)
	cmpl $0, -48(%rbp)
	jnz .Lbb3972
	cmpq $3, %rdi
	jz .Lbb3969
	cmpq $4, %rdi
	jz .Lbb3963
	cmpq $5, %rdi
	jz .Lbb3961
	cmpq $6, %rdi
	jz .Lbb3947
	cmpq $7, %rdi
	setz %r8b
	movzbl %r8b, %r8d
	movl %r8d, -68(%rbp)
	cmpq $1, %rsi
	setz %r8b
	movzbl %r8b, %r8d
	movl %r8d, -300(%rbp)
	movq %rsi, %r11
	shrq $40, %r11
	andq $8388607, %r11
	cmpq $65538, %r11
	setz %r11b
	movzbl %r11b, %r11d
	movl %r11d, -296(%rbp)
	movl %r8d, %r11d
	orl -296(%rbp), %r11d
	movl %r11d, -304(%rbp)
	movl -296(%rbp), %r11d
	cmpl $0, -68(%rbp)
	jnz .Lbb3935
	cmpq $8, %rdi
	jz .Lbb3932
	cmpq $9, %rdi
	jz .Lbb3930
	cmpq $10, %rdi
	jz .Lbb3920
	cmpq $11, %rdi
	jz .Lbb3917
	cmpq $12, %rdi
	jz .Lbb3908
	cmpq $13, %rdi
	jz .Lbb3899
	cmpq $14, %rdi
	jz .Lbb3892
	cmpq $15, %rdi
	jz .Lbb3889
	cmpq $16, %rdi
	jz .Lbb3883
	cmpq $17, %rdi
	jz .Lbb3881
	cmpq $18, %rdi
	setz %r8b
	movzbl %r8b, %r8d
	movl %r8d, -72(%rbp)
	movl %r15d, %r8d
	movq %r8, -128(%rbp)
	cmpq $1, %r8
	setz %r8b
	movzbl %r8b, %r8d
	movl %r8d, %r11d
	movq %r11, -176(%rbp)
	movq -64(%rbp), %r8
	movl -304(%rbp), %r11d
	cmpl $0, -72(%rbp)
	jnz .Lbb3871
	cmpq $19, %rdi
	jz .Lbb3868
	cmpq $20, %rdi
	jz .Lbb3859
	cmpq $21, %rdi
	jz .Lbb3856
	cmpq $22, %rdi
	jz .Lbb3850
	cmpq $23, %rdi
	setz %r11b
	movzbl %r11b, %r11d
	cmpl $0, %r11d
	jnz .Lbb3839
	cmpq $24, %rdi
	jz .Lbb3830
	cmpq $25, %rdi
	jz .Lbb3827
	cmpq $26, %rdi
	jz .Lbb3824
	cmpq $27, %rdi
	jz .Lbb3814
	cmpq $28, %rdi
	setz %r11b
	movzbl %r11b, %r11d
	movl %r11d, -292(%rbp)
	movq -176(%rbp), %r11
	cmpl $0, -292(%rbp)
	jnz .Lbb3805
	cmpq $29, %rdi
	jz .Lbb3802
	cmpq $30, %rdi
	jz .Lbb3786
	cmpq $31, %rdi
	jz .Lbb3783
	movl %r9d, %r9d
	movq %r9, -120(%rbp)
	cmpq $32, %rdi
	jz .Lbb3774
	movl %ecx, %ecx
	movq %rcx, -88(%rbp)
	cmpq $33, %rdi
	jz .Lbb3764
	cmpq $34, %rdi
	jz .Lbb3761
	movq %r10, -568(%rbp)
	movq $1099511627775, %rax
	cmpq %rax, %r10
	jbe .Lbb3757
	leaq -568(%rbp), %rdx
	movl $170, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor1
	movq -416(%rbp), %rsi
	movq -208(%rbp), %rdx
	movq -88(%rbp), %rcx
	movq %rax, -104(%rbp)
	jmp .Lbb3759
.Lbb3757:
	movq $72244511014649856, %rax
	orq %r10, %rax
	movq %rax, -104(%rbp)
.Lbb3759:
	movl %ecx, %eax
	addl $1, %eax
	movl %eax, %eax
	movq %rax, -96(%rbp)
	movq %rdx, -568(%rbp)
	movq %rsi, -560(%rbp)
	leaq -568(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r15, %rsi
	movq %r14, %rdi
	movq -456(%rbp), %r15
	movq -424(%rbp), %rcx
	movq -272(%rbp), %r14
	movq -96(%rbp), %rdx
	movq %rdi, -568(%rbp)
	movq %rsi, -560(%rbp)
	movq %rdx, -552(%rbp)
	movq %rcx, -544(%rbp)
	movq %rax, -536(%rbp)
	movl $5, %ecx
	leaq -568(%rbp), %rdx
	movl $171, %esi
	movq %rbx, %rdi
	callq p111_rt_ctor
	movq %rax, %rcx
	movq %r15, %rax
	movq -104(%rbp), %r15
	movq %rcx, -568(%rbp)
	movq %rax, -560(%rbp)
	leaq -568(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r15, -568(%rbp)
	movq %rax, -560(%rbp)
	leaq -568(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r14, %r8
	xchgq %rax, %r13
	movl $0, %edi
	movq %r12, %r14
	movq %r13, %r12
	movq %r8, %r13
	movl $0, %r15d
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3761:
	xchgq %rax, %r14
	xchgq %r13, %rax
	movq %r15, -584(%rbp)
	movq %rax, -576(%rbp)
	leaq -584(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r15
	movl $0, %edi
	movq %r15, %rax
	xchgq %r14, %r12
	movl $0, %r15d
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3764:
	xchgq %rax, %r14
	xchgq %r13, %rax
	cmpq $1, %r10
	setz %dl
	movzbl %dl, %edx
	movq %r10, %rsi
	shrq $40, %rsi
	andq $8388607, %rsi
	cmpq $65538, %rsi
	setz %sil
	movzbl %sil, %esi
	orl %esi, %edx
	jnz .Lbb3771
	xorl $1, %edx
	jz .Lbb3769
	addl %r9d, %ecx
	movl %ecx, %ecx
	movq %rax, %rdx
	leaq -528(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_101_100_103_101_
	movq %r15, %rax
	movq -384(%rbp), %rcx
	movq -424(%rbp), %r15
	movq -416(%rbp), %rsi
	movq -208(%rbp), %rdx
	movq -272(%rbp), %r8
	movq -528(%rbp), %rdi
	movq -520(%rbp), %r10
	xchgq %r13, %rax
	xchgq %r12, %r13
	xchgq %r14, %r12
	xchgq %rcx, %r15
	movq %rsi, %r9
	movq %rdx, %rsi
	movq %r8, %rdx
	movq %rdi, -272(%rbp)
	movl $35, %edi
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3769:
	movq %rax, %rdx
	movq %r15, %r14
	movq -208(%rbp), %r15
	movq %rbx, %rdi
	movq %rdx, %rsi
	movq %rdi, %rbx
	callq p111_rt_sink
	movq %rbx, %rdi
	movq -464(%rbp), %rbx
	movq %r12, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r13, %rdx
	movq %r12, %rdi
	movq %rdx, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r14, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r15, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4008
.Lbb3771:
	xchgq %rax, %r15
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_99_95_99_108_101_97_114_
	movq %rax, -112(%rbp)
	movq -208(%rbp), %rdx
	movq -272(%rbp), %r8
	movq %r8, -600(%rbp)
	movq %rdx, -592(%rbp)
	leaq -600(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %rsi
	movq $72076285735600128, %rdx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_110_116_95_114_101_118_101_114_115_101_
	movq %rax, %r8
	movq %r15, %rax
	movq -112(%rbp), %rcx
	movq %rax, %rdx
	leaq -528(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_101_109_105_116_
	movq -528(%rbp), %r15
	movq -520(%rbp), %rax
	movl $34, %edi
	xchgq %r13, %rax
	xchgq %r12, %r13
	xchgq %r14, %r12
	xchgq %r15, %r14
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3774:
	xchgq %rax, %r14
	xchgq %r13, %rax
	movq %r8, %rcx
	cmpq $17, %rcx
	jz .Lbb3781
	cmpq $18, %rcx
	jnz .Lbb3779
	leaq -616(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take2
	movq -384(%rbp), %rcx
	movq -424(%rbp), %rax
	movq -416(%rbp), %rsi
	movq -208(%rbp), %rdx
	movq -120(%rbp), %r9
	movq -616(%rbp), %rdi
	movq -608(%rbp), %r8
	movl %esi, %r10d
	cmpq %r9, %r10
	setz %r9b
	movzbl %r9b, %r9d
	movl %r9d, %r10d
	movq %rax, %r9
	movq %r14, %rax
	movq %r13, %r14
	movq %r12, %r13
	movq %r8, %r12
	movq %rdi, -272(%rbp)
	movl $33, %edi
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3779:
	movq %rbx, %rdi
	movq -464(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4008
.Lbb3781:
	movq %r13, %rdx
	movq %r15, %r14
	movq -208(%rbp), %r15
	movq %rbx, %rdi
	movq -464(%rbp), %rbx
	movq %rdx, %rsi
	movq %rdi, %r13
	callq p111_rt_sink
	movq %r14, %rdx
	movq %r13, %rdi
	movq %rdx, %rsi
	movq %rdi, %r13
	callq p111_rt_sink
	movq %r13, %rdi
	movq %r15, %rsi
	movq %rdi, %r13
	callq p111_rt_sink
	movq %r13, %rdi
	movq %r12, %rsi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_102_97_105_108_
	movq %rax, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4008
.Lbb3783:
	xchgq %rax, %r14
	xchgq %r13, %rax
	movq %r15, -632(%rbp)
	movq %rax, -624(%rbp)
	leaq -632(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r15
	movl $0, %edi
	movq %r15, %rax
	xchgq %r14, %r12
	movl $0, %r15d
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3786:
	xchgq %rax, %r14
	xchgq %r13, %rax
	movq %r8, %rcx
	movq %r11, %rdx
	cmpq $17, %rcx
	jz .Lbb3800
	cmpq $18, %rcx
	jnz .Lbb3798
	movq %rdx, %r15
	leaq -688(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take2
	movq %r15, %rdx
	movq -128(%rbp), %rax
	movq -688(%rbp), %r15
	movq -680(%rbp), %rcx
	movq %rcx, -136(%rbp)
	cmpq $1, %rdx
	setz %cl
	movzbl %cl, %ecx
	shrq $40, %rdx
	andq $8388607, %rdx
	cmpq $65538, %rdx
	setz %dl
	movzbl %dl, %edx
	orl %edx, %ecx
	jnz .Lbb3794
	xorl $1, %ecx
	jnz .Lbb3793
	movl $4, %esi
	movq %rbx, %rdi
	callq p111_rt_fail
	movq %r15, %rax
	movl $0, %ecx
	jmp .Lbb3796
.Lbb3793:
	subl $1, %eax
	movl %eax, %esi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_85_51_50_46_115_104_111_119_
	movq %rax, %rcx
	movq %r15, %rax
	movq $144142675918017308, %rdx
	movq %rdx, -688(%rbp)
	movq %rcx, -680(%rbp)
	movq $0, -672(%rbp)
	movq $0, -664(%rbp)
	movq %rax, %r15
	movq $72076285735600128, %rax
	movq %rax, -656(%rbp)
	movq $0, -648(%rbp)
	movq $0, -640(%rbp)
	movl $7, %ecx
	leaq -688(%rbp), %rdx
	movl $161, %esi
	movq %rbx, %rdi
	callq p111_rt_ctor
	movq %rax, %rcx
	movq %r15, %rax
	jmp .Lbb3796
.Lbb3794:
	movq %r15, %rax
	movq $144292209499394829, %rcx
.Lbb3796:
	movq %rcx, %r15
	movq %rax, -688(%rbp)
	movq $72076285735600128, %rax
	movq %rax, -680(%rbp)
	leaq -688(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r15, %rcx
	movq %rax, %r8
	movq %r12, %r15
	movq -136(%rbp), %r12
	movq %r15, %rdx
	leaq -528(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_101_109_105_116_
	movq %r12, %rax
	movq -528(%rbp), %r12
	movq -520(%rbp), %r15
	movl $31, %edi
	xchgq %rax, %r13
	xchgq %r14, %r12
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3798:
	movq %rbx, %rdi
	movq -464(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4008
.Lbb3800:
	movq %r13, %r14
	movq %rbx, %rdi
	movq -464(%rbp), %rbx
	movq %r14, %rsi
	movq %rdi, %r13
	callq p111_rt_sink
	movq %r13, %rdi
	movq %r12, %rsi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_102_97_105_108_
	movq %rax, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4008
.Lbb3802:
	xchgq %rax, %r14
	xchgq %r13, %rax
	xchgq %r12, %r15
	movq %r12, -704(%rbp)
	movq %rax, -696(%rbp)
	leaq -704(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r12
	movl $0, %edi
	movq %r12, %rax
	movq %r14, %r12
	movq %r15, %r14
	movl $0, %r15d
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3805:
	xchgq %rax, %r14
	xchgq %r13, %rax
	xchgq %r12, %r15
	movq %r8, %rcx
	cmpq $17, %rcx
	jz .Lbb3812
	cmpq $18, %rcx
	jnz .Lbb3810
	leaq -720(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take2
	movq -720(%rbp), %rax
	movq -712(%rbp), %rcx
	movq %rcx, -144(%rbp)
	movq %rax, -720(%rbp)
	movq $72076285735600128, %rax
	movq %rax, -712(%rbp)
	leaq -720(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r12, %rcx
	movq -144(%rbp), %r12
	movq %rcx, -720(%rbp)
	movq %rax, -712(%rbp)
	leaq -720(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r8
	movq $144292209499394846, %rcx
	movq %r15, %rdx
	leaq -528(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_101_109_105_116_
	movq %r13, %rax
	movq -528(%rbp), %r13
	movq -520(%rbp), %r15
	movl $29, %edi
	xchgq %r12, %r13
	xchgq %r14, %r12
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3810:
	movq %rbx, %rdi
	movq -464(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4008
.Lbb3812:
	movq %r15, %r12
	movq %r13, %r14
	movq %rbx, %rdi
	movq -464(%rbp), %rbx
	movq %r14, %rsi
	movq %rdi, %r13
	callq p111_rt_sink
	movq %r13, %rdi
	movq %r12, %rsi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_102_97_105_108_
	movq %rax, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4008
.Lbb3814:
	xchgq %rax, %r14
	xchgq %r12, %r15
	xchgq %r13, %r12
	movq %rax, -736(%rbp)
	movq $1099511627775, %rdx
	cmpq %rdx, %rax
	jbe .Lbb3817
	leaq -736(%rbp), %rdx
	movl $173, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor1
	movq -384(%rbp), %rcx
	jmp .Lbb3818
.Lbb3817:
	movq $72247809549533184, %rdx
	orq %rdx, %rax
.Lbb3818:
	movq %rax, -152(%rbp)
	movq %rcx, -736(%rbp)
	movq $1099511627775, %rdx
	cmpq %rdx, %rcx
	jbe .Lbb3820
	leaq -736(%rbp), %rdx
	movl $174, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor1
	movq %rax, %rcx
	movq %r14, %rax
	movq -152(%rbp), %r14
	jmp .Lbb3822
.Lbb3820:
	xchgq %rax, %r14
	movq $72248909061160960, %rdx
	orq %rdx, %rcx
.Lbb3822:
	movq %rcx, -736(%rbp)
	movq %rax, -728(%rbp)
	leaq -736(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r14, -736(%rbp)
	movq %rax, -728(%rbp)
	leaq -736(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r14
	movl $0, %edi
	movq %r12, %rax
	movq %r14, %r12
	movq %r15, %r14
	movl $0, %r15d
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3824:
	xchgq %r12, %r15
	xchgq %r13, %r12
	movq %rcx, %rax
	movq %rax, -752(%rbp)
	movq $72076285735600128, %rax
	movq %rax, -744(%rbp)
	leaq -752(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r8
	movq %r13, %rax
	movq -456(%rbp), %r13
	movq $144292209499394853, %rcx
	movq %rax, %rdx
	leaq -528(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_101_109_105_116_
	movq %r12, %rax
	movq -528(%rbp), %r12
	movq -520(%rbp), %rcx
	movl $27, %edi
	xchgq %rax, %r13
	xchgq %r15, %r12
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3827:
	xchgq %r13, %rax
	xchgq %r12, %r15
	movq %r12, -768(%rbp)
	movq %rax, -760(%rbp)
	leaq -768(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r12
	movl $0, %edi
	movq %r12, %rax
	movq %r13, %r12
	movq %r14, %r13
	movq %r15, %r14
	movl $0, %r15d
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3830:
	xchgq %r13, %rax
	xchgq %r12, %r15
	movq %r8, %rcx
	cmpq $24, %rcx
	jz .Lbb3837
	cmpq $25, %rcx
	jnz .Lbb3835
	leaq -784(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take2
	movq -784(%rbp), %rsi
	movq -776(%rbp), %rax
	movq %rax, -160(%rbp)
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_67_104_97_114_46_116_111_95_117_51_50_
	movq %rax, %rcx
	movq %r15, %rax
	movq -160(%rbp), %r15
	movq %rax, %rdx
	leaq -528(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_99_95_119_111_114_100_95_101_109_105_116_
	movq -528(%rbp), %rax
	movq -520(%rbp), %rcx
	movl $26, %edi
	xchgq %r12, %rax
	xchgq %r14, %r12
	xchgq %r15, %r14
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3835:
	movq %rbx, %rdi
	movq -464(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4008
.Lbb3837:
	movq $72076285735600128, %r8
	movq $144292209499394860, %rcx
	movq %r15, %rdx
	leaq -528(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_101_109_105_116_
	movq %r12, %rax
	movq -528(%rbp), %r12
	movq -520(%rbp), %r15
	movl $25, %edi
	xchgq %r14, %r12
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3839:
	movq %r12, %r14
	xchgq %r13, %r15
	xchgq %rax, %r13
	movq %rcx, %r12
	movq %r9, %rcx
	movq %rax, -800(%rbp)
	movq $1099511627775, %rdx
	cmpq %rdx, %rax
	jbe .Lbb3842
	leaq -800(%rbp), %rdx
	movl $170, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor1
	movq %r12, %rcx
	movq -424(%rbp), %r12
	jmp .Lbb3844
.Lbb3842:
	xchgq %r12, %rcx
	movq $72244511014649856, %rdx
	orq %rdx, %rax
.Lbb3844:
	movq %rax, -168(%rbp)
	movq %rcx, -800(%rbp)
	movq $1099511627775, %rdx
	cmpq %rdx, %rcx
	jbe .Lbb3846
	leaq -800(%rbp), %rdx
	movl $172, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor1
	movq %rax, %rcx
	movq %r14, %rax
	movq -168(%rbp), %r14
	jmp .Lbb3848
.Lbb3846:
	xchgq %rax, %r14
	movq $72246710037905408, %rdx
	orq %rdx, %rcx
.Lbb3848:
	movq %rcx, -800(%rbp)
	movq %rax, -792(%rbp)
	leaq -800(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r14, -800(%rbp)
	movq %rax, -792(%rbp)
	leaq -800(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r12, %rdx
	movq %rax, %r12
	movl $0, %edi
	movq %r13, %rax
	movq %r15, %r13
	movq %rdx, %r14
	movl $0, %r15d
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3850:
	xchgq %r13, %r15
	xchgq %rax, %r13
	movq %rax, %rcx
	shrq $40, %rcx
	andq $65535, %rcx
	cmpq $176, %rcx
	jnz .Lbb3854
	leaq -824(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take3
	movq -824(%rbp), %rax
	movq -816(%rbp), %rcx
	movq -808(%rbp), %rdx
	movl $23, %edi
	xchgq %r14, %r13
	xchgq %r12, %rax
	xchgq %r15, %r12
	movq %rdx, %r9
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3854:
	movq %rbx, %rdi
	movq -464(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4008
.Lbb3856:
	xchgq %r13, %r15
	xchgq %rax, %r13
	movq %r13, %r9
	movl $1, %r8d
	movq %rax, %rcx
	movq %r14, %rdx
	leaq -528(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_99_95_115_117_99_99_95_115_99_97_110_
	movq %r12, %rax
	movq -528(%rbp), %r12
	movq -520(%rbp), %r14
	movl $22, %edi
	xchgq %r12, %r14
	xchgq %rax, %r12
	xchgq %r13, %rax
	xchgq %r15, %r13
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3859:
	xchgq %r13, %r15
	xchgq %rax, %r13
	xchgq %r12, %rax
	movq %r9, %rdx
	movl %r11d, %esi
	xorl $1, %esi
	jnz .Lbb3866
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_sink
	movq %r14, %rcx
	movq %r13, %rax
	movq -384(%rbp), %r14
	movq -424(%rbp), %r13
	movl -296(%rbp), %edi
	movl -300(%rbp), %r8d
	movl %r8d, %edx
	orl %edi, %edx
	jz .Lbb3864
	movl $0, %r9d
	movq %rcx, %r8
	movq %rax, %rcx
	movq %r15, %rdx
	leaq -528(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_99_95_107_105_100_
	movq %r14, %rcx
	movq %r13, %rdx
	movq %r12, %rax
	movq -528(%rbp), %r12
	movq -520(%rbp), %r13
	movl $21, %edi
	movq %r12, %r14
	movq %rcx, %r12
	movq %r13, %r15
	movq %rax, %r13
	movq %rdx, %rax
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3864:
	movq %r15, %rdx
	movq %r12, %r15
	movq %r14, %r13
	movq %rbx, %rdi
	movq -464(%rbp), %rbx
	movq %rdx, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r15, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r13, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4008
.Lbb3866:
	xchgq %r13, %r12
	xchgq %r15, %r13
	xchgq %r14, %r15
	xchgq %rax, %r14
	movl $9, %edi
	xchgq %r12, %rax
	xchgq %r14, %r12
	xchgq %r15, %r14
	movq %rdx, %r9
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3868:
	xchgq %r14, %r15
	xchgq %r12, %r14
	xchgq %rax, %r12
	movq %rax, -840(%rbp)
	movq %r14, -832(%rbp)
	leaq -840(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r13, %rcx
	xchgq %rax, %r12
	movl $0, %edi
	movq %r15, %r13
	movq %rax, %r14
	movq %r12, %rax
	movq %rcx, %r12
	movl $0, %r15d
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3871:
	xchgq %r13, %rcx
	xchgq %r15, %r13
	xchgq %r14, %r15
	movq %r9, %rdx
	movq -80(%rbp), %rdi
	cmpq $1, %rcx
	setz %cl
	movzbl %cl, %ecx
	andq $8388607, %rdi
	cmpq $65538, %rdi
	setz %dil
	movzbl %dil, %edi
	orl %edi, %ecx
	jnz .Lbb3878
	xorl $1, %ecx
	jz .Lbb3876
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %rdx
	movq %rdx, -184(%rbp)
	movq %rdx, %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_115_104_97_112_101_95_110_97_109_101_
	movq %rax, %rsi
	movq $144142675918016930, %rdx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq %rax, %rsi
	movq -176(%rbp), %rdx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_66_111_111_108_46_97_110_100_
	movq %rax, %rsi
	movq %r13, %rax
	movq -424(%rbp), %r13
	movq -208(%rbp), %rcx
	movq -184(%rbp), %rdx
	movl $20, %edi
	xchgq %rax, %r14
	xchgq %r15, %rax
	movq %rcx, %r9
	movq %r13, %rcx
	movq %r12, %r13
	movq %rdx, %r12
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3876:
	movq %rbx, %rdi
	movq -464(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4008
.Lbb3878:
	movq %r12, %r15
	movq %rdx, %r13
	movq %rsi, %r12
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_sink
	movq %r12, %rdi
	movq -208(%rbp), %r12
	movq %rdi, %rcx
	movq %r15, %rdx
	leaq -528(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_99_95_119_111_114_100_95_101_109_105_116_
	movq %r14, %rcx
	movq %r13, %rdx
	movq %r12, %rsi
	movq -528(%rbp), %r12
	movq -520(%rbp), %r13
	movl $19, %edi
	movq %rsi, %rax
	movq %r12, %r14
	movq %rdx, %r12
	movq %r13, %r15
	movq %rcx, %r13
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3881:
	xchgq %r14, %r15
	xchgq %r12, %r14
	movq %rsi, %rdi
	movq %rdx, %rsi
	movq %r9, %rdx
	xchgq %r14, %rax
	movq %rcx, %r9
	movq %r12, %rcx
	movq %r13, %r12
	movq %rdx, %r13
	movq %rsi, %rdx
	movq %rdi, %rsi
	movl $18, %edi
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3883:
	xchgq %r14, %r15
	xchgq %r12, %r14
	movq %r9, %rax
	movq %rax, %rcx
	shrq $40, %rcx
	andq $65535, %rcx
	cmpq $175, %rcx
	jnz .Lbb3887
	leaq -864(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take3
	movq -456(%rbp), %rax
	movq -384(%rbp), %rcx
	movq -864(%rbp), %rdx
	movq -856(%rbp), %rsi
	movq -848(%rbp), %rdi
	xchgq %r14, %rax
	xchgq %r13, %r12
	xchgq %rcx, %r13
	movq %rdx, %r9
	movq %rdi, %rdx
	movl $17, %edi
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3887:
	movq %rbx, %rdi
	movq -464(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4008
.Lbb3889:
	xchgq %r14, %r15
	xchgq %r12, %r14
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %r14, %rcx
	movq %rax, %rdx
	movq %r13, %rax
	movq -384(%rbp), %r14
	movq -424(%rbp), %r13
	movq -416(%rbp), %rdi
	movq %rdx, -192(%rbp)
	subq $16, %rsp
	movq %rsp, %rsi
	movq %rdi, 8(%rsi)
	movq %r12, 0(%rsi)
	movq %r15, %r9
	movq %rdx, %r8
	movq %rax, %rdx
	leaq -528(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_99_95_100_101_99_111_100_101_
	movq %r14, %rcx
	movq %r13, %rdx
	movq -192(%rbp), %r13
	subq $-16, %rsp
	movq -528(%rbp), %r14
	movq -520(%rbp), %rax
	movl $16, %edi
	xchgq %rcx, %r14
	movq %rax, %r9
	movq %r12, %rax
	movq %r15, %r12
	movq %rdx, %r15
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3892:
	xchgq %r14, %r15
	xchgq %r12, %r14
	movq %rdx, %rax
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_sink
	movq -456(%rbp), %rax
	movq -384(%rbp), %rcx
	movq -424(%rbp), %rdx
	movq -416(%rbp), %rsi
	movq -272(%rbp), %r8
	cmpq $1, %r8
	setz %dil
	movzbl %dil, %edi
	shrq $40, %r8
	andq $8388607, %r8
	cmpq $65538, %r8
	setz %r8b
	movzbl %r8b, %r8d
	orl %r8d, %edi
	jnz .Lbb3898
	xorl $1, %edi
	jz .Lbb3896
	movl $9, %edi
	movq %rsi, %r14
	movq %r12, %r9
	movq %rcx, %r12
	movq %r15, %rcx
	movq %rax, %r15
	movq %rdx, %rax
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3896:
	movq %r13, %rdx
	movq %rax, %r12
	movq %r15, %r14
	movq %rcx, %r13
	movq %rbx, %rdi
	movq -464(%rbp), %rbx
	movq %rdx, %rsi
	movq %rdi, %r15
	callq p111_rt_sink
	movq %r15, %rdi
	movq %r12, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r14, %rdx
	movq %r12, %rdi
	movq %rdx, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r13, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4008
.Lbb3898:
	movl $15, %edi
	xchgq %rcx, %rax
	movq %r15, %r9
	movq %rsi, %r15
	movq %r12, %rsi
	movq %r14, %r12
	movq %rdx, %r14
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3899:
	xchgq %r14, %r15
	xchgq %r12, %r14
	movq %rcx, %rsi
	movq %rbx, %rdi
	callq p111_rt_sink
	movq -208(%rbp), %rax
	movq -200(%rbp), %rdx
	cmpq $1, %rdx
	setz %cl
	movzbl %cl, %ecx
	shrq $40, %rdx
	andq $8388607, %rdx
	cmpq $65538, %rdx
	setz %dl
	movzbl %dl, %edx
	orl %edx, %ecx
	jnz .Lbb3906
	xorl $1, %ecx
	jz .Lbb3904
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %rsi
	movq -272(%rbp), %rcx
	movq -240(%rbp), %r10
	movq -216(%rbp), %r8
	movq -280(%rbp), %rax
	movq -224(%rbp), %r9
	movq -232(%rbp), %r11
	movq %rsi, -248(%rbp)
	movq %rsi, -920(%rbp)
	movq %rcx, -912(%rbp)
	movq %r10, -904(%rbp)
	movq %r8, -896(%rbp)
	movq %rax, -888(%rbp)
	movq %r9, -880(%rbp)
	movq %r11, -872(%rbp)
	movl $7, %ecx
	leaq -920(%rbp), %rdx
	movl $161, %esi
	movq %rbx, %rdi
	callq p111_rt_ctor
	movq %rax, -256(%rbp)
	movq -248(%rbp), %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %rcx
	movq %rcx, -264(%rbp)
	movq $144142675917963894, %rdx
	movq %rcx, %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq %rax, %rdi
	movq -456(%rbp), %rax
	movq -424(%rbp), %rdx
	movq -416(%rbp), %rsi
	movq -256(%rbp), %r8
	movq -264(%rbp), %rcx
	xchgq %r14, %r12
	xchgq %r15, %r14
	movq %rdx, %r9
	movq %rcx, %rdx
	movq %r8, %rcx
	movq %rdi, -272(%rbp)
	movl $14, %edi
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3904:
	movq %r13, %rdx
	movq -456(%rbp), %r12
	movq %r15, %r13
	movq %rax, %r15
	movq -272(%rbp), %r14
	movq %rbx, %rdi
	movq %rdx, %rsi
	movq %rdi, %rbx
	callq p111_rt_sink
	movq %r12, %rdx
	movq %rbx, %rdi
	movq -280(%rbp), %rsi
	movq %rsi, %r12
	movq %rdx, %rsi
	movq %rdi, %rbx
	callq p111_rt_sink
	movq %r13, %rdx
	movq %r12, %rsi
	movq %rbx, %rdi
	movq -464(%rbp), %rbx
	movq %rsi, %r13
	movq %rdx, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r15, %rdx
	movq %r13, %rsi
	movq %r12, %rdi
	movq %rsi, %r13
	movq %rdx, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r13, %rsi
	movq %r12, %rdi
	movq %rsi, %r13
	movq %r14, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r13, %rsi
	movq %r12, %rdi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4008
.Lbb3906:
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_sink
	movq -272(%rbp), %rax
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_sink
	movq -280(%rbp), %rax
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_sink
	movq %r14, %rax
	movq -456(%rbp), %r14
	movq %rax, -920(%rbp)
	movq %r15, -912(%rbp)
	leaq -920(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	xchgq %rax, %r14
	movl $0, %edi
	xchgq %rax, %r12
	xchgq %r14, %rax
	movl $0, %r15d
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3908:
	xchgq %r14, %r15
	xchgq %r12, %r14
	movq %r9, %rdx
	movq %rsi, -960(%rbp)
	movq $1099511627775, %rdi
	cmpq %rdi, %rsi
	jbe .Lbb3912
	leaq -960(%rbp), %rdx
	movl $170, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor1
	movq %r14, %rcx
	movq %r13, %rdx
	movq %rax, %rsi
	movq -456(%rbp), %rax
	movq -384(%rbp), %r14
	movq -424(%rbp), %r13
	movq %rsi, -288(%rbp)
	jmp .Lbb3915
.Lbb3912:
	xchgq %r14, %rcx
	xchgq %r13, %rdx
	movq $72244511014649856, %rdi
	orq %rdi, %rsi
	movq %rsi, -288(%rbp)
.Lbb3915:
	movq %rdx, -960(%rbp)
	movq %rcx, -952(%rbp)
	movq $1, -944(%rbp)
	movq %rax, -936(%rbp)
	movq $72076285735600128, %rax
	movq %rax, -928(%rbp)
	movl $5, %ecx
	leaq -960(%rbp), %rdx
	movl $171, %esi
	movq %rbx, %rdi
	callq p111_rt_ctor
	movq %rax, %rcx
	movq %r15, %rax
	movq -288(%rbp), %r15
	movq %rcx, -960(%rbp)
	movq %rax, -952(%rbp)
	leaq -960(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r15, -960(%rbp)
	movq %rax, -952(%rbp)
	leaq -960(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r14, %rdx
	movq %r13, %rsi
	xchgq %rax, %r12
	movl $0, %edi
	movq %rsi, %r13
	movq %rdx, %r14
	movl $0, %r15d
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3917:
	xchgq %r12, %r14
	xchgq %rax, %r15
	movq %rax, -976(%rbp)
	movq %r14, -968(%rbp)
	leaq -976(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	xchgq %rax, %r13
	movl $0, %edi
	xchgq %r12, %r13
	xchgq %rax, %r12
	movq %r15, %r14
	movl $0, %r15d
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3920:
	xchgq %rax, %r15
	xchgq %r13, %rax
	xchgq %r12, %r13
	xchgq %r14, %r12
	movq %rcx, %rdx
	movq %r9, %rsi
	movl -304(%rbp), %ecx
	movl %r11d, %edi
	orl %r8d, %edi
	jnz .Lbb3927
	xorl $1, %ecx
	jz .Lbb3925
	movq %r15, %rcx
	movq %rax, %rdx
	leaq -528(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_101_100_103_101_
	movq %r14, %rcx
	movq %r13, %rax
	movq -384(%rbp), %r13
	movq -424(%rbp), %r14
	movq -528(%rbp), %rdx
	movq -520(%rbp), %rsi
	movl $12, %edi
	xchgq %rax, %r13
	xchgq %r12, %rax
	xchgq %r15, %r12
	xchgq %rcx, %r14
	movq %rdx, %r9
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3925:
	movq %rax, %rdx
	movq %r13, %r12
	movq %r14, %r15
	movq -384(%rbp), %r13
	movq %rbx, %rdi
	movq -464(%rbp), %rbx
	movq %rdx, %rsi
	movq %rdi, %r14
	callq p111_rt_sink
	movq %r14, %rdi
	movq %r12, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r15, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r13, %rcx
	movq %r12, %rdi
	movq %rcx, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4008
.Lbb3927:
	movq %rax, %r15
	movq %r13, %rax
	movq %r14, %r12
	movq %rdx, %r13
	movq %rsi, %r14
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_99_95_99_108_101_97_114_
	movq %rax, %rcx
	movq $72076285735600128, %r8
	movq %r15, %rdx
	leaq -528(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_101_109_105_116_
	movq %r14, %rcx
	movq %r13, %rdx
	movq %r12, %rax
	movq -528(%rbp), %r12
	movq -520(%rbp), %r13
	movl $11, %edi
	movq %r12, %r14
	movq %rdx, %r12
	movq %r13, %r15
	movq %rax, %r13
	movq %rcx, %rax
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3930:
	xchgq %r12, %r14
	xchgq %rax, %r15
	movq %rcx, %rdx
	movq %r9, %rcx
	movq -56(%rbp), %rsi
	movl $10, %edi
	xchgq %r14, %r12
	xchgq %r15, %rax
	movq %rcx, %r9
	movq %rdx, %rcx
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3932:
	xchgq %r12, %r14
	xchgq %rax, %r15
	movq %rax, -992(%rbp)
	movq %r14, -984(%rbp)
	leaq -992(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r14
	movl $0, %edi
	xchgq %r12, %r13
	movq %r14, %rax
	movq %r15, %r14
	movl $0, %r15d
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3935:
	xchgq %r12, %r14
	xchgq %rax, %r15
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_sink
	movq -424(%rbp), %rdx
	movl -296(%rbp), %ecx
	movl -300(%rbp), %eax
	orl %ecx, %eax
	jnz .Lbb3942
	movq %rdx, %rsi
	movq %rbx, %rdi
	callq p111_rt_sink
	movq -384(%rbp), %rdx
	movl -304(%rbp), %eax
	xorl $1, %eax
	jz .Lbb3940
	movq %rdx, %rcx
	movq %r13, %rdx
	leaq -528(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_99_95_119_111_114_100_95_101_109_105_116_
	movq -528(%rbp), %r13
	movq -520(%rbp), %rax
	movl $8, %edi
	xchgq %r14, %r13
	xchgq %r12, %rax
	xchgq %r15, %r12
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3940:
	movq %r13, %rdx
	movq %r14, %r12
	movq %r15, %r13
	movq %rbx, %rdi
	movq -464(%rbp), %rbx
	movq %rdx, %rsi
	movq %rdi, %r14
	callq p111_rt_sink
	movq %r14, %rdi
	movq %r12, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r13, %rdx
	movq %r12, %rdi
	movq %rdx, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4008
.Lbb3942:
	movq %rdx, -1008(%rbp)
	movq $1099511627775, %rax
	cmpq %rax, %rdx
	jbe .Lbb3944
	leaq -1008(%rbp), %rdx
	movl $173, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor1
	jmp .Lbb3945
.Lbb3944:
	movq $72247809549533184, %rax
	orq %rdx, %rax
.Lbb3945:
	movq %rax, -1008(%rbp)
	movq %r14, -1000(%rbp)
	leaq -1008(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	xchgq %rax, %r13
	movl $0, %edi
	movq %r12, %r14
	movq %r13, %r12
	movq %rax, %r13
	movq %r15, %rax
	movl $0, %r15d
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3947:
	xchgq %rax, %r15
	xchgq %r13, %rax
	xchgq %r12, %r13
	xchgq %r14, %r12
	movq %rcx, %rdx
	movq %r8, %rcx
	cmpq $163, %rcx
	jz .Lbb3958
	cmpq $162, %rcx
	jz .Lbb3955
	cmpq $161, %rcx
	jnz .Lbb3953
	movl $7, %ecx
	leaq -1064(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_take
	movq -1064(%rbp), %rsi
	movq -1056(%rbp), %rax
	movq %rax, -312(%rbp)
	movq -1048(%rbp), %r10
	movq %r10, -376(%rbp)
	movq -1040(%rbp), %r8
	movq %r8, -368(%rbp)
	movq -1032(%rbp), %rax
	movq %rax, -320(%rbp)
	movq -1024(%rbp), %r9
	movq %r9, -360(%rbp)
	movq -1016(%rbp), %r11
	movq %r11, -352(%rbp)
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, -328(%rbp)
	movq -312(%rbp), %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, -336(%rbp)
	movq -320(%rbp), %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq -336(%rbp), %rdi
	movq -328(%rbp), %rsi
	movq -352(%rbp), %r11
	movq -360(%rbp), %r9
	movq -368(%rbp), %r8
	movq -376(%rbp), %r10
	movq %rax, -408(%rbp)
	movq %rsi, -1064(%rbp)
	movq %rdi, -1056(%rbp)
	movq %r10, -1048(%rbp)
	movq %r8, -1040(%rbp)
	movq %rax, -1032(%rbp)
	movq %r9, -1024(%rbp)
	movq %r11, -1016(%rbp)
	movl $7, %ecx
	leaq -1064(%rbp), %rdx
	movl $161, %esi
	movq %rbx, %rdi
	callq p111_rt_ctor
	movq %rax, -392(%rbp)
	movq -328(%rbp), %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %rcx
	movq %rcx, -344(%rbp)
	movq $144142675918017354, %rdx
	movq %rcx, %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq %rax, -400(%rbp)
	movq %r15, %rax
	movq -384(%rbp), %r15
	movq -424(%rbp), %rdx
	movq -416(%rbp), %rsi
	movq -336(%rbp), %rdi
	movq -344(%rbp), %rcx
	movq -352(%rbp), %r11
	movq -360(%rbp), %r9
	movq -368(%rbp), %r8
	movq -376(%rbp), %r10
	xchgq %rax, %r12
	movq %rdi, -272(%rbp)
	movl $13, %edi
	movq %r8, -216(%rbp)
	movsd -408(%rbp), %xmm15
	movsd %xmm15, -280(%rbp)
	movq %r9, -224(%rbp)
	movq %rdx, %r9
	movq %rcx, %rdx
	movq -392(%rbp), %rcx
	movq %r11, -232(%rbp)
	movsd -400(%rbp), %xmm15
	movsd %xmm15, -200(%rbp)
	jmp .Lbb3719
.Lbb3953:
	movq %rbx, %rdi
	movq -464(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4008
.Lbb3955:
	movq %rdx, %r15
	movl $7, %ecx
	leaq -1064(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_take
	movq -1064(%rbp), %r9
	movq -1056(%rbp), %r8
	movq -1048(%rbp), %rdi
	movq -1040(%rbp), %rsi
	movq -1032(%rbp), %rdx
	movq -1024(%rbp), %rcx
	movq -1016(%rbp), %rax
	movq %r9, -1064(%rbp)
	movq %r8, -1056(%rbp)
	movq %rdi, -1048(%rbp)
	movq %rsi, -1040(%rbp)
	movq %rdx, -1032(%rbp)
	movq %rcx, -1024(%rbp)
	movq %rax, -1016(%rbp)
	movl $7, %ecx
	leaq -1064(%rbp), %rdx
	movl $162, %esi
	movq %rbx, %rdi
	callq p111_rt_ctor
	movq -424(%rbp), %rdx
	movq -416(%rbp), %rsi
	movl $9, %edi
	movq %r14, %rcx
	movq %rsi, %r14
	movq %r15, %r9
	movq %r12, %r15
	movq %rax, %r12
	movq %rdx, %rax
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3958:
	movq %rdx, %r15
	movl $5, %ecx
	leaq -1064(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_take
	movq -1064(%rbp), %rsi
	movq -1056(%rbp), %rax
	movq %rax, -440(%rbp)
	movq -1048(%rbp), %rdx
	movq %rdx, -432(%rbp)
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, -448(%rbp)
	movq $144142675917973346, %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq %r15, %rcx
	movq %rax, %rsi
	movq -448(%rbp), %r15
	movq -432(%rbp), %rdx
	movq -440(%rbp), %rax
	movl $7, %edi
	xchgq %r14, %rax
	xchgq %rcx, %r14
	movq %rdx, %r9
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3961:
	xchgq %r13, %r15
	xchgq %r12, %r13
	xchgq %r14, %r12
	movq %r9, %rdx
	movl $6, %edi
	xchgq %r15, %r12
	xchgq %rax, %r14
	xchgq %r13, %rax
	xchgq %rcx, %r13
	movq %rdx, %r9
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3963:
	xchgq %r13, %r15
	xchgq %r12, %r13
	xchgq %r14, %r12
	movq %r11, %rdx
	movq %rdx, %rax
	andq $65535, %rax
	cmpq $164, %rax
	jnz .Lbb3967
	leaq -1088(%rbp), %rdx
	movq %rcx, %rsi
	movq %rbx, %rdi
	callq p125_rt_take3
	movq %r15, %rax
	movq -456(%rbp), %r15
	movq -1088(%rbp), %rcx
	movq -1080(%rbp), %rdx
	movq -1072(%rbp), %rsi
	movl $5, %edi
	xchgq %rax, %r12
	xchgq %r13, %rax
	xchgq %r14, %r13
	xchgq %r15, %r14
	movq %rdx, %r9
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3967:
	movq %rbx, %rdi
	movq -464(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4008
.Lbb3969:
	xchgq %rax, %r15
	xchgq %r13, %rax
	xchgq %r12, %r13
	xchgq %r14, %r12
	movq %r13, %rcx
	movq %rax, %rdx
	leaq -528(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_110_111_100_101_
	movq -528(%rbp), %rax
	movq -520(%rbp), %rcx
	movl $4, %edi
	xchgq %r12, %rax
	xchgq %r15, %r12
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3972:
	xchgq %rax, %r15
	xchgq %r13, %rax
	xchgq %r12, %r13
	xchgq %r14, %r12
	movq %r8, %rcx
	cmpq $170, %rcx
	jz .Lbb3988
	cmpq $173, %rcx
	jz .Lbb3986
	cmpq $174, %rcx
	jz .Lbb3984
	cmpq $172, %rcx
	jz .Lbb3982
	cmpq $171, %rcx
	jnz .Lbb3980
	movl $5, %ecx
	leaq -1128(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_take
	movq -1128(%rbp), %rax
	movq -1120(%rbp), %rcx
	movq -1112(%rbp), %rdx
	movq -1104(%rbp), %rsi
	movq -1096(%rbp), %rdi
	xchgq %r12, %rax
	xchgq %r13, %r12
	xchgq %r15, %r13
	movq %rdx, %r9
	movq %rdi, %rdx
	movl $32, %edi
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3980:
	movq %rbx, %rdi
	movq -464(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4008
.Lbb3982:
	leaq -1128(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take1
	movq -1128(%rbp), %rax
	movl $30, %edi
	xchgq %r12, %rax
	xchgq %r13, %r12
	xchgq %r15, %r13
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3984:
	leaq -1128(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take1
	movq -1128(%rbp), %rax
	movl $28, %edi
	xchgq %r12, %rax
	xchgq %r13, %r12
	xchgq %r15, %r13
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3986:
	leaq -1128(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take1
	movq -1128(%rbp), %rax
	movl $24, %edi
	xchgq %r12, %r14
	xchgq %r13, %r12
	xchgq %rax, %r13
	xchgq %r15, %rax
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3988:
	leaq -1128(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take1
	movq %r13, %rax
	movq -1128(%rbp), %r13
	movl $3, %edi
	xchgq %r13, %r12
	xchgq %rax, %r13
	xchgq %r14, %rax
	xchgq %r15, %r14
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3990:
	xchgq %rax, %r15
	xchgq %r12, %rax
	xchgq %r14, %r12
	movq %r11, %rdx
	cmpq $1, %rcx
	setz %cl
	movzbl %cl, %ecx
	andq $8388607, %rdx
	cmpq $65538, %rdx
	setz %dl
	movzbl %dl, %edx
	orl %edx, %ecx
	jnz .Lbb3997
	xorl $1, %ecx
	jz .Lbb3995
	movl %r15d, %ecx
	subl $1, %ecx
	movl %ecx, %r15d
	movl $2, %edi
	xchgq %r12, %r13
	xchgq %r15, %r14
	movl $0, %ecx
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb3995:
	movq %r14, %r15
	movq %r12, %r14
	movq %rax, %r12
	movq %rbx, %rdi
	movq -464(%rbp), %rbx
	movq %r13, %rsi
	movq %rdi, %r13
	callq p111_rt_sink
	movq %r13, %rdi
	movq %r12, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r14, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r15, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4008
.Lbb3997:
	movq %r14, %r15
	movq %r12, %r14
	movq %rax, %r12
	movq %rbx, %rdi
	movq -464(%rbp), %rbx
	movq %r12, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r14, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r15, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r13, %rsi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_102_97_105_108_
	movq %rax, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4008
.Lbb3999:
	xchgq %rax, %r14
	xchgq %r12, %rax
	movq %r8, %r15
	movq %rax, %rcx
	shrq $40, %rcx
	andq $65535, %rcx
	cmpq $17, %rcx
	jz .Lbb4006
	cmpq $18, %rcx
	jnz .Lbb4004
	leaq -1144(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take2
	movq -1144(%rbp), %rax
	movq -1136(%rbp), %rcx
	movl $1, %edi
	xchgq %r12, %rax
	xchgq %r14, %r12
	xchgq %rcx, %r15
	movl $0, %r9d
	movl $0, %esi
	movl $0, %edx
	movq $0, -272(%rbp)
	movl $0, %r10d
	movq $0, -216(%rbp)
	movq $0, -280(%rbp)
	movq $0, -224(%rbp)
	movq $0, -232(%rbp)
	movq $0, -200(%rbp)
	jmp .Lbb3719
.Lbb4004:
	movq %rbx, %rdi
	movq -464(%rbp), %rbx
	movq %r13, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4008
.Lbb4006:
	movq %r14, %rdx
	movq %rbx, %rdi
	movq -464(%rbp), %rbx
	movq %r13, %rcx
	leaq -528(%rbp), %rsi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_109_97_116_99_104_95_56_
	movq -528(%rbp), %rcx
	movq -520(%rbp), %rax
	movq %rcx, (%rbx)
	movq %rax, 8(%rbx)
	movl $0, %eax
.Lbb4008:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type p113d_FID_36_112_49_55_51_115_99_99_46_53_, @function
.size p113d_FID_36_112_49_55_51_115_99_99_46_53_, .-p113d_FID_36_112_49_55_51_115_99_99_46_53_

p113d_FID_36_112_49_55_51_115_99_99_46_50_:
	endbr64
	pushq %rbp
	movq %rsp, %rbp
	subq $472, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movq 72(%rbp), %r10
	movq 64(%rbp), %r12
	movq 56(%rbp), %rbx
	movq 48(%rbp), %r11
	movq 40(%rbp), %rax
	movq 32(%rbp), %r15
	movq 24(%rbp), %r14
	movq 16(%rbp), %r13
	xchgq %r9, %r12
	xchgq %rbx, %rdx
	xchgq %r8, %rbx
	movq %rsi, -240(%rbp)
	movq %rcx, %rsi
	movq %r11, %rcx
	movq %rdx, -176(%rbp)
	movq %r15, %rdx
	movq %r12, %r15
	movq %rbx, %r12
	movq %rdi, %rbx
	movq %r9, -168(%rbp)
	movq %rax, %r9
	movq %r13, %rax
	movq %rsi, %r13
	movq %rcx, %rsi
.p2align 4
.Lbb2959:
	movq %rax, -64(%rbp)
	movq %rdx, -232(%rbp)
	movq %r9, -224(%rbp)
	movq %rsi, -112(%rbp)
	cmpq $0, %r8
	jz .Lbb3044
	cmpq $1, %r8
	jz .Lbb3034
	cmpq $2, %r8
	jz .Lbb3028
	cmpq $3, %r8
	jz .Lbb3025
	cmpq $4, %r8
	setz %cl
	movzbl %cl, %ecx
	movl %ecx, -92(%rbp)
	movl %eax, %ecx
	movl %ecx, %edi
	subl $1, %edi
	movl %edi, -16(%rbp)
	cmpq $1, %r10
	movq %r10, %r11
	setz %r10b
	movzbl %r10b, %r10d
	movl %r10d, -104(%rbp)
	movq %r11, %rdi
	shrq $40, %rdi
	andq $8388607, %rdi
	cmpq $65538, %rdi
	setz %dil
	movzbl %dil, %edi
	movl %edi, -100(%rbp)
	orl %r10d, %edi
	movl %edi, -96(%rbp)
	movl -16(%rbp), %edi
	movl -92(%rbp), %r10d
	movl %edi, %edi
	movq %rdi, -184(%rbp)
	movl %r12d, %edi
	movq %rdi, -136(%rbp)
	cmpl $0, %r10d
	jnz .Lbb3013
	cmpq $5, %r8
	jz .Lbb3001
	cmpq $6, %r8
	jz .Lbb2998
	cmpq $7, %r8
	jz .Lbb2992
	cmpq $8, %r8
	jz .Lbb2989
	movq %r9, %rax
	cmpq $9, %r8
	jz .Lbb2973
	movq %r15, %r12
	movq %rdi, %rax
	movl %r13d, %esi
	addl $1, %esi
	movq %r12, %r15
	movl %esi, %r12d
	orl %ecx, %eax
	movl %eax, %r13d
	movl %r15d, %eax
	subl $1, %eax
	movl %eax, %r15d
	movl $0, %r8d
	movq %r13, %rax
	movq %r14, %r13
	movq %r15, %r14
	movq %r12, %r15
	movq %rdx, %r12
	movl $0, %edx
	movl $0, %r9d
	movl $0, %esi
	movq $0, -176(%rbp)
	movq $0, -168(%rbp)
	movl $0, %r10d
	jmp .Lbb2959
.Lbb2973:
	movq %rsi, %rdx
	cmpq $1, %rdx
	setz %cl
	movzbl %cl, %ecx
	shrq $40, %rdx
	andq $8388607, %rdx
	cmpq $65538, %rdx
	setz %dl
	movzbl %dl, %edx
	movl %ecx, %esi
	orl %edx, %esi
	xorl $1, %esi
	jnz .Lbb2987
	orl %edx, %ecx
	jz .Lbb2985
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_115_104_97_112_101_95_110_97_109_101_
	movq %rax, %rsi
	movq $144142675917972605, %rdx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq %rax, %rsi
	movq -64(%rbp), %rax
	movq -232(%rbp), %rdx
	cmpq $1, %rsi
	setz %cl
	movzbl %cl, %ecx
	shrq $40, %rsi
	andq $8388607, %rsi
	cmpq $65538, %rsi
	setz %sil
	movzbl %sil, %esi
	orl %esi, %ecx
	jnz .Lbb2981
	xorl $1, %ecx
	jnz .Lbb2979
	movl $4, %esi
	movq %rbx, %rdi
	callq p111_rt_fail
	movq %r13, %rax
	movq -64(%rbp), %r13
	movq -232(%rbp), %rdx
	jmp .Lbb2980
.Lbb2979:
	xchgq %r13, %rax
.Lbb2980:
	movq %r14, %rcx
	movl $0, %r14d
	jmp .Lbb2983
.Lbb2981:
	xchgq %r13, %rax
	cmpq $32, %r12
	setb %dil
	movzbl %dil, %edi
	movl %r12d, %ecx
	movl $1, %esi
	shlq %cl, %rsi
	movq %r14, %rcx
	movl $4294967295, %r8d
	andq %r8, %rsi
	cmpl $0, %edi
	movl $0, %edi
	mov %rsi, %r14
	cmovz %rdi, %r14
.Lbb2983:
	movl $1, %r9d
	movq %rdx, %r8
	movq %rax, %rdx
	leaq -304(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_99_95_107_105_100_
	movq -304(%rbp), %rax
	movq -296(%rbp), %rcx
	movl $10, %r8d
	xchgq %r12, %r13
	xchgq %r15, %r12
	xchgq %r14, %rax
	movq %rcx, %rdx
	movl $0, %r9d
	movl $0, %esi
	movq $0, -176(%rbp)
	movq $0, -168(%rbp)
	movl $0, %r10d
	jmp .Lbb2959
.Lbb2985:
	movq %r13, %rsi
	movq %rax, %r13
	movq %rbx, %rdi
	movq -240(%rbp), %rbx
	movq %rsi, %r14
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r13, %rsi
	movq %r12, %rdi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3043
.Lbb2987:
	movq %r13, %r14
	movq %rax, %rsi
	movq -184(%rbp), %r12
	movq %rbx, %rdi
	movq -240(%rbp), %rbx
	movq %rsi, %r9
	movq %rdi, %r13
	callq p111_rt_sink
	movq %r14, %rsi
	movq %r13, %rdi
	movq $0, -328(%rbp)
	movq $0, -320(%rbp)
	movq %r12, -312(%rbp)
	leaq -328(%rbp), %rdx
	movq %rsi, %r12
	movl $175, %esi
	callq p125_rt_ctor3
	movq %r12, %rsi
	movq %rsi, (%rbx)
	movq %rax, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3043
.Lbb2989:
	xchgq %r13, %r14
	xchgq %rax, %r13
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %rdx
	movq %rdx, -56(%rbp)
	movq %rdx, %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %rsi
	movq %rsi, -24(%rbp)
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_115_104_97_112_101_95_116_97_103_
	movq %rax, %rsi
	movq $144142675917963894, %rdx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq %rax, -48(%rbp)
	movq -24(%rbp), %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %rsi
	movq %rsi, -32(%rbp)
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_115_104_97_112_101_95_110_97_109_101_
	movq %rax, %rsi
	movq $144142675917972605, %rdx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq %rax, -40(%rbp)
	movq -32(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_115_104_97_112_101_95_110_97_109_101_
	movq %rax, %rsi
	movq $144142675917964477, %rdx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq -40(%rbp), %rcx
	movq %rcx, -344(%rbp)
	movq %rax, -336(%rbp)
	movl $2, %ecx
	leaq -344(%rbp), %rdx
	movl $68, %esi
	movq %rbx, %rdi
	callq p111_rt_op
	movq %rax, %rdx
	movq -48(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_66_111_111_108_46_97_110_100_
	movq %r13, %rcx
	movq %rax, %rsi
	movq -112(%rbp), %r13
	movq -176(%rbp), %rax
	movq -56(%rbp), %rdx
	movl $9, %r8d
	xchgq %r14, %r13
	movq %rdx, %r9
	movq %rax, %rdx
	movq %rcx, %rax
	movq $0, -176(%rbp)
	movq $0, -168(%rbp)
	movl $0, %r10d
	jmp .Lbb2959
.Lbb2992:
	xchgq %r13, %r14
	movq %r9, %rax
	movq %rax, %rcx
	shrq $40, %rcx
	andq $65535, %rcx
	cmpq $164, %rcx
	jnz .Lbb2996
	leaq -368(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take3
	movq %r13, %rax
	movq -64(%rbp), %rcx
	movq -232(%rbp), %rdx
	movq -368(%rbp), %r13
	movq -360(%rbp), %rsi
	movq -352(%rbp), %rdi
	movl $8, %r8d
	movq %rdi, %r9
	movq %rax, -176(%rbp)
	movq %r15, %rax
	movq %r12, %r15
	movq %r14, %r12
	movq %r13, %r14
	movq %rdx, %r13
	movq %rsi, %rdx
	movq %rcx, %rsi
	movq $0, -168(%rbp)
	movl $0, %r10d
	jmp .Lbb2959
.Lbb2996:
	movq %rbx, %rdi
	movq -240(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3043
.Lbb2998:
	movq %rax, %rcx
	movq %r14, %rax
	movq %r13, %r14
	movq %r9, %r13
	movq %rcx, -392(%rbp)
	movq %rax, -384(%rbp)
	movq %rdx, -376(%rbp)
	leaq -392(%rbp), %rdx
	movl $164, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor3
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_sink
	movq -176(%rbp), %rax
	movq -168(%rbp), %rcx
	movq %rax, %rdx
	leaq -304(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_110_111_100_101_
	movq %r13, %rax
	movq -112(%rbp), %r13
	movq -304(%rbp), %rcx
	movq -296(%rbp), %rdx
	movl $7, %r8d
	xchgq %r14, %r13
	movq %rdx, %r9
	movq %rcx, %rdx
	movl $0, %esi
	movq $0, -176(%rbp)
	movq $0, -168(%rbp)
	movl $0, %r10d
	jmp .Lbb2959
.Lbb3001:
	xchgq %r13, %r14
	movq %rsi, %rax
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_sink
	movq %r13, %rcx
	movq -64(%rbp), %r13
	movq -232(%rbp), %rdx
	movq -224(%rbp), %rax
	movq %rcx, -416(%rbp)
	movq %rdx, -408(%rbp)
	movq %rax, -400(%rbp)
	leaq -416(%rbp), %rdx
	movl $164, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor3
	movq %rax, -72(%rbp)
	movq %r14, %rax
	movq -176(%rbp), %r14
	movq -168(%rbp), %rcx
	movl -96(%rbp), %edi
	movl -100(%rbp), %esi
	movl -104(%rbp), %edx
	xorl $1, %edi
	jnz .Lbb3011
	orl %esi, %edx
	jz .Lbb3009
	movl $0, %r9d
	movq %rcx, %r8
	movq %r14, %rcx
	movq %rax, %rdx
	leaq -304(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_99_95_107_105_100_
	movq -72(%rbp), %rsi
	movq -304(%rbp), %rax
	movq %rax, -88(%rbp)
	movq -296(%rbp), %rdx
	movq %rdx, -80(%rbp)
	movq %rsi, %rax
	shrq $40, %rax
	andq $65535, %rax
	cmpq $164, %rax
	jnz .Lbb3007
	leaq -416(%rbp), %rdx
	movq %rbx, %rdi
	callq p125_rt_take3
	movq %r14, %rax
	movq -168(%rbp), %rcx
	movq -80(%rbp), %rdx
	movq -88(%rbp), %r14
	movq -416(%rbp), %rsi
	movq -408(%rbp), %rdi
	movq -400(%rbp), %r8
	xchgq %r12, %r13
	xchgq %r15, %r12
	movq %rax, %r9
	movq %rsi, %rax
	movq %rcx, %rsi
	movq %r14, -176(%rbp)
	movq %rdi, %r14
	movq %rdx, -168(%rbp)
	movq %r8, %rdx
	movl $6, %r8d
	movl $0, %r10d
	jmp .Lbb2959
.Lbb3007:
	movq %rbx, %rdi
	movq -240(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3043
.Lbb3009:
	movq %rax, %rsi
	movq -72(%rbp), %r13
	movq %rbx, %rdi
	movq -240(%rbp), %rbx
	movq %rsi, %r14
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r13, %rsi
	movq %r12, %rdi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3043
.Lbb3011:
	movq %rax, %r14
	movq -184(%rbp), %r12
	movq -72(%rbp), %rsi
	movq %rbx, %rdi
	movq -240(%rbp), %rbx
	movq %rdi, %r13
	callq p111_rt_sink
	movq %r14, %rsi
	movq %r13, %rdi
	movq $0, -416(%rbp)
	movq $0, -408(%rbp)
	movq %r12, -400(%rbp)
	leaq -416(%rbp), %rdx
	movq %rsi, %r12
	movl $175, %esi
	callq p125_rt_ctor3
	movq %r12, %rsi
	movq %rsi, (%rbx)
	movq %rax, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3043
.Lbb3013:
	movq %r14, %rcx
	movq %r13, %r14
	movq %rax, %r13
	movq %r9, %rax
	movq %rcx, -440(%rbp)
	movq %rdx, -432(%rbp)
	movq %rax, -424(%rbp)
	leaq -440(%rbp), %rdx
	movl $164, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor3
	movq %rax, -144(%rbp)
	movq -112(%rbp), %rax
	movl -96(%rbp), %ecx
	movl -100(%rbp), %esi
	movl -104(%rbp), %edx
	orl %esi, %edx
	jnz .Lbb3023
	xorl $1, %ecx
	jz .Lbb3021
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %rdx
	movq %rdx, -160(%rbp)
	movq %rdx, %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %rsi
	movq %rsi, -120(%rbp)
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_115_104_97_112_101_95_116_97_103_
	movq %rax, %rsi
	movq $144142675917963894, %rdx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq %rax, -128(%rbp)
	movq -120(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_115_104_97_112_101_95_110_97_109_101_
	movq %rax, %rsi
	movq $144142675917963900, %rdx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq %rax, %rdx
	movq -128(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_66_111_111_108_46_97_110_100_
	movq %rax, %rsi
	movq -136(%rbp), %rax
	cmpq $32, %rax
	setb %al
	movzbl %al, %eax
	movl %eax, %edx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_66_111_111_108_46_97_110_100_
	movq %rax, -152(%rbp)
	movq -144(%rbp), %rsi
	movq %rsi, %rax
	shrq $40, %rax
	andq $65535, %rax
	cmpq $164, %rax
	jnz .Lbb3019
	leaq -440(%rbp), %rdx
	movq %rbx, %rdi
	callq p125_rt_take3
	movq -176(%rbp), %rax
	movq -168(%rbp), %rcx
	movq -160(%rbp), %rdx
	movq -152(%rbp), %r10
	movq -440(%rbp), %rsi
	movq -432(%rbp), %rdi
	movq -424(%rbp), %r8
	movq %r8, %r9
	movl $5, %r8d
	movq %rax, -176(%rbp)
	movq %r13, %rax
	movq %r14, %r13
	movq %rsi, %r14
	movq %rdx, %rsi
	movq %rdi, %rdx
	movq %rcx, -168(%rbp)
	jmp .Lbb2959
.Lbb3019:
	movq %rbx, %rdi
	movq -240(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3043
.Lbb3021:
	movq %r14, %rsi
	movq %rax, %r14
	movq -144(%rbp), %r13
	movq %rbx, %rdi
	movq -240(%rbp), %rbx
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r14, %rsi
	movq %r12, %rdi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r13, %rsi
	movq %r12, %rdi
	movq %rsi, %r13
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3043
.Lbb3023:
	movq %rax, %rsi
	movq -144(%rbp), %r13
	movq %rbx, %rdi
	movq -240(%rbp), %rbx
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r13, %rsi
	movq %r12, %rdi
	movq -184(%rbp), %r12
	movq %rdi, %r13
	callq p111_rt_sink
	movq %r14, %rsi
	movq %r13, %rdi
	movq $1, -440(%rbp)
	movq %r15, -432(%rbp)
	movq %r12, -424(%rbp)
	leaq -440(%rbp), %rdx
	movq %rsi, %r12
	movl $175, %esi
	callq p125_rt_ctor3
	movq %r12, %rsi
	movq %rsi, (%rbx)
	movq %rax, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3043
.Lbb3025:
	xchgq %r13, %r14
	xchgq %rax, %r13
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %rcx
	movq %rcx, -216(%rbp)
	movq %rcx, %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %rsi
	movq %rsi, -208(%rbp)
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %rsi
	movq %rsi, -192(%rbp)
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_115_104_97_112_101_95_116_97_103_
	movq %rax, %rsi
	movq $144142675917963894, %rdx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq %rax, -200(%rbp)
	movq -192(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_115_104_97_112_101_95_110_97_109_101_
	movq %rax, %rsi
	movq $144142675917971638, %rdx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq %rax, %rdx
	movq -200(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_66_111_111_108_46_97_110_100_
	movq %rax, %r10
	movq -232(%rbp), %rdx
	movq -224(%rbp), %rax
	movq -208(%rbp), %rsi
	movq -216(%rbp), %rcx
	movl $4, %r8d
	movq %rax, %r9
	movq %rdx, -176(%rbp)
	movq %rax, -168(%rbp)
	movq %r13, %rax
	movq %r14, %r13
	movq %rcx, %r14
	jmp .Lbb2959
.Lbb3028:
	xchgq %r13, %r14
	xchgq %rax, %r13
	movq %rax, %rcx
	shrq $40, %rcx
	andq $65535, %rcx
	cmpq $164, %rcx
	jnz .Lbb3032
	leaq -464(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take3
	movq %r12, %rax
	movq -464(%rbp), %r12
	movq -456(%rbp), %rcx
	movq -448(%rbp), %rdx
	movl $3, %r8d
	xchgq %rax, %r15
	xchgq %r14, %r12
	movq %rdx, %r9
	movq %rcx, %rdx
	movl $0, %esi
	movq $0, -176(%rbp)
	movq $0, -168(%rbp)
	movl $0, %r10d
	jmp .Lbb2959
.Lbb3032:
	movq %rbx, %rdi
	movq -240(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3043
.Lbb3034:
	xchgq %r13, %r14
	xchgq %rax, %r13
	xchgq %r12, %rax
	cmpq $1, %rdx
	setz %cl
	movzbl %cl, %ecx
	shrq $40, %rdx
	andq $8388607, %rdx
	cmpq $65538, %rdx
	setz %dl
	movzbl %dl, %edx
	orl %edx, %ecx
	jnz .Lbb3041
	xorl $1, %ecx
	jz .Lbb3039
	movq %rax, %rcx
	movq %r14, %rdx
	leaq -304(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_110_111_100_101_
	movq %r13, %rax
	movq -304(%rbp), %r13
	movq -296(%rbp), %r14
	movl $2, %r8d
	xchgq %r15, %r13
	xchgq %r12, %r15
	xchgq %rax, %r12
	movl $0, %edx
	movl $0, %r9d
	movl $0, %esi
	movq $0, -176(%rbp)
	movq $0, -168(%rbp)
	movl $0, %r10d
	jmp .Lbb2959
.Lbb3039:
	movq %r14, %rsi
	movq %rbx, %rdi
	movq -240(%rbp), %rbx
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3043
.Lbb3041:
	movq %r14, %rsi
	movq %rbx, %rdi
	movq -240(%rbp), %rbx
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_102_97_105_108_
	movq %rax, (%rbx)
	movq $144307602662183731, %rax
	movq %rax, 8(%rbx)
	movl $0, %eax
.Lbb3043:
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.Lbb3044:
	xchgq %r13, %r14
	xchgq %r12, %r13
	movl %r12d, %ecx
	cmpq $0, %rcx
	setz %cl
	movzbl %cl, %ecx
	movl %ecx, %ecx
	movl $1, %r8d
	xchgq %r13, %r12
	xchgq %r14, %r13
	movq %rcx, %rdx
	movl $0, %r9d
	movl $0, %esi
	movq $0, -176(%rbp)
	movq $0, -168(%rbp)
	movl $0, %r10d
	jmp .Lbb2959
.type p113d_FID_36_112_49_55_51_115_99_99_46_50_, @function
.size p113d_FID_36_112_49_55_51_115_99_99_46_50_, .-p113d_FID_36_112_49_55_51_115_99_99_46_50_
