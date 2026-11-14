
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-references02/memory-dependence-dependent/qbe/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000406d00 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_>:
  406d00:	endbr64 
  406d04:	push   %rbp
  406d05:	mov    %rsp,%rbp
  406d08:	sub    $0x810,%rsp
  406d0f:	push   %rbx
  406d10:	push   %r12
  406d12:	push   %r13
  406d14:	push   %r14
  406d16:	mov    (%rdi),%rbx
  406d19:	mov    %rsi,%rax
  406d1c:	shr    $0x28,%rax
  406d20:	and    $0xffff,%rax
  406d26:	cmp    $0x8,%rax
  406d2a:	je     406d45 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x45>
  406d2c:	cs cs cs cs cs mov $0x4,%esi
  406d36:	callq  40f7d0 <p111_rt_fail>
  406d3b:	mov    $0x0,%eax
  406d40:	jmpq   406e6e <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x16e>
  406d45:	lea    -0x810(%rbp),%rdx
  406d4c:	mov    %rdi,%r12
  406d4f:	callq  414de0 <p125_rt_take2>
  406d54:	mov    %r12,%rdi
  406d57:	mov    -0x810(%rbp),%rsi
  406d5e:	mov    -0x808(%rbp),%rdx
  406d65:	mov    %rsi,%rax
  406d68:	shr    $0x28,%rax
  406d6c:	and    $0xffff,%rax
  406d72:	cmp    $0x8,%rax
  406d76:	je     406d8c <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x8c>
  406d78:	mov    $0x4,%esi
  406d7d:	callq  40f7d0 <p111_rt_fail>
  406d82:	mov    $0x0,%eax
  406d87:	jmpq   406e6e <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x16e>
  406d8c:	mov    %rdx,%r13
  406d8f:	lea    -0x810(%rbp),%rdx
  406d96:	mov    %rdi,%r12
  406d99:	callq  414de0 <p125_rt_take2>
  406d9e:	mov    %r13,%rdx
  406da1:	mov    %r12,%rdi
  406da4:	mov    -0x810(%rbp),%rcx
  406dab:	mov    -0x808(%rbp),%rsi
  406db2:	mov    %rcx,-0x810(%rbp)
  406db9:	mov    %rsi,-0x808(%rbp)
  406dc0:	mov    %rcx,%rax
  406dc3:	shr    $0x38,%rax
  406dc7:	cmp    $0x4,%rax
  406dcb:	sete   %r8b
  406dcf:	movzbl %r8b,%r8d
  406dd3:	movabs $0xffffffffff,%rax
  406ddd:	and    %rcx,%rax
  406de0:	cmp    $0x3108280,%rax
  406de6:	setae  %r9b
  406dea:	movzbl %r9b,%r9d
  406dee:	and    %r9d,%r8d
  406df1:	cmp    $0x0,%r8d
  406df5:	jne    406e31 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x131>
  406df7:	mov    $0x2,%r9d
  406dfd:	lea    -0x10(%rbp),%r8
  406e01:	mov    %rcx,%r14
  406e04:	mov    $0x2,%ecx
  406e09:	mov    %rdx,%r13
  406e0c:	lea    -0x810(%rbp),%rdx
  406e13:	mov    %rsi,%r12
  406e16:	mov    $0x48,%esi
  406e1b:	mov    %rdi,%rbx
  406e1e:	callq  4130b0 <p113_rt_array_pair>
  406e23:	mov    %r14,%rcx
  406e26:	mov    %r13,%rdx
  406e29:	mov    %r12,%rsi
  406e2c:	mov    %rbx,%rdi
  406e2f:	jmp    406e65 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x165>
  406e31:	mov    %rcx,%r12
  406e34:	shr    $0x28,%rcx
  406e38:	and    $0x1f,%rcx
  406e3c:	mov    $0x1,%r8d
  406e42:	shl    %cl,%r8
  406e45:	mov    %r12,%rcx
  406e48:	sub    $0x1,%r8
  406e4c:	and    %rsi,%r8
  406e4f:	shl    $0x3,%rax
  406e53:	shl    $0x2,%r8
  406e57:	add    %r8,%rax
  406e5a:	mov    (%rbx,%rax,1),%eax
  406e5d:	mov    %rcx,-0x10(%rbp)
  406e61:	mov    %rax,-0x8(%rbp)
  406e65:	mov    -0x8(%rbp),%r8
  406e69:	callq  406c90 <p113d_FID_36_112_114_111_100_117_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_>
  406e6e:	pop    %r14
  406e70:	pop    %r13
  406e72:	pop    %r12
  406e74:	pop    %rbx
  406e75:	leaveq 
  406e76:	retq   

Disassembly of section .fini:
