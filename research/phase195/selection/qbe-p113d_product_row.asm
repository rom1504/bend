
/home/ai/bend2/build/publish/bend/selfhost/build/phase186/release-native45-acquire01/editdist/phase186-qbe-n2/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000408d60 <p113d_FID_36_112_114_111_100_117_99_116_46_114_111_119_>:
  408d60:	endbr64 
  408d64:	push   %rbp
  408d65:	mov    %rsp,%rbp
  408d68:	sub    $0x58,%rsp
  408d6c:	push   %rbx
  408d6d:	push   %r12
  408d6f:	push   %r13
  408d71:	push   %r14
  408d73:	push   %r15
  408d75:	mov    0x20(%rbp),%r10
  408d79:	mov    0x18(%rbp),%r11
  408d7d:	mov    0x10(%rbp),%rbx
  408d81:	mov    %r8,%r14
  408d84:	mov    %rdx,%r12
  408d87:	mov    %rcx,%rdx
  408d8a:	mov    %rsi,%rax
  408d8d:	mov    %r9,%rsi
  408d90:	mov    %rsi,-0x28(%rbp)
  408d94:	mov    %rax,-0x50(%rbp)
  408d98:	mov    (%rdi),%r9
  408d9b:	mov    %rbx,%rcx
  408d9e:	shr    $0x38,%rcx
  408da2:	cmp    $0x4,%rcx
  408da6:	sete   %cl
  408da9:	movzbl %cl,%ecx
  408dac:	movabs $0xffffffffff,%r8
  408db6:	mov    %rbx,%r13
  408db9:	and    %r8,%r13
  408dbc:	cmp    $0x3108280,%r13
  408dc3:	setae  %r8b
  408dc7:	movzbl %r8b,%r8d
  408dcb:	and    %r8d,%ecx
  408dce:	mov    %ecx,-0x18(%rbp)
  408dd1:	mov    %r11,%rcx
  408dd4:	shr    $0x38,%rcx
  408dd8:	cmp    $0x4,%rcx
  408ddc:	sete   %cl
  408ddf:	movzbl %cl,%ecx
  408de2:	mov    %rsi,%r8
  408de5:	movabs $0xffffffffff,%rsi
  408def:	and    %r11,%rsi
  408df2:	cmp    $0x3108280,%rsi
  408df9:	setae  %r15b
  408dfd:	movzbl %r15b,%r15d
  408e01:	mov    %r15d,-0xc(%rbp)
  408e05:	and    -0xc(%rbp),%ecx
  408e08:	mov    %ecx,-0x1c(%rbp)
  408e0b:	mov    %r10,%rcx
  408e0e:	shr    $0x38,%rcx
  408e12:	cmp    $0x4,%rcx
  408e16:	sete   %cl
  408e19:	movzbl %cl,%ecx
  408e1c:	mov    %ecx,-0x14(%rbp)
  408e1f:	movabs $0xffffffffff,%rcx
  408e29:	mov    %r10,%r15
  408e2c:	and    %rcx,%r15
  408e2f:	cmp    $0x3108280,%r15
  408e36:	setae  %cl
  408e39:	movzbl %cl,%ecx
  408e3c:	mov    %ecx,-0x10(%rbp)
  408e3f:	mov    -0x14(%rbp),%ecx
  408e42:	and    -0x10(%rbp),%ecx
  408e45:	mov    %ecx,-0x20(%rbp)
  408e48:	mov    -0x18(%rbp),%ecx
  408e4b:	and    -0x1c(%rbp),%ecx
  408e4e:	test   %ecx,-0x20(%rbp)
  408e51:	jne    408e85 <p113d_FID_36_112_114_111_100_117_99_116_46_114_111_119_+0x125>
  408e53:	mov    %r14,%rsi
  408e56:	sub    $0x20,%rsp
  408e5a:	mov    %rsp,%rcx
  408e5d:	mov    %r10,0x10(%rcx)
  408e61:	mov    %r11,0x8(%rcx)
  408e65:	mov    %rbx,(%rcx)
  408e68:	mov    %r8,%r9
  408e6b:	mov    %rsi,%r8
  408e6e:	mov    %rdx,%rcx
  408e71:	mov    %r12,%rdx
  408e74:	mov    %rax,%rsi
  408e77:	callq  4088f0 <p117v_FID_36_112_114_111_100_117_99_116_46_114_111_119_>
  408e7c:	sub    $0xffffffffffffffe0,%rsp
  408e80:	jmpq   408fc8 <p113d_FID_36_112_114_111_100_117_99_116_46_114_111_119_+0x268>
  408e85:	mov    %rdx,%rax
  408e88:	mov    %r14,%rdx
  408e8b:	mov    %r13,%rdi
  408e8e:	mov    %rbx,%rcx
  408e91:	shr    $0x28,%rcx
  408e95:	and    $0x1f,%rcx
  408e99:	mov    $0x1,%r8d
  408e9f:	shl    %cl,%r8
  408ea2:	mov    %r8,%r13
  408ea5:	sub    $0x1,%r13
  408ea9:	mov    %r13,-0x40(%rbp)
  408ead:	mov    %rdi,%rcx
  408eb0:	shl    $0x3,%rcx
  408eb4:	mov    %r9,%r14
  408eb7:	add    %rcx,%r14
  408eba:	mov    %r14,-0x48(%rbp)
  408ebe:	mov    %r11,%rcx
  408ec1:	shr    $0x28,%rcx
  408ec5:	and    $0x1f,%rcx
  408ec9:	mov    $0x1,%edi
  408ece:	shl    %cl,%rdi
  408ed1:	sub    $0x1,%rdi
  408ed5:	mov    %rsi,%rcx
  408ed8:	shl    $0x3,%rcx
  408edc:	mov    %r9,%r8
  408edf:	add    %rcx,%r8
  408ee2:	mov    %r10,%rcx
  408ee5:	shr    $0x28,%rcx
  408ee9:	and    $0x1f,%rcx
  408eed:	mov    $0x1,%esi
  408ef2:	shl    %cl,%rsi
  408ef5:	mov    %rsi,-0x30(%rbp)
  408ef9:	mov    -0x28(%rbp),%rsi
  408efd:	mov    -0x30(%rbp),%rcx
  408f01:	sub    $0x1,%rcx
  408f05:	shl    $0x3,%r15
  408f09:	add    %r15,%r9
  408f0c:	nopl   0x0(%rax)
  408f10:	cmp    $0x0,%r12
  408f14:	je     408fb0 <p113d_FID_36_112_114_111_100_117_99_116_46_114_111_119_+0x250>
  408f1a:	and    %rax,%r13
  408f1d:	mov    (%r14,%r13,4),%r14d
  408f21:	mov    %edx,%r13d
  408f24:	cmp    %r13,%r14
  408f27:	setne  %r13b
  408f2b:	movzbl %r13b,%r13d
  408f2f:	xor    $0x1,%r13d
  408f33:	mov    $0x1,%r14d
  408f39:	mov    $0x0,%r13d
  408f3f:	mov    %r13,%r15
  408f42:	cmove  %r14,%r15
  408f46:	mov    %r15,-0x38(%rbp)
  408f4a:	mov    %rdi,%r13
  408f4d:	and    %rax,%r13
  408f50:	mov    (%r8,%r13,4),%r13d
  408f54:	mov    %rax,%r15
  408f57:	mov    %eax,%eax
  408f59:	add    $0x1,%eax
  408f5c:	mov    %eax,%eax
  408f5e:	mov    %rdi,%r14
  408f61:	and    %rax,%r14
  408f64:	mov    (%r8,%r14,4),%r14d
  408f68:	and    %rcx,%r15
  408f6b:	mov    (%r9,%r15,4),%r15d
  408f6f:	add    $0x1,%r14d
  408f73:	mov    %r14d,%r14d
  408f76:	add    $0x1,%r15d
  408f7a:	mov    %r15d,%r15d
  408f7d:	cmp    %r15,%r14
  408f80:	cmovae %r15,%r14
  408f84:	mov    -0x38(%rbp),%r15
  408f88:	add    %r13d,%r15d
  408f8b:	mov    -0x40(%rbp),%r13
  408f8f:	mov    %r15d,%r15d
  408f92:	cmp    %r15,%r14
  408f95:	cmovae %r15,%r14
  408f99:	mov    %rcx,%r15
  408f9c:	and    %rax,%r15
  408f9f:	mov    %r14d,(%r9,%r15,4)
  408fa3:	mov    -0x48(%rbp),%r14
  408fa7:	sub    $0x1,%r12
  408fab:	jmpq   408f10 <p113d_FID_36_112_114_111_100_117_99_116_46_114_111_119_+0x1b0>
  408fb0:	mov    -0x50(%rbp),%rax
  408fb4:	mov    %rsi,(%rax)
  408fb7:	mov    %rbx,0x8(%rax)
  408fbb:	mov    %r10,0x10(%rax)
  408fbf:	mov    %r11,0x18(%rax)
  408fc3:	mov    $0x0,%eax
  408fc8:	pop    %r15
  408fca:	pop    %r14
  408fcc:	pop    %r13
  408fce:	pop    %r12
  408fd0:	pop    %rbx
  408fd1:	leaveq 
  408fd2:	retq   

Disassembly of section .fini:
