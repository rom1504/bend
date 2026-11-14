
/home/ai/bend2/build/publish/bend/selfhost/build/phase184/bend-products01/tree-bitonic/bend-c/program:     file format elf64-x86-64


Disassembly of section .text:

000000000000dfa0 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_>:
    dfa0:	push   rbp
    dfa1:	sub    rsp,0x20
    dfa5:	mov    ebp,r15d
    dfa8:	movabs r11,0xffffffff80
    dfb2:	mov    rax,rsi
    dfb5:	shr    rax,0x28
    dfb9:	movzx  eax,ax
    dfbc:	cmp    eax,0xa4
    dfc1:	je     dffb <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x5b>
    dfc3:	cmp    eax,0xa5
    dfc8:	jne    e994 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x9f4>
    dfce:	lea    rbx,[r11+0x7f]
    dfd2:	mov    rax,rsi
    dfd5:	and    rax,rbx
    dfd8:	test   rsi,rsi
    dfdb:	js     e043 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0xa3>
    dfdd:	mov    r9,QWORD PTR [r12+rax*8]
    dfe1:	mov    rdi,QWORD PTR [r12+rax*8+0x8]
    dfe6:	mov    rcx,rax
    dfe9:	cmp    rcx,0x3108180
    dff0:	jae    e0b7 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x117>
    dff6:	jmp    e0ee <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x14e>
    dffb:	movabs r9,0x7f00000000000000
    e005:	mov    rax,rsi
    e008:	and    rax,r9
    e00b:	movabs r10,0x100000000000000
    e015:	cmp    rax,r10
    e018:	je     e2e6 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x346>
    e01e:	lea    rax,[r11+0x7f]
    e022:	and    rax,rsi
    e025:	test   rsi,rsi
    e028:	js     e248 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x2a8>
    e02e:	mov    rcx,rax
    e031:	cmp    rcx,0x3108180
    e038:	jae    e2b0 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x310>
    e03e:	jmp    e2e6 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x346>
    e043:	mov    ecx,DWORD PTR [r12+rax*8+0x4]
    e048:	mov    edi,DWORD PTR [r12+rax*8]
    e04c:	mov    r8d,edi
    e04f:	and    r8d,0xffffff
    e056:	cmp    r8d,0x1
    e05a:	jne    e75e <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x7be>
    e060:	mov    esi,DWORD PTR [r12+rax*8]
    e064:	shl    rcx,0x20
    e068:	or     rcx,rdi
    e06b:	shr    rcx,0x18
    e06f:	mov    r9,QWORD PTR [r12+rcx*8]
    e073:	mov    rdi,QWORD PTR [r12+rcx*8+0x8]
    e078:	mov    rsi,QWORD PTR [r13+0x0]
    e07c:	mov    QWORD PTR [r12+rax*8],rsi
    e080:	mov    QWORD PTR [r13+0x0],rax
    e084:	mov    rax,QWORD PTR [r13+0x100]
    e08b:	inc    rax
    e08e:	mov    QWORD PTR [r13+0x100],rax
    e095:	cmp    BYTE PTR [rip+0x10b7f4],0x1        # 119890 <KEEP_WORDS>
    e09c:	jne    e79d <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x7fd>
    e0a2:	cmp    rax,0x8000
    e0a8:	jae    e79d <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x7fd>
    e0ae:	cmp    rcx,0x3108180
    e0b5:	jb     e0ee <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x14e>
    e0b7:	mov    rax,QWORD PTR [r13+0x8]
    e0bb:	mov    QWORD PTR [r12+rcx*8],rax
    e0bf:	mov    QWORD PTR [r13+0x8],rcx
    e0c3:	mov    rax,QWORD PTR [r13+0x108]
    e0ca:	add    rax,0x2
    e0ce:	mov    QWORD PTR [r13+0x108],rax
    e0d5:	cmp    BYTE PTR [rip+0x10b7b4],0x1        # 119890 <KEEP_WORDS>
    e0dc:	jne    e737 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x797>
    e0e2:	cmp    rax,0x8000
    e0e8:	jae    e737 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x797>
    e0ee:	mov    rax,rdx
    e0f1:	shr    rax,0x28
    e0f5:	movzx  r15d,ax
    e0f9:	cmp    r15,0xa5
    e100:	jne    e132 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x192>
    e102:	mov    r15,r14
    e105:	and    rbx,rdx
    e108:	mov    r14d,ebp
    e10b:	test   rdx,rdx
    e10e:	js     e36b <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x3cb>
    e114:	mov    rbp,QWORD PTR [r12+rbx*8]
    e118:	mov    r10,QWORD PTR [r12+rbx*8+0x8]
    e11d:	mov    rcx,rbx
    e120:	cmp    rcx,0x3108180
    e127:	jae    e3dc <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x43c>
    e12d:	jmp    e413 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x473>
    e132:	movabs rsi,0x7e00000000000000
    e13c:	test   r9,rsi
    e13f:	sete   al
    e142:	cmp    r9,0xffffffffffffffff
    e146:	sete   cl
    e149:	or     cl,al
    e14b:	mov    rax,r9
    e14e:	and    rax,r11
    e151:	cmp    rax,0x3108180
    e157:	setb   al
    e15a:	or     al,cl
    e15c:	mov    QWORD PTR [rsp+0x10],r14
    e161:	mov    DWORD PTR [rsp+0xc],ebp
    e165:	jne    e19e <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x1fe>
    e167:	mov    QWORD PTR [rsp+0x18],rdi
    e16c:	mov    rdi,r12
    e16f:	mov    rsi,r13
    e172:	mov    rbp,rdx
    e175:	mov    rdx,r9
    e178:	mov    r14,r11
    e17b:	call   7810 <term_drop>
    e180:	movabs rsi,0x7e00000000000000
    e18a:	mov    rdi,QWORD PTR [rsp+0x18]
    e18f:	mov    r11,r14
    e192:	mov    rdx,rbp
    e195:	mov    ebp,DWORD PTR [rsp+0xc]
    e199:	mov    r14,QWORD PTR [rsp+0x10]
    e19e:	test   rdi,rsi
    e1a1:	sete   al
    e1a4:	cmp    rdi,0xffffffffffffffff
    e1a8:	sete   cl
    e1ab:	or     cl,al
    e1ad:	mov    rax,rdi
    e1b0:	and    rax,r11
    e1b3:	cmp    rax,0x3108180
    e1b9:	setb   al
    e1bc:	or     al,cl
    e1be:	jne    e1f0 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x250>
    e1c0:	mov    rax,rdi
    e1c3:	mov    rdi,r12
    e1c6:	mov    rsi,r13
    e1c9:	mov    rbp,rdx
    e1cc:	mov    rdx,rax
    e1cf:	mov    r14,r11
    e1d2:	call   7810 <term_drop>
    e1d7:	movabs rsi,0x7e00000000000000
    e1e1:	mov    r11,r14
    e1e4:	mov    rdx,rbp
    e1e7:	mov    ebp,DWORD PTR [rsp+0xc]
    e1eb:	mov    r14,QWORD PTR [rsp+0x10]
    e1f0:	cmp    r15d,0xa4
    e1f7:	jne    ea0e <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0xa6e>
    e1fd:	movabs rsi,0x100a40000000000
    e207:	movabs rax,0x7f00000000000000
    e211:	and    rax,rdx
    e214:	movabs rcx,0x100000000000000
    e21e:	cmp    rax,rcx
    e221:	je     e6b8 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x718>
    e227:	and    rbx,rdx
    e22a:	test   rdx,rdx
    e22d:	js     e61a <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x67a>
    e233:	mov    rcx,rbx
    e236:	cmp    rcx,0x3108180
    e23d:	jae    e682 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x6e2>
    e243:	jmp    e6b8 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x718>
    e248:	mov    ecx,DWORD PTR [r12+rax*8+0x4]
    e24d:	mov    edi,DWORD PTR [r12+rax*8]
    e251:	mov    ebx,edi
    e253:	and    ebx,0xffffff
    e259:	cmp    ebx,0x1
    e25c:	jne    e837 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x897>
    e262:	mov    esi,DWORD PTR [r12+rax*8]
    e266:	shl    rcx,0x20
    e26a:	or     rcx,rdi
    e26d:	shr    rcx,0x18
    e271:	mov    rsi,QWORD PTR [r13+0x0]
    e275:	mov    QWORD PTR [r12+rax*8],rsi
    e279:	mov    QWORD PTR [r13+0x0],rax
    e27d:	mov    rax,QWORD PTR [r13+0x100]
    e284:	inc    rax
    e287:	mov    QWORD PTR [r13+0x100],rax
    e28e:	cmp    BYTE PTR [rip+0x10b5fb],0x1        # 119890 <KEEP_WORDS>
    e295:	jne    e8f4 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x954>
    e29b:	cmp    rax,0x8000
    e2a1:	jae    e8f4 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x954>
    e2a7:	cmp    rcx,0x3108180
    e2ae:	jb     e2e6 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x346>
    e2b0:	mov    rax,QWORD PTR [r13+0x0]
    e2b4:	mov    QWORD PTR [r12+rcx*8],rax
    e2b8:	mov    QWORD PTR [r13+0x0],rcx
    e2bc:	mov    rax,QWORD PTR [r13+0x100]
    e2c3:	inc    rax
    e2c6:	mov    QWORD PTR [r13+0x100],rax
    e2cd:	cmp    BYTE PTR [rip+0x10b5bc],0x1        # 119890 <KEEP_WORDS>
    e2d4:	jne    e7ce <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x82e>
    e2da:	cmp    rax,0x8000
    e2e0:	jae    e7ce <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x82e>
    e2e6:	mov    rax,rdx
    e2e9:	shr    rax,0x28
    e2ed:	movzx  eax,ax
    e2f0:	cmp    eax,0xa4
    e2f5:	je     e330 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x390>
    e2f7:	cmp    eax,0xa5
    e2fc:	jne    e9ff <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0xa5f>
    e302:	lea    rax,[r11+0x7f]
    e306:	and    rax,rdx
    e309:	test   rdx,rdx
    e30c:	js     e4a3 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x503>
    e312:	mov    rdx,QWORD PTR [r12+rax*8]
    e316:	mov    r10,QWORD PTR [r12+rax*8+0x8]
    e31b:	mov    rcx,rax
    e31e:	cmp    rcx,0x3108180
    e325:	jae    e514 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x574>
    e32b:	jmp    e54b <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x5ab>
    e330:	movabs rsi,0x100a40000000000
    e33a:	and    r9,rdx
    e33d:	cmp    r9,r10
    e340:	je     e6b8 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x718>
    e346:	add    r11,0x7f
    e34a:	and    r11,rdx
    e34d:	test   rdx,rdx
    e350:	js     e5e3 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x643>
    e356:	mov    rcx,r11
    e359:	cmp    rcx,0x3108180
    e360:	jae    e682 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x6e2>
    e366:	jmp    e6b8 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x718>
    e36b:	mov    ecx,DWORD PTR [r12+rbx*8+0x4]
    e370:	mov    eax,DWORD PTR [r12+rbx*8]
    e374:	mov    esi,eax
    e376:	and    esi,0xffffff
    e37c:	cmp    esi,0x1
    e37f:	jne    e86a <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x8ca>
    e385:	mov    edx,DWORD PTR [r12+rbx*8]
    e389:	shl    rcx,0x20
    e38d:	or     rcx,rax
    e390:	shr    rcx,0x18
    e394:	mov    rbp,QWORD PTR [r12+rcx*8]
    e398:	mov    r10,QWORD PTR [r12+rcx*8+0x8]
    e39d:	mov    rax,QWORD PTR [r13+0x0]
    e3a1:	mov    QWORD PTR [r12+rbx*8],rax
    e3a5:	mov    QWORD PTR [r13+0x0],rbx
    e3a9:	mov    rax,QWORD PTR [r13+0x100]
    e3b0:	inc    rax
    e3b3:	mov    QWORD PTR [r13+0x100],rax
    e3ba:	cmp    BYTE PTR [rip+0x10b4cf],0x1        # 119890 <KEEP_WORDS>
    e3c1:	jne    e91f <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x97f>
    e3c7:	cmp    rax,0x8000
    e3cd:	jae    e91f <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x97f>
    e3d3:	cmp    rcx,0x3108180
    e3da:	jb     e413 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x473>
    e3dc:	mov    rax,QWORD PTR [r13+0x8]
    e3e0:	mov    QWORD PTR [r12+rcx*8],rax
    e3e4:	mov    QWORD PTR [r13+0x8],rcx
    e3e8:	mov    rax,QWORD PTR [r13+0x108]
    e3ef:	add    rax,0x2
    e3f3:	mov    QWORD PTR [r13+0x108],rax
    e3fa:	cmp    BYTE PTR [rip+0x10b48f],0x1        # 119890 <KEEP_WORDS>
    e401:	jne    e7ec <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x84c>
    e407:	cmp    rax,0x8000
    e40d:	jae    e7ec <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x84c>
    e413:	mov    rcx,QWORD PTR [r13+0x8]
    e417:	test   rcx,rcx
    e41a:	je     e6da <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x73a>
    e420:	mov    rax,QWORD PTR [r12+rcx*8]
    e424:	mov    QWORD PTR [r13+0x8],rax
    e428:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
    e430:	movabs rsi,0x200a50000000000
    e43a:	mov    QWORD PTR [r12+rcx*8],r9
    e43e:	mov    QWORD PTR [r12+rcx*8+0x8],rbp
    e443:	mov    r8,QWORD PTR [r13+0x8]
    e447:	test   r8,r8
    e44a:	je     e6f8 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x758>
    e450:	mov    rax,QWORD PTR [r12+r8*8]
    e454:	mov    QWORD PTR [r13+0x8],rax
    e458:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
    e460:	mov    ebp,r14d
    e463:	or     rcx,rsi
    e466:	mov    QWORD PTR [r12+r8*8],rdi
    e46a:	mov    QWORD PTR [r12+r8*8+0x8],r10
    e46f:	or     r8,rsi
    e472:	mov    rax,QWORD PTR [r13+0x8]
    e476:	test   rax,rax
    e479:	mov    r14,r15
    e47c:	je     e71c <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x77c>
    e482:	mov    rdx,QWORD PTR [r12+rax*8]
    e486:	mov    QWORD PTR [r13+0x8],rdx
    e48a:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
    e492:	mov    QWORD PTR [r12+rax*8],rcx
    e496:	mov    QWORD PTR [r12+rax*8+0x8],r8
    e49b:	or     rsi,rax
    e49e:	jmp    e6b8 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x718>
    e4a3:	mov    ecx,DWORD PTR [r12+rax*8+0x4]
    e4a8:	mov    esi,DWORD PTR [r12+rax*8]
    e4ac:	mov    edi,esi
    e4ae:	and    edi,0xffffff
    e4b4:	cmp    edi,0x1
    e4b7:	jne    e89a <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x8fa>
    e4bd:	mov    edx,DWORD PTR [r12+rax*8]
    e4c1:	shl    rcx,0x20
    e4c5:	or     rcx,rsi
    e4c8:	shr    rcx,0x18
    e4cc:	mov    rdx,QWORD PTR [r12+rcx*8]
    e4d0:	mov    r10,QWORD PTR [r12+rcx*8+0x8]
    e4d5:	mov    rsi,QWORD PTR [r13+0x0]
    e4d9:	mov    QWORD PTR [r12+rax*8],rsi
    e4dd:	mov    QWORD PTR [r13+0x0],rax
    e4e1:	mov    rax,QWORD PTR [r13+0x100]
    e4e8:	inc    rax
    e4eb:	mov    QWORD PTR [r13+0x100],rax
    e4f2:	cmp    BYTE PTR [rip+0x10b397],0x1        # 119890 <KEEP_WORDS>
    e4f9:	jne    e944 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x9a4>
    e4ff:	cmp    rax,0x8000
    e505:	jae    e944 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x9a4>
    e50b:	cmp    rcx,0x3108180
    e512:	jb     e54b <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x5ab>
    e514:	mov    rax,QWORD PTR [r13+0x8]
    e518:	mov    QWORD PTR [r12+rcx*8],rax
    e51c:	mov    QWORD PTR [r13+0x8],rcx
    e520:	mov    rax,QWORD PTR [r13+0x108]
    e527:	add    rax,0x2
    e52b:	mov    QWORD PTR [r13+0x108],rax
    e532:	cmp    BYTE PTR [rip+0x10b357],0x1        # 119890 <KEEP_WORDS>
    e539:	jne    e804 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x864>
    e53f:	cmp    rax,0x8000
    e545:	jae    e804 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x864>
    e54b:	movabs rdi,0x7e00000000000000
    e555:	test   rdx,rdi
    e558:	sete   al
    e55b:	cmp    rdx,0xffffffffffffffff
    e55f:	sete   cl
    e562:	or     cl,al
    e564:	mov    rax,rdx
    e567:	and    rax,r11
    e56a:	cmp    rax,0x3108180
    e570:	setb   al
    e573:	or     al,cl
    e575:	jne    e59c <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x5fc>
    e577:	mov    rdi,r12
    e57a:	mov    rsi,r13
    e57d:	mov    ebx,ebp
    e57f:	mov    rbp,r11
    e582:	mov    r15,r10
    e585:	call   7810 <term_drop>
    e58a:	movabs rdi,0x7e00000000000000
    e594:	mov    r10,r15
    e597:	mov    r11,rbp
    e59a:	mov    ebp,ebx
    e59c:	movabs rsi,0x100a40000000000
    e5a6:	test   r10,rdi
    e5a9:	sete   al
    e5ac:	cmp    r10,0xffffffffffffffff
    e5b0:	sete   cl
    e5b3:	or     cl,al
    e5b5:	and    r11,r10
    e5b8:	cmp    r11,0x3108180
    e5bf:	setb   al
    e5c2:	or     al,cl
    e5c4:	jne    e6b8 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x718>
    e5ca:	mov    rdi,r12
    e5cd:	mov    r15,rsi
    e5d0:	mov    rsi,r13
    e5d3:	mov    rdx,r10
    e5d6:	call   7810 <term_drop>
    e5db:	mov    rsi,r15
    e5de:	jmp    e6b8 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x718>
    e5e3:	mov    ecx,DWORD PTR [r12+r11*8+0x4]
    e5e8:	mov    eax,DWORD PTR [r12+r11*8]
    e5ec:	mov    edi,eax
    e5ee:	and    edi,0xffffff
    e5f4:	cmp    edi,0x1
    e5f7:	jne    e8cd <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x92d>
    e5fd:	mov    edx,DWORD PTR [r12+r11*8]
    e601:	shl    rcx,0x20
    e605:	or     rcx,rax
    e608:	shr    rcx,0x18
    e60c:	mov    rax,QWORD PTR [r13+0x0]
    e610:	mov    QWORD PTR [r12+r11*8],rax
    e614:	mov    QWORD PTR [r13+0x0],r11
    e618:	jmp    e64f <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x6af>
    e61a:	mov    ecx,DWORD PTR [r12+rbx*8+0x4]
    e61f:	mov    eax,DWORD PTR [r12+rbx*8]
    e623:	mov    edi,eax
    e625:	and    edi,0xffffff
    e62b:	cmp    edi,0x1
    e62e:	jne    e8cd <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x92d>
    e634:	mov    edx,DWORD PTR [r12+rbx*8]
    e638:	shl    rcx,0x20
    e63c:	or     rcx,rax
    e63f:	shr    rcx,0x18
    e643:	mov    rax,QWORD PTR [r13+0x0]
    e647:	mov    QWORD PTR [r12+rbx*8],rax
    e64b:	mov    QWORD PTR [r13+0x0],rbx
    e64f:	mov    rax,QWORD PTR [r13+0x100]
    e656:	inc    rax
    e659:	mov    QWORD PTR [r13+0x100],rax
    e660:	cmp    BYTE PTR [rip+0x10b229],0x1        # 119890 <KEEP_WORDS>
    e667:	jne    e96f <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x9cf>
    e66d:	cmp    rax,0x8000
    e673:	jae    e96f <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x9cf>
    e679:	cmp    rcx,0x3108180
    e680:	jb     e6b8 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x718>
    e682:	mov    rax,QWORD PTR [r13+0x0]
    e686:	mov    QWORD PTR [r12+rcx*8],rax
    e68a:	mov    QWORD PTR [r13+0x0],rcx
    e68e:	mov    rax,QWORD PTR [r13+0x100]
    e695:	inc    rax
    e698:	mov    QWORD PTR [r13+0x100],rax
    e69f:	cmp    BYTE PTR [rip+0x10b1ea],0x1        # 119890 <KEEP_WORDS>
    e6a6:	jne    e822 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x882>
    e6ac:	cmp    rax,0x8000
    e6b2:	jae    e822 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x882>
    e6b8:	mov    eax,DWORD PTR [r14-0x8]
    e6bc:	add    r14,0xfffffffffffffff8
    e6c0:	lea    rcx,[rip+0x9749]        # 17e10 <wl_tab>
    e6c7:	mov    rax,QWORD PTR [rcx+rax*8]
    e6cb:	mov    r15d,ebp
    e6ce:	mov    edi,0x1
    e6d3:	add    rsp,0x20
    e6d7:	pop    rbp
    e6d8:	jmp    rax
    e6da:	mov    rcx,rdi
    e6dd:	mov    rdi,r12
    e6e0:	mov    rsi,r13
    e6e3:	mov    edx,0x1
    e6e8:	call   159a8 <heap_alloc_miss>
    e6ed:	mov    rdi,rcx
    e6f0:	mov    rcx,rax
    e6f3:	jmp    e430 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x490>
    e6f8:	mov    r9,rdi
    e6fb:	mov    rdi,r12
    e6fe:	mov    r8,rsi
    e701:	mov    rsi,r13
    e704:	mov    edx,0x1
    e709:	call   159a8 <heap_alloc_miss>
    e70e:	mov    rdi,r9
    e711:	mov    rsi,r8
    e714:	mov    r8,rax
    e717:	jmp    e460 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x4c0>
    e71c:	mov    rdi,r12
    e71f:	mov    r9,rsi
    e722:	mov    rsi,r13
    e725:	mov    edx,0x1
    e72a:	call   159a8 <heap_alloc_miss>
    e72f:	mov    rsi,r9
    e732:	jmp    e492 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x4f2>
    e737:	mov    r8,rdi
    e73a:	mov    rdi,r12
    e73d:	mov    rsi,r13
    e740:	mov    rax,rdx
    e743:	mov    edx,0x1
    e748:	mov    rcx,r11
    e74b:	call   15881 <heap_hand>
    e750:	mov    rdi,r8
    e753:	mov    r11,rcx
    e756:	mov    rdx,rax
    e759:	jmp    e0ee <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x14e>
    e75e:	shl    rcx,0x20
    e762:	or     rcx,rdi
    e765:	shr    rcx,0x18
    e769:	mov    r9,QWORD PTR [r12+rcx*8]
    e76d:	mov    r15,QWORD PTR [r12+rcx*8+0x8]
    e772:	mov    rdi,r12
    e775:	mov    rax,rsi
    e778:	mov    rsi,r13
    e77b:	mov    r10,rdx
    e77e:	mov    rdx,rax
    e781:	mov    r8d,0x2
    e787:	mov    rax,r11
    e78a:	call   15912 <span_fade>
    e78f:	mov    rdi,r15
    e792:	mov    r11,rax
    e795:	mov    rdx,r10
    e798:	jmp    e0ee <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x14e>
    e79d:	mov    r10,rdi
    e7a0:	mov    rdi,r12
    e7a3:	mov    rsi,r13
    e7a6:	mov    rax,rdx
    e7a9:	xor    edx,edx
    e7ab:	mov    r8,r11
    e7ae:	call   15881 <heap_hand>
    e7b3:	mov    rdi,r10
    e7b6:	mov    r11,r8
    e7b9:	mov    rdx,rax
    e7bc:	cmp    rcx,0x3108180
    e7c3:	jae    e0b7 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x117>
    e7c9:	jmp    e0ee <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x14e>
    e7ce:	mov    rdi,r12
    e7d1:	mov    rsi,r13
    e7d4:	mov    rax,rdx
    e7d7:	xor    edx,edx
    e7d9:	mov    rcx,r11
    e7dc:	call   15881 <heap_hand>
    e7e1:	mov    r11,rcx
    e7e4:	mov    rdx,rax
    e7e7:	jmp    e2e6 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x346>
    e7ec:	mov    rax,rdi
    e7ef:	mov    rdi,r12
    e7f2:	mov    rsi,r13
    e7f5:	mov    edx,0x1
    e7fa:	call   15881 <heap_hand>
    e7ff:	jmp    e892 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x8f2>
    e804:	mov    rdi,r12
    e807:	mov    rsi,r13
    e80a:	mov    rax,rdx
    e80d:	mov    edx,0x1
    e812:	mov    rcx,r11
    e815:	call   15881 <heap_hand>
    e81a:	mov    r11,rcx
    e81d:	jmp    e8c5 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x925>
    e822:	mov    rdi,r12
    e825:	mov    rax,rsi
    e828:	mov    rsi,r13
    e82b:	xor    edx,edx
    e82d:	call   15881 <heap_hand>
    e832:	jmp    e8ec <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x94c>
    e837:	shl    rcx,0x20
    e83b:	or     rcx,rdi
    e83e:	shr    rcx,0x18
    e842:	mov    rdi,r12
    e845:	mov    rax,rsi
    e848:	mov    rsi,r13
    e84b:	mov    rbx,rdx
    e84e:	mov    rdx,rax
    e851:	mov    r8d,0x1
    e857:	mov    rax,r11
    e85a:	call   15912 <span_fade>
    e85f:	mov    r11,rax
    e862:	mov    rdx,rbx
    e865:	jmp    e2e6 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x346>
    e86a:	shl    rcx,0x20
    e86e:	or     rcx,rax
    e871:	shr    rcx,0x18
    e875:	mov    rbp,QWORD PTR [r12+rcx*8]
    e879:	mov    r10,QWORD PTR [r12+rcx*8+0x8]
    e87e:	mov    rax,rdi
    e881:	mov    rdi,r12
    e884:	mov    rsi,r13
    e887:	mov    r8d,0x2
    e88d:	call   15912 <span_fade>
    e892:	mov    rdi,rax
    e895:	jmp    e413 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x473>
    e89a:	shl    rcx,0x20
    e89e:	or     rcx,rsi
    e8a1:	shr    rcx,0x18
    e8a5:	mov    rax,QWORD PTR [r12+rcx*8]
    e8a9:	mov    r10,QWORD PTR [r12+rcx*8+0x8]
    e8ae:	mov    rdi,r12
    e8b1:	mov    rsi,r13
    e8b4:	mov    r8d,0x2
    e8ba:	mov    r9,r11
    e8bd:	call   15912 <span_fade>
    e8c2:	mov    r11,r9
    e8c5:	mov    rdx,rax
    e8c8:	jmp    e54b <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x5ab>
    e8cd:	shl    rcx,0x20
    e8d1:	or     rcx,rax
    e8d4:	shr    rcx,0x18
    e8d8:	mov    rdi,r12
    e8db:	mov    rax,rsi
    e8de:	mov    rsi,r13
    e8e1:	mov    r8d,0x1
    e8e7:	call   15912 <span_fade>
    e8ec:	mov    rsi,rax
    e8ef:	jmp    e6b8 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x718>
    e8f4:	mov    rdi,r12
    e8f7:	mov    rsi,r13
    e8fa:	mov    rax,rdx
    e8fd:	xor    edx,edx
    e8ff:	mov    r8,r11
    e902:	call   15881 <heap_hand>
    e907:	mov    r11,r8
    e90a:	mov    rdx,rax
    e90d:	cmp    rcx,0x3108180
    e914:	jae    e2b0 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x310>
    e91a:	jmp    e2e6 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x346>
    e91f:	mov    rax,rdi
    e922:	mov    rdi,r12
    e925:	mov    rsi,r13
    e928:	xor    edx,edx
    e92a:	call   15881 <heap_hand>
    e92f:	mov    rdi,rax
    e932:	cmp    rcx,0x3108180
    e939:	jae    e3dc <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x43c>
    e93f:	jmp    e413 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x473>
    e944:	mov    rdi,r12
    e947:	mov    rsi,r13
    e94a:	mov    rax,rdx
    e94d:	xor    edx,edx
    e94f:	mov    r8,r11
    e952:	call   15881 <heap_hand>
    e957:	mov    r11,r8
    e95a:	mov    rdx,rax
    e95d:	cmp    rcx,0x3108180
    e964:	jae    e514 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x574>
    e96a:	jmp    e54b <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x5ab>
    e96f:	mov    rdi,r12
    e972:	mov    rax,rsi
    e975:	mov    rsi,r13
    e978:	xor    edx,edx
    e97a:	call   15881 <heap_hand>
    e97f:	mov    rsi,rax
    e982:	cmp    rcx,0x3108180
    e989:	jae    e682 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x6e2>
    e98f:	jmp    e6b8 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0x718>
    e994:	mov    rbx,rdx
    e997:	movabs r15,0x7e00000000000000
    e9a1:	test   rsi,r15
    e9a4:	sete   al
    e9a7:	cmp    rsi,0xffffffffffffffff
    e9ab:	sete   cl
    e9ae:	or     cl,al
    e9b0:	mov    rax,rsi
    e9b3:	mov    r14,r11
    e9b6:	and    rax,r11
    e9b9:	cmp    rax,0x3108180
    e9bf:	setb   al
    e9c2:	or     al,cl
    e9c4:	jne    e9d4 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0xa34>
    e9c6:	mov    rdx,rsi
    e9c9:	mov    rdi,r12
    e9cc:	mov    rsi,r13
    e9cf:	call   7810 <term_drop>
    e9d4:	test   rbx,r15
    e9d7:	sete   cl
    e9da:	cmp    rbx,0xffffffffffffffff
    e9de:	sete   dl
    e9e1:	or     dl,cl
    e9e3:	and    r14,rbx
    e9e6:	cmp    r14,0x3108180
    e9ed:	setb   al
    e9f0:	or     al,dl
    e9f2:	jne    ea3f <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0xa9f>
    e9f4:	mov    rdi,r12
    e9f7:	mov    rsi,r13
    e9fa:	mov    rdx,rbx
    e9fd:	jmp    ea3a <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0xa9a>
    e9ff:	movabs rax,0x7e00000000000000
    ea09:	test   rdx,rax
    ea0c:	jmp    ea11 <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0xa71>
    ea0e:	test   rdx,rsi
    ea11:	sete   al
    ea14:	cmp    rdx,0xffffffffffffffff
    ea18:	sete   cl
    ea1b:	or     cl,al
    ea1d:	mov    rax,rdx
    ea20:	and    r11,rdx
    ea23:	cmp    r11,0x3108180
    ea2a:	setb   dl
    ea2d:	or     dl,cl
    ea2f:	jne    ea3f <WL_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_+0xa9f>
    ea31:	mov    rdi,r12
    ea34:	mov    rsi,r13
    ea37:	mov    rdx,rax
    ea3a:	call   7810 <term_drop>
    ea3f:	lea    rdi,[rip+0xffffffffffff416a]        # 2bb0 <FID_RESW_T+0x350>
    ea46:	call   15820 <err_fail>

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
