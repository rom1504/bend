
selfhost/build/phase93/broad01/coverage-record-aggregation-256/upstream.program:     file format elf64-x86-64


Disassembly of section .text:

00000000000172e0 <WL_FID_U32_SHOW_GO>:
   172e0:	55                   	push   %rbp
   172e1:	48 83 ec 10          	sub    $0x10,%rsp
   172e5:	44 89 7c 24 0c       	mov    %r15d,0xc(%rsp)
   172ea:	48 85 f6             	test   %rsi,%rsi
   172ed:	0f 84 a9 00 00 00    	je     1739c <WL_FID_U32_SHOW_GO+0xbc>
   172f3:	48 89 d3             	mov    %rdx,%rbx
   172f6:	49 89 f0             	mov    %rsi,%r8
   172f9:	41 bf cd cc cc cc    	mov    $0xcccccccd,%r15d
   172ff:	48 bd 00 00 00 00 00 	movabs $0x200020000000000,%rbp
   17306:	02 00 02 
   17309:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
   17310:	85 db                	test   %ebx,%ebx
   17312:	0f 84 ae 00 00 00    	je     173c6 <WL_FID_U32_SHOW_GO+0xe6>
   17318:	4d 8b 4d 08          	mov    0x8(%r13),%r9
   1731c:	4d 85 c9             	test   %r9,%r9
   1731f:	74 4e                	je     1736f <WL_FID_U32_SHOW_GO+0x8f>
   17321:	4b 8b 04 cc          	mov    (%r12,%r9,8),%rax
   17325:	49 89 45 08          	mov    %rax,0x8(%r13)
   17329:	49 83 85 08 01 00 00 	addq   $0xfffffffffffffffe,0x108(%r13)
   17330:	fe 
   17331:	41 89 da             	mov    %ebx,%r10d
   17334:	4d 0f af d7          	imul   %r15,%r10
   17338:	49 c1 ea 23          	shr    $0x23,%r10
   1733c:	43 8d 04 12          	lea    (%r10,%r10,1),%eax
   17340:	8d 04 80             	lea    (%rax,%rax,4),%eax
   17343:	f7 d8                	neg    %eax
   17345:	01 d8                	add    %ebx,%eax
   17347:	83 c0 30             	add    $0x30,%eax
   1734a:	4b 89 04 cc          	mov    %rax,(%r12,%r9,8)
   1734e:	48 89 c8             	mov    %rcx,%rax
   17351:	48 c1 e8 38          	shr    $0x38,%rax
   17355:	83 f8 02             	cmp    $0x2,%eax
   17358:	74 2a                	je     17384 <WL_FID_U32_SHOW_GO+0xa4>
   1735a:	4b 89 4c cc 08       	mov    %rcx,0x8(%r12,%r9,8)
   1735f:	49 09 e9             	or     %rbp,%r9
   17362:	44 89 d3             	mov    %r10d,%ebx
   17365:	4c 89 c9             	mov    %r9,%rcx
   17368:	49 ff c8             	dec    %r8
   1736b:	75 a3                	jne    17310 <WL_FID_U32_SHOW_GO+0x30>
   1736d:	eb 30                	jmp    1739f <WL_FID_U32_SHOW_GO+0xbf>
   1736f:	4c 89 e7             	mov    %r12,%rdi
   17372:	4c 89 ee             	mov    %r13,%rsi
   17375:	ba 01 00 00 00       	mov    $0x1,%edx
   1737a:	e8 a7 5f 00 00       	callq  1d326 <heap_alloc_miss>
   1737f:	49 89 c1             	mov    %rax,%r9
   17382:	eb ad                	jmp    17331 <WL_FID_U32_SHOW_GO+0x51>
   17384:	4c 89 e7             	mov    %r12,%rdi
   17387:	4c 89 ee             	mov    %r13,%rsi
   1738a:	48 89 ca             	mov    %rcx,%rdx
   1738d:	b9 01 00 00 00       	mov    $0x1,%ecx
   17392:	e8 95 62 00 00       	callq  1d62c <rfc_wrap>
   17397:	48 89 c1             	mov    %rax,%rcx
   1739a:	eb be                	jmp    1735a <WL_FID_U32_SHOW_GO+0x7a>
   1739c:	49 89 c9             	mov    %rcx,%r9
   1739f:	41 8b 46 f8          	mov    -0x8(%r14),%eax
   173a3:	49 83 c6 f8          	add    $0xfffffffffffffff8,%r14
   173a7:	48 8d 0d 12 83 00 00 	lea    0x8312(%rip),%rcx        # 1f6c0 <wl_tab>
   173ae:	48 8b 04 c1          	mov    (%rcx,%rax,8),%rax
   173b2:	44 8b 7c 24 0c       	mov    0xc(%rsp),%r15d
   173b7:	bf 01 00 00 00       	mov    $0x1,%edi
   173bc:	4c 89 ce             	mov    %r9,%rsi
   173bf:	48 83 c4 10          	add    $0x10,%rsp
   173c3:	5d                   	pop    %rbp
   173c4:	ff e0                	jmpq   *%rax
   173c6:	41 8b 46 f8          	mov    -0x8(%r14),%eax
   173ca:	49 83 c6 f8          	add    $0xfffffffffffffff8,%r14
   173ce:	48 8d 15 eb 82 00 00 	lea    0x82eb(%rip),%rdx        # 1f6c0 <wl_tab>
   173d5:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
   173d9:	44 8b 7c 24 0c       	mov    0xc(%rsp),%r15d
   173de:	bf 01 00 00 00       	mov    $0x1,%edi
   173e3:	48 89 ce             	mov    %rcx,%rsi
   173e6:	48 83 c4 10          	add    $0x10,%rsp
   173ea:	5d                   	pop    %rbp
   173eb:	ff e0                	jmpq   *%rax

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
