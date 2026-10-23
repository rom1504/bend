
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-original-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000419010 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_95_108_101_103_97_99_121_>:
  419010:	f3 0f 1e fa          	endbr64 
  419014:	55                   	push   %rbp
  419015:	48 89 e5             	mov    %rsp,%rbp
  419018:	48 81 ec 00 10 00 00 	sub    $0x1000,%rsp
  41901f:	53                   	push   %rbx
  419020:	41 54                	push   %r12
  419022:	41 55                	push   %r13
  419024:	41 56                	push   %r14
  419026:	48 8b 77 28          	mov    0x28(%rdi),%rsi
  41902a:	4c 8b 6f 30          	mov    0x30(%rdi),%r13
  41902e:	4c 8b 67 38          	mov    0x38(%rdi),%r12
  419032:	48 8b 5f 40          	mov    0x40(%rdi),%rbx
  419036:	49 89 fe             	mov    %rdi,%r14
  419039:	e8 f2 bc 00 00       	callq  424d30 <p111_rt_keep>
  41903e:	4c 89 f7             	mov    %r14,%rdi
  419041:	48 89 c6             	mov    %rax,%rsi
  419044:	48 89 b5 00 f0 ff ff 	mov    %rsi,-0x1000(%rbp)
  41904b:	4c 89 ad 08 f0 ff ff 	mov    %r13,-0xff8(%rbp)
  419052:	4c 89 a5 10 f0 ff ff 	mov    %r12,-0xff0(%rbp)
  419059:	48 89 9d 18 f0 ff ff 	mov    %rbx,-0xfe8(%rbp)
  419060:	48 8b 47 10          	mov    0x10(%rdi),%rax
  419064:	48 89 30             	mov    %rsi,(%rax)
  419067:	4c 89 68 08          	mov    %r13,0x8(%rax)
  41906b:	4c 89 60 10          	mov    %r12,0x10(%rax)
  41906f:	48 89 58 18          	mov    %rbx,0x18(%rax)
  419073:	48 c7 40 20 d5 01 00 	movq   $0x1d5,0x20(%rax)
  41907a:	00 
  41907b:	48 83 c0 28          	add    $0x28,%rax
  41907f:	48 89 47 10          	mov    %rax,0x10(%rdi)
  419083:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  419088:	49 89 dc             	mov    %rbx,%r12
  41908b:	49 21 c4             	and    %rax,%r12
  41908e:	49 83 fc 00          	cmp    $0x0,%r12
  419092:	49 89 f5             	mov    %rsi,%r13
  419095:	40 0f 94 c6          	sete   %sil
  419099:	40 0f b6 f6          	movzbl %sil,%esi
  41909d:	48 89 fb             	mov    %rdi,%rbx
  4190a0:	e8 5b 39 ff ff       	callq  40ca00 <p112w_FID_36_100_105_114_101_99_116_46_66_111_111_108_46_110_111_116_>
  4190a5:	4c 89 ee             	mov    %r13,%rsi
  4190a8:	48 89 df             	mov    %rbx,%rdi
  4190ab:	48 89 c3             	mov    %rax,%rbx
  4190ae:	49 89 fd             	mov    %rdi,%r13
  4190b1:	e8 7a bc 00 00       	callq  424d30 <p111_rt_keep>
  4190b6:	4c 89 ef             	mov    %r13,%rdi
  4190b9:	48 89 c6             	mov    %rax,%rsi
  4190bc:	49 89 f6             	mov    %rsi,%r14
  4190bf:	49 89 fd             	mov    %rdi,%r13
  4190c2:	e8 09 38 ff ff       	callq  40c8d0 <p112w_FID_36_100_105_114_101_99_116_46_100_120_>
  4190c7:	4c 89 f6             	mov    %r14,%rsi
  4190ca:	4c 89 ef             	mov    %r13,%rdi
  4190cd:	49 89 c5             	mov    %rax,%r13
  4190d0:	49 89 fe             	mov    %rdi,%r14
  4190d3:	e8 f8 37 ff ff       	callq  40c8d0 <p112w_FID_36_100_105_114_101_99_116_46_100_120_>
  4190d8:	4c 89 f7             	mov    %r14,%rdi
  4190db:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  4190e0:	4c 21 e9             	and    %r13,%rcx
  4190e3:	48 83 f9 00          	cmp    $0x0,%rcx
  4190e7:	0f 94 c1             	sete   %cl
  4190ea:	0f b6 c9             	movzbl %cl,%ecx
  4190ed:	48 89 8d 00 f8 ff ff 	mov    %rcx,-0x800(%rbp)
  4190f4:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  4190f9:	48 21 c8             	and    %rcx,%rax
  4190fc:	49 39 c4             	cmp    %rax,%r12
  4190ff:	0f 92 c0             	setb   %al
  419102:	0f b6 c0             	movzbl %al,%eax
  419105:	48 89 85 08 f8 ff ff 	mov    %rax,-0x7f8(%rbp)
  41910c:	b9 02 00 00 00       	mov    $0x2,%ecx
  419111:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  419118:	be 44 00 00 00       	mov    $0x44,%esi
  41911d:	49 89 fc             	mov    %rdi,%r12
  419120:	e8 4b c4 00 00       	callq  425570 <p111_rt_op>
  419125:	4c 89 e7             	mov    %r12,%rdi
  419128:	48 89 9d 00 f8 ff ff 	mov    %rbx,-0x800(%rbp)
  41912f:	48 89 85 08 f8 ff ff 	mov    %rax,-0x7f8(%rbp)
  419136:	b9 02 00 00 00       	mov    $0x2,%ecx
  41913b:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  419142:	be cc 01 00 00       	mov    $0x1cc,%esi
  419147:	e8 34 c2 00 00       	callq  425380 <p111_rt_jump>
  41914c:	41 5e                	pop    %r14
  41914e:	41 5d                	pop    %r13
  419150:	41 5c                	pop    %r12
  419152:	5b                   	pop    %rbx
  419153:	c9                   	leaveq 
  419154:	c3                   	retq   

Disassembly of section .fini:
