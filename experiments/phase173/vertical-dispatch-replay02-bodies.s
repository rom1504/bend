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
	jz .Lbb3155
	movq %rbx, %r15
	movq %rdi, %rbx
	xchgq %r12, %r14
	jmp .Lbb3174
.Lbb3155:
	cmpq $1, %rax
	jnz .Lbb3157
	movq %r15, %rax
	movq %r13, %r15
	movq %rbx, %r13
	movq %rdi, %rbx
	jmp .Lbb3178
.Lbb3157:
	cmpq $2, %rax
	jnz .Lbb3159
	movq %r15, %rax
	movq %r13, %r15
	movq %r12, %r13
	movq %r14, %r12
	movq %rbx, %r14
	movq %rdi, %rbx
	jmp .Lbb3182
.Lbb3159:
	cmpq $3, %rax
	jnz .Lbb3161
	movq %rbx, %rax
	movq %rdi, %rbx
	xchgq %r13, %r15
	xchgq %r14, %r13
	xchgq %r12, %r14
	jmp .Lbb3185
.Lbb3161:
	cmpq $4, %rax
	jz .Lbb3163
	movq %r14, %rcx
	movq %r15, %rax
	movq %r12, %r15
	movq %rbx, %r12
	movq %rdi, %rbx
	jmp .Lbb3166
.Lbb3163:
	movq %r13, -24(%rbp)
	movq %r15, %r13
	movq %rbx, %r15
	movq %rdi, %rbx
.p2align 4
.Lbb3164:
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
.Lbb3166:
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
	jnz .Lbb3171
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_sink
	movl %r14d, %eax
	movq -16(%rbp), %r14
	xorl $1, %eax
	jz .Lbb3169
	xchgq %r15, %r14
	xchgq %r12, %r15
	jmp .Lbb3174
.Lbb3169:
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
	jmp .Lbb3197
.Lbb3171:
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
.Lbb3174:
	movq %r15, %rax
	shrq $40, %rax
	andq $65535, %rax
	cmpq $17, %rax
	jz .Lbb3195
	cmpq $18, %rax
	jnz .Lbb3193
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
.Lbb3178:
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
	jnz .Lbb3191
	xorl $1, %ecx
	jz .Lbb3189
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
.Lbb3182:
	movq %rax, %rcx
	shrq $40, %rcx
	andq $65535, %rcx
	cmpq $164, %rcx
	jnz .Lbb3187
	leaq -136(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take3
	movq -136(%rbp), %rax
	movq -128(%rbp), %r10
	movq -120(%rbp), %r8
	xchgq %r15, %rax
	xchgq %r12, %r15
.Lbb3185:
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
	jmp .Lbb3164
.Lbb3187:
	movq %rbx, %rdi
	movq -32(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3197
.Lbb3189:
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
	jmp .Lbb3197
.Lbb3191:
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
	jmp .Lbb3197
.Lbb3193:
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
	jmp .Lbb3197
.Lbb3195:
	movq %rbx, %rdi
	movq -32(%rbp), %rbx
	movq $72076285735600128, %rdx
	movq %r14, %rsi
	callq p113d_FID_36_100_105_114_101_99_116_46_110_116_95_114_101_118_101_114_115_101_
	movq %r13, (%rbx)
	movq %rax, 8(%rbx)
	movl $0, %eax
.Lbb3197:
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
	subq $1400, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	movq 112(%rbp), %rax
	movq %rax, -16(%rbp)
	movq 104(%rbp), %rax
	movq %rax, -24(%rbp)
	movq 96(%rbp), %rax
	movq %rax, -32(%rbp)
	movq 88(%rbp), %rbx
	movq %rbx, -40(%rbp)
	movq 80(%rbp), %r11
	movq %r11, -8(%rbp)
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
	movq %rsi, -704(%rbp)
	movq %r11, %rsi
	cmpq $0, %r9
	setz %r11b
	movzbl %r11b, %r11d
	cmpl $0, %r11d
	movq -8(%rbp), %r11
	jz .Lbb3716
	movq %rbx, %r15
	movq %rdi, %rbx
	movq %r12, %r14
	movq %r13, %r12
	movq %rdx, %r13
	jmp .Lbb3791
.Lbb3716:
	cmpq $1, %r9
	jnz .Lbb3718
	movq %r12, %rax
	movq %r14, %r12
	movq %rbx, %r14
	movq %rdi, %rbx
	xchgq %rdx, %r15
	jmp .Lbb3795
.Lbb3718:
	cmpq $2, %r9
	jnz .Lbb3720
	movq %rdx, %rax
	movq %rbx, %r15
	movq %rdi, %rbx
	xchgq %r12, %r14
	jmp .Lbb3799
.Lbb3720:
	cmpq $3, %r9
	jnz .Lbb3722
	movq %rdx, %rax
	movq %r12, %r15
	movq %rbx, %r12
	movq %rdi, %rbx
	xchgq %r13, %r14
	jmp .Lbb3884
.Lbb3722:
	cmpq $4, %r9
	jnz .Lbb3724
	movq %rdx, -224(%rbp)
	xchgq %r12, %r14
	movq %r15, %rax
	movq %rbx, %r15
	movq %rdi, %rbx
	jmp .Lbb3886
.Lbb3724:
	cmpq $5, %r9
	jnz .Lbb3726
	movq %rdx, %rsi
	movq %rbx, %rdx
	movq %rdi, %rbx
	xchgq %r14, %r15
	xchgq %r13, %rax
	xchgq %r12, %rcx
	jmp .Lbb3889
.Lbb3726:
	cmpq $6, %r9
	jnz .Lbb3728
	movq %r12, -328(%rbp)
	xchgq %r13, %r14
	movq %r15, %r12
	movq %rbx, %r15
	movq %rdi, %rbx
	movq %rax, -592(%rbp)
	movq %rdx, %rax
	movq %rcx, -600(%rbp)
	jmp .Lbb3890
.Lbb3728:
	cmpq $7, %r9
	jnz .Lbb3730
	movq %r13, -672(%rbp)
	movq %rdx, %r13
	movq %r15, -696(%rbp)
	movq %rbx, %r15
	movq %rdi, %rbx
	xchgq %r14, %rax
	movq %rcx, -680(%rbp)
	jmp .Lbb3979
.Lbb3730:
	cmpq $8, %r9
	jnz .Lbb3732
	movq %rbx, %r15
	movq %rdi, %rbx
	xchgq %r12, %r13
	movq %r14, %rax
	movq %rdx, %r14
	jmp .Lbb3983
.Lbb3732:
	cmpq $9, %r9
	jnz .Lbb3734
	movq %rbx, %rcx
	movq %rdi, %rbx
	xchgq %r14, %r15
	xchgq %r12, %rax
	xchgq %r13, %r12
	jmp .Lbb3958
.Lbb3734:
	cmpq $10, %r9
	jnz .Lbb3736
	movq %r13, -608(%rbp)
	movq %r14, %r13
	movq %rax, %r14
	movq %rcx, %rsi
	movq %r12, %rcx
	movq %r15, %r12
	movq %rbx, %r15
	movq %rdi, %rbx
	jmp .Lbb3960
.Lbb3736:
	cmpq $11, %r9
	jnz .Lbb3738
	movq %rbx, %r15
	movq %rdi, %rbx
	xchgq %r12, %r13
	movq %r14, %rax
	movq %rdx, %r14
	jmp .Lbb3975
.Lbb3738:
	cmpq $12, %r9
	jnz .Lbb3740
	movq %r13, -640(%rbp)
	movq %r15, %r13
	xchgq %r12, %rax
	movq %rcx, %r15
	movq %rbx, %rcx
	movq %rdi, %rbx
	jmp .Lbb3964
.Lbb3740:
	cmpq $13, %r9
	jnz .Lbb3742
	movq %rdx, -568(%rbp)
	movq %rbx, -584(%rbp)
	movq %rdi, %rbx
	movq %r12, -560(%rbp)
	movq %r13, %r12
	movq %r14, -576(%rbp)
	movq %rax, -392(%rbp)
	movq %rcx, -400(%rbp)
	movq %rsi, %r14
	movq %r8, %r13
	movq %r10, -344(%rbp)
	movq %r11, -352(%rbp)
	movq -40(%rbp), %rsi
	movsd -32(%rbp), %xmm15
	movsd %xmm15, -360(%rbp)
	movsd -24(%rbp), %xmm15
	movsd %xmm15, -368(%rbp)
	movsd -16(%rbp), %xmm15
	movsd %xmm15, -336(%rbp)
	jmp .Lbb3895
.Lbb3742:
	cmpq $14, %r9
	jnz .Lbb3744
	movq %rbx, -416(%rbp)
	movq %rdi, %rbx
	movq %r14, -424(%rbp)
	movq %r12, %r14
	movq %r15, %r12
	movq %rdx, %r15
	movq %rax, -432(%rbp)
	movq %rcx, -440(%rbp)
	movq %rsi, %rax
	movq %r8, -448(%rbp)
	jmp .Lbb3899
.Lbb3744:
	cmpq $15, %r9
	jnz .Lbb3746
	movq %rdx, -456(%rbp)
	movq %rbx, -464(%rbp)
	movq %rdi, %rbx
	movq %r15, -472(%rbp)
	movq %rax, %r15
	movq %r12, %rax
	movq %r14, %r12
	movq %rcx, %r14
	jmp .Lbb3906
.Lbb3746:
	cmpq $16, %r9
	jnz .Lbb3748
	movq %rdx, -480(%rbp)
	movq %rbx, -488(%rbp)
	movq %rdi, %rbx
	xchgq %r13, %r14
	xchgq %r12, %r15
	jmp .Lbb3908
.Lbb3748:
	cmpq $17, %r9
	jnz .Lbb3750
	xchgq %r14, %rax
	xchgq %r13, %rcx
	xchgq %rbx, %rsi
	xchgq %rdi, %rbx
	xchgq %rdx, %rdi
	xchgq %r12, %rdx
	jmp .Lbb3911
.Lbb3750:
	cmpq $18, %r9
	jnz .Lbb3752
	movq %r13, -496(%rbp)
	xchgq %r14, %r15
	movq %rax, %r13
	movq %r12, %rax
	movq %rcx, -552(%rbp)
	movq %rsi, %r12
	movq %rdx, %rsi
	movq %rbx, %rdx
	movq %rdi, %rbx
	jmp .Lbb3912
.Lbb3752:
	cmpq $19, %r9
	jnz .Lbb3754
	movq %rbx, %r15
	movq %rdi, %rbx
	xchgq %r12, %r13
	movq %r14, %rax
	movq %rdx, %r14
	jmp .Lbb3946
.Lbb3754:
	cmpq $20, %r9
	jnz .Lbb3756
	movq %rcx, %rsi
	movq %r12, %rcx
	movq %r15, %r12
	movq %rax, %r15
	movq %r13, %rax
	movq %r14, %r13
	movq %rdx, %r14
	movq %rbx, %rdx
	movq %rdi, %rbx
	jmp .Lbb3916
.Lbb3756:
	cmpq $21, %r9
	jnz .Lbb3758
	movq %r13, %r15
	movq %rbx, %r13
	movq %rdi, %rbx
	movq %r14, %rax
	movq %rdx, %r14
	jmp .Lbb3920
.Lbb3758:
	cmpq $22, %r9
	jnz .Lbb3760
	movq %r13, %r12
	movq %rbx, %r13
	movq %rdi, %rbx
	movq %r14, %r15
	movq %rdx, %r14
	jmp .Lbb3922
.Lbb3760:
	cmpq $23, %r9
	jnz .Lbb3762
	movq %r12, %r13
	movq %r14, %r12
	movq %rbx, %r14
	movq %rdi, %rbx
	movq %rax, %rcx
	movq %rdx, %rax
	jmp .Lbb3925
.Lbb3762:
	cmpq $24, %r9
	jnz .Lbb3764
	movq %rdx, %rax
	movq %rbx, %r15
	movq %rdi, %rbx
	xchgq %r12, %r14
	jmp .Lbb3859
.Lbb3764:
	cmpq $25, %r9
	jnz .Lbb3766
	movq %rdx, %r15
	xchgq %r12, %r13
	movq %r14, %rax
	movq %rbx, %r14
	movq %rdi, %rbx
	jmp .Lbb3880
.Lbb3766:
	cmpq $26, %r9
	jnz .Lbb3768
	movq %rdx, -208(%rbp)
	xchgq %r12, %r13
	movq %r15, %rax
	movq %r14, %r15
	movq %rbx, %r14
	movq %rdi, %rbx
	jmp .Lbb3863
.Lbb3768:
	cmpq $27, %r9
	jnz .Lbb3770
	movq %rdx, %rax
	movq %r14, %rcx
	movq %r12, %r14
	movq %r13, %r12
	movq %rbx, %r13
	movq %rdi, %rbx
	jmp .Lbb3865
.Lbb3770:
	cmpq $28, %r9
	jnz .Lbb3772
	movq %rdx, %rax
	movq %rbx, %r15
	movq %rdi, %rbx
	xchgq %r12, %r13
	jmp .Lbb3848
.Lbb3772:
	cmpq $29, %r9
	jnz .Lbb3774
	movq %rdx, %r15
	xchgq %r12, %r13
	movq %r14, %rax
	movq %rbx, %r14
	movq %rdi, %rbx
	jmp .Lbb3852
.Lbb3774:
	cmpq $30, %r9
	jnz .Lbb3776
	movq %rdx, %rax
	movq %rbx, %r15
	movq %rdi, %rbx
	xchgq %r12, %r13
	jmp .Lbb3829
.Lbb3776:
	cmpq $31, %r9
	jnz .Lbb3778
	movq %rdx, %r15
	xchgq %r12, %r13
	movq %r14, %rax
	movq %rbx, %r14
	movq %rdi, %rbx
	jmp .Lbb3840
.Lbb3778:
	cmpq $32, %r9
	jnz .Lbb3780
	movq %rbx, -120(%rbp)
	movq %rdi, %rbx
	movq %r12, -104(%rbp)
	movq %r13, -128(%rbp)
	movq %r15, -112(%rbp)
	movq %r14, %r15
	movq %rax, %r13
	movq %rdx, %rax
	movq %rcx, %r12
	movq %rsi, %r14
	jmp .Lbb3806
.Lbb3780:
	cmpq $33, %r9
	jnz .Lbb3782
	movq %r12, -168(%rbp)
	movq %r13, %r12
	movq %rbx, %r13
	movq %rdi, %rbx
	movq %r15, -152(%rbp)
	movq %rdx, %r15
	movq %rax, -160(%rbp)
	movq %r14, %rax
	movq %rcx, -144(%rbp)
	movq %rsi, %r14
	movq %r8, -176(%rbp)
	jmp .Lbb3810
.Lbb3782:
	cmpq $34, %r9
	jnz .Lbb3784
	movq %rdx, %r15
	xchgq %r12, %r13
	movq %r14, %rax
	movq %rbx, %r14
	movq %rdi, %rbx
	jmp .Lbb3813
.Lbb3784:
	movq %rdx, -96(%rbp)
	movq %rbx, -72(%rbp)
	movq %rdi, %rbx
	movq %r12, -80(%rbp)
	movq %r13, -88(%rbp)
	movq %r15, %rdx
	movq %rax, %r13
	movq %r14, %rax
	movq %rcx, %r12
	movq %rsi, %r15
.p2align 4
.Lbb3785:
	movq %r8, %r14
	movq %rax, -48(%rbp)
	movq %rdx, -56(%rbp)
	movq %r10, -808(%rbp)
	movq $1099511627775, %rcx
	cmpq %rcx, %r10
	jbe .Lbb3787
	leaq -808(%rbp), %rdx
	movl $170, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor1
	movq %r15, %rcx
	movq %rax, %r15
	movq %r12, %rax
	movq -48(%rbp), %r12
	movq -56(%rbp), %rdx
	jmp .Lbb3789
.Lbb3787:
	xchgq %rax, %r12
	movq %r15, %rcx
	movq $72244511014649856, %rsi
	movq %r10, %r15
	orq %rsi, %r15
.Lbb3789:
	movl %edx, %edx
	addl $1, %edx
	movl %edx, %edx
	movq %rdx, -64(%rbp)
	movq %rcx, -808(%rbp)
	movq %rax, -800(%rbp)
	leaq -808(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r13, %rcx
	movq %r12, %rsi
	movq -72(%rbp), %r12
	movq -80(%rbp), %r13
	movq -88(%rbp), %rdi
	movq -64(%rbp), %rdx
	movq %rdi, -808(%rbp)
	movq %rsi, -800(%rbp)
	movq %rdx, -792(%rbp)
	movq %rcx, -784(%rbp)
	movq %rax, -776(%rbp)
	movl $5, %ecx
	leaq -808(%rbp), %rdx
	movl $171, %esi
	movq %rbx, %rdi
	callq p111_rt_ctor
	movq %rax, %rcx
	movq %r13, %rax
	movq -96(%rbp), %r13
	movq %rcx, -808(%rbp)
	movq %rax, -800(%rbp)
	leaq -808(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r15, -808(%rbp)
	movq %rax, -800(%rbp)
	leaq -808(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r15
	xchgq %r14, %r13
.p2align 4
.Lbb3791:
	movq %r15, %rax
	shrq $40, %rax
	andq $65535, %rax
	cmpq $17, %rax
	jz .Lbb4000
	cmpq $18, %rax
	jnz .Lbb3998
	leaq -1384(%rbp), %rdx
	movq %r15, %rsi
	movq %rbx, %rdi
	callq p125_rt_take2
	movq -1384(%rbp), %r15
	movq -1376(%rbp), %rax
	movl %r12d, %ecx
	cmpq $0, %rcx
	setz %cl
	movzbl %cl, %ecx
	movl %ecx, %ecx
	xchgq %r13, %r15
	xchgq %r12, %rax
	movq %rcx, %rdx
.Lbb3795:
	cmpq $1, %rdx
	setz %cl
	movzbl %cl, %ecx
	shrq $40, %rdx
	andq $8388607, %rdx
	cmpq $65538, %rdx
	setz %dl
	movzbl %dl, %edx
	orl %edx, %ecx
	jnz .Lbb3996
	xorl $1, %ecx
	jz .Lbb3994
	movl %eax, %eax
	subl $1, %eax
	movl %eax, %eax
	xchgq %r13, %rax
.Lbb3799:
	movq %rax, %rcx
	shrq $40, %rcx
	andq $65535, %rcx
	cmpq $170, %rcx
	jz .Lbb3882
	cmpq $173, %rcx
	jz .Lbb3858
	cmpq $174, %rcx
	jz .Lbb3846
	cmpq $172, %rcx
	jz .Lbb3827
	cmpq $171, %rcx
	jnz .Lbb3825
	movl $5, %ecx
	leaq -1368(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_take
	movq -1368(%rbp), %rax
	movq -1360(%rbp), %rcx
	movq -1352(%rbp), %rdx
	movq -1344(%rbp), %rsi
	movq -1336(%rbp), %rdi
	movq %r15, -120(%rbp)
	movq %r13, -104(%rbp)
	movq %r12, -128(%rbp)
	movq %rax, %r15
	movq %r14, %rax
	movq %rcx, -112(%rbp)
	movq %rdx, %r13
	movq %rsi, %r12
	movq %rdi, %r14
.Lbb3806:
	movq %rax, %rcx
	shrq $40, %rcx
	andq $65535, %rcx
	cmpq $17, %rcx
	jz .Lbb3823
	cmpq $18, %rcx
	jnz .Lbb3821
	leaq -856(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take2
	movq -120(%rbp), %rcx
	movq -104(%rbp), %rsi
	movq -128(%rbp), %rax
	movq -112(%rbp), %rdx
	movq -856(%rbp), %rdi
	movq -848(%rbp), %r8
	movl %r13d, %r10d
	movl %r12d, %r9d
	cmpq %r9, %r10
	setz %r9b
	movzbl %r9b, %r9d
	movl %r9d, %r10d
	movq %rsi, -168(%rbp)
	movq %rdx, -152(%rbp)
	movq %r13, -160(%rbp)
	movq %r8, %r13
	movq %r12, -144(%rbp)
	movq %rax, %r12
	movq %r15, %rax
	movq %rcx, %r15
	movq %rdi, -176(%rbp)
.Lbb3810:
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
	jz .Lbb3815
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_99_95_99_108_101_97_114_
	movq %rax, -136(%rbp)
	movq %r14, %rax
	movq -168(%rbp), %r14
	movq -176(%rbp), %rcx
	movq %rcx, -840(%rbp)
	movq %rax, -832(%rbp)
	leaq -840(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %rsi
	movq $72076285735600128, %rdx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_110_116_95_114_101_118_101_114_115_101_
	movq %rax, %r8
	movq -136(%rbp), %rcx
	movq %r15, %rdx
	leaq -768(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_101_109_105_116_
	movq -768(%rbp), %r15
	movq -760(%rbp), %rax
	xchgq %r13, %r15
	xchgq %r12, %r13
.Lbb3813:
	movq %rax, -824(%rbp)
	movq %r15, -816(%rbp)
	leaq -824(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r15
	xchgq %r15, %r14
	xchgq %r13, %r15
	xchgq %r12, %r13
	jmp .Lbb3791
.Lbb3815:
	xchgq %r15, %rax
	movq -152(%rbp), %rsi
	movq -160(%rbp), %rdx
	xorl $1, %ecx
	jz .Lbb3819
	movl %esi, %ecx
	movl %edx, %edx
	addl %edx, %ecx
	movl %ecx, %ecx
	movq %rax, %rdx
	leaq -768(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_101_100_103_101_
	movq %r15, %rax
	movq -168(%rbp), %r15
	movq -152(%rbp), %rsi
	movq -160(%rbp), %rdx
	movq -144(%rbp), %rdi
	movq -176(%rbp), %rcx
	movq -768(%rbp), %r8
	movq -760(%rbp), %r10
	movq %r13, -96(%rbp)
	movq %r15, -72(%rbp)
	movq %r12, -80(%rbp)
	movq %rax, -88(%rbp)
	movq %rsi, %rax
	movq %rdi, %r13
	movq %r14, %r12
	movq %rcx, %r15
	jmp .Lbb3785
.Lbb3819:
	movq %rbx, %rdi
	movq %rax, %rsi
	movq %rdi, %rbx
	callq p111_rt_sink
	movq %rbx, %rdi
	movq -704(%rbp), %rbx
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
	movq %r14, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4002
.Lbb3821:
	movq %rbx, %rdi
	movq -704(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4002
.Lbb3823:
	movq -120(%rbp), %r13
	movq -128(%rbp), %rax
	movq %rbx, %rdi
	movq -704(%rbp), %rbx
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
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_102_97_105_108_
	movq %rax, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4002
.Lbb3825:
	movq %rbx, %rdi
	movq -704(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4002
.Lbb3827:
	leaq -1368(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take1
	movq -1368(%rbp), %rax
	xchgq %r14, %rax
.Lbb3829:
	movq %rax, %rcx
	shrq $40, %rcx
	andq $65535, %rcx
	cmpq $17, %rcx
	jz .Lbb3844
	cmpq $18, %rcx
	jnz .Lbb3842
	leaq -928(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take2
	movq %r14, %rax
	movq -928(%rbp), %r14
	movq -920(%rbp), %rcx
	movq %rcx, -184(%rbp)
	movl %eax, %eax
	cmpq $1, %rax
	setz %cl
	movzbl %cl, %ecx
	movl %ecx, %edx
	cmpq $1, %rdx
	setz %cl
	movzbl %cl, %ecx
	shrq $40, %rdx
	andq $8388607, %rdx
	cmpq $65538, %rdx
	setz %dl
	movzbl %dl, %edx
	orl %edx, %ecx
	jnz .Lbb3836
	xorl $1, %ecx
	jnz .Lbb3835
	movl $4, %esi
	movq %rbx, %rdi
	callq p111_rt_fail
	movq %r14, %rax
	movl $0, %ecx
	jmp .Lbb3838
.Lbb3835:
	subl $1, %eax
	movl %eax, %esi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_85_51_50_46_115_104_111_119_
	movq %rax, %rcx
	movq %r14, %rax
	movq $144142675918017308, %rdx
	movq %rdx, -928(%rbp)
	movq %rcx, -920(%rbp)
	movq $0, -912(%rbp)
	movq $0, -904(%rbp)
	movq %rax, %r14
	movq $72076285735600128, %rax
	movq %rax, -896(%rbp)
	movq $0, -888(%rbp)
	movq $0, -880(%rbp)
	movl $7, %ecx
	leaq -928(%rbp), %rdx
	movl $161, %esi
	movq %rbx, %rdi
	callq p111_rt_ctor
	movq %rax, %rcx
	movq %r14, %rax
	jmp .Lbb3838
.Lbb3836:
	movq %r14, %rax
	movq $144292209499394829, %rcx
.Lbb3838:
	movq %rcx, %r14
	movq %rax, -928(%rbp)
	movq $72076285735600128, %rax
	movq %rax, -920(%rbp)
	leaq -928(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r14, %rcx
	movq %rax, %r8
	movq -184(%rbp), %r14
	movq %r15, %rdx
	leaq -768(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_101_109_105_116_
	movq %r14, %rax
	movq -768(%rbp), %r14
	movq -760(%rbp), %r15
	xchgq %r13, %r14
	xchgq %r12, %r13
	xchgq %rax, %r15
.Lbb3840:
	movq %rax, -872(%rbp)
	movq %r15, -864(%rbp)
	leaq -872(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r15
	xchgq %r15, %r14
	xchgq %r13, %r15
	xchgq %r12, %r13
	jmp .Lbb3791
.Lbb3842:
	movq %rbx, %rdi
	movq -704(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4002
.Lbb3844:
	movq %rbx, %rdi
	movq -704(%rbp), %rbx
	movq %r12, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r15, %rsi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_102_97_105_108_
	movq %rax, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4002
.Lbb3846:
	leaq -1368(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take1
	movq -1368(%rbp), %rax
	xchgq %r14, %rax
.Lbb3848:
	movq %rax, %rcx
	shrq $40, %rcx
	andq $65535, %rcx
	cmpq $17, %rcx
	jz .Lbb3856
	cmpq $18, %rcx
	jnz .Lbb3854
	leaq -960(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take2
	movq -960(%rbp), %rax
	movq -952(%rbp), %rcx
	movq %rcx, -192(%rbp)
	movq %rax, -960(%rbp)
	movq $72076285735600128, %rax
	movq %rax, -952(%rbp)
	leaq -960(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r14, %rcx
	movq -192(%rbp), %r14
	movq %rcx, -960(%rbp)
	movq %rax, -952(%rbp)
	leaq -960(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r8
	movq $144292209499394846, %rcx
	movq %r15, %rdx
	leaq -768(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_101_109_105_116_
	movq -768(%rbp), %r15
	movq -760(%rbp), %rax
	xchgq %r14, %r15
	xchgq %r13, %r14
	xchgq %r12, %r13
.Lbb3852:
	movq %rax, -944(%rbp)
	movq %r15, -936(%rbp)
	leaq -944(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r15
	xchgq %r15, %r14
	xchgq %r13, %r15
	xchgq %r12, %r13
	jmp .Lbb3791
.Lbb3854:
	movq %rbx, %rdi
	movq -704(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4002
.Lbb3856:
	movq %rbx, %rdi
	movq -704(%rbp), %rbx
	movq %r12, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r15, %rsi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_102_97_105_108_
	movq %rax, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4002
.Lbb3858:
	leaq -1368(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take1
	movq -1368(%rbp), %rax
.Lbb3859:
	movq %rax, %rcx
	shrq $40, %rcx
	andq $65535, %rcx
	cmpq $24, %rcx
	jz .Lbb3878
	cmpq $25, %rcx
	jnz .Lbb3876
	leaq -1024(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take2
	movq -1024(%rbp), %rsi
	movq -1016(%rbp), %rax
	movq %rax, -200(%rbp)
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_67_104_97_114_46_116_111_95_117_51_50_
	movq %rax, %rcx
	movq %r15, %rax
	movq -200(%rbp), %r15
	movq %rax, %rdx
	leaq -768(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_99_95_119_111_114_100_95_101_109_105_116_
	movq -768(%rbp), %rax
	movq -760(%rbp), %rcx
	movq %r14, -208(%rbp)
	movq %r13, %r14
	movq %r12, %r13
	movq %r15, %r12
	movq %rax, %r15
	movq %rcx, %rax
.Lbb3863:
	movq %rax, -992(%rbp)
	movq $72076285735600128, %rax
	movq %rax, -984(%rbp)
	leaq -992(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r8
	movq %r15, %rax
	movq -208(%rbp), %r15
	movq $144292209499394853, %rcx
	movq %rax, %rdx
	leaq -768(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_101_109_105_116_
	movq -768(%rbp), %rax
	movq -760(%rbp), %rcx
	xchgq %r14, %r13
	xchgq %rax, %rcx
	xchgq %r15, %rax
.Lbb3865:
	movq %rax, -216(%rbp)
	movq %r12, -976(%rbp)
	movq $1099511627775, %rdx
	cmpq %rdx, %r12
	jbe .Lbb3868
	movq %rcx, %r12
	leaq -976(%rbp), %rdx
	movl $173, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor1
	movq %r15, %rcx
	movq %rax, %r15
	movq -216(%rbp), %rax
	jmp .Lbb3870
.Lbb3868:
	xchgq %r12, %r15
	xchgq %rcx, %r12
	movq $72247809549533184, %rdx
	orq %rdx, %r15
.Lbb3870:
	movq %rcx, -976(%rbp)
	movq $1099511627775, %rdx
	cmpq %rdx, %rcx
	jbe .Lbb3872
	leaq -976(%rbp), %rdx
	movl $174, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor1
	movq %rax, %rcx
	movq %r14, %rax
	movq -216(%rbp), %r14
	jmp .Lbb3874
.Lbb3872:
	xchgq %rax, %r14
	movq $72248909061160960, %rdx
	orq %rdx, %rcx
.Lbb3874:
	movq %rcx, -976(%rbp)
	movq %rax, -968(%rbp)
	leaq -976(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r15, -976(%rbp)
	movq %rax, -968(%rbp)
	leaq -976(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r15
	xchgq %r12, %r13
	jmp .Lbb3791
.Lbb3876:
	movq %rbx, %rdi
	movq -704(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4002
.Lbb3878:
	movq $72076285735600128, %r8
	movq $144292209499394860, %rcx
	movq %r15, %rdx
	leaq -768(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_101_109_105_116_
	movq -768(%rbp), %r15
	movq -760(%rbp), %rax
	xchgq %r14, %r15
	xchgq %r13, %r14
	xchgq %r12, %r13
.Lbb3880:
	movq %rax, -1008(%rbp)
	movq %r15, -1000(%rbp)
	leaq -1008(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r15
	xchgq %r15, %r14
	xchgq %r13, %r15
	xchgq %r12, %r13
	jmp .Lbb3791
.Lbb3882:
	leaq -1368(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take1
	movq -1368(%rbp), %rax
	xchgq %rax, %r12
	xchgq %r15, %rax
.Lbb3884:
	movq %r12, %rcx
	movq %rax, %rdx
	leaq -768(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_110_111_100_101_
	movq -768(%rbp), %rax
	movq -760(%rbp), %rcx
	movq %r12, -224(%rbp)
	movq %rax, %r12
	movq %rcx, %rax
.Lbb3886:
	movq %rax, %rcx
	shrq $40, %rcx
	andq $65535, %rcx
	cmpq $164, %rcx
	jnz .Lbb3992
	leaq -1328(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take3
	movq -224(%rbp), %rax
	movq -1328(%rbp), %rcx
	movq -1320(%rbp), %rdx
	movq -1312(%rbp), %rsi
	xchgq %rax, %rdx
	xchgq %r14, %rax
	xchgq %rcx, %r14
	xchgq %r15, %rcx
	xchgq %r13, %r15
	xchgq %r12, %rsi
.Lbb3889:
	movq %rdx, -328(%rbp)
	movq %r13, -592(%rbp)
	movq %rax, %r13
	movq %r14, %rax
	movq %rcx, %r14
	movq %r12, -600(%rbp)
	movq %r15, %r12
	movq %rsi, %r15
.Lbb3890:
	movq %rax, %rcx
	shrq $40, %rcx
	andq $65535, %rcx
	cmpq $163, %rcx
	jz .Lbb3977
	cmpq $162, %rcx
	jz .Lbb3956
	cmpq $161, %rcx
	jnz .Lbb3954
	movl $7, %ecx
	leaq -1304(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_take
	movq -1304(%rbp), %rsi
	movq -1296(%rbp), %rax
	movq %rax, -232(%rbp)
	movq -1288(%rbp), %r10
	movq %r10, -304(%rbp)
	movq -1280(%rbp), %rdx
	movq %rdx, -296(%rbp)
	movq -1272(%rbp), %rax
	movq %rax, -240(%rbp)
	movq -1264(%rbp), %rdi
	movq %rdi, -288(%rbp)
	movq -1256(%rbp), %r8
	movq %r8, -280(%rbp)
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, -248(%rbp)
	movq -232(%rbp), %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, -264(%rbp)
	movq -240(%rbp), %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %rsi
	movq -264(%rbp), %r11
	movq -248(%rbp), %rax
	movq -280(%rbp), %r8
	movq -288(%rbp), %rdi
	movq -296(%rbp), %rdx
	movq -304(%rbp), %r10
	movq %rsi, -256(%rbp)
	movq %rax, -1304(%rbp)
	movq %r11, -1296(%rbp)
	movq %r10, -1288(%rbp)
	movq %rdx, -1280(%rbp)
	movq %rsi, -1272(%rbp)
	movq %rdi, -1264(%rbp)
	movq %r8, -1256(%rbp)
	movl $7, %ecx
	leaq -1304(%rbp), %rdx
	movl $161, %esi
	movq %rbx, %rdi
	callq p111_rt_ctor
	movq %rax, -312(%rbp)
	movq -248(%rbp), %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %r9
	movq %r9, -272(%rbp)
	movq $144142675918017354, %rdx
	movq %r9, %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq %rax, -320(%rbp)
	movq -592(%rbp), %rcx
	movq -600(%rbp), %rax
	movq -256(%rbp), %rsi
	movq -264(%rbp), %r11
	movq -272(%rbp), %r9
	movq -280(%rbp), %r8
	movq -288(%rbp), %rdi
	movq -296(%rbp), %rdx
	movq -304(%rbp), %r10
	movq %r15, -568(%rbp)
	movsd -328(%rbp), %xmm15
	movsd %xmm15, -584(%rbp)
	movq %r14, -560(%rbp)
	movq %r12, -576(%rbp)
	movq %r13, %r12
	movq -312(%rbp), %r15
	movq %rcx, -392(%rbp)
	movq %rax, -400(%rbp)
	movq %r9, %r14
	movq %r11, %r13
	movq %r10, -344(%rbp)
	movq %rdx, -352(%rbp)
	movq %rdi, -360(%rbp)
	movq %r8, -368(%rbp)
	movsd -320(%rbp), %xmm15
	movsd %xmm15, -336(%rbp)
.Lbb3895:
	movq %r15, %rax
	movq %rsi, %r15
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_sink
	movq %r15, %rsi
	movq %r14, %rax
	movq %r12, %r15
	movq -560(%rbp), %r12
	movq -336(%rbp), %rdx
	cmpq $1, %rdx
	setz %cl
	movzbl %cl, %ecx
	shrq $40, %rdx
	andq $8388607, %rdx
	cmpq $65538, %rdx
	setz %dl
	movzbl %dl, %edx
	orl %edx, %ecx
	jnz .Lbb3952
	xorl $1, %ecx
	jz .Lbb3950
	movq %rsi, %r14
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %r14, %rsi
	movq %r13, %rdi
	movq %rax, %r8
	movq -568(%rbp), %r13
	movq -576(%rbp), %r14
	movq -344(%rbp), %r10
	movq -352(%rbp), %rdx
	movq -360(%rbp), %rcx
	movq -368(%rbp), %rax
	movq %r8, -376(%rbp)
	movq %r8, -1160(%rbp)
	movq %rdi, -1152(%rbp)
	movq %r10, -1144(%rbp)
	movq %rdx, -1136(%rbp)
	movq %rsi, -1128(%rbp)
	movq %rcx, -1120(%rbp)
	movq %rax, -1112(%rbp)
	movl $7, %ecx
	leaq -1160(%rbp), %rdx
	movl $161, %esi
	movq %rbx, %rdi
	callq p111_rt_ctor
	movq %rax, -384(%rbp)
	movq -376(%rbp), %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %rcx
	movq %rcx, -408(%rbp)
	movq $144142675917963894, %rdx
	movq %rcx, %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq %rax, %rdi
	movq -584(%rbp), %rax
	movq -392(%rbp), %rsi
	movq -400(%rbp), %rdx
	movq -384(%rbp), %r8
	movq -408(%rbp), %rcx
	movq %rax, -416(%rbp)
	xchgq %r13, %r15
	movq %r14, -424(%rbp)
	movq %r12, %r14
	movq %r8, %r12
	movq %rsi, -432(%rbp)
	movq %rdx, -440(%rbp)
	movq %rcx, %rax
	movq %rdi, -448(%rbp)
.Lbb3899:
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_sink
	movq -416(%rbp), %rsi
	movq -424(%rbp), %rdx
	movq -432(%rbp), %rcx
	movq -440(%rbp), %rax
	movq -448(%rbp), %r8
	cmpq $1, %r8
	setz %dil
	movzbl %dil, %edi
	shrq $40, %r8
	andq $8388607, %r8
	cmpq $65538, %r8
	setz %r8b
	movzbl %r8b, %r8d
	orl %r8d, %edi
	jnz .Lbb3905
	movl %edi, %esi
	xorl $1, %esi
	jz .Lbb3903
	xchgq %rcx, %rax
	xchgq %r12, %rcx
	xchgq %r15, %rdx
	xchgq %r14, %r15
	xchgq %r13, %r14
	jmp .Lbb3958
.Lbb3903:
	movq %rbx, %rdi
	movq -704(%rbp), %rbx
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
	jmp .Lbb4002
.Lbb3905:
	movq %r15, -456(%rbp)
	movq %rsi, -464(%rbp)
	xchgq %r12, %rax
	movq %r14, -472(%rbp)
	movq %r13, %r15
	movq %rcx, %r13
	movq %rdx, %r14
.Lbb3906:
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %r14, %rsi
	movq %rax, %r14
	movq -456(%rbp), %rax
	movq -464(%rbp), %rcx
	subq $16, %rsp
	movq %rsp, %rdx
	movq %rsi, 8(%rdx)
	movq %r12, 0(%rdx)
	movq %r13, %r9
	movq %r14, %r8
	movq %rax, %rdx
	leaq -768(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_99_95_100_101_99_111_100_101_
	movq -472(%rbp), %rax
	subq $-16, %rsp
	movq -768(%rbp), %rcx
	movq -760(%rbp), %rdx
	movq %r14, -480(%rbp)
	movq %r13, -488(%rbp)
	movq %rax, %r14
	movq %r15, %r13
	movq %r12, %r15
	movq %rcx, %r12
	movq %rdx, %rax
.Lbb3908:
	movq %rax, %rcx
	shrq $40, %rcx
	andq $65535, %rcx
	cmpq $175, %rcx
	jnz .Lbb3948
	leaq -1104(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take3
	movq -480(%rbp), %rcx
	movq -488(%rbp), %rax
	movq -1104(%rbp), %rdx
	movq -1096(%rbp), %rsi
	movq -1088(%rbp), %rdi
	xchgq %rax, %rdx
	xchgq %r14, %rax
	xchgq %rcx, %rsi
	xchgq %r15, %rcx
	xchgq %r13, %r15
	xchgq %r12, %rdi
.Lbb3911:
	movq %rdx, -496(%rbp)
	movq %rdi, %rdx
	xchgq %rsi, %rax
	xchgq %r14, %rsi
	movq %r13, -552(%rbp)
	movq %r15, %r13
	movq %rcx, %r15
.Lbb3912:
	movq %rdx, -512(%rbp)
	cmpq $1, %rsi
	setz %cl
	movzbl %cl, %ecx
	shrq $40, %rsi
	andq $8388607, %rsi
	cmpq $65538, %rsi
	setz %sil
	movzbl %sil, %esi
	orl %esi, %ecx
	jnz .Lbb3943
	xorl $1, %ecx
	jz .Lbb3941
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %rcx
	movq %rcx, -504(%rbp)
	movq %rcx, %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_115_104_97_112_101_95_110_97_109_101_
	movq %rax, %rsi
	movq $144142675918016930, %rdx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq %rax, %rsi
	movl %r15d, %eax
	cmpq $1, %rax
	setz %al
	movzbl %al, %eax
	movl %eax, %edx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_66_111_111_108_46_97_110_100_
	movq %rax, %rsi
	movq %r15, %rax
	movq -512(%rbp), %r15
	movq -496(%rbp), %rdx
	movq -504(%rbp), %rcx
	xchgq %rcx, %rdx
	xchgq %r13, %r12
	xchgq %r14, %r13
	xchgq %r15, %r14
.Lbb3916:
	movq %rcx, -528(%rbp)
	movq %rax, -536(%rbp)
	cmpq $1, %rsi
	setz %dil
	movzbl %dil, %edi
	movl %edi, -684(%rbp)
	shrq $40, %rsi
	andq $8388607, %rsi
	cmpq $65538, %rsi
	setz %sil
	movzbl %sil, %esi
	movl %esi, -520(%rbp)
	orl %edi, %esi
	xorl $1, %esi
	jnz .Lbb3940
	movq %rdx, %rsi
	movq %rbx, %rdi
	callq p111_rt_sink
	movq -528(%rbp), %rcx
	movq -536(%rbp), %rax
	movl -520(%rbp), %esi
	movl -684(%rbp), %edx
	orl %esi, %edx
	jz .Lbb3938
	movl $0, %r9d
	movq %rax, %r8
	movq %r14, %rdx
	leaq -768(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_99_95_107_105_100_
	movq -768(%rbp), %r14
	movq -760(%rbp), %rax
	xchgq %r13, %r14
	xchgq %r12, %r13
	xchgq %r15, %r12
.Lbb3920:
	movq %r12, %r9
	movl $1, %r8d
	movq %rax, %rcx
	movq %r15, %rdx
	leaq -768(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_99_95_115_117_99_99_95_115_99_97_110_
	movq -768(%rbp), %r15
	movq -760(%rbp), %rax
	movq %r15, %r12
	movq %rax, %r15
.Lbb3922:
	movq %r15, %rax
	shrq $40, %rax
	andq $65535, %rax
	cmpq $176, %rax
	jnz .Lbb3936
	leaq -1064(%rbp), %rdx
	movq %r15, %rsi
	movq %rbx, %rdi
	callq p125_rt_take3
	movq -1064(%rbp), %r15
	movq -1056(%rbp), %rax
	movq -1048(%rbp), %rcx
	xchgq %r12, %rax
	xchgq %r15, %r12
.Lbb3925:
	movq %rax, -544(%rbp)
	movq %r12, -1040(%rbp)
	movq $1099511627775, %rdx
	cmpq %rdx, %r12
	jbe .Lbb3928
	movq %rcx, %r12
	leaq -1040(%rbp), %rdx
	movl $170, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor1
	movq %r15, %rcx
	movq %rax, %r15
	movq -544(%rbp), %rax
	jmp .Lbb3930
.Lbb3928:
	xchgq %r15, %rcx
	xchgq %r12, %r15
	movq $72244511014649856, %rdx
	orq %rdx, %r15
.Lbb3930:
	movq %rcx, -1040(%rbp)
	movq $1099511627775, %rdx
	cmpq %rdx, %rcx
	jbe .Lbb3932
	leaq -1040(%rbp), %rdx
	movl $172, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor1
	movq %rax, %rcx
	movq %r14, %rax
	movq -544(%rbp), %r14
	jmp .Lbb3934
.Lbb3932:
	xchgq %rax, %r14
	movq $72246710037905408, %rdx
	orq %rdx, %rcx
.Lbb3934:
	movq %rcx, -1040(%rbp)
	movq %rax, -1032(%rbp)
	leaq -1040(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r15, -1040(%rbp)
	movq %rax, -1032(%rbp)
	leaq -1040(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r15
	xchgq %r14, %r13
	jmp .Lbb3791
.Lbb3936:
	movq %rbx, %rdi
	movq -704(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4002
.Lbb3938:
	movq %rbx, %rdi
	movq -704(%rbp), %rbx
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
	jmp .Lbb4002
.Lbb3940:
	xchgq %rax, %r12
	xchgq %rcx, %rax
	xchgq %rdx, %rcx
	xchgq %r14, %rdx
	xchgq %r13, %r15
	jmp .Lbb3958
.Lbb3941:
	movq %rbx, %rdi
	movq -704(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4002
.Lbb3943:
	movq %rdx, %r15
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_sink
	movq -552(%rbp), %rax
	movq %rax, %rcx
	movq %r15, %rdx
	leaq -768(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_99_95_119_111_114_100_95_101_109_105_116_
	movq -768(%rbp), %r15
	movq -760(%rbp), %rax
	xchgq %r13, %r15
	xchgq %r12, %r13
.Lbb3946:
	movq %rax, -1080(%rbp)
	movq %r15, -1072(%rbp)
	leaq -1080(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r15
	xchgq %r14, %r15
	xchgq %r12, %r13
	jmp .Lbb3791
.Lbb3948:
	movq %rbx, %rdi
	movq -704(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4002
.Lbb3950:
	movq -568(%rbp), %rdx
	movq %r13, %r14
	movq %r15, %r13
	movq %rax, %r15
	movq %rbx, %rdi
	movq %rsi, %r12
	movq %rdx, %rsi
	movq %rdi, %rbx
	callq p111_rt_sink
	movq %r13, %rdx
	movq %r12, %rsi
	movq %rbx, %rdi
	movq %rdx, %r12
	movq -560(%rbp), %rdx
	movq %rsi, %r13
	movq %rdx, %rsi
	movq %rdi, %rbx
	callq p111_rt_sink
	movq %r13, %rsi
	movq %rbx, %rdi
	movq -704(%rbp), %rbx
	movq %rsi, %r13
	movq %r12, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r15, %rdx
	movq %r13, %rsi
	movq %r12, %rdi
	movq %rsi, %r13
	movq %rdx, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r14, %rdx
	movq %r13, %rsi
	movq %r12, %rdi
	movq %rsi, %r13
	movq %rdx, %rsi
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
	jmp .Lbb4002
.Lbb3952:
	movq %rsi, %r14
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_sink
	movq %r14, %rsi
	movq %r13, %rax
	movq -568(%rbp), %r13
	movq %rsi, %r14
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_sink
	movq %r14, %rsi
	movq -576(%rbp), %r14
	movq %rbx, %rdi
	callq p111_rt_sink
	movq -584(%rbp), %rax
	movq %rax, -1160(%rbp)
	movq %r15, -1152(%rbp)
	leaq -1160(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r15
	xchgq %r15, %r14
	xchgq %r12, %r15
	jmp .Lbb3791
.Lbb3954:
	movq %rbx, %rdi
	movq -704(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4002
.Lbb3956:
	movl $7, %ecx
	leaq -1304(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_take
	movq -1304(%rbp), %r9
	movq -1296(%rbp), %r8
	movq -1288(%rbp), %rdi
	movq -1280(%rbp), %rsi
	movq -1272(%rbp), %rdx
	movq -1264(%rbp), %rcx
	movq -1256(%rbp), %rax
	movq %r9, -1304(%rbp)
	movq %r8, -1296(%rbp)
	movq %rdi, -1288(%rbp)
	movq %rsi, -1280(%rbp)
	movq %rdx, -1272(%rbp)
	movq %rcx, -1264(%rbp)
	movq %rax, -1256(%rbp)
	movl $7, %ecx
	leaq -1304(%rbp), %rdx
	movl $162, %esi
	movq %rbx, %rdi
	callq p111_rt_ctor
	movq %rax, %rdx
	movq -592(%rbp), %rcx
	movq -600(%rbp), %rax
	xchgq %rax, %r12
	xchgq %rcx, %rax
	xchgq %rdx, %rcx
	xchgq %r15, %rdx
	xchgq %r14, %r15
	xchgq %r13, %r14
.Lbb3958:
	movl %r12d, %esi
	cmpq $0, %rsi
	setz %sil
	movzbl %sil, %esi
	movl %esi, %esi
	movq %r12, -608(%rbp)
	movq %r14, %r12
	movq %r13, %r14
	movq %r15, %r13
	movq %rcx, %r15
	movq %rax, %rcx
.Lbb3960:
	movq %rdx, %rax
	movq %rcx, -616(%rbp)
	cmpq $1, %rsi
	setz %dl
	movzbl %dl, %edx
	shrq $40, %rsi
	andq $8388607, %rsi
	cmpq $65538, %rsi
	setz %sil
	movzbl %sil, %esi
	orl %esi, %edx
	jnz .Lbb3972
	xorl $1, %edx
	jz .Lbb3970
	movq %rax, %rdx
	leaq -768(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_101_100_103_101_
	movq %r15, %rax
	movq -616(%rbp), %r15
	movq -608(%rbp), %rcx
	movq -768(%rbp), %rdx
	movq -760(%rbp), %rsi
	movq %r13, -640(%rbp)
	movq %r14, %r13
	movq %r12, %r14
	movq %rdx, %r12
	movq %rax, %rdx
	movq %rcx, %rax
	movq %r15, %rcx
	movq %rsi, %r15
.Lbb3964:
	movq %rdx, -624(%rbp)
	movq %rcx, -632(%rbp)
	movq %r15, -1200(%rbp)
	movq $1099511627775, %rsi
	cmpq %rsi, %r15
	jbe .Lbb3967
	movq %rax, %r15
	leaq -1200(%rbp), %rdx
	movl $170, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor1
	xchgq %rax, %r15
	movq -624(%rbp), %rdx
	movq -632(%rbp), %rcx
	jmp .Lbb3968
.Lbb3967:
	movq $72244511014649856, %rsi
	orq %rsi, %r15
.Lbb3968:
	movq %rdx, -1200(%rbp)
	movq %rcx, -1192(%rbp)
	movq $1, -1184(%rbp)
	movq %rax, -1176(%rbp)
	movq $72076285735600128, %rax
	movq %rax, -1168(%rbp)
	movl $5, %ecx
	leaq -1200(%rbp), %rdx
	movl $171, %esi
	movq %rbx, %rdi
	callq p111_rt_ctor
	movq %rax, %rcx
	movq -640(%rbp), %rax
	movq %rcx, -1200(%rbp)
	movq %rax, -1192(%rbp)
	leaq -1200(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %r15, -1200(%rbp)
	movq %rax, -1192(%rbp)
	leaq -1200(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r15
	xchgq %r12, %r13
	jmp .Lbb3791
.Lbb3970:
	movq %rbx, %rdi
	movq -704(%rbp), %rbx
	movq %rax, %rsi
	movq %rdi, %r14
	callq p111_rt_sink
	movq %r14, %rdi
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
	jmp .Lbb4002
.Lbb3972:
	xchgq %rax, %r15
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_99_95_99_108_101_97_114_
	movq %rax, %rcx
	movq $72076285735600128, %r8
	movq %r15, %rdx
	leaq -768(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_101_109_105_116_
	movq -768(%rbp), %r15
	movq -760(%rbp), %rax
	xchgq %r13, %r14
	xchgq %r12, %r15
.Lbb3975:
	movq %rax, -1216(%rbp)
	movq %r15, -1208(%rbp)
	leaq -1216(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r15
	xchgq %r14, %r15
	xchgq %r12, %r13
	jmp .Lbb3791
.Lbb3977:
	movl $5, %ecx
	leaq -1304(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_take
	movq -1304(%rbp), %rsi
	movq -1296(%rbp), %rcx
	movq %rcx, -656(%rbp)
	movq -1288(%rbp), %rdx
	movq %rdx, -648(%rbp)
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, -664(%rbp)
	movq $144142675917973346, %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq %rax, %rsi
	movq -664(%rbp), %rax
	movq -648(%rbp), %rdx
	movq -656(%rbp), %rcx
	movq %r12, -672(%rbp)
	movq %r13, %r12
	movq %r15, %r13
	movq %r14, %r15
	movq %rcx, -696(%rbp)
	movq %rdx, %r14
	movq %rsi, -680(%rbp)
.Lbb3979:
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_sink
	movq %r14, %rax
	movq -672(%rbp), %r14
	movq -680(%rbp), %rdx
	cmpq $1, %rdx
	setz %cl
	movzbl %cl, %ecx
	shrq $40, %rdx
	andq $8388607, %rdx
	cmpq $65538, %rdx
	setz %dl
	movzbl %dl, %edx
	orl %edx, %ecx
	movl %ecx, -688(%rbp)
	jnz .Lbb3987
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_sink
	movq -696(%rbp), %rax
	movl -688(%rbp), %ecx
	xorl $1, %ecx
	jz .Lbb3985
	movq %rax, %rcx
	movq %r13, %rdx
	leaq -768(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_99_95_119_111_114_100_95_101_109_105_116_
	movq -768(%rbp), %r13
	movq -760(%rbp), %rax
	xchgq %r14, %r13
	xchgq %r15, %r14
	xchgq %r12, %r15
.Lbb3983:
	movq %rax, -1232(%rbp)
	movq %r15, -1224(%rbp)
	leaq -1232(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r15
	xchgq %r14, %r15
	xchgq %r12, %r13
	jmp .Lbb3791
.Lbb3985:
	movq %rbx, %rdi
	movq -704(%rbp), %rbx
	movq %r13, %rsi
	movq %rdi, %r13
	callq p111_rt_sink
	movq %r13, %rdi
	movq %r15, %rsi
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
	jmp .Lbb4002
.Lbb3987:
	movq %rax, -1248(%rbp)
	movq $1099511627775, %rcx
	cmpq %rcx, %rax
	jbe .Lbb3989
	leaq -1248(%rbp), %rdx
	movl $173, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor1
	jmp .Lbb3990
.Lbb3989:
	movq $72247809549533184, %rcx
	orq %rcx, %rax
.Lbb3990:
	movq %rax, -1248(%rbp)
	movq %r15, -1240(%rbp)
	leaq -1248(%rbp), %rdx
	movl $18, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor2
	movq %rax, %r15
	xchgq %r12, %r14
	jmp .Lbb3791
.Lbb3992:
	movq %rbx, %rdi
	movq -704(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4002
.Lbb3994:
	movq %rbx, %rdi
	movq -704(%rbp), %rbx
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
	jmp .Lbb4002
.Lbb3996:
	movq %rbx, %rdi
	movq -704(%rbp), %rbx
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
	jmp .Lbb4002
.Lbb3998:
	movq %rbx, %rdi
	movq -704(%rbp), %rbx
	movq %r13, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb4002
.Lbb4000:
	movq %r14, %rdx
	movq %rbx, %rdi
	movq -704(%rbp), %rbx
	movq %r13, %rcx
	leaq -768(%rbp), %rsi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_109_97_116_99_104_95_56_
	movq -768(%rbp), %rcx
	movq -760(%rbp), %rax
	movq %rcx, (%rbx)
	movq %rax, 8(%rbx)
	movl $0, %eax
.Lbb4002:
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
	subq $520, %rsp
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
	xchgq %r8, %rbx
	movq %rsi, -280(%rbp)
	movq %rcx, %rsi
	movq %r11, %rcx
	cmpq $0, %rdx
	setz %r11b
	movzbl %r11b, %r11d
	cmpl $0, %r11d
	jz .Lbb2959
	movq %rsi, %rax
	movq %rbx, %r15
	movq %rdi, %rbx
	xchgq %r12, %r14
	jmp .Lbb2991
.Lbb2959:
	cmpq $1, %rdx
	jnz .Lbb2961
	movq %rbx, %rax
	movq %rdi, %rbx
	xchgq %r12, %r14
	movq %r15, %rdx
	movq %rsi, %r15
	jmp .Lbb2993
.Lbb2961:
	cmpq $2, %rdx
	jnz .Lbb2963
	movq %rsi, %r15
	xchgq %r12, %r13
	movq %r14, %rax
	movq %rbx, %r14
	movq %rdi, %rbx
	jmp .Lbb2997
.Lbb2963:
	cmpq $3, %rdx
	jnz .Lbb2965
	movq %rsi, -32(%rbp)
	movq %rbx, -40(%rbp)
	movq %rdi, %rbx
	movq %r12, -48(%rbp)
	movq %r13, -56(%rbp)
	movq %r15, %r13
	movq %rax, %r12
	jmp .Lbb3000
.Lbb2965:
	cmpq $4, %rdx
	jnz .Lbb2967
	movq %rsi, -64(%rbp)
	movq %r12, -288(%rbp)
	movq %rbx, %r12
	movq %rdi, %rbx
	movq %r13, -80(%rbp)
	xchgq %r15, %rax
	movq %rcx, %r13
	movq %r14, %rcx
	movq %r8, -96(%rbp)
	movq %r9, -104(%rbp)
	movq %r10, %r14
	jmp .Lbb3002
.Lbb2967:
	cmpq $5, %rdx
	jnz .Lbb2969
	movq %rbx, -168(%rbp)
	movq %rdi, %rbx
	movq %r12, -144(%rbp)
	movq %r13, -136(%rbp)
	movq %r14, -112(%rbp)
	movq %r15, -120(%rbp)
	movq %rsi, %r15
	movq %rax, -128(%rbp)
	movq %rcx, %rax
	movq %r8, %r13
	movq %r9, %r12
	movq %r10, %r14
	jmp .Lbb3007
.Lbb2969:
	cmpq $6, %rdx
	jnz .Lbb2971
	movq %rsi, -192(%rbp)
	movq %rbx, -176(%rbp)
	movq %rdi, %rbx
	movq %r12, -184(%rbp)
	movq %r13, %rdx
	movq %rax, %r13
	movq %r15, %rax
	movq %rcx, %r12
	movq %r14, %rcx
	movq %r8, %r14
	movq %r9, %r15
	jmp .Lbb3012
.Lbb2971:
	cmpq $7, %rdx
	jnz .Lbb2973
	movq %rsi, -200(%rbp)
	movq %rbx, -208(%rbp)
	movq %rdi, %rbx
	xchgq %r13, %r14
	xchgq %r12, %r15
	jmp .Lbb3014
.Lbb2973:
	cmpq $8, %rdx
	jnz .Lbb2975
	movq %rsi, -240(%rbp)
	movq %rbx, -248(%rbp)
	movq %rdi, %rbx
	movq %r12, -256(%rbp)
	movq %r13, -216(%rbp)
	movq %r14, %r12
	movq %rcx, %r14
	movq %r8, %r13
	jmp .Lbb3017
.Lbb2975:
	cmpq $9, %rdx
	jz .Lbb2977
	movq %rbx, %rcx
	movq %rdi, %rbx
	movq %r12, %rax
	movq %r15, %r12
	movq %r13, %r15
	movq %r14, %r13
	movq %rsi, %r14
	jmp .Lbb2989
.Lbb2977:
	movq %r12, -264(%rbp)
	movq %rbx, %r12
	movq %rdi, %rbx
	movq %r14, -272(%rbp)
	movq %r13, %r14
	movq %rsi, %r13
	movq %rcx, %rdx
.p2align 4
.Lbb2978:
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
	jnz .Lbb3041
	orl %edx, %ecx
	jz .Lbb3039
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_115_104_97_112_101_95_110_97_109_101_
	movq %rax, %rsi
	movq $144142675917972605, %rdx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq %rax, %rsi
	movq -264(%rbp), %rcx
	movq -272(%rbp), %rax
	cmpq $1, %rsi
	setz %dl
	movzbl %dl, %edx
	shrq $40, %rsi
	andq $8388607, %rsi
	cmpq $65538, %rsi
	setz %sil
	movzbl %sil, %esi
	orl %esi, %edx
	jnz .Lbb2985
	xorl $1, %edx
	jnz .Lbb2983
	movl $4, %esi
	movq %rbx, %rdi
	callq p111_rt_fail
	movq %r15, %rdx
	movq %r13, %rax
	movq -264(%rbp), %r15
	movq -272(%rbp), %r13
	jmp .Lbb2984
.Lbb2983:
	xchgq %r13, %rax
	movq %r15, %rdx
	movq %rcx, %r15
.Lbb2984:
	movq %r13, %rcx
	movl $0, %r13d
	jmp .Lbb2987
.Lbb2985:
	xchgq %r13, %rax
	movq %r15, %rdx
	movq %rcx, %r15
	cmpq $32, %r12
	setb %dil
	movzbl %dil, %edi
	movl %r12d, %ecx
	movl $1, %esi
	shlq %cl, %rsi
	movq %r13, %rcx
	movl $4294967295, %r8d
	andq %r8, %rsi
	cmpl $0, %edi
	movl $0, %edi
	mov %rsi, %r13
	cmovz %rdi, %r13
.Lbb2987:
	movl $1, %r9d
	movq %rdx, %r8
	movq %rax, %rdx
	leaq -352(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_99_95_107_105_100_
	movq -352(%rbp), %rax
	movq -344(%rbp), %rcx
	xchgq %r15, %rcx
	xchgq %r13, %r15
	xchgq %rax, %r13
	xchgq %r14, %rax
	xchgq %r12, %r14
.Lbb2989:
	movl %r14d, %edx
	addl $1, %edx
	movl %edx, %r14d
	movl %ecx, %ecx
	movl %r15d, %edx
	orl %edx, %ecx
	movl %ecx, %r15d
	movl %eax, %eax
	subl $1, %eax
	movl %eax, %eax
	xchgq %r13, %rax
	xchgq %r15, %r13
	xchgq %r12, %r15
.Lbb2991:
	movl %r12d, %ecx
	cmpq $0, %rcx
	setz %cl
	movzbl %cl, %ecx
	movl %ecx, %ecx
	xchgq %rax, %r15
	movq %rcx, %rdx
.Lbb2993:
	cmpq $1, %rdx
	setz %cl
	movzbl %cl, %ecx
	shrq $40, %rdx
	andq $8388607, %rdx
	cmpq $65538, %rdx
	setz %dl
	movzbl %dl, %edx
	orl %edx, %ecx
	jnz .Lbb3037
	xorl $1, %ecx
	jz .Lbb3035
	movq %rax, %rcx
	movq %r15, %rdx
	leaq -352(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_110_111_100_101_
	movq -352(%rbp), %r15
	movq -344(%rbp), %rax
	xchgq %r14, %r15
	xchgq %r13, %r14
	xchgq %r12, %r13
.Lbb2997:
	movq %rax, %rcx
	shrq $40, %rcx
	andq $65535, %rcx
	cmpq $164, %rcx
	jnz .Lbb3033
	leaq -512(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take3
	movq -512(%rbp), %rax
	movq -504(%rbp), %rcx
	movq -496(%rbp), %rdx
	movq %r12, -32(%rbp)
	movq %r15, -40(%rbp)
	movq %r14, -48(%rbp)
	movq %r13, -56(%rbp)
	movq %rax, %r14
	movq %rcx, %r13
	movq %rdx, %r12
.Lbb3000:
	movq %r14, %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %r14
	movq %r14, %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %r15
	movq %r15, %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %rsi
	movq %rsi, -16(%rbp)
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_115_104_97_112_101_95_116_97_103_
	movq %rax, %rsi
	movq $144142675917963894, %rdx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq %rax, -24(%rbp)
	movq -16(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_115_104_97_112_101_95_110_97_109_101_
	movq %rax, %rsi
	movq $144142675917971638, %rdx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq %rax, %rdx
	movq -24(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_66_111_111_108_46_97_110_100_
	movq %rax, %rcx
	movq -32(%rbp), %rdi
	movq -40(%rbp), %rsi
	movq -48(%rbp), %rdx
	movq -56(%rbp), %rax
	movq %rdi, -64(%rbp)
	movq %rdx, -288(%rbp)
	movq %rax, -80(%rbp)
	movq %r13, %rax
	movq %r13, -96(%rbp)
	movq %r15, %r13
	movq %r12, %r15
	movq %r12, -104(%rbp)
	movq %rsi, %r12
	xchgq %r14, %rcx
.Lbb3002:
	movq %rcx, -488(%rbp)
	movq %rax, -480(%rbp)
	movq %r15, -472(%rbp)
	leaq -488(%rbp), %rdx
	movl $164, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor3
	movq %r14, %rcx
	movq %rax, %r15
	cmpq $1, %rcx
	setz %al
	movzbl %al, %eax
	shrq $40, %rcx
	andq $8388607, %rcx
	cmpq $65538, %rcx
	setz %cl
	movzbl %cl, %ecx
	orl %ecx, %eax
	jnz .Lbb3031
	xorl $1, %eax
	jz .Lbb3029
	movq %r13, %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %r13
	movq %r13, %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %rsi
	movq %rsi, %r14
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_115_104_97_112_101_95_116_97_103_
	movq %rax, %rsi
	movq $144142675917963894, %rdx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq %r14, %rsi
	movq %rax, -72(%rbp)
	movq -64(%rbp), %r14
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_115_104_97_112_101_95_110_97_109_101_
	movq %rax, %rsi
	movq $144142675917963900, %rdx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq %r15, %rsi
	movq %rax, %rdx
	movq %rsi, %r15
	movq -72(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_66_111_111_108_46_97_110_100_
	movq %rax, %rsi
	movl %r12d, %eax
	cmpq $32, %rax
	setb %al
	movzbl %al, %eax
	movl %eax, %edx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_66_111_111_108_46_97_110_100_
	movq %r15, %rsi
	movq %rax, -88(%rbp)
	movq -80(%rbp), %r15
	movq %rsi, %rax
	shrq $40, %rax
	andq $65535, %rax
	cmpq $164, %rax
	jnz .Lbb3027
	leaq -488(%rbp), %rdx
	movq %rbx, %rdi
	callq p125_rt_take3
	movq -288(%rbp), %rax
	movq -96(%rbp), %rsi
	movq -104(%rbp), %rdx
	movq -88(%rbp), %rcx
	movq -488(%rbp), %rdi
	movq -480(%rbp), %r8
	movq -472(%rbp), %r9
	movq %r12, -168(%rbp)
	movq %rax, -144(%rbp)
	movq %r15, -136(%rbp)
	movq %r14, %r15
	movq %rdi, -112(%rbp)
	movq %r8, -120(%rbp)
	movq %r9, -128(%rbp)
	movq %r13, %rax
	movq %rsi, %r13
	movq %rdx, %r12
	movq %rcx, %r14
.Lbb3007:
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_sink
	movq %r14, %rcx
	movq -112(%rbp), %rdx
	movq %rcx, %r14
	movq -120(%rbp), %rcx
	movq -128(%rbp), %rax
	movq %rdx, -464(%rbp)
	movq %rcx, -456(%rbp)
	movq %rax, -448(%rbp)
	leaq -464(%rbp), %rdx
	movl $164, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor3
	movq %r14, %rcx
	movq %rax, %rsi
	movq -136(%rbp), %r14
	cmpq $1, %rcx
	setz %al
	movzbl %al, %eax
	shrq $40, %rcx
	andq $8388607, %rcx
	cmpq $65538, %rcx
	setz %cl
	movzbl %cl, %ecx
	movl %eax, %edx
	orl %ecx, %edx
	xorl $1, %edx
	jnz .Lbb3025
	orl %ecx, %eax
	jz .Lbb3023
	movl $0, %r9d
	movq %r12, %r8
	movq %r13, %rcx
	movq %r15, %rdx
	movq %rsi, %r15
	leaq -352(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_99_95_107_105_100_
	movq %r15, %rsi
	movq -144(%rbp), %r15
	movq -352(%rbp), %rcx
	movq %rcx, -160(%rbp)
	movq -344(%rbp), %rdx
	movq %rdx, -152(%rbp)
	movq %rsi, %rax
	shrq $40, %rax
	andq $65535, %rax
	cmpq $164, %rax
	jnz .Lbb3021
	leaq -464(%rbp), %rdx
	movq %rbx, %rdi
	callq p125_rt_take3
	movq -168(%rbp), %rax
	movq -152(%rbp), %rdx
	movq -160(%rbp), %rcx
	movq -464(%rbp), %rsi
	movq -456(%rbp), %rdi
	movq -448(%rbp), %r8
	movq %rax, -192(%rbp)
	movq %r15, -176(%rbp)
	movq %r14, -184(%rbp)
	movq %r8, %rax
	movq %rcx, %r14
	movq %rdi, %rcx
	movq %rdx, %r15
	movq %rsi, %rdx
.Lbb3012:
	movq %rdx, -440(%rbp)
	movq %rcx, -432(%rbp)
	movq %rax, -424(%rbp)
	leaq -440(%rbp), %rdx
	movl $164, %esi
	movq %rbx, %rdi
	callq p125_rt_ctor3
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p111_rt_sink
	movq %r15, %rcx
	movq %r14, %rax
	movq -176(%rbp), %r15
	movq -184(%rbp), %r14
	movq %rax, %rdx
	leaq -352(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_112_114_111_100_117_99_116_46_112_49_55_51_115_95_110_111_100_101_
	movq -192(%rbp), %rax
	movq -352(%rbp), %rcx
	movq -344(%rbp), %rdx
	movq %rax, -200(%rbp)
	movq %r15, -208(%rbp)
	movq %r14, %r15
	movq %r13, %r14
	movq %r12, %r13
	movq %rcx, %r12
	movq %rdx, %rax
.Lbb3014:
	movq %rax, %rcx
	shrq $40, %rcx
	andq $65535, %rcx
	cmpq $164, %rcx
	jnz .Lbb3019
	leaq -416(%rbp), %rdx
	movq %rax, %rsi
	movq %rbx, %rdi
	callq p125_rt_take3
	movq -200(%rbp), %rcx
	movq -208(%rbp), %rax
	movq -416(%rbp), %rdx
	movq %r12, -240(%rbp)
	movq %rcx, -248(%rbp)
	movq %rax, -256(%rbp)
	movq %r15, -216(%rbp)
	movq %rdx, %r12
.Lbb3017:
	movq %r12, %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %r12
	movq %r12, %rsi
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %rsi
	movq %rsi, %r15
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_115_104_97_112_101_95_116_97_103_
	movq %rax, %rsi
	movq $144142675917963894, %rdx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq %r15, %rsi
	movq %rax, -232(%rbp)
	movq %rbx, %rdi
	callq p111_rt_keep
	movq %rax, %rsi
	movq %rsi, %r15
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_115_104_97_112_101_95_110_97_109_101_
	movq %rax, %rsi
	movq $144142675917972605, %rdx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq %r15, %rsi
	movq %rax, -224(%rbp)
	movq -216(%rbp), %r15
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_115_104_97_112_101_95_110_97_109_101_
	movq %rax, %rsi
	movq $144142675917964477, %rdx
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_
	movq -224(%rbp), %rcx
	movq %rcx, -392(%rbp)
	movq %rax, -384(%rbp)
	movl $2, %ecx
	leaq -392(%rbp), %rdx
	movl $68, %esi
	movq %rbx, %rdi
	callq p111_rt_op
	movq %rax, %rdx
	movq -232(%rbp), %rsi
	movq %rbx, %rdi
	callq p113d_FID_36_100_105_114_101_99_116_46_66_111_111_108_46_97_110_100_
	movq %rax, %rsi
	movq -240(%rbp), %rdx
	movq -248(%rbp), %rcx
	movq -256(%rbp), %rax
	movq %rax, -264(%rbp)
	movq %r14, -272(%rbp)
	movq %r15, %r14
	movq %r13, %r15
	movq %rdx, %r13
	movq %r12, %rax
	movq %rcx, %r12
	movq %rsi, %rdx
	jmp .Lbb2978
.Lbb3019:
	movq %rbx, %rdi
	movq -280(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3043
.Lbb3021:
	movq %rbx, %rdi
	movq -280(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3043
.Lbb3023:
	movq %rsi, %r13
	movq %r15, %rsi
	movq %rbx, %rdi
	movq -280(%rbp), %rbx
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
.Lbb3025:
	movq %r15, %r13
	movq %rbx, %rdi
	movq -280(%rbp), %rbx
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r13, %rsi
	movq %r12, %rdi
	movl %r14d, %eax
	subl $1, %eax
	movl %eax, %eax
	movq $0, -464(%rbp)
	movq $0, -456(%rbp)
	movq %rax, -448(%rbp)
	leaq -464(%rbp), %rdx
	movq %rsi, %r15
	movl $175, %esi
	callq p125_rt_ctor3
	movq %r15, (%rbx)
	movq %rax, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3043
.Lbb3027:
	movq %rbx, %rdi
	movq -280(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3043
.Lbb3029:
	movq -64(%rbp), %rsi
	movq %r13, %r14
	movq %r15, %r13
	movq %rbx, %rdi
	movq -280(%rbp), %rbx
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
.Lbb3031:
	movq -64(%rbp), %r14
	movq %r13, %rsi
	movq %r15, %r13
	movq -80(%rbp), %r15
	movq %rbx, %rdi
	movq -280(%rbp), %rbx
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r13, %rsi
	movq %r12, %rdi
	movq -288(%rbp), %r12
	movq %rdi, %r13
	callq p111_rt_sink
	movq %r14, %rsi
	movq %r13, %rdi
	movl %r15d, %eax
	subl $1, %eax
	movl %eax, %eax
	movq $1, -488(%rbp)
	movq %r12, -480(%rbp)
	movq %rax, -472(%rbp)
	leaq -488(%rbp), %rdx
	movq %rsi, %r14
	movl $175, %esi
	callq p125_rt_ctor3
	movq %r14, (%rbx)
	movq %rax, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3043
.Lbb3033:
	movq %rbx, %rdi
	movq -280(%rbp), %rbx
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3043
.Lbb3035:
	movq %r15, %rsi
	movq %rbx, %rdi
	movq -280(%rbp), %rbx
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movq $0, (%rbx)
	movq $0, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3043
.Lbb3037:
	movq %r15, %rsi
	movq %rbx, %rdi
	movq -280(%rbp), %rbx
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_55_51_115_95_102_97_105_108_
	movq %rax, (%rbx)
	movq $144307602662183731, %rax
	movq %rax, 8(%rbx)
	movl $0, %eax
	jmp .Lbb3043
.Lbb3039:
	movq %r13, %rsi
	movq %rax, %r13
	movq %rbx, %rdi
	movq -280(%rbp), %rbx
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
.Lbb3041:
	movq %rax, %rsi
	movq %rbx, %rdi
	movq -280(%rbp), %rbx
	movq %rsi, %rax
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r13, %rsi
	movq %r12, %rdi
	movl %r14d, %eax
	subl $1, %eax
	movl %eax, %eax
	movq $0, -376(%rbp)
	movq $0, -368(%rbp)
	movq %rax, -360(%rbp)
	leaq -376(%rbp), %rdx
	movq %rsi, %r13
	movl $175, %esi
	callq p125_rt_ctor3
	movq %r13, (%rbx)
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
.type p113d_FID_36_112_49_55_51_115_99_99_46_50_, @function
.size p113d_FID_36_112_49_55_51_115_99_99_46_50_, .-p113d_FID_36_112_49_55_51_115_99_99_46_50_
