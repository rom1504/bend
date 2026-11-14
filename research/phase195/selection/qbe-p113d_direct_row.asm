
/home/ai/bend2/build/publish/bend/selfhost/build/phase186/release-native45-acquire01/editdist/phase186-qbe-n2/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000408790 <p113d_FID_36_100_105_114_101_99_116_46_114_111_119_>:
  408790:	endbr64 
  408794:	push   %rbp
  408795:	mov    %rsp,%rbp
  408798:	sub    $0x800,%rsp
  40879f:	push   %rbx
  4087a0:	push   %r12
  4087a2:	push   %r13
  4087a4:	push   %r14
  4087a6:	mov    %r8,%rax
  4087a9:	mov    %rdi,%rbx
  4087ac:	mov    %rbx,%rdi
  4087af:	mov    %rax,%r8
  4087b2:	data16 nopw %cs:0x0(%rax,%rax,1)
  4087bd:	nopl   (%rax)
  4087c0:	cmp    $0x0,%rsi
  4087c4:	je     4087fd <p113d_FID_36_100_105_114_101_99_116_46_114_111_119_+0x6d>
  4087c6:	sub    $0x1,%rsi
  4087ca:	mov    %edx,%eax
  4087cc:	add    $0x1,%eax
  4087cf:	mov    %eax,%r13d
  4087d2:	mov    %rcx,%r14
  4087d5:	mov    %r8,%rcx
  4087d8:	mov    %rdx,%rbx
  4087db:	mov    %r14,%rdx
  4087de:	mov    %rsi,%r12
  4087e1:	mov    %rbx,%rsi
  4087e4:	mov    %rdi,%rbx
  4087e7:	callq  408130 <p113d_FID_36_100_105_114_101_99_116_46_99_101_108_108_>
  4087ec:	mov    %r14,%rcx
  4087ef:	mov    %r13,%rdx
  4087f2:	mov    %r12,%rsi
  4087f5:	mov    %rbx,%rdi
  4087f8:	mov    %rax,%r8
  4087fb:	jmp    4087c0 <p113d_FID_36_100_105_114_101_99_116_46_114_111_119_+0x30>
  4087fd:	mov    %r8,%rsi
  408800:	mov    %rdi,%rbx
  408803:	mov    %rsi,%rax
  408806:	shr    $0x28,%rax
  40880a:	and    $0xffff,%rax
  408810:	cmp    $0xa4,%rax
  408816:	je     40882f <p113d_FID_36_100_105_114_101_99_116_46_114_111_119_+0x9f>
  408818:	mov    $0x4,%esi
  40881d:	mov    %rbx,%rdi
  408820:	callq  414d30 <p111_rt_fail>
  408825:	mov    $0x0,%eax
  40882a:	jmpq   4088e0 <p113d_FID_36_100_105_114_101_99_116_46_114_111_119_+0x150>
  40882f:	cs lea %cs:-0x800(%rbp),%rdx
  408838:	mov    %rbx,%rdi
  40883b:	callq  41a810 <p125_rt_take4>
  408840:	mov    -0x800(%rbp),%r9
  408847:	mov    -0x7f8(%rbp),%r8
  40884e:	mov    -0x7f0(%rbp),%rcx
  408855:	mov    -0x7e8(%rbp),%rdi
  40885c:	mov    %r9,-0x800(%rbp)
  408863:	mov    %r8,-0x7f8(%rbp)
  40886a:	mov    %rdi,-0x7f0(%rbp)
  408871:	mov    %rcx,-0x7e8(%rbp)
  408878:	mov    0x8(%rbx),%r11
  40887c:	mov    0x10(%r11),%rax
  408880:	cmp    $0x0,%rax
  408884:	jne    40889c <p113d_FID_36_100_105_114_101_99_116_46_114_111_119_+0x10c>
  408886:	lea    -0x800(%rbp),%rdx
  40888d:	mov    $0xa4,%esi
  408892:	mov    %rbx,%rdi
  408895:	callq  41a740 <p125_rt_ctor4>
  40889a:	jmp    4088e0 <p113d_FID_36_100_105_114_101_99_116_46_114_111_119_+0x150>
  40889c:	mov    (%rbx),%rdx
  40889f:	mov    %rax,%rsi
  4088a2:	shl    $0x3,%rsi
  4088a6:	mov    (%rdx,%rsi,1),%rbx
  4088aa:	mov    0x110(%r11),%r10
  4088b1:	mov    %rbx,0x10(%r11)
  4088b5:	sub    $0x4,%r10
  4088b9:	mov    %r10,0x110(%r11)
  4088c0:	mov    %r9,(%rdx,%rsi,1)
  4088c4:	mov    %r8,0x8(%rdx,%rsi,1)
  4088c9:	mov    %rdi,0x10(%rdx,%rsi,1)
  4088ce:	mov    %rcx,0x18(%rdx,%rsi,1)
  4088d3:	movabs $0x200a40000000000,%rcx
  4088dd:	or     %rcx,%rax
  4088e0:	pop    %r14
  4088e2:	pop    %r13
  4088e4:	pop    %r12
  4088e6:	pop    %rbx
  4088e7:	leaveq 
  4088e8:	retq   

Disassembly of section .fini:
