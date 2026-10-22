0000000000406110 <p126_typed_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_>:
  406110:	f3 0f 1e fa          	endbr64 
  406114:	55                   	push   %rbp
  406115:	48 89 e5             	mov    %rsp,%rbp
  406118:	48 83 ec 18          	sub    $0x18,%rsp
  40611c:	53                   	push   %rbx
  40611d:	f3 44 0f 10 45 18    	movss  0x18(%rbp),%xmm8
  406123:	f3 44 0f 10 4d 10    	movss  0x10(%rbp),%xmm9
  406129:	f3 44 0f 10 fd       	movss  %xmm5,%xmm15
  40612e:	f3 0f 10 e9          	movss  %xmm1,%xmm5
  406132:	f3 41 0f 10 cf       	movss  %xmm15,%xmm1
  406137:	f3 44 0f 10 ff       	movss  %xmm7,%xmm15
  40613c:	f3 0f 10 fd          	movss  %xmm5,%xmm7
  406140:	f3 41 0f 10 ef       	movss  %xmm15,%xmm5
  406145:	f3 44 0f 10 fb       	movss  %xmm3,%xmm15
  40614a:	f3 0f 10 df          	movss  %xmm7,%xmm3
  40614e:	f3 41 0f 10 ff       	movss  %xmm15,%xmm7
  406153:	f3 44 0f 10 fa       	movss  %xmm2,%xmm15
  406158:	f3 0f 10 d3          	movss  %xmm3,%xmm2
  40615c:	f3 41 0f 10 df       	movss  %xmm15,%xmm3
  406161:	f3 44 0f 10 fc       	movss  %xmm4,%xmm15
  406166:	f3 0f 10 e0          	movss  %xmm0,%xmm4
  40616a:	f3 41 0f 10 c7       	movss  %xmm15,%xmm0
  40616f:	66 48 0f 7e f8       	movq   %xmm7,%rax
  406174:	89 c0                	mov    %eax,%eax
  406176:	66 48 0f 7e f1       	movq   %xmm6,%rcx
  40617b:	89 c9                	mov    %ecx,%ecx
  40617d:	66 48 0f 7e ea       	movq   %xmm5,%rdx
  406182:	41 89 d2             	mov    %edx,%r10d
  406185:	66 4c 0f 7e ca       	movq   %xmm9,%rdx
  40618a:	41 89 d1             	mov    %edx,%r9d
  40618d:	66 4c 0f 7e c2       	movq   %xmm8,%rdx
  406192:	41 89 d0             	mov    %edx,%r8d
  406195:	f3 0f 5c c4          	subss  %xmm4,%xmm0
  406199:	66 48 0f 7e c2       	movq   %xmm0,%rdx
  40619e:	89 d6                	mov    %edx,%esi
  4061a0:	0f 57 15 69 ce 02 00 	xorps  0x2ce69(%rip),%xmm2        # 433010 <_IO_stdin_used+0x10>
  4061a7:	f3 0f 58 d1          	addss  %xmm1,%xmm2
  4061ab:	66 48 0f 7e d2       	movq   %xmm2,%rdx
  4061b0:	89 d2                	mov    %edx,%edx
  4061b2:	66 48 0f 6e c9       	movq   %rcx,%xmm1
  4061b7:	f3 0f 5c cb          	subss  %xmm3,%xmm1
  4061bb:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  4061c0:	89 c9                	mov    %ecx,%ecx
  4061c2:	66 49 0f 6e da       	movq   %r10,%xmm3
  4061c7:	f3 0f 59 c3          	mulss  %xmm3,%xmm0
  4061cb:	66 49 0f 6e d9       	movq   %r9,%xmm3
  4061d0:	f3 0f 59 d3          	mulss  %xmm3,%xmm2
  4061d4:	f3 0f 58 c2          	addss  %xmm2,%xmm0
  4061d8:	66 49 0f 6e d0       	movq   %r8,%xmm2
  4061dd:	f3 0f 59 ca          	mulss  %xmm2,%xmm1
  4061e1:	f3 0f 58 c8          	addss  %xmm0,%xmm1
  4061e5:	f3 0f 10 c1          	movss  %xmm1,%xmm0
  4061e9:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  4061ed:	66 48 0f 6e d6       	movq   %rsi,%xmm2
  4061f2:	f3 0f 59 d2          	mulss  %xmm2,%xmm2
  4061f6:	66 48 0f 6e da       	movq   %rdx,%xmm3
  4061fb:	f3 0f 59 db          	mulss  %xmm3,%xmm3
  4061ff:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  406203:	66 48 0f 6e d9       	movq   %rcx,%xmm3
  406208:	f3 0f 59 db          	mulss  %xmm3,%xmm3
  40620c:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  406210:	66 48 0f 6e d8       	movq   %rax,%xmm3
  406215:	f3 0f 59 db          	mulss  %xmm3,%xmm3
  406219:	f3 0f 5c d3          	subss  %xmm3,%xmm2
  40621d:	f3 0f 5c c2          	subss  %xmm2,%xmm0
  406221:	f3 0f 10 15 fb cd 02 00 	movss  0x2cdfb(%rip),%xmm2        # 433024 <_IO_stdin_used+0x24>
  406229:	0f 2e d0             	ucomiss %xmm0,%xmm2
  40622c:	0f 97 c0             	seta   %al
  40622f:	0f b6 c0             	movzbl %al,%eax
  406232:	89 c1                	mov    %eax,%ecx
  406234:	48 83 f9 01          	cmp    $0x1,%rcx
  406238:	0f 94 c0             	sete   %al
  40623b:	0f b6 c0             	movzbl %al,%eax
  40623e:	48 c1 e9 28          	shr    $0x28,%rcx
  406242:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  406249:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  406250:	0f 94 c1             	sete   %cl
  406253:	0f b6 c9             	movzbl %cl,%ecx
  406256:	09 c8                	or     %ecx,%eax
  406258:	0f 85 bb 00 00 00    	jne    406319 <p126_typed_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x209>
  40625e:	83 f0 01             	xor    $0x1,%eax
  406261:	75 17                	jne    40627a <p126_typed_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x16a>
  406263:	be 04 00 00 00       	mov    $0x4,%esi
  406268:	48 89 fb             	mov    %rdi,%rbx
  40626b:	e8 90 6b 02 00       	callq  42ce00 <p111_rt_fail>
  406270:	b8 00 00 00 00       	mov    $0x0,%eax
  406275:	e9 a4 00 00 00       	jmpq   40631e <p126_typed_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x20e>
  40627a:	48 89 fb             	mov    %rdi,%rbx
  40627d:	66 48 0f 7e c8       	movq   %xmm1,%rax
  406282:	89 c0                	mov    %eax,%eax
  406284:	66 48 0f 6e c8       	movq   %rax,%xmm1
  406289:	0f 57 0d 80 cd 02 00 	xorps  0x2cd80(%rip),%xmm1        # 433010 <_IO_stdin_used+0x10>
  406290:	f3 0f 58 0d 8c cd 02 00 	addss  0x2cd8c(%rip),%xmm1        # 433024 <_IO_stdin_used+0x24>
  406298:	f3 0f 11 4d f0       	movss  %xmm1,-0x10(%rbp)
  40629d:	f3 0f 5a c0          	cvtss2sd %xmm0,%xmm0
  4062a1:	e8 1a c2 ff ff       	callq  4024c0 <sqrt@plt>
  4062a6:	48 89 df             	mov    %rbx,%rdi
  4062a9:	f2 0f 10 c8          	movsd  %xmm0,%xmm1
  4062ad:	f3 0f 10 45 f0       	movss  -0x10(%rbp),%xmm0
  4062b2:	f2 0f 5a c9          	cvtsd2ss %xmm1,%xmm1
  4062b6:	f3 0f 5c c1          	subss  %xmm1,%xmm0
  4062ba:	f3 0f 10 0d 66 cd 02 00 	movss  0x2cd66(%rip),%xmm1        # 433028 <_IO_stdin_used+0x28>
  4062c2:	0f 2e c8             	ucomiss %xmm0,%xmm1
  4062c5:	0f 97 c0             	seta   %al
  4062c8:	0f b6 c0             	movzbl %al,%eax
  4062cb:	89 c1                	mov    %eax,%ecx
  4062cd:	48 83 f9 01          	cmp    $0x1,%rcx
  4062d1:	0f 94 c0             	sete   %al
  4062d4:	0f b6 c0             	movzbl %al,%eax
  4062d7:	48 c1 e9 28          	shr    $0x28,%rcx
  4062db:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  4062e2:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  4062e9:	0f 94 c1             	sete   %cl
  4062ec:	0f b6 c9             	movzbl %cl,%ecx
  4062ef:	09 c8                	or     %ecx,%eax
  4062f1:	75 1f                	jne    406312 <p126_typed_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x202>
  4062f3:	83 f0 01             	xor    $0x1,%eax
  4062f6:	75 11                	jne    406309 <p126_typed_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x1f9>
  4062f8:	be 04 00 00 00       	mov    $0x4,%esi
  4062fd:	e8 fe 6a 02 00       	callq  42ce00 <p111_rt_fail>
  406302:	b8 00 00 00 00       	mov    $0x0,%eax
  406307:	eb 15                	jmp    40631e <p126_typed_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x20e>
  406309:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40630e:	89 c0                	mov    %eax,%eax
  406310:	eb 0c                	jmp    40631e <p126_typed_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x20e>
  406312:	b8 28 6b 6e 4e       	mov    $0x4e6e6b28,%eax
  406317:	eb 05                	jmp    40631e <p126_typed_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x20e>
  406319:	b8 28 6b 6e 4e       	mov    $0x4e6e6b28,%eax
  40631e:	5b                   	pop    %rbx
  40631f:	c9                   	leaveq 
  406320:	c3                   	retq   
  406321:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 nopw %cs:0x0(%rax,%rax,1)
  40632c:	0f 1f 40 00          	nopl   0x0(%rax)

