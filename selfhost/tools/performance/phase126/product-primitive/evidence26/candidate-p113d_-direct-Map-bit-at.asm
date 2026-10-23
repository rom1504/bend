
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p126-observer26-coverage-record-aggregation-256-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000406fb0 <p113d_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_46_97_116_>:
  406fb0:	endbr64 
  406fb4:	push   %rbp
  406fb5:	mov    %rsp,%rbp
  406fb8:	sub    $0x840,%rsp
  406fbf:	push   %rbx
  406fc0:	push   %r12
  406fc2:	xchg   %rdx,%rsi
  406fc5:	mov    %rsi,%rax
  406fc8:	shr    $0x28,%rax
  406fcc:	and    $0xffff,%rax
  406fd2:	cmp    $0x8,%rax
  406fd6:	je     406ff7 <p113d_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_46_97_116_+0x47>
  406fd8:	mov    %rdx,%rsi
  406fdb:	mov    %rdi,%rbx
  406fde:	callq  42f120 <p111_rt_sink>
  406fe3:	mov    %rbx,%rdi
  406fe6:	mov    $0x4,%esi
  406feb:	callq  42f8b0 <p111_rt_fail>
  406ff0:	mov    $0x0,%eax
  406ff5:	jmp    407053 <p113d_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_46_97_116_+0xa3>
  406ff7:	mov    %rdx,%r12
  406ffa:	lea    -0x840(%rbp),%rdx
  407001:	mov    %rdi,%rbx
  407004:	callq  4348d0 <p125_rt_take2>
  407009:	mov    %r12,%rdx
  40700c:	mov    %rbx,%rdi
  40700f:	mov    -0x840(%rbp),%rcx
  407016:	mov    -0x838(%rbp),%r8
  40701d:	lea    -0x40(%rbp),%rsi
  407021:	mov    %rdi,%rbx
  407024:	callq  4053b0 <p113d_FID_36_112_114_111_100_117_99_116_46_77_97_112_46_98_105_116_46_103_111_>
  407029:	mov    %rbx,%rdi
  40702c:	mov    -0x40(%rbp),%rcx
  407030:	mov    -0x38(%rbp),%rax
  407034:	mov    %rcx,-0x840(%rbp)
  40703b:	mov    %rax,-0x838(%rbp)
  407042:	lea    -0x840(%rbp),%rdx
  407049:	mov    $0x8,%esi
  40704e:	callq  4347e0 <p125_rt_ctor2>
  407053:	pop    %r12
  407055:	pop    %rbx
  407056:	leaveq 
  407057:	retq   

Disassembly of section .fini:
