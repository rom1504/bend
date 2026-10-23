
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-candidate-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000419030 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_95_108_101_103_97_99_121_>:
  419030:	f3 0f 1e fa          	endbr64 
  419034:	55                   	push   %rbp
  419035:	48 89 e5             	mov    %rsp,%rbp
  419038:	48 81 ec 00 10 00 00 	sub    $0x1000,%rsp
  41903f:	53                   	push   %rbx
  419040:	41 54                	push   %r12
  419042:	41 55                	push   %r13
  419044:	41 56                	push   %r14
  419046:	48 8b 77 28          	mov    0x28(%rdi),%rsi
  41904a:	4c 8b 6f 30          	mov    0x30(%rdi),%r13
  41904e:	4c 8b 67 38          	mov    0x38(%rdi),%r12
  419052:	48 8b 5f 40          	mov    0x40(%rdi),%rbx
  419056:	49 89 fe             	mov    %rdi,%r14
  419059:	e8 f2 bc 00 00       	callq  424d50 <p111_rt_keep>
  41905e:	4c 89 f7             	mov    %r14,%rdi
  419061:	48 89 c6             	mov    %rax,%rsi
  419064:	48 89 b5 00 f0 ff ff 	mov    %rsi,-0x1000(%rbp)
  41906b:	4c 89 ad 08 f0 ff ff 	mov    %r13,-0xff8(%rbp)
  419072:	4c 89 a5 10 f0 ff ff 	mov    %r12,-0xff0(%rbp)
  419079:	48 89 9d 18 f0 ff ff 	mov    %rbx,-0xfe8(%rbp)
  419080:	48 8b 47 10          	mov    0x10(%rdi),%rax
  419084:	48 89 30             	mov    %rsi,(%rax)
  419087:	4c 89 68 08          	mov    %r13,0x8(%rax)
  41908b:	4c 89 60 10          	mov    %r12,0x10(%rax)
  41908f:	48 89 58 18          	mov    %rbx,0x18(%rax)
  419093:	48 c7 40 20 bf 01 00 	movq   $0x1bf,0x20(%rax)
  41909a:	00 
  41909b:	48 83 c0 28          	add    $0x28,%rax
  41909f:	48 89 47 10          	mov    %rax,0x10(%rdi)
  4190a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  4190a8:	49 89 dc             	mov    %rbx,%r12
  4190ab:	49 21 c4             	and    %rax,%r12
  4190ae:	49 83 fc 00          	cmp    $0x0,%r12
  4190b2:	49 89 f5             	mov    %rsi,%r13
  4190b5:	40 0f 94 c6          	sete   %sil
  4190b9:	40 0f b6 f6          	movzbl %sil,%esi
  4190bd:	48 89 fb             	mov    %rdi,%rbx
  4190c0:	e8 0b 49 ff ff       	callq  40d9d0 <p112w_FID_36_100_105_114_101_99_116_46_66_111_111_108_46_110_111_116_>
  4190c5:	4c 89 ee             	mov    %r13,%rsi
  4190c8:	48 89 df             	mov    %rbx,%rdi
  4190cb:	48 89 c3             	mov    %rax,%rbx
  4190ce:	49 89 fd             	mov    %rdi,%r13
  4190d1:	e8 7a bc 00 00       	callq  424d50 <p111_rt_keep>
  4190d6:	4c 89 ef             	mov    %r13,%rdi
  4190d9:	48 89 c6             	mov    %rax,%rsi
  4190dc:	49 89 f6             	mov    %rsi,%r14
  4190df:	49 89 fd             	mov    %rdi,%r13
  4190e2:	e8 b9 47 ff ff       	callq  40d8a0 <p112w_FID_36_100_105_114_101_99_116_46_100_120_>
  4190e7:	4c 89 f6             	mov    %r14,%rsi
  4190ea:	4c 89 ef             	mov    %r13,%rdi
  4190ed:	49 89 c5             	mov    %rax,%r13
  4190f0:	49 89 fe             	mov    %rdi,%r14
  4190f3:	e8 a8 47 ff ff       	callq  40d8a0 <p112w_FID_36_100_105_114_101_99_116_46_100_120_>
  4190f8:	4c 89 f7             	mov    %r14,%rdi
  4190fb:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  419100:	4c 21 e9             	and    %r13,%rcx
  419103:	48 83 f9 00          	cmp    $0x0,%rcx
  419107:	0f 94 c1             	sete   %cl
  41910a:	0f b6 c9             	movzbl %cl,%ecx
  41910d:	48 89 8d 00 f8 ff ff 	mov    %rcx,-0x800(%rbp)
  419114:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  419119:	48 21 c8             	and    %rcx,%rax
  41911c:	49 39 c4             	cmp    %rax,%r12
  41911f:	0f 92 c0             	setb   %al
  419122:	0f b6 c0             	movzbl %al,%eax
  419125:	48 89 85 08 f8 ff ff 	mov    %rax,-0x7f8(%rbp)
  41912c:	b9 02 00 00 00       	mov    $0x2,%ecx
  419131:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  419138:	be 44 00 00 00       	mov    $0x44,%esi
  41913d:	49 89 fc             	mov    %rdi,%r12
  419140:	e8 4b c4 00 00       	callq  425590 <p111_rt_op>
  419145:	4c 89 e7             	mov    %r12,%rdi
  419148:	48 89 9d 00 f8 ff ff 	mov    %rbx,-0x800(%rbp)
  41914f:	48 89 85 08 f8 ff ff 	mov    %rax,-0x7f8(%rbp)
  419156:	b9 02 00 00 00       	mov    $0x2,%ecx
  41915b:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  419162:	be b6 01 00 00       	mov    $0x1b6,%esi
  419167:	e8 34 c2 00 00       	callq  4253a0 <p111_rt_jump>
  41916c:	41 5e                	pop    %r14
  41916e:	41 5d                	pop    %r13
  419170:	41 5c                	pop    %r12
  419172:	5b                   	pop    %rbx
  419173:	c9                   	leaveq 
  419174:	c3                   	retq   

Disassembly of section .fini:
