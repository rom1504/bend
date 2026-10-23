
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p126-observer32-coverage-record-aggregation-256-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000414080 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_>:
  414080:	f3 0f 1e fa          	endbr64 
  414084:	2e 2e 2e 2e 2e 55    	cs cs cs cs cs push %rbp
  41408a:	48 89 e5             	mov    %rsp,%rbp
  41408d:	48 81 ec 08 08 00 00 	sub    $0x808,%rsp
  414094:	53                   	push   %rbx
  414095:	41 54                	push   %r12
  414097:	41 55                	push   %r13
  414099:	41 56                	push   %r14
  41409b:	41 57                	push   %r15
  41409d:	48 8b 5f 28          	mov    0x28(%rdi),%rbx
  4140a1:	48 8b 77 30          	mov    0x30(%rdi),%rsi
  4140a5:	4c 8b 6f 38          	mov    0x38(%rdi),%r13
  4140a9:	48 89 f0             	mov    %rsi,%rax
  4140ac:	48 c1 e8 28          	shr    $0x28,%rax
  4140b0:	48 25 ff ff 00 00    	and    $0xffff,%rax
  4140b6:	48 83 f8 24          	cmp    $0x24,%rax
  4140ba:	0f 94 c1             	sete   %cl
  4140bd:	0f b6 c9             	movzbl %cl,%ecx
  4140c0:	83 f9 00             	cmp    $0x0,%ecx
  4140c3:	0f 85 c1 01 00 00    	jne    41428a <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_+0x20a>
  4140c9:	48 83 f8 25          	cmp    $0x25,%rax
  4140cd:	0f 94 c1             	sete   %cl
  4140d0:	0f b6 c9             	movzbl %cl,%ecx
  4140d3:	83 f9 00             	cmp    $0x0,%ecx
  4140d6:	0f 85 35 01 00 00    	jne    414211 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_+0x191>
  4140dc:	0f 1f 40 00          	nopl   0x0(%rax)
  4140e0:	48 83 f8 26          	cmp    $0x26,%rax
  4140e4:	74 5f                	je     414145 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_+0xc5>
  4140e6:	49 89 f4             	mov    %rsi,%r12
  4140e9:	48 89 de             	mov    %rbx,%rsi
  4140ec:	48 89 fb             	mov    %rdi,%rbx
  4140ef:	e8 dc b5 01 00       	callq  42f6d0 <p111_rt_sink>
  4140f4:	4c 89 e6             	mov    %r12,%rsi
  4140f7:	48 89 df             	mov    %rbx,%rdi
  4140fa:	4c 89 ad 00 f8 ff ff 	mov    %r13,-0x800(%rbp)
  414101:	48 8b 47 10          	mov    0x10(%rdi),%rax
  414105:	4c 89 28             	mov    %r13,(%rax)
  414108:	48 c7 40 08 07 01 00 	movq   $0x107,0x8(%rax)
  41410f:	00 
  414110:	48 83 c0 10          	add    $0x10,%rax
  414114:	48 89 47 10          	mov    %rax,0x10(%rdi)
  414118:	48 89 b5 00 f8 ff ff 	mov    %rsi,-0x800(%rbp)
  41411f:	48 8b 47 10          	mov    0x10(%rdi),%rax
  414123:	48 89 30             	mov    %rsi,(%rax)
  414126:	48 c7 40 08 08 01 00 	movq   $0x108,0x8(%rax)
  41412d:	00 
  41412e:	48 83 c0 10          	add    $0x10,%rax
  414132:	48 89 47 10          	mov    %rax,0x10(%rdi)
  414136:	be 04 00 00 00       	mov    $0x4,%esi
  41413b:	e8 20 bd 01 00       	callq  42fe60 <p111_rt_fail>
  414140:	e9 9a 01 00 00       	jmpq   4142df <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_+0x25f>
  414145:	49 89 dc             	mov    %rbx,%r12
  414148:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  41414f:	48 89 fb             	mov    %rdi,%rbx
  414152:	e8 89 0f 02 00       	callq  4350e0 <p125_rt_take3>
  414157:	4c 89 ee             	mov    %r13,%rsi
  41415a:	48 89 df             	mov    %rbx,%rdi
  41415d:	49 89 f7             	mov    %rsi,%r15
  414160:	48 8b b5 00 f8 ff ff 	mov    -0x800(%rbp),%rsi
  414167:	4c 8b b5 08 f8 ff ff 	mov    -0x7f8(%rbp),%r14
  41416e:	4c 8b ad 10 f8 ff ff 	mov    -0x7f0(%rbp),%r13
  414175:	48 89 fb             	mov    %rdi,%rbx
  414178:	e8 c3 b4 01 00       	callq  42f640 <p111_rt_keep>
  41417d:	4c 89 fe             	mov    %r15,%rsi
  414180:	48 89 df             	mov    %rbx,%rdi
  414183:	48 89 c3             	mov    %rax,%rbx
  414186:	48 89 9d 00 f8 ff ff 	mov    %rbx,-0x800(%rbp)
  41418d:	4c 89 b5 08 f8 ff ff 	mov    %r14,-0x7f8(%rbp)
  414194:	4c 89 ad 10 f8 ff ff 	mov    %r13,-0x7f0(%rbp)
  41419b:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  4141a2:	49 89 f5             	mov    %rsi,%r13
  4141a5:	be 26 00 00 00       	mov    $0x26,%esi
  4141aa:	49 89 fe             	mov    %rdi,%r14
  4141ad:	e8 5e 0e 02 00       	callq  435010 <p125_rt_ctor3>
  4141b2:	4c 89 f7             	mov    %r14,%rdi
  4141b5:	48 89 c1             	mov    %rax,%rcx
  4141b8:	48 89 8d 00 f8 ff ff 	mov    %rcx,-0x800(%rbp)
  4141bf:	4c 89 a5 08 f8 ff ff 	mov    %r12,-0x7f8(%rbp)
  4141c6:	48 8b 47 10          	mov    0x10(%rdi),%rax
  4141ca:	48 89 08             	mov    %rcx,(%rax)
  4141cd:	48 8b 8d 08 f8 ff ff 	mov    -0x7f8(%rbp),%rcx
  4141d4:	48 89 48 08          	mov    %rcx,0x8(%rax)
  4141d8:	48 c7 40 10 06 01 00 	movq   $0x106,0x10(%rax)
  4141df:	00 
  4141e0:	48 83 c0 18          	add    $0x18,%rax
  4141e4:	48 89 47 10          	mov    %rax,0x10(%rdi)
  4141e8:	4c 89 ad 00 f8 ff ff 	mov    %r13,-0x800(%rbp)
  4141ef:	48 89 9d 08 f8 ff ff 	mov    %rbx,-0x7f8(%rbp)
  4141f6:	b9 02 00 00 00       	mov    $0x2,%ecx
  4141fb:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  414202:	be 85 02 00 00       	mov    $0x285,%esi
  414207:	e8 84 ba 01 00       	callq  42fc90 <p111_rt_jump>
  41420c:	e9 ce 00 00 00       	jmpq   4142df <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_+0x25f>
  414211:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  414218:	49 89 fc             	mov    %rdi,%r12
  41421b:	e8 60 0c 02 00       	callq  434e80 <p125_rt_take2>
  414220:	4c 89 ee             	mov    %r13,%rsi
  414223:	4c 89 e7             	mov    %r12,%rdi
  414226:	48 8b 85 00 f8 ff ff 	mov    -0x800(%rbp),%rax
  41422d:	48 8b 8d 08 f8 ff ff 	mov    -0x7f8(%rbp),%rcx
  414234:	48 89 9d 00 f8 ff ff 	mov    %rbx,-0x800(%rbp)
  41423b:	48 89 8d 08 f8 ff ff 	mov    %rcx,-0x7f8(%rbp)
  414242:	48 8b 4f 10          	mov    0x10(%rdi),%rcx
  414246:	48 89 19             	mov    %rbx,(%rcx)
  414249:	48 8b 95 08 f8 ff ff 	mov    -0x7f8(%rbp),%rdx
  414250:	48 89 51 08          	mov    %rdx,0x8(%rcx)
  414254:	48 c7 41 10 05 01 00 	movq   $0x105,0x10(%rcx)
  41425b:	00 
  41425c:	48 83 c1 18          	add    $0x18,%rcx
  414260:	48 89 4f 10          	mov    %rcx,0x10(%rdi)
  414264:	48 89 b5 00 f8 ff ff 	mov    %rsi,-0x800(%rbp)
  41426b:	48 89 85 08 f8 ff ff 	mov    %rax,-0x7f8(%rbp)
  414272:	b9 02 00 00 00       	mov    $0x2,%ecx
  414277:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  41427e:	be 87 01 00 00       	mov    $0x187,%esi
  414283:	e8 08 ba 01 00       	callq  42fc90 <p111_rt_jump>
  414288:	eb 55                	jmp    4142df <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_+0x25f>
  41428a:	4c 89 ee             	mov    %r13,%rsi
  41428d:	49 89 fc             	mov    %rdi,%r12
  414290:	e8 3b b4 01 00       	callq  42f6d0 <p111_rt_sink>
  414295:	4c 89 e7             	mov    %r12,%rdi
  414298:	48 b8 00 00 00 00 00 	movabs $0x100240000000000,%rax
  41429f:	24 00 01 
  4142a2:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  4142a9:	48 89 9d 08 f8 ff ff 	mov    %rbx,-0x7f8(%rbp)
  4142b0:	48 8d 95 00 f8 ff ff 	lea    -0x800(%rbp),%rdx
  4142b7:	be 08 00 00 00       	mov    $0x8,%esi
  4142bc:	48 89 fb             	mov    %rdi,%rbx
  4142bf:	e8 cc 0a 02 00       	callq  434d90 <p125_rt_ctor2>
  4142c4:	48 89 df             	mov    %rbx,%rdi
  4142c7:	48 89 85 00 f8 ff ff 	mov    %rax,-0x800(%rbp)
  4142ce:	ba 01 00 00 00       	mov    $0x1,%edx
  4142d3:	48 8d b5 00 f8 ff ff 	lea    -0x800(%rbp),%rsi
  4142da:	e8 11 ba 01 00       	callq  42fcf0 <p111_rt_return>
  4142df:	41 5f                	pop    %r15
  4142e1:	41 5e                	pop    %r14
  4142e3:	41 5d                	pop    %r13
  4142e5:	41 5c                	pop    %r12
  4142e7:	5b                   	pop    %rbx
  4142e8:	c9                   	leaveq 
  4142e9:	c3                   	retq   

Disassembly of section .fini:
