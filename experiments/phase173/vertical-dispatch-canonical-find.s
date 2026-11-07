p113d_FID_36_112_49_50_54_115_99_99_46_49_53_49_52_:
	endbr64
	pushq %rbp
	movq %rsp, %rbp
	subq $80, %rsp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	movq %r8, %r12
	movq %rcx, %rax
	movq %rdx, %rbx
	movq %rbx, %rdx
	movq %rax, %r8
	movq %r12, %r14
.p2align 4
.Lbb16593:
	cmpq $0, %rsi
	jz .Lbb16602
	movq %r8, %rax
	shrq $40, %rax
	andq $65535, %rax
	cmpq $17, %rax
	jz .Lbb16600
	cmpq $18, %rax
	jnz .Lbb16598
	movq %rdx, %r12
	leaq -72(%rbp), %rdx
	movq %r8, %rsi
	movq %rdi, %rbx
	callq p125_rt_take2
	movq %r12, %rdx
	movq %rbx, %rdi
	movq -72(%rbp), %rsi
	movq -64(%rbp), %rbx
	movq %rsi, %r13
	movq %rdx, %rsi
	movq %rdi, %r12
	callq p111_rt_keep
	movq %r13, %rsi
	movq %r12, %rdi
	movq %rax, %r13
	movq %rdi, %r12
	callq p111_rt_keep
	movq %r13, %rdx
	movq %r12, %rdi
	movq %rax, %r14
	movq %rdx, %r13
	movq %r14, %rdx
	movq %r13, %rsi
	movq %rdi, %r12
	callq p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_107_101_121_95_101_113_
	movq %r14, %r8
	movq %r13, %rdx
	movq %r12, %rdi
	movq %rax, %r9
	movl $0, %esi
	movq %rbx, %r14
	jmp .Lbb16593
.Lbb16598:
	movq %rdx, %rsi
	movq %rdi, %rbx
	callq p111_rt_sink
	movq %rbx, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movl $0, %eax
	jmp .Lbb16610
.Lbb16600:
	movq %rdx, %rsi
	movq %rsi, %r12
	movq $144142675917963786, %rsi
	movq %rdi, %rbx
	callq p113d_FID_36_100_105_114_101_99_116_46_97_116_111_109_
	movq %r12, %rsi
	movq %rbx, %rdi
	movq %rax, %rbx
	movq %rsi, %r13
	movq $144142675917963786, %rsi
	movq %rdi, %r12
	callq p113d_FID_36_100_105_114_101_99_116_46_97_116_111_109_
	movq %r13, %rsi
	movq %r12, %rdi
	movq %rsi, -72(%rbp)
	movq $144142675917967716, %rcx
	movq %rcx, -64(%rbp)
	movq $0, -56(%rbp)
	movq $0, -48(%rbp)
	movq %rbx, -40(%rbp)
	movq %rax, -32(%rbp)
	movq $72076285735600128, %rax
	movq %rax, -24(%rbp)
	movq $0, -16(%rbp)
	movq $0, -8(%rbp)
	movl $9, %ecx
	leaq -72(%rbp), %rdx
	movl $153, %esi
	callq p111_rt_ctor
	jmp .Lbb16610
.Lbb16602:
	movq %rdx, %r13
	cmpq $1, %r9
	setz %al
	movzbl %al, %eax
	movq %r9, %rcx
	shrq $40, %rcx
	andq $8388607, %rcx
	cmpq $65538, %rcx
	setz %cl
	movzbl %cl, %ecx
	movl %eax, %ebx
	orl %ecx, %ebx
	jnz .Lbb16608
	movq %r8, %rsi
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r14, %r8
	movq %r13, %rdx
	movq %r12, %rdi
	movl %ebx, %eax
	xorl $1, %eax
	jz .Lbb16606
	movl $1, %esi
	movl $0, %r14d
	movl $0, %r9d
	jmp .Lbb16593
.Lbb16606:
	movq %rdx, %rsi
	movq %r8, %r14
	movq %rdi, %rbx
	callq p111_rt_sink
	movq %rbx, %rdi
	movq %r14, %rsi
	movq %rdi, %rbx
	callq p111_rt_sink
	movq %rbx, %rdi
	movl $4, %esi
	callq p111_rt_fail
	movl $0, %eax
	jmp .Lbb16610
.Lbb16608:
	movq %r13, %rsi
	movq %r8, %rbx
	movq %rdi, %r12
	callq p111_rt_sink
	movq %r12, %rdi
	movq %r14, %rsi
	callq p111_rt_sink
	movq %rbx, %rax
.Lbb16610:
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.type p113d_FID_36_112_49_50_54_115_99_99_46_49_53_49_52_, @function
.size p113d_FID_36_112_49_50_54_115_99_99_46_49_53_49_52_, .-p113d_FID_36_112_49_50_54_115_99_99_46_49_53_49_52_
