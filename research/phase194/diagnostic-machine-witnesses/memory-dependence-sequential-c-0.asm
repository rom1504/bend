
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-references02/memory-dependence-sequential/c/program:     file format elf64-x86-64


Disassembly of section .text:

00000000000099d0 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_>:
    99d0:	push   %rbp
    99d1:	sub    $0x10,%rsp
    99d5:	mov    %r15d,0x4(%rsp)
    99da:	mov    %r14,0x8(%rsp)
    99df:	test   %rsi,%rsi
    99e2:	je     9e9b <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x4cb>
    99e8:	mov    %rsi,%r9
    99eb:	movabs $0x200080000000000,%r11
    99f5:	movabs $0xffff0000000000,%rdi
    99ff:	movabs $0xffffffff80,%r8
    9a09:	movabs $0x80000000000,%r14
    9a13:	lea    0x7f(%r8),%rbp
    9a17:	nopw   0x0(%rax,%rax,1)
    9a20:	mov    %rdx,%rax
    9a23:	and    %rdi,%rax
    9a26:	cmp    %r14,%rax
    9a29:	jne    9f36 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x566>
    9a2f:	mov    %rdx,%rsi
    9a32:	and    %rbp,%rsi
    9a35:	test   %rdx,%rdx
    9a38:	js     9a60 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x90>
    9a3a:	mov    (%r12,%rsi,8),%rax
    9a3e:	mov    0x8(%r12,%rsi,8),%rbx
    9a43:	mov    %rsi,%rcx
    9a46:	cmp    $0x3108180,%rcx
    9a4d:	jae    9adc <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x10c>
    9a53:	jmpq   9b14 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x144>
    9a58:	nopl   0x0(%rax,%rax,1)
    9a60:	mov    0x4(%r12,%rsi,8),%ecx
    9a65:	mov    (%r12,%rsi,8),%eax
    9a69:	mov    %eax,%edi
    9a6b:	and    $0xffffff,%edi
    9a71:	cmp    $0x1,%edi
    9a74:	jne    9da2 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x3d2>
    9a7a:	mov    (%r12,%rsi,8),%edx
    9a7e:	shl    $0x20,%rcx
    9a82:	or     %rax,%rcx
    9a85:	shr    $0x18,%rcx
    9a89:	mov    (%r12,%rcx,8),%rax
    9a8d:	mov    0x8(%r12,%rcx,8),%rbx
    9a92:	mov    0x0(%r13),%rdx
    9a96:	mov    %rdx,(%r12,%rsi,8)
    9a9a:	mov    %rsi,0x0(%r13)
    9a9e:	mov    0x100(%r13),%rdx
    9aa5:	inc    %rdx
    9aa8:	mov    %rdx,0x100(%r13)
    9aaf:	cmpb   $0x1,0x10c1da(%rip)        # 115c90 <KEEP_WORDS>
    9ab6:	jne    9e35 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x465>
    9abc:	cmp    $0x8000,%rdx
    9ac3:	jae    9e35 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x465>
    9ac9:	movabs $0xffff0000000000,%rdi
    9ad3:	cmp    $0x3108180,%rcx
    9ada:	jb     9b14 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x144>
    9adc:	mov    0x8(%r13),%rdx
    9ae0:	mov    %rdx,(%r12,%rcx,8)
    9ae4:	mov    %rcx,0x8(%r13)
    9ae8:	mov    0x108(%r13),%rcx
    9aef:	add    $0x2,%rcx
    9af3:	mov    %rcx,0x108(%r13)
    9afa:	cmpb   $0x1,0x10c18f(%rip)        # 115c90 <KEEP_WORDS>
    9b01:	jne    9d50 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x380>
    9b07:	cmp    $0x8000,%rcx
    9b0e:	jae    9d50 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x380>
    9b14:	mov    %rax,%rcx
    9b17:	and    %rdi,%rcx
    9b1a:	cmp    %r14,%rcx
    9b1d:	jne    9ec7 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x4f7>
    9b23:	mov    %rax,%rdx
    9b26:	and    %rbp,%rdx
    9b29:	test   %rax,%rax
    9b2c:	js     9b50 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x180>
    9b2e:	mov    (%r12,%rdx,8),%r15
    9b32:	mov    0x8(%r12,%rdx,8),%r10
    9b37:	mov    %rdx,%rcx
    9b3a:	cmp    $0x3108180,%rcx
    9b41:	jae    9bcb <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x1fb>
    9b47:	jmpq   9c02 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x232>
    9b4c:	nopl   0x0(%rax)
    9b50:	mov    0x4(%r12,%rdx,8),%ecx
    9b55:	mov    (%r12,%rdx,8),%esi
    9b59:	mov    %esi,%edi
    9b5b:	and    $0xffffff,%edi
    9b61:	cmp    $0x1,%edi
    9b64:	jne    9dea <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x41a>
    9b6a:	mov    (%r12,%rdx,8),%eax
    9b6e:	shl    $0x20,%rcx
    9b72:	or     %rsi,%rcx
    9b75:	shr    $0x18,%rcx
    9b79:	mov    (%r12,%rcx,8),%r15
    9b7d:	mov    0x8(%r12,%rcx,8),%r10
    9b82:	mov    0x0(%r13),%rax
    9b86:	mov    %rax,(%r12,%rdx,8)
    9b8a:	mov    %rdx,0x0(%r13)
    9b8e:	mov    0x100(%r13),%rax
    9b95:	inc    %rax
    9b98:	mov    %rax,0x100(%r13)
    9b9f:	cmpb   $0x1,0x10c0ea(%rip)        # 115c90 <KEEP_WORDS>
    9ba6:	jne    9e68 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x498>
    9bac:	cmp    $0x8000,%rax
    9bb2:	jae    9e68 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x498>
    9bb8:	movabs $0xffff0000000000,%rdi
    9bc2:	cmp    $0x3108180,%rcx
    9bc9:	jb     9c02 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x232>
    9bcb:	mov    0x8(%r13),%rax
    9bcf:	mov    %rax,(%r12,%rcx,8)
    9bd3:	mov    %rcx,0x8(%r13)
    9bd7:	mov    0x108(%r13),%rax
    9bde:	add    $0x2,%rax
    9be2:	mov    %rax,0x108(%r13)
    9be9:	cmpb   $0x1,0x10c0a0(%rip)        # 115c90 <KEEP_WORDS>
    9bf0:	jne    9d79 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x3a9>
    9bf6:	cmp    $0x8000,%rax
    9bfc:	jae    9d79 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x3a9>
    9c02:	mov    %r10,%rax
    9c05:	test   %r10,%r10
    9c08:	js     9c60 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x290>
    9c0a:	shr    $0x39,%rax
    9c0e:	sete   %al
    9c11:	mov    %r10,%rcx
    9c14:	and    %r8,%rcx
    9c17:	cmp    $0x3108180,%rcx
    9c1e:	setb   %cl
    9c21:	or     %al,%cl
    9c23:	jne    9c7c <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x2ac>
    9c25:	mov    %r12,%rdi
    9c28:	mov    %r13,%rsi
    9c2b:	mov    %r10,%rdx
    9c2e:	mov    $0x2,%ecx
    9c33:	callq  1227e <rfc_wrap>
    9c38:	movabs $0xffff0000000000,%rdi
    9c42:	movabs $0x200080000000000,%r11
    9c4c:	mov    %rax,%r10
    9c4f:	jmp    9c7c <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x2ac>
    9c51:	data16 data16 data16 data16 data16 nopw %cs:0x0(%rax,%rax,1)
    9c60:	and    %rbp,%rax
    9c63:	mov    $0x1,%ecx
    9c68:	lock xadd %ecx,(%r12,%rax,8)
    9c6e:	not    %ecx
    9c70:	test   $0xfffffe,%ecx
    9c76:	je     9f77 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x5a7>
    9c7c:	mov    %r15,%rcx
    9c7f:	shr    $0x28,%rcx
    9c83:	mov    $0xffffffff,%eax
    9c88:	shl    %cl,%eax
    9c8a:	not    %eax
    9c8c:	and    %r10d,%eax
    9c8f:	mov    %r15,%rcx
    9c92:	and    %rbp,%rcx
    9c95:	lea    (%r12,%rcx,8),%rcx
    9c99:	add    (%rcx,%rax,4),%ebx
    9c9c:	mov    0x8(%r13),%rcx
    9ca0:	test   %rcx,%rcx
    9ca3:	je     9cfe <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x32e>
    9ca5:	mov    (%r12,%rcx,8),%rax
    9ca9:	mov    %rax,0x8(%r13)
    9cad:	addq   $0xfffffffffffffffe,0x108(%r13)
    9cb5:	inc    %r10d
    9cb8:	movzbl %r10b,%eax
    9cbc:	mov    %r15,(%r12,%rcx,8)
    9cc0:	mov    %rax,0x8(%r12,%rcx,8)
    9cc5:	mov    0x8(%r13),%rdx
    9cc9:	test   %rdx,%rdx
    9ccc:	je     9d27 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x357>
    9cce:	mov    (%r12,%rdx,8),%rax
    9cd2:	mov    %rax,0x8(%r13)
    9cd6:	addq   $0xfffffffffffffffe,0x108(%r13)
    9cde:	dec    %r9
    9ce1:	or     %r11,%rcx
    9ce4:	mov    %rcx,(%r12,%rdx,8)
    9ce8:	mov    %rbx,0x8(%r12,%rdx,8)
    9ced:	or     %r11,%rdx
    9cf0:	test   %r9,%r9
    9cf3:	jne    9a20 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x50>
    9cf9:	jmpq   9e9b <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x4cb>
    9cfe:	mov    %r12,%rdi
    9d01:	mov    %r13,%rsi
    9d04:	mov    $0x1,%edx
    9d09:	callq  11f78 <heap_alloc_miss>
    9d0e:	movabs $0xffff0000000000,%rdi
    9d18:	movabs $0x200080000000000,%r11
    9d22:	mov    %rax,%rcx
    9d25:	jmp    9cb5 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x2e5>
    9d27:	mov    %r12,%rdi
    9d2a:	mov    %r13,%rsi
    9d2d:	mov    $0x1,%edx
    9d32:	callq  11f78 <heap_alloc_miss>
    9d37:	movabs $0xffff0000000000,%rdi
    9d41:	movabs $0x200080000000000,%r11
    9d4b:	mov    %rax,%rdx
    9d4e:	jmp    9cde <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x30e>
    9d50:	mov    %r12,%rdi
    9d53:	mov    %r13,%rsi
    9d56:	mov    $0x1,%edx
    9d5b:	callq  11e51 <heap_hand>
    9d60:	movabs $0xffff0000000000,%rdi
    9d6a:	movabs $0x200080000000000,%r11
    9d74:	jmpq   9b14 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x144>
    9d79:	mov    %r12,%rdi
    9d7c:	mov    %r13,%rsi
    9d7f:	mov    $0x1,%edx
    9d84:	callq  11e51 <heap_hand>
    9d89:	movabs $0xffff0000000000,%rdi
    9d93:	movabs $0x200080000000000,%r11
    9d9d:	jmpq   9c02 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x232>
    9da2:	shl    $0x20,%rcx
    9da6:	or     %rax,%rcx
    9da9:	shr    $0x18,%rcx
    9dad:	mov    (%r12,%rcx,8),%rax
    9db1:	mov    0x8(%r12,%rcx,8),%rbx
    9db6:	mov    %r12,%rdi
    9db9:	mov    %r13,%rsi
    9dbc:	mov    $0x2,%r8d
    9dc2:	callq  11ee2 <span_fade>
    9dc7:	movabs $0x200080000000000,%r11
    9dd1:	movabs $0xffffffff80,%r8
    9ddb:	movabs $0xffff0000000000,%rdi
    9de5:	jmpq   9b14 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x144>
    9dea:	shl    $0x20,%rcx
    9dee:	or     %rsi,%rcx
    9df1:	shr    $0x18,%rcx
    9df5:	mov    (%r12,%rcx,8),%r15
    9df9:	mov    0x8(%r12,%rcx,8),%r10
    9dfe:	mov    %r12,%rdi
    9e01:	mov    %r13,%rsi
    9e04:	mov    %rax,%rdx
    9e07:	mov    $0x2,%r8d
    9e0d:	callq  11ee2 <span_fade>
    9e12:	movabs $0x200080000000000,%r11
    9e1c:	movabs $0xffffffff80,%r8
    9e26:	movabs $0xffff0000000000,%rdi
    9e30:	jmpq   9c02 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x232>
    9e35:	mov    %r12,%rdi
    9e38:	mov    %r13,%rsi
    9e3b:	xor    %edx,%edx
    9e3d:	callq  11e51 <heap_hand>
    9e42:	movabs $0x200080000000000,%r11
    9e4c:	movabs $0xffff0000000000,%rdi
    9e56:	cmp    $0x3108180,%rcx
    9e5d:	jae    9adc <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x10c>
    9e63:	jmpq   9b14 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x144>
    9e68:	mov    %r12,%rdi
    9e6b:	mov    %r13,%rsi
    9e6e:	xor    %edx,%edx
    9e70:	callq  11e51 <heap_hand>
    9e75:	movabs $0x200080000000000,%r11
    9e7f:	movabs $0xffff0000000000,%rdi
    9e89:	cmp    $0x3108180,%rcx
    9e90:	jae    9bcb <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x1fb>
    9e96:	jmpq   9c02 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x232>
    9e9b:	mov    0x8(%rsp),%r14
    9ea0:	mov    -0x8(%r14),%eax
    9ea4:	add    $0xfffffffffffffff8,%r14
    9ea8:	lea    0xa531(%rip),%rcx        # 143e0 <wl_tab>
    9eaf:	mov    (%rcx,%rax,8),%rax
    9eb3:	mov    0x4(%rsp),%r15d
    9eb8:	mov    $0x1,%edi
    9ebd:	mov    %rdx,%rsi
    9ec0:	add    $0x10,%rsp
    9ec4:	pop    %rbp
    9ec5:	jmpq   *%rax
    9ec7:	movabs $0x7e00000000000000,%r14
    9ed1:	test   %r14,%rax
    9ed4:	sete   %cl
    9ed7:	cmp    $0xffffffffffffffff,%rax
    9edb:	sete   %dl
    9ede:	or     %cl,%dl
    9ee0:	mov    %rax,%rcx
    9ee3:	and    %r8,%rcx
    9ee6:	cmp    $0x3108180,%rcx
    9eed:	setb   %cl
    9ef0:	or     %dl,%cl
    9ef2:	jne    9f02 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x532>
    9ef4:	mov    %r12,%rdi
    9ef7:	mov    %r13,%rsi
    9efa:	mov    %rax,%rdx
    9efd:	callq  6ac0 <term_drop>
    9f02:	test   %r14,%rbx
    9f05:	sete   %al
    9f08:	cmp    $0xffffffffffffffff,%rbx
    9f0c:	sete   %cl
    9f0f:	or     %al,%cl
    9f11:	movabs $0xffffffff80,%rax
    9f1b:	and    %rbx,%rax
    9f1e:	cmp    $0x3108180,%rax
    9f24:	setb   %al
    9f27:	or     %cl,%al
    9f29:	jne    9f6b <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x59b>
    9f2b:	mov    %r12,%rdi
    9f2e:	mov    %r13,%rsi
    9f31:	mov    %rbx,%rdx
    9f34:	jmp    9f66 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x596>
    9f36:	movabs $0x7e00000000000000,%rax
    9f40:	test   %rax,%rdx
    9f43:	sete   %al
    9f46:	cmp    $0xffffffffffffffff,%rdx
    9f4a:	sete   %cl
    9f4d:	or     %al,%cl
    9f4f:	and    %rdx,%r8
    9f52:	cmp    $0x3108180,%r8
    9f59:	setb   %al
    9f5c:	or     %cl,%al
    9f5e:	jne    9f6b <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x59b>
    9f60:	mov    %r12,%rdi
    9f63:	mov    %r13,%rsi
    9f66:	callq  6ac0 <term_drop>
    9f6b:	lea    -0x7a62(%rip),%rdi        # 2510 <FID_RESW_T+0x310>
    9f72:	callq  11df0 <err_fail>
    9f77:	lea    -0x74a5(%rip),%rdi        # 2ad9 <FID_RESW_T+0x8d9>
    9f7e:	callq  11df0 <err_fail>

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
