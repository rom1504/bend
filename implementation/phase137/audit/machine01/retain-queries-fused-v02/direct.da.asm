
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-queries-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000407c40 <p113d_FID_36_100_105_114_101_99_116_46_100_97_>:
  407c40:	endbr64 
  407c44:	push   %rbp
  407c45:	mov    %rsp,%rbp
  407c48:	push   %rbx
  407c49:	push   %r12
  407c4b:	mov    $0x1,%ecx
  407c50:	mov    $0x0,%edx
  407c55:	mov    %rsi,%r12
  407c58:	mov    %rdi,%rbx
  407c5b:	callq  437e00 <p118_rt_borrow_scalar_safe>
  407c60:	mov    %r12,%rsi
  407c63:	mov    %rbx,%rdi
  407c66:	cmp    $0x0,%rax
  407c6a:	jne    407c73 <p113d_FID_36_100_105_114_101_99_116_46_100_97_+0x33>
  407c6c:	callq  4078d0 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_100_97_>
  407c71:	jmp    407c8f <p113d_FID_36_100_105_114_101_99_116_46_100_97_+0x4f>
  407c73:	mov    %rsi,%r12
  407c76:	mov    %rdi,%rbx
  407c79:	callq  407a90 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_97_>
  407c7e:	mov    %r12,%rsi
  407c81:	mov    %rbx,%rdi
  407c84:	mov    %rax,%rbx
  407c87:	callq  431fa0 <p111_rt_sink>
  407c8c:	mov    %rbx,%rax
  407c8f:	pop    %r12
  407c91:	pop    %rbx
  407c92:	leaveq 
  407c93:	retq   

Disassembly of section .fini:
