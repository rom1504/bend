
/home/ai/bend2/build/publish/bend/selfhost/build/phase186/release-native45-acquire01/editdist/phase186-qbe-n2/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000409a90 <p113d_FID_36_100_105_114_101_99_116_46_100_105_115_116_>:
  409a90:	endbr64 
  409a94:	cs cs cs cs cs push %rbp
  409a9a:	cs cs cs mov %rsp,%rbp
  409aa0:	sub    $0x818,%rsp
  409aa7:	push   %rbx
  409aa8:	push   %r12
  409aaa:	push   %r13
  409aac:	push   %r14
  409aae:	push   %r15
  409ab0:	mov    (%rdi),%rbx
  409ab3:	mov    %rsi,%rax
  409ab6:	shr    $0x28,%rax
  409aba:	and    $0xffff,%rax
  409ac0:	cmp    $0xa4,%rax
  409ac6:	je     409adc <p113d_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x4c>
  409ac8:	mov    $0x4,%esi
  409acd:	callq  414d30 <p111_rt_fail>
  409ad2:	mov    $0x0,%eax
  409ad7:	jmpq   409be5 <p113d_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x155>
  409adc:	lea    -0x810(%rbp),%rdx
  409ae3:	mov    %rdi,%r12
  409ae6:	callq  41a810 <p125_rt_take4>
  409aeb:	mov    %r12,%rdi
  409aee:	mov    -0x810(%rbp),%rsi
  409af5:	mov    -0x808(%rbp),%r15
  409afc:	mov    -0x800(%rbp),%r13
  409b03:	mov    -0x7f8(%rbp),%r14
  409b0a:	mov    %rdi,%r12
  409b0d:	callq  4145a0 <p111_rt_sink>
  409b12:	mov    %r15,%rsi
  409b15:	mov    %r12,%rdi
  409b18:	mov    %rdi,%r12
  409b1b:	callq  4145a0 <p111_rt_sink>
  409b20:	mov    %r14,%rsi
  409b23:	mov    %r12,%rdi
  409b26:	mov    %rdi,%r12
  409b29:	callq  4145a0 <p111_rt_sink>
  409b2e:	mov    %r13,%rsi
  409b31:	mov    %r12,%rdi
  409b34:	mov    %rsi,-0x810(%rbp)
  409b3b:	movq   $0x100,-0x808(%rbp)
  409b46:	mov    %rsi,%rax
  409b49:	shr    $0x38,%rax
  409b4d:	cmp    $0x4,%rax
  409b51:	sete   %cl
  409b54:	movzbl %cl,%ecx
  409b57:	movabs $0xffffffffff,%rax
  409b61:	and    %rsi,%rax
  409b64:	cmp    $0x3108280,%rax
  409b6a:	setae  %dl
  409b6d:	movzbl %dl,%edx
  409b70:	and    %edx,%ecx
  409b72:	cmp    $0x0,%ecx
  409b75:	jne    409ba5 <p113d_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x115>
  409b77:	mov    $0x2,%r9d
  409b7d:	lea    -0x10(%rbp),%r8
  409b81:	mov    $0x2,%ecx
  409b86:	lea    -0x810(%rbp),%rdx
  409b8d:	mov    %rsi,%r12
  409b90:	mov    $0x48,%esi
  409b95:	mov    %rdi,%rbx
  409b98:	callq  418610 <p113_rt_array_pair>
  409b9d:	mov    %r12,%rsi
  409ba0:	mov    %rbx,%rdi
  409ba3:	jmp    409bdc <p113d_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x14c>
  409ba5:	mov    %rsi,%rcx
  409ba8:	shr    $0x28,%rcx
  409bac:	and    $0x1f,%rcx
  409bb0:	mov    $0x1,%edx
  409bb5:	shl    %cl,%rdx
  409bb8:	mov    %rdx,%rcx
  409bbb:	sub    $0x1,%rcx
  409bbf:	and    $0x100,%rcx
  409bc6:	shl    $0x3,%rax
  409bca:	shl    $0x2,%rcx
  409bce:	add    %rcx,%rax
  409bd1:	mov    (%rbx,%rax,1),%eax
  409bd4:	mov    %rsi,-0x10(%rbp)
  409bd8:	mov    %rax,-0x8(%rbp)
  409bdc:	mov    -0x8(%rbp),%rdx
  409be0:	callq  409a70 <p113d_FID_36_112_114_111_100_117_99_116_46_100_105_115_116_46_102_105_110_>
  409be5:	pop    %r15
  409be7:	pop    %r14
  409be9:	pop    %r13
  409beb:	pop    %r12
  409bed:	pop    %rbx
  409bee:	leaveq 
  409bef:	retq   

Disassembly of section .fini:
