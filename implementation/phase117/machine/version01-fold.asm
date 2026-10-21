
selfhost/build/phase111/p117-version01-variation-local-fold-128-0-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

00000000004058c0 <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_>:
  4058c0:	endbr64 
  4058c4:	push   %rbp
  4058c5:	mov    %rsp,%rbp
  4058c8:	sub    $0x8,%rsp
  4058cc:	push   %rbx
  4058cd:	mov    (%rdi),%rax
  4058d0:	mov    %r8,%r10
  4058d3:	shr    $0x38,%r10
  4058d7:	cmp    $0x4,%r10
  4058db:	sete   %r11b
  4058df:	movzbl %r11b,%r11d
  4058e3:	movabs $0xffffffffff,%r10
  4058ed:	and    %r8,%r10
  4058f0:	cmp    $0x3108280,%r10
  4058f7:	setae  %bl
  4058fa:	movzbl %bl,%ebx
  4058fd:	test   %r11d,%ebx
  405900:	jne    405909 <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0x49>
  405902:	callq  405730 <p117v_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_>
  405907:	jmp    405973 <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0xb3>
  405909:	mov    %rcx,%r11
  40590c:	mov    %r8,%rcx
  40590f:	shr    $0x28,%rcx
  405913:	and    $0x1f,%rcx
  405917:	mov    $0x1,%edi
  40591c:	shl    %cl,%rdi
  40591f:	mov    %r11,%rcx
  405922:	sub    $0x1,%rdi
  405926:	shl    $0x3,%r10
  40592a:	add    %r10,%rax
  40592d:	nopl   (%rax)
  405930:	cmp    $0x0,%rdx
  405934:	je     405967 <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0xa7>
  405936:	sub    $0x1,%rdx
  40593a:	mov    %ecx,%r10d
  40593d:	mov    %rcx,%r11
  405940:	mov    %r10d,%ecx
  405943:	add    $0x1,%ecx
  405946:	mov    %ecx,%ecx
  405948:	and    %rdi,%r11
  40594b:	shl    $0x2,%r11
  40594f:	mov    %r9,%rbx
  405952:	mov    (%rax,%r11,1),%r9d
  405956:	mov    %ebx,%ebx
  405958:	add    %ebx,%r9d
  40595b:	mov    %r9d,%r9d
  40595e:	xor    %r9,%r10
  405961:	mov    %r10d,(%rax,%r11,1)
  405965:	jmp    405930 <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0x70>
  405967:	mov    %r8,(%rsi)
  40596a:	mov    %r9,0x8(%rsi)
  40596e:	mov    $0x0,%eax
  405973:	pop    %rbx
  405974:	leaveq 
  405975:	retq   

Disassembly of section .fini:
