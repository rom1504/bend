
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-queries-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040c9e0 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_>:
  40c9e0:	endbr64 
  40c9e4:	push   %rbp
  40c9e5:	mov    %rsp,%rbp
  40c9e8:	sub    $0x810,%rsp
  40c9ef:	push   %rbx
  40c9f0:	push   %r12
  40c9f2:	push   %r13
  40c9f4:	push   %r14
  40c9f6:	mov    %rdx,%rbx
  40c9f9:	mov    %rbx,%rdx
  40c9fc:	nopl   0x0(%rax)
  40ca00:	mov    %rsi,%rax
  40ca03:	shr    $0x28,%rax
  40ca07:	and    $0xffff,%rax
  40ca0d:	cmp    $0x11,%rax
  40ca11:	je     40cd8d <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x3ad>
  40ca17:	nopw   0x0(%rax,%rax,1)
  40ca20:	cmp    $0x12,%rax
  40ca24:	jne    40cd7c <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x39c>
  40ca2a:	mov    %rdx,%r14
  40ca2d:	lea    -0x810(%rbp),%rdx
  40ca34:	mov    %rdi,%rbx
  40ca37:	callq  437750 <p125_rt_take2>
  40ca3c:	mov    %rbx,%rdi
  40ca3f:	mov    -0x810(%rbp),%rsi
  40ca46:	mov    -0x808(%rbp),%r13
  40ca4d:	mov    %rdi,%rbx
  40ca50:	callq  431f10 <p111_rt_keep>
  40ca55:	mov    %rbx,%rdi
  40ca58:	mov    %rax,%rsi
  40ca5b:	mov    %rsi,%r12
  40ca5e:	mov    %rdi,%rbx
  40ca61:	callq  40acd0 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_105_115_95_99_97_99_104_101_>
  40ca66:	mov    %r14,%rdx
  40ca69:	mov    %r12,%rsi
  40ca6c:	mov    %rbx,%rdi
  40ca6f:	mov    %rax,%rcx
  40ca72:	cmp    $0x1,%rcx
  40ca76:	sete   %al
  40ca79:	movzbl %al,%eax
  40ca7c:	shr    $0x28,%rcx
  40ca80:	and    $0x7fffff,%rcx
  40ca87:	cmp    $0x10002,%rcx
  40ca8e:	sete   %cl
  40ca91:	movzbl %cl,%ecx
  40ca94:	or     %ecx,%eax
  40ca96:	jne    40cc73 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x293>
  40ca9c:	cs xor $0x1,%eax
  40caa0:	je     40cc2c <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x24c>
  40caa6:	mov    $0x0,%ecx
  40caab:	mov    %rdx,%r14
  40caae:	lea    -0x810(%rbp),%rdx
  40cab5:	mov    %rsi,%r12
  40cab8:	mov    $0x0,%esi
  40cabd:	mov    %rdi,%rbx
  40cac0:	callq  432010 <p111_rt_ctor>
  40cac5:	mov    %rbx,%rdi
  40cac8:	mov    %rax,%rsi
  40cacb:	mov    %rdi,%rbx
  40cace:	callq  431fa0 <p111_rt_sink>
  40cad3:	mov    %r14,%rdx
  40cad6:	mov    %r12,%rsi
  40cad9:	mov    %rbx,%rdi
  40cadc:	mov    %rsi,%r12
  40cadf:	mov    %rdx,%rsi
  40cae2:	mov    %rdi,%rbx
  40cae5:	callq  431f10 <p111_rt_keep>
  40caea:	mov    %r12,%rsi
  40caed:	mov    %rbx,%rdi
  40caf0:	mov    %rax,%r12
  40caf3:	mov    %rdi,%rbx
  40caf6:	callq  431f10 <p111_rt_keep>
  40cafb:	mov    %r12,%rdx
  40cafe:	mov    %rbx,%rdi
  40cb01:	mov    %rax,%rsi
  40cb04:	mov    %rdx,%r14
  40cb07:	mov    %rsi,%rdx
  40cb0a:	mov    %rsi,%r12
  40cb0d:	mov    %r14,%rsi
  40cb10:	mov    %rdi,%rbx
  40cb13:	callq  40aa10 <p113d_FID_36_100_105_114_101_99_116_46_112_49_51_55_113_95_110_97_109_101_95_101_113_>
  40cb18:	mov    %r12,%rsi
  40cb1b:	mov    %rbx,%rdi
  40cb1e:	mov    %rax,%rcx
  40cb21:	cmp    $0x1,%rcx
  40cb25:	sete   %al
  40cb28:	movzbl %al,%eax
  40cb2b:	shr    $0x28,%rcx
  40cb2f:	and    $0x7fffff,%rcx
  40cb36:	cmp    $0x10002,%rcx
  40cb3d:	sete   %cl
  40cb40:	movzbl %cl,%ecx
  40cb43:	mov    %eax,%ebx
  40cb45:	or     %ecx,%ebx
  40cb47:	jne    40cbdb <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x1fb>
  40cb4d:	mov    %rdi,%r12
  40cb50:	callq  431fa0 <p111_rt_sink>
  40cb55:	mov    %r14,%rdx
  40cb58:	mov    %r13,%rsi
  40cb5b:	mov    %r12,%rdi
  40cb5e:	mov    %ebx,%eax
  40cb60:	xor    $0x1,%eax
  40cb63:	je     40cba5 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x1c5>
  40cb65:	cs cs cs cs cs mov $0x0,%ecx
  40cb6f:	mov    %rdx,%r13
  40cb72:	lea    -0x810(%rbp),%rdx
  40cb79:	mov    %rsi,%r12
  40cb7c:	mov    $0x0,%esi
  40cb81:	mov    %rdi,%rbx
  40cb84:	callq  432010 <p111_rt_ctor>
  40cb89:	mov    %rbx,%rdi
  40cb8c:	mov    %rax,%rsi
  40cb8f:	mov    %rdi,%rbx
  40cb92:	callq  431fa0 <p111_rt_sink>
  40cb97:	mov    %r13,%rdx
  40cb9a:	mov    %r12,%rsi
  40cb9d:	mov    %rbx,%rdi
  40cba0:	jmpq   40ca00 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x20>
  40cba5:	mov    %rsi,%r12
  40cba8:	mov    %rdx,%rsi
  40cbab:	mov    %rdi,%rbx
  40cbae:	callq  431fa0 <p111_rt_sink>
  40cbb3:	mov    %r12,%rsi
  40cbb6:	mov    %rbx,%rdi
  40cbb9:	mov    %rsi,%r13
  40cbbc:	mov    %rdi,%rbx
  40cbbf:	callq  431fa0 <p111_rt_sink>
  40cbc4:	mov    %rbx,%rdi
  40cbc7:	mov    $0x4,%esi
  40cbcc:	callq  432730 <p111_rt_fail>
  40cbd1:	mov    $0x0,%eax
  40cbd6:	jmpq   40cd9f <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x3bf>
  40cbdb:	mov    %rsi,%rbx
  40cbde:	mov    %r14,%rsi
  40cbe1:	mov    %rsi,%r12
  40cbe4:	mov    %rdi,%r12
  40cbe7:	callq  431fa0 <p111_rt_sink>
  40cbec:	mov    %r13,%rsi
  40cbef:	mov    %r12,%rdi
  40cbf2:	mov    %rsi,%r12
  40cbf5:	mov    %rdi,%r12
  40cbf8:	callq  431fa0 <p111_rt_sink>
  40cbfd:	mov    %r12,%rdi
  40cc00:	mov    $0x0,%ecx
  40cc05:	lea    -0x810(%rbp),%rdx
  40cc0c:	mov    $0x0,%esi
  40cc11:	mov    %rdi,%r12
  40cc14:	callq  432010 <p111_rt_ctor>
  40cc19:	mov    %r12,%rdi
  40cc1c:	mov    %rax,%rsi
  40cc1f:	callq  431fa0 <p111_rt_sink>
  40cc24:	mov    %rbx,%rax
  40cc27:	jmpq   40cd9f <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x3bf>
  40cc2c:	mov    %r13,%r12
  40cc2f:	mov    %rsi,%r13
  40cc32:	mov    %rdx,%rsi
  40cc35:	mov    %rdi,%rbx
  40cc38:	callq  431fa0 <p111_rt_sink>
  40cc3d:	mov    %r13,%rsi
  40cc40:	mov    %rbx,%rdi
  40cc43:	mov    %rsi,%r13
  40cc46:	mov    %rdi,%rbx
  40cc49:	callq  431fa0 <p111_rt_sink>
  40cc4e:	mov    %r12,%rsi
  40cc51:	mov    %rbx,%rdi
  40cc54:	mov    %rdi,%rbx
  40cc57:	callq  431fa0 <p111_rt_sink>
  40cc5c:	mov    %rbx,%rdi
  40cc5f:	mov    $0x4,%esi
  40cc64:	callq  432730 <p111_rt_fail>
  40cc69:	mov    $0x0,%eax
  40cc6e:	jmpq   40cd9f <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x3bf>
  40cc73:	xchg   %rsi,%r13
  40cc76:	mov    %rdx,%r12
  40cc79:	mov    %rdi,%rbx
  40cc7c:	callq  431fa0 <p111_rt_sink>
  40cc81:	mov    %r13,%rsi
  40cc84:	mov    %rbx,%rdi
  40cc87:	mov    $0x0,%ecx
  40cc8c:	lea    -0x810(%rbp),%rdx
  40cc93:	mov    %rsi,%r13
  40cc96:	mov    $0x0,%esi
  40cc9b:	mov    %rdi,%rbx
  40cc9e:	callq  432010 <p111_rt_ctor>
  40cca3:	mov    %rbx,%rdi
  40cca6:	mov    %rax,%rsi
  40cca9:	mov    %rdi,%rbx
  40ccac:	callq  431fa0 <p111_rt_sink>
  40ccb1:	mov    %r13,%rsi
  40ccb4:	mov    %rbx,%rdi
  40ccb7:	mov    %rdi,%rbx
  40ccba:	callq  4076f0 <p113d_FID_36_100_105_114_101_99_116_46_100_99_>
  40ccbf:	mov    %r12,%rsi
  40ccc2:	mov    %rbx,%rdi
  40ccc5:	mov    %rax,%rcx
  40ccc8:	shr    $0x28,%rcx
  40cccc:	and    $0xffff,%rcx
  40ccd3:	cmp    $0x11,%rcx
  40ccd7:	je     40cd2f <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x34f>
  40ccd9:	cmp    $0x12,%rcx
  40ccdd:	je     40ccfc <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x31c>
  40ccdf:	mov    %rsi,%r12
  40cce2:	mov    $0x4,%esi
  40cce7:	mov    %rdi,%rbx
  40ccea:	callq  432730 <p111_rt_fail>
  40ccef:	mov    %rbx,%rdi
  40ccf2:	mov    %r12,%rsi
  40ccf5:	mov    $0x0,%ebx
  40ccfa:	jmp    40cd39 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x359>
  40ccfc:	mov    %rsi,%r12
  40ccff:	mov    %rax,%rsi
  40cd02:	lea    -0x10(%rbp),%rdx
  40cd06:	mov    %rdi,%rbx
  40cd09:	callq  437750 <p125_rt_take2>
  40cd0e:	mov    %r12,%rsi
  40cd11:	mov    %rbx,%rdi
  40cd14:	mov    -0x10(%rbp),%rbx
  40cd18:	mov    %rsi,%r13
  40cd1b:	mov    -0x8(%rbp),%rsi
  40cd1f:	mov    %rdi,%r12
  40cd22:	callq  431fa0 <p111_rt_sink>
  40cd27:	mov    %r13,%rsi
  40cd2a:	mov    %r12,%rdi
  40cd2d:	jmp    40cd39 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x359>
  40cd2f:	movabs $0x2009900031086df,%rbx
  40cd39:	mov    %rbx,%r12
  40cd3c:	mov    %rdi,%rbx
  40cd3f:	callq  431f10 <p111_rt_keep>
  40cd44:	mov    %r12,%rsi
  40cd47:	mov    %rbx,%rdi
  40cd4a:	mov    %rax,%rdx
  40cd4d:	mov    %rdx,%r13
  40cd50:	mov    $0x811c9dc5,%edx
  40cd55:	mov    %rsi,%r12
  40cd58:	mov    %r13,%rsi
  40cd5b:	mov    %rdi,%rbx
  40cd5e:	callq  405590 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_104_97_115_104_>
  40cd63:	mov    %r13,%rdx
  40cd66:	mov    %r12,%rsi
  40cd69:	mov    %rbx,%rdi
  40cd6c:	mov    %rax,%rcx
  40cd6f:	mov    $0x20,%r8d
  40cd75:	callq  40bfb0 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_>
  40cd7a:	jmp    40cd9f <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x3bf>
  40cd7c:	mov    $0x4,%esi
  40cd81:	callq  432730 <p111_rt_fail>
  40cd86:	mov    $0x0,%eax
  40cd8b:	jmp    40cd9f <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x3bf>
  40cd8d:	mov    %rdx,%rsi
  40cd90:	callq  431fa0 <p111_rt_sink>
  40cd95:	movabs $0x2009900031086df,%rax
  40cd9f:	pop    %r14
  40cda1:	pop    %r13
  40cda3:	pop    %r12
  40cda5:	pop    %rbx
  40cda6:	leaveq 
  40cda7:	retq   

Disassembly of section .fini:
