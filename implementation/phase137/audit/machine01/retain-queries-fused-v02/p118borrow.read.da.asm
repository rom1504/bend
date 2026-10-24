
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-queries-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000407a90 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_97_>:
  407a90:	endbr64 
  407a94:	cs cs cs push %rbp
  407a98:	mov    %rsp,%rbp
  407a9b:	sub    $0x800,%rsp
  407aa2:	mov    %rsi,%rax
  407aa5:	shr    $0x28,%rax
  407aa9:	mov    %rax,%r9
  407aac:	and    $0xffff,%r9
  407ab3:	cmp    $0x99,%r9
  407aba:	sete   %al
  407abd:	movzbl %al,%eax
  407ac0:	cmp    $0x0,%eax
  407ac3:	jne    407c1c <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_97_+0x18c>
  407ac9:	cmp    $0x9a,%r9
  407ad0:	sete   %r10b
  407ad4:	movzbl %r10b,%r10d
  407ad8:	mov    %rsi,%rax
  407adb:	shr    $0x38,%rax
  407adf:	and    $0x7f,%rax
  407ae3:	cmp    $0x2,%rax
  407ae7:	sete   %r8b
  407aeb:	movzbl %r8b,%r8d
  407aef:	mov    %rsi,%rcx
  407af2:	shr    $0x3f,%rcx
  407af6:	movabs $0xffffffffff,%rax
  407b00:	and    %rsi,%rax
  407b03:	mov    %rax,%rdx
  407b06:	shl    $0x3,%rdx
  407b0a:	cmp    $0x0,%r10d
  407b0e:	jne    407bb7 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_97_+0x127>
  407b14:	cmp    $0x9b,%r9
  407b1b:	sete   %r9b
  407b1f:	movzbl %r9b,%r9d
  407b23:	je     407b39 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_97_+0xa9>
  407b25:	mov    $0x4,%esi
  407b2a:	callq  432730 <p111_rt_fail>
  407b2f:	mov    $0x0,%eax
  407b34:	jmpq   407c3a <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_97_+0x1aa>
  407b39:	test   %r8d,%r9d
  407b3c:	jne    407b57 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_97_+0xc7>
  407b3e:	mov    $0x4,%r8d
  407b44:	mov    $0x9b,%ecx
  407b49:	lea    -0x800(%rbp),%rdx
  407b50:	callq  4369d0 <p118_rt_borrow_fields>
  407b55:	jmp    407bab <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_97_+0x11b>
  407b57:	cs cs cs mov %rcx,%rsi
  407b5d:	mov    (%rdi),%rcx
  407b60:	cmp    $0x0,%rsi
  407b64:	je     407b78 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_97_+0xe8>
  407b66:	mov    (%rdx,%rcx,1),%eax
  407b69:	mov    0x4(%rdx,%rcx,1),%edx
  407b6d:	shl    $0x20,%rdx
  407b71:	or     %rdx,%rax
  407b74:	shr    $0x18,%rax
  407b78:	shl    $0x3,%rax
  407b7c:	mov    (%rax,%rcx,1),%rdx
  407b80:	mov    %rdx,-0x800(%rbp)
  407b87:	mov    0x8(%rax,%rcx,1),%rdx
  407b8c:	mov    %rdx,-0x7f8(%rbp)
  407b93:	mov    0x10(%rax,%rcx,1),%rdx
  407b98:	mov    %rdx,-0x7f0(%rbp)
  407b9f:	mov    0x18(%rax,%rcx,1),%rax
  407ba4:	mov    %rax,-0x7e8(%rbp)
  407bab:	mov    -0x800(%rbp),%rax
  407bb2:	jmpq   407c3a <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_97_+0x1aa>
  407bb7:	mov    %r10d,%r9d
  407bba:	test   %r8d,%r9d
  407bbd:	jne    407bd8 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_97_+0x148>
  407bbf:	mov    $0x2,%r8d
  407bc5:	mov    $0x9a,%ecx
  407bca:	lea    -0x800(%rbp),%rdx
  407bd1:	callq  4369d0 <p118_rt_borrow_fields>
  407bd6:	jmp    407c13 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_97_+0x183>
  407bd8:	cs cs mov %rcx,%rsi
  407bdd:	mov    (%rdi),%rcx
  407be0:	cmp    $0x0,%rsi
  407be4:	je     407bf8 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_97_+0x168>
  407be6:	mov    (%rdx,%rcx,1),%eax
  407be9:	mov    0x4(%rdx,%rcx,1),%edx
  407bed:	shl    $0x20,%rdx
  407bf1:	or     %rdx,%rax
  407bf4:	shr    $0x18,%rax
  407bf8:	shl    $0x3,%rax
  407bfc:	mov    (%rax,%rcx,1),%rdx
  407c00:	mov    %rdx,-0x800(%rbp)
  407c07:	mov    0x8(%rax,%rcx,1),%rax
  407c0c:	mov    %rax,-0x7f8(%rbp)
  407c13:	mov    -0x800(%rbp),%rax
  407c1a:	jmp    407c3a <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_97_+0x1aa>
  407c1c:	mov    $0x9,%r8d
  407c22:	mov    $0x99,%ecx
  407c27:	lea    -0x800(%rbp),%rdx
  407c2e:	callq  4369d0 <p118_rt_borrow_fields>
  407c33:	mov    -0x7f0(%rbp),%rax
  407c3a:	leaveq 
  407c3b:	retq   

Disassembly of section .fini:
