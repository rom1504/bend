
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-record-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000408f80 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_114_101_99_111_114_100_95_113_117_101_114_121_>:
  408f80:	endbr64 
  408f84:	push   %rbp
  408f85:	mov    %rsp,%rbp
  408f88:	sub    $0x808,%rsp
  408f8f:	push   %rbx
  408f90:	push   %r12
  408f92:	push   %r13
  408f94:	mov    %rsi,%rcx
  408f97:	mov    %rdx,%rsi
  408f9a:	mov    %rsi,%rax
  408f9d:	shr    $0x28,%rax
  408fa1:	and    $0xffff,%rax
  408fa7:	cmp    $0x9c,%rax
  408fad:	je     408fc2 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_114_101_99_111_114_100_95_113_117_101_114_121_+0x42>
  408faf:	cs cs mov $0x4,%esi
  408fb6:	callq  431a50 <p111_rt_fail>
  408fbb:	mov    $0x0,%eax
  408fc0:	jmp    409036 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_114_101_99_111_114_100_95_113_117_101_114_121_+0xb6>
  408fc2:	mov    $0x9,%r8d
  408fc8:	mov    %rcx,%r12
  408fcb:	mov    $0x9c,%ecx
  408fd0:	lea    -0x800(%rbp),%rdx
  408fd7:	mov    %rdi,%rbx
  408fda:	callq  435cf0 <p118_rt_borrow_fields>
  408fdf:	mov    %r12,%rcx
  408fe2:	mov    %rbx,%rdi
  408fe5:	mov    -0x800(%rbp),%rdx
  408fec:	mov    %rcx,%r13
  408fef:	mov    $0x0,%ecx
  408ff4:	mov    %rdx,%r12
  408ff7:	lea    -0x800(%rbp),%rdx
  408ffe:	mov    $0x2,%esi
  409003:	mov    %rdi,%rbx
  409006:	callq  432bf0 <p111_rt_special_ctor>
  40900b:	mov    %r12,%rdx
  40900e:	mov    %rbx,%rdi
  409011:	mov    %rax,%rcx
  409014:	mov    %rdx,%r12
  409017:	mov    %r13,%rdx
  40901a:	mov    %r12,%rsi
  40901d:	mov    %rdi,%rbx
  409020:	callq  405870 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_56_56_95_115_116_114_105_110_103_95_101_113_95_103_111_>
  409025:	mov    %r13,%rcx
  409028:	mov    %r12,%rdx
  40902b:	mov    %rbx,%rdi
  40902e:	mov    %rax,%rsi
  409031:	callq  405cc0 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_57_56_95_101_113_95_102_105_110_105_115_104_>
  409036:	pop    %r13
  409038:	pop    %r12
  40903a:	pop    %rbx
  40903b:	leaveq 
  40903c:	retq   

Disassembly of section .fini:
