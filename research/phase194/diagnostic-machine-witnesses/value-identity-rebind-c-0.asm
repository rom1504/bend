
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-references02/value-identity-rebind/c/program:     file format elf64-x86-64


Disassembly of section .text:

0000000000009ba0 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_>:
    9ba0:	test   %rsi,%rsi
    9ba3:	je     9c46 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_+0xa6>
    9ba9:	mov    %rsi,%rdi
    9bac:	mov    %rsi,%rax
    9baf:	and    $0x3,%rdi
    9bb3:	je     9be4 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_+0x44>
    9bb5:	mov    %edx,%r8d
    9bb8:	nopl   0x0(%rax,%rax,1)
    9bc0:	mov    %ecx,%ebx
    9bc2:	dec    %rax
    9bc5:	lea    0x1(%r8),%edx
    9bc9:	add    %ecx,%r8d
    9bcc:	xor    $0x9e3779b9,%r8d
    9bd3:	imul   $0x19660d,%r8d,%ecx
    9bda:	add    %ebx,%ecx
    9bdc:	mov    %edx,%r8d
    9bdf:	dec    %rdi
    9be2:	jne    9bc0 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_+0x20>
    9be4:	cmp    $0x4,%rsi
    9be8:	jb     9c46 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_+0xa6>
    9bea:	nopw   0x0(%rax,%rax,1)
    9bf0:	lea    (%rdx,%rcx,1),%esi
    9bf3:	xor    $0x9e3779b9,%esi
    9bf9:	imul   $0x19660d,%esi,%esi
    9bff:	add    %ecx,%esi
    9c01:	mov    %edx,%ecx
    9c03:	lea    (%rcx,%rsi,1),%edi
    9c06:	inc    %edi
    9c08:	xor    $0x9e3779b9,%edi
    9c0e:	imul   $0x19660d,%edi,%edi
    9c14:	add    %esi,%edi
    9c16:	lea    (%rcx,%rdi,1),%esi
    9c19:	add    $0x2,%esi
    9c1c:	xor    $0x9e3779b9,%esi
    9c22:	imul   $0x19660d,%esi,%esi
    9c28:	add    %edi,%esi
    9c2a:	add    $0x4,%edx
    9c2d:	add    %esi,%ecx
    9c2f:	add    $0x3,%ecx
    9c32:	xor    $0x9e3779b9,%ecx
    9c38:	imul   $0x19660d,%ecx,%ecx
    9c3e:	add    %esi,%ecx
    9c40:	add    $0xfffffffffffffffc,%rax
    9c44:	jne    9bf0 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_+0x50>
    9c46:	mov    %ecx,%esi
    9c48:	mov    -0x8(%r14),%eax
    9c4c:	add    $0xfffffffffffffff8,%r14
    9c50:	lea    0x9429(%rip),%rcx        # 13080 <wl_tab>
    9c57:	mov    (%rcx,%rax,8),%rax
    9c5b:	mov    $0x1,%edi
    9c60:	jmpq   *%rax

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
