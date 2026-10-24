
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-record-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000408dd0 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_114_101_99_111_114_100_95_113_117_101_114_121_>:
  408dd0:	endbr64 
  408dd4:	cs cs cs cs cs push %rbp
  408dda:	cs cs mov %rsp,%rbp
  408ddf:	sub    $0x838,%rsp
  408de6:	push   %rbx
  408de7:	push   %r12
  408de9:	push   %r13
  408deb:	push   %r14
  408ded:	push   %r15
  408def:	mov    %rdx,%rax
  408df2:	mov    %rax,%rcx
  408df5:	shr    $0x28,%rcx
  408df9:	and    $0xffff,%rcx
  408e00:	cmp    $0x9c,%rcx
  408e07:	je     408e2b <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_114_101_99_111_114_100_95_113_117_101_114_121_+0x5b>
  408e09:	mov    %rsi,%r12
  408e0c:	mov    %rdi,%rbx
  408e0f:	callq  4312c0 <p111_rt_sink>
  408e14:	mov    %rbx,%rdi
  408e17:	mov    $0x4,%esi
  408e1c:	callq  431a50 <p111_rt_fail>
  408e21:	mov    $0x0,%eax
  408e26:	jmpq   408f73 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_114_101_99_111_114_100_95_113_117_101_114_121_+0x1a3>
  408e2b:	mov    %rsi,%r12
  408e2e:	mov    %rax,%rsi
  408e31:	mov    $0x9,%ecx
  408e36:	lea    -0x830(%rbp),%rdx
  408e3d:	mov    %rdi,%rbx
  408e40:	callq  4314b0 <p111_rt_take>
  408e45:	mov    %rbx,%rdi
  408e48:	mov    -0x830(%rbp),%r13
  408e4f:	mov    -0x828(%rbp),%rsi
  408e56:	mov    -0x820(%rbp),%r14
  408e5d:	mov    -0x818(%rbp),%r15
  408e64:	mov    -0x810(%rbp),%rbx
  408e6b:	mov    %rbx,-0x10(%rbp)
  408e6f:	mov    -0x808(%rbp),%rbx
  408e76:	mov    %rbx,-0x18(%rbp)
  408e7a:	mov    -0x800(%rbp),%rbx
  408e81:	mov    %rbx,-0x20(%rbp)
  408e85:	mov    -0x7f8(%rbp),%rbx
  408e8c:	mov    %rbx,-0x28(%rbp)
  408e90:	mov    -0x7f0(%rbp),%rbx
  408e97:	mov    %rbx,-0x30(%rbp)
  408e9b:	mov    %rdi,%rbx
  408e9e:	callq  4312c0 <p111_rt_sink>
  408ea3:	mov    %r14,%rsi
  408ea6:	mov    %rbx,%rdi
  408ea9:	mov    -0x10(%rbp),%r14
  408ead:	mov    %rdi,%rbx
  408eb0:	callq  4312c0 <p111_rt_sink>
  408eb5:	mov    %r15,%rsi
  408eb8:	mov    %rbx,%rdi
  408ebb:	mov    -0x18(%rbp),%r15
  408ebf:	mov    %rdi,%rbx
  408ec2:	callq  4312c0 <p111_rt_sink>
  408ec7:	mov    %r14,%rsi
  408eca:	mov    %rbx,%rdi
  408ecd:	mov    -0x20(%rbp),%r14
  408ed1:	mov    %rdi,%rbx
  408ed4:	callq  4312c0 <p111_rt_sink>
  408ed9:	mov    %r15,%rsi
  408edc:	mov    %rbx,%rdi
  408edf:	mov    -0x28(%rbp),%r15
  408ee3:	mov    %rdi,%rbx
  408ee6:	callq  4312c0 <p111_rt_sink>
  408eeb:	mov    %r14,%rsi
  408eee:	mov    %rbx,%rdi
  408ef1:	mov    -0x30(%rbp),%r14
  408ef5:	mov    %rdi,%rbx
  408ef8:	callq  4312c0 <p111_rt_sink>
  408efd:	mov    %r15,%rsi
  408f00:	mov    %rbx,%rdi
  408f03:	mov    %rdi,%rbx
  408f06:	callq  4312c0 <p111_rt_sink>
  408f0b:	mov    %r14,%rsi
  408f0e:	mov    %rbx,%rdi
  408f11:	mov    %rdi,%rbx
  408f14:	callq  4312c0 <p111_rt_sink>
  408f19:	mov    %r13,%rsi
  408f1c:	mov    %rbx,%rdi
  408f1f:	mov    %rdi,%rbx
  408f22:	callq  431230 <p111_rt_keep>
  408f27:	mov    %r12,%rsi
  408f2a:	mov    %rbx,%rdi
  408f2d:	mov    %rax,%r12
  408f30:	mov    %rdi,%rbx
  408f33:	callq  431230 <p111_rt_keep>
  408f38:	mov    %r12,%rsi
  408f3b:	mov    %rbx,%rdi
  408f3e:	mov    %rax,%r13
  408f41:	mov    $0x1,%ecx
  408f46:	mov    %r13,%rdx
  408f49:	mov    %rsi,%r12
  408f4c:	mov    %rdi,%rbx
  408f4f:	callq  405c00 <p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_95_103_111_>
  408f54:	mov    %r12,%rsi
  408f57:	mov    %rbx,%rdi
  408f5a:	mov    %rax,%rbx
  408f5d:	mov    %rdi,%r12
  408f60:	callq  4312c0 <p111_rt_sink>
  408f65:	mov    %r13,%rsi
  408f68:	mov    %r12,%rdi
  408f6b:	callq  4312c0 <p111_rt_sink>
  408f70:	mov    %rbx,%rax
  408f73:	pop    %r15
  408f75:	pop    %r14
  408f77:	pop    %r13
  408f79:	pop    %r12
  408f7b:	pop    %rbx
  408f7c:	leaveq 
  408f7d:	retq   

Disassembly of section .fini:
