
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-references02/memory-dependence-sequential/qbe/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000406cb0 <p113d_FID_36_112_114_111_100_117_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_>:
  406cb0:	endbr64 
  406cb4:	push   %rbp
  406cb5:	mov    %rsp,%rbp
  406cb8:	sub    $0x800,%rsp
  406cbf:	push   %rbx
  406cc0:	push   %r12
  406cc2:	mov    %esi,%eax
  406cc4:	add    $0x1,%eax
  406cc7:	mov    %eax,%eax
  406cc9:	and    $0xff,%rax
  406ccf:	mov    %edx,%edx
  406cd1:	mov    %r8d,%esi
  406cd4:	add    %esi,%edx
  406cd6:	mov    %edx,%ebx
  406cd8:	mov    %rcx,-0x800(%rbp)
  406cdf:	mov    %rax,-0x7f8(%rbp)
  406ce6:	lea    -0x800(%rbp),%rdx
  406ced:	mov    $0x8,%esi
  406cf2:	mov    %rdi,%r12
  406cf5:	callq  414d30 <p125_rt_ctor2>
  406cfa:	mov    %r12,%rdi
  406cfd:	mov    %rax,-0x800(%rbp)
  406d04:	mov    %rbx,-0x7f8(%rbp)
  406d0b:	lea    -0x800(%rbp),%rdx
  406d12:	mov    $0x8,%esi
  406d17:	callq  414d30 <p125_rt_ctor2>
  406d1c:	pop    %r12
  406d1e:	pop    %rbx
  406d1f:	leaveq 
  406d20:	retq   

Disassembly of section .fini:
