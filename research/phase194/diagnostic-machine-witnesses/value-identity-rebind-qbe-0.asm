
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-references02/value-identity-rebind/qbe/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000406a30 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_>:
  406a30:	endbr64 
  406a34:	push   %rbp
  406a35:	mov    %rsp,%rbp
  406a38:	mov    %rcx,%rax
  406a3b:	mov    %rax,%rcx
  406a3e:	xchg   %ax,%ax
  406a40:	cmp    $0x0,%rsi
  406a44:	je     406a72 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_+0x42>
  406a46:	sub    $0x1,%rsi
  406a4a:	mov    %rcx,%rax
  406a4d:	mov    %edx,%ecx
  406a4f:	mov    %ecx,%edx
  406a51:	add    $0x1,%edx
  406a54:	mov    %edx,%edx
  406a56:	mov    %eax,%eax
  406a58:	add    %eax,%ecx
  406a5a:	mov    %ecx,%ecx
  406a5c:	mov    $0x9e3779b9,%edi
  406a61:	xor    %rdi,%rcx
  406a64:	imul   $0x19660d,%ecx,%ecx
  406a6a:	mov    %ecx,%ecx
  406a6c:	add    %ecx,%eax
  406a6e:	mov    %eax,%ecx
  406a70:	jmp    406a40 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_+0x10>
  406a72:	mov    %rcx,%rax
  406a75:	leaveq 
  406a76:	retq   

Disassembly of section .fini:
