
selfhost/build/phase194/native45-02/editdist/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040dcdc <p113d_FID_36_100_105_114_101_99_116_46_100_105_115_116_>:
  40dcdc:	push   %rbp
  40dcdd:	mov    %rsp,%rbp
  40dce0:	sub    $0x9f0,%rsp
  40dce7:	mov    %r12,-0x10(%rbp)
  40dceb:	mov    %rbx,-0x8(%rbp)
  40dcef:	mov    %r13,-0x18(%rbp)
  40dcf3:	mov    %r14,-0x20(%rbp)
  40dcf7:	mov    %r15,-0x28(%rbp)
  40dcfb:	mov    %rdi,%rax
  40dcfe:	mov    %rax,%r12
  40dd01:	mov    %rsi,%rax
  40dd04:	mov    %rax,%rdi
  40dd07:	mov    (%r12),%r15
  40dd0b:	mov    %rdi,%rsi
  40dd0e:	shr    $0x28,%rsi
  40dd12:	and    $0xffff,%rsi
  40dd19:	movabs $0xa4,%r11
  40dd23:	cmp    %r11,%rsi
  40dd26:	jne    40df4c <p113d_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x270>
  40dd2c:	mov    %r12,%r10
  40dd2f:	mov    %r10,0x18(%rsp)
  40dd34:	mov    %rdi,%r10
  40dd37:	mov    %r10,0x20(%rsp)
  40dd3c:	lea    -0x830(%rbp),%r10
  40dd43:	mov    %r10,0x28(%rsp)
  40dd48:	mov    0x18(%rsp),%rdi
  40dd4d:	mov    0x20(%rsp),%rsi
  40dd52:	mov    0x28(%rsp),%rdx
  40dd57:	xor    %eax,%eax
  40dd59:	callq  422ff0 <p125_rt_take4>
  40dd5e:	mov    %rax,-0x8a0(%rbp)
  40dd65:	lea    -0x830(%rbp),%r10
  40dd6c:	mov    (%r10),%rdi
  40dd6f:	lea    -0x830(%rbp),%r10
  40dd76:	mov    0x8(%r10),%r13
  40dd7a:	lea    -0x830(%rbp),%r10
  40dd81:	mov    0x10(%r10),%rbx
  40dd85:	lea    -0x830(%rbp),%r10
  40dd8c:	mov    0x18(%r10),%r14
  40dd90:	mov    %r12,%r10
  40dd93:	mov    %r10,0x10(%rsp)
  40dd98:	mov    %rdi,%r10
  40dd9b:	mov    %r10,0x18(%rsp)
  40dda0:	mov    0x10(%rsp),%rdi
  40dda5:	mov    0x18(%rsp),%rsi
  40ddaa:	xor    %eax,%eax
  40ddac:	callq  41cd80 <p111_rt_sink>
  40ddb1:	mov    %rax,-0x8a0(%rbp)
  40ddb8:	mov    %r12,%rdi
  40ddbb:	mov    %r13,%rsi
  40ddbe:	xor    %eax,%eax
  40ddc0:	callq  41cd80 <p111_rt_sink>
  40ddc5:	mov    %rax,-0x8a0(%rbp)
  40ddcc:	mov    %r12,%rdi
  40ddcf:	mov    %r14,%rsi
  40ddd2:	xor    %eax,%eax
  40ddd4:	callq  41cd80 <p111_rt_sink>
  40ddd9:	mov    %rax,-0x8a0(%rbp)
  40dde0:	lea    -0x830(%rbp),%r10
  40dde7:	mov    %rbx,%r11
  40ddea:	mov    %r11,(%r10)
  40dded:	lea    -0x830(%rbp),%r10
  40ddf4:	movabs $0x100,%r11
  40ddfe:	mov    %r11,0x8(%r10)
  40de02:	mov    %rbx,%rdi
  40de05:	shr    $0x38,%rdi
  40de09:	mov    %rdi,%rsi
  40de0c:	cmp    $0x4,%rsi
  40de13:	sete   %sil
  40de17:	movzbl %sil,%esi
  40de1b:	movabs $0xffffffffff,%r11
  40de25:	mov    %rbx,%rdi
  40de28:	and    %r11,%rdi
  40de2b:	mov    %rdi,%rdx
  40de2e:	cmp    $0x3108280,%rdx
  40de35:	setae  %dl
  40de38:	movzbl %dl,%edx
  40de3b:	and    %edx,%esi
  40de3d:	mov    %rsi,%r10
  40de40:	test   %r10d,%r10d
  40de43:	je     40deb0 <p113d_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x1d4>
  40de49:	mov    %rbx,%rsi
  40de4c:	shr    $0x28,%rsi
  40de50:	and    $0x1f,%rsi
  40de57:	mov    %rsi,%r11
  40de5a:	movabs $0x1,%rsi
  40de64:	mov    %r11d,%ecx
  40de67:	shl    %cl,%rsi
  40de6a:	sub    $0x1,%rsi
  40de71:	mov    %rsi,%r11
  40de74:	movabs $0x100,%rsi
  40de7e:	and    %r11,%rsi
  40de81:	shl    $0x3,%rdi
  40de85:	shl    $0x2,%rsi
  40de89:	add    %rsi,%rdi
  40de8c:	mov    (%r15,%rdi,1),%edi
  40de90:	lea    -0x8d0(%rbp),%r10
  40de97:	mov    %rbx,%r11
  40de9a:	mov    %r11,(%r10)
  40de9d:	lea    -0x8d0(%rbp),%r10
  40dea4:	mov    %rdi,%r11
  40dea7:	mov    %r11,0x8(%r10)
  40deab:	jmpq   40def4 <p113d_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x218>
  40deb0:	mov    %r12,%rdi
  40deb3:	movabs $0x48,%rsi
  40debd:	mov    %esi,%esi
  40debf:	lea    -0x830(%rbp),%rdx
  40dec6:	movabs $0x2,%rcx
  40ded0:	mov    %ecx,%ecx
  40ded2:	lea    -0x8d0(%rbp),%r8
  40ded9:	movabs $0x2,%r9
  40dee3:	mov    %r9d,%r9d
  40dee6:	xor    %eax,%eax
  40dee8:	callq  420df0 <p113_rt_array_pair>
  40deed:	mov    %rax,-0x948(%rbp)
  40def4:	lea    -0x8d0(%rbp),%r10
  40defb:	mov    0x8(%r10),%rdi
  40deff:	mov    %r12,%r10
  40df02:	mov    %r10,0x18(%rsp)
  40df07:	mov    %rbx,%r10
  40df0a:	mov    %r10,0x20(%rsp)
  40df0f:	mov    %rdi,%r10
  40df12:	mov    %r10,0x28(%rsp)
  40df17:	mov    0x18(%rsp),%rdi
  40df1c:	mov    0x20(%rsp),%rsi
  40df21:	mov    0x28(%rsp),%rdx
  40df26:	xor    %eax,%eax
  40df28:	callq  40dc7f <p113d_FID_36_112_114_111_100_117_99_116_46_100_105_115_116_46_102_105_110_>
  40df2d:	mov    %rax,%rdi
  40df30:	mov    %rdi,%rax
  40df33:	mov    -0x10(%rbp),%r12
  40df37:	mov    -0x8(%rbp),%rbx
  40df3b:	mov    -0x18(%rbp),%r13
  40df3f:	mov    -0x20(%rbp),%r14
  40df43:	mov    -0x28(%rbp),%r15
  40df47:	mov    %rbp,%rsp
  40df4a:	pop    %rbp
  40df4b:	retq   
  40df4c:	mov    %r12,%rdi
  40df4f:	movabs $0x4,%rsi
  40df59:	mov    %esi,%esi
  40df5b:	xor    %eax,%eax
  40df5d:	callq  41d510 <p111_rt_fail>
  40df62:	mov    %rax,-0x8a0(%rbp)
  40df69:	movabs $0x0,%rax
  40df73:	mov    -0x10(%rbp),%r12
  40df77:	mov    -0x8(%rbp),%rbx
  40df7b:	mov    -0x18(%rbp),%r13
  40df7f:	mov    -0x20(%rbp),%r14
  40df83:	mov    -0x28(%rbp),%r15
  40df87:	mov    %rbp,%rsp
  40df8a:	pop    %rbp
  40df8b:	retq   

Disassembly of section .fini:
