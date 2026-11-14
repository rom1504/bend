
selfhost/build/phase194/native45-02/editdist/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040bb78 <p113d_FID_36_100_105_114_101_99_116_46_114_111_119_>:
  40bb78:	push   %rbp
  40bb79:	mov    %rsp,%rbp
  40bb7c:	sub    $0x990,%rsp
  40bb83:	mov    %r12,-0x10(%rbp)
  40bb87:	mov    %rbx,-0x8(%rbp)
  40bb8b:	mov    %r13,-0x18(%rbp)
  40bb8f:	mov    %r14,-0x20(%rbp)
  40bb93:	mov    %rdi,%rax
  40bb96:	mov    %rax,%r12
  40bb99:	mov    %rsi,%rax
  40bb9c:	mov    %rax,%rdi
  40bb9f:	mov    %rdx,%rax
  40bba2:	mov    %rax,%rdx
  40bba5:	mov    %rcx,%rax
  40bba8:	mov    %rax,%rbx
  40bbab:	mov    %r8,%rax
  40bbae:	mov    %rax,%r8
  40bbb1:	cmp    $0x0,%rdi
  40bbb8:	jne    40bcee <p113d_FID_36_100_105_114_101_99_116_46_114_111_119_+0x176>
  40bbbe:	mov    %r8,%rdi
  40bbc1:	shr    $0x28,%rdi
  40bbc5:	and    $0xffff,%rdi
  40bbcc:	movabs $0xa4,%r11
  40bbd6:	cmp    %r11,%rdi
  40bbd9:	jne    40bcb2 <p113d_FID_36_100_105_114_101_99_116_46_114_111_119_+0x13a>
  40bbdf:	mov    %r12,%r10
  40bbe2:	mov    %r10,0x18(%rsp)
  40bbe7:	mov    %r8,%r10
  40bbea:	mov    %r10,0x20(%rsp)
  40bbef:	lea    -0x850(%rbp),%r10
  40bbf6:	mov    %r10,0x28(%rsp)
  40bbfb:	mov    0x18(%rsp),%rdi
  40bc00:	mov    0x20(%rsp),%rsi
  40bc05:	mov    0x28(%rsp),%rdx
  40bc0a:	xor    %eax,%eax
  40bc0c:	callq  422ff0 <p125_rt_take4>
  40bc11:	mov    %rax,-0x8d0(%rbp)
  40bc18:	lea    -0x850(%rbp),%r10
  40bc1f:	mov    (%r10),%rdi
  40bc22:	lea    -0x850(%rbp),%r10
  40bc29:	mov    0x8(%r10),%rsi
  40bc2d:	lea    -0x850(%rbp),%r10
  40bc34:	mov    0x10(%r10),%r8
  40bc38:	lea    -0x850(%rbp),%r10
  40bc3f:	mov    0x18(%r10),%rdx
  40bc43:	lea    -0x850(%rbp),%r10
  40bc4a:	mov    %rdi,%r11
  40bc4d:	mov    %r11,(%r10)
  40bc50:	lea    -0x850(%rbp),%r10
  40bc57:	mov    %rsi,%r11
  40bc5a:	mov    %r11,0x8(%r10)
  40bc5e:	lea    -0x850(%rbp),%r10
  40bc65:	mov    %rdx,%r11
  40bc68:	mov    %r11,0x10(%r10)
  40bc6c:	lea    -0x850(%rbp),%r10
  40bc73:	mov    %r8,%r11
  40bc76:	mov    %r11,0x18(%r10)
  40bc7a:	mov    %r12,%rdi
  40bc7d:	movabs $0xa4,%rsi
  40bc87:	mov    %esi,%esi
  40bc89:	lea    -0x850(%rbp),%rdx
  40bc90:	xor    %eax,%eax
  40bc92:	callq  422f20 <p125_rt_ctor4>
  40bc97:	mov    %rax,%rdi
  40bc9a:	mov    %rdi,%rax
  40bc9d:	mov    -0x10(%rbp),%r12
  40bca1:	mov    -0x8(%rbp),%rbx
  40bca5:	mov    -0x18(%rbp),%r13
  40bca9:	mov    -0x20(%rbp),%r14
  40bcad:	mov    %rbp,%rsp
  40bcb0:	pop    %rbp
  40bcb1:	retq   
  40bcb2:	mov    %r12,%rdi
  40bcb5:	movabs $0x4,%rsi
  40bcbf:	mov    %esi,%esi
  40bcc1:	xor    %eax,%eax
  40bcc3:	callq  41d510 <p111_rt_fail>
  40bcc8:	mov    %rax,-0x8d0(%rbp)
  40bccf:	movabs $0x0,%rax
  40bcd9:	mov    -0x10(%rbp),%r12
  40bcdd:	mov    -0x8(%rbp),%rbx
  40bce1:	mov    -0x18(%rbp),%r13
  40bce5:	mov    -0x20(%rbp),%r14
  40bce9:	mov    %rbp,%rsp
  40bcec:	pop    %rbp
  40bced:	retq   
  40bcee:	mov    %rdi,%r13
  40bcf1:	sub    $0x1,%r13
  40bcf8:	mov    %edx,%edi
  40bcfa:	add    $0x1,%edi
  40bd00:	mov    %rdi,%r14
  40bd03:	mov    %r12,%r10
  40bd06:	mov    %r10,0x20(%rsp)
  40bd0b:	mov    %rdx,%r10
  40bd0e:	mov    %r10,0x28(%rsp)
  40bd13:	mov    %rbx,%r10
  40bd16:	mov    %r10,0x30(%rsp)
  40bd1b:	mov    %r8,%r10
  40bd1e:	mov    %r10,0x38(%rsp)
  40bd23:	mov    0x20(%rsp),%rdi
  40bd28:	mov    0x28(%rsp),%rsi
  40bd2d:	mov    0x30(%rsp),%rdx
  40bd32:	mov    0x38(%rsp),%rcx
  40bd37:	xor    %eax,%eax
  40bd39:	callq  40aede <p113d_FID_36_100_105_114_101_99_116_46_99_101_108_108_>
  40bd3e:	mov    %rax,%r8
  40bd41:	mov    %r13,%rdi
  40bd44:	mov    %r14,%rdx
  40bd47:	jmpq   40bbb1 <p113d_FID_36_100_105_114_101_99_116_46_114_111_119_+0x39>

Disassembly of section .fini:
