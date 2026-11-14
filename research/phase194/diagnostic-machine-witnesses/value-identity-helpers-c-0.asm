
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-references02/value-identity-helpers/c/program:     file format elf64-x86-64


Disassembly of section .text:

0000000000009c00 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_>:
    9c00:	test   %rsi,%rsi
    9c03:	je     9ca6 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_+0xa6>
    9c09:	mov    %rsi,%rdi
    9c0c:	mov    %rsi,%rax
    9c0f:	and    $0x3,%rdi
    9c13:	je     9c44 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_+0x44>
    9c15:	mov    %edx,%r8d
    9c18:	nopl   0x0(%rax,%rax,1)
    9c20:	mov    %ecx,%ebx
    9c22:	dec    %rax
    9c25:	lea    0x1(%r8),%edx
    9c29:	add    %ecx,%r8d
    9c2c:	xor    $0x9e3779b9,%r8d
    9c33:	imul   $0x19660d,%r8d,%ecx
    9c3a:	add    %ebx,%ecx
    9c3c:	mov    %edx,%r8d
    9c3f:	dec    %rdi
    9c42:	jne    9c20 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_+0x20>
    9c44:	cmp    $0x4,%rsi
    9c48:	jb     9ca6 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_+0xa6>
    9c4a:	nopw   0x0(%rax,%rax,1)
    9c50:	lea    (%rdx,%rcx,1),%esi
    9c53:	xor    $0x9e3779b9,%esi
    9c59:	imul   $0x19660d,%esi,%esi
    9c5f:	add    %ecx,%esi
    9c61:	mov    %edx,%ecx
    9c63:	lea    (%rcx,%rsi,1),%edi
    9c66:	inc    %edi
    9c68:	xor    $0x9e3779b9,%edi
    9c6e:	imul   $0x19660d,%edi,%edi
    9c74:	add    %esi,%edi
    9c76:	lea    (%rcx,%rdi,1),%esi
    9c79:	add    $0x2,%esi
    9c7c:	xor    $0x9e3779b9,%esi
    9c82:	imul   $0x19660d,%esi,%esi
    9c88:	add    %edi,%esi
    9c8a:	add    $0x4,%edx
    9c8d:	add    %esi,%ecx
    9c8f:	add    $0x3,%ecx
    9c92:	xor    $0x9e3779b9,%ecx
    9c98:	imul   $0x19660d,%ecx,%ecx
    9c9e:	add    %esi,%ecx
    9ca0:	add    $0xfffffffffffffffc,%rax
    9ca4:	jne    9c50 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_+0x50>
    9ca6:	mov    %ecx,%esi
    9ca8:	mov    -0x8(%r14),%eax
    9cac:	add    $0xfffffffffffffff8,%r14
    9cb0:	lea    0x9489(%rip),%rcx        # 13140 <wl_tab>
    9cb7:	mov    (%rcx,%rax,8),%rax
    9cbb:	mov    $0x1,%edi
    9cc0:	jmpq   *%rax

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
