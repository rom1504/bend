
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p130-native01-n1/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000dcb940 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_104_97_115_104_>:
  dcb940:	f3 0f 1e fa          	endbr64 
  dcb944:	55                   	push   %rbp
  dcb945:	48 89 e5             	mov    %rsp,%rbp
  dcb948:	48 83 ec 10          	sub    $0x10,%rsp
  dcb94c:	53                   	push   %rbx
  dcb94d:	41 54                	push   %r12
  dcb94f:	be 00 00 00 00       	mov    $0x0,%esi
  dcb954:	48 89 fb             	mov    %rdi,%rbx
  dcb957:	e8 54 c0 01 00       	callq  de79b0 <p111_rt_reg_get>
  dcb95c:	48 89 df             	mov    %rbx,%rdi
  dcb95f:	48 89 c6             	mov    %rax,%rsi
  dcb962:	49 89 f4             	mov    %rsi,%r12
  dcb965:	be 01 00 00 00       	mov    $0x1,%esi
  dcb96a:	48 89 fb             	mov    %rdi,%rbx
  dcb96d:	e8 3e c0 01 00       	callq  de79b0 <p111_rt_reg_get>
  dcb972:	4c 89 e6             	mov    %r12,%rsi
  dcb975:	48 89 df             	mov    %rbx,%rdi
  dcb978:	48 89 c2             	mov    %rax,%rdx
  dcb97b:	48 89 fb             	mov    %rdi,%rbx
  dcb97e:	e8 9d ac 63 ff       	callq  406620 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_104_97_115_104_>
  dcb983:	48 89 df             	mov    %rbx,%rdi
  dcb986:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  dcb98a:	ba 01 00 00 00       	mov    $0x1,%edx
  dcb98f:	48 8d 75 f8          	lea    -0x8(%rbp),%rsi
  dcb993:	e8 c8 be 01 00       	callq  de7860 <p111_rt_return>
  dcb998:	41 5c                	pop    %r12
  dcb99a:	5b                   	pop    %rbx
  dcb99b:	c9                   	leaveq 
  dcb99c:	c3                   	retq   

Disassembly of section .fini:
