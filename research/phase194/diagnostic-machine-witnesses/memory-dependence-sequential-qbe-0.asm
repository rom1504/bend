
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-references02/memory-dependence-sequential/qbe/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000406eb0 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_>:
  406eb0:	endbr64 
  406eb4:	push   %rbp
  406eb5:	mov    %rsp,%rbp
  406eb8:	push   %rbx
  406eb9:	push   %r12
  406ebb:	mov    %rdx,%rax
  406ebe:	mov    %rax,%rdx
  406ec1:	data16 nopw %cs:0x0(%rax,%rax,1)
  406ecc:	nopl   0x0(%rax)
  406ed0:	cmp    $0x0,%rsi
  406ed4:	je     406ef3 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x43>
  406ed6:	sub    $0x1,%rsi
  406eda:	mov    %rsi,%r12
  406edd:	mov    %rdx,%rsi
  406ee0:	mov    %rdi,%rbx
  406ee3:	callq  406d30 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_>
  406ee8:	mov    %r12,%rsi
  406eeb:	mov    %rbx,%rdi
  406eee:	mov    %rax,%rdx
  406ef1:	jmp    406ed0 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x20>
  406ef3:	mov    %rdx,%rax
  406ef6:	pop    %r12
  406ef8:	pop    %rbx
  406ef9:	leaveq 
  406efa:	retq   

Disassembly of section .fini:
