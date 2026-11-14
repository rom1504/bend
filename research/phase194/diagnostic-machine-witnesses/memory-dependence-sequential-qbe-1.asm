
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-references02/memory-dependence-sequential/qbe/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000406be0 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_>:
  406be0:	endbr64 
  406be4:	push   %rbp
  406be5:	mov    %rsp,%rbp
  406be8:	sub    $0x808,%rsp
  406bef:	push   %rbx
  406bf0:	push   %r12
  406bf2:	push   %r13
  406bf4:	mov    %rsi,%rbx
  406bf7:	mov    %rcx,%rsi
  406bfa:	mov    %rsi,%rax
  406bfd:	shr    $0x28,%rax
  406c01:	and    $0xffff,%rax
  406c07:	cmp    $0x8,%rax
  406c0b:	je     406c25 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0x45>
  406c0d:	cs cs cs cs mov $0x4,%esi
  406c16:	callq  40f810 <p111_rt_fail>
  406c1b:	mov    $0x0,%eax
  406c20:	jmpq   406ca5 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_+0xc5>
  406c25:	mov    %rdx,%r13
  406c28:	lea    -0x800(%rbp),%rdx
  406c2f:	mov    %rdi,%r12
  406c32:	callq  414e20 <p125_rt_take2>
  406c37:	mov    %r13,%rdx
  406c3a:	mov    %r12,%rdi
  406c3d:	mov    -0x800(%rbp),%rcx
  406c44:	mov    -0x7f8(%rbp),%rsi
  406c4b:	mov    %ebx,%eax
  406c4d:	add    $0x1,%eax
  406c50:	mov    %eax,%eax
  406c52:	and    $0xff,%eax
  406c57:	mov    %eax,%eax
  406c59:	mov    %edx,%edx
  406c5b:	mov    %esi,%esi
  406c5d:	add    %esi,%edx
  406c5f:	mov    %edx,%ebx
  406c61:	mov    %rcx,-0x800(%rbp)
  406c68:	mov    %rax,-0x7f8(%rbp)
  406c6f:	lea    -0x800(%rbp),%rdx
  406c76:	mov    $0x8,%esi
  406c7b:	mov    %rdi,%r12
  406c7e:	callq  414d30 <p125_rt_ctor2>
  406c83:	mov    %r12,%rdi
  406c86:	mov    %rax,-0x800(%rbp)
  406c8d:	mov    %rbx,-0x7f8(%rbp)
  406c94:	lea    -0x800(%rbp),%rdx
  406c9b:	mov    $0x8,%esi
  406ca0:	callq  414d30 <p125_rt_ctor2>
  406ca5:	pop    %r13
  406ca7:	pop    %r12
  406ca9:	pop    %rbx
  406caa:	leaveq 
  406cab:	retq   

Disassembly of section .fini:
