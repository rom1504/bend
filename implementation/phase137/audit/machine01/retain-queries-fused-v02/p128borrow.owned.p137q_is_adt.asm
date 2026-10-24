
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-queries-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

00000000004099c0 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_105_115_95_97_100_116_>:
  4099c0:	endbr64 
  4099c4:	push   %rbp
  4099c5:	mov    %rsp,%rbp
  4099c8:	sub    $0x828,%rsp
  4099cf:	push   %rbx
  4099d0:	push   %r12
  4099d2:	push   %r13
  4099d4:	push   %r14
  4099d6:	push   %r15
  4099d8:	mov    %rsi,%rax
  4099db:	shr    $0x28,%rax
  4099df:	and    $0xffff,%rax
  4099e5:	cmp    $0x99,%rax
  4099eb:	sete   %cl
  4099ee:	movzbl %cl,%ecx
  4099f1:	cmp    $0x0,%ecx
  4099f4:	jne    409a8d <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0xcd>
  4099fa:	nopw   0x0(%rax,%rax,1)
  409a00:	cmp    $0x9a,%rax
  409a06:	je     409a65 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0xa5>
  409a08:	cmp    $0x9b,%rax
  409a0e:	je     409a25 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x65>
  409a10:	cs mov $0x4,%esi
  409a16:	callq  432730 <p111_rt_fail>
  409a1b:	mov    $0x0,%eax
  409a20:	jmpq   409bd1 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x211>
  409a25:	cs cs lea %cs:-0x820(%rbp),%rdx
  409a2f:	mov    %rdi,%rbx
  409a32:	callq  437c20 <p125_rt_take4>
  409a37:	mov    %rbx,%rdi
  409a3a:	mov    -0x810(%rbp),%rsi
  409a41:	mov    -0x808(%rbp),%r12
  409a48:	mov    %rdi,%rbx
  409a4b:	callq  431fa0 <p111_rt_sink>
  409a50:	mov    %r12,%rsi
  409a53:	mov    %rbx,%rdi
  409a56:	callq  431fa0 <p111_rt_sink>
  409a5b:	mov    $0x0,%eax
  409a60:	jmpq   409bd1 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x211>
  409a65:	lea    -0x820(%rbp),%rdx
  409a6c:	mov    %rdi,%rbx
  409a6f:	callq  437750 <p125_rt_take2>
  409a74:	mov    %rbx,%rdi
  409a77:	mov    -0x818(%rbp),%rsi
  409a7e:	callq  431fa0 <p111_rt_sink>
  409a83:	mov    $0x0,%eax
  409a88:	jmpq   409bd1 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x211>
  409a8d:	mov    $0x9,%ecx
  409a92:	lea    -0x820(%rbp),%rdx
  409a99:	mov    %rdi,%rbx
  409a9c:	callq  432190 <p111_rt_take>
  409aa1:	mov    %rbx,%rdi
  409aa4:	mov    -0x820(%rbp),%rsi
  409aab:	mov    -0x818(%rbp),%r12
  409ab2:	mov    -0x810(%rbp),%r13
  409ab9:	mov    -0x808(%rbp),%r15
  409ac0:	mov    -0x800(%rbp),%r14
  409ac7:	mov    -0x7f8(%rbp),%rbx
  409ace:	mov    %rbx,-0x8(%rbp)
  409ad2:	mov    -0x7f0(%rbp),%rbx
  409ad9:	mov    %rbx,-0x10(%rbp)
  409add:	mov    -0x7e8(%rbp),%rbx
  409ae4:	mov    %rbx,-0x18(%rbp)
  409ae8:	mov    -0x7e0(%rbp),%rbx
  409aef:	mov    %rbx,-0x20(%rbp)
  409af3:	mov    %rdi,%rbx
  409af6:	callq  431fa0 <p111_rt_sink>
  409afb:	mov    %r13,%rsi
  409afe:	mov    %rbx,%rdi
  409b01:	mov    -0x8(%rbp),%r13
  409b05:	mov    %rdi,%rbx
  409b08:	callq  431fa0 <p111_rt_sink>
  409b0d:	mov    %r15,%rsi
  409b10:	mov    %rbx,%rdi
  409b13:	mov    -0x10(%rbp),%r15
  409b17:	mov    %rdi,%rbx
  409b1a:	callq  431fa0 <p111_rt_sink>
  409b1f:	mov    %r14,%rsi
  409b22:	mov    %rbx,%rdi
  409b25:	mov    -0x18(%rbp),%r14
  409b29:	mov    %rdi,%rbx
  409b2c:	callq  431fa0 <p111_rt_sink>
  409b31:	mov    %r13,%rsi
  409b34:	mov    %rbx,%rdi
  409b37:	mov    -0x20(%rbp),%r13
  409b3b:	mov    %rdi,%rbx
  409b3e:	callq  431fa0 <p111_rt_sink>
  409b43:	mov    %r15,%rsi
  409b46:	mov    %rbx,%rdi
  409b49:	mov    %rdi,%rbx
  409b4c:	callq  431fa0 <p111_rt_sink>
  409b51:	mov    %r14,%rsi
  409b54:	mov    %rbx,%rdi
  409b57:	mov    %rdi,%rbx
  409b5a:	callq  431fa0 <p111_rt_sink>
  409b5f:	mov    %r13,%rsi
  409b62:	mov    %rbx,%rdi
  409b65:	mov    %rdi,%rbx
  409b68:	callq  431fa0 <p111_rt_sink>
  409b6d:	mov    %r12,%rsi
  409b70:	mov    %rbx,%rdi
  409b73:	mov    %rdi,%rbx
  409b76:	callq  431f10 <p111_rt_keep>
  409b7b:	mov    %rbx,%rdi
  409b7e:	mov    %rax,%rsi
  409b81:	mov    %rsi,%r12
  409b84:	movabs $0x200190003108638,%rsi
  409b8e:	mov    %rdi,%rbx
  409b91:	callq  431f10 <p111_rt_keep>
  409b96:	mov    %r12,%rsi
  409b99:	mov    %rbx,%rdi
  409b9c:	mov    %rax,%r13
  409b9f:	mov    $0x1,%ecx
  409ba4:	mov    %r13,%rdx
  409ba7:	mov    %rsi,%r12
  409baa:	mov    %rdi,%rbx
  409bad:	callq  405c00 <p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_95_103_111_>
  409bb2:	mov    %r12,%rsi
  409bb5:	mov    %rbx,%rdi
  409bb8:	mov    %rax,%rbx
  409bbb:	mov    %rdi,%r12
  409bbe:	callq  431fa0 <p111_rt_sink>
  409bc3:	mov    %r13,%rsi
  409bc6:	mov    %r12,%rdi
  409bc9:	callq  431fa0 <p111_rt_sink>
  409bce:	mov    %rbx,%rax
  409bd1:	pop    %r15
  409bd3:	pop    %r14
  409bd5:	pop    %r13
  409bd7:	pop    %r12
  409bd9:	pop    %rbx
  409bda:	leaveq 
  409bdb:	retq   

Disassembly of section .fini:
