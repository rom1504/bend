
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-references02/memory-dependence-dependent/qbe/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000406be0 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_>:
  406be0:	endbr64 
  406be4:	push   %rbp
  406be5:	mov    %rsp,%rbp
  406be8:	sub    $0x800,%rsp
  406bef:	push   %rbx
  406bf0:	push   %r12
  406bf2:	mov    %rcx,%rsi
  406bf5:	mov    %rsi,%rax
  406bf8:	shr    $0x28,%rax
  406bfc:	and    $0xffff,%rax
  406c02:	cmp    $0x8,%rax
  406c06:	je     406c19 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x39>
  406c08:	mov    $0x4,%esi
  406c0d:	callq  40f7d0 <p111_rt_fail>
  406c12:	mov    $0x0,%eax
  406c17:	jmp    406c8b <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0xab>
  406c19:	mov    %rdx,%r12
  406c1c:	lea    -0x800(%rbp),%rdx
  406c23:	mov    %rdi,%rbx
  406c26:	callq  414de0 <p125_rt_take2>
  406c2b:	mov    %r12,%rdx
  406c2e:	mov    %rbx,%rdi
  406c31:	mov    -0x800(%rbp),%rcx
  406c38:	mov    -0x7f8(%rbp),%rax
  406c3f:	mov    %edx,%edx
  406c41:	mov    %eax,%esi
  406c43:	add    %esi,%edx
  406c45:	mov    %edx,%ebx
  406c47:	mov    %rcx,-0x800(%rbp)
  406c4e:	mov    %rax,-0x7f8(%rbp)
  406c55:	lea    -0x800(%rbp),%rdx
  406c5c:	mov    $0x8,%esi
  406c61:	mov    %rdi,%r12
  406c64:	callq  414cf0 <p125_rt_ctor2>
  406c69:	mov    %r12,%rdi
  406c6c:	mov    %rax,-0x800(%rbp)
  406c73:	mov    %rbx,-0x7f8(%rbp)
  406c7a:	lea    -0x800(%rbp),%rdx
  406c81:	mov    $0x8,%esi
  406c86:	callq  414cf0 <p125_rt_ctor2>
  406c8b:	pop    %r12
  406c8d:	pop    %rbx
  406c8e:	leaveq 
  406c8f:	retq   

Disassembly of section .fini:
