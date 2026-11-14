
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-references02/memory-dependence-sequential/qbe/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000406d30 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_>:
  406d30:	endbr64 
  406d34:	push   %rbp
  406d35:	mov    %rsp,%rbp
  406d38:	sub    $0x810,%rsp
  406d3f:	push   %rbx
  406d40:	push   %r12
  406d42:	push   %r13
  406d44:	push   %r14
  406d46:	mov    (%rdi),%rbx
  406d49:	mov    %rsi,%rax
  406d4c:	shr    $0x28,%rax
  406d50:	and    $0xffff,%rax
  406d56:	cmp    $0x8,%rax
  406d5a:	je     406d70 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x40>
  406d5c:	mov    $0x4,%esi
  406d61:	callq  40f810 <p111_rt_fail>
  406d66:	mov    $0x0,%eax
  406d6b:	jmpq   406e9f <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x16f>
  406d70:	cs cs lea %cs:-0x810(%rbp),%rdx
  406d7a:	mov    %rdi,%r12
  406d7d:	callq  414e20 <p125_rt_take2>
  406d82:	mov    %r12,%rdi
  406d85:	mov    -0x810(%rbp),%rsi
  406d8c:	mov    -0x808(%rbp),%rdx
  406d93:	mov    %rsi,%rax
  406d96:	shr    $0x28,%rax
  406d9a:	and    $0xffff,%rax
  406da0:	cmp    $0x8,%rax
  406da4:	je     406dba <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x8a>
  406da6:	mov    $0x4,%esi
  406dab:	callq  40f810 <p111_rt_fail>
  406db0:	mov    $0x0,%eax
  406db5:	jmpq   406e9f <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x16f>
  406dba:	cs mov %rdx,%r13
  406dbe:	lea    -0x810(%rbp),%rdx
  406dc5:	mov    %rdi,%r12
  406dc8:	callq  414e20 <p125_rt_take2>
  406dcd:	mov    %r13,%rdx
  406dd0:	mov    %r12,%rdi
  406dd3:	mov    -0x810(%rbp),%rcx
  406dda:	mov    -0x808(%rbp),%rsi
  406de1:	mov    %rcx,-0x810(%rbp)
  406de8:	mov    %rsi,-0x808(%rbp)
  406def:	mov    %rcx,%rax
  406df2:	shr    $0x38,%rax
  406df6:	cmp    $0x4,%rax
  406dfa:	sete   %r8b
  406dfe:	movzbl %r8b,%r8d
  406e02:	movabs $0xffffffffff,%rax
  406e0c:	and    %rcx,%rax
  406e0f:	cmp    $0x3108280,%rax
  406e15:	setae  %r9b
  406e19:	movzbl %r9b,%r9d
  406e1d:	and    %r9d,%r8d
  406e20:	cmp    $0x0,%r8d
  406e24:	jne    406e62 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x132>
  406e26:	cs cs mov $0x2,%r9d
  406e2e:	lea    -0x10(%rbp),%r8
  406e32:	mov    %rcx,%r14
  406e35:	mov    $0x2,%ecx
  406e3a:	mov    %rdx,%r13
  406e3d:	lea    -0x810(%rbp),%rdx
  406e44:	mov    %rsi,%r12
  406e47:	mov    $0x48,%esi
  406e4c:	mov    %rdi,%rbx
  406e4f:	callq  4130f0 <p113_rt_array_pair>
  406e54:	mov    %r14,%rcx
  406e57:	mov    %r13,%rdx
  406e5a:	mov    %r12,%rsi
  406e5d:	mov    %rbx,%rdi
  406e60:	jmp    406e96 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x166>
  406e62:	mov    %rcx,%r12
  406e65:	shr    $0x28,%rcx
  406e69:	and    $0x1f,%rcx
  406e6d:	mov    $0x1,%r8d
  406e73:	shl    %cl,%r8
  406e76:	mov    %r12,%rcx
  406e79:	sub    $0x1,%r8
  406e7d:	and    %rsi,%r8
  406e80:	shl    $0x3,%rax
  406e84:	shl    $0x2,%r8
  406e88:	add    %r8,%rax
  406e8b:	mov    (%rbx,%rax,1),%eax
  406e8e:	mov    %rcx,-0x10(%rbp)
  406e92:	mov    %rax,-0x8(%rbp)
  406e96:	mov    -0x8(%rbp),%r8
  406e9a:	callq  406cb0 <p113d_FID_36_112_114_111_100_117_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_>
  406e9f:	pop    %r14
  406ea1:	pop    %r13
  406ea3:	pop    %r12
  406ea5:	pop    %rbx
  406ea6:	leaveq 
  406ea7:	retq   

Disassembly of section .fini:
