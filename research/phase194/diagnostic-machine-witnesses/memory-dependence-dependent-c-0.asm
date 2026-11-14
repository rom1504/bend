
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-references02/memory-dependence-dependent/c/program:     file format elf64-x86-64


Disassembly of section .text:

00000000000099e0 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_>:
    99e0:	push   %rbp
    99e1:	sub    $0x10,%rsp
    99e5:	mov    %r15d,0x4(%rsp)
    99ea:	mov    %r14,0x8(%rsp)
    99ef:	test   %rsi,%rsi
    99f2:	je     9e6c <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x48c>
    99f8:	mov    %rsi,%r9
    99fb:	movabs $0x200080000000000,%r11
    9a05:	movabs $0xffff0000000000,%rdi
    9a0f:	movabs $0xffffffff80,%rax
    9a19:	movabs $0x80000000000,%r14
    9a23:	lea    0x7f(%rax),%rbp
    9a27:	nopw   0x0(%rax,%rax,1)
    9a30:	mov    %rdx,%rax
    9a33:	and    %rdi,%rax
    9a36:	cmp    %r14,%rax
    9a39:	jne    9f10 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x530>
    9a3f:	mov    %rdx,%rax
    9a42:	and    %rbp,%rax
    9a45:	test   %rdx,%rdx
    9a48:	js     9a70 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x90>
    9a4a:	mov    (%r12,%rax,8),%r10
    9a4e:	mov    0x8(%r12,%rax,8),%rbx
    9a53:	mov    %rax,%rcx
    9a56:	cmp    $0x3108180,%rcx
    9a5d:	jae    9aeb <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x10b>
    9a63:	jmpq   9b22 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x142>
    9a68:	nopl   0x0(%rax,%rax,1)
    9a70:	mov    0x4(%r12,%rax,8),%ecx
    9a75:	mov    (%r12,%rax,8),%esi
    9a79:	mov    %esi,%edi
    9a7b:	and    $0xffffff,%edi
    9a81:	cmp    $0x1,%edi
    9a84:	jne    9d87 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x3a7>
    9a8a:	mov    (%r12,%rax,8),%edx
    9a8e:	shl    $0x20,%rcx
    9a92:	or     %rsi,%rcx
    9a95:	shr    $0x18,%rcx
    9a99:	mov    (%r12,%rcx,8),%r10
    9a9d:	mov    0x8(%r12,%rcx,8),%rbx
    9aa2:	mov    0x0(%r13),%rdx
    9aa6:	mov    %rdx,(%r12,%rax,8)
    9aaa:	mov    %rax,0x0(%r13)
    9aae:	mov    0x100(%r13),%rax
    9ab5:	inc    %rax
    9ab8:	mov    %rax,0x100(%r13)
    9abf:	cmpb   $0x1,0x10c24a(%rip)        # 115d10 <KEEP_WORDS>
    9ac6:	jne    9e06 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x426>
    9acc:	cmp    $0x8000,%rax
    9ad2:	jae    9e06 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x426>
    9ad8:	movabs $0xffff0000000000,%rdi
    9ae2:	cmp    $0x3108180,%rcx
    9ae9:	jb     9b22 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x142>
    9aeb:	mov    0x8(%r13),%rax
    9aef:	mov    %rax,(%r12,%rcx,8)
    9af3:	mov    %rcx,0x8(%r13)
    9af7:	mov    0x108(%r13),%rax
    9afe:	add    $0x2,%rax
    9b02:	mov    %rax,0x108(%r13)
    9b09:	cmpb   $0x1,0x10c200(%rip)        # 115d10 <KEEP_WORDS>
    9b10:	jne    9d4c <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x36c>
    9b16:	cmp    $0x8000,%rax
    9b1c:	jae    9d4c <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x36c>
    9b22:	mov    %r10,%rax
    9b25:	and    %rdi,%rax
    9b28:	cmp    %r14,%rax
    9b2b:	jne    9e98 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x4b8>
    9b31:	mov    %r10,%rdx
    9b34:	and    %rbp,%rdx
    9b37:	test   %r10,%r10
    9b3a:	js     9b60 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x180>
    9b3c:	mov    (%r12,%rdx,8),%r15
    9b40:	mov    0x8(%r12,%rdx,8),%rax
    9b45:	mov    %rdx,%rcx
    9b48:	cmp    $0x3108180,%rcx
    9b4f:	jae    9bd2 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x1f2>
    9b55:	jmpq   9c0a <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x22a>
    9b5a:	nopw   0x0(%rax,%rax,1)
    9b60:	mov    0x4(%r12,%rdx,8),%ecx
    9b65:	mov    (%r12,%rdx,8),%eax
    9b69:	mov    %eax,%esi
    9b6b:	and    $0xffffff,%esi
    9b71:	cmp    $0x1,%esi
    9b74:	jne    9dc5 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x3e5>
    9b7a:	mov    (%r12,%rdx,8),%esi
    9b7e:	shl    $0x20,%rcx
    9b82:	or     %rax,%rcx
    9b85:	shr    $0x18,%rcx
    9b89:	mov    (%r12,%rcx,8),%r15
    9b8d:	mov    0x8(%r12,%rcx,8),%rax
    9b92:	mov    0x0(%r13),%rsi
    9b96:	mov    %rsi,(%r12,%rdx,8)
    9b9a:	mov    %rdx,0x0(%r13)
    9b9e:	mov    0x100(%r13),%rdx
    9ba5:	inc    %rdx
    9ba8:	mov    %rdx,0x100(%r13)
    9baf:	cmpb   $0x1,0x10c15a(%rip)        # 115d10 <KEEP_WORDS>
    9bb6:	jne    9e39 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x459>
    9bbc:	cmp    $0x8000,%rdx
    9bc3:	jae    9e39 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x459>
    9bc9:	cmp    $0x3108180,%rcx
    9bd0:	jb     9c0a <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x22a>
    9bd2:	mov    0x8(%r13),%rdx
    9bd6:	mov    %rdx,(%r12,%rcx,8)
    9bda:	mov    %rcx,0x8(%r13)
    9bde:	mov    0x108(%r13),%rcx
    9be5:	add    $0x2,%rcx
    9be9:	mov    %rcx,0x108(%r13)
    9bf0:	cmpb   $0x1,0x10c119(%rip)        # 115d10 <KEEP_WORDS>
    9bf7:	jne    9d75 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x395>
    9bfd:	cmp    $0x8000,%rcx
    9c04:	jae    9d75 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x395>
    9c0a:	mov    %rax,%rcx
    9c0d:	test   %rax,%rax
    9c10:	js     9c60 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x280>
    9c12:	shr    $0x39,%rcx
    9c16:	sete   %cl
    9c19:	mov    %rax,%rdx
    9c1c:	movabs $0xffffffff80,%rsi
    9c26:	and    %rsi,%rdx
    9c29:	cmp    $0x3108180,%rdx
    9c30:	setb   %dl
    9c33:	or     %cl,%dl
    9c35:	jne    9c7c <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x29c>
    9c37:	mov    %r12,%rdi
    9c3a:	mov    %r13,%rsi
    9c3d:	mov    %rax,%rdx
    9c40:	mov    $0x2,%ecx
    9c45:	callq  122de <rfc_wrap>
    9c4a:	movabs $0xffff0000000000,%rdi
    9c54:	movabs $0x200080000000000,%r11
    9c5e:	jmp    9c7c <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x29c>
    9c60:	and    %rbp,%rcx
    9c63:	mov    $0x1,%edx
    9c68:	lock xadd %edx,(%r12,%rcx,8)
    9c6e:	not    %edx
    9c70:	test   $0xfffffe,%edx
    9c76:	je     9f5a <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x57a>
    9c7c:	mov    %r15,%rcx
    9c7f:	shr    $0x28,%rcx
    9c83:	mov    $0xffffffff,%edx
    9c88:	shl    %cl,%edx
    9c8a:	not    %edx
    9c8c:	and    %eax,%edx
    9c8e:	mov    %r15,%rax
    9c91:	and    %rbp,%rax
    9c94:	lea    (%r12,%rax,8),%rax
    9c98:	mov    (%rax,%rdx,4),%r8d
    9c9c:	mov    0x8(%r13),%rcx
    9ca0:	test   %rcx,%rcx
    9ca3:	je     9cfa <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x31a>
    9ca5:	mov    (%r12,%rcx,8),%rax
    9ca9:	mov    %rax,0x8(%r13)
    9cad:	addq   $0xfffffffffffffffe,0x108(%r13)
    9cb5:	mov    %r15,(%r12,%rcx,8)
    9cb9:	mov    %r8,0x8(%r12,%rcx,8)
    9cbe:	mov    0x8(%r13),%rdx
    9cc2:	test   %rdx,%rdx
    9cc5:	je     9d23 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x343>
    9cc7:	mov    (%r12,%rdx,8),%rax
    9ccb:	mov    %rax,0x8(%r13)
    9ccf:	addq   $0xfffffffffffffffe,0x108(%r13)
    9cd7:	dec    %r9
    9cda:	add    %r8d,%ebx
    9cdd:	or     %r11,%rcx
    9ce0:	mov    %rcx,(%r12,%rdx,8)
    9ce4:	mov    %rbx,0x8(%r12,%rdx,8)
    9ce9:	or     %r11,%rdx
    9cec:	test   %r9,%r9
    9cef:	jne    9a30 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x50>
    9cf5:	jmpq   9e6c <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x48c>
    9cfa:	mov    %r12,%rdi
    9cfd:	mov    %r13,%rsi
    9d00:	mov    $0x1,%edx
    9d05:	callq  11fd8 <heap_alloc_miss>
    9d0a:	movabs $0xffff0000000000,%rdi
    9d14:	movabs $0x200080000000000,%r11
    9d1e:	mov    %rax,%rcx
    9d21:	jmp    9cb5 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x2d5>
    9d23:	mov    %r12,%rdi
    9d26:	mov    %r13,%rsi
    9d29:	mov    $0x1,%edx
    9d2e:	callq  11fd8 <heap_alloc_miss>
    9d33:	movabs $0xffff0000000000,%rdi
    9d3d:	movabs $0x200080000000000,%r11
    9d47:	mov    %rax,%rdx
    9d4a:	jmp    9cd7 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x2f7>
    9d4c:	mov    %r12,%rdi
    9d4f:	mov    %r13,%rsi
    9d52:	mov    $0x1,%edx
    9d57:	callq  11eb1 <heap_hand>
    9d5c:	movabs $0xffff0000000000,%rdi
    9d66:	movabs $0x200080000000000,%r11
    9d70:	jmpq   9b22 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x142>
    9d75:	mov    %r12,%rdi
    9d78:	mov    %r13,%rsi
    9d7b:	mov    $0x1,%edx
    9d80:	callq  11eb1 <heap_hand>
    9d85:	jmp    9ded <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x40d>
    9d87:	shl    $0x20,%rcx
    9d8b:	or     %rsi,%rcx
    9d8e:	shr    $0x18,%rcx
    9d92:	mov    (%r12,%rcx,8),%r10
    9d96:	mov    0x8(%r12,%rcx,8),%rbx
    9d9b:	mov    %r12,%rdi
    9d9e:	mov    %r13,%rsi
    9da1:	mov    $0x2,%r8d
    9da7:	callq  11f42 <span_fade>
    9dac:	movabs $0x200080000000000,%r11
    9db6:	movabs $0xffff0000000000,%rdi
    9dc0:	jmpq   9b22 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x142>
    9dc5:	shl    $0x20,%rcx
    9dc9:	or     %rax,%rcx
    9dcc:	shr    $0x18,%rcx
    9dd0:	mov    (%r12,%rcx,8),%r15
    9dd4:	mov    0x8(%r12,%rcx,8),%rax
    9dd9:	mov    %r12,%rdi
    9ddc:	mov    %r13,%rsi
    9ddf:	mov    %r10,%rdx
    9de2:	mov    $0x2,%r8d
    9de8:	callq  11f42 <span_fade>
    9ded:	movabs $0xffff0000000000,%rdi
    9df7:	movabs $0x200080000000000,%r11
    9e01:	jmpq   9c0a <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x22a>
    9e06:	mov    %r12,%rdi
    9e09:	mov    %r13,%rsi
    9e0c:	xor    %edx,%edx
    9e0e:	callq  11eb1 <heap_hand>
    9e13:	movabs $0x200080000000000,%r11
    9e1d:	movabs $0xffff0000000000,%rdi
    9e27:	cmp    $0x3108180,%rcx
    9e2e:	jae    9aeb <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x10b>
    9e34:	jmpq   9b22 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x142>
    9e39:	mov    %r12,%rdi
    9e3c:	mov    %r13,%rsi
    9e3f:	xor    %edx,%edx
    9e41:	callq  11eb1 <heap_hand>
    9e46:	movabs $0xffff0000000000,%rdi
    9e50:	movabs $0x200080000000000,%r11
    9e5a:	cmp    $0x3108180,%rcx
    9e61:	jae    9bd2 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x1f2>
    9e67:	jmpq   9c0a <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x22a>
    9e6c:	mov    0x8(%rsp),%r14
    9e71:	mov    -0x8(%r14),%eax
    9e75:	add    $0xfffffffffffffff8,%r14
    9e79:	lea    0xa5c0(%rip),%rcx        # 14440 <wl_tab>
    9e80:	mov    (%rcx,%rax,8),%rax
    9e84:	mov    0x4(%rsp),%r15d
    9e89:	mov    $0x1,%edi
    9e8e:	mov    %rdx,%rsi
    9e91:	add    $0x10,%rsp
    9e95:	pop    %rbp
    9e96:	jmpq   *%rax
    9e98:	movabs $0x7e00000000000000,%r14
    9ea2:	test   %r14,%r10
    9ea5:	sete   %al
    9ea8:	cmp    $0xffffffffffffffff,%r10
    9eac:	sete   %cl
    9eaf:	or     %al,%cl
    9eb1:	mov    %r10,%rax
    9eb4:	movabs $0xffffffff80,%rdx
    9ebe:	and    %rdx,%rax
    9ec1:	cmp    $0x3108180,%rax
    9ec7:	setb   %al
    9eca:	or     %cl,%al
    9ecc:	jne    9edc <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x4fc>
    9ece:	mov    %r12,%rdi
    9ed1:	mov    %r13,%rsi
    9ed4:	mov    %r10,%rdx
    9ed7:	callq  6ad0 <term_drop>
    9edc:	test   %r14,%rbx
    9edf:	sete   %al
    9ee2:	cmp    $0xffffffffffffffff,%rbx
    9ee6:	sete   %cl
    9ee9:	or     %al,%cl
    9eeb:	movabs $0xffffffff80,%rax
    9ef5:	and    %rbx,%rax
    9ef8:	cmp    $0x3108180,%rax
    9efe:	setb   %al
    9f01:	or     %cl,%al
    9f03:	jne    9f4e <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x56e>
    9f05:	mov    %r12,%rdi
    9f08:	mov    %r13,%rsi
    9f0b:	mov    %rbx,%rdx
    9f0e:	jmp    9f49 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x569>
    9f10:	movabs $0x7e00000000000000,%rax
    9f1a:	test   %rax,%rdx
    9f1d:	sete   %al
    9f20:	cmp    $0xffffffffffffffff,%rdx
    9f24:	sete   %cl
    9f27:	or     %al,%cl
    9f29:	movabs $0xffffffff80,%rax
    9f33:	and    %rdx,%rax
    9f36:	cmp    $0x3108180,%rax
    9f3c:	setb   %al
    9f3f:	or     %cl,%al
    9f41:	jne    9f4e <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x56e>
    9f43:	mov    %r12,%rdi
    9f46:	mov    %r13,%rsi
    9f49:	callq  6ad0 <term_drop>
    9f4e:	lea    -0x7a45(%rip),%rdi        # 2510 <FID_RESW_T+0x310>
    9f55:	callq  11e50 <err_fail>
    9f5a:	lea    -0x7488(%rip),%rdi        # 2ad9 <FID_RESW_T+0x8d9>
    9f61:	callq  11e50 <err_fail>

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
