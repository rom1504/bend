0000000000406110 <p126_typed_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_>:
  406110:	f3 0f 1e fa          	endbr64 
  406114:	55                   	push   %rbp
  406115:	48 89 e5             	mov    %rsp,%rbp
  406118:	48 83 ec 18          	sub    $0x18,%rsp
  40611c:	53                   	push   %rbx
  40611d:	f3 44 0f 10 45 18    	movss  0x18(%rbp),%xmm8
  406123:	f3 44 0f 10 4d 10    	movss  0x10(%rbp),%xmm9
  406129:	f3 44 0f 10 ff       	movss  %xmm7,%xmm15
  40612e:	f3 0f 10 f8          	movss  %xmm0,%xmm7
  406132:	f3 41 0f 10 c7       	movss  %xmm15,%xmm0
  406137:	f3 44 0f 10 fb       	movss  %xmm3,%xmm15
  40613c:	f3 0f 10 df          	movss  %xmm7,%xmm3
  406140:	f3 41 0f 10 ff       	movss  %xmm15,%xmm7
  406145:	f3 44 0f 10 fa       	movss  %xmm2,%xmm15
  40614a:	f3 0f 10 d3          	movss  %xmm3,%xmm2
  40614e:	f3 41 0f 10 df       	movss  %xmm15,%xmm3
  406153:	f3 44 0f 10 fc       	movss  %xmm4,%xmm15
  406158:	f3 0f 10 e2          	movss  %xmm2,%xmm4
  40615c:	f3 41 0f 10 d7       	movss  %xmm15,%xmm2
  406161:	f3 44 0f 10 fd       	movss  %xmm5,%xmm15
  406166:	f3 0f 10 ec          	movss  %xmm4,%xmm5
  40616a:	f3 41 0f 10 e7       	movss  %xmm15,%xmm4
  40616f:	f3 44 0f 10 f9       	movss  %xmm1,%xmm15
  406174:	f3 0f 10 cd          	movss  %xmm5,%xmm1
  406178:	f3 41 0f 10 ef       	movss  %xmm15,%xmm5
  40617d:	f3 44 0f 10 fe       	movss  %xmm6,%xmm15
  406182:	f3 0f 10 f1          	movss  %xmm1,%xmm6
  406186:	f3 41 0f 10 cf       	movss  %xmm15,%xmm1
  40618b:	66 48 0f 7e f8       	movq   %xmm7,%rax
  406190:	89 c0                	mov    %eax,%eax
  406192:	f3 0f 5c d6          	subss  %xmm6,%xmm2
  406196:	f3 0f 5c e5          	subss  %xmm5,%xmm4
  40619a:	0f 57 1d 6f ce 02 00 	xorps  0x2ce6f(%rip),%xmm3        # 433010 <_IO_stdin_used+0x10>
  4061a1:	f3 0f 58 d9          	addss  %xmm1,%xmm3
  4061a5:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  4061a9:	f3 41 0f 10 c9       	movss  %xmm9,%xmm1
  4061ae:	f3 0f 59 cc          	mulss  %xmm4,%xmm1
  4061b2:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  4061b6:	f3 41 0f 10 c8       	movss  %xmm8,%xmm1
  4061bb:	f3 0f 59 cb          	mulss  %xmm3,%xmm1
  4061bf:	f3 0f 58 c8          	addss  %xmm0,%xmm1
  4061c3:	f3 0f 10 c1          	movss  %xmm1,%xmm0
  4061c7:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  4061cb:	f3 0f 59 d2          	mulss  %xmm2,%xmm2
  4061cf:	f3 0f 59 e4          	mulss  %xmm4,%xmm4
  4061d3:	f3 0f 58 d4          	addss  %xmm4,%xmm2
  4061d7:	f3 0f 59 db          	mulss  %xmm3,%xmm3
  4061db:	f3 0f 58 d3          	addss  %xmm3,%xmm2
  4061df:	66 48 0f 6e d8       	movq   %rax,%xmm3
  4061e4:	f3 0f 59 db          	mulss  %xmm3,%xmm3
  4061e8:	f3 0f 5c d3          	subss  %xmm3,%xmm2
  4061ec:	f3 0f 5c c2          	subss  %xmm2,%xmm0
  4061f0:	f3 0f 10 15 2c ce 02 00 	movss  0x2ce2c(%rip),%xmm2        # 433024 <_IO_stdin_used+0x24>
  4061f8:	0f 2e d0             	ucomiss %xmm0,%xmm2
  4061fb:	0f 97 c0             	seta   %al
  4061fe:	0f b6 c0             	movzbl %al,%eax
  406201:	89 c1                	mov    %eax,%ecx
  406203:	48 83 f9 01          	cmp    $0x1,%rcx
  406207:	0f 94 c0             	sete   %al
  40620a:	0f b6 c0             	movzbl %al,%eax
  40620d:	48 c1 e9 28          	shr    $0x28,%rcx
  406211:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  406218:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  40621f:	0f 94 c1             	sete   %cl
  406222:	0f b6 c9             	movzbl %cl,%ecx
  406225:	09 c8                	or     %ecx,%eax
  406227:	0f 85 af 00 00 00    	jne    4062dc <p126_typed_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x1cc>
  40622d:	83 f0 01             	xor    $0x1,%eax
  406230:	75 17                	jne    406249 <p126_typed_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x139>
  406232:	be 04 00 00 00       	mov    $0x4,%esi
  406237:	48 89 fb             	mov    %rdi,%rbx
  40623a:	e8 e1 67 02 00       	callq  42ca20 <p111_rt_fail>
  40623f:	b8 00 00 00 00       	mov    $0x0,%eax
  406244:	e9 98 00 00 00       	jmpq   4062e1 <p126_typed_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x1d1>
  406249:	48 89 fb             	mov    %rdi,%rbx
  40624c:	0f 57 0d bd cd 02 00 	xorps  0x2cdbd(%rip),%xmm1        # 433010 <_IO_stdin_used+0x10>
  406253:	f3 0f 58 0d c9 cd 02 00 	addss  0x2cdc9(%rip),%xmm1        # 433024 <_IO_stdin_used+0x24>
  40625b:	f3 0f 11 4d f0       	movss  %xmm1,-0x10(%rbp)
  406260:	f3 0f 5a c0          	cvtss2sd %xmm0,%xmm0
  406264:	e8 57 c2 ff ff       	callq  4024c0 <sqrt@plt>
  406269:	48 89 df             	mov    %rbx,%rdi
  40626c:	f2 0f 10 c8          	movsd  %xmm0,%xmm1
  406270:	f3 0f 10 45 f0       	movss  -0x10(%rbp),%xmm0
  406275:	f2 0f 5a c9          	cvtsd2ss %xmm1,%xmm1
  406279:	f3 0f 5c c1          	subss  %xmm1,%xmm0
  40627d:	f3 0f 10 0d a3 cd 02 00 	movss  0x2cda3(%rip),%xmm1        # 433028 <_IO_stdin_used+0x28>
  406285:	0f 2e c8             	ucomiss %xmm0,%xmm1
  406288:	0f 97 c0             	seta   %al
  40628b:	0f b6 c0             	movzbl %al,%eax
  40628e:	89 c1                	mov    %eax,%ecx
  406290:	48 83 f9 01          	cmp    $0x1,%rcx
  406294:	0f 94 c0             	sete   %al
  406297:	0f b6 c0             	movzbl %al,%eax
  40629a:	48 c1 e9 28          	shr    $0x28,%rcx
  40629e:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  4062a5:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  4062ac:	0f 94 c1             	sete   %cl
  4062af:	0f b6 c9             	movzbl %cl,%ecx
  4062b2:	09 c8                	or     %ecx,%eax
  4062b4:	75 1f                	jne    4062d5 <p126_typed_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x1c5>
  4062b6:	83 f0 01             	xor    $0x1,%eax
  4062b9:	75 11                	jne    4062cc <p126_typed_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x1bc>
  4062bb:	be 04 00 00 00       	mov    $0x4,%esi
  4062c0:	e8 5b 67 02 00       	callq  42ca20 <p111_rt_fail>
  4062c5:	b8 00 00 00 00       	mov    $0x0,%eax
  4062ca:	eb 15                	jmp    4062e1 <p126_typed_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x1d1>
  4062cc:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4062d1:	89 c0                	mov    %eax,%eax
  4062d3:	eb 0c                	jmp    4062e1 <p126_typed_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x1d1>
  4062d5:	b8 28 6b 6e 4e       	mov    $0x4e6e6b28,%eax
  4062da:	eb 05                	jmp    4062e1 <p126_typed_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_+0x1d1>
  4062dc:	b8 28 6b 6e 4e       	mov    $0x4e6e6b28,%eax
  4062e1:	5b                   	pop    %rbx
  4062e2:	c9                   	leaveq 
  4062e3:	c3                   	retq   
  4062e4:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 nopw %cs:0x0(%rax,%rax,1)
  4062ef:	90                   	nop

