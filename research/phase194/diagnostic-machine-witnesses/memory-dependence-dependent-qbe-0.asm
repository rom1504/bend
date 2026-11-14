
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-references02/memory-dependence-dependent/qbe/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000406e80 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_>:
  406e80:	endbr64 
  406e84:	push   %rbp
  406e85:	mov    %rsp,%rbp
  406e88:	push   %rbx
  406e89:	push   %r12
  406e8b:	mov    %rdx,%rax
  406e8e:	mov    %rax,%rdx
  406e91:	data16 nopw %cs:0x0(%rax,%rax,1)
  406e9c:	nopl   0x0(%rax)
  406ea0:	cmp    $0x0,%rsi
  406ea4:	je     406ec3 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x43>
  406ea6:	sub    $0x1,%rsi
  406eaa:	mov    %rsi,%r12
  406ead:	mov    %rdx,%rsi
  406eb0:	mov    %rdi,%rbx
  406eb3:	callq  406d00 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_>
  406eb8:	mov    %r12,%rsi
  406ebb:	mov    %rbx,%rdi
  406ebe:	mov    %rax,%rdx
  406ec1:	jmp    406ea0 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x20>
  406ec3:	mov    %rdx,%rax
  406ec6:	pop    %r12
  406ec8:	pop    %rbx
  406ec9:	leaveq 
  406eca:	retq   

Disassembly of section .fini:
