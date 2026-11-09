
selfhost/build/phase184/c-products02/drivers/u32.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <main>:
   0:	55                   	push   %rbp
   1:	41 57                	push   %r15
   3:	41 56                	push   %r14
   5:	41 55                	push   %r13
   7:	41 54                	push   %r12
   9:	53                   	push   %rbx
   a:	48 83 ec 58          	sub    $0x58,%rsp
   e:	49 89 f6             	mov    %rsi,%r14
  11:	83 ff 06             	cmp    $0x6,%edi
  14:	0f 84 06 01 00 00    	je     120 <main+0x120>
  1a:	83 ff 04             	cmp    $0x4,%edi
  1d:	0f 85 a5 06 00 00    	jne    6c8 <main+0x6c8>
  23:	49 8b 7e 08          	mov    0x8(%r14),%rdi
  27:	48 8d 35 00 00 00 00 	lea    0x0(%rip),%rsi        # 2e <main+0x2e>
			2a: R_X86_64_PC32	.L.str-0x4
  2e:	e8 00 00 00 00       	callq  33 <main+0x33>
			2f: R_X86_64_PLT32	strcmp-0x4
  33:	85 c0                	test   %eax,%eax
  35:	0f 85 8d 06 00 00    	jne    6c8 <main+0x6c8>
  3b:	49 8b 46 10          	mov    0x10(%r14),%rax
  3f:	0f b6 10             	movzbl (%rax),%edx
  42:	84 d2                	test   %dl,%dl
  44:	0f 84 72 06 00 00    	je     6bc <main+0x6bc>
  4a:	48 ff c0             	inc    %rax
  4d:	31 ff                	xor    %edi,%edi
  4f:	b9 cd cc cc cc       	mov    $0xcccccccd,%ecx
  54:	66 66 66 2e 0f 1f 84 	data16 data16 nopw %cs:0x0(%rax,%rax,1)
  5b:	00 00 00 00 00 
  60:	8d 72 c6             	lea    -0x3a(%rdx),%esi
  63:	40 80 fe f5          	cmp    $0xf5,%sil
  67:	0f 86 e3 05 00 00    	jbe    650 <main+0x650>
  6d:	0f b6 d2             	movzbl %dl,%edx
  70:	be 2f 00 00 00       	mov    $0x2f,%esi
  75:	29 d6                	sub    %edx,%esi
  77:	48 0f af f1          	imul   %rcx,%rsi
  7b:	48 c1 ee 23          	shr    $0x23,%rsi
  7f:	39 f7                	cmp    %esi,%edi
  81:	0f 87 d5 05 00 00    	ja     65c <main+0x65c>
  87:	8d 34 bf             	lea    (%rdi,%rdi,4),%esi
  8a:	8d 3c 72             	lea    (%rdx,%rsi,2),%edi
  8d:	83 c7 d0             	add    $0xffffffd0,%edi
  90:	0f b6 10             	movzbl (%rax),%edx
  93:	48 ff c0             	inc    %rax
  96:	84 d2                	test   %dl,%dl
  98:	75 c6                	jne    60 <main+0x60>
  9a:	49 8b 46 18          	mov    0x18(%r14),%rax
  9e:	0f b6 10             	movzbl (%rax),%edx
  a1:	84 d2                	test   %dl,%dl
  a3:	0f 84 13 06 00 00    	je     6bc <main+0x6bc>
  a9:	48 ff c0             	inc    %rax
  ac:	31 f6                	xor    %esi,%esi
  ae:	b9 cd cc cc cc       	mov    $0xcccccccd,%ecx
  b3:	66 66 66 66 2e 0f 1f 	data16 data16 data16 nopw %cs:0x0(%rax,%rax,1)
  ba:	84 00 00 00 00 00 
  c0:	44 8d 42 c6          	lea    -0x3a(%rdx),%r8d
  c4:	41 80 f8 f5          	cmp    $0xf5,%r8b
  c8:	0f 86 82 05 00 00    	jbe    650 <main+0x650>
  ce:	0f b6 d2             	movzbl %dl,%edx
  d1:	41 b8 2f 00 00 00    	mov    $0x2f,%r8d
  d7:	41 29 d0             	sub    %edx,%r8d
  da:	4c 0f af c1          	imul   %rcx,%r8
  de:	49 c1 e8 23          	shr    $0x23,%r8
  e2:	44 39 c6             	cmp    %r8d,%esi
  e5:	0f 87 71 05 00 00    	ja     65c <main+0x65c>
  eb:	8d 34 b6             	lea    (%rsi,%rsi,4),%esi
  ee:	8d 34 72             	lea    (%rdx,%rsi,2),%esi
  f1:	83 c6 d0             	add    $0xffffffd0,%esi
  f4:	0f b6 10             	movzbl (%rax),%edx
  f7:	48 ff c0             	inc    %rax
  fa:	84 d2                	test   %dl,%dl
  fc:	75 c2                	jne    c0 <main+0xc0>
  fe:	e8 00 00 00 00       	callq  103 <main+0x103>
			ff: R_X86_64_PLT32	bench_u32-0x4
 103:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 10a <main+0x10a>
			106: R_X86_64_PC32	.L.str.2-0x4
 10a:	89 c6                	mov    %eax,%esi
 10c:	31 c0                	xor    %eax,%eax
 10e:	e8 00 00 00 00       	callq  113 <main+0x113>
			10f: R_X86_64_PLT32	printf-0x4
 113:	85 c0                	test   %eax,%eax
 115:	0f 89 0e 05 00 00    	jns    629 <main+0x629>
 11b:	e9 b4 05 00 00       	jmpq   6d4 <main+0x6d4>
 120:	4d 8b 7e 08          	mov    0x8(%r14),%r15
 124:	48 8d 35 00 00 00 00 	lea    0x0(%rip),%rsi        # 12b <main+0x12b>
			127: R_X86_64_PC32	.L.str-0x4
 12b:	4c 89 ff             	mov    %r15,%rdi
 12e:	e8 00 00 00 00       	callq  133 <main+0x133>
			12f: R_X86_64_PLT32	strcmp-0x4
 133:	85 c0                	test   %eax,%eax
 135:	0f 84 8d 05 00 00    	je     6c8 <main+0x6c8>
 13b:	49 8b 46 10          	mov    0x10(%r14),%rax
 13f:	0f b6 10             	movzbl (%rax),%edx
 142:	84 d2                	test   %dl,%dl
 144:	0f 84 72 05 00 00    	je     6bc <main+0x6bc>
 14a:	48 ff c0             	inc    %rax
 14d:	45 31 c0             	xor    %r8d,%r8d
 150:	b9 cd cc cc cc       	mov    $0xcccccccd,%ecx
 155:	66 66 2e 0f 1f 84 00 	data16 nopw %cs:0x0(%rax,%rax,1)
 15c:	00 00 00 00 
 160:	8d 72 c6             	lea    -0x3a(%rdx),%esi
 163:	40 80 fe f5          	cmp    $0xf5,%sil
 167:	0f 86 e3 04 00 00    	jbe    650 <main+0x650>
 16d:	45 89 c5             	mov    %r8d,%r13d
 170:	0f b6 fa             	movzbl %dl,%edi
 173:	ba 2f 00 00 00       	mov    $0x2f,%edx
 178:	29 fa                	sub    %edi,%edx
 17a:	48 0f af d1          	imul   %rcx,%rdx
 17e:	48 c1 ea 23          	shr    $0x23,%rdx
 182:	41 39 d0             	cmp    %edx,%r8d
 185:	0f 87 d1 04 00 00    	ja     65c <main+0x65c>
 18b:	43 8d 54 ad 00       	lea    0x0(%r13,%r13,4),%edx
 190:	44 8d 04 57          	lea    (%rdi,%rdx,2),%r8d
 194:	41 83 c0 d0          	add    $0xffffffd0,%r8d
 198:	0f b6 10             	movzbl (%rax),%edx
 19b:	48 ff c0             	inc    %rax
 19e:	84 d2                	test   %dl,%dl
 1a0:	75 be                	jne    160 <main+0x160>
 1a2:	49 8b 46 18          	mov    0x18(%r14),%rax
 1a6:	0f b6 10             	movzbl (%rax),%edx
 1a9:	84 d2                	test   %dl,%dl
 1ab:	0f 84 0b 05 00 00    	je     6bc <main+0x6bc>
 1b1:	48 ff c0             	inc    %rax
 1b4:	45 31 db             	xor    %r11d,%r11d
 1b7:	b9 cd cc cc cc       	mov    $0xcccccccd,%ecx
 1bc:	0f 1f 40 00          	nopl   0x0(%rax)
 1c0:	8d 72 c6             	lea    -0x3a(%rdx),%esi
 1c3:	40 80 fe f5          	cmp    $0xf5,%sil
 1c7:	0f 86 83 04 00 00    	jbe    650 <main+0x650>
 1cd:	45 89 d9             	mov    %r11d,%r9d
 1d0:	44 0f b6 d2          	movzbl %dl,%r10d
 1d4:	ba 2f 00 00 00       	mov    $0x2f,%edx
 1d9:	44 29 d2             	sub    %r10d,%edx
 1dc:	48 0f af d1          	imul   %rcx,%rdx
 1e0:	48 c1 ea 23          	shr    $0x23,%rdx
 1e4:	41 39 d3             	cmp    %edx,%r11d
 1e7:	0f 87 6f 04 00 00    	ja     65c <main+0x65c>
 1ed:	43 8d 14 89          	lea    (%r9,%r9,4),%edx
 1f1:	45 8d 1c 52          	lea    (%r10,%rdx,2),%r11d
 1f5:	41 83 c3 d0          	add    $0xffffffd0,%r11d
 1f9:	0f b6 10             	movzbl (%rax),%edx
 1fc:	48 ff c0             	inc    %rax
 1ff:	84 d2                	test   %dl,%dl
 201:	75 bd                	jne    1c0 <main+0x1c0>
 203:	48 89 7c 24 48       	mov    %rdi,0x48(%rsp)
 208:	49 8b 46 20          	mov    0x20(%r14),%rax
 20c:	0f b6 10             	movzbl (%rax),%edx
 20f:	84 d2                	test   %dl,%dl
 211:	0f 84 a5 04 00 00    	je     6bc <main+0x6bc>
 217:	48 ff c0             	inc    %rax
 21a:	31 db                	xor    %ebx,%ebx
 21c:	b9 cd cc cc cc       	mov    $0xcccccccd,%ecx
 221:	66 66 66 66 66 66 2e 	data16 data16 data16 data16 data16 nopw %cs:0x0(%rax,%rax,1)
 228:	0f 1f 84 00 00 00 00 
 22f:	00 
 230:	8d 72 c6             	lea    -0x3a(%rdx),%esi
 233:	40 80 fe f5          	cmp    $0xf5,%sil
 237:	0f 86 13 04 00 00    	jbe    650 <main+0x650>
 23d:	0f b6 d2             	movzbl %dl,%edx
 240:	be 2f 00 00 00       	mov    $0x2f,%esi
 245:	29 d6                	sub    %edx,%esi
 247:	48 0f af f1          	imul   %rcx,%rsi
 24b:	48 c1 ee 23          	shr    $0x23,%rsi
 24f:	39 f3                	cmp    %esi,%ebx
 251:	0f 87 05 04 00 00    	ja     65c <main+0x65c>
 257:	8d 34 9b             	lea    (%rbx,%rbx,4),%esi
 25a:	8d 1c 72             	lea    (%rdx,%rsi,2),%ebx
 25d:	83 c3 d0             	add    $0xffffffd0,%ebx
 260:	0f b6 10             	movzbl (%rax),%edx
 263:	48 ff c0             	inc    %rax
 266:	84 d2                	test   %dl,%dl
 268:	75 c6                	jne    230 <main+0x230>
 26a:	49 8b 46 28          	mov    0x28(%r14),%rax
 26e:	0f b6 10             	movzbl (%rax),%edx
 271:	84 d2                	test   %dl,%dl
 273:	0f 84 43 04 00 00    	je     6bc <main+0x6bc>
 279:	48 ff c0             	inc    %rax
 27c:	45 31 f6             	xor    %r14d,%r14d
 27f:	b9 cd cc cc cc       	mov    $0xcccccccd,%ecx
 284:	66 66 66 2e 0f 1f 84 	data16 data16 nopw %cs:0x0(%rax,%rax,1)
 28b:	00 00 00 00 00 
 290:	8d 72 c6             	lea    -0x3a(%rdx),%esi
 293:	40 80 fe f5          	cmp    $0xf5,%sil
 297:	0f 86 b3 03 00 00    	jbe    650 <main+0x650>
 29d:	0f b6 d2             	movzbl %dl,%edx
 2a0:	be 2f 00 00 00       	mov    $0x2f,%esi
 2a5:	29 d6                	sub    %edx,%esi
 2a7:	48 0f af f1          	imul   %rcx,%rsi
 2ab:	48 c1 ee 23          	shr    $0x23,%rsi
 2af:	41 39 f6             	cmp    %esi,%r14d
 2b2:	0f 87 a4 03 00 00    	ja     65c <main+0x65c>
 2b8:	43 8d 34 b6          	lea    (%r14,%r14,4),%esi
 2bc:	44 8d 34 72          	lea    (%rdx,%rsi,2),%r14d
 2c0:	41 83 c6 d0          	add    $0xffffffd0,%r14d
 2c4:	0f b6 10             	movzbl (%rax),%edx
 2c7:	48 ff c0             	inc    %rax
 2ca:	84 d2                	test   %dl,%dl
 2cc:	75 c2                	jne    290 <main+0x290>
 2ce:	44 89 5c 24 08       	mov    %r11d,0x8(%rsp)
 2d3:	4c 89 54 24 38       	mov    %r10,0x38(%rsp)
 2d8:	4c 89 4c 24 40       	mov    %r9,0x40(%rsp)
 2dd:	44 89 44 24 1c       	mov    %r8d,0x1c(%rsp)
 2e2:	48 8d 35 00 00 00 00 	lea    0x0(%rip),%rsi        # 2e9 <main+0x2e9>
			2e5: R_X86_64_PC32	.L.str.13-0x4
 2e9:	4c 89 ff             	mov    %r15,%rdi
 2ec:	e8 00 00 00 00       	callq  2f1 <main+0x2f1>
			2ed: R_X86_64_PLT32	fopen-0x4
 2f1:	48 85 c0             	test   %rax,%rax
 2f4:	0f 84 0a 04 00 00    	je     704 <main+0x704>
 2fa:	49 89 c4             	mov    %rax,%r12
 2fd:	48 89 5c 24 50       	mov    %rbx,0x50(%rsp)
 302:	4c 89 6c 24 30       	mov    %r13,0x30(%rsp)
 307:	bd 00 10 00 00       	mov    $0x1000,%ebp
 30c:	bf 00 10 00 00       	mov    $0x1000,%edi
 311:	e8 00 00 00 00       	callq  316 <main+0x316>
			312: R_X86_64_PLT32	malloc-0x4
 316:	48 85 c0             	test   %rax,%rax
 319:	0f 84 f1 03 00 00    	je     710 <main+0x710>
 31f:	49 89 c7             	mov    %rax,%r15
 322:	45 31 ed             	xor    %r13d,%r13d
 325:	66 66 2e 0f 1f 84 00 	data16 nopw %cs:0x0(%rax,%rax,1)
 32c:	00 00 00 00 
 330:	48 8d 45 ff          	lea    -0x1(%rbp),%rax
 334:	49 39 c5             	cmp    %rax,%r13
 337:	75 27                	jne    360 <main+0x360>
 339:	48 85 ed             	test   %rbp,%rbp
 33c:	0f 88 42 03 00 00    	js     684 <main+0x684>
 342:	48 01 ed             	add    %rbp,%rbp
 345:	4c 89 ff             	mov    %r15,%rdi
 348:	48 89 ee             	mov    %rbp,%rsi
 34b:	e8 00 00 00 00       	callq  350 <main+0x350>
			34c: R_X86_64_PLT32	realloc-0x4
 350:	48 89 c3             	mov    %rax,%rbx
 353:	48 85 c0             	test   %rax,%rax
 356:	75 0b                	jne    363 <main+0x363>
 358:	e9 43 03 00 00       	jmpq   6a0 <main+0x6a0>
 35d:	0f 1f 00             	nopl   (%rax)
 360:	4c 89 fb             	mov    %r15,%rbx
 363:	4a 8d 3c 2b          	lea    (%rbx,%r13,1),%rdi
 367:	4c 89 ea             	mov    %r13,%rdx
 36a:	48 f7 d2             	not    %rdx
 36d:	48 01 ea             	add    %rbp,%rdx
 370:	be 01 00 00 00       	mov    $0x1,%esi
 375:	4c 89 e1             	mov    %r12,%rcx
 378:	e8 00 00 00 00       	callq  37d <main+0x37d>
			379: R_X86_64_PLT32	fread-0x4
 37d:	49 89 c7             	mov    %rax,%r15
 380:	4c 89 e7             	mov    %r12,%rdi
 383:	e8 00 00 00 00       	callq  388 <main+0x388>
			384: R_X86_64_PLT32	ferror-0x4
 388:	85 c0                	test   %eax,%eax
 38a:	0f 85 d8 02 00 00    	jne    668 <main+0x668>
 390:	4d 01 fd             	add    %r15,%r13
 393:	4c 89 e7             	mov    %r12,%rdi
 396:	e8 00 00 00 00       	callq  39b <main+0x39b>
			397: R_X86_64_PLT32	feof-0x4
 39b:	49 89 df             	mov    %rbx,%r15
 39e:	85 c0                	test   %eax,%eax
 3a0:	74 8e                	je     330 <main+0x330>
 3a2:	48 89 5c 24 10       	mov    %rbx,0x10(%rsp)
 3a7:	4c 89 e7             	mov    %r12,%rdi
 3aa:	e8 00 00 00 00       	callq  3af <main+0x3af>
			3ab: R_X86_64_PLT32	fclose-0x4
 3af:	85 c0                	test   %eax,%eax
 3b1:	0f 85 6d 03 00 00    	jne    724 <main+0x724>
 3b7:	4d 85 ed             	test   %r13,%r13
 3ba:	48 8b 5c 24 10       	mov    0x10(%rsp),%rbx
 3bf:	74 10                	je     3d1 <main+0x3d1>
 3c1:	31 c0                	xor    %eax,%eax
 3c3:	42 80 7c 2b ff 0a    	cmpb   $0xa,-0x1(%rbx,%r13,1)
 3c9:	0f 94 c0             	sete   %al
 3cc:	49 29 c5             	sub    %rax,%r13
 3cf:	eb 03                	jmp    3d4 <main+0x3d4>
 3d1:	45 31 ed             	xor    %r13d,%r13d
 3d4:	48 89 df             	mov    %rbx,%rdi
 3d7:	31 f6                	xor    %esi,%esi
 3d9:	4c 89 ea             	mov    %r13,%rdx
 3dc:	e8 00 00 00 00       	callq  3e1 <main+0x3e1>
			3dd: R_X86_64_PLT32	memchr-0x4
 3e1:	48 85 c0             	test   %rax,%rax
 3e4:	0f 85 50 03 00 00    	jne    73a <main+0x73a>
 3ea:	42 c6 04 2b 00       	movb   $0x0,(%rbx,%r13,1)
 3ef:	0f b6 13             	movzbl (%rbx),%edx
 3f2:	84 d2                	test   %dl,%dl
 3f4:	0f 84 c2 02 00 00    	je     6bc <main+0x6bc>
 3fa:	48 8d 43 01          	lea    0x1(%rbx),%rax
 3fe:	45 31 ff             	xor    %r15d,%r15d
 401:	b9 cd cc cc cc       	mov    $0xcccccccd,%ecx
 406:	48 8b 5c 24 50       	mov    0x50(%rsp),%rbx
 40b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
 410:	8d 72 c6             	lea    -0x3a(%rdx),%esi
 413:	40 80 fe f5          	cmp    $0xf5,%sil
 417:	0f 86 33 02 00 00    	jbe    650 <main+0x650>
 41d:	0f b6 d2             	movzbl %dl,%edx
 420:	be 2f 00 00 00       	mov    $0x2f,%esi
 425:	29 d6                	sub    %edx,%esi
 427:	48 0f af f1          	imul   %rcx,%rsi
 42b:	48 c1 ee 23          	shr    $0x23,%rsi
 42f:	41 39 f7             	cmp    %esi,%r15d
 432:	0f 87 24 02 00 00    	ja     65c <main+0x65c>
 438:	43 8d 34 bf          	lea    (%r15,%r15,4),%esi
 43c:	44 8d 3c 72          	lea    (%rdx,%rsi,2),%r15d
 440:	41 83 c7 d0          	add    $0xffffffd0,%r15d
 444:	0f b6 10             	movzbl (%rax),%edx
 447:	48 ff c0             	inc    %rax
 44a:	84 d2                	test   %dl,%dl
 44c:	75 c2                	jne    410 <main+0x410>
 44e:	89 df                	mov    %ebx,%edi
 450:	44 89 f6             	mov    %r14d,%esi
 453:	e8 00 00 00 00       	callq  458 <main+0x458>
			454: R_X86_64_PLT32	bench_u32-0x4
 458:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 45f <main+0x45f>
			45b: R_X86_64_PC32	.L.str.2-0x4
 45f:	31 ed                	xor    %ebp,%ebp
 461:	89 c6                	mov    %eax,%esi
 463:	31 c0                	xor    %eax,%eax
 465:	e8 00 00 00 00       	callq  46a <main+0x46a>
			466: R_X86_64_PLT32	printf-0x4
 46a:	85 c0                	test   %eax,%eax
 46c:	0f 88 62 02 00 00    	js     6d4 <main+0x6d4>
 472:	83 7c 24 08 00       	cmpl   $0x0,0x8(%rsp)
 477:	74 30                	je     4a9 <main+0x4a9>
 479:	48 8b 44 24 40       	mov    0x40(%rsp),%rax
 47e:	8d 04 80             	lea    (%rax,%rax,4),%eax
 481:	48 8b 4c 24 38       	mov    0x38(%rsp),%rcx
 486:	44 8d 24 41          	lea    (%rcx,%rax,2),%r12d
 48a:	41 83 c4 d0          	add    $0xffffffd0,%r12d
 48e:	31 ed                	xor    %ebp,%ebp
 490:	89 df                	mov    %ebx,%edi
 492:	44 89 f6             	mov    %r14d,%esi
 495:	e8 00 00 00 00       	callq  49a <main+0x49a>
			496: R_X86_64_PLT32	bench_u32-0x4
 49a:	31 c9                	xor    %ecx,%ecx
 49c:	44 39 f8             	cmp    %r15d,%eax
 49f:	0f 94 c1             	sete   %cl
 4a2:	01 cd                	add    %ecx,%ebp
 4a4:	41 ff cc             	dec    %r12d
 4a7:	75 e7                	jne    490 <main+0x490>
 4a9:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 4b0 <main+0x4b0>
			4ac: R_X86_64_PC32	.L.str.2-0x4
 4b0:	89 ee                	mov    %ebp,%esi
 4b2:	31 c0                	xor    %eax,%eax
 4b4:	e8 00 00 00 00       	callq  4b9 <main+0x4b9>
			4b5: R_X86_64_PLT32	printf-0x4
 4b9:	85 c0                	test   %eax,%eax
 4bb:	0f 88 8d 02 00 00    	js     74e <main+0x74e>
 4c1:	48 8d 74 24 20       	lea    0x20(%rsp),%rsi
 4c6:	bf 01 00 00 00       	mov    $0x1,%edi
 4cb:	e8 00 00 00 00       	callq  4d0 <main+0x4d0>
			4cc: R_X86_64_PLT32	clock_gettime-0x4
 4d0:	85 c0                	test   %eax,%eax
 4d2:	0f 85 08 02 00 00    	jne    6e0 <main+0x6e0>
 4d8:	48 8b 74 24 20       	mov    0x20(%rsp),%rsi
 4dd:	48 85 f6             	test   %rsi,%rsi
 4e0:	8b 4c 24 1c          	mov    0x1c(%rsp),%ecx
 4e4:	0f 88 02 02 00 00    	js     6ec <main+0x6ec>
 4ea:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
 4ef:	48 3d 00 ca 9a 3b    	cmp    $0x3b9aca00,%rax
 4f5:	0f 83 f1 01 00 00    	jae    6ec <main+0x6ec>
 4fb:	4c 69 e8 83 de 1b 43 	imul   $0x431bde83,%rax,%r13
 502:	49 c1 ed 32          	shr    $0x32,%r13
 506:	4c 89 e8             	mov    %r13,%rax
 509:	48 f7 d0             	not    %rax
 50c:	48 c1 e8 03          	shr    $0x3,%rax
 510:	48 ba cf f7 53 e3 a5 	movabs $0x20c49ba5e353f7cf,%rdx
 517:	9b c4 20 
 51a:	48 f7 e2             	mul    %rdx
 51d:	48 c1 ea 04          	shr    $0x4,%rdx
 521:	48 39 d6             	cmp    %rdx,%rsi
 524:	0f 87 ce 01 00 00    	ja     6f8 <main+0x6f8>
 52a:	48 89 74 24 08       	mov    %rsi,0x8(%rsp)
 52f:	85 c9                	test   %ecx,%ecx
 531:	74 38                	je     56b <main+0x56b>
 533:	48 8b 44 24 30       	mov    0x30(%rsp),%rax
 538:	8d 04 80             	lea    (%rax,%rax,4),%eax
 53b:	48 8b 4c 24 48       	mov    0x48(%rsp),%rcx
 540:	44 8d 24 41          	lea    (%rcx,%rax,2),%r12d
 544:	41 83 c4 d0          	add    $0xffffffd0,%r12d
 548:	31 ed                	xor    %ebp,%ebp
 54a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
 550:	89 df                	mov    %ebx,%edi
 552:	44 89 f6             	mov    %r14d,%esi
 555:	e8 00 00 00 00       	callq  55a <main+0x55a>
			556: R_X86_64_PLT32	bench_u32-0x4
 55a:	31 c9                	xor    %ecx,%ecx
 55c:	44 39 f8             	cmp    %r15d,%eax
 55f:	0f 94 c1             	sete   %cl
 562:	01 cd                	add    %ecx,%ebp
 564:	41 ff cc             	dec    %r12d
 567:	75 e7                	jne    550 <main+0x550>
 569:	eb 02                	jmp    56d <main+0x56d>
 56b:	31 ed                	xor    %ebp,%ebp
 56d:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 574 <main+0x574>
			570: R_X86_64_PC32	.L.str.2-0x4
 574:	89 ee                	mov    %ebp,%esi
 576:	31 c0                	xor    %eax,%eax
 578:	e8 00 00 00 00       	callq  57d <main+0x57d>
			579: R_X86_64_PLT32	printf-0x4
 57d:	85 c0                	test   %eax,%eax
 57f:	0f 88 d5 01 00 00    	js     75a <main+0x75a>
 585:	48 8d 74 24 20       	lea    0x20(%rsp),%rsi
 58a:	bf 01 00 00 00       	mov    $0x1,%edi
 58f:	e8 00 00 00 00       	callq  594 <main+0x594>
			590: R_X86_64_PLT32	clock_gettime-0x4
 594:	85 c0                	test   %eax,%eax
 596:	0f 85 44 01 00 00    	jne    6e0 <main+0x6e0>
 59c:	48 8b 4c 24 20       	mov    0x20(%rsp),%rcx
 5a1:	48 85 c9             	test   %rcx,%rcx
 5a4:	0f 88 42 01 00 00    	js     6ec <main+0x6ec>
 5aa:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
 5af:	48 3d 00 ca 9a 3b    	cmp    $0x3b9aca00,%rax
 5b5:	0f 83 31 01 00 00    	jae    6ec <main+0x6ec>
 5bb:	48 69 f8 83 de 1b 43 	imul   $0x431bde83,%rax,%rdi
 5c2:	48 c1 ef 32          	shr    $0x32,%rdi
 5c6:	48 89 f8             	mov    %rdi,%rax
 5c9:	48 f7 d0             	not    %rax
 5cc:	48 c1 e8 03          	shr    $0x3,%rax
 5d0:	48 ba cf f7 53 e3 a5 	movabs $0x20c49ba5e353f7cf,%rdx
 5d7:	9b c4 20 
 5da:	48 f7 e2             	mul    %rdx
 5dd:	48 c1 ea 04          	shr    $0x4,%rdx
 5e1:	48 39 d1             	cmp    %rdx,%rcx
 5e4:	0f 87 0e 01 00 00    	ja     6f8 <main+0x6f8>
 5ea:	48 69 44 24 08 e8 03 	imul   $0x3e8,0x8(%rsp),%rax
 5f1:	00 00 
 5f3:	4c 01 e8             	add    %r13,%rax
 5f6:	48 69 f1 e8 03 00 00 	imul   $0x3e8,%rcx,%rsi
 5fd:	48 01 fe             	add    %rdi,%rsi
 600:	48 29 c6             	sub    %rax,%rsi
 603:	0f 82 5d 01 00 00    	jb     766 <main+0x766>
 609:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 610 <main+0x610>
			60c: R_X86_64_PC32	.L.str.6-0x4
 610:	31 c0                	xor    %eax,%eax
 612:	e8 00 00 00 00       	callq  617 <main+0x617>
			613: R_X86_64_PLT32	printf-0x4
 617:	85 c0                	test   %eax,%eax
 619:	0f 88 53 01 00 00    	js     772 <main+0x772>
 61f:	48 8b 7c 24 10       	mov    0x10(%rsp),%rdi
 624:	e8 00 00 00 00       	callq  629 <main+0x629>
			625: R_X86_64_PLT32	free-0x4
 629:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 630 <main+0x630>
			62c: R_X86_64_REX_GOTPCRELX	stdout-0x4
 630:	48 8b 38             	mov    (%rax),%rdi
 633:	e8 00 00 00 00       	callq  638 <main+0x638>
			634: R_X86_64_PLT32	fclose-0x4
 638:	31 c9                	xor    %ecx,%ecx
 63a:	85 c0                	test   %eax,%eax
 63c:	0f 95 c1             	setne  %cl
 63f:	89 c8                	mov    %ecx,%eax
 641:	48 83 c4 58          	add    $0x58,%rsp
 645:	5b                   	pop    %rbx
 646:	41 5c                	pop    %r12
 648:	41 5d                	pop    %r13
 64a:	41 5e                	pop    %r14
 64c:	41 5f                	pop    %r15
 64e:	5d                   	pop    %rbp
 64f:	c3                   	retq   
 650:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 657 <main+0x657>
			653: R_X86_64_PC32	.L.str.9-0x4
 657:	e8 00 00 00 00       	callq  65c <main+0x65c>
			658: R_X86_64_PLT32	.text.unlikely.-0x4
 65c:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 663 <main+0x663>
			65f: R_X86_64_PC32	.L.str.10-0x4
 663:	e8 00 00 00 00       	callq  668 <main+0x668>
			664: R_X86_64_PLT32	.text.unlikely.-0x4
 668:	48 89 df             	mov    %rbx,%rdi
 66b:	e8 00 00 00 00       	callq  670 <main+0x670>
			66c: R_X86_64_PLT32	free-0x4
 670:	4c 89 e7             	mov    %r12,%rdi
 673:	e8 00 00 00 00       	callq  678 <main+0x678>
			674: R_X86_64_PLT32	fclose-0x4
 678:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 67f <main+0x67f>
			67b: R_X86_64_PC32	.L.str.18-0x4
 67f:	e8 00 00 00 00       	callq  684 <main+0x684>
			680: R_X86_64_PLT32	.text.unlikely.-0x4
 684:	4c 89 ff             	mov    %r15,%rdi
 687:	e8 00 00 00 00       	callq  68c <main+0x68c>
			688: R_X86_64_PLT32	free-0x4
 68c:	4c 89 e7             	mov    %r12,%rdi
 68f:	e8 00 00 00 00       	callq  694 <main+0x694>
			690: R_X86_64_PLT32	fclose-0x4
 694:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 69b <main+0x69b>
			697: R_X86_64_PC32	.L.str.16-0x4
 69b:	e8 00 00 00 00       	callq  6a0 <main+0x6a0>
			69c: R_X86_64_PLT32	.text.unlikely.-0x4
 6a0:	4c 89 ff             	mov    %r15,%rdi
 6a3:	e8 00 00 00 00       	callq  6a8 <main+0x6a8>
			6a4: R_X86_64_PLT32	free-0x4
 6a8:	4c 89 e7             	mov    %r12,%rdi
 6ab:	e8 00 00 00 00       	callq  6b0 <main+0x6b0>
			6ac: R_X86_64_PLT32	fclose-0x4
 6b0:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 6b7 <main+0x6b7>
			6b3: R_X86_64_PC32	.L.str.17-0x4
 6b7:	e8 00 00 00 00       	callq  6bc <main+0x6bc>
			6b8: R_X86_64_PLT32	.text.unlikely.-0x4
 6bc:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 6c3 <main+0x6c3>
			6bf: R_X86_64_PC32	.L.str.8-0x4
 6c3:	e8 00 00 00 00       	callq  6c8 <main+0x6c8>
			6c4: R_X86_64_PLT32	.text.unlikely.-0x4
 6c8:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 6cf <main+0x6cf>
			6cb: R_X86_64_PC32	.L.str.1-0x4
 6cf:	e8 00 00 00 00       	callq  6d4 <main+0x6d4>
			6d0: R_X86_64_PLT32	.text.unlikely.-0x4
 6d4:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 6db <main+0x6db>
			6d7: R_X86_64_PC32	.L.str.11-0x4
 6db:	e8 00 00 00 00       	callq  6e0 <main+0x6e0>
			6dc: R_X86_64_PLT32	.text.unlikely.-0x4
 6e0:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 6e7 <main+0x6e7>
			6e3: R_X86_64_PC32	.L.str.21-0x4
 6e7:	e8 00 00 00 00       	callq  6ec <main+0x6ec>
			6e8: R_X86_64_PLT32	.text.unlikely.-0x4
 6ec:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 6f3 <main+0x6f3>
			6ef: R_X86_64_PC32	.L.str.22-0x4
 6f3:	e8 00 00 00 00       	callq  6f8 <main+0x6f8>
			6f4: R_X86_64_PLT32	.text.unlikely.-0x4
 6f8:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 6ff <main+0x6ff>
			6fb: R_X86_64_PC32	.L.str.23-0x4
 6ff:	e8 00 00 00 00       	callq  704 <main+0x704>
			700: R_X86_64_PLT32	.text.unlikely.-0x4
 704:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 70b <main+0x70b>
			707: R_X86_64_PC32	.L.str.14-0x4
 70b:	e8 00 00 00 00       	callq  710 <main+0x710>
			70c: R_X86_64_PLT32	.text.unlikely.-0x4
 710:	4c 89 e7             	mov    %r12,%rdi
 713:	e8 00 00 00 00       	callq  718 <main+0x718>
			714: R_X86_64_PLT32	fclose-0x4
 718:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 71f <main+0x71f>
			71b: R_X86_64_PC32	.L.str.15-0x4
 71f:	e8 00 00 00 00       	callq  724 <main+0x724>
			720: R_X86_64_PLT32	.text.unlikely.-0x4
 724:	48 8b 7c 24 10       	mov    0x10(%rsp),%rdi
 729:	e8 00 00 00 00       	callq  72e <main+0x72e>
			72a: R_X86_64_PLT32	free-0x4
 72e:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 735 <main+0x735>
			731: R_X86_64_PC32	.L.str.19-0x4
 735:	e8 00 00 00 00       	callq  73a <main+0x73a>
			736: R_X86_64_PLT32	.text.unlikely.-0x4
 73a:	48 89 df             	mov    %rbx,%rdi
 73d:	e8 00 00 00 00       	callq  742 <main+0x742>
			73e: R_X86_64_PLT32	free-0x4
 742:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 749 <main+0x749>
			745: R_X86_64_PC32	.L.str.20-0x4
 749:	e8 00 00 00 00       	callq  74e <main+0x74e>
			74a: R_X86_64_PLT32	.text.unlikely.-0x4
 74e:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 755 <main+0x755>
			751: R_X86_64_PC32	.L.str.3-0x4
 755:	e8 00 00 00 00       	callq  75a <main+0x75a>
			756: R_X86_64_PLT32	.text.unlikely.-0x4
 75a:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 761 <main+0x761>
			75d: R_X86_64_PC32	.L.str.4-0x4
 761:	e8 00 00 00 00       	callq  766 <main+0x766>
			762: R_X86_64_PLT32	.text.unlikely.-0x4
 766:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 76d <main+0x76d>
			769: R_X86_64_PC32	.L.str.5-0x4
 76d:	e8 00 00 00 00       	callq  772 <main+0x772>
			76e: R_X86_64_PLT32	.text.unlikely.-0x4
 772:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 779 <main+0x779>
			775: R_X86_64_PC32	.L.str.7-0x4
 779:	e8 00 00 00 00       	callq  77e <.L.str.23+0x4fc>
			77a: R_X86_64_PLT32	.text.unlikely.-0x4

Disassembly of section .text.unlikely.:

0000000000000000 <fail>:
   0:	50                   	push   %rax
   1:	48 89 fa             	mov    %rdi,%rdx
   4:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # b <fail+0xb>
			7: R_X86_64_REX_GOTPCRELX	stderr-0x4
   b:	48 8b 38             	mov    (%rax),%rdi
   e:	48 8d 35 00 00 00 00 	lea    0x0(%rip),%rsi        # 15 <fail+0x15>
			11: R_X86_64_PC32	.L.str.12-0x4
  15:	31 c0                	xor    %eax,%eax
  17:	e8 00 00 00 00       	callq  1c <fail+0x1c>
			18: R_X86_64_PLT32	fprintf-0x4
  1c:	bf 01 00 00 00       	mov    $0x1,%edi
  21:	e8 00 00 00 00       	callq  26 <.L.str.1+0x1e>
			22: R_X86_64_PLT32	exit-0x4
