
/home/ai/bend2/build/publish/bend/selfhost/build/phase193/budget-native45-02/tree-bitonic/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040e8a5 <p114r_FID_36_100_105_114_101_99_116_46_115_99_97_110_>:
  40e8a5:	push   %rbp
  40e8a6:	mov    %rsp,%rbp
  40e8a9:	sub    $0x1a40,%rsp
  40e8b0:	mov    %r12,-0x10(%rbp)
  40e8b4:	mov    %rbx,-0x8(%rbp)
  40e8b8:	mov    %r13,-0x18(%rbp)
  40e8bc:	mov    %r14,-0x20(%rbp)
  40e8c0:	mov    %rdi,%rax
  40e8c3:	mov    %rax,%r12
  40e8c6:	mov    %rsi,%rax
  40e8c9:	mov    %rax,%rbx
  40e8cc:	mov    %rdx,%rax
  40e8cf:	mov    %rax,%rdi
  40e8d2:	mov    %rcx,%rax
  40e8d5:	mov    %rax,%r13
  40e8d8:	mov    %r8,%rax
  40e8db:	mov    %rax,%r14
  40e8de:	mov    %rdi,%r10
  40e8e1:	test   %r10d,%r10d
  40e8e4:	je     40ea71 <p114r_FID_36_100_105_114_101_99_116_46_115_99_97_110_+0x1cc>
  40e8ea:	cmp    $0x0,%r13
  40e8f1:	je     40ea59 <p114r_FID_36_100_105_114_101_99_116_46_115_99_97_110_+0x1b4>
  40e8f7:	sub    $0x1,%r13
  40e8fe:	mov    0x10(%r12),%rdi
  40e903:	movabs $0xfffffffffffffff8,%r11
  40e90d:	add    %r11,%rdi
  40e910:	mov    %rdi,0x10(%r12)
  40e915:	mov    0x10(%r12),%rdi
  40e91a:	mov    (%rdi),%rdi
  40e91d:	movabs $0x48,%r11
  40e927:	cmp    %r11,%rdi
  40e92a:	jne    40e9b2 <p114r_FID_36_100_105_114_101_99_116_46_115_99_97_110_+0x10d>
  40e930:	mov    0x10(%r12),%rdi
  40e935:	movabs $0xfffffffffffffff8,%r11
  40e93f:	add    %r11,%rdi
  40e942:	mov    %rdi,0x10(%r12)
  40e947:	mov    0x10(%r12),%rdi
  40e94c:	mov    (%rdi),%rbx
  40e94f:	lea    -0x10b8(%rbp),%r10
  40e956:	mov    %r14,%r11
  40e959:	mov    %r11,(%r10)
  40e95c:	mov    %r12,%rdi
  40e95f:	movabs $0x49,%rsi
  40e969:	mov    %esi,%esi
  40e96b:	lea    -0x10b8(%rbp),%rdx
  40e972:	movabs $0x1,%rcx
  40e97c:	mov    %ecx,%ecx
  40e97e:	xor    %eax,%eax
  40e980:	callq  41c610 <p111_rt_frame>
  40e985:	mov    %rax,-0x1910(%rbp)
  40e98c:	add    $0x1,%r13
  40e993:	lea    -0x10b8(%rbp),%r10
  40e99a:	mov    %rbx,%r11
  40e99d:	mov    %r11,(%r10)
  40e9a0:	movabs $0x0,%r10
  40e9aa:	mov    %r10,%rdi
  40e9ad:	jmpq   40e8de <p114r_FID_36_100_105_114_101_99_116_46_115_99_97_110_+0x39>
  40e9b2:	movabs $0x49,%r11
  40e9bc:	cmp    %r11,%rdi
  40e9bf:	jne    40ea27 <p114r_FID_36_100_105_114_101_99_116_46_115_99_97_110_+0x182>
  40e9c5:	mov    0x10(%r12),%rdi
  40e9ca:	movabs $0xfffffffffffffff8,%r11
  40e9d4:	add    %r11,%rdi
  40e9d7:	mov    %rdi,0x10(%r12)
  40e9dc:	mov    0x10(%r12),%rdi
  40e9e1:	mov    (%rdi),%rdi
  40e9e4:	mov    %r12,%r10
  40e9e7:	mov    %r10,0x18(%rsp)
  40e9ec:	mov    %rdi,%r10
  40e9ef:	mov    %r10,0x20(%rsp)
  40e9f4:	mov    %r14,%r10
  40e9f7:	mov    %r10,0x28(%rsp)
  40e9fc:	mov    0x18(%rsp),%rdi
  40ea01:	mov    0x20(%rsp),%rsi
  40ea06:	mov    0x28(%rsp),%rdx
  40ea0b:	xor    %eax,%eax
  40ea0d:	callq  409767 <p112w_FID_36_100_105_114_101_99_116_46_115_116_97_116_95_106_111_105_110_>
  40ea12:	mov    %rax,%r14
  40ea15:	movabs $0x1,%r10
  40ea1f:	mov    %r10,%rdi
  40ea22:	jmpq   40e8de <p114r_FID_36_100_105_114_101_99_116_46_115_99_97_110_+0x39>
  40ea27:	mov    %r12,%rdi
  40ea2a:	movabs $0x4,%rsi
  40ea34:	mov    %esi,%esi
  40ea36:	xor    %eax,%eax
  40ea38:	callq  41c860 <p111_rt_fail>
  40ea3d:	mov    %rax,-0x1940(%rbp)
  40ea44:	mov    -0x10(%rbp),%r12
  40ea48:	mov    -0x8(%rbp),%rbx
  40ea4c:	mov    -0x18(%rbp),%r13
  40ea50:	mov    -0x20(%rbp),%r14
  40ea54:	mov    %rbp,%rsp
  40ea57:	pop    %rbp
  40ea58:	retq   
  40ea59:	mov    %r14,%rax
  40ea5c:	mov    -0x10(%rbp),%r12
  40ea60:	mov    -0x8(%rbp),%rbx
  40ea64:	mov    -0x18(%rbp),%r13
  40ea68:	mov    -0x20(%rbp),%r14
  40ea6c:	mov    %rbp,%rsp
  40ea6f:	pop    %rbp
  40ea70:	retq   
  40ea71:	mov    %rbx,%rdi
  40ea74:	shr    $0x28,%rdi
  40ea78:	and    $0xffff,%rdi
  40ea7f:	movabs $0xa4,%r11
  40ea89:	cmp    %r11,%rdi
  40ea8c:	jne    40ebbc <p114r_FID_36_100_105_114_101_99_116_46_115_99_97_110_+0x317>
  40ea92:	mov    %rbx,%rdi
  40ea95:	shr    $0x28,%rdi
  40ea99:	and    $0x7fffff,%rdi
  40eaa0:	movabs $0xa4,%rsi
  40eaaa:	or     $0x10000,%rsi
  40eab1:	cmp    %rsi,%rdi
  40eab4:	jne    40eadc <p114r_FID_36_100_105_114_101_99_116_46_115_99_97_110_+0x237>
  40eaba:	movabs $0xffffffffff,%r11
  40eac4:	mov    %rbx,%rdi
  40eac7:	and    %r11,%rdi
  40eaca:	lea    -0x850(%rbp),%r10
  40ead1:	mov    %rdi,%r11
  40ead4:	mov    %r11,(%r10)
  40ead7:	jmpq   40eaf7 <p114r_FID_36_100_105_114_101_99_116_46_115_99_97_110_+0x252>
  40eadc:	mov    %r12,%rdi
  40eadf:	mov    %rbx,%rsi
  40eae2:	lea    -0x850(%rbp),%rdx
  40eae9:	xor    %eax,%eax
  40eaeb:	callq  421bf0 <p125_rt_take1>
  40eaf0:	mov    %rax,-0x1980(%rbp)
  40eaf7:	lea    -0x850(%rbp),%r10
  40eafe:	mov    (%r10),%rdi
  40eb01:	mov    %r12,%r10
  40eb04:	mov    %r10,0x10(%rsp)
  40eb09:	mov    %rdi,%r10
  40eb0c:	mov    %r10,0x18(%rsp)
  40eb11:	mov    0x10(%rsp),%rdi
  40eb16:	mov    0x18(%rsp),%rsi
  40eb1b:	xor    %eax,%eax
  40eb1d:	callq  41c040 <p111_rt_keep>
  40eb22:	mov    %rax,%rdi
  40eb25:	mov    %rdi,%r14
  40eb28:	mov    %r12,%r10
  40eb2b:	mov    %r10,0x10(%rsp)
  40eb30:	mov    %rdi,%r10
  40eb33:	mov    %r10,0x18(%rsp)
  40eb38:	mov    0x10(%rsp),%rdi
  40eb3d:	mov    0x18(%rsp),%rsi
  40eb42:	xor    %eax,%eax
  40eb44:	callq  41c040 <p111_rt_keep>
  40eb49:	mov    %rax,%rdi
  40eb4c:	lea    -0x850(%rbp),%r10
  40eb53:	mov    %r14,%r11
  40eb56:	mov    %r11,(%r10)
  40eb59:	lea    -0x850(%rbp),%r10
  40eb60:	mov    %rdi,%r11
  40eb63:	mov    %r11,0x8(%r10)
  40eb67:	lea    -0x850(%rbp),%r10
  40eb6e:	movabs $0x1,%r11
  40eb78:	mov    %r11,0x10(%r10)
  40eb7c:	lea    -0x850(%rbp),%r10
  40eb83:	mov    %rdi,%r11
  40eb86:	mov    %r11,0x18(%r10)
  40eb8a:	mov    %r12,%rdi
  40eb8d:	movabs $0xa6,%rsi
  40eb97:	mov    %esi,%esi
  40eb99:	lea    -0x850(%rbp),%rdx
  40eba0:	xor    %eax,%eax
  40eba2:	callq  422270 <p125_rt_ctor4>
  40eba7:	mov    %rax,%r14
  40ebaa:	movabs $0x1,%r10
  40ebb4:	mov    %r10,%rdi
  40ebb7:	jmpq   40e8de <p114r_FID_36_100_105_114_101_99_116_46_115_99_97_110_+0x39>
  40ebbc:	mov    %rbx,%rdi
  40ebbf:	shr    $0x28,%rdi
  40ebc3:	and    $0xffff,%rdi
  40ebca:	movabs $0xa5,%r11
  40ebd4:	cmp    %r11,%rdi
  40ebd7:	jne    40ec78 <p114r_FID_36_100_105_114_101_99_116_46_115_99_97_110_+0x3d3>
  40ebdd:	mov    %r12,%rdi
  40ebe0:	mov    %rbx,%rsi
  40ebe3:	lea    -0x850(%rbp),%rdx
  40ebea:	xor    %eax,%eax
  40ebec:	callq  421e70 <p125_rt_take2>
  40ebf1:	mov    %rax,-0x1980(%rbp)
  40ebf8:	lea    -0x850(%rbp),%r10
  40ebff:	mov    (%r10),%rbx
  40ec02:	lea    -0x850(%rbp),%r10
  40ec09:	mov    0x8(%r10),%rsi
  40ec0d:	lea    -0x850(%rbp),%r10
  40ec14:	mov    %rsi,%r11
  40ec17:	mov    %r11,(%r10)
  40ec1a:	mov    0x10(%r12),%rdi
  40ec1f:	mov    %rsi,(%rdi)
  40ec22:	mov    %rdi,%r10
  40ec25:	movabs $0x48,%r11
  40ec2f:	mov    %r11,0x8(%r10)
  40ec33:	mov    %rdi,%r10
  40ec36:	add    $0x10,%r10
  40ec3d:	mov    %r10,-0x19b8(%rbp)
  40ec44:	mov    %r12,%r10
  40ec47:	mov    -0x19b8(%rbp),%r11
  40ec4e:	mov    %r11,0x10(%r10)
  40ec52:	add    $0x1,%r13
  40ec59:	lea    -0x850(%rbp),%r10
  40ec60:	mov    %rbx,%r11
  40ec63:	mov    %r11,(%r10)
  40ec66:	movabs $0x0,%r10
  40ec70:	mov    %r10,%rdi
  40ec73:	jmpq   40e8de <p114r_FID_36_100_105_114_101_99_116_46_115_99_97_110_+0x39>
  40ec78:	lea    -0x850(%rbp),%r10
  40ec7f:	mov    %rbx,%r11
  40ec82:	mov    %r11,(%r10)
  40ec85:	mov    %r12,%r10
  40ec88:	mov    0x10(%r10),%r10
  40ec8c:	mov    %r10,-0x19c0(%rbp)
  40ec93:	mov    %rbx,%r11
  40ec96:	mov    %r11,(%r10)
  40ec99:	mov    -0x19c0(%rbp),%r10
  40eca0:	movabs $0x4a,%r11
  40ecaa:	mov    %r11,0x8(%r10)
  40ecae:	mov    -0x19c0(%rbp),%r10
  40ecb5:	add    $0x10,%r10
  40ecbc:	mov    %r10,-0x19c8(%rbp)
  40ecc3:	mov    %r12,%r10
  40ecc6:	mov    -0x19c8(%rbp),%r11
  40eccd:	mov    %r11,0x10(%r10)
  40ecd1:	mov    %r12,%rdi
  40ecd4:	movabs $0x4,%rsi
  40ecde:	mov    %esi,%esi
  40ece0:	xor    %eax,%eax
  40ece2:	callq  41c860 <p111_rt_fail>
  40ece7:	mov    %rax,-0x19d0(%rbp)
  40ecee:	mov    -0x10(%rbp),%r12
  40ecf2:	mov    -0x8(%rbp),%rbx
  40ecf6:	mov    -0x18(%rbp),%r13
  40ecfa:	mov    -0x20(%rbp),%r14
  40ecfe:	mov    %rbp,%rsp
  40ed01:	pop    %rbp
  40ed02:	retq   

Disassembly of section .fini:
