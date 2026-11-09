
selfhost/build/phase184/c-products02/drivers/text.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <main>:
   0:	55                   	push   %rbp
   1:	41 57                	push   %r15
   3:	41 56                	push   %r14
   5:	41 55                	push   %r13
   7:	41 54                	push   %r12
   9:	53                   	push   %rbx
   a:	48 83 ec 48          	sub    $0x48,%rsp
   e:	49 89 f6             	mov    %rsi,%r14
  11:	83 ff 06             	cmp    $0x6,%edi
  14:	0f 84 1d 01 00 00    	je     137 <main+0x137>
  1a:	83 ff 04             	cmp    $0x4,%edi
  1d:	0f 85 ac 06 00 00    	jne    6cf <main+0x6cf>
  23:	49 8b 7e 08          	mov    0x8(%r14),%rdi
  27:	48 8d 35 00 00 00 00 	lea    0x0(%rip),%rsi        # 2e <main+0x2e>
			2a: R_X86_64_PC32	.L.str-0x4
  2e:	e8 00 00 00 00       	callq  33 <main+0x33>
			2f: R_X86_64_PLT32	strcmp-0x4
  33:	85 c0                	test   %eax,%eax
  35:	0f 85 94 06 00 00    	jne    6cf <main+0x6cf>
  3b:	49 8b 46 10          	mov    0x10(%r14),%rax
  3f:	0f b6 10             	movzbl (%rax),%edx
  42:	84 d2                	test   %dl,%dl
  44:	0f 84 79 06 00 00    	je     6c3 <main+0x6c3>
  4a:	48 ff c0             	inc    %rax
  4d:	31 ff                	xor    %edi,%edi
  4f:	b9 cd cc cc cc       	mov    $0xcccccccd,%ecx
  54:	66 66 66 2e 0f 1f 84 	data16 data16 nopw %cs:0x0(%rax,%rax,1)
  5b:	00 00 00 00 00 
  60:	8d 72 c6             	lea    -0x3a(%rdx),%esi
  63:	40 80 fe f5          	cmp    $0xf5,%sil
  67:	0f 86 de 05 00 00    	jbe    64b <main+0x64b>
  6d:	0f b6 d2             	movzbl %dl,%edx
  70:	be 2f 00 00 00       	mov    $0x2f,%esi
  75:	29 d6                	sub    %edx,%esi
  77:	48 0f af f1          	imul   %rcx,%rsi
  7b:	48 c1 ee 23          	shr    $0x23,%rsi
  7f:	39 f7                	cmp    %esi,%edi
  81:	0f 87 d0 05 00 00    	ja     657 <main+0x657>
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
  a3:	0f 84 1a 06 00 00    	je     6c3 <main+0x6c3>
  a9:	48 ff c0             	inc    %rax
  ac:	31 f6                	xor    %esi,%esi
  ae:	b9 cd cc cc cc       	mov    $0xcccccccd,%ecx
  b3:	66 66 66 66 2e 0f 1f 	data16 data16 data16 nopw %cs:0x0(%rax,%rax,1)
  ba:	84 00 00 00 00 00 
  c0:	44 8d 42 c6          	lea    -0x3a(%rdx),%r8d
  c4:	41 80 f8 f5          	cmp    $0xf5,%r8b
  c8:	0f 86 7d 05 00 00    	jbe    64b <main+0x64b>
  ce:	0f b6 d2             	movzbl %dl,%edx
  d1:	41 b8 2f 00 00 00    	mov    $0x2f,%r8d
  d7:	41 29 d0             	sub    %edx,%r8d
  da:	4c 0f af c1          	imul   %rcx,%r8
  de:	49 c1 e8 23          	shr    $0x23,%r8
  e2:	44 39 c6             	cmp    %r8d,%esi
  e5:	0f 87 6c 05 00 00    	ja     657 <main+0x657>
  eb:	8d 34 b6             	lea    (%rsi,%rsi,4),%esi
  ee:	8d 34 72             	lea    (%rdx,%rsi,2),%esi
  f1:	83 c6 d0             	add    $0xffffffd0,%esi
  f4:	0f b6 10             	movzbl (%rax),%edx
  f7:	48 ff c0             	inc    %rax
  fa:	84 d2                	test   %dl,%dl
  fc:	75 c2                	jne    c0 <main+0xc0>
  fe:	e8 00 00 00 00       	callq  103 <main+0x103>
			ff: R_X86_64_PLT32	bench_text-0x4
 103:	48 85 c0             	test   %rax,%rax
 106:	0f 84 57 05 00 00    	je     663 <main+0x663>
 10c:	48 89 c3             	mov    %rax,%rbx
 10f:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 116 <main+0x116>
			112: R_X86_64_PC32	.L.str.12-0x4
 116:	48 89 c6             	mov    %rax,%rsi
 119:	31 c0                	xor    %eax,%eax
 11b:	e8 00 00 00 00       	callq  120 <main+0x120>
			11c: R_X86_64_PLT32	printf-0x4
 120:	89 c5                	mov    %eax,%ebp
 122:	48 89 df             	mov    %rbx,%rdi
 125:	e8 00 00 00 00       	callq  12a <main+0x12a>
			126: R_X86_64_PLT32	free-0x4
 12a:	85 ed                	test   %ebp,%ebp
 12c:	0f 89 f2 04 00 00    	jns    624 <main+0x624>
 132:	e9 a4 05 00 00       	jmpq   6db <main+0x6db>
 137:	4d 8b 7e 08          	mov    0x8(%r14),%r15
 13b:	48 8d 35 00 00 00 00 	lea    0x0(%rip),%rsi        # 142 <main+0x142>
			13e: R_X86_64_PC32	.L.str-0x4
 142:	4c 89 ff             	mov    %r15,%rdi
 145:	e8 00 00 00 00       	callq  14a <main+0x14a>
			146: R_X86_64_PLT32	strcmp-0x4
 14a:	85 c0                	test   %eax,%eax
 14c:	0f 84 7d 05 00 00    	je     6cf <main+0x6cf>
 152:	49 8b 46 10          	mov    0x10(%r14),%rax
 156:	0f b6 10             	movzbl (%rax),%edx
 159:	84 d2                	test   %dl,%dl
 15b:	0f 84 62 05 00 00    	je     6c3 <main+0x6c3>
 161:	48 ff c0             	inc    %rax
 164:	31 ff                	xor    %edi,%edi
 166:	b9 cd cc cc cc       	mov    $0xcccccccd,%ecx
 16b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
 170:	8d 72 c6             	lea    -0x3a(%rdx),%esi
 173:	40 80 fe f5          	cmp    $0xf5,%sil
 177:	0f 86 ce 04 00 00    	jbe    64b <main+0x64b>
 17d:	89 fb                	mov    %edi,%ebx
 17f:	44 0f b6 ea          	movzbl %dl,%r13d
 183:	ba 2f 00 00 00       	mov    $0x2f,%edx
 188:	44 29 ea             	sub    %r13d,%edx
 18b:	48 0f af d1          	imul   %rcx,%rdx
 18f:	48 c1 ea 23          	shr    $0x23,%rdx
 193:	39 d7                	cmp    %edx,%edi
 195:	0f 87 bc 04 00 00    	ja     657 <main+0x657>
 19b:	8d 14 9b             	lea    (%rbx,%rbx,4),%edx
 19e:	41 8d 7c 55 d0       	lea    -0x30(%r13,%rdx,2),%edi
 1a3:	0f b6 10             	movzbl (%rax),%edx
 1a6:	48 ff c0             	inc    %rax
 1a9:	84 d2                	test   %dl,%dl
 1ab:	75 c3                	jne    170 <main+0x170>
 1ad:	49 8b 46 18          	mov    0x18(%r14),%rax
 1b1:	0f b6 10             	movzbl (%rax),%edx
 1b4:	84 d2                	test   %dl,%dl
 1b6:	0f 84 07 05 00 00    	je     6c3 <main+0x6c3>
 1bc:	48 ff c0             	inc    %rax
 1bf:	45 31 db             	xor    %r11d,%r11d
 1c2:	b9 cd cc cc cc       	mov    $0xcccccccd,%ecx
 1c7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
 1ce:	00 00 
 1d0:	8d 72 c6             	lea    -0x3a(%rdx),%esi
 1d3:	40 80 fe f5          	cmp    $0xf5,%sil
 1d7:	0f 86 6e 04 00 00    	jbe    64b <main+0x64b>
 1dd:	45 89 d9             	mov    %r11d,%r9d
 1e0:	44 0f b6 d2          	movzbl %dl,%r10d
 1e4:	ba 2f 00 00 00       	mov    $0x2f,%edx
 1e9:	44 29 d2             	sub    %r10d,%edx
 1ec:	48 0f af d1          	imul   %rcx,%rdx
 1f0:	48 c1 ea 23          	shr    $0x23,%rdx
 1f4:	41 39 d3             	cmp    %edx,%r11d
 1f7:	0f 87 5a 04 00 00    	ja     657 <main+0x657>
 1fd:	43 8d 14 89          	lea    (%r9,%r9,4),%edx
 201:	45 8d 1c 52          	lea    (%r10,%rdx,2),%r11d
 205:	41 83 c3 d0          	add    $0xffffffd0,%r11d
 209:	0f b6 10             	movzbl (%rax),%edx
 20c:	48 ff c0             	inc    %rax
 20f:	84 d2                	test   %dl,%dl
 211:	75 bd                	jne    1d0 <main+0x1d0>
 213:	49 8b 46 20          	mov    0x20(%r14),%rax
 217:	0f b6 10             	movzbl (%rax),%edx
 21a:	84 d2                	test   %dl,%dl
 21c:	0f 84 a1 04 00 00    	je     6c3 <main+0x6c3>
 222:	48 ff c0             	inc    %rax
 225:	45 31 c0             	xor    %r8d,%r8d
 228:	b9 cd cc cc cc       	mov    $0xcccccccd,%ecx
 22d:	0f 1f 00             	nopl   (%rax)
 230:	8d 72 c6             	lea    -0x3a(%rdx),%esi
 233:	40 80 fe f5          	cmp    $0xf5,%sil
 237:	0f 86 0e 04 00 00    	jbe    64b <main+0x64b>
 23d:	0f b6 d2             	movzbl %dl,%edx
 240:	be 2f 00 00 00       	mov    $0x2f,%esi
 245:	29 d6                	sub    %edx,%esi
 247:	48 0f af f1          	imul   %rcx,%rsi
 24b:	48 c1 ee 23          	shr    $0x23,%rsi
 24f:	41 39 f0             	cmp    %esi,%r8d
 252:	0f 87 ff 03 00 00    	ja     657 <main+0x657>
 258:	43 8d 34 80          	lea    (%r8,%r8,4),%esi
 25c:	44 8d 04 72          	lea    (%rdx,%rsi,2),%r8d
 260:	41 83 c0 d0          	add    $0xffffffd0,%r8d
 264:	0f b6 10             	movzbl (%rax),%edx
 267:	48 ff c0             	inc    %rax
 26a:	84 d2                	test   %dl,%dl
 26c:	75 c2                	jne    230 <main+0x230>
 26e:	49 8b 46 28          	mov    0x28(%r14),%rax
 272:	0f b6 10             	movzbl (%rax),%edx
 275:	84 d2                	test   %dl,%dl
 277:	0f 84 46 04 00 00    	je     6c3 <main+0x6c3>
 27d:	48 ff c0             	inc    %rax
 280:	45 31 f6             	xor    %r14d,%r14d
 283:	b9 cd cc cc cc       	mov    $0xcccccccd,%ecx
 288:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
 28f:	00 
 290:	8d 72 c6             	lea    -0x3a(%rdx),%esi
 293:	40 80 fe f5          	cmp    $0xf5,%sil
 297:	0f 86 ae 03 00 00    	jbe    64b <main+0x64b>
 29d:	0f b6 d2             	movzbl %dl,%edx
 2a0:	be 2f 00 00 00       	mov    $0x2f,%esi
 2a5:	29 d6                	sub    %edx,%esi
 2a7:	48 0f af f1          	imul   %rcx,%rsi
 2ab:	48 c1 ee 23          	shr    $0x23,%rsi
 2af:	41 39 f6             	cmp    %esi,%r14d
 2b2:	0f 87 9f 03 00 00    	ja     657 <main+0x657>
 2b8:	43 8d 34 b6          	lea    (%r14,%r14,4),%esi
 2bc:	44 8d 34 72          	lea    (%rdx,%rsi,2),%r14d
 2c0:	41 83 c6 d0          	add    $0xffffffd0,%r14d
 2c4:	0f b6 10             	movzbl (%rax),%edx
 2c7:	48 ff c0             	inc    %rax
 2ca:	84 d2                	test   %dl,%dl
 2cc:	75 c2                	jne    290 <main+0x290>
 2ce:	44 89 1c 24          	mov    %r11d,(%rsp)
 2d2:	4c 89 54 24 38       	mov    %r10,0x38(%rsp)
 2d7:	4c 89 4c 24 40       	mov    %r9,0x40(%rsp)
 2dc:	4c 89 44 24 08       	mov    %r8,0x8(%rsp)
 2e1:	89 7c 24 14          	mov    %edi,0x14(%rsp)
 2e5:	48 8d 35 00 00 00 00 	lea    0x0(%rip),%rsi        # 2ec <main+0x2ec>
			2e8: R_X86_64_PC32	.L.str.15-0x4
 2ec:	4c 89 ff             	mov    %r15,%rdi
 2ef:	e8 00 00 00 00       	callq  2f4 <main+0x2f4>
			2f0: R_X86_64_PLT32	fopen-0x4
 2f4:	48 85 c0             	test   %rax,%rax
 2f7:	0f 84 0e 04 00 00    	je     70b <main+0x70b>
 2fd:	49 89 c4             	mov    %rax,%r12
 300:	4c 89 6c 24 28       	mov    %r13,0x28(%rsp)
 305:	48 89 5c 24 30       	mov    %rbx,0x30(%rsp)
 30a:	bd 00 10 00 00       	mov    $0x1000,%ebp
 30f:	bf 00 10 00 00       	mov    $0x1000,%edi
 314:	e8 00 00 00 00       	callq  319 <main+0x319>
			315: R_X86_64_PLT32	malloc-0x4
 319:	48 85 c0             	test   %rax,%rax
 31c:	0f 84 f5 03 00 00    	je     717 <main+0x717>
 322:	49 89 c7             	mov    %rax,%r15
 325:	45 31 ed             	xor    %r13d,%r13d
 328:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
 32f:	00 
 330:	48 8d 45 ff          	lea    -0x1(%rbp),%rax
 334:	49 39 c5             	cmp    %rax,%r13
 337:	75 27                	jne    360 <main+0x360>
 339:	48 85 ed             	test   %rbp,%rbp
 33c:	0f 88 49 03 00 00    	js     68b <main+0x68b>
 342:	48 01 ed             	add    %rbp,%rbp
 345:	4c 89 ff             	mov    %r15,%rdi
 348:	48 89 ee             	mov    %rbp,%rsi
 34b:	e8 00 00 00 00       	callq  350 <main+0x350>
			34c: R_X86_64_PLT32	realloc-0x4
 350:	48 89 c3             	mov    %rax,%rbx
 353:	48 85 c0             	test   %rax,%rax
 356:	75 0b                	jne    363 <main+0x363>
 358:	e9 4a 03 00 00       	jmpq   6a7 <main+0x6a7>
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
 38a:	0f 85 df 02 00 00    	jne    66f <main+0x66f>
 390:	4d 01 fd             	add    %r15,%r13
 393:	4c 89 e7             	mov    %r12,%rdi
 396:	e8 00 00 00 00       	callq  39b <main+0x39b>
			397: R_X86_64_PLT32	feof-0x4
 39b:	49 89 df             	mov    %rbx,%r15
 39e:	85 c0                	test   %eax,%eax
 3a0:	74 8e                	je     330 <main+0x330>
 3a2:	4c 89 e7             	mov    %r12,%rdi
 3a5:	e8 00 00 00 00       	callq  3aa <main+0x3aa>
			3a6: R_X86_64_PLT32	fclose-0x4
 3aa:	85 c0                	test   %eax,%eax
 3ac:	0f 85 79 03 00 00    	jne    72b <main+0x72b>
 3b2:	4d 85 ed             	test   %r13,%r13
 3b5:	4c 8b 7c 24 08       	mov    0x8(%rsp),%r15
 3ba:	74 10                	je     3cc <main+0x3cc>
 3bc:	31 c0                	xor    %eax,%eax
 3be:	42 80 7c 2b ff 0a    	cmpb   $0xa,-0x1(%rbx,%r13,1)
 3c4:	0f 94 c0             	sete   %al
 3c7:	49 29 c5             	sub    %rax,%r13
 3ca:	eb 03                	jmp    3cf <main+0x3cf>
 3cc:	45 31 ed             	xor    %r13d,%r13d
 3cf:	48 89 df             	mov    %rbx,%rdi
 3d2:	31 f6                	xor    %esi,%esi
 3d4:	4c 89 ea             	mov    %r13,%rdx
 3d7:	e8 00 00 00 00       	callq  3dc <main+0x3dc>
			3d8: R_X86_64_PLT32	memchr-0x4
 3dc:	48 85 c0             	test   %rax,%rax
 3df:	0f 85 5a 03 00 00    	jne    73f <main+0x73f>
 3e5:	42 c6 04 2b 00       	movb   $0x0,(%rbx,%r13,1)
 3ea:	44 89 ff             	mov    %r15d,%edi
 3ed:	44 89 f6             	mov    %r14d,%esi
 3f0:	e8 00 00 00 00       	callq  3f5 <main+0x3f5>
			3f1: R_X86_64_PLT32	bench_text-0x4
 3f5:	48 85 c0             	test   %rax,%rax
 3f8:	0f 84 65 02 00 00    	je     663 <main+0x663>
 3fe:	49 89 c7             	mov    %rax,%r15
 401:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 408 <main+0x408>
			404: R_X86_64_PC32	.L.str.12-0x4
 408:	31 ed                	xor    %ebp,%ebp
 40a:	48 89 c6             	mov    %rax,%rsi
 40d:	31 c0                	xor    %eax,%eax
 40f:	e8 00 00 00 00       	callq  414 <main+0x414>
			410: R_X86_64_PLT32	printf-0x4
 414:	41 89 c4             	mov    %eax,%r12d
 417:	4c 89 ff             	mov    %r15,%rdi
 41a:	e8 00 00 00 00       	callq  41f <main+0x41f>
			41b: R_X86_64_PLT32	free-0x4
 41f:	45 85 e4             	test   %r12d,%r12d
 422:	0f 88 b3 02 00 00    	js     6db <main+0x6db>
 428:	83 3c 24 00          	cmpl   $0x0,(%rsp)
 42c:	74 59                	je     487 <main+0x487>
 42e:	48 8b 44 24 40       	mov    0x40(%rsp),%rax
 433:	8d 04 80             	lea    (%rax,%rax,4),%eax
 436:	48 8b 4c 24 38       	mov    0x38(%rsp),%rcx
 43b:	44 8d 24 41          	lea    (%rcx,%rax,2),%r12d
 43f:	41 83 c4 d0          	add    $0xffffffd0,%r12d
 443:	31 ed                	xor    %ebp,%ebp
 445:	66 66 2e 0f 1f 84 00 	data16 nopw %cs:0x0(%rax,%rax,1)
 44c:	00 00 00 00 
 450:	48 8b 7c 24 08       	mov    0x8(%rsp),%rdi
 455:	44 89 f6             	mov    %r14d,%esi
 458:	e8 00 00 00 00       	callq  45d <main+0x45d>
			459: R_X86_64_PLT32	bench_text-0x4
 45d:	48 85 c0             	test   %rax,%rax
 460:	0f 84 fd 01 00 00    	je     663 <main+0x663>
 466:	49 89 c7             	mov    %rax,%r15
 469:	48 89 c7             	mov    %rax,%rdi
 46c:	48 89 de             	mov    %rbx,%rsi
 46f:	e8 00 00 00 00       	callq  474 <main+0x474>
			470: R_X86_64_PLT32	strcmp-0x4
 474:	83 f8 01             	cmp    $0x1,%eax
 477:	83 d5 00             	adc    $0x0,%ebp
 47a:	4c 89 ff             	mov    %r15,%rdi
 47d:	e8 00 00 00 00       	callq  482 <main+0x482>
			47e: R_X86_64_PLT32	free-0x4
 482:	41 ff cc             	dec    %r12d
 485:	75 c9                	jne    450 <main+0x450>
 487:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 48e <main+0x48e>
			48a: R_X86_64_PC32	.L.str.2-0x4
 48e:	89 ee                	mov    %ebp,%esi
 490:	31 c0                	xor    %eax,%eax
 492:	e8 00 00 00 00       	callq  497 <main+0x497>
			493: R_X86_64_PLT32	printf-0x4
 497:	85 c0                	test   %eax,%eax
 499:	0f 88 b4 02 00 00    	js     753 <main+0x753>
 49f:	48 8d 74 24 18       	lea    0x18(%rsp),%rsi
 4a4:	bf 01 00 00 00       	mov    $0x1,%edi
 4a9:	e8 00 00 00 00       	callq  4ae <main+0x4ae>
			4aa: R_X86_64_PLT32	clock_gettime-0x4
 4ae:	85 c0                	test   %eax,%eax
 4b0:	0f 85 31 02 00 00    	jne    6e7 <main+0x6e7>
 4b6:	48 8b 74 24 18       	mov    0x18(%rsp),%rsi
 4bb:	48 85 f6             	test   %rsi,%rsi
 4be:	8b 4c 24 14          	mov    0x14(%rsp),%ecx
 4c2:	0f 88 2b 02 00 00    	js     6f3 <main+0x6f3>
 4c8:	48 8b 44 24 20       	mov    0x20(%rsp),%rax
 4cd:	48 3d 00 ca 9a 3b    	cmp    $0x3b9aca00,%rax
 4d3:	0f 83 1a 02 00 00    	jae    6f3 <main+0x6f3>
 4d9:	4c 69 e8 83 de 1b 43 	imul   $0x431bde83,%rax,%r13
 4e0:	49 c1 ed 32          	shr    $0x32,%r13
 4e4:	4c 89 e8             	mov    %r13,%rax
 4e7:	48 f7 d0             	not    %rax
 4ea:	48 c1 e8 03          	shr    $0x3,%rax
 4ee:	48 ba cf f7 53 e3 a5 	movabs $0x20c49ba5e353f7cf,%rdx
 4f5:	9b c4 20 
 4f8:	48 f7 e2             	mul    %rdx
 4fb:	48 c1 ea 04          	shr    $0x4,%rdx
 4ff:	48 39 d6             	cmp    %rdx,%rsi
 502:	0f 87 f7 01 00 00    	ja     6ff <main+0x6ff>
 508:	48 89 34 24          	mov    %rsi,(%rsp)
 50c:	85 c9                	test   %ecx,%ecx
 50e:	74 59                	je     569 <main+0x569>
 510:	48 8b 44 24 30       	mov    0x30(%rsp),%rax
 515:	8d 04 80             	lea    (%rax,%rax,4),%eax
 518:	48 8b 4c 24 28       	mov    0x28(%rsp),%rcx
 51d:	44 8d 24 41          	lea    (%rcx,%rax,2),%r12d
 521:	41 83 c4 d0          	add    $0xffffffd0,%r12d
 525:	31 ed                	xor    %ebp,%ebp
 527:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
 52e:	00 00 
 530:	48 8b 7c 24 08       	mov    0x8(%rsp),%rdi
 535:	44 89 f6             	mov    %r14d,%esi
 538:	e8 00 00 00 00       	callq  53d <main+0x53d>
			539: R_X86_64_PLT32	bench_text-0x4
 53d:	48 85 c0             	test   %rax,%rax
 540:	0f 84 1d 01 00 00    	je     663 <main+0x663>
 546:	49 89 c7             	mov    %rax,%r15
 549:	48 89 c7             	mov    %rax,%rdi
 54c:	48 89 de             	mov    %rbx,%rsi
 54f:	e8 00 00 00 00       	callq  554 <main+0x554>
			550: R_X86_64_PLT32	strcmp-0x4
 554:	83 f8 01             	cmp    $0x1,%eax
 557:	83 d5 00             	adc    $0x0,%ebp
 55a:	4c 89 ff             	mov    %r15,%rdi
 55d:	e8 00 00 00 00       	callq  562 <main+0x562>
			55e: R_X86_64_PLT32	free-0x4
 562:	41 ff cc             	dec    %r12d
 565:	75 c9                	jne    530 <main+0x530>
 567:	eb 02                	jmp    56b <main+0x56b>
 569:	31 ed                	xor    %ebp,%ebp
 56b:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 572 <main+0x572>
			56e: R_X86_64_PC32	.L.str.2-0x4
 572:	89 ee                	mov    %ebp,%esi
 574:	31 c0                	xor    %eax,%eax
 576:	e8 00 00 00 00       	callq  57b <main+0x57b>
			577: R_X86_64_PLT32	printf-0x4
 57b:	85 c0                	test   %eax,%eax
 57d:	0f 88 dc 01 00 00    	js     75f <main+0x75f>
 583:	48 8d 74 24 18       	lea    0x18(%rsp),%rsi
 588:	bf 01 00 00 00       	mov    $0x1,%edi
 58d:	e8 00 00 00 00       	callq  592 <main+0x592>
			58e: R_X86_64_PLT32	clock_gettime-0x4
 592:	85 c0                	test   %eax,%eax
 594:	0f 85 4d 01 00 00    	jne    6e7 <main+0x6e7>
 59a:	48 8b 4c 24 18       	mov    0x18(%rsp),%rcx
 59f:	48 85 c9             	test   %rcx,%rcx
 5a2:	0f 88 4b 01 00 00    	js     6f3 <main+0x6f3>
 5a8:	48 8b 44 24 20       	mov    0x20(%rsp),%rax
 5ad:	48 3d 00 ca 9a 3b    	cmp    $0x3b9aca00,%rax
 5b3:	0f 83 3a 01 00 00    	jae    6f3 <main+0x6f3>
 5b9:	48 69 f8 83 de 1b 43 	imul   $0x431bde83,%rax,%rdi
 5c0:	48 c1 ef 32          	shr    $0x32,%rdi
 5c4:	48 89 f8             	mov    %rdi,%rax
 5c7:	48 f7 d0             	not    %rax
 5ca:	48 c1 e8 03          	shr    $0x3,%rax
 5ce:	48 ba cf f7 53 e3 a5 	movabs $0x20c49ba5e353f7cf,%rdx
 5d5:	9b c4 20 
 5d8:	48 f7 e2             	mul    %rdx
 5db:	48 c1 ea 04          	shr    $0x4,%rdx
 5df:	48 39 d1             	cmp    %rdx,%rcx
 5e2:	0f 87 17 01 00 00    	ja     6ff <main+0x6ff>
 5e8:	48 69 04 24 e8 03 00 	imul   $0x3e8,(%rsp),%rax
 5ef:	00 
 5f0:	4c 01 e8             	add    %r13,%rax
 5f3:	48 69 f1 e8 03 00 00 	imul   $0x3e8,%rcx,%rsi
 5fa:	48 01 fe             	add    %rdi,%rsi
 5fd:	48 29 c6             	sub    %rax,%rsi
 600:	0f 82 65 01 00 00    	jb     76b <main+0x76b>
 606:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 60d <main+0x60d>
			609: R_X86_64_PC32	.L.str.6-0x4
 60d:	31 c0                	xor    %eax,%eax
 60f:	e8 00 00 00 00       	callq  614 <main+0x614>
			610: R_X86_64_PLT32	printf-0x4
 614:	85 c0                	test   %eax,%eax
 616:	0f 88 5b 01 00 00    	js     777 <main+0x777>
 61c:	48 89 df             	mov    %rbx,%rdi
 61f:	e8 00 00 00 00       	callq  624 <main+0x624>
			620: R_X86_64_PLT32	free-0x4
 624:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 62b <main+0x62b>
			627: R_X86_64_REX_GOTPCRELX	stdout-0x4
 62b:	48 8b 38             	mov    (%rax),%rdi
 62e:	e8 00 00 00 00       	callq  633 <main+0x633>
			62f: R_X86_64_PLT32	fclose-0x4
 633:	31 c9                	xor    %ecx,%ecx
 635:	85 c0                	test   %eax,%eax
 637:	0f 95 c1             	setne  %cl
 63a:	89 c8                	mov    %ecx,%eax
 63c:	48 83 c4 48          	add    $0x48,%rsp
 640:	5b                   	pop    %rbx
 641:	41 5c                	pop    %r12
 643:	41 5d                	pop    %r13
 645:	41 5e                	pop    %r14
 647:	41 5f                	pop    %r15
 649:	5d                   	pop    %rbp
 64a:	c3                   	retq   
 64b:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 652 <main+0x652>
			64e: R_X86_64_PC32	.L.str.9-0x4
 652:	e8 00 00 00 00       	callq  657 <main+0x657>
			653: R_X86_64_PLT32	.text.unlikely.-0x4
 657:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 65e <main+0x65e>
			65a: R_X86_64_PC32	.L.str.10-0x4
 65e:	e8 00 00 00 00       	callq  663 <main+0x663>
			65f: R_X86_64_PLT32	.text.unlikely.-0x4
 663:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 66a <main+0x66a>
			666: R_X86_64_PC32	.L.str.11-0x4
 66a:	e8 00 00 00 00       	callq  66f <main+0x66f>
			66b: R_X86_64_PLT32	.text.unlikely.-0x4
 66f:	48 89 df             	mov    %rbx,%rdi
 672:	e8 00 00 00 00       	callq  677 <main+0x677>
			673: R_X86_64_PLT32	free-0x4
 677:	4c 89 e7             	mov    %r12,%rdi
 67a:	e8 00 00 00 00       	callq  67f <main+0x67f>
			67b: R_X86_64_PLT32	fclose-0x4
 67f:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 686 <main+0x686>
			682: R_X86_64_PC32	.L.str.20-0x4
 686:	e8 00 00 00 00       	callq  68b <main+0x68b>
			687: R_X86_64_PLT32	.text.unlikely.-0x4
 68b:	4c 89 ff             	mov    %r15,%rdi
 68e:	e8 00 00 00 00       	callq  693 <main+0x693>
			68f: R_X86_64_PLT32	free-0x4
 693:	4c 89 e7             	mov    %r12,%rdi
 696:	e8 00 00 00 00       	callq  69b <main+0x69b>
			697: R_X86_64_PLT32	fclose-0x4
 69b:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 6a2 <main+0x6a2>
			69e: R_X86_64_PC32	.L.str.18-0x4
 6a2:	e8 00 00 00 00       	callq  6a7 <main+0x6a7>
			6a3: R_X86_64_PLT32	.text.unlikely.-0x4
 6a7:	4c 89 ff             	mov    %r15,%rdi
 6aa:	e8 00 00 00 00       	callq  6af <main+0x6af>
			6ab: R_X86_64_PLT32	free-0x4
 6af:	4c 89 e7             	mov    %r12,%rdi
 6b2:	e8 00 00 00 00       	callq  6b7 <main+0x6b7>
			6b3: R_X86_64_PLT32	fclose-0x4
 6b7:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 6be <main+0x6be>
			6ba: R_X86_64_PC32	.L.str.19-0x4
 6be:	e8 00 00 00 00       	callq  6c3 <main+0x6c3>
			6bf: R_X86_64_PLT32	.text.unlikely.-0x4
 6c3:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 6ca <main+0x6ca>
			6c6: R_X86_64_PC32	.L.str.8-0x4
 6ca:	e8 00 00 00 00       	callq  6cf <main+0x6cf>
			6cb: R_X86_64_PLT32	.text.unlikely.-0x4
 6cf:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 6d6 <main+0x6d6>
			6d2: R_X86_64_PC32	.L.str.1-0x4
 6d6:	e8 00 00 00 00       	callq  6db <main+0x6db>
			6d7: R_X86_64_PLT32	.text.unlikely.-0x4
 6db:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 6e2 <main+0x6e2>
			6de: R_X86_64_PC32	.L.str.13-0x4
 6e2:	e8 00 00 00 00       	callq  6e7 <main+0x6e7>
			6e3: R_X86_64_PLT32	.text.unlikely.-0x4
 6e7:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 6ee <main+0x6ee>
			6ea: R_X86_64_PC32	.L.str.23-0x4
 6ee:	e8 00 00 00 00       	callq  6f3 <main+0x6f3>
			6ef: R_X86_64_PLT32	.text.unlikely.-0x4
 6f3:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 6fa <main+0x6fa>
			6f6: R_X86_64_PC32	.L.str.24-0x4
 6fa:	e8 00 00 00 00       	callq  6ff <main+0x6ff>
			6fb: R_X86_64_PLT32	.text.unlikely.-0x4
 6ff:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 706 <main+0x706>
			702: R_X86_64_PC32	.L.str.25-0x4
 706:	e8 00 00 00 00       	callq  70b <main+0x70b>
			707: R_X86_64_PLT32	.text.unlikely.-0x4
 70b:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 712 <main+0x712>
			70e: R_X86_64_PC32	.L.str.16-0x4
 712:	e8 00 00 00 00       	callq  717 <main+0x717>
			713: R_X86_64_PLT32	.text.unlikely.-0x4
 717:	4c 89 e7             	mov    %r12,%rdi
 71a:	e8 00 00 00 00       	callq  71f <main+0x71f>
			71b: R_X86_64_PLT32	fclose-0x4
 71f:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 726 <main+0x726>
			722: R_X86_64_PC32	.L.str.17-0x4
 726:	e8 00 00 00 00       	callq  72b <main+0x72b>
			727: R_X86_64_PLT32	.text.unlikely.-0x4
 72b:	48 89 df             	mov    %rbx,%rdi
 72e:	e8 00 00 00 00       	callq  733 <main+0x733>
			72f: R_X86_64_PLT32	free-0x4
 733:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 73a <main+0x73a>
			736: R_X86_64_PC32	.L.str.21-0x4
 73a:	e8 00 00 00 00       	callq  73f <main+0x73f>
			73b: R_X86_64_PLT32	.text.unlikely.-0x4
 73f:	48 89 df             	mov    %rbx,%rdi
 742:	e8 00 00 00 00       	callq  747 <main+0x747>
			743: R_X86_64_PLT32	free-0x4
 747:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 74e <main+0x74e>
			74a: R_X86_64_PC32	.L.str.22-0x4
 74e:	e8 00 00 00 00       	callq  753 <main+0x753>
			74f: R_X86_64_PLT32	.text.unlikely.-0x4
 753:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 75a <main+0x75a>
			756: R_X86_64_PC32	.L.str.3-0x4
 75a:	e8 00 00 00 00       	callq  75f <main+0x75f>
			75b: R_X86_64_PLT32	.text.unlikely.-0x4
 75f:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 766 <main+0x766>
			762: R_X86_64_PC32	.L.str.4-0x4
 766:	e8 00 00 00 00       	callq  76b <main+0x76b>
			767: R_X86_64_PLT32	.text.unlikely.-0x4
 76b:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 772 <main+0x772>
			76e: R_X86_64_PC32	.L.str.5-0x4
 772:	e8 00 00 00 00       	callq  777 <main+0x777>
			773: R_X86_64_PLT32	.text.unlikely.-0x4
 777:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 77e <main+0x77e>
			77a: R_X86_64_PC32	.L.str.7-0x4
 77e:	e8 00 00 00 00       	callq  783 <.L.str.25+0x4e4>
			77f: R_X86_64_PLT32	.text.unlikely.-0x4

Disassembly of section .text.unlikely.:

0000000000000000 <fail>:
   0:	50                   	push   %rax
   1:	48 89 fa             	mov    %rdi,%rdx
   4:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # b <fail+0xb>
			7: R_X86_64_REX_GOTPCRELX	stderr-0x4
   b:	48 8b 38             	mov    (%rax),%rdi
   e:	48 8d 35 00 00 00 00 	lea    0x0(%rip),%rsi        # 15 <fail+0x15>
			11: R_X86_64_PC32	.L.str.14-0x4
  15:	31 c0                	xor    %eax,%eax
  17:	e8 00 00 00 00       	callq  1c <fail+0x1c>
			18: R_X86_64_PLT32	fprintf-0x4
  1c:	bf 01 00 00 00       	mov    $0x1,%edi
  21:	e8 00 00 00 00       	callq  26 <.L.str.1+0x1e>
			22: R_X86_64_PLT32	exit-0x4
