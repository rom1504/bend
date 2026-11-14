
/home/ai/bend2/build/publish/bend/selfhost/build/phase184/bend-products01/test-map-set-ops/bend-c/program:     file format elf64-x86-64


Disassembly of section .text:

000000000001ff40 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_>:
   1ff40:	push   rbp
   1ff41:	sub    rsp,0x80
   1ff48:	mov    r8,rcx
   1ff4b:	mov    rbp,rsi
   1ff4e:	movabs r11,0xffff0000000000
   1ff58:	movabs rdi,0xfffffffe00
   1ff62:	mov    rax,rsi
   1ff65:	and    rax,r11
   1ff68:	movabs rcx,0x2d0000000000
   1ff72:	cmp    rax,rcx
   1ff75:	mov    QWORD PTR [rsp+0x8],r13
   1ff7a:	jne    1ffc9 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x89>
   1ff7c:	lea    r10,[rdi+0x1ff]
   1ff83:	mov    rax,rbp
   1ff86:	and    rax,r10
   1ff89:	test   rbp,rbp
   1ff8c:	mov    QWORD PTR [rsp+0x20],r14
   1ff91:	mov    QWORD PTR [rsp+0x18],rdx
   1ff96:	mov    DWORD PTR [rsp+0x14],r15d
   1ff9b:	js     20091 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x151>
   1ffa1:	mov    rcx,QWORD PTR [r12+rax*8]
   1ffa5:	mov    QWORD PTR [rsp+0x30],rcx
   1ffaa:	mov    rbx,QWORD PTR [r12+rax*8+0x8]
   1ffaf:	mov    r15,QWORD PTR [r12+rax*8+0x10]
   1ffb4:	mov    rcx,rax
   1ffb7:	cmp    rcx,0x3108200
   1ffbe:	jae    2010c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1cc>
   1ffc4:	jmp    20143 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x203>
   1ffc9:	movabs rax,0x7e00000000000000
   1ffd3:	test   r8,rax
   1ffd6:	sete   al
   1ffd9:	cmp    r8,0xffffffffffffffff
   1ffdd:	sete   cl
   1ffe0:	or     cl,al
   1ffe2:	and    rdi,r8
   1ffe5:	cmp    rdi,0x3108200
   1ffec:	setb   al
   1ffef:	or     al,cl
   1fff1:	jne    2000c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xcc>
   1fff3:	mov    rdi,r12
   1fff6:	mov    rsi,r13
   1fff9:	mov    rbx,rdx
   1fffc:	mov    rdx,r8
   1ffff:	call   e8c0 <term_drop>
   20004:	mov    rdx,rbx
   20007:	mov    r13,QWORD PTR [rsp+0x8]
   2000c:	mov    r8,QWORD PTR [r13+0x8]
   20010:	test   r8,r8
   20013:	je     205a3 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x663>
   20019:	mov    rax,QWORD PTR [r12+r8*8]
   2001d:	mov    QWORD PTR [r13+0x8],rax
   20021:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   20029:	movabs r9,0xff00000000000000
   20033:	mov    rax,rbp
   20036:	shr    rax,0x38
   2003a:	cmp    eax,0x2
   2003d:	je     205c1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x681>
   20043:	mov    QWORD PTR [r12+r8*8],rbp
   20047:	and    r9,rdx
   2004a:	movabs rax,0x200000000000000
   20054:	cmp    r9,rax
   20057:	je     205e2 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6a2>
   2005d:	mov    QWORD PTR [r12+r8*8+0x8],rdx
   20062:	movabs rsi,0x200080000000000
   2006c:	or     rsi,r8
   2006f:	mov    eax,DWORD PTR [r14-0x8]
   20073:	add    r14,0xfffffffffffffff8
   20077:	lea    rcx,[rip+0x40742]        # 607c0 <wl_tab>
   2007e:	mov    rax,QWORD PTR [rcx+rax*8]
   20082:	mov    edi,0x1
   20087:	add    rsp,0x80
   2008e:	pop    rbp
   2008f:	jmp    rax
   20091:	mov    ecx,DWORD PTR [r12+rax*8+0x4]
   20096:	mov    edx,DWORD PTR [r12+rax*8]
   2009a:	mov    esi,edx
   2009c:	and    esi,0xffffff
   200a2:	cmp    esi,0x1
   200a5:	jne    22559 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2619>
   200ab:	mov    esi,DWORD PTR [r12+rax*8]
   200af:	shl    rcx,0x20
   200b3:	or     rcx,rdx
   200b6:	shr    rcx,0x18
   200ba:	mov    rdx,QWORD PTR [r12+rcx*8]
   200be:	mov    QWORD PTR [rsp+0x30],rdx
   200c3:	mov    rbx,QWORD PTR [r12+rcx*8+0x8]
   200c8:	mov    r15,QWORD PTR [r12+rcx*8+0x10]
   200cd:	mov    rdx,QWORD PTR [r13+0x0]
   200d1:	mov    QWORD PTR [r12+rax*8],rdx
   200d5:	mov    QWORD PTR [r13+0x0],rax
   200d9:	mov    rax,QWORD PTR [r13+0x100]
   200e0:	inc    rax
   200e3:	mov    QWORD PTR [r13+0x100],rax
   200ea:	cmp    BYTE PTR [rip+0x142f9f],0x1        # 163090 <KEEP_WORDS>
   200f1:	jne    22ec0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2f80>
   200f7:	cmp    rax,0x8000
   200fd:	jae    22ec0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2f80>
   20103:	cmp    rcx,0x3108200
   2010a:	jb     20143 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x203>
   2010c:	mov    rax,QWORD PTR [r13+0x10]
   20110:	mov    QWORD PTR [r12+rcx*8],rax
   20114:	mov    QWORD PTR [r13+0x10],rcx
   20118:	mov    rax,QWORD PTR [r13+0x110]
   2011f:	add    rax,0x4
   20123:	mov    QWORD PTR [r13+0x110],rax
   2012a:	cmp    BYTE PTR [rip+0x142f5f],0x1        # 163090 <KEEP_WORDS>
   20131:	jne    224b1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2571>
   20137:	cmp    rax,0x8000
   2013d:	jae    224b1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2571>
   20143:	mov    rax,rbx
   20146:	shr    rax,0x28
   2014a:	cmp    ax,0x2d
   2014e:	je     201f9 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2b9>
   20154:	movzx  eax,ax
   20157:	cmp    eax,0x2c
   2015a:	je     201cb <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x28b>
   2015c:	cmp    eax,0x2b
   2015f:	jne    26dfd <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6ebd>
   20165:	mov    rax,r15
   20168:	shr    rax,0x28
   2016c:	cmp    ax,0x2d
   20170:	je     2056c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x62c>
   20176:	movzx  eax,ax
   20179:	cmp    eax,0x2c
   2017c:	je     2053f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5ff>
   20182:	cmp    eax,0x2b
   20185:	jne    27421 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x74e1>
   2018b:	and    r11,r8
   2018e:	movabs rax,0x80000000000
   20198:	cmp    r11,rax
   2019b:	jne    27b18 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7bd8>
   201a1:	and    r10,r8
   201a4:	test   r8,r8
   201a7:	js     222cc <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x238c>
   201ad:	mov    rdx,QWORD PTR [r12+r10*8]
   201b1:	mov    r15,QWORD PTR [r12+r10*8+0x8]
   201b6:	mov    rcx,r10
   201b9:	cmp    rcx,0x3108200
   201c0:	jae    2233d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x23fd>
   201c6:	jmp    22374 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2434>
   201cb:	mov    rax,rbx
   201ce:	and    rax,r10
   201d1:	test   rbx,rbx
   201d4:	js     20230 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2f0>
   201d6:	mov    r14,QWORD PTR [r12+rax*8]
   201da:	mov    rcx,QWORD PTR [r12+rax*8+0x8]
   201df:	mov    QWORD PTR [rsp+0x28],rcx
   201e4:	mov    rcx,rax
   201e7:	cmp    rcx,0x3108200
   201ee:	jae    202a6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x366>
   201f4:	jmp    202dd <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x39d>
   201f9:	mov    rax,rbx
   201fc:	and    rax,r10
   201ff:	test   rbx,rbx
   20202:	js     20349 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x409>
   20208:	mov    rcx,QWORD PTR [r12+rax*8]
   2020c:	mov    QWORD PTR [rsp+0x28],rcx
   20211:	mov    r9,QWORD PTR [r12+rax*8+0x8]
   20216:	mov    r14,QWORD PTR [r12+rax*8+0x10]
   2021b:	mov    rcx,rax
   2021e:	cmp    rcx,0x3108200
   20225:	jae    203cd <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x48d>
   2022b:	jmp    20404 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4c4>
   20230:	mov    ecx,DWORD PTR [r12+rax*8+0x4]
   20235:	mov    edx,DWORD PTR [r12+rax*8]
   20239:	mov    esi,edx
   2023b:	and    esi,0xffffff
   20241:	cmp    esi,0x1
   20244:	jne    23606 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x36c6>
   2024a:	mov    esi,DWORD PTR [r12+rax*8]
   2024e:	shl    rcx,0x20
   20252:	or     rcx,rdx
   20255:	shr    rcx,0x18
   20259:	mov    r14,QWORD PTR [r12+rcx*8]
   2025d:	mov    rdx,QWORD PTR [r12+rcx*8+0x8]
   20262:	mov    QWORD PTR [rsp+0x28],rdx
   20267:	mov    rdx,QWORD PTR [r13+0x0]
   2026b:	mov    QWORD PTR [r12+rax*8],rdx
   2026f:	mov    QWORD PTR [r13+0x0],rax
   20273:	mov    rax,QWORD PTR [r13+0x100]
   2027a:	inc    rax
   2027d:	mov    QWORD PTR [r13+0x100],rax
   20284:	cmp    BYTE PTR [rip+0x142e05],0x1        # 163090 <KEEP_WORDS>
   2028b:	jne    24ab3 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4b73>
   20291:	cmp    rax,0x8000
   20297:	jae    24ab3 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4b73>
   2029d:	cmp    rcx,0x3108200
   202a4:	jb     202dd <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x39d>
   202a6:	mov    rax,QWORD PTR [r13+0x8]
   202aa:	mov    QWORD PTR [r12+rcx*8],rax
   202ae:	mov    QWORD PTR [r13+0x8],rcx
   202b2:	mov    rax,QWORD PTR [r13+0x108]
   202b9:	add    rax,0x2
   202bd:	mov    QWORD PTR [r13+0x108],rax
   202c4:	cmp    BYTE PTR [rip+0x142dc5],0x1        # 163090 <KEEP_WORDS>
   202cb:	jne    235cc <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x368c>
   202d1:	cmp    rax,0x8000
   202d7:	jae    235cc <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x368c>
   202dd:	mov    rax,r15
   202e0:	shr    rax,0x28
   202e4:	cmp    ax,0x2d
   202e8:	je     2049f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x55f>
   202ee:	movzx  eax,ax
   202f1:	cmp    eax,0x2c
   202f4:	je     2046d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x52d>
   202fa:	cmp    eax,0x2b
   202fd:	jne    270d2 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7192>
   20303:	mov    rax,r8
   20306:	and    rax,r11
   20309:	movabs rbp,0x80000000000
   20313:	cmp    rax,rbp
   20316:	jne    27be3 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7ca3>
   2031c:	mov    rax,r8
   2031f:	and    rax,r10
   20322:	test   r8,r8
   20325:	js     216fe <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x17be>
   2032b:	mov    rdx,QWORD PTR [r12+rax*8]
   2032f:	mov    rbx,QWORD PTR [r12+rax*8+0x8]
   20334:	mov    rcx,rax
   20337:	cmp    rcx,0x3108200
   2033e:	jae    2176f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x182f>
   20344:	jmp    217a6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1866>
   20349:	mov    r9,r11
   2034c:	mov    ecx,DWORD PTR [r12+rax*8+0x4]
   20351:	mov    edx,DWORD PTR [r12+rax*8]
   20355:	mov    esi,edx
   20357:	and    esi,0xffffff
   2035d:	cmp    esi,0x1
   20360:	jne    2364e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x370e>
   20366:	mov    esi,DWORD PTR [r12+rax*8]
   2036a:	shl    rcx,0x20
   2036e:	or     rcx,rdx
   20371:	shr    rcx,0x18
   20375:	mov    rdx,QWORD PTR [r12+rcx*8]
   20379:	mov    QWORD PTR [rsp+0x28],rdx
   2037e:	mov    rbx,QWORD PTR [r12+rcx*8+0x8]
   20383:	mov    r14,QWORD PTR [r12+rcx*8+0x10]
   20388:	mov    rdx,QWORD PTR [r13+0x0]
   2038c:	mov    QWORD PTR [r12+rax*8],rdx
   20390:	mov    QWORD PTR [r13+0x0],rax
   20394:	mov    rax,QWORD PTR [r13+0x100]
   2039b:	inc    rax
   2039e:	mov    QWORD PTR [r13+0x100],rax
   203a5:	cmp    BYTE PTR [rip+0x142ce4],0x1        # 163090 <KEEP_WORDS>
   203ac:	jne    24ae2 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4ba2>
   203b2:	cmp    rax,0x8000
   203b8:	jae    24ae2 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4ba2>
   203be:	mov    r11,r9
   203c1:	mov    r9,rbx
   203c4:	cmp    rcx,0x3108200
   203cb:	jb     20404 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4c4>
   203cd:	mov    rax,QWORD PTR [r13+0x10]
   203d1:	mov    QWORD PTR [r12+rcx*8],rax
   203d5:	mov    QWORD PTR [r13+0x10],rcx
   203d9:	mov    rax,QWORD PTR [r13+0x110]
   203e0:	add    rax,0x4
   203e4:	mov    QWORD PTR [r13+0x110],rax
   203eb:	cmp    BYTE PTR [rip+0x142c9e],0x1        # 163090 <KEEP_WORDS>
   203f2:	jne    235e1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x36a1>
   203f8:	cmp    rax,0x8000
   203fe:	jae    235e1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x36a1>
   20404:	mov    rax,r15
   20407:	shr    rax,0x28
   2040b:	cmp    ax,0x2d
   2040f:	je     20508 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5c8>
   20415:	movzx  eax,ax
   20418:	cmp    eax,0x2c
   2041b:	je     204d6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x596>
   20421:	cmp    eax,0x2b
   20424:	jne    2725a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x731a>
   2042a:	and    r11,r8
   2042d:	movabs rax,0x80000000000
   20437:	cmp    r11,rax
   2043a:	jne    27d2d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7ded>
   20440:	mov    rax,r8
   20443:	and    rax,r10
   20446:	test   r8,r8
   20449:	js     21d8e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1e4e>
   2044f:	mov    r8,QWORD PTR [r12+rax*8]
   20453:	mov    r15,QWORD PTR [r12+rax*8+0x8]
   20458:	mov    rcx,rax
   2045b:	cmp    rcx,0x3108200
   20462:	jae    21dff <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1ebf>
   20468:	jmp    21e36 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1ef6>
   2046d:	mov    rax,r15
   20470:	and    rax,r10
   20473:	test   r15,r15
   20476:	js     205fa <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6ba>
   2047c:	mov    rsi,QWORD PTR [r12+rax*8]
   20480:	mov    rcx,QWORD PTR [r12+rax*8+0x8]
   20485:	mov    QWORD PTR [rsp+0x40],rcx
   2048a:	mov    rcx,rax
   2048d:	cmp    rcx,0x3108200
   20494:	jae    20670 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x730>
   2049a:	jmp    206a7 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x767>
   2049f:	mov    rax,r15
   204a2:	and    rax,r10
   204a5:	test   r15,r15
   204a8:	js     206ed <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7ad>
   204ae:	mov    rcx,QWORD PTR [r12+rax*8]
   204b2:	mov    QWORD PTR [rsp+0x38],rcx
   204b7:	mov    rsi,QWORD PTR [r12+rax*8+0x8]
   204bc:	mov    rbx,QWORD PTR [r12+rax*8+0x10]
   204c1:	mov    rcx,rax
   204c4:	cmp    rcx,0x3108200
   204cb:	jae    2076e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x82e>
   204d1:	jmp    207a5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x865>
   204d6:	mov    rax,r15
   204d9:	and    rax,r10
   204dc:	test   r15,r15
   204df:	js     207f5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8b5>
   204e5:	mov    rsi,QWORD PTR [r12+rax*8]
   204e9:	mov    rcx,QWORD PTR [r12+rax*8+0x8]
   204ee:	mov    QWORD PTR [rsp+0x48],rcx
   204f3:	mov    rcx,rax
   204f6:	cmp    rcx,0x3108200
   204fd:	jae    2086b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x92b>
   20503:	jmp    208a2 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x962>
   20508:	mov    rax,r15
   2050b:	and    rax,r10
   2050e:	test   r15,r15
   20511:	js     208ed <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x9ad>
   20517:	mov    rbp,QWORD PTR [r12+rax*8]
   2051b:	mov    rcx,QWORD PTR [r12+rax*8+0x8]
   20520:	mov    QWORD PTR [rsp+0x38],rcx
   20525:	mov    rsi,QWORD PTR [r12+rax*8+0x10]
   2052a:	mov    rcx,rax
   2052d:	cmp    rcx,0x3108200
   20534:	jae    20974 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xa34>
   2053a:	jmp    209ab <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xa6b>
   2053f:	mov    rax,r15
   20542:	and    rax,r10
   20545:	test   r15,r15
   20548:	js     209f5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xab5>
   2054e:	mov    rbx,QWORD PTR [r12+rax*8]
   20552:	mov    r15,QWORD PTR [r12+rax*8+0x8]
   20557:	mov    rcx,rax
   2055a:	cmp    rcx,0x3108200
   20561:	jae    20a66 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xb26>
   20567:	jmp    20a9d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xb5d>
   2056c:	mov    rax,r15
   2056f:	and    rax,r10
   20572:	test   r15,r15
   20575:	js     20ae3 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xba3>
   2057b:	mov    rsi,QWORD PTR [r12+rax*8]
   2057f:	mov    r15,QWORD PTR [r12+rax*8+0x8]
   20584:	mov    rcx,QWORD PTR [r12+rax*8+0x10]
   20589:	mov    QWORD PTR [rsp+0x28],rcx
   2058e:	mov    rcx,rax
   20591:	cmp    rcx,0x3108200
   20598:	jae    20b64 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xc24>
   2059e:	jmp    20b9b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xc5b>
   205a3:	mov    rdi,r12
   205a6:	mov    rsi,r13
   205a9:	mov    rcx,rdx
   205ac:	mov    edx,0x1
   205b1:	call   5e35b <heap_alloc_miss>
   205b6:	mov    rdx,rcx
   205b9:	mov    r8,rax
   205bc:	jmp    20029 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xe9>
   205c1:	mov    rdi,r12
   205c4:	mov    rsi,r13
   205c7:	mov    r10,rdx
   205ca:	mov    rdx,rbp
   205cd:	mov    ecx,0x1
   205d2:	call   5e661 <rfc_wrap>
   205d7:	mov    rdx,r10
   205da:	mov    rbp,rax
   205dd:	jmp    20043 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x103>
   205e2:	mov    rdi,r12
   205e5:	mov    rsi,r13
   205e8:	mov    ecx,0x1
   205ed:	call   5e661 <rfc_wrap>
   205f2:	mov    rdx,rax
   205f5:	jmp    2005d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x11d>
   205fa:	mov    ecx,DWORD PTR [r12+rax*8+0x4]
   205ff:	mov    edx,DWORD PTR [r12+rax*8]
   20603:	mov    esi,edx
   20605:	and    esi,0xffffff
   2060b:	cmp    esi,0x1
   2060e:	jne    25d55 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5e15>
   20614:	mov    esi,DWORD PTR [r12+rax*8]
   20618:	shl    rcx,0x20
   2061c:	or     rcx,rdx
   2061f:	shr    rcx,0x18
   20623:	mov    rsi,QWORD PTR [r12+rcx*8]
   20627:	mov    rdx,QWORD PTR [r12+rcx*8+0x8]
   2062c:	mov    QWORD PTR [rsp+0x40],rdx
   20631:	mov    rdx,QWORD PTR [r13+0x0]
   20635:	mov    QWORD PTR [r12+rax*8],rdx
   20639:	mov    QWORD PTR [r13+0x0],rax
   2063d:	mov    rax,QWORD PTR [r13+0x100]
   20644:	inc    rax
   20647:	mov    QWORD PTR [r13+0x100],rax
   2064e:	cmp    BYTE PTR [rip+0x142a3b],0x1        # 163090 <KEEP_WORDS>
   20655:	jne    2615a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x621a>
   2065b:	cmp    rax,0x8000
   20661:	jae    2615a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x621a>
   20667:	cmp    rcx,0x3108200
   2066e:	jb     206a7 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x767>
   20670:	mov    rax,QWORD PTR [r13+0x8]
   20674:	mov    QWORD PTR [r12+rcx*8],rax
   20678:	mov    QWORD PTR [r13+0x8],rcx
   2067c:	mov    rax,QWORD PTR [r13+0x108]
   20683:	add    rax,0x2
   20687:	mov    QWORD PTR [r13+0x108],rax
   2068e:	cmp    BYTE PTR [rip+0x1429fb],0x1        # 163090 <KEEP_WORDS>
   20695:	jne    25b4e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5c0e>
   2069b:	cmp    rax,0x8000
   206a1:	jae    25b4e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5c0e>
   206a7:	mov    rax,r8
   206aa:	and    rax,r11
   206ad:	movabs rcx,0x80000000000
   206b7:	cmp    rax,rcx
   206ba:	jne    2752b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x75eb>
   206c0:	mov    rdx,r8
   206c3:	and    rdx,r10
   206c6:	test   r8,r8
   206c9:	js     20bde <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xc9e>
   206cf:	mov    r9,QWORD PTR [r12+rdx*8]
   206d3:	mov    rax,QWORD PTR [r12+rdx*8+0x8]
   206d8:	mov    rcx,rdx
   206db:	cmp    rcx,0x3108200
   206e2:	jae    20c56 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xd16>
   206e8:	jmp    20c8e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xd4e>
   206ed:	mov    r9,r11
   206f0:	mov    ecx,DWORD PTR [r12+rax*8+0x4]
   206f5:	mov    edx,DWORD PTR [r12+rax*8]
   206f9:	mov    esi,edx
   206fb:	and    esi,0xffffff
   20701:	cmp    esi,0x1
   20704:	jne    25da0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5e60>
   2070a:	mov    esi,DWORD PTR [r12+rax*8]
   2070e:	shl    rcx,0x20
   20712:	or     rcx,rdx
   20715:	shr    rcx,0x18
   20719:	mov    rdx,QWORD PTR [r12+rcx*8]
   2071d:	mov    QWORD PTR [rsp+0x38],rdx
   20722:	mov    rsi,QWORD PTR [r12+rcx*8+0x8]
   20727:	mov    rbx,QWORD PTR [r12+rcx*8+0x10]
   2072c:	mov    rdx,QWORD PTR [r13+0x0]
   20730:	mov    QWORD PTR [r12+rax*8],rdx
   20734:	mov    QWORD PTR [r13+0x0],rax
   20738:	mov    rax,QWORD PTR [r13+0x100]
   2073f:	inc    rax
   20742:	mov    QWORD PTR [r13+0x100],rax
   20749:	cmp    BYTE PTR [rip+0x142940],0x1        # 163090 <KEEP_WORDS>
   20750:	jne    2618f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x624f>
   20756:	cmp    rax,0x8000
   2075c:	jae    2618f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x624f>
   20762:	mov    r11,r9
   20765:	cmp    rcx,0x3108200
   2076c:	jb     207a5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x865>
   2076e:	mov    rax,QWORD PTR [r13+0x10]
   20772:	mov    QWORD PTR [r12+rcx*8],rax
   20776:	mov    QWORD PTR [r13+0x10],rcx
   2077a:	mov    rax,QWORD PTR [r13+0x110]
   20781:	add    rax,0x4
   20785:	mov    QWORD PTR [r13+0x110],rax
   2078c:	cmp    BYTE PTR [rip+0x1428fd],0x1        # 163090 <KEEP_WORDS>
   20793:	jne    25b6c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5c2c>
   20799:	cmp    rax,0x8000
   2079f:	jae    25b6c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5c2c>
   207a5:	mov    rax,r8
   207a8:	and    rax,r11
   207ab:	movabs r15,0x80000000000
   207b5:	cmp    rax,r15
   207b8:	mov    QWORD PTR [rsp+0x48],rsi
   207bd:	jne    276f7 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x77b7>
   207c3:	mov    rdx,r8
   207c6:	and    rdx,r10
   207c9:	test   r8,r8
   207cc:	js     20f15 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xfd5>
   207d2:	mov    rax,QWORD PTR [r12+rdx*8]
   207d6:	mov    QWORD PTR [rsp+0x40],rax
   207db:	mov    rax,QWORD PTR [r12+rdx*8+0x8]
   207e0:	mov    rcx,rdx
   207e3:	cmp    rcx,0x3108200
   207ea:	jae    20f91 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1051>
   207f0:	jmp    20fc9 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1089>
   207f5:	mov    ecx,DWORD PTR [r12+rax*8+0x4]
   207fa:	mov    edx,DWORD PTR [r12+rax*8]
   207fe:	mov    esi,edx
   20800:	and    esi,0xffffff
   20806:	cmp    esi,0x1
   20809:	jne    25ded <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5ead>
   2080f:	mov    esi,DWORD PTR [r12+rax*8]
   20813:	shl    rcx,0x20
   20817:	or     rcx,rdx
   2081a:	shr    rcx,0x18
   2081e:	mov    rsi,QWORD PTR [r12+rcx*8]
   20822:	mov    rdx,QWORD PTR [r12+rcx*8+0x8]
   20827:	mov    QWORD PTR [rsp+0x48],rdx
   2082c:	mov    rdx,QWORD PTR [r13+0x0]
   20830:	mov    QWORD PTR [r12+rax*8],rdx
   20834:	mov    QWORD PTR [r13+0x0],rax
   20838:	mov    rax,QWORD PTR [r13+0x100]
   2083f:	inc    rax
   20842:	mov    QWORD PTR [r13+0x100],rax
   20849:	cmp    BYTE PTR [rip+0x142840],0x1        # 163090 <KEEP_WORDS>
   20850:	jne    261c1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6281>
   20856:	cmp    rax,0x8000
   2085c:	jae    261c1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6281>
   20862:	cmp    rcx,0x3108200
   20869:	jb     208a2 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x962>
   2086b:	mov    rax,QWORD PTR [r13+0x8]
   2086f:	mov    QWORD PTR [r12+rcx*8],rax
   20873:	mov    QWORD PTR [r13+0x8],rcx
   20877:	mov    rax,QWORD PTR [r13+0x108]
   2087e:	add    rax,0x2
   20882:	mov    QWORD PTR [r13+0x108],rax
   20889:	cmp    BYTE PTR [rip+0x142800],0x1        # 163090 <KEEP_WORDS>
   20890:	jne    25b97 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5c57>
   20896:	cmp    rax,0x8000
   2089c:	jae    25b97 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5c57>
   208a2:	mov    rax,r8
   208a5:	and    rax,r11
   208a8:	movabs r15,0x80000000000
   208b2:	cmp    rax,r15
   208b5:	jne    27906 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x79c6>
   208bb:	mov    rdx,r8
   208be:	and    rdx,r10
   208c1:	test   r8,r8
   208c4:	js     211ea <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x12aa>
   208ca:	mov    rax,QWORD PTR [r12+rdx*8]
   208ce:	mov    QWORD PTR [rsp+0x38],rax
   208d3:	mov    rax,QWORD PTR [r12+rdx*8+0x8]
   208d8:	mov    rcx,rdx
   208db:	cmp    rcx,0x3108200
   208e2:	jae    21267 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1327>
   208e8:	jmp    2129f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x135f>
   208ed:	mov    rbx,r9
   208f0:	mov    r9,r11
   208f3:	mov    ecx,DWORD PTR [r12+rax*8+0x4]
   208f8:	mov    edx,DWORD PTR [r12+rax*8]
   208fc:	mov    esi,edx
   208fe:	and    esi,0xffffff
   20904:	cmp    esi,0x1
   20907:	jne    25e3e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5efe>
   2090d:	mov    esi,DWORD PTR [r12+rax*8]
   20911:	shl    rcx,0x20
   20915:	or     rcx,rdx
   20918:	shr    rcx,0x18
   2091c:	mov    rbp,QWORD PTR [r12+rcx*8]
   20920:	mov    rdx,QWORD PTR [r12+rcx*8+0x8]
   20925:	mov    QWORD PTR [rsp+0x38],rdx
   2092a:	mov    rsi,QWORD PTR [r12+rcx*8+0x10]
   2092f:	mov    rdx,QWORD PTR [r13+0x0]
   20933:	mov    QWORD PTR [r12+rax*8],rdx
   20937:	mov    QWORD PTR [r13+0x0],rax
   2093b:	mov    rax,QWORD PTR [r13+0x100]
   20942:	inc    rax
   20945:	mov    QWORD PTR [r13+0x100],rax
   2094c:	cmp    BYTE PTR [rip+0x14273d],0x1        # 163090 <KEEP_WORDS>
   20953:	jne    261f6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x62b6>
   20959:	cmp    rax,0x8000
   2095f:	jae    261f6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x62b6>
   20965:	mov    r11,r9
   20968:	mov    r9,rbx
   2096b:	cmp    rcx,0x3108200
   20972:	jb     209ab <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xa6b>
   20974:	mov    rax,QWORD PTR [r13+0x10]
   20978:	mov    QWORD PTR [r12+rcx*8],rax
   2097c:	mov    QWORD PTR [r13+0x10],rcx
   20980:	mov    rax,QWORD PTR [r13+0x110]
   20987:	add    rax,0x4
   2098b:	mov    QWORD PTR [r13+0x110],rax
   20992:	cmp    BYTE PTR [rip+0x1426f7],0x1        # 163090 <KEEP_WORDS>
   20999:	jne    25bb5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5c75>
   2099f:	cmp    rax,0x8000
   209a5:	jae    25bb5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5c75>
   209ab:	and    r11,r8
   209ae:	movabs rax,0x80000000000
   209b8:	cmp    r11,rax
   209bb:	jne    27eb6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7f76>
   209c1:	and    r10,r8
   209c4:	test   r8,r8
   209c7:	js     214d5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1595>
   209cd:	mov    rax,QWORD PTR [r12+r10*8]
   209d1:	mov    QWORD PTR [rsp+0x48],rax
   209d6:	mov    rax,QWORD PTR [r12+r10*8+0x8]
   209db:	mov    rcx,r10
   209de:	mov    r10,QWORD PTR [rsp+0x38]
   209e3:	cmp    rcx,0x3108200
   209ea:	jae    21551 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1611>
   209f0:	jmp    21589 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1649>
   209f5:	mov    ecx,DWORD PTR [r12+rax*8+0x4]
   209fa:	mov    edx,DWORD PTR [r12+rax*8]
   209fe:	mov    esi,edx
   20a00:	and    esi,0xffffff
   20a06:	cmp    esi,0x1
   20a09:	jne    25e95 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5f55>
   20a0f:	mov    esi,DWORD PTR [r12+rax*8]
   20a13:	shl    rcx,0x20
   20a17:	or     rcx,rdx
   20a1a:	shr    rcx,0x18
   20a1e:	mov    rbx,QWORD PTR [r12+rcx*8]
   20a22:	mov    r15,QWORD PTR [r12+rcx*8+0x8]
   20a27:	mov    rdx,QWORD PTR [r13+0x0]
   20a2b:	mov    QWORD PTR [r12+rax*8],rdx
   20a2f:	mov    QWORD PTR [r13+0x0],rax
   20a33:	mov    rax,QWORD PTR [r13+0x100]
   20a3a:	inc    rax
   20a3d:	mov    QWORD PTR [r13+0x100],rax
   20a44:	cmp    BYTE PTR [rip+0x142645],0x1        # 163090 <KEEP_WORDS>
   20a4b:	jne    2622b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x62eb>
   20a51:	cmp    rax,0x8000
   20a57:	jae    2622b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x62eb>
   20a5d:	cmp    rcx,0x3108200
   20a64:	jb     20a9d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xb5d>
   20a66:	mov    rax,QWORD PTR [r13+0x8]
   20a6a:	mov    QWORD PTR [r12+rcx*8],rax
   20a6e:	mov    QWORD PTR [r13+0x8],rcx
   20a72:	mov    rax,QWORD PTR [r13+0x108]
   20a79:	add    rax,0x2
   20a7d:	mov    QWORD PTR [r13+0x108],rax
   20a84:	cmp    BYTE PTR [rip+0x142605],0x1        # 163090 <KEEP_WORDS>
   20a8b:	jne    25be0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5ca0>
   20a91:	cmp    rax,0x8000
   20a97:	jae    25be0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5ca0>
   20a9d:	mov    rax,r8
   20aa0:	and    rax,r11
   20aa3:	movabs rbp,0x80000000000
   20aad:	cmp    rax,rbp
   20ab0:	jne    28104 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x81c4>
   20ab6:	mov    rax,r8
   20ab9:	and    rax,r10
   20abc:	test   r8,r8
   20abf:	js     21a73 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1b33>
   20ac5:	mov    rdx,QWORD PTR [r12+rax*8]
   20ac9:	mov    r9,QWORD PTR [r12+rax*8+0x8]
   20ace:	mov    rcx,rax
   20ad1:	cmp    rcx,0x3108200
   20ad8:	jae    21ae4 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1ba4>
   20ade:	jmp    21b1b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1bdb>
   20ae3:	mov    r9,r11
   20ae6:	mov    ecx,DWORD PTR [r12+rax*8+0x4]
   20aeb:	mov    edx,DWORD PTR [r12+rax*8]
   20aef:	mov    esi,edx
   20af1:	and    esi,0xffffff
   20af7:	cmp    esi,0x1
   20afa:	jne    25edb <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5f9b>
   20b00:	mov    esi,DWORD PTR [r12+rax*8]
   20b04:	shl    rcx,0x20
   20b08:	or     rcx,rdx
   20b0b:	shr    rcx,0x18
   20b0f:	mov    rsi,QWORD PTR [r12+rcx*8]
   20b13:	mov    r15,QWORD PTR [r12+rcx*8+0x8]
   20b18:	mov    rdx,QWORD PTR [r12+rcx*8+0x10]
   20b1d:	mov    QWORD PTR [rsp+0x28],rdx
   20b22:	mov    rdx,QWORD PTR [r13+0x0]
   20b26:	mov    QWORD PTR [r12+rax*8],rdx
   20b2a:	mov    QWORD PTR [r13+0x0],rax
   20b2e:	mov    rax,QWORD PTR [r13+0x100]
   20b35:	inc    rax
   20b38:	mov    QWORD PTR [r13+0x100],rax
   20b3f:	cmp    BYTE PTR [rip+0x14254a],0x1        # 163090 <KEEP_WORDS>
   20b46:	jne    2625a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x631a>
   20b4c:	cmp    rax,0x8000
   20b52:	jae    2625a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x631a>
   20b58:	mov    r11,r9
   20b5b:	cmp    rcx,0x3108200
   20b62:	jb     20b9b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xc5b>
   20b64:	mov    rax,QWORD PTR [r13+0x10]
   20b68:	mov    QWORD PTR [r12+rcx*8],rax
   20b6c:	mov    QWORD PTR [r13+0x10],rcx
   20b70:	mov    rax,QWORD PTR [r13+0x110]
   20b77:	add    rax,0x4
   20b7b:	mov    QWORD PTR [r13+0x110],rax
   20b82:	cmp    BYTE PTR [rip+0x142507],0x1        # 163090 <KEEP_WORDS>
   20b89:	jne    25bf8 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5cb8>
   20b8f:	cmp    rax,0x8000
   20b95:	jae    25bf8 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5cb8>
   20b9b:	and    r11,r8
   20b9e:	movabs rax,0x80000000000
   20ba8:	cmp    r11,rax
   20bab:	jne    2824a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x830a>
   20bb1:	mov    rdx,r8
   20bb4:	and    rdx,r10
   20bb7:	test   r8,r8
   20bba:	js     2203e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x20fe>
   20bc0:	mov    rbx,QWORD PTR [r12+rdx*8]
   20bc4:	mov    rax,QWORD PTR [r12+rdx*8+0x8]
   20bc9:	mov    rcx,rdx
   20bcc:	cmp    rcx,0x3108200
   20bd3:	jae    220b6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2176>
   20bd9:	jmp    220ee <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x21ae>
   20bde:	mov    r15,rsi
   20be1:	mov    ecx,DWORD PTR [r12+rdx*8+0x4]
   20be6:	mov    eax,DWORD PTR [r12+rdx*8]
   20bea:	mov    esi,eax
   20bec:	and    esi,0xffffff
   20bf2:	cmp    esi,0x1
   20bf5:	jne    25f2b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5feb>
   20bfb:	mov    esi,DWORD PTR [r12+rdx*8]
   20bff:	shl    rcx,0x20
   20c03:	or     rcx,rax
   20c06:	shr    rcx,0x18
   20c0a:	mov    r9,QWORD PTR [r12+rcx*8]
   20c0e:	mov    rax,QWORD PTR [r12+rcx*8+0x8]
   20c13:	mov    rsi,QWORD PTR [r13+0x0]
   20c17:	mov    QWORD PTR [r12+rdx*8],rsi
   20c1b:	mov    QWORD PTR [r13+0x0],rdx
   20c1f:	mov    rdx,QWORD PTR [r13+0x100]
   20c26:	inc    rdx
   20c29:	mov    QWORD PTR [r13+0x100],rdx
   20c30:	cmp    BYTE PTR [rip+0x142459],0x1        # 163090 <KEEP_WORDS>
   20c37:	jne    2628c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x634c>
   20c3d:	cmp    rdx,0x8000
   20c44:	jae    2628c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x634c>
   20c4a:	mov    rsi,r15
   20c4d:	cmp    rcx,0x3108200
   20c54:	jb     20c8e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xd4e>
   20c56:	mov    rdx,QWORD PTR [r13+0x8]
   20c5a:	mov    QWORD PTR [r12+rcx*8],rdx
   20c5e:	mov    QWORD PTR [r13+0x8],rcx
   20c62:	mov    rcx,QWORD PTR [r13+0x108]
   20c69:	add    rcx,0x2
   20c6d:	mov    QWORD PTR [r13+0x108],rcx
   20c74:	cmp    BYTE PTR [rip+0x142415],0x1        # 163090 <KEEP_WORDS>
   20c7b:	jne    25c23 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5ce3>
   20c81:	cmp    rcx,0x8000
   20c88:	jae    25c23 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5ce3>
   20c8e:	mov    r15,QWORD PTR [r13+0x8]
   20c92:	cmp    rax,0x1
   20c96:	je     20de5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xea5>
   20c9c:	movabs rcx,0x7fffff0000000000
   20ca6:	and    rax,rcx
   20ca9:	movabs rcx,0x100020000000000
   20cb3:	cmp    rax,rcx
   20cb6:	je     20de5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xea5>
   20cbc:	test   r15,r15
   20cbf:	je     24eef <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4faf>
   20cc5:	mov    rax,QWORD PTR [r12+r15*8]
   20cc9:	mov    QWORD PTR [r13+0x8],rax
   20ccd:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   20cd5:	movabs rbp,0xff00000000000000
   20cdf:	mov    rax,rsi
   20ce2:	shr    rax,0x38
   20ce6:	cmp    eax,0x2
   20ce9:	mov    rdx,QWORD PTR [rsp+0x40]
   20cee:	je     24f13 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4fd3>
   20cf4:	mov    QWORD PTR [r12+r15*8],rsi
   20cf8:	mov    rax,rdx
   20cfb:	and    rax,rbp
   20cfe:	movabs rcx,0x200000000000000
   20d08:	cmp    rax,rcx
   20d0b:	je     24f39 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4ff9>
   20d11:	mov    QWORD PTR [r12+r15*8+0x8],rdx
   20d16:	mov    rax,r14
   20d19:	mov    rcx,r9
   20d1c:	jmp    20d2a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xdea>
   20d1e:	xchg   ax,ax
   20d20:	cmp    rsi,0x4
   20d24:	jne    224f9 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x25b9>
   20d2a:	mov    rdx,rcx
   20d2d:	shr    rdx,0x28
   20d31:	cmp    dx,0x19
   20d35:	jne    22fb5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3075>
   20d3b:	mov    rsi,rcx
   20d3e:	and    rsi,r10
   20d41:	test   rcx,rcx
   20d44:	jns    20d6e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xe2e>
   20d46:	mov    ecx,DWORD PTR [r12+rsi*8+0x4]
   20d4b:	mov    edx,DWORD PTR [r12+rsi*8]
   20d4f:	mov    edi,edx
   20d51:	and    edi,0xffffff
   20d57:	cmp    edi,0x1
   20d5a:	jne    20d60 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xe20>
   20d5c:	mov    esi,DWORD PTR [r12+rsi*8]
   20d60:	shl    rcx,0x20
   20d64:	or     rcx,rdx
   20d67:	shr    rcx,0x18
   20d6b:	mov    rsi,rcx
   20d6e:	mov    rcx,rax
   20d71:	shr    rcx,0x28
   20d75:	cmp    cx,0x19
   20d79:	jne    23185 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3245>
   20d7f:	mov    rdx,QWORD PTR [r12+rsi*8]
   20d83:	mov    rcx,QWORD PTR [r12+rsi*8+0x8]
   20d88:	mov    rsi,rax
   20d8b:	and    rsi,r10
   20d8e:	test   rax,rax
   20d91:	jns    20dbb <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xe7b>
   20d93:	mov    eax,DWORD PTR [r12+rsi*8+0x4]
   20d98:	mov    edi,DWORD PTR [r12+rsi*8]
   20d9c:	mov    ebx,edi
   20d9e:	and    ebx,0xffffff
   20da4:	cmp    ebx,0x1
   20da7:	jne    20dad <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xe6d>
   20da9:	mov    esi,DWORD PTR [r12+rsi*8]
   20dad:	shl    rax,0x20
   20db1:	or     rax,rdi
   20db4:	shr    rax,0x18
   20db8:	mov    rsi,rax
   20dbb:	mov    ebx,DWORD PTR [r12+rsi*8]
   20dbf:	xor    edi,edi
   20dc1:	mov    rax,QWORD PTR [r12+rsi*8+0x8]
   20dc6:	mov    esi,0x3
   20dcb:	cmp    edx,ebx
   20dcd:	sete   dl
   20dd0:	jb     20d20 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xde0>
   20dd6:	mov    dil,dl
   20dd9:	xor    rdi,0x5
   20ddd:	mov    rsi,rdi
   20de0:	jmp    20d20 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xde0>
   20de5:	test   r15,r15
   20de8:	je     24bc5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4c85>
   20dee:	mov    rax,QWORD PTR [r12+r15*8]
   20df2:	mov    QWORD PTR [r13+0x8],rax
   20df6:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   20dfe:	movabs rbp,0xff00000000000000
   20e08:	mov    rax,r14
   20e0b:	shr    rax,0x38
   20e0f:	cmp    eax,0x2
   20e12:	mov    rdx,QWORD PTR [rsp+0x28]
   20e17:	je     24be9 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4ca9>
   20e1d:	mov    QWORD PTR [r12+r15*8],r14
   20e21:	mov    rax,rdx
   20e24:	and    rax,rbp
   20e27:	movabs rcx,0x200000000000000
   20e31:	cmp    rax,rcx
   20e34:	je     24c15 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4cd5>
   20e3a:	mov    QWORD PTR [r12+r15*8+0x8],rdx
   20e3f:	mov    r14,rsi
   20e42:	mov    rax,rsi
   20e45:	mov    rcx,r9
   20e48:	jmp    20e5a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xf1a>
   20e4a:	nop    WORD PTR [rax+rax*1+0x0]
   20e50:	cmp    rsi,0x4
   20e54:	jne    224c9 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2589>
   20e5a:	mov    rdx,rcx
   20e5d:	shr    rdx,0x28
   20e61:	cmp    dx,0x19
   20e65:	jne    22eef <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2faf>
   20e6b:	mov    rsi,rcx
   20e6e:	and    rsi,r10
   20e71:	test   rcx,rcx
   20e74:	jns    20e9e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xf5e>
   20e76:	mov    ecx,DWORD PTR [r12+rsi*8+0x4]
   20e7b:	mov    edx,DWORD PTR [r12+rsi*8]
   20e7f:	mov    edi,edx
   20e81:	and    edi,0xffffff
   20e87:	cmp    edi,0x1
   20e8a:	jne    20e90 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xf50>
   20e8c:	mov    esi,DWORD PTR [r12+rsi*8]
   20e90:	shl    rcx,0x20
   20e94:	or     rcx,rdx
   20e97:	shr    rcx,0x18
   20e9b:	mov    rsi,rcx
   20e9e:	mov    rcx,rax
   20ea1:	shr    rcx,0x28
   20ea5:	cmp    cx,0x19
   20ea9:	jne    2314f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x320f>
   20eaf:	mov    rdx,QWORD PTR [r12+rsi*8]
   20eb3:	mov    rcx,QWORD PTR [r12+rsi*8+0x8]
   20eb8:	mov    rsi,rax
   20ebb:	and    rsi,r10
   20ebe:	test   rax,rax
   20ec1:	jns    20eeb <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xfab>
   20ec3:	mov    eax,DWORD PTR [r12+rsi*8+0x4]
   20ec8:	mov    edi,DWORD PTR [r12+rsi*8]
   20ecc:	mov    ebx,edi
   20ece:	and    ebx,0xffffff
   20ed4:	cmp    ebx,0x1
   20ed7:	jne    20edd <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xf9d>
   20ed9:	mov    esi,DWORD PTR [r12+rsi*8]
   20edd:	shl    rax,0x20
   20ee1:	or     rax,rdi
   20ee4:	shr    rax,0x18
   20ee8:	mov    rsi,rax
   20eeb:	mov    ebx,DWORD PTR [r12+rsi*8]
   20eef:	xor    edi,edi
   20ef1:	mov    rax,QWORD PTR [r12+rsi*8+0x8]
   20ef6:	mov    esi,0x3
   20efb:	cmp    edx,ebx
   20efd:	sete   dl
   20f00:	jb     20e50 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xf10>
   20f06:	mov    dil,dl
   20f09:	xor    rdi,0x5
   20f0d:	mov    rsi,rdi
   20f10:	jmp    20e50 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xf10>
   20f15:	mov    ecx,DWORD PTR [r12+rdx*8+0x4]
   20f1a:	mov    eax,DWORD PTR [r12+rdx*8]
   20f1e:	mov    esi,eax
   20f20:	and    esi,0xffffff
   20f26:	cmp    esi,0x1
   20f29:	jne    25f67 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6027>
   20f2f:	mov    esi,DWORD PTR [r12+rdx*8]
   20f33:	shl    rcx,0x20
   20f37:	or     rcx,rax
   20f3a:	shr    rcx,0x18
   20f3e:	mov    rax,QWORD PTR [r12+rcx*8]
   20f42:	mov    QWORD PTR [rsp+0x40],rax
   20f47:	mov    rax,QWORD PTR [r12+rcx*8+0x8]
   20f4c:	mov    rsi,QWORD PTR [r13+0x0]
   20f50:	mov    QWORD PTR [r12+rdx*8],rsi
   20f54:	mov    QWORD PTR [r13+0x0],rdx
   20f58:	mov    rdx,QWORD PTR [r13+0x100]
   20f5f:	inc    rdx
   20f62:	mov    QWORD PTR [r13+0x100],rdx
   20f69:	cmp    BYTE PTR [rip+0x142120],0x1        # 163090 <KEEP_WORDS>
   20f70:	jne    262b4 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6374>
   20f76:	cmp    rdx,0x8000
   20f7d:	jae    262b4 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6374>
   20f83:	mov    rsi,QWORD PTR [rsp+0x48]
   20f88:	cmp    rcx,0x3108200
   20f8f:	jb     20fc9 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1089>
   20f91:	mov    rdx,QWORD PTR [r13+0x8]
   20f95:	mov    QWORD PTR [r12+rcx*8],rdx
   20f99:	mov    QWORD PTR [r13+0x8],rcx
   20f9d:	mov    rcx,QWORD PTR [r13+0x108]
   20fa4:	add    rcx,0x2
   20fa8:	mov    QWORD PTR [r13+0x108],rcx
   20faf:	cmp    BYTE PTR [rip+0x1420da],0x1        # 163090 <KEEP_WORDS>
   20fb6:	jne    25c44 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5d04>
   20fbc:	cmp    rcx,0x8000
   20fc3:	jae    25c44 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5d04>
   20fc9:	cmp    rax,0x1
   20fcd:	je     21145 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1205>
   20fd3:	movabs rcx,0x7fffff0000000000
   20fdd:	and    rax,rcx
   20fe0:	movabs rcx,0x100020000000000
   20fea:	cmp    rax,rcx
   20fed:	je     21145 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1205>
   20ff3:	mov    r9,QWORD PTR [r13+0x10]
   20ff7:	test   r9,r9
   20ffa:	mov    rdx,QWORD PTR [rsp+0x38]
   20fff:	je     24f57 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5017>
   21005:	mov    rax,QWORD PTR [r12+r9*8]
   21009:	mov    QWORD PTR [r13+0x10],rax
   2100d:	add    QWORD PTR [r13+0x110],0xfffffffffffffffc
   21015:	movabs rbp,0xff00000000000000
   2101f:	mov    rax,rdx
   21022:	shr    rax,0x38
   21026:	cmp    eax,0x2
   21029:	je     24f7f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x503f>
   2102f:	mov    QWORD PTR [r12+r9*8],rdx
   21033:	mov    rax,rsi
   21036:	and    rax,rbp
   21039:	movabs rcx,0x200000000000000
   21043:	cmp    rax,rcx
   21046:	je     24fa2 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5062>
   2104c:	mov    QWORD PTR [r12+r9*8+0x8],rsi
   21051:	mov    rax,rbx
   21054:	and    rax,rbp
   21057:	cmp    rax,rcx
   2105a:	je     24fcd <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x508d>
   21060:	mov    QWORD PTR [r12+r9*8+0x10],rbx
   21065:	mov    rax,r14
   21068:	mov    rcx,QWORD PTR [rsp+0x40]
   2106d:	mov    QWORD PTR [rsp+0x38],r9
   21072:	jmp    2108a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x114a>
   21074:	data16 data16 nop WORD PTR cs:[rax+rax*1+0x0]
   21080:	cmp    rsi,0x4
   21084:	jne    22529 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x25e9>
   2108a:	mov    rdx,rcx
   2108d:	shr    rdx,0x28
   21091:	cmp    dx,0x19
   21095:	jne    23078 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3138>
   2109b:	mov    rsi,rcx
   2109e:	and    rsi,r10
   210a1:	test   rcx,rcx
   210a4:	jns    210ce <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x118e>
   210a6:	mov    ecx,DWORD PTR [r12+rsi*8+0x4]
   210ab:	mov    edx,DWORD PTR [r12+rsi*8]
   210af:	mov    edi,edx
   210b1:	and    edi,0xffffff
   210b7:	cmp    edi,0x1
   210ba:	jne    210c0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1180>
   210bc:	mov    esi,DWORD PTR [r12+rsi*8]
   210c0:	shl    rcx,0x20
   210c4:	or     rcx,rdx
   210c7:	shr    rcx,0x18
   210cb:	mov    rsi,rcx
   210ce:	mov    rcx,rax
   210d1:	shr    rcx,0x28
   210d5:	cmp    cx,0x19
   210d9:	jne    231bb <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x327b>
   210df:	mov    rdx,QWORD PTR [r12+rsi*8]
   210e3:	mov    rcx,QWORD PTR [r12+rsi*8+0x8]
   210e8:	mov    rsi,rax
   210eb:	and    rsi,r10
   210ee:	test   rax,rax
   210f1:	jns    2111b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x11db>
   210f3:	mov    eax,DWORD PTR [r12+rsi*8+0x4]
   210f8:	mov    edi,DWORD PTR [r12+rsi*8]
   210fc:	mov    ebx,edi
   210fe:	and    ebx,0xffffff
   21104:	cmp    ebx,0x1
   21107:	jne    2110d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x11cd>
   21109:	mov    esi,DWORD PTR [r12+rsi*8]
   2110d:	shl    rax,0x20
   21111:	or     rax,rdi
   21114:	shr    rax,0x18
   21118:	mov    rsi,rax
   2111b:	mov    ebx,DWORD PTR [r12+rsi*8]
   2111f:	xor    edi,edi
   21121:	mov    rax,QWORD PTR [r12+rsi*8+0x8]
   21126:	mov    esi,0x3
   2112b:	cmp    edx,ebx
   2112d:	sete   dl
   21130:	jb     21080 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1140>
   21136:	mov    dil,dl
   21139:	xor    rdi,0x5
   2113d:	mov    rsi,rdi
   21140:	jmp    21080 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1140>
   21145:	mov    r8,QWORD PTR [r13+0x8]
   21149:	mov    rcx,r14
   2114c:	test   r8,r8
   2114f:	je     24c39 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4cf9>
   21155:	mov    rax,QWORD PTR [r12+r8*8]
   21159:	mov    QWORD PTR [r13+0x8],rax
   2115d:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   21165:	mov    rdx,QWORD PTR [rsp+0x28]
   2116a:	movabs r14,0xff00000000000000
   21174:	mov    rax,rcx
   21177:	shr    rax,0x38
   2117b:	cmp    eax,0x2
   2117e:	je     24c51 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4d11>
   21184:	mov    QWORD PTR [r12+r8*8],rcx
   21188:	mov    rax,rdx
   2118b:	and    rax,r14
   2118e:	movabs r15,0x200000000000000
   21198:	cmp    rax,r15
   2119b:	mov    QWORD PTR [rsp+0x58],rbx
   211a0:	je     24c71 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4d31>
   211a6:	mov    QWORD PTR [r12+r8*8+0x8],rdx
   211ab:	movabs rbx,0x2002c0000000000
   211b5:	or     rbx,r8
   211b8:	cmp    DWORD PTR [rsp+0x14],0x0
   211bd:	je     225a6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2666>
   211c3:	mov    rax,QWORD PTR [rsp+0x20]
   211c8:	mov    rcx,QWORD PTR [rsp+0x30]
   211cd:	mov    QWORD PTR [rax],rcx
   211d0:	mov    QWORD PTR [rax+0x8],rbx
   211d4:	mov    QWORD PTR [rax+0x10],0xaf
   211dc:	add    rax,0x18
   211e0:	mov    QWORD PTR [rsp+0x20],rax
   211e5:	jmp    225f5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x26b5>
   211ea:	mov    rbx,rsi
   211ed:	mov    ecx,DWORD PTR [r12+rdx*8+0x4]
   211f2:	mov    eax,DWORD PTR [r12+rdx*8]
   211f6:	mov    esi,eax
   211f8:	and    esi,0xffffff
   211fe:	cmp    esi,0x1
   21201:	jne    25fa4 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6064>
   21207:	mov    esi,DWORD PTR [r12+rdx*8]
   2120b:	shl    rcx,0x20
   2120f:	or     rcx,rax
   21212:	shr    rcx,0x18
   21216:	mov    rax,QWORD PTR [r12+rcx*8]
   2121a:	mov    QWORD PTR [rsp+0x38],rax
   2121f:	mov    rax,QWORD PTR [r12+rcx*8+0x8]
   21224:	mov    rsi,QWORD PTR [r13+0x0]
   21228:	mov    QWORD PTR [r12+rdx*8],rsi
   2122c:	mov    QWORD PTR [r13+0x0],rdx
   21230:	mov    rdx,QWORD PTR [r13+0x100]
   21237:	inc    rdx
   2123a:	mov    QWORD PTR [r13+0x100],rdx
   21241:	cmp    BYTE PTR [rip+0x141e48],0x1        # 163090 <KEEP_WORDS>
   21248:	jne    262de <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x639e>
   2124e:	cmp    rdx,0x8000
   21255:	jae    262de <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x639e>
   2125b:	mov    rsi,rbx
   2125e:	cmp    rcx,0x3108200
   21265:	jb     2129f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x135f>
   21267:	mov    rdx,QWORD PTR [r13+0x8]
   2126b:	mov    QWORD PTR [r12+rcx*8],rdx
   2126f:	mov    QWORD PTR [r13+0x8],rcx
   21273:	mov    rcx,QWORD PTR [r13+0x108]
   2127a:	add    rcx,0x2
   2127e:	mov    QWORD PTR [r13+0x108],rcx
   21285:	cmp    BYTE PTR [rip+0x141e04],0x1        # 163090 <KEEP_WORDS>
   2128c:	jne    25c64 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5d24>
   21292:	cmp    rcx,0x8000
   21299:	jae    25c64 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5d24>
   2129f:	cmp    rax,0x1
   212a3:	je     21373 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1433>
   212a9:	movabs rcx,0x7fffff0000000000
   212b3:	and    rax,rcx
   212b6:	movabs rcx,0x100020000000000
   212c0:	cmp    rax,rcx
   212c3:	je     21373 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1433>
   212c9:	mov    r8,QWORD PTR [r13+0x8]
   212cd:	test   r8,r8
   212d0:	mov    QWORD PTR [rsp+0x40],r14
   212d5:	je     24fee <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x50ae>
   212db:	mov    rax,QWORD PTR [r12+r8*8]
   212df:	mov    QWORD PTR [r13+0x8],rax
   212e3:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   212eb:	movabs r14,0xff00000000000000
   212f5:	mov    rax,rsi
   212f8:	shr    rax,0x38
   212fc:	cmp    eax,0x2
   212ff:	mov    rcx,QWORD PTR [rsp+0x48]
   21304:	je     2500c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x50cc>
   2130a:	mov    QWORD PTR [r12+r8*8],rsi
   2130e:	mov    rax,rcx
   21311:	and    rax,r14
   21314:	movabs rbp,0x200000000000000
   2131e:	cmp    rax,rbp
   21321:	mov    rdx,QWORD PTR [rsp+0x28]
   21326:	je     2502c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x50ec>
   2132c:	mov    r15,r9
   2132f:	mov    QWORD PTR [r12+r8*8+0x8],rcx
   21334:	movabs rbx,0x2002c0000000000
   2133e:	or     rbx,r8
   21341:	cmp    DWORD PTR [rsp+0x14],0x0
   21346:	je     22848 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2908>
   2134c:	mov    rax,QWORD PTR [rsp+0x20]
   21351:	mov    rcx,QWORD PTR [rsp+0x30]
   21356:	mov    QWORD PTR [rax],rcx
   21359:	mov    QWORD PTR [rax+0x8],rbx
   2135d:	mov    QWORD PTR [rax+0x10],0xba
   21365:	add    rax,0x18
   21369:	mov    QWORD PTR [rsp+0x20],rax
   2136e:	jmp    228a6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2966>
   21373:	mov    rcx,QWORD PTR [r13+0x10]
   21377:	test   rcx,rcx
   2137a:	je     24c89 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4d49>
   21380:	mov    rax,QWORD PTR [r12+rcx*8]
   21384:	mov    QWORD PTR [r13+0x10],rax
   21388:	add    QWORD PTR [r13+0x110],0xfffffffffffffffc
   21390:	movabs rbp,0xff00000000000000
   2139a:	mov    rdx,QWORD PTR [rsp+0x28]
   2139f:	mov    rax,rdx
   213a2:	shr    rax,0x38
   213a6:	cmp    eax,0x2
   213a9:	mov    QWORD PTR [rsp+0x58],rcx
   213ae:	je     24cad <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4d6d>
   213b4:	mov    QWORD PTR [r12+rcx*8],rdx
   213b8:	mov    rax,r9
   213bb:	and    rax,rbp
   213be:	movabs rdx,0x200000000000000
   213c8:	cmp    rax,rdx
   213cb:	je     24cd6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4d96>
   213d1:	mov    QWORD PTR [r12+rcx*8+0x8],r9
   213d6:	mov    rax,r14
   213d9:	and    rax,rbp
   213dc:	movabs rdx,0x200000000000000
   213e6:	cmp    rax,rdx
   213e9:	je     24d02 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4dc2>
   213ef:	mov    QWORD PTR [r12+rcx*8+0x10],r14
   213f4:	mov    r14,rsi
   213f7:	mov    rax,rsi
   213fa:	mov    rcx,QWORD PTR [rsp+0x38]
   213ff:	jmp    2141a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x14da>
   21401:	data16 data16 data16 data16 data16 nop WORD PTR cs:[rax+rax*1+0x0]
   21410:	cmp    rsi,0x4
   21414:	jne    224e1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x25a1>
   2141a:	mov    rdx,rcx
   2141d:	shr    rdx,0x28
   21421:	cmp    dx,0x19
   21425:	jne    22f52 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3012>
   2142b:	mov    rsi,rcx
   2142e:	and    rsi,r10
   21431:	test   rcx,rcx
   21434:	jns    2145e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x151e>
   21436:	mov    ecx,DWORD PTR [r12+rsi*8+0x4]
   2143b:	mov    edx,DWORD PTR [r12+rsi*8]
   2143f:	mov    edi,edx
   21441:	and    edi,0xffffff
   21447:	cmp    edi,0x1
   2144a:	jne    21450 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1510>
   2144c:	mov    esi,DWORD PTR [r12+rsi*8]
   21450:	shl    rcx,0x20
   21454:	or     rcx,rdx
   21457:	shr    rcx,0x18
   2145b:	mov    rsi,rcx
   2145e:	mov    rcx,rax
   21461:	shr    rcx,0x28
   21465:	cmp    cx,0x19
   21469:	jne    2316a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x322a>
   2146f:	mov    rdx,QWORD PTR [r12+rsi*8]
   21473:	mov    rcx,QWORD PTR [r12+rsi*8+0x8]
   21478:	mov    rsi,rax
   2147b:	and    rsi,r10
   2147e:	test   rax,rax
   21481:	jns    214ab <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x156b>
   21483:	mov    eax,DWORD PTR [r12+rsi*8+0x4]
   21488:	mov    edi,DWORD PTR [r12+rsi*8]
   2148c:	mov    ebx,edi
   2148e:	and    ebx,0xffffff
   21494:	cmp    ebx,0x1
   21497:	jne    2149d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x155d>
   21499:	mov    esi,DWORD PTR [r12+rsi*8]
   2149d:	shl    rax,0x20
   214a1:	or     rax,rdi
   214a4:	shr    rax,0x18
   214a8:	mov    rsi,rax
   214ab:	mov    ebx,DWORD PTR [r12+rsi*8]
   214af:	xor    edi,edi
   214b1:	mov    rax,QWORD PTR [r12+rsi*8+0x8]
   214b6:	mov    esi,0x3
   214bb:	cmp    edx,ebx
   214bd:	sete   dl
   214c0:	jb     21410 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x14d0>
   214c6:	mov    dil,dl
   214c9:	xor    rdi,0x5
   214cd:	mov    rsi,rdi
   214d0:	jmp    21410 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x14d0>
   214d5:	mov    ecx,DWORD PTR [r12+r10*8+0x4]
   214da:	mov    eax,DWORD PTR [r12+r10*8]
   214de:	mov    edx,eax
   214e0:	and    edx,0xffffff
   214e6:	cmp    edx,0x1
   214e9:	jne    25fe9 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x60a9>
   214ef:	mov    edx,DWORD PTR [r12+r10*8]
   214f3:	shl    rcx,0x20
   214f7:	or     rcx,rax
   214fa:	shr    rcx,0x18
   214fe:	mov    rax,QWORD PTR [r12+rcx*8]
   21502:	mov    QWORD PTR [rsp+0x48],rax
   21507:	mov    rax,QWORD PTR [r12+rcx*8+0x8]
   2150c:	mov    rdx,QWORD PTR [r13+0x0]
   21510:	mov    QWORD PTR [r12+r10*8],rdx
   21514:	mov    QWORD PTR [r13+0x0],r10
   21518:	mov    rdx,QWORD PTR [r13+0x100]
   2151f:	inc    rdx
   21522:	mov    QWORD PTR [r13+0x100],rdx
   21529:	cmp    BYTE PTR [rip+0x141b60],0x1        # 163090 <KEEP_WORDS>
   21530:	jne    26306 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x63c6>
   21536:	cmp    rdx,0x8000
   2153d:	jae    26306 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x63c6>
   21543:	mov    r10,QWORD PTR [rsp+0x38]
   21548:	cmp    rcx,0x3108200
   2154f:	jb     21589 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1649>
   21551:	mov    rdx,QWORD PTR [r13+0x8]
   21555:	mov    QWORD PTR [r12+rcx*8],rdx
   21559:	mov    QWORD PTR [r13+0x8],rcx
   2155d:	mov    rcx,QWORD PTR [r13+0x108]
   21564:	add    rcx,0x2
   21568:	mov    QWORD PTR [r13+0x108],rcx
   2156f:	cmp    BYTE PTR [rip+0x141b1a],0x1        # 163090 <KEEP_WORDS>
   21576:	jne    25c85 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5d45>
   2157c:	cmp    rcx,0x8000
   21583:	jae    25c85 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5d45>
   21589:	movabs r15,0xff00000000000000
   21593:	movabs rdi,0x2002d0000000000
   2159d:	mov    rbx,QWORD PTR [r13+0x10]
   215a1:	cmp    rax,0x1
   215a5:	je     21661 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1721>
   215ab:	movabs rcx,0x7fffff0000000000
   215b5:	and    rax,rcx
   215b8:	movabs rcx,0x100020000000000
   215c2:	cmp    rax,rcx
   215c5:	je     21661 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1721>
   215cb:	test   rbx,rbx
   215ce:	je     250c4 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5184>
   215d4:	mov    rax,QWORD PTR [r12+rbx*8]
   215d8:	mov    QWORD PTR [r13+0x10],rax
   215dc:	add    QWORD PTR [r13+0x110],0xfffffffffffffffc
   215e4:	mov    rax,rbp
   215e7:	and    rax,r15
   215ea:	movabs rcx,0x200000000000000
   215f4:	cmp    rax,rcx
   215f7:	je     250e8 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x51a8>
   215fd:	mov    QWORD PTR [r12+rbx*8],rbp
   21601:	mov    rax,r10
   21604:	and    rax,r15
   21607:	cmp    rax,rcx
   2160a:	je     2511d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x51dd>
   21610:	mov    QWORD PTR [r12+rbx*8+0x8],r10
   21615:	mov    rax,rsi
   21618:	and    rax,r15
   2161b:	cmp    rax,rcx
   2161e:	je     2514e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x520e>
   21624:	mov    rbp,r9
   21627:	mov    QWORD PTR [r12+rbx*8+0x10],rsi
   2162c:	or     rbx,rdi
   2162f:	cmp    DWORD PTR [rsp+0x14],0x0
   21634:	je     22b05 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2bc5>
   2163a:	mov    rax,QWORD PTR [rsp+0x20]
   2163f:	mov    rcx,QWORD PTR [rsp+0x30]
   21644:	mov    QWORD PTR [rax],rcx
   21647:	mov    QWORD PTR [rax+0x8],rbx
   2164b:	mov    QWORD PTR [rax+0x10],0xbe
   21653:	add    rax,0x18
   21657:	mov    QWORD PTR [rsp+0x20],rax
   2165c:	jmp    22b5e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2c1e>
   21661:	test   rbx,rbx
   21664:	je     24dab <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4e6b>
   2166a:	mov    rax,QWORD PTR [r12+rbx*8]
   2166e:	mov    QWORD PTR [r13+0x10],rax
   21672:	add    QWORD PTR [r13+0x110],0xfffffffffffffffc
   2167a:	mov    rdx,QWORD PTR [rsp+0x28]
   2167f:	mov    rax,rdx
   21682:	and    rax,r15
   21685:	movabs rcx,0x200000000000000
   2168f:	cmp    rax,rcx
   21692:	je     24dcf <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4e8f>
   21698:	mov    QWORD PTR [r12+rbx*8],rdx
   2169c:	mov    rax,r9
   2169f:	and    rax,r15
   216a2:	cmp    rax,rcx
   216a5:	je     24dfd <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4ebd>
   216ab:	mov    QWORD PTR [r12+rbx*8+0x8],r9
   216b0:	mov    rax,r14
   216b3:	and    rax,r15
   216b6:	cmp    rax,rcx
   216b9:	je     24e2e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4eee>
   216bf:	mov    QWORD PTR [rsp+0x58],rsi
   216c4:	mov    QWORD PTR [r12+rbx*8+0x10],r14
   216c9:	or     rbx,rdi
   216cc:	cmp    DWORD PTR [rsp+0x14],0x0
   216d1:	je     22704 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x27c4>
   216d7:	mov    rax,QWORD PTR [rsp+0x20]
   216dc:	mov    rcx,QWORD PTR [rsp+0x30]
   216e1:	mov    QWORD PTR [rax],rcx
   216e4:	mov    QWORD PTR [rax+0x8],rbx
   216e8:	mov    QWORD PTR [rax+0x10],0xc0
   216f0:	add    rax,0x18
   216f4:	mov    QWORD PTR [rsp+0x20],rax
   216f9:	jmp    22753 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2813>
   216fe:	mov    ecx,DWORD PTR [r12+rax*8+0x4]
   21703:	mov    edx,DWORD PTR [r12+rax*8]
   21707:	mov    esi,edx
   21709:	and    esi,0xffffff
   2170f:	cmp    esi,0x1
   21712:	jne    26026 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x60e6>
   21718:	mov    esi,DWORD PTR [r12+rax*8]
   2171c:	shl    rcx,0x20
   21720:	or     rcx,rdx
   21723:	shr    rcx,0x18
   21727:	mov    rdx,QWORD PTR [r12+rcx*8]
   2172b:	mov    rbx,QWORD PTR [r12+rcx*8+0x8]
   21730:	mov    rsi,QWORD PTR [r13+0x0]
   21734:	mov    QWORD PTR [r12+rax*8],rsi
   21738:	mov    QWORD PTR [r13+0x0],rax
   2173c:	mov    rax,QWORD PTR [r13+0x100]
   21743:	inc    rax
   21746:	mov    QWORD PTR [r13+0x100],rax
   2174d:	cmp    BYTE PTR [rip+0x14193c],0x1        # 163090 <KEEP_WORDS>
   21754:	jne    26330 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x63f0>
   2175a:	cmp    rax,0x8000
   21760:	jae    26330 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x63f0>
   21766:	cmp    rcx,0x3108200
   2176d:	jb     217a6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1866>
   2176f:	mov    rax,QWORD PTR [r13+0x8]
   21773:	mov    QWORD PTR [r12+rcx*8],rax
   21777:	mov    QWORD PTR [r13+0x8],rcx
   2177b:	mov    rax,QWORD PTR [r13+0x108]
   21782:	add    rax,0x2
   21786:	mov    QWORD PTR [r13+0x108],rax
   2178d:	cmp    BYTE PTR [rip+0x1418fc],0x1        # 163090 <KEEP_WORDS>
   21794:	jne    25ca0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5d60>
   2179a:	cmp    rax,0x8000
   217a0:	jae    25ca0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5d60>
   217a6:	cmp    rbx,0x1
   217aa:	je     218a7 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1967>
   217b0:	movabs rax,0x7fffff0000000000
   217ba:	and    rax,rbx
   217bd:	movabs rcx,0x100020000000000
   217c7:	cmp    rax,rcx
   217ca:	je     218a7 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1967>
   217d0:	mov    rax,r14
   217d3:	mov    rcx,rdx
   217d6:	jmp    217ea <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x18aa>
   217d8:	nop    DWORD PTR [rax+rax*1+0x0]
   217e0:	cmp    rdi,0x4
   217e4:	jne    22541 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2601>
   217ea:	mov    rsi,rcx
   217ed:	shr    rsi,0x28
   217f1:	cmp    si,0x19
   217f5:	jne    230ef <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x31af>
   217fb:	mov    rdi,rcx
   217fe:	and    rdi,r10
   21801:	test   rcx,rcx
   21804:	jns    2182e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x18ee>
   21806:	mov    ecx,DWORD PTR [r12+rdi*8+0x4]
   2180b:	mov    esi,DWORD PTR [r12+rdi*8]
   2180f:	mov    ebx,esi
   21811:	and    ebx,0xffffff
   21817:	cmp    ebx,0x1
   2181a:	jne    21820 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x18e0>
   2181c:	mov    edi,DWORD PTR [r12+rdi*8]
   21820:	shl    rcx,0x20
   21824:	or     rcx,rsi
   21827:	shr    rcx,0x18
   2182b:	mov    rdi,rcx
   2182e:	mov    rcx,rax
   21831:	shr    rcx,0x28
   21835:	cmp    cx,0x19
   21839:	jne    235b1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3671>
   2183f:	mov    rsi,QWORD PTR [r12+rdi*8]
   21843:	mov    rcx,QWORD PTR [r12+rdi*8+0x8]
   21848:	mov    rdi,rax
   2184b:	and    rdi,r10
   2184e:	test   rax,rax
   21851:	jns    2187c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x193c>
   21853:	mov    eax,DWORD PTR [r12+rdi*8+0x4]
   21858:	mov    r8d,DWORD PTR [r12+rdi*8]
   2185c:	mov    ebx,r8d
   2185f:	and    ebx,0xffffff
   21865:	cmp    ebx,0x1
   21868:	jne    2186e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x192e>
   2186a:	mov    edi,DWORD PTR [r12+rdi*8]
   2186e:	shl    rax,0x20
   21872:	or     rax,r8
   21875:	shr    rax,0x18
   21879:	mov    rdi,rax
   2187c:	mov    ebx,DWORD PTR [r12+rdi*8]
   21880:	xor    r8d,r8d
   21883:	mov    rax,QWORD PTR [r12+rdi*8+0x8]
   21888:	mov    edi,0x3
   2188d:	cmp    esi,ebx
   2188f:	sete   bl
   21892:	jb     217e0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x18a0>
   21898:	mov    r8b,bl
   2189b:	xor    r8,0x5
   2189f:	mov    rdi,r8
   218a2:	jmp    217e0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x18a0>
   218a7:	mov    r15,QWORD PTR [rsp+0x30]
   218ac:	movabs rax,0x7e00000000000000
   218b6:	test   rdx,rax
   218b9:	sete   al
   218bc:	cmp    rdx,0xffffffffffffffff
   218c0:	sete   cl
   218c3:	or     cl,al
   218c5:	mov    rax,rdx
   218c8:	and    rax,rdi
   218cb:	cmp    rax,0x3108200
   218d1:	setb   al
   218d4:	or     al,cl
   218d6:	jne    218f2 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x19b2>
   218d8:	mov    rdi,r12
   218db:	mov    rsi,r13
   218de:	call   e8c0 <term_drop>
   218e3:	movabs rdi,0xfffffffe00
   218ed:	mov    r13,QWORD PTR [rsp+0x8]
   218f2:	cmp    rbx,0x1
   218f6:	mov    rbp,QWORD PTR [rsp+0x20]
   218fb:	je     21916 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x19d6>
   218fd:	movabs rax,0x100020000000000
   21907:	mov    rcx,rbx
   2190a:	and    rcx,rax
   2190d:	cmp    rcx,rax
   21910:	jne    2849c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x855c>
   21916:	mov    r8,QWORD PTR [r13+0x8]
   2191a:	test   r8,r8
   2191d:	je     25522 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x55e2>
   21923:	mov    rax,QWORD PTR [r12+r8*8]
   21927:	mov    QWORD PTR [r13+0x8],rax
   2192b:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   21933:	mov    rdx,QWORD PTR [rsp+0x28]
   21938:	movabs r10,0xff00000000000000
   21942:	mov    rax,r14
   21945:	shr    rax,0x38
   21949:	cmp    eax,0x2
   2194c:	je     2553a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x55fa>
   21952:	mov    QWORD PTR [r12+r8*8],r14
   21956:	mov    rax,rdx
   21959:	and    rax,r10
   2195c:	movabs rbx,0x200000000000000
   21966:	cmp    rax,rbx
   21969:	je     2555c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x561c>
   2196f:	mov    QWORD PTR [r12+r8*8+0x8],rdx
   21974:	movabs rcx,0x2002c0000000000
   2197e:	mov    rsi,QWORD PTR [rsp+0x8]
   21983:	mov    r9,QWORD PTR [rsi+0x10]
   21987:	test   r9,r9
   2198a:	je     25576 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5636>
   21990:	mov    rax,QWORD PTR [r12+r9*8]
   21994:	mov    QWORD PTR [rsi+0x10],rax
   21998:	add    QWORD PTR [rsi+0x110],0xfffffffffffffffc
   219a0:	or     r8,rcx
   219a3:	mov    rax,r15
   219a6:	and    rax,r10
   219a9:	cmp    rax,rbx
   219ac:	je     2558b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x564b>
   219b2:	mov    QWORD PTR [r12+r9*8],r15
   219b6:	mov    rax,r8
   219b9:	shr    rax,0x38
   219bd:	cmp    eax,0x2
   219c0:	jbe    255a8 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5668>
   219c6:	movabs r15,0x300000000000000
   219d0:	mov    QWORD PTR [r12+r9*8+0x8],r8
   219d5:	movabs rax,0x1002b0000000000
   219df:	mov    QWORD PTR [r12+r9*8+0x10],rax
   219e4:	movabs rcx,0x2002d0000000000
   219ee:	or     rcx,r9
   219f1:	mov    rsi,QWORD PTR [rsp+0x8]
   219f6:	mov    r8,QWORD PTR [rsi+0x8]
   219fa:	test   r8,r8
   219fd:	je     255c5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5685>
   21a03:	mov    rax,QWORD PTR [r12+r8*8]
   21a07:	mov    QWORD PTR [rsi+0x8],rax
   21a0b:	add    QWORD PTR [rsi+0x108],0xfffffffffffffffe
   21a13:	cmp    rcx,r15
   21a16:	jb     255de <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x569e>
   21a1c:	mov    r15d,DWORD PTR [rsp+0x14]
   21a21:	mov    QWORD PTR [r12+r8*8],rcx
   21a25:	and    r10,QWORD PTR [rsp+0x18]
   21a2a:	cmp    r10,rbx
   21a2d:	je     255fb <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x56bb>
   21a33:	mov    r13,QWORD PTR [rsp+0x8]
   21a38:	mov    rax,QWORD PTR [rsp+0x18]
   21a3d:	mov    QWORD PTR [r12+r8*8+0x8],rax
   21a42:	movabs rsi,0x200080000000000
   21a4c:	or     rsi,r8
   21a4f:	mov    eax,DWORD PTR [rbp-0x8]
   21a52:	add    rbp,0xfffffffffffffff8
   21a56:	lea    rcx,[rip+0x3ed63]        # 607c0 <wl_tab>
   21a5d:	mov    rax,QWORD PTR [rcx+rax*8]
   21a61:	mov    r14,rbp
   21a64:	mov    edi,0x1
   21a69:	add    rsp,0x80
   21a70:	pop    rbp
   21a71:	jmp    rax
   21a73:	mov    ecx,DWORD PTR [r12+rax*8+0x4]
   21a78:	mov    edx,DWORD PTR [r12+rax*8]
   21a7c:	mov    esi,edx
   21a7e:	and    esi,0xffffff
   21a84:	cmp    esi,0x1
   21a87:	jne    26066 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6126>
   21a8d:	mov    esi,DWORD PTR [r12+rax*8]
   21a91:	shl    rcx,0x20
   21a95:	or     rcx,rdx
   21a98:	shr    rcx,0x18
   21a9c:	mov    rdx,QWORD PTR [r12+rcx*8]
   21aa0:	mov    r9,QWORD PTR [r12+rcx*8+0x8]
   21aa5:	mov    rsi,QWORD PTR [r13+0x0]
   21aa9:	mov    QWORD PTR [r12+rax*8],rsi
   21aad:	mov    QWORD PTR [r13+0x0],rax
   21ab1:	mov    rax,QWORD PTR [r13+0x100]
   21ab8:	inc    rax
   21abb:	mov    QWORD PTR [r13+0x100],rax
   21ac2:	cmp    BYTE PTR [rip+0x1415c7],0x1        # 163090 <KEEP_WORDS>
   21ac9:	jne    26365 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6425>
   21acf:	cmp    rax,0x8000
   21ad5:	jae    26365 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6425>
   21adb:	cmp    rcx,0x3108200
   21ae2:	jb     21b1b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1bdb>
   21ae4:	mov    rax,QWORD PTR [r13+0x8]
   21ae8:	mov    QWORD PTR [r12+rcx*8],rax
   21aec:	mov    QWORD PTR [r13+0x8],rcx
   21af0:	mov    rax,QWORD PTR [r13+0x108]
   21af7:	add    rax,0x2
   21afb:	mov    QWORD PTR [r13+0x108],rax
   21b02:	cmp    BYTE PTR [rip+0x141587],0x1        # 163090 <KEEP_WORDS>
   21b09:	jne    25ccb <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5d8b>
   21b0f:	cmp    rax,0x8000
   21b15:	jae    25ccb <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5d8b>
   21b1b:	mov    rax,rbx
   21b1e:	mov    rcx,rdx
   21b21:	cmp    r9,0x1
   21b25:	je     21cca <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1d8a>
   21b2b:	movabs rax,0x7fffff0000000000
   21b35:	and    r9,rax
   21b38:	movabs rsi,0x100020000000000
   21b42:	mov    rax,rbx
   21b45:	mov    rcx,rdx
   21b48:	cmp    r9,rsi
   21b4b:	je     21cca <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1d8a>
   21b51:	movabs rax,0x7e00000000000000
   21b5b:	test   rdx,rax
   21b5e:	sete   al
   21b61:	cmp    rdx,0xffffffffffffffff
   21b65:	sete   cl
   21b68:	or     cl,al
   21b6a:	and    rdi,rdx
   21b6d:	cmp    rdi,0x3108200
   21b74:	setb   al
   21b77:	or     al,cl
   21b79:	jne    21b8b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1c4b>
   21b7b:	mov    rdi,r12
   21b7e:	mov    rsi,r13
   21b81:	call   e8c0 <term_drop>
   21b86:	mov    r13,QWORD PTR [rsp+0x8]
   21b8b:	mov    r8,QWORD PTR [r13+0x8]
   21b8f:	test   r8,r8
   21b92:	mov    r14,QWORD PTR [rsp+0x20]
   21b97:	je     25210 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x52d0>
   21b9d:	mov    rax,QWORD PTR [r12+r8*8]
   21ba1:	mov    QWORD PTR [r13+0x8],rax
   21ba5:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   21bad:	movabs r10,0xff00000000000000
   21bb7:	mov    rax,rbx
   21bba:	shr    rax,0x38
   21bbe:	cmp    eax,0x2
   21bc1:	je     25228 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x52e8>
   21bc7:	mov    QWORD PTR [r12+r8*8],rbx
   21bcb:	mov    rax,r15
   21bce:	and    rax,r10
   21bd1:	movabs rbx,0x200000000000000
   21bdb:	cmp    rax,rbx
   21bde:	je     25245 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5305>
   21be4:	mov    QWORD PTR [r12+r8*8+0x8],r15
   21be9:	movabs rcx,0x2002c0000000000
   21bf3:	mov    rsi,QWORD PTR [rsp+0x8]
   21bf8:	mov    r9,QWORD PTR [rsi+0x10]
   21bfc:	test   r9,r9
   21bff:	je     25262 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5322>
   21c05:	mov    rax,QWORD PTR [r12+r9*8]
   21c09:	mov    QWORD PTR [rsi+0x10],rax
   21c0d:	add    QWORD PTR [rsi+0x110],0xfffffffffffffffc
   21c15:	or     r8,rcx
   21c18:	mov    rax,QWORD PTR [rsp+0x30]
   21c1d:	and    rax,r10
   21c20:	cmp    rax,rbx
   21c23:	je     25277 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5337>
   21c29:	mov    rax,QWORD PTR [rsp+0x30]
   21c2e:	mov    QWORD PTR [r12+r9*8],rax
   21c32:	movabs rax,0x1002b0000000000
   21c3c:	mov    QWORD PTR [r12+r9*8+0x8],rax
   21c41:	mov    rax,r8
   21c44:	shr    rax,0x38
   21c48:	cmp    eax,0x2
   21c4b:	jbe    25298 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5358>
   21c51:	movabs r15,0x300000000000000
   21c5b:	mov    QWORD PTR [r12+r9*8+0x10],r8
   21c60:	movabs rcx,0x2002d0000000000
   21c6a:	or     rcx,r9
   21c6d:	mov    rsi,QWORD PTR [rsp+0x8]
   21c72:	mov    r8,QWORD PTR [rsi+0x8]
   21c76:	test   r8,r8
   21c79:	je     252b5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5375>
   21c7f:	mov    rax,QWORD PTR [r12+r8*8]
   21c83:	mov    QWORD PTR [rsi+0x8],rax
   21c87:	add    QWORD PTR [rsi+0x108],0xfffffffffffffffe
   21c8f:	cmp    rcx,r15
   21c92:	jb     252ce <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x538e>
   21c98:	mov    r15d,DWORD PTR [rsp+0x14]
   21c9d:	mov    QWORD PTR [r12+r8*8],rcx
   21ca1:	and    r10,QWORD PTR [rsp+0x18]
   21ca6:	cmp    r10,rbx
   21ca9:	je     252eb <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x53ab>
   21caf:	mov    r13,QWORD PTR [rsp+0x8]
   21cb4:	jmp    22290 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2350>
   21cb9:	nop    DWORD PTR [rax+0x0]
   21cc0:	cmp    rdi,0x4
   21cc4:	jne    22511 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x25d1>
   21cca:	mov    rsi,rcx
   21ccd:	shr    rsi,0x28
   21cd1:	cmp    si,0x19
   21cd5:	jne    23018 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x30d8>
   21cdb:	mov    rdi,rcx
   21cde:	and    rdi,r10
   21ce1:	test   rcx,rcx
   21ce4:	jns    21d11 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1dd1>
   21ce6:	mov    ecx,DWORD PTR [r12+rdi*8+0x4]
   21ceb:	mov    esi,DWORD PTR [r12+rdi*8]
   21cef:	mov    r8d,esi
   21cf2:	and    r8d,0xffffff
   21cf9:	cmp    r8d,0x1
   21cfd:	jne    21d03 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1dc3>
   21cff:	mov    edi,DWORD PTR [r12+rdi*8]
   21d03:	shl    rcx,0x20
   21d07:	or     rcx,rsi
   21d0a:	shr    rcx,0x18
   21d0e:	mov    rdi,rcx
   21d11:	mov    rcx,rax
   21d14:	shr    rcx,0x28
   21d18:	cmp    cx,0x19
   21d1c:	jne    231a0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3260>
   21d22:	mov    rsi,QWORD PTR [r12+rdi*8]
   21d26:	mov    rcx,QWORD PTR [r12+rdi*8+0x8]
   21d2b:	mov    rdi,rax
   21d2e:	and    rdi,r10
   21d31:	test   rax,rax
   21d34:	jns    21d61 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1e21>
   21d36:	mov    eax,DWORD PTR [r12+rdi*8+0x4]
   21d3b:	mov    r8d,DWORD PTR [r12+rdi*8]
   21d3f:	mov    r9d,r8d
   21d42:	and    r9d,0xffffff
   21d49:	cmp    r9d,0x1
   21d4d:	jne    21d53 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1e13>
   21d4f:	mov    edi,DWORD PTR [r12+rdi*8]
   21d53:	shl    rax,0x20
   21d57:	or     rax,r8
   21d5a:	shr    rax,0x18
   21d5e:	mov    rdi,rax
   21d61:	mov    r9d,DWORD PTR [r12+rdi*8]
   21d65:	xor    r8d,r8d
   21d68:	mov    rax,QWORD PTR [r12+rdi*8+0x8]
   21d6d:	mov    edi,0x3
   21d72:	cmp    esi,r9d
   21d75:	sete   sil
   21d79:	jb     21cc0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1d80>
   21d7f:	mov    r8b,sil
   21d82:	xor    r8,0x5
   21d86:	mov    rdi,r8
   21d89:	jmp    21cc0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1d80>
   21d8e:	mov    ecx,DWORD PTR [r12+rax*8+0x4]
   21d93:	mov    edx,DWORD PTR [r12+rax*8]
   21d97:	mov    esi,edx
   21d99:	and    esi,0xffffff
   21d9f:	cmp    esi,0x1
   21da2:	jne    260ac <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x616c>
   21da8:	mov    esi,DWORD PTR [r12+rax*8]
   21dac:	shl    rcx,0x20
   21db0:	or     rcx,rdx
   21db3:	shr    rcx,0x18
   21db7:	mov    r8,QWORD PTR [r12+rcx*8]
   21dbb:	mov    r15,QWORD PTR [r12+rcx*8+0x8]
   21dc0:	mov    rdx,QWORD PTR [r13+0x0]
   21dc4:	mov    QWORD PTR [r12+rax*8],rdx
   21dc8:	mov    QWORD PTR [r13+0x0],rax
   21dcc:	mov    rax,QWORD PTR [r13+0x100]
   21dd3:	inc    rax
   21dd6:	mov    QWORD PTR [r13+0x100],rax
   21ddd:	cmp    BYTE PTR [rip+0x1412ac],0x1        # 163090 <KEEP_WORDS>
   21de4:	jne    2639a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x645a>
   21dea:	cmp    rax,0x8000
   21df0:	jae    2639a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x645a>
   21df6:	cmp    rcx,0x3108200
   21dfd:	jb     21e36 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1ef6>
   21dff:	mov    rax,QWORD PTR [r13+0x8]
   21e03:	mov    QWORD PTR [r12+rcx*8],rax
   21e07:	mov    QWORD PTR [r13+0x8],rcx
   21e0b:	mov    rax,QWORD PTR [r13+0x108]
   21e12:	add    rax,0x2
   21e16:	mov    QWORD PTR [r13+0x108],rax
   21e1d:	cmp    BYTE PTR [rip+0x14126c],0x1        # 163090 <KEEP_WORDS>
   21e24:	jne    25cf6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5db6>
   21e2a:	cmp    rax,0x8000
   21e30:	jae    25cf6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5db6>
   21e36:	cmp    r15,0x1
   21e3a:	je     21e99 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1f59>
   21e3c:	movabs rax,0x7fffff0000000000
   21e46:	and    rax,r15
   21e49:	movabs rcx,0x100020000000000
   21e53:	cmp    rax,rcx
   21e56:	je     21e99 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1f59>
   21e58:	mov    QWORD PTR [rsp+0x38],r8
   21e5d:	mov    QWORD PTR [rsp+0x40],r14
   21e62:	movabs r15,0x1002b0000000000
   21e6c:	cmp    DWORD PTR [rsp+0x14],0x0
   21e71:	je     22c74 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2d34>
   21e77:	mov    r14,QWORD PTR [rsp+0x20]
   21e7c:	mov    rax,QWORD PTR [rsp+0x30]
   21e81:	mov    QWORD PTR [r14],rax
   21e84:	mov    QWORD PTR [r14+0x8],r15
   21e88:	mov    QWORD PTR [r14+0x10],0xb6
   21e90:	add    r14,0x18
   21e94:	jmp    22cd9 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2d99>
   21e99:	mov    rbp,r14
   21e9c:	movabs r14,0x7e00000000000000
   21ea6:	test   r8,r14
   21ea9:	sete   al
   21eac:	cmp    r8,0xffffffffffffffff
   21eb0:	sete   cl
   21eb3:	or     cl,al
   21eb5:	mov    rax,r8
   21eb8:	and    rax,rdi
   21ebb:	cmp    rax,0x3108200
   21ec1:	setb   al
   21ec4:	or     al,cl
   21ec6:	jne    21eeb <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1fab>
   21ec8:	mov    rdi,r12
   21ecb:	mov    rsi,r13
   21ece:	mov    rdx,r8
   21ed1:	mov    rbx,r9
   21ed4:	call   e8c0 <term_drop>
   21ed9:	mov    r9,rbx
   21edc:	movabs rdi,0xfffffffe00
   21ee6:	mov    r13,QWORD PTR [rsp+0x8]
   21eeb:	cmp    r15,0x1
   21eef:	je     21f0a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1fca>
   21ef1:	movabs rax,0x100020000000000
   21efb:	mov    rcx,r15
   21efe:	and    rcx,rax
   21f01:	cmp    rcx,rax
   21f04:	jne    28675 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8735>
   21f0a:	mov    r8,QWORD PTR [r13+0x10]
   21f0e:	test   r8,r8
   21f11:	mov    rcx,QWORD PTR [rsp+0x28]
   21f16:	je     2561a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x56da>
   21f1c:	mov    rax,QWORD PTR [r12+r8*8]
   21f20:	mov    QWORD PTR [r13+0x10],rax
   21f24:	add    QWORD PTR [r13+0x110],0xfffffffffffffffc
   21f2c:	mov    r14,QWORD PTR [rsp+0x20]
   21f31:	movabs rbx,0xff00000000000000
   21f3b:	mov    rax,rcx
   21f3e:	shr    rax,0x38
   21f42:	cmp    eax,0x2
   21f45:	je     25632 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x56f2>
   21f4b:	mov    QWORD PTR [r12+r8*8],rcx
   21f4f:	mov    rax,r9
   21f52:	and    rax,rbx
   21f55:	movabs r15,0x200000000000000
   21f5f:	cmp    rax,r15
   21f62:	je     2564d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x570d>
   21f68:	mov    QWORD PTR [r12+r8*8+0x8],r9
   21f6d:	mov    rax,rbp
   21f70:	and    rax,rbx
   21f73:	cmp    rax,r15
   21f76:	je     25668 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5728>
   21f7c:	movabs r9,0x2002d0000000000
   21f86:	mov    QWORD PTR [r12+r8*8+0x10],rbp
   21f8b:	mov    rsi,r13
   21f8e:	mov    r10,QWORD PTR [r13+0x10]
   21f92:	test   r10,r10
   21f95:	je     25683 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5743>
   21f9b:	mov    rax,QWORD PTR [r12+r10*8]
   21f9f:	mov    QWORD PTR [rsi+0x10],rax
   21fa3:	add    QWORD PTR [rsi+0x110],0xfffffffffffffffc
   21fab:	mov    rdx,QWORD PTR [rsp+0x30]
   21fb0:	or     r8,r9
   21fb3:	mov    rax,rdx
   21fb6:	and    rax,rbx
   21fb9:	cmp    rax,r15
   21fbc:	je     25698 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5758>
   21fc2:	mov    QWORD PTR [r12+r10*8],rdx
   21fc6:	mov    rax,r8
   21fc9:	shr    rax,0x38
   21fcd:	cmp    eax,0x2
   21fd0:	jbe    256b2 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5772>
   21fd6:	movabs rcx,0x300000000000000
   21fe0:	mov    QWORD PTR [r12+r10*8+0x8],r8
   21fe5:	movabs rax,0x1002b0000000000
   21fef:	mov    QWORD PTR [r12+r10*8+0x10],rax
   21ff4:	or     r9,r10
   21ff7:	mov    r13,QWORD PTR [rsp+0x8]
   21ffc:	mov    r8,QWORD PTR [r13+0x8]
   22000:	test   r8,r8
   22003:	je     256cf <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x578f>
   22009:	mov    rax,QWORD PTR [r12+r8*8]
   2200d:	mov    QWORD PTR [r13+0x8],rax
   22011:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   22019:	cmp    r9,rcx
   2201c:	jb     256eb <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x57ab>
   22022:	mov    QWORD PTR [r12+r8*8],r9
   22026:	and    rbx,QWORD PTR [rsp+0x18]
   2202b:	cmp    rbx,r15
   2202e:	je     25713 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x57d3>
   22034:	mov    r15d,DWORD PTR [rsp+0x14]
   22039:	jmp    22290 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2350>
   2203e:	mov    r9,rsi
   22041:	mov    ecx,DWORD PTR [r12+rdx*8+0x4]
   22046:	mov    eax,DWORD PTR [r12+rdx*8]
   2204a:	mov    esi,eax
   2204c:	and    esi,0xffffff
   22052:	cmp    esi,0x1
   22055:	jne    260e6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x61a6>
   2205b:	mov    esi,DWORD PTR [r12+rdx*8]
   2205f:	shl    rcx,0x20
   22063:	or     rcx,rax
   22066:	shr    rcx,0x18
   2206a:	mov    rbx,QWORD PTR [r12+rcx*8]
   2206e:	mov    rax,QWORD PTR [r12+rcx*8+0x8]
   22073:	mov    rsi,QWORD PTR [r13+0x0]
   22077:	mov    QWORD PTR [r12+rdx*8],rsi
   2207b:	mov    QWORD PTR [r13+0x0],rdx
   2207f:	mov    rdx,QWORD PTR [r13+0x100]
   22086:	inc    rdx
   22089:	mov    QWORD PTR [r13+0x100],rdx
   22090:	cmp    BYTE PTR [rip+0x140ff9],0x1        # 163090 <KEEP_WORDS>
   22097:	jne    263c3 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6483>
   2209d:	cmp    rdx,0x8000
   220a4:	jae    263c3 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6483>
   220aa:	mov    rsi,r9
   220ad:	cmp    rcx,0x3108200
   220b4:	jb     220ee <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x21ae>
   220b6:	mov    rdx,QWORD PTR [r13+0x8]
   220ba:	mov    QWORD PTR [r12+rcx*8],rdx
   220be:	mov    QWORD PTR [r13+0x8],rcx
   220c2:	mov    rcx,QWORD PTR [r13+0x108]
   220c9:	add    rcx,0x2
   220cd:	mov    QWORD PTR [r13+0x108],rcx
   220d4:	cmp    BYTE PTR [rip+0x140fb5],0x1        # 163090 <KEEP_WORDS>
   220db:	jne    25d0b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5dcb>
   220e1:	cmp    rcx,0x8000
   220e8:	jae    25d0b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5dcb>
   220ee:	movabs r11,0x1002b0000000000
   220f8:	cmp    rax,0x1
   220fc:	je     2229f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x235f>
   22102:	movabs rcx,0x7fffff0000000000
   2210c:	and    rax,rcx
   2210f:	movabs rcx,0x100020000000000
   22119:	cmp    rax,rcx
   2211c:	je     2229f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x235f>
   22122:	movabs rax,0x7e00000000000000
   2212c:	test   rbx,rax
   2212f:	sete   al
   22132:	cmp    rbx,0xffffffffffffffff
   22136:	sete   cl
   22139:	or     cl,al
   2213b:	and    rdi,rbx
   2213e:	cmp    rdi,0x3108200
   22145:	setb   al
   22148:	or     al,cl
   2214a:	jne    2216b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x222b>
   2214c:	mov    rdi,r12
   2214f:	mov    r14,rsi
   22152:	mov    rsi,r13
   22155:	mov    rdx,rbx
   22158:	mov    rbx,r11
   2215b:	call   e8c0 <term_drop>
   22160:	mov    r11,rbx
   22163:	mov    rsi,r14
   22166:	mov    r13,QWORD PTR [rsp+0x8]
   2216b:	mov    r8,QWORD PTR [r13+0x10]
   2216f:	test   r8,r8
   22172:	je     252f8 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x53b8>
   22178:	mov    rax,QWORD PTR [r12+r8*8]
   2217c:	mov    QWORD PTR [r13+0x10],rax
   22180:	add    QWORD PTR [r13+0x110],0xfffffffffffffffc
   22188:	mov    rdx,QWORD PTR [rsp+0x28]
   2218d:	movabs rbx,0xff00000000000000
   22197:	mov    rax,rsi
   2219a:	shr    rax,0x38
   2219e:	cmp    eax,0x2
   221a1:	je     2531c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x53dc>
   221a7:	mov    r14,QWORD PTR [rsp+0x30]
   221ac:	mov    QWORD PTR [r12+r8*8],rsi
   221b0:	mov    rax,r15
   221b3:	and    rax,rbx
   221b6:	movabs rbp,0x200000000000000
   221c0:	cmp    rax,rbp
   221c3:	je     25347 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5407>
   221c9:	mov    QWORD PTR [r12+r8*8+0x8],r15
   221ce:	mov    rax,rdx
   221d1:	and    rax,rbx
   221d4:	cmp    rax,rbp
   221d7:	je     2536d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x542d>
   221dd:	movabs r9,0x2002d0000000000
   221e7:	mov    QWORD PTR [r12+r8*8+0x10],rdx
   221ec:	mov    rsi,r13
   221ef:	mov    r10,QWORD PTR [r13+0x10]
   221f3:	test   r10,r10
   221f6:	je     2538b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x544b>
   221fc:	mov    rax,QWORD PTR [r12+r10*8]
   22200:	mov    QWORD PTR [rsi+0x10],rax
   22204:	add    QWORD PTR [rsi+0x110],0xfffffffffffffffc
   2220c:	or     r8,r9
   2220f:	mov    rax,r14
   22212:	and    rax,rbx
   22215:	cmp    rax,rbp
   22218:	je     253a6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5466>
   2221e:	mov    QWORD PTR [r12+r10*8],r14
   22222:	mov    QWORD PTR [r12+r10*8+0x8],r11
   22227:	mov    rax,r8
   2222a:	shr    rax,0x38
   2222e:	cmp    eax,0x2
   22231:	jbe    253c9 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5489>
   22237:	mov    r14,QWORD PTR [rsp+0x20]
   2223c:	mov    r15d,DWORD PTR [rsp+0x14]
   22241:	movabs rcx,0x300000000000000
   2224b:	mov    QWORD PTR [r12+r10*8+0x10],r8
   22250:	or     r9,r10
   22253:	mov    r13,QWORD PTR [rsp+0x8]
   22258:	mov    r8,QWORD PTR [r13+0x8]
   2225c:	test   r8,r8
   2225f:	je     253e6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x54a6>
   22265:	mov    rax,QWORD PTR [r12+r8*8]
   22269:	mov    QWORD PTR [r13+0x8],rax
   2226d:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   22275:	cmp    r9,rcx
   22278:	jb     25402 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x54c2>
   2227e:	mov    QWORD PTR [r12+r8*8],r9
   22282:	and    rbx,QWORD PTR [rsp+0x18]
   22287:	cmp    rbx,rbp
   2228a:	je     2542a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x54ea>
   22290:	mov    rax,QWORD PTR [rsp+0x18]
   22295:	mov    QWORD PTR [r12+r8*8+0x8],rax
   2229a:	jmp    20062 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x122>
   2229f:	cmp    DWORD PTR [rsp+0x14],0x0
   222a4:	je     2298c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2a4c>
   222aa:	mov    r14,QWORD PTR [rsp+0x20]
   222af:	mov    rax,QWORD PTR [rsp+0x30]
   222b4:	mov    QWORD PTR [r14],rax
   222b7:	mov    QWORD PTR [r14+0x8],r11
   222bb:	mov    QWORD PTR [r14+0x10],0xa4
   222c3:	add    r14,0x18
   222c7:	jmp    22a01 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2ac1>
   222cc:	mov    ecx,DWORD PTR [r12+r10*8+0x4]
   222d1:	mov    eax,DWORD PTR [r12+r10*8]
   222d5:	mov    edx,eax
   222d7:	and    edx,0xffffff
   222dd:	cmp    edx,0x1
   222e0:	jne    26120 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x61e0>
   222e6:	mov    edx,DWORD PTR [r12+r10*8]
   222ea:	shl    rcx,0x20
   222ee:	or     rcx,rax
   222f1:	shr    rcx,0x18
   222f5:	mov    rdx,QWORD PTR [r12+rcx*8]
   222f9:	mov    r15,QWORD PTR [r12+rcx*8+0x8]
   222fe:	mov    rax,QWORD PTR [r13+0x0]
   22302:	mov    QWORD PTR [r12+r10*8],rax
   22306:	mov    QWORD PTR [r13+0x0],r10
   2230a:	mov    rax,QWORD PTR [r13+0x100]
   22311:	inc    rax
   22314:	mov    QWORD PTR [r13+0x100],rax
   2231b:	cmp    BYTE PTR [rip+0x140d6e],0x1        # 163090 <KEEP_WORDS>
   22322:	jne    263ef <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x64af>
   22328:	cmp    rax,0x8000
   2232e:	jae    263ef <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x64af>
   22334:	cmp    rcx,0x3108200
   2233b:	jb     22374 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2434>
   2233d:	mov    rax,QWORD PTR [r13+0x8]
   22341:	mov    QWORD PTR [r12+rcx*8],rax
   22345:	mov    QWORD PTR [r13+0x8],rcx
   22349:	mov    rax,QWORD PTR [r13+0x108]
   22350:	add    rax,0x2
   22354:	mov    QWORD PTR [r13+0x108],rax
   2235b:	cmp    BYTE PTR [rip+0x140d2e],0x1        # 163090 <KEEP_WORDS>
   22362:	jne    25d30 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5df0>
   22368:	cmp    rax,0x8000
   2236e:	jae    25d30 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5df0>
   22374:	movabs rax,0x7e00000000000000
   2237e:	test   rdx,rax
   22381:	sete   al
   22384:	cmp    rdx,0xffffffffffffffff
   22388:	sete   cl
   2238b:	or     cl,al
   2238d:	and    rdi,rdx
   22390:	cmp    rdi,0x3108200
   22397:	setb   al
   2239a:	or     al,cl
   2239c:	jne    223ab <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x246b>
   2239e:	mov    rdi,r12
   223a1:	mov    rsi,QWORD PTR [rsp+0x8]
   223a6:	call   e8c0 <term_drop>
   223ab:	movabs r10,0xff00000000000000
   223b5:	movabs rbx,0x300000000000000
   223bf:	movabs r8,0x2002d0000000000
   223c9:	movabs rsi,0x200080000000000
   223d3:	movabs r14,0x1002b0000000000
   223dd:	mov    rax,QWORD PTR [rsp+0x8]
   223e2:	mov    r9,QWORD PTR [rax+0x10]
   223e6:	cmp    r15,0x1
   223ea:	je     22406 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x24c6>
   223ec:	movabs rax,0x7fffff0000000000
   223f6:	and    r15,rax
   223f9:	movabs rax,0x100020000000000
   22403:	cmp    r15,rax
   22406:	test   r9,r9
   22409:	je     24b11 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4bd1>
   2240f:	mov    rax,QWORD PTR [r12+r9*8]
   22413:	mov    rcx,QWORD PTR [rsp+0x8]
   22418:	mov    QWORD PTR [rcx+0x10],rax
   2241c:	add    QWORD PTR [rcx+0x110],0xfffffffffffffffc
   22424:	mov    rax,QWORD PTR [rsp+0x30]
   22429:	and    rax,r10
   2242c:	movabs r15,0x200000000000000
   22436:	cmp    rax,r15
   22439:	je     24b31 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4bf1>
   2243f:	mov    rax,QWORD PTR [rsp+0x30]
   22444:	mov    QWORD PTR [r12+r9*8],rax
   22448:	mov    QWORD PTR [r12+r9*8+0x8],r14
   2244d:	mov    QWORD PTR [r12+r9*8+0x10],r14
   22452:	or     r8,r9
   22455:	mov    rdx,QWORD PTR [rsp+0x8]
   2245a:	mov    r9,QWORD PTR [rdx+0x8]
   2245e:	test   r9,r9
   22461:	je     24b58 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4c18>
   22467:	mov    rax,QWORD PTR [r12+r9*8]
   2246b:	mov    QWORD PTR [rdx+0x8],rax
   2246f:	add    QWORD PTR [rdx+0x108],0xfffffffffffffffe
   22477:	cmp    r8,rbx
   2247a:	jb     24b7a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4c3a>
   22480:	mov    QWORD PTR [r12+r9*8],r8
   22484:	mov    rax,QWORD PTR [rsp+0x18]
   22489:	and    r10,rax
   2248c:	cmp    r10,r15
   2248f:	je     24b9d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4c5d>
   22495:	mov    r14,QWORD PTR [rsp+0x20]
   2249a:	mov    r13,QWORD PTR [rsp+0x8]
   2249f:	mov    r15d,DWORD PTR [rsp+0x14]
   224a4:	mov    QWORD PTR [r12+r9*8+0x8],rax
   224a9:	or     rsi,r9
   224ac:	jmp    2006f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x12f>
   224b1:	mov    rdi,r12
   224b4:	mov    rsi,r13
   224b7:	mov    edx,0x2
   224bc:	mov    rax,r11
   224bf:	call   5e231 <heap_hand>
   224c4:	jmp    22594 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2654>
   224c9:	cmp    esi,0x3
   224cc:	jne    2315b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x321b>
   224d2:	movabs r10,0x100030000000000
   224dc:	jmp    236a5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3765>
   224e1:	cmp    esi,0x3
   224e4:	jne    23176 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3236>
   224ea:	movabs r9,0x100030000000000
   224f4:	jmp    23a8b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3b4b>
   224f9:	cmp    esi,0x3
   224fc:	jne    23191 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3251>
   22502:	movabs r10,0x100030000000000
   2250c:	jmp    23eaa <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3f6a>
   22511:	cmp    edi,0x3
   22514:	jne    231ac <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x326c>
   2251a:	movabs r9,0x100030000000000
   22524:	jmp    2428d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x434d>
   22529:	cmp    esi,0x3
   2252c:	jne    231c7 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3287>
   22532:	movabs r9,0x100030000000000
   2253c:	jmp    231d1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3291>
   22541:	cmp    edi,0x3
   22544:	jne    235bd <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x367d>
   2254a:	movabs r9,0x100030000000000
   22554:	jmp    246d3 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4793>
   22559:	shl    rcx,0x20
   2255d:	or     rcx,rdx
   22560:	shr    rcx,0x18
   22564:	mov    rax,QWORD PTR [r12+rcx*8]
   22568:	mov    QWORD PTR [rsp+0x30],rax
   2256d:	mov    rbx,QWORD PTR [r12+rcx*8+0x8]
   22572:	mov    r15,QWORD PTR [r12+rcx*8+0x10]
   22577:	mov    rdi,r12
   2257a:	mov    rsi,r13
   2257d:	mov    rdx,rbp
   22580:	mov    r9,r8
   22583:	mov    r8d,0x3
   22589:	mov    rax,r11
   2258c:	call   5e2c2 <span_fade>
   22591:	mov    r8,r9
   22594:	mov    r11,rax
   22597:	movabs rdi,0xfffffffe00
   225a1:	jmp    20143 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x203>
   225a6:	mov    rbp,QWORD PTR [rsp+0x20]
   225ab:	mov    rcx,QWORD PTR [rbp-0x18]
   225af:	mov    r8d,DWORD PTR [rbp-0x10]
   225b3:	mov    rdi,r12
   225b6:	mov    rsi,r13
   225b9:	mov    edx,0xaf
   225be:	mov    r9d,0x1
   225c4:	call   ed60 <task_node>
   225c9:	mov    r13,QWORD PTR [rsp+0x8]
   225ce:	mov    rcx,QWORD PTR [rsp+0x30]
   225d3:	mov    QWORD PTR [r12+rax*8],rcx
   225d7:	mov    QWORD PTR [r12+rax*8+0x8],rbx
   225dc:	movabs rcx,0x500af0000000000
   225e6:	or     rcx,rax
   225e9:	mov    QWORD PTR [rbp-0x18],rcx
   225ed:	mov    QWORD PTR [rbp-0x10],0x2
   225f5:	mov    rdi,r12
   225f8:	mov    rsi,r13
   225fb:	mov    rdx,QWORD PTR [rsp+0x38]
   22600:	call   5c510 <term_keep>
   22605:	mov    r13,QWORD PTR [rsp+0x8]
   2260a:	mov    rbx,rax
   2260d:	mov    r8,QWORD PTR [r13+0x10]
   22611:	test   r8,r8
   22614:	je     24d2e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4dee>
   2261a:	mov    rax,QWORD PTR [r12+r8*8]
   2261e:	mov    QWORD PTR [r13+0x10],rax
   22622:	add    QWORD PTR [r13+0x110],0xfffffffffffffffc
   2262a:	mov    rcx,rbx
   2262d:	and    rcx,r14
   22630:	mov    rax,rbx
   22633:	cmp    rcx,r15
   22636:	mov    rcx,QWORD PTR [rsp+0x48]
   2263b:	je     24d46 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4e06>
   22641:	mov    QWORD PTR [r12+r8*8],rax
   22645:	mov    rax,rcx
   22648:	and    rax,r14
   2264b:	cmp    rax,r15
   2264e:	je     24d63 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4e23>
   22654:	mov    QWORD PTR [r12+r8*8+0x8],rcx
   22659:	and    r14,QWORD PTR [rsp+0x58]
   2265e:	cmp    r14,r15
   22661:	je     24d8c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4e4c>
   22667:	mov    r14,QWORD PTR [rsp+0x20]
   2266c:	movabs rbp,0x2002d0000000000
   22676:	or     rbp,r8
   22679:	mov    rax,QWORD PTR [rsp+0x58]
   2267e:	mov    QWORD PTR [r12+r8*8+0x10],rax
   22683:	mov    r15d,DWORD PTR [rsp+0x14]
   22688:	test   r15d,r15d
   2268b:	je     226a7 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2767>
   2268d:	mov    QWORD PTR [r14],rbp
   22690:	mov    rax,QWORD PTR [rsp+0x18]
   22695:	mov    QWORD PTR [r14+0x8],rax
   22699:	mov    QWORD PTR [r14+0x10],0xb0
   226a1:	add    r14,0x18
   226a5:	jmp    226ef <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x27af>
   226a7:	mov    rcx,QWORD PTR [r14-0x18]
   226ab:	mov    r8d,DWORD PTR [r14-0x10]
   226af:	mov    rdi,r12
   226b2:	mov    rsi,r13
   226b5:	mov    edx,0xb0
   226ba:	mov    r9d,0x1
   226c0:	call   ed60 <task_node>
   226c5:	mov    QWORD PTR [r12+rax*8],rbp
   226c9:	mov    rcx,QWORD PTR [rsp+0x18]
   226ce:	mov    QWORD PTR [r12+rax*8+0x8],rcx
   226d3:	movabs rcx,0x500b00000000000
   226dd:	or     rcx,rax
   226e0:	mov    QWORD PTR [r14-0x18],rcx
   226e4:	mov    QWORD PTR [r14-0x10],0x2
   226ec:	xor    r15d,r15d
   226ef:	mov    rsi,QWORD PTR [rsp+0x40]
   226f4:	mov    rdx,rbx
   226f7:	add    rsp,0x80
   226fe:	pop    rbp
   226ff:	jmp    1db20 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_>
   22704:	mov    r14,QWORD PTR [rsp+0x20]
   22709:	mov    rcx,QWORD PTR [r14-0x18]
   2270d:	mov    r8d,DWORD PTR [r14-0x10]
   22711:	mov    rdi,r12
   22714:	mov    rsi,r13
   22717:	mov    edx,0xc0
   2271c:	mov    r9d,0x1
   22722:	call   ed60 <task_node>
   22727:	mov    r13,QWORD PTR [rsp+0x8]
   2272c:	mov    rcx,QWORD PTR [rsp+0x30]
   22731:	mov    QWORD PTR [r12+rax*8],rcx
   22735:	mov    QWORD PTR [r12+rax*8+0x8],rbx
   2273a:	movabs rcx,0x500c00000000000
   22744:	or     rcx,rax
   22747:	mov    QWORD PTR [r14-0x18],rcx
   2274b:	mov    QWORD PTR [r14-0x10],0x2
   22753:	mov    rdi,r12
   22756:	mov    rsi,r13
   22759:	mov    rdx,rbp
   2275c:	call   5c510 <term_keep>
   22761:	mov    r13,QWORD PTR [rsp+0x8]
   22766:	mov    rbx,rax
   22769:	mov    r8,QWORD PTR [r13+0x10]
   2276d:	test   r8,r8
   22770:	je     24e55 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4f15>
   22776:	mov    rax,QWORD PTR [r12+r8*8]
   2277a:	mov    QWORD PTR [r13+0x10],rax
   2277e:	add    QWORD PTR [r13+0x110],0xfffffffffffffffc
   22786:	mov    r9,QWORD PTR [rsp+0x38]
   2278b:	movabs r10,0x200000000000000
   22795:	mov    rcx,rbx
   22798:	and    rcx,r15
   2279b:	mov    rax,rbx
   2279e:	cmp    rcx,r10
   227a1:	mov    rcx,QWORD PTR [rsp+0x58]
   227a6:	movabs rdx,0x2002d0000000000
   227b0:	je     24e6d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4f2d>
   227b6:	mov    QWORD PTR [r12+r8*8],rax
   227ba:	mov    rax,r9
   227bd:	and    rax,r15
   227c0:	cmp    rax,r10
   227c3:	je     24e94 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4f54>
   227c9:	mov    QWORD PTR [r12+r8*8+0x8],r9
   227ce:	and    r15,rcx
   227d1:	cmp    r15,r10
   227d4:	je     24eca <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4f8a>
   227da:	mov    r14,QWORD PTR [rsp+0x20]
   227df:	mov    r15d,DWORD PTR [rsp+0x14]
   227e4:	or     rdx,r8
   227e7:	mov    QWORD PTR [r12+r8*8+0x10],rcx
   227ec:	test   r15d,r15d
   227ef:	je     2280a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x28ca>
   227f1:	mov    QWORD PTR [r14],rdx
   227f4:	mov    rax,QWORD PTR [rsp+0x18]
   227f9:	mov    QWORD PTR [r14+0x8],rax
   227fd:	mov    QWORD PTR [r14+0x10],0xc1
   22805:	jmp    22c0e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2cce>
   2280a:	mov    rcx,QWORD PTR [r14-0x18]
   2280e:	mov    r8d,DWORD PTR [r14-0x10]
   22812:	mov    r15,rdx
   22815:	mov    rdi,r12
   22818:	mov    rsi,r13
   2281b:	mov    edx,0xc1
   22820:	mov    r9d,0x1
   22826:	call   ed60 <task_node>
   2282b:	mov    QWORD PTR [r12+rax*8],r15
   2282f:	mov    rcx,QWORD PTR [rsp+0x18]
   22834:	mov    QWORD PTR [r12+rax*8+0x8],rcx
   22839:	movabs rcx,0x500c10000000000
   22843:	jmp    22c4d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2d0d>
   22848:	mov    rbp,QWORD PTR [rsp+0x20]
   2284d:	mov    rcx,QWORD PTR [rbp-0x18]
   22851:	mov    r8d,DWORD PTR [rbp-0x10]
   22855:	mov    rdi,r12
   22858:	mov    rsi,r13
   2285b:	mov    edx,0xba
   22860:	mov    r9d,0x1
   22866:	call   ed60 <task_node>
   2286b:	mov    r13,QWORD PTR [rsp+0x8]
   22870:	mov    rcx,QWORD PTR [rsp+0x30]
   22875:	mov    QWORD PTR [r12+rax*8],rcx
   22879:	mov    QWORD PTR [r12+rax*8+0x8],rbx
   2287e:	movabs rcx,0x500ba0000000000
   22888:	or     rcx,rax
   2288b:	mov    QWORD PTR [rbp-0x18],rcx
   2288f:	mov    rdx,QWORD PTR [rsp+0x28]
   22894:	mov    QWORD PTR [rbp-0x10],0x2
   2289c:	movabs rbp,0x200000000000000
   228a6:	mov    rdi,r12
   228a9:	mov    rsi,r13
   228ac:	call   5c510 <term_keep>
   228b1:	mov    r13,QWORD PTR [rsp+0x8]
   228b6:	mov    rbx,rax
   228b9:	mov    r8,QWORD PTR [r13+0x10]
   228bd:	test   r8,r8
   228c0:	je     2504c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x510c>
   228c6:	mov    rax,QWORD PTR [r12+r8*8]
   228ca:	mov    QWORD PTR [r13+0x10],rax
   228ce:	add    QWORD PTR [r13+0x110],0xfffffffffffffffc
   228d6:	mov    rcx,rbx
   228d9:	and    rcx,r14
   228dc:	mov    rax,rbx
   228df:	cmp    rcx,rbp
   228e2:	je     25064 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5124>
   228e8:	mov    QWORD PTR [r12+r8*8],rax
   228ec:	mov    rax,r15
   228ef:	and    rax,r14
   228f2:	cmp    rax,rbp
   228f5:	je     2507c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x513c>
   228fb:	mov    QWORD PTR [r12+r8*8+0x8],r15
   22900:	and    r14,QWORD PTR [rsp+0x40]
   22905:	cmp    r14,rbp
   22908:	je     250a5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5165>
   2290e:	mov    r14,QWORD PTR [rsp+0x20]
   22913:	movabs rbp,0x2002d0000000000
   2291d:	or     rbp,r8
   22920:	mov    rax,QWORD PTR [rsp+0x40]
   22925:	mov    QWORD PTR [r12+r8*8+0x10],rax
   2292a:	mov    r15d,DWORD PTR [rsp+0x14]
   2292f:	test   r15d,r15d
   22932:	je     22951 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2a11>
   22934:	mov    QWORD PTR [r14],rbp
   22937:	mov    rax,QWORD PTR [rsp+0x18]
   2293c:	mov    QWORD PTR [r14+0x8],rax
   22940:	mov    QWORD PTR [r14+0x10],0xbb
   22948:	add    r14,0x18
   2294c:	jmp    22eab <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2f6b>
   22951:	mov    rcx,QWORD PTR [r14-0x18]
   22955:	mov    r8d,DWORD PTR [r14-0x10]
   22959:	mov    rdi,r12
   2295c:	mov    rsi,r13
   2295f:	mov    edx,0xbb
   22964:	mov    r9d,0x1
   2296a:	call   ed60 <task_node>
   2296f:	mov    QWORD PTR [r12+rax*8],rbp
   22973:	mov    rcx,QWORD PTR [rsp+0x18]
   22978:	mov    QWORD PTR [r12+rax*8+0x8],rcx
   2297d:	movabs rcx,0x500bb0000000000
   22987:	jmp    22e99 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2f59>
   2298c:	mov    r14,QWORD PTR [rsp+0x20]
   22991:	mov    rcx,QWORD PTR [r14-0x18]
   22995:	mov    r8d,DWORD PTR [r14-0x10]
   22999:	mov    rdi,r12
   2299c:	mov    rbp,r15
   2299f:	mov    r15,rsi
   229a2:	mov    rsi,r13
   229a5:	mov    edx,0xa4
   229aa:	mov    r9d,0x1
   229b0:	mov    r13,r10
   229b3:	call   ed60 <task_node>
   229b8:	mov    rsi,r15
   229bb:	mov    r15,rbp
   229be:	mov    r10,r13
   229c1:	movabs rdi,0xfffffffe00
   229cb:	mov    r13,QWORD PTR [rsp+0x8]
   229d0:	mov    rcx,QWORD PTR [rsp+0x30]
   229d5:	mov    QWORD PTR [r12+rax*8],rcx
   229d9:	movabs rcx,0x1002b0000000000
   229e3:	mov    QWORD PTR [r12+rax*8+0x8],rcx
   229e8:	movabs rcx,0x500a40000000000
   229f2:	or     rcx,rax
   229f5:	mov    QWORD PTR [r14-0x18],rcx
   229f9:	mov    QWORD PTR [r14-0x10],0x2
   22a01:	test   rsi,rsi
   22a04:	js     22a39 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2af9>
   22a06:	mov    rax,rsi
   22a09:	shr    rax,0x39
   22a0d:	sete   al
   22a10:	and    rdi,rsi
   22a13:	cmp    rdi,0x3108200
   22a1a:	setb   cl
   22a1d:	or     cl,al
   22a1f:	jne    22a54 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2b14>
   22a21:	mov    rdi,r12
   22a24:	mov    rdx,rsi
   22a27:	mov    rsi,r13
   22a2a:	mov    ecx,0x2
   22a2f:	call   5e661 <rfc_wrap>
   22a34:	mov    rsi,rax
   22a37:	jmp    22a54 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2b14>
   22a39:	and    r10,rsi
   22a3c:	mov    eax,0x1
   22a41:	lock xadd DWORD PTR [r12+r10*8],eax
   22a47:	not    eax
   22a49:	test   eax,0xfffffe
   22a4e:	je     28ddd <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e9d>
   22a54:	mov    r8,QWORD PTR [r13+0x10]
   22a58:	test   r8,r8
   22a5b:	mov    QWORD PTR [rsp+0x20],rsi
   22a60:	je     25444 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5504>
   22a66:	mov    rax,QWORD PTR [r12+r8*8]
   22a6a:	mov    QWORD PTR [r13+0x10],rax
   22a6e:	add    QWORD PTR [r13+0x110],0xfffffffffffffffc
   22a76:	movabs r9,0xff00000000000000
   22a80:	mov    rcx,rsi
   22a83:	shr    rcx,0x38
   22a87:	cmp    ecx,0x2
   22a8a:	je     25461 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5521>
   22a90:	mov    QWORD PTR [r12+r8*8],rsi
   22a94:	mov    rax,r15
   22a97:	and    rax,r9
   22a9a:	movabs r10,0x200000000000000
   22aa4:	cmp    rax,r10
   22aa7:	je     2547e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x553e>
   22aad:	mov    QWORD PTR [r12+r8*8+0x8],r15
   22ab2:	mov    rax,QWORD PTR [rsp+0x28]
   22ab7:	and    r9,rax
   22aba:	cmp    r9,r10
   22abd:	je     2549b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x555b>
   22ac3:	mov    r13,QWORD PTR [rsp+0x8]
   22ac8:	movabs rbp,0x2002d0000000000
   22ad2:	or     rbp,r8
   22ad5:	mov    QWORD PTR [r12+r8*8+0x10],rax
   22ada:	mov    r15d,DWORD PTR [rsp+0x14]
   22adf:	test   r15d,r15d
   22ae2:	je     22e03 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2ec3>
   22ae8:	mov    QWORD PTR [r14],rbp
   22aeb:	mov    rax,QWORD PTR [rsp+0x18]
   22af0:	mov    QWORD PTR [r14+0x8],rax
   22af4:	mov    QWORD PTR [r14+0x10],0xa5
   22afc:	add    r14,0x18
   22b00:	jmp    22e4b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2f0b>
   22b05:	mov    QWORD PTR [rsp+0x40],r14
   22b0a:	mov    r14,QWORD PTR [rsp+0x20]
   22b0f:	mov    rcx,QWORD PTR [r14-0x18]
   22b13:	mov    r8d,DWORD PTR [r14-0x10]
   22b17:	mov    rdi,r12
   22b1a:	mov    rsi,r13
   22b1d:	mov    edx,0xbe
   22b22:	mov    r9d,0x1
   22b28:	call   ed60 <task_node>
   22b2d:	mov    r13,QWORD PTR [rsp+0x8]
   22b32:	mov    rcx,QWORD PTR [rsp+0x30]
   22b37:	mov    QWORD PTR [r12+rax*8],rcx
   22b3b:	mov    QWORD PTR [r12+rax*8+0x8],rbx
   22b40:	movabs rcx,0x500be0000000000
   22b4a:	or     rcx,rax
   22b4d:	mov    QWORD PTR [r14-0x18],rcx
   22b51:	mov    QWORD PTR [r14-0x10],0x2
   22b59:	mov    r14,QWORD PTR [rsp+0x40]
   22b5e:	mov    rdi,r12
   22b61:	mov    rsi,r13
   22b64:	mov    rdx,QWORD PTR [rsp+0x28]
   22b69:	call   5c510 <term_keep>
   22b6e:	mov    r13,QWORD PTR [rsp+0x8]
   22b73:	mov    rbx,rax
   22b76:	mov    r8,QWORD PTR [r13+0x10]
   22b7a:	test   r8,r8
   22b7d:	je     2516f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x522f>
   22b83:	mov    rax,QWORD PTR [r12+r8*8]
   22b87:	mov    QWORD PTR [r13+0x10],rax
   22b8b:	add    QWORD PTR [r13+0x110],0xfffffffffffffffc
   22b93:	mov    rcx,rbx
   22b96:	and    rcx,r15
   22b99:	mov    rax,rbx
   22b9c:	movabs rdx,0x200000000000000
   22ba6:	cmp    rcx,rdx
   22ba9:	mov    rcx,rdx
   22bac:	movabs rdx,0x2002d0000000000
   22bb6:	je     25187 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5247>
   22bbc:	mov    QWORD PTR [r12+r8*8],rax
   22bc0:	mov    rax,rbp
   22bc3:	and    rax,r15
   22bc6:	cmp    rax,rcx
   22bc9:	je     251b3 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5273>
   22bcf:	mov    QWORD PTR [r12+r8*8+0x8],rbp
   22bd4:	and    r15,r14
   22bd7:	cmp    r15,rcx
   22bda:	je     251ee <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x52ae>
   22be0:	mov    rax,r14
   22be3:	mov    r14,QWORD PTR [rsp+0x20]
   22be8:	mov    r15d,DWORD PTR [rsp+0x14]
   22bed:	or     rdx,r8
   22bf0:	mov    QWORD PTR [r12+r8*8+0x10],rax
   22bf5:	test   r15d,r15d
   22bf8:	je     22c14 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2cd4>
   22bfa:	mov    QWORD PTR [r14],rdx
   22bfd:	mov    rax,QWORD PTR [rsp+0x18]
   22c02:	mov    QWORD PTR [r14+0x8],rax
   22c06:	mov    QWORD PTR [r14+0x10],0xbf
   22c0e:	add    r14,0x18
   22c12:	jmp    22c5f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2d1f>
   22c14:	mov    rcx,QWORD PTR [r14-0x18]
   22c18:	mov    r8d,DWORD PTR [r14-0x10]
   22c1c:	mov    r15,rdx
   22c1f:	mov    rdi,r12
   22c22:	mov    rsi,r13
   22c25:	mov    edx,0xbf
   22c2a:	mov    r9d,0x1
   22c30:	call   ed60 <task_node>
   22c35:	mov    QWORD PTR [r12+rax*8],r15
   22c39:	mov    rcx,QWORD PTR [rsp+0x18]
   22c3e:	mov    QWORD PTR [r12+rax*8+0x8],rcx
   22c43:	movabs rcx,0x500bf0000000000
   22c4d:	or     rcx,rax
   22c50:	mov    QWORD PTR [r14-0x18],rcx
   22c54:	mov    QWORD PTR [r14-0x10],0x2
   22c5c:	xor    r15d,r15d
   22c5f:	mov    rsi,QWORD PTR [rsp+0x48]
   22c64:	mov    rdx,rbx
   22c67:	add    rsp,0x80
   22c6e:	pop    rbp
   22c6f:	jmp    1db20 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_>
   22c74:	mov    r14,QWORD PTR [rsp+0x20]
   22c79:	mov    rcx,QWORD PTR [r14-0x18]
   22c7d:	mov    r8d,DWORD PTR [r14-0x10]
   22c81:	mov    rdi,r12
   22c84:	mov    rsi,r13
   22c87:	mov    edx,0xb6
   22c8c:	mov    rbp,r9
   22c8f:	mov    r9d,0x1
   22c95:	mov    r13,r10
   22c98:	call   ed60 <task_node>
   22c9d:	mov    r9,rbp
   22ca0:	mov    r10,r13
   22ca3:	movabs rdi,0xfffffffe00
   22cad:	mov    r13,QWORD PTR [rsp+0x8]
   22cb2:	mov    rcx,QWORD PTR [rsp+0x30]
   22cb7:	mov    QWORD PTR [r12+rax*8],rcx
   22cbb:	mov    QWORD PTR [r12+rax*8+0x8],r15
   22cc0:	movabs rcx,0x500b60000000000
   22cca:	or     rcx,rax
   22ccd:	mov    QWORD PTR [r14-0x18],rcx
   22cd1:	mov    QWORD PTR [r14-0x10],0x2
   22cd9:	mov    rcx,QWORD PTR [rsp+0x28]
   22cde:	test   rcx,rcx
   22ce1:	js     22d28 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2de8>
   22ce3:	mov    rax,rcx
   22ce6:	shr    rax,0x39
   22cea:	sete   al
   22ced:	and    rdi,rcx
   22cf0:	cmp    rdi,0x3108200
   22cf7:	setb   cl
   22cfa:	or     cl,al
   22cfc:	je     2641e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x64de>
   22d02:	mov    rcx,QWORD PTR [rsp+0x28]
   22d07:	mov    r8,QWORD PTR [r13+0x10]
   22d0b:	mov    r15,r9
   22d0e:	test   r8,r8
   22d11:	jne    22d4f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2e0f>
   22d13:	mov    rdi,r12
   22d16:	mov    rsi,r13
   22d19:	mov    edx,0x2
   22d1e:	call   5e35b <heap_alloc_miss>
   22d23:	mov    r8,rax
   22d26:	jmp    22d5f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2e1f>
   22d28:	and    r10,rcx
   22d2b:	mov    eax,0x1
   22d30:	lock xadd DWORD PTR [r12+r10*8],eax
   22d36:	not    eax
   22d38:	test   eax,0xfffffe
   22d3d:	je     28ddd <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e9d>
   22d43:	mov    r8,QWORD PTR [r13+0x10]
   22d47:	mov    r15,r9
   22d4a:	test   r8,r8
   22d4d:	je     22d13 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2dd3>
   22d4f:	mov    rax,QWORD PTR [r12+r8*8]
   22d53:	mov    QWORD PTR [r13+0x10],rax
   22d57:	add    QWORD PTR [r13+0x110],0xfffffffffffffffc
   22d5f:	movabs r9,0xff00000000000000
   22d69:	mov    rax,rcx
   22d6c:	shr    rcx,0x38
   22d70:	mov    rbx,rax
   22d73:	cmp    ecx,0x2
   22d76:	je     254b8 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5578>
   22d7c:	mov    QWORD PTR [r12+r8*8],rax
   22d80:	mov    rax,r15
   22d83:	and    rax,r9
   22d86:	movabs r10,0x200000000000000
   22d90:	cmp    rax,r10
   22d93:	je     254d0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5590>
   22d99:	mov    QWORD PTR [r12+r8*8+0x8],r15
   22d9e:	and    r9,QWORD PTR [rsp+0x40]
   22da3:	cmp    r9,r10
   22da6:	je     254fb <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x55bb>
   22dac:	mov    rdx,rbx
   22daf:	mov    r13,QWORD PTR [rsp+0x8]
   22db4:	movabs rbp,0x2002d0000000000
   22dbe:	or     rbp,r8
   22dc1:	mov    rax,QWORD PTR [rsp+0x40]
   22dc6:	mov    QWORD PTR [r12+r8*8+0x10],rax
   22dcb:	mov    r15d,DWORD PTR [rsp+0x14]
   22dd0:	test   r15d,r15d
   22dd3:	je     22e60 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2f20>
   22dd9:	mov    QWORD PTR [r14],rbp
   22ddc:	mov    rax,QWORD PTR [rsp+0x18]
   22de1:	mov    QWORD PTR [r14+0x8],rax
   22de5:	mov    QWORD PTR [r14+0x10],0xb7
   22ded:	add    r14,0x18
   22df1:	mov    rsi,QWORD PTR [rsp+0x38]
   22df6:	add    rsp,0x80
   22dfd:	pop    rbp
   22dfe:	jmp    1db20 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_>
   22e03:	mov    rcx,QWORD PTR [r14-0x18]
   22e07:	mov    r8d,DWORD PTR [r14-0x10]
   22e0b:	mov    rdi,r12
   22e0e:	mov    rsi,r13
   22e11:	mov    edx,0xa5
   22e16:	mov    r9d,0x1
   22e1c:	call   ed60 <task_node>
   22e21:	mov    QWORD PTR [r12+rax*8],rbp
   22e25:	mov    rcx,QWORD PTR [rsp+0x18]
   22e2a:	mov    QWORD PTR [r12+rax*8+0x8],rcx
   22e2f:	movabs rcx,0x500a50000000000
   22e39:	or     rcx,rax
   22e3c:	mov    QWORD PTR [r14-0x18],rcx
   22e40:	mov    QWORD PTR [r14-0x10],0x2
   22e48:	xor    r15d,r15d
   22e4b:	mov    rsi,rbx
   22e4e:	mov    rdx,QWORD PTR [rsp+0x20]
   22e53:	add    rsp,0x80
   22e5a:	pop    rbp
   22e5b:	jmp    1db20 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_>
   22e60:	mov    rbx,rdx
   22e63:	mov    rcx,QWORD PTR [r14-0x18]
   22e67:	mov    r8d,DWORD PTR [r14-0x10]
   22e6b:	mov    rdi,r12
   22e6e:	mov    rsi,r13
   22e71:	mov    edx,0xb7
   22e76:	mov    r9d,0x1
   22e7c:	call   ed60 <task_node>
   22e81:	mov    QWORD PTR [r12+rax*8],rbp
   22e85:	mov    rcx,QWORD PTR [rsp+0x18]
   22e8a:	mov    QWORD PTR [r12+rax*8+0x8],rcx
   22e8f:	movabs rcx,0x500b70000000000
   22e99:	or     rcx,rax
   22e9c:	mov    QWORD PTR [r14-0x18],rcx
   22ea0:	mov    QWORD PTR [r14-0x10],0x2
   22ea8:	xor    r15d,r15d
   22eab:	mov    rsi,QWORD PTR [rsp+0x38]
   22eb0:	mov    rdx,rbx
   22eb3:	add    rsp,0x80
   22eba:	pop    rbp
   22ebb:	jmp    1db20 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_>
   22ec0:	mov    rdi,r12
   22ec3:	mov    rsi,r13
   22ec6:	xor    edx,edx
   22ec8:	mov    rax,r11
   22ecb:	call   5e231 <heap_hand>
   22ed0:	mov    r11,rax
   22ed3:	movabs rdi,0xfffffffe00
   22edd:	cmp    rcx,0x3108200
   22ee4:	jae    2010c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1cc>
   22eea:	jmp    20143 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x203>
   22eef:	movzx  ecx,dx
   22ef2:	cmp    ecx,0x18
   22ef5:	jne    28dd1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e91>
   22efb:	mov    rcx,rax
   22efe:	shr    rcx,0x28
   22f02:	cmp    cx,0x18
   22f06:	je     2369b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x375b>
   22f0c:	movzx  ecx,cx
   22f0f:	cmp    ecx,0x19
   22f12:	jne    28dd1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e91>
   22f18:	mov    rdx,r10
   22f1b:	movabs r10,0x100030000000000
   22f25:	test   rax,rax
   22f28:	jns    236a5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3765>
   22f2e:	and    rax,rdx
   22f31:	mov    ecx,DWORD PTR [r12+rax*8+0x4]
   22f36:	mov    ecx,DWORD PTR [r12+rax*8]
   22f3a:	and    ecx,0xffffff
   22f40:	cmp    ecx,0x1
   22f43:	jne    236a5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3765>
   22f49:	mov    eax,DWORD PTR [r12+rax*8]
   22f4d:	jmp    236a5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3765>
   22f52:	movzx  ecx,dx
   22f55:	cmp    ecx,0x18
   22f58:	jne    28dd1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e91>
   22f5e:	mov    rcx,rax
   22f61:	shr    rcx,0x28
   22f65:	cmp    cx,0x18
   22f69:	je     23a81 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3b41>
   22f6f:	movzx  ecx,cx
   22f72:	cmp    ecx,0x19
   22f75:	jne    28dd1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e91>
   22f7b:	movabs r9,0x100030000000000
   22f85:	test   rax,rax
   22f88:	mov    rdx,r14
   22f8b:	jns    23a8e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3b4e>
   22f91:	and    rax,r10
   22f94:	mov    ecx,DWORD PTR [r12+rax*8+0x4]
   22f99:	mov    ecx,DWORD PTR [r12+rax*8]
   22f9d:	and    ecx,0xffffff
   22fa3:	cmp    ecx,0x1
   22fa6:	jne    23a8e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3b4e>
   22fac:	mov    eax,DWORD PTR [r12+rax*8]
   22fb0:	jmp    23a8e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3b4e>
   22fb5:	movzx  ecx,dx
   22fb8:	cmp    ecx,0x18
   22fbb:	jne    28dd1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e91>
   22fc1:	mov    rcx,rax
   22fc4:	shr    rcx,0x28
   22fc8:	cmp    cx,0x18
   22fcc:	je     23ea0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3f60>
   22fd2:	movzx  ecx,cx
   22fd5:	cmp    ecx,0x19
   22fd8:	jne    28dd1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e91>
   22fde:	mov    rdx,r10
   22fe1:	movabs r10,0x100030000000000
   22feb:	test   rax,rax
   22fee:	jns    23eaa <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3f6a>
   22ff4:	and    rax,rdx
   22ff7:	mov    ecx,DWORD PTR [r12+rax*8+0x4]
   22ffc:	mov    ecx,DWORD PTR [r12+rax*8]
   23000:	and    ecx,0xffffff
   23006:	cmp    ecx,0x1
   23009:	jne    23eaa <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3f6a>
   2300f:	mov    eax,DWORD PTR [r12+rax*8]
   23013:	jmp    23eaa <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3f6a>
   23018:	movzx  ecx,si
   2301b:	cmp    ecx,0x18
   2301e:	jne    28dd1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e91>
   23024:	mov    rcx,rax
   23027:	shr    rcx,0x28
   2302b:	cmp    cx,0x18
   2302f:	je     24283 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4343>
   23035:	movzx  ecx,cx
   23038:	cmp    ecx,0x19
   2303b:	jne    28dd1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e91>
   23041:	movabs r9,0x100030000000000
   2304b:	test   rax,rax
   2304e:	jns    2428d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x434d>
   23054:	and    rax,r10
   23057:	mov    ecx,DWORD PTR [r12+rax*8+0x4]
   2305c:	mov    ecx,DWORD PTR [r12+rax*8]
   23060:	and    ecx,0xffffff
   23066:	cmp    ecx,0x1
   23069:	jne    2428d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x434d>
   2306f:	mov    eax,DWORD PTR [r12+rax*8]
   23073:	jmp    2428d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x434d>
   23078:	movzx  ecx,dx
   2307b:	cmp    ecx,0x18
   2307e:	jne    28dd1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e91>
   23084:	mov    rcx,rax
   23087:	shr    rcx,0x28
   2308b:	cmp    cx,0x18
   2308f:	movabs rdx,0x200000000000000
   23099:	je     2464f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x470f>
   2309f:	movzx  ecx,cx
   230a2:	cmp    ecx,0x19
   230a5:	jne    28dd1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e91>
   230ab:	movabs r9,0x100030000000000
   230b5:	test   rax,rax
   230b8:	jns    231db <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x329b>
   230be:	and    rax,r10
   230c1:	mov    ecx,DWORD PTR [r12+rax*8+0x4]
   230c6:	mov    ecx,DWORD PTR [r12+rax*8]
   230ca:	and    ecx,0xffffff
   230d0:	cmp    ecx,0x1
   230d3:	jne    231db <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x329b>
   230d9:	mov    eax,DWORD PTR [r12+rax*8]
   230dd:	mov    r8,QWORD PTR [r13+0x8]
   230e1:	test   r8,r8
   230e4:	jne    231e8 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x32a8>
   230ea:	jmp    24666 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4726>
   230ef:	movzx  ecx,si
   230f2:	cmp    ecx,0x18
   230f5:	jne    28dd1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e91>
   230fb:	mov    rcx,rax
   230fe:	shr    rcx,0x28
   23102:	cmp    cx,0x18
   23106:	je     246c9 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4789>
   2310c:	movzx  ecx,cx
   2310f:	cmp    ecx,0x19
   23112:	jne    28dd1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e91>
   23118:	movabs r9,0x100030000000000
   23122:	test   rax,rax
   23125:	jns    246d3 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4793>
   2312b:	and    rax,r10
   2312e:	mov    ecx,DWORD PTR [r12+rax*8+0x4]
   23133:	mov    ecx,DWORD PTR [r12+rax*8]
   23137:	and    ecx,0xffffff
   2313d:	cmp    ecx,0x1
   23140:	jne    246d3 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4793>
   23146:	mov    eax,DWORD PTR [r12+rax*8]
   2314a:	jmp    246d3 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4793>
   2314f:	movzx  eax,cx
   23152:	cmp    eax,0x18
   23155:	jne    28dd1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e91>
   2315b:	movabs r10,0x100050000000000
   23165:	jmp    236a5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3765>
   2316a:	movzx  eax,cx
   2316d:	cmp    eax,0x18
   23170:	jne    28dd1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e91>
   23176:	movabs r9,0x100050000000000
   23180:	jmp    23a8b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3b4b>
   23185:	movzx  eax,cx
   23188:	cmp    eax,0x18
   2318b:	jne    28dd1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e91>
   23191:	movabs r10,0x100050000000000
   2319b:	jmp    23eaa <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3f6a>
   231a0:	movzx  eax,cx
   231a3:	cmp    eax,0x18
   231a6:	jne    28dd1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e91>
   231ac:	movabs r9,0x100050000000000
   231b6:	jmp    2428d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x434d>
   231bb:	movzx  eax,cx
   231be:	cmp    eax,0x18
   231c1:	jne    28dd1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e91>
   231c7:	movabs r9,0x100050000000000
   231d1:	movabs rdx,0x200000000000000
   231db:	mov    r8,QWORD PTR [r13+0x8]
   231df:	test   r8,r8
   231e2:	je     24666 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4726>
   231e8:	mov    rax,QWORD PTR [r12+r8*8]
   231ec:	mov    QWORD PTR [r13+0x8],rax
   231f0:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   231f8:	mov    rax,QWORD PTR [rsp+0x40]
   231fd:	and    rax,rbp
   23200:	cmp    rax,rdx
   23203:	je     2469a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x475a>
   23209:	mov    rax,QWORD PTR [rsp+0x40]
   2320e:	mov    QWORD PTR [r12+r8*8],rax
   23212:	mov    rax,r14
   23215:	and    rax,rbp
   23218:	cmp    rax,rdx
   2321b:	je     25a05 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5ac5>
   23221:	movabs r10,0x200080000000000
   2322b:	mov    QWORD PTR [r12+r8*8+0x8],r14
   23230:	or     r8,r10
   23233:	mov    rbx,QWORD PTR [r13+0x8]
   23237:	test   rbx,rbx
   2323a:	je     25a26 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5ae6>
   23240:	mov    rax,QWORD PTR [r12+rbx*8]
   23244:	mov    QWORD PTR [r13+0x8],rax
   23248:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   23250:	mov    rax,r8
   23253:	shr    rax,0x38
   23257:	cmp    eax,0x2
   2325a:	jbe    25a4f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5b0f>
   23260:	mov    QWORD PTR [r12+rbx*8],r8
   23264:	mov    QWORD PTR [r12+rbx*8+0x8],r9
   23269:	mov    rdx,rbx
   2326c:	or     rdx,r10
   2326f:	mov    rax,rdx
   23272:	and    rax,r11
   23275:	cmp    rax,r15
   23278:	jne    26fa4 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7064>
   2327e:	mov    r14,r11
   23281:	lea    r8,[rsp+0x70]
   23286:	mov    rdi,r12
   23289:	mov    rsi,r13
   2328c:	mov    ecx,0x2
   23291:	call   e600 <ctr_take>
   23296:	mov    rdi,r12
   23299:	mov    rsi,r13
   2329c:	mov    edx,0x1
   232a1:	mov    rcx,rax
   232a4:	call   e5b0 <spare_free>
   232a9:	mov    rdx,QWORD PTR [rsp+0x70]
   232ae:	mov    rbx,QWORD PTR [rsp+0x78]
   232b3:	mov    rax,rdx
   232b6:	and    rax,r14
   232b9:	cmp    rax,r15
   232bc:	jne    2703b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x70fb>
   232c2:	mov    rbp,r14
   232c5:	movabs r14,0x7e00000000000000
   232cf:	lea    r8,[rsp+0x60]
   232d4:	mov    rdi,r12
   232d7:	mov    rsi,r13
   232da:	mov    ecx,0x2
   232df:	call   e600 <ctr_take>
   232e4:	mov    rdi,r12
   232e7:	mov    rsi,r13
   232ea:	mov    edx,0x1
   232ef:	mov    rcx,rax
   232f2:	call   e5b0 <spare_free>
   232f7:	mov    rdx,QWORD PTR [rsp+0x60]
   232fc:	mov    r15,QWORD PTR [rsp+0x68]
   23301:	test   rdx,r14
   23304:	sete   al
   23307:	cmp    rdx,0xffffffffffffffff
   2330b:	sete   cl
   2330e:	or     cl,al
   23310:	mov    rax,rdx
   23313:	movabs rsi,0xfffffffe00
   2331d:	and    rax,rsi
   23320:	cmp    rax,0x3108200
   23326:	setb   al
   23329:	or     al,cl
   2332b:	jne    23344 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3404>
   2332d:	mov    rdi,r12
   23330:	mov    rsi,QWORD PTR [rsp+0x8]
   23335:	call   e8c0 <term_drop>
   2333a:	movabs rsi,0xfffffffe00
   23344:	movabs rdi,0x300000000000000
   2334e:	and    rbp,rbx
   23351:	movabs rax,0x40000000000
   2335b:	cmp    rbp,rax
   2335e:	jne    23495 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3555>
   23364:	mov    rdx,QWORD PTR [rsp+0x18]
   23369:	test   rdx,r14
   2336c:	sete   al
   2336f:	cmp    rdx,0xffffffffffffffff
   23373:	sete   cl
   23376:	or     cl,al
   23378:	and    rsi,rdx
   2337b:	cmp    rsi,0x3108200
   23382:	setb   al
   23385:	or     al,cl
   23387:	mov    rsi,QWORD PTR [rsp+0x8]
   2338c:	movabs rbx,0xff00000000000000
   23396:	jne    233a5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3465>
   23398:	mov    rdi,r12
   2339b:	call   e8c0 <term_drop>
   233a0:	mov    rsi,QWORD PTR [rsp+0x8]
   233a5:	mov    rdi,r12
   233a8:	mov    rdx,QWORD PTR [rsp+0x28]
   233ad:	call   5c510 <term_keep>
   233b2:	mov    r13,QWORD PTR [rsp+0x8]
   233b7:	mov    r10,rax
   233ba:	mov    r8,QWORD PTR [r13+0x8]
   233be:	test   r8,r8
   233c1:	movabs rbp,0x200080000000000
   233cb:	je     26a61 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6b21>
   233d1:	mov    rax,QWORD PTR [r12+r8*8]
   233d5:	mov    QWORD PTR [r13+0x8],rax
   233d9:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   233e1:	mov    rax,r15
   233e4:	and    rax,rbx
   233e7:	movabs rdx,0x200000000000000
   233f1:	cmp    rax,rdx
   233f4:	movabs rsi,0x300000000000000
   233fe:	je     26a79 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6b39>
   23404:	mov    QWORD PTR [r12+r8*8],r15
   23408:	and    rbx,r10
   2340b:	mov    rax,r10
   2340e:	cmp    rbx,rdx
   23411:	je     26aa8 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6b68>
   23417:	mov    QWORD PTR [r12+r8*8+0x8],rax
   2341c:	movabs r9,0x2002c0000000000
   23426:	or     r9,r8
   23429:	mov    rcx,QWORD PTR [r13+0x8]
   2342d:	test   rcx,rcx
   23430:	mov    r14,QWORD PTR [rsp+0x20]
   23435:	mov    r15d,DWORD PTR [rsp+0x14]
   2343a:	je     26ad4 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6b94>
   23440:	mov    rax,QWORD PTR [r12+rcx*8]
   23444:	mov    QWORD PTR [r13+0x8],rax
   23448:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   23450:	cmp    r9,rsi
   23453:	jb     26b04 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6bc4>
   23459:	lea    r8,[r12+rcx*8]
   2345d:	mov    QWORD PTR [r12+rcx*8],r9
   23461:	cmp    rbx,rdx
   23464:	je     23590 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3650>
   2346a:	mov    QWORD PTR [r8+0x8],r10
   2346e:	or     rcx,rbp
   23471:	movabs rax,0x2002d0000000000
   2347b:	mov    rdx,QWORD PTR [rsp+0x38]
   23480:	or     rdx,rax
   23483:	mov    rsi,QWORD PTR [rsp+0x30]
   23488:	add    rsp,0x80
   2348f:	pop    rbp
   23490:	jmp    1e7c0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_108_111_>
   23495:	test   rbx,r14
   23498:	sete   al
   2349b:	cmp    rbx,0xffffffffffffffff
   2349f:	sete   cl
   234a2:	or     cl,al
   234a4:	and    rsi,rbx
   234a7:	cmp    rsi,0x3108200
   234ae:	setb   al
   234b1:	or     al,cl
   234b3:	mov    r13,QWORD PTR [rsp+0x8]
   234b8:	movabs rbp,0xff00000000000000
   234c2:	jne    234dd <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x359d>
   234c4:	mov    r14,rdi
   234c7:	mov    rdi,r12
   234ca:	mov    rsi,r13
   234cd:	mov    rdx,rbx
   234d0:	call   e8c0 <term_drop>
   234d5:	mov    rdi,r14
   234d8:	mov    r13,QWORD PTR [rsp+0x8]
   234dd:	mov    r8,QWORD PTR [r13+0x8]
   234e1:	test   r8,r8
   234e4:	je     26b40 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6c00>
   234ea:	mov    rax,QWORD PTR [r12+r8*8]
   234ee:	mov    QWORD PTR [r13+0x8],rax
   234f2:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   234fa:	mov    r10,QWORD PTR [rsp+0x18]
   234ff:	mov    rdx,QWORD PTR [rsp+0x28]
   23504:	mov    rax,r15
   23507:	and    rax,rbp
   2350a:	movabs rsi,0x200000000000000
   23514:	cmp    rax,rsi
   23517:	je     26b5e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6c1e>
   2351d:	mov    QWORD PTR [r12+r8*8],r15
   23521:	mov    rax,rdx
   23524:	and    rax,rbp
   23527:	cmp    rax,rsi
   2352a:	je     26b8e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6c4e>
   23530:	mov    r14,QWORD PTR [rsp+0x20]
   23535:	mov    r15d,DWORD PTR [rsp+0x14]
   2353a:	mov    QWORD PTR [r12+r8*8+0x8],rdx
   2353f:	movabs r9,0x2002c0000000000
   23549:	or     r9,r8
   2354c:	mov    rcx,QWORD PTR [r13+0x8]
   23550:	test   rcx,rcx
   23553:	je     26bb6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6c76>
   23559:	mov    rax,QWORD PTR [r12+rcx*8]
   2355d:	mov    QWORD PTR [r13+0x8],rax
   23561:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   23569:	cmp    r9,rdi
   2356c:	jb     26be2 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6ca2>
   23572:	lea    r8,[r12+rcx*8]
   23576:	mov    QWORD PTR [r12+rcx*8],r9
   2357a:	and    rbp,r10
   2357d:	cmp    rbp,rsi
   23580:	movabs rbp,0x200080000000000
   2358a:	jne    2346a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x352a>
   23590:	mov    rdi,r12
   23593:	mov    rsi,r13
   23596:	mov    rdx,r10
   23599:	mov    r9,rcx
   2359c:	mov    ecx,0x1
   235a1:	call   5e661 <rfc_wrap>
   235a6:	mov    rcx,r9
   235a9:	mov    r10,rax
   235ac:	jmp    2346a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x352a>
   235b1:	movzx  eax,cx
   235b4:	cmp    eax,0x18
   235b7:	jne    28dd1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e91>
   235bd:	movabs r9,0x100050000000000
   235c7:	jmp    246d3 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4793>
   235cc:	mov    rdi,r12
   235cf:	mov    rsi,r13
   235d2:	mov    edx,0x1
   235d7:	mov    rax,r11
   235da:	call   5e231 <heap_hand>
   235df:	jmp    2363c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x36fc>
   235e1:	mov    rdi,r12
   235e4:	mov    rsi,r13
   235e7:	mov    edx,0x2
   235ec:	mov    rax,r11
   235ef:	call   5e231 <heap_hand>
   235f4:	mov    r11,rax
   235f7:	movabs rdi,0xfffffffe00
   23601:	jmp    20404 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4c4>
   23606:	shl    rcx,0x20
   2360a:	or     rcx,rdx
   2360d:	shr    rcx,0x18
   23611:	mov    r14,QWORD PTR [r12+rcx*8]
   23615:	mov    rax,QWORD PTR [r12+rcx*8+0x8]
   2361a:	mov    QWORD PTR [rsp+0x28],rax
   2361f:	mov    rdi,r12
   23622:	mov    rsi,r13
   23625:	mov    rdx,rbx
   23628:	mov    r9,r8
   2362b:	mov    r8d,0x2
   23631:	mov    rax,r11
   23634:	call   5e2c2 <span_fade>
   23639:	mov    r8,r9
   2363c:	mov    r11,rax
   2363f:	movabs rdi,0xfffffffe00
   23649:	jmp    202dd <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x39d>
   2364e:	shl    rcx,0x20
   23652:	or     rcx,rdx
   23655:	shr    rcx,0x18
   23659:	mov    rax,QWORD PTR [r12+rcx*8]
   2365d:	mov    QWORD PTR [rsp+0x28],rax
   23662:	mov    rbp,QWORD PTR [r12+rcx*8+0x8]
   23667:	mov    r14,QWORD PTR [r12+rcx*8+0x10]
   2366c:	mov    rdi,r12
   2366f:	mov    rsi,r13
   23672:	mov    rdx,rbx
   23675:	mov    rax,r8
   23678:	mov    r8d,0x3
   2367e:	call   5e2c2 <span_fade>
   23683:	mov    r8,rax
   23686:	movabs rdi,0xfffffffe00
   23690:	mov    r11,r9
   23693:	mov    r9,rbp
   23696:	jmp    20404 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4c4>
   2369b:	movabs r10,0x100040000000000
   236a5:	mov    rsi,QWORD PTR [rsp+0x8]
   236aa:	mov    r8,QWORD PTR [rsi+0x8]
   236ae:	test   r8,r8
   236b1:	je     25732 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x57f2>
   236b7:	mov    rax,QWORD PTR [r12+r8*8]
   236bb:	mov    QWORD PTR [rsi+0x8],rax
   236bf:	add    QWORD PTR [rsi+0x108],0xfffffffffffffffe
   236c7:	mov    rax,r9
   236ca:	and    rax,rbp
   236cd:	movabs rdx,0x200000000000000
   236d7:	cmp    rax,rdx
   236da:	je     2574d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x580d>
   236e0:	mov    rcx,r14
   236e3:	mov    QWORD PTR [r12+r8*8],r9
   236e7:	mov    rax,rcx
   236ea:	and    rax,rbp
   236ed:	cmp    rax,rdx
   236f0:	je     2577d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x583d>
   236f6:	movabs r9,0x200080000000000
   23700:	mov    QWORD PTR [r12+r8*8+0x8],rcx
   23705:	or     r8,r9
   23708:	mov    rsi,QWORD PTR [rsp+0x8]
   2370d:	mov    rbx,QWORD PTR [rsi+0x8]
   23711:	test   rbx,rbx
   23714:	je     257a0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5860>
   2371a:	mov    rax,QWORD PTR [r12+rbx*8]
   2371e:	mov    QWORD PTR [rsi+0x8],rax
   23722:	add    QWORD PTR [rsi+0x108],0xfffffffffffffffe
   2372a:	mov    rax,r8
   2372d:	shr    rax,0x38
   23731:	cmp    eax,0x2
   23734:	jbe    257c6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5886>
   2373a:	mov    QWORD PTR [rsp+0x38],r15
   2373f:	mov    QWORD PTR [r12+rbx*8],r8
   23743:	mov    QWORD PTR [r12+rbx*8+0x8],r10
   23748:	mov    rdx,rbx
   2374b:	or     rdx,r9
   2374e:	mov    rax,rdx
   23751:	and    rax,r11
   23754:	movabs rbp,0x80000000000
   2375e:	cmp    rax,rbp
   23761:	jne    288cc <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x898c>
   23767:	mov    r13,r11
   2376a:	lea    r8,[rsp+0x70]
   2376f:	mov    rdi,r12
   23772:	mov    rbx,QWORD PTR [rsp+0x8]
   23777:	mov    rsi,rbx
   2377a:	mov    ecx,0x2
   2377f:	call   e600 <ctr_take>
   23784:	mov    rdi,r12
   23787:	mov    rsi,rbx
   2378a:	mov    edx,0x1
   2378f:	mov    rcx,rax
   23792:	call   e5b0 <spare_free>
   23797:	mov    rdx,QWORD PTR [rsp+0x70]
   2379c:	mov    r15,QWORD PTR [rsp+0x78]
   237a1:	mov    rax,rdx
   237a4:	and    rax,r13
   237a7:	cmp    rax,rbp
   237aa:	jne    28afe <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8bbe>
   237b0:	mov    r14,r13
   237b3:	lea    r8,[rsp+0x60]
   237b8:	mov    rdi,r12
   237bb:	mov    rsi,rbx
   237be:	mov    ecx,0x2
   237c3:	call   e600 <ctr_take>
   237c8:	mov    rdi,r12
   237cb:	mov    rsi,rbx
   237ce:	mov    edx,0x1
   237d3:	mov    rcx,rax
   237d6:	call   e5b0 <spare_free>
   237db:	mov    rdx,QWORD PTR [rsp+0x60]
   237e0:	mov    rbx,QWORD PTR [rsp+0x68]
   237e5:	movabs r13,0x7e00000000000000
   237ef:	test   rdx,r13
   237f2:	sete   al
   237f5:	cmp    rdx,0xffffffffffffffff
   237f9:	sete   cl
   237fc:	or     cl,al
   237fe:	mov    rax,rdx
   23801:	movabs rsi,0xfffffffe00
   2380b:	and    rax,rsi
   2380e:	cmp    rax,0x3108200
   23814:	setb   al
   23817:	or     al,cl
   23819:	movabs rbp,0xff00000000000000
   23823:	jne    2383c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x38fc>
   23825:	mov    rdi,r12
   23828:	mov    rsi,QWORD PTR [rsp+0x8]
   2382d:	call   e8c0 <term_drop>
   23832:	movabs rsi,0xfffffffe00
   2383c:	movabs r9,0x300000000000000
   23846:	and    r14,r15
   23849:	movabs rax,0x40000000000
   23853:	cmp    r14,rax
   23856:	jne    23979 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3a39>
   2385c:	mov    rdx,QWORD PTR [rsp+0x18]
   23861:	test   rdx,r13
   23864:	sete   al
   23867:	cmp    rdx,0xffffffffffffffff
   2386b:	sete   cl
   2386e:	or     cl,al
   23870:	and    rsi,rdx
   23873:	cmp    rsi,0x3108200
   2387a:	setb   al
   2387d:	or     al,cl
   2387f:	mov    rsi,QWORD PTR [rsp+0x8]
   23884:	jne    23893 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3953>
   23886:	mov    rdi,r12
   23889:	call   e8c0 <term_drop>
   2388e:	mov    rsi,QWORD PTR [rsp+0x8]
   23893:	mov    rdi,r12
   23896:	mov    rdx,QWORD PTR [rsp+0x40]
   2389b:	call   5c510 <term_keep>
   238a0:	mov    r13,QWORD PTR [rsp+0x8]
   238a5:	mov    r10,rax
   238a8:	mov    r8,QWORD PTR [r13+0x8]
   238ac:	test   r8,r8
   238af:	mov    r14,QWORD PTR [rsp+0x20]
   238b4:	mov    r15d,DWORD PTR [rsp+0x14]
   238b9:	je     2644b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x650b>
   238bf:	mov    rax,QWORD PTR [r12+r8*8]
   238c3:	mov    QWORD PTR [r13+0x8],rax
   238c7:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   238cf:	mov    rax,rbx
   238d2:	and    rax,rbp
   238d5:	movabs rdx,0x200000000000000
   238df:	cmp    rax,rdx
   238e2:	movabs r9,0x300000000000000
   238ec:	je     26463 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6523>
   238f2:	mov    QWORD PTR [r12+r8*8],rbx
   238f6:	and    rbp,r10
   238f9:	mov    rax,r10
   238fc:	cmp    rbp,rdx
   238ff:	je     26488 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6548>
   23905:	mov    QWORD PTR [r12+r8*8+0x8],rax
   2390a:	movabs rbx,0x2002c0000000000
   23914:	or     r8,rbx
   23917:	mov    rcx,QWORD PTR [r13+0x8]
   2391b:	test   rcx,rcx
   2391e:	je     264aa <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x656a>
   23924:	mov    rax,QWORD PTR [r12+rcx*8]
   23928:	mov    QWORD PTR [r13+0x8],rax
   2392c:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   23934:	cmp    r8,r9
   23937:	jb     264d0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6590>
   2393d:	lea    r9,[r12+rcx*8]
   23941:	mov    QWORD PTR [r12+rcx*8],r8
   23945:	cmp    rbp,rdx
   23948:	je     23a60 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3b20>
   2394e:	mov    QWORD PTR [r9+0x8],r10
   23952:	movabs rax,0x200080000000000
   2395c:	or     rcx,rax
   2395f:	mov    rdx,QWORD PTR [rsp+0x38]
   23964:	or     rdx,rbx
   23967:	mov    rsi,QWORD PTR [rsp+0x30]
   2396c:	add    rsp,0x80
   23973:	pop    rbp
   23974:	jmp    1d730 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_104_105_>
   23979:	test   r15,r13
   2397c:	sete   al
   2397f:	cmp    r15,0xffffffffffffffff
   23983:	sete   cl
   23986:	or     cl,al
   23988:	and    rsi,r15
   2398b:	cmp    rsi,0x3108200
   23992:	setb   al
   23995:	or     al,cl
   23997:	mov    r13,QWORD PTR [rsp+0x8]
   2399c:	jne    239b7 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3a77>
   2399e:	mov    rdi,r12
   239a1:	mov    rsi,r13
   239a4:	mov    rdx,r15
   239a7:	mov    r14,r9
   239aa:	call   e8c0 <term_drop>
   239af:	mov    r9,r14
   239b2:	mov    r13,QWORD PTR [rsp+0x8]
   239b7:	mov    r8,QWORD PTR [r13+0x8]
   239bb:	test   r8,r8
   239be:	je     2650c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x65cc>
   239c4:	mov    rax,QWORD PTR [r12+r8*8]
   239c8:	mov    QWORD PTR [r13+0x8],rax
   239cc:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   239d4:	mov    r14,QWORD PTR [rsp+0x20]
   239d9:	mov    r15d,DWORD PTR [rsp+0x14]
   239de:	mov    rdx,QWORD PTR [rsp+0x40]
   239e3:	mov    rax,rbx
   239e6:	and    rax,rbp
   239e9:	movabs rsi,0x200000000000000
   239f3:	cmp    rax,rsi
   239f6:	je     26524 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x65e4>
   239fc:	mov    QWORD PTR [r12+r8*8],rbx
   23a00:	mov    rax,rdx
   23a03:	and    rax,rbp
   23a06:	cmp    rax,rsi
   23a09:	je     2654e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x660e>
   23a0f:	mov    r10,QWORD PTR [rsp+0x18]
   23a14:	movabs rbx,0x2002c0000000000
   23a1e:	mov    QWORD PTR [r12+r8*8+0x8],rdx
   23a23:	or     r8,rbx
   23a26:	mov    rcx,QWORD PTR [r13+0x8]
   23a2a:	test   rcx,rcx
   23a2d:	je     26570 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6630>
   23a33:	mov    rax,QWORD PTR [r12+rcx*8]
   23a37:	mov    QWORD PTR [r13+0x8],rax
   23a3b:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   23a43:	cmp    r8,r9
   23a46:	jb     26596 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6656>
   23a4c:	lea    r9,[r12+rcx*8]
   23a50:	mov    QWORD PTR [r12+rcx*8],r8
   23a54:	and    rbp,r10
   23a57:	cmp    rbp,rsi
   23a5a:	jne    2394e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3a0e>
   23a60:	mov    rdi,r12
   23a63:	mov    rsi,r13
   23a66:	mov    rdx,r10
   23a69:	mov    r8,rcx
   23a6c:	mov    ecx,0x1
   23a71:	call   5e661 <rfc_wrap>
   23a76:	mov    rcx,r8
   23a79:	mov    r10,rax
   23a7c:	jmp    2394e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3a0e>
   23a81:	movabs r9,0x100040000000000
   23a8b:	mov    rdx,r14
   23a8e:	mov    r8,QWORD PTR [r13+0x8]
   23a92:	test   r8,r8
   23a95:	je     257e9 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x58a9>
   23a9b:	mov    rax,QWORD PTR [r12+r8*8]
   23a9f:	mov    QWORD PTR [r13+0x8],rax
   23aa3:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   23aab:	mov    rax,QWORD PTR [rsp+0x38]
   23ab0:	and    rax,rbp
   23ab3:	movabs rcx,0x200000000000000
   23abd:	cmp    rax,rcx
   23ac0:	je     2580a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x58ca>
   23ac6:	mov    rax,QWORD PTR [rsp+0x38]
   23acb:	mov    QWORD PTR [r12+r8*8],rax
   23acf:	mov    rax,rdx
   23ad2:	and    rax,rbp
   23ad5:	movabs rcx,0x200000000000000
   23adf:	cmp    rax,rcx
   23ae2:	je     25832 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x58f2>
   23ae8:	movabs r10,0x200080000000000
   23af2:	mov    QWORD PTR [r12+r8*8+0x8],rdx
   23af7:	or     r8,r10
   23afa:	mov    rbx,QWORD PTR [r13+0x8]
   23afe:	test   rbx,rbx
   23b01:	je     25850 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5910>
   23b07:	mov    rax,QWORD PTR [r12+rbx*8]
   23b0b:	mov    QWORD PTR [r13+0x8],rax
   23b0f:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   23b17:	mov    rax,r8
   23b1a:	shr    rax,0x38
   23b1e:	cmp    eax,0x2
   23b21:	jbe    25879 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5939>
   23b27:	mov    QWORD PTR [r12+rbx*8],r8
   23b2b:	mov    QWORD PTR [r12+rbx*8+0x8],r9
   23b30:	mov    rdx,rbx
   23b33:	or     rdx,r10
   23b36:	mov    rax,rdx
   23b39:	and    rax,r11
   23b3c:	cmp    rax,r15
   23b3f:	jne    2896d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8a2d>
   23b45:	mov    r14,r11
   23b48:	lea    r8,[rsp+0x70]
   23b4d:	mov    rdi,r12
   23b50:	mov    rsi,r13
   23b53:	mov    ecx,0x2
   23b58:	call   e600 <ctr_take>
   23b5d:	mov    rdi,r12
   23b60:	mov    rsi,r13
   23b63:	mov    edx,0x1
   23b68:	mov    rcx,rax
   23b6b:	call   e5b0 <spare_free>
   23b70:	mov    rdx,QWORD PTR [rsp+0x70]
   23b75:	mov    rbx,QWORD PTR [rsp+0x78]
   23b7a:	mov    rax,rdx
   23b7d:	and    rax,r14
   23b80:	cmp    rax,r15
   23b83:	jne    28b9f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8c5f>
   23b89:	mov    rbp,r14
   23b8c:	movabs r14,0x7e00000000000000
   23b96:	lea    r8,[rsp+0x60]
   23b9b:	mov    rdi,r12
   23b9e:	mov    rsi,r13
   23ba1:	mov    ecx,0x2
   23ba6:	call   e600 <ctr_take>
   23bab:	mov    rdi,r12
   23bae:	mov    rsi,r13
   23bb1:	mov    edx,0x1
   23bb6:	mov    rcx,rax
   23bb9:	call   e5b0 <spare_free>
   23bbe:	mov    rdx,QWORD PTR [rsp+0x60]
   23bc3:	mov    r15,QWORD PTR [rsp+0x68]
   23bc8:	test   rdx,r14
   23bcb:	sete   al
   23bce:	cmp    rdx,0xffffffffffffffff
   23bd2:	sete   cl
   23bd5:	or     cl,al
   23bd7:	mov    rax,rdx
   23bda:	movabs rsi,0xfffffffe00
   23be4:	and    rax,rsi
   23be7:	cmp    rax,0x3108200
   23bed:	setb   al
   23bf0:	or     al,cl
   23bf2:	jne    23c0b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3ccb>
   23bf4:	mov    rdi,r12
   23bf7:	mov    rsi,QWORD PTR [rsp+0x8]
   23bfc:	call   e8c0 <term_drop>
   23c01:	movabs rsi,0xfffffffe00
   23c0b:	movabs rdi,0x300000000000000
   23c15:	and    rbp,rbx
   23c18:	movabs rax,0x40000000000
   23c22:	cmp    rbp,rax
   23c25:	jne    23d70 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3e30>
   23c2b:	mov    rdx,QWORD PTR [rsp+0x18]
   23c30:	test   rdx,r14
   23c33:	sete   al
   23c36:	cmp    rdx,0xffffffffffffffff
   23c3a:	sete   cl
   23c3d:	or     cl,al
   23c3f:	and    rsi,rdx
   23c42:	cmp    rsi,0x3108200
   23c49:	setb   al
   23c4c:	or     al,cl
   23c4e:	mov    rsi,QWORD PTR [rsp+0x8]
   23c53:	movabs rbx,0xff00000000000000
   23c5d:	jne    23c6c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3d2c>
   23c5f:	mov    rdi,r12
   23c62:	call   e8c0 <term_drop>
   23c67:	mov    rsi,QWORD PTR [rsp+0x8]
   23c6c:	mov    rdi,r12
   23c6f:	mov    rdx,QWORD PTR [rsp+0x48]
   23c74:	call   5c510 <term_keep>
   23c79:	mov    r13,QWORD PTR [rsp+0x8]
   23c7e:	mov    r10,rax
   23c81:	mov    r8,QWORD PTR [r13+0x8]
   23c85:	test   r8,r8
   23c88:	movabs rbp,0x200080000000000
   23c92:	je     265c1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6681>
   23c98:	mov    rax,QWORD PTR [r12+r8*8]
   23c9c:	mov    QWORD PTR [r13+0x8],rax
   23ca0:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   23ca8:	mov    rax,r15
   23cab:	and    rax,rbx
   23cae:	movabs rcx,0x200000000000000
   23cb8:	cmp    rax,rcx
   23cbb:	movabs rdx,0x300000000000000
   23cc5:	je     265d9 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6699>
   23ccb:	mov    QWORD PTR [r12+r8*8],r15
   23ccf:	and    rbx,r10
   23cd2:	mov    rax,r10
   23cd5:	movabs rcx,0x200000000000000
   23cdf:	cmp    rbx,rcx
   23ce2:	je     265fe <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x66be>
   23ce8:	mov    QWORD PTR [r12+r8*8+0x8],rax
   23ced:	movabs r9,0x2002c0000000000
   23cf7:	or     r9,r8
   23cfa:	mov    rcx,QWORD PTR [r13+0x8]
   23cfe:	test   rcx,rcx
   23d01:	mov    r14,QWORD PTR [rsp+0x20]
   23d06:	mov    r15d,DWORD PTR [rsp+0x14]
   23d0b:	je     26620 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x66e0>
   23d11:	mov    rax,QWORD PTR [r12+rcx*8]
   23d15:	mov    QWORD PTR [r13+0x8],rax
   23d19:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   23d21:	cmp    r9,rdx
   23d24:	jb     26646 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6706>
   23d2a:	lea    r8,[r12+rcx*8]
   23d2e:	mov    QWORD PTR [r12+rcx*8],r9
   23d32:	movabs rax,0x200000000000000
   23d3c:	cmp    rbx,rax
   23d3f:	je     23e7f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3f3f>
   23d45:	mov    QWORD PTR [r8+0x8],r10
   23d49:	or     rcx,rbp
   23d4c:	movabs rax,0x2002d0000000000
   23d56:	mov    rdx,QWORD PTR [rsp+0x58]
   23d5b:	or     rdx,rax
   23d5e:	mov    rsi,QWORD PTR [rsp+0x30]
   23d63:	add    rsp,0x80
   23d6a:	pop    rbp
   23d6b:	jmp    1d730 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_104_105_>
   23d70:	test   rbx,r14
   23d73:	sete   al
   23d76:	cmp    rbx,0xffffffffffffffff
   23d7a:	sete   cl
   23d7d:	or     cl,al
   23d7f:	and    rsi,rbx
   23d82:	cmp    rsi,0x3108200
   23d89:	setb   al
   23d8c:	or     al,cl
   23d8e:	mov    r13,QWORD PTR [rsp+0x8]
   23d93:	movabs rbp,0xff00000000000000
   23d9d:	jne    23db8 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3e78>
   23d9f:	mov    r14,rdi
   23da2:	mov    rdi,r12
   23da5:	mov    rsi,r13
   23da8:	mov    rdx,rbx
   23dab:	call   e8c0 <term_drop>
   23db0:	mov    rdi,r14
   23db3:	mov    r13,QWORD PTR [rsp+0x8]
   23db8:	mov    r8,QWORD PTR [r13+0x8]
   23dbc:	test   r8,r8
   23dbf:	je     26667 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6727>
   23dc5:	mov    rax,QWORD PTR [r12+r8*8]
   23dc9:	mov    QWORD PTR [r13+0x8],rax
   23dcd:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   23dd5:	mov    r10,QWORD PTR [rsp+0x18]
   23dda:	mov    rdx,QWORD PTR [rsp+0x48]
   23ddf:	mov    rax,r15
   23de2:	and    rax,rbp
   23de5:	movabs rcx,0x200000000000000
   23def:	cmp    rax,rcx
   23df2:	je     26685 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6745>
   23df8:	mov    QWORD PTR [r12+r8*8],r15
   23dfc:	mov    rax,rdx
   23dff:	and    rax,rbp
   23e02:	movabs rcx,0x200000000000000
   23e0c:	cmp    rax,rcx
   23e0f:	je     266ab <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x676b>
   23e15:	mov    r14,QWORD PTR [rsp+0x20]
   23e1a:	mov    r15d,DWORD PTR [rsp+0x14]
   23e1f:	mov    QWORD PTR [r12+r8*8+0x8],rdx
   23e24:	movabs r9,0x2002c0000000000
   23e2e:	or     r9,r8
   23e31:	mov    rcx,QWORD PTR [r13+0x8]
   23e35:	test   rcx,rcx
   23e38:	je     266c9 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6789>
   23e3e:	mov    rax,QWORD PTR [r12+rcx*8]
   23e42:	mov    QWORD PTR [r13+0x8],rax
   23e46:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   23e4e:	cmp    r9,rdi
   23e51:	jb     266eb <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x67ab>
   23e57:	lea    r8,[r12+rcx*8]
   23e5b:	mov    QWORD PTR [r12+rcx*8],r9
   23e5f:	and    rbp,r10
   23e62:	movabs rax,0x200000000000000
   23e6c:	cmp    rbp,rax
   23e6f:	movabs rbp,0x200080000000000
   23e79:	jne    23d45 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3e05>
   23e7f:	mov    rdi,r12
   23e82:	mov    rsi,r13
   23e85:	mov    rdx,r10
   23e88:	mov    r9,rcx
   23e8b:	mov    ecx,0x1
   23e90:	call   5e661 <rfc_wrap>
   23e95:	mov    rcx,r9
   23e98:	mov    r10,rax
   23e9b:	jmp    23d45 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3e05>
   23ea0:	movabs r10,0x100040000000000
   23eaa:	mov    rsi,QWORD PTR [rsp+0x8]
   23eaf:	mov    r8,QWORD PTR [rsi+0x8]
   23eb3:	test   r8,r8
   23eb6:	je     2589a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x595a>
   23ebc:	mov    rax,QWORD PTR [r12+r8*8]
   23ec0:	mov    QWORD PTR [rsi+0x8],rax
   23ec4:	add    QWORD PTR [rsi+0x108],0xfffffffffffffffe
   23ecc:	mov    rax,r9
   23ecf:	and    rax,rbp
   23ed2:	movabs rcx,0x200000000000000
   23edc:	cmp    rax,rcx
   23edf:	je     258b5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5975>
   23ee5:	mov    QWORD PTR [r12+r8*8],r9
   23ee9:	mov    rax,r14
   23eec:	and    rax,rbp
   23eef:	cmp    rax,rcx
   23ef2:	je     258e2 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x59a2>
   23ef8:	movabs r9,0x200080000000000
   23f02:	mov    QWORD PTR [r12+r8*8+0x8],r14
   23f07:	or     r8,r9
   23f0a:	mov    rsi,QWORD PTR [rsp+0x8]
   23f0f:	mov    rbx,QWORD PTR [rsi+0x8]
   23f13:	test   rbx,rbx
   23f16:	je     25905 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x59c5>
   23f1c:	mov    rax,QWORD PTR [r12+rbx*8]
   23f20:	mov    QWORD PTR [rsi+0x8],rax
   23f24:	add    QWORD PTR [rsi+0x108],0xfffffffffffffffe
   23f2c:	mov    rax,r8
   23f2f:	shr    rax,0x38
   23f33:	cmp    eax,0x2
   23f36:	jbe    2592b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x59eb>
   23f3c:	mov    QWORD PTR [rsp+0x38],r15
   23f41:	mov    QWORD PTR [r12+rbx*8],r8
   23f45:	mov    QWORD PTR [r12+rbx*8+0x8],r10
   23f4a:	mov    rdx,rbx
   23f4d:	or     rdx,r9
   23f50:	mov    rax,rdx
   23f53:	and    rax,r11
   23f56:	movabs rbp,0x80000000000
   23f60:	cmp    rax,rbp
   23f63:	jne    28a36 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8af6>
   23f69:	mov    r13,r11
   23f6c:	lea    r8,[rsp+0x70]
   23f71:	mov    rdi,r12
   23f74:	mov    rbx,QWORD PTR [rsp+0x8]
   23f79:	mov    rsi,rbx
   23f7c:	mov    ecx,0x2
   23f81:	call   e600 <ctr_take>
   23f86:	mov    rdi,r12
   23f89:	mov    rsi,rbx
   23f8c:	mov    edx,0x1
   23f91:	mov    rcx,rax
   23f94:	call   e5b0 <spare_free>
   23f99:	mov    rdx,QWORD PTR [rsp+0x70]
   23f9e:	mov    r15,QWORD PTR [rsp+0x78]
   23fa3:	mov    rax,rdx
   23fa6:	and    rax,r13
   23fa9:	cmp    rax,rbp
   23fac:	jne    28cab <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8d6b>
   23fb2:	mov    r14,r13
   23fb5:	lea    r8,[rsp+0x60]
   23fba:	mov    rdi,r12
   23fbd:	mov    rsi,rbx
   23fc0:	mov    ecx,0x2
   23fc5:	call   e600 <ctr_take>
   23fca:	mov    rdi,r12
   23fcd:	mov    rsi,rbx
   23fd0:	mov    edx,0x1
   23fd5:	mov    rcx,rax
   23fd8:	call   e5b0 <spare_free>
   23fdd:	mov    rdx,QWORD PTR [rsp+0x60]
   23fe2:	mov    rbx,QWORD PTR [rsp+0x68]
   23fe7:	movabs r13,0x7e00000000000000
   23ff1:	test   rdx,r13
   23ff4:	sete   al
   23ff7:	cmp    rdx,0xffffffffffffffff
   23ffb:	sete   cl
   23ffe:	or     cl,al
   24000:	mov    rax,rdx
   24003:	movabs rsi,0xfffffffe00
   2400d:	and    rax,rsi
   24010:	cmp    rax,0x3108200
   24016:	setb   al
   24019:	or     al,cl
   2401b:	movabs rbp,0xff00000000000000
   24025:	jne    2403e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x40fe>
   24027:	mov    rdi,r12
   2402a:	mov    rsi,QWORD PTR [rsp+0x8]
   2402f:	call   e8c0 <term_drop>
   24034:	movabs rsi,0xfffffffe00
   2403e:	movabs r9,0x300000000000000
   24048:	and    r14,r15
   2404b:	movabs rax,0x40000000000
   24055:	cmp    r14,rax
   24058:	jne    2417b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x423b>
   2405e:	mov    rdx,QWORD PTR [rsp+0x18]
   24063:	test   rdx,r13
   24066:	sete   al
   24069:	cmp    rdx,0xffffffffffffffff
   2406d:	sete   cl
   24070:	or     cl,al
   24072:	and    rsi,rdx
   24075:	cmp    rsi,0x3108200
   2407c:	setb   al
   2407f:	or     al,cl
   24081:	mov    rsi,QWORD PTR [rsp+0x8]
   24086:	jne    24095 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4155>
   24088:	mov    rdi,r12
   2408b:	call   e8c0 <term_drop>
   24090:	mov    rsi,QWORD PTR [rsp+0x8]
   24095:	mov    rdi,r12
   24098:	mov    rdx,QWORD PTR [rsp+0x28]
   2409d:	call   5c510 <term_keep>
   240a2:	mov    r13,QWORD PTR [rsp+0x8]
   240a7:	mov    r10,rax
   240aa:	mov    r8,QWORD PTR [r13+0x8]
   240ae:	test   r8,r8
   240b1:	mov    r14,QWORD PTR [rsp+0x20]
   240b6:	mov    r15d,DWORD PTR [rsp+0x14]
   240bb:	je     2670c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x67cc>
   240c1:	mov    rax,QWORD PTR [r12+r8*8]
   240c5:	mov    QWORD PTR [r13+0x8],rax
   240c9:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   240d1:	mov    rax,rbx
   240d4:	and    rax,rbp
   240d7:	movabs rdx,0x200000000000000
   240e1:	cmp    rax,rdx
   240e4:	movabs r9,0x300000000000000
   240ee:	je     26724 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x67e4>
   240f4:	mov    QWORD PTR [r12+r8*8],rbx
   240f8:	and    rbp,r10
   240fb:	mov    rax,r10
   240fe:	cmp    rbp,rdx
   24101:	je     26749 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6809>
   24107:	mov    QWORD PTR [r12+r8*8+0x8],rax
   2410c:	movabs rbx,0x2002c0000000000
   24116:	or     r8,rbx
   24119:	mov    rcx,QWORD PTR [r13+0x8]
   2411d:	test   rcx,rcx
   24120:	je     2676b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x682b>
   24126:	mov    rax,QWORD PTR [r12+rcx*8]
   2412a:	mov    QWORD PTR [r13+0x8],rax
   2412e:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   24136:	cmp    r8,r9
   24139:	jb     26791 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6851>
   2413f:	lea    r9,[r12+rcx*8]
   24143:	mov    QWORD PTR [r12+rcx*8],r8
   24147:	cmp    rbp,rdx
   2414a:	je     24262 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4322>
   24150:	mov    QWORD PTR [r9+0x8],r10
   24154:	movabs rax,0x200080000000000
   2415e:	or     rcx,rax
   24161:	mov    rdx,QWORD PTR [rsp+0x38]
   24166:	or     rdx,rbx
   24169:	mov    rsi,QWORD PTR [rsp+0x30]
   2416e:	add    rsp,0x80
   24175:	pop    rbp
   24176:	jmp    1e7c0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_108_111_>
   2417b:	test   r15,r13
   2417e:	sete   al
   24181:	cmp    r15,0xffffffffffffffff
   24185:	sete   cl
   24188:	or     cl,al
   2418a:	and    rsi,r15
   2418d:	cmp    rsi,0x3108200
   24194:	setb   al
   24197:	or     al,cl
   24199:	mov    r13,QWORD PTR [rsp+0x8]
   2419e:	jne    241b9 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4279>
   241a0:	mov    rdi,r12
   241a3:	mov    rsi,r13
   241a6:	mov    rdx,r15
   241a9:	mov    r14,r9
   241ac:	call   e8c0 <term_drop>
   241b1:	mov    r9,r14
   241b4:	mov    r13,QWORD PTR [rsp+0x8]
   241b9:	mov    r8,QWORD PTR [r13+0x8]
   241bd:	test   r8,r8
   241c0:	je     267cd <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x688d>
   241c6:	mov    rax,QWORD PTR [r12+r8*8]
   241ca:	mov    QWORD PTR [r13+0x8],rax
   241ce:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   241d6:	mov    r14,QWORD PTR [rsp+0x20]
   241db:	mov    r15d,DWORD PTR [rsp+0x14]
   241e0:	mov    rdx,QWORD PTR [rsp+0x28]
   241e5:	mov    rax,rbx
   241e8:	and    rax,rbp
   241eb:	movabs rsi,0x200000000000000
   241f5:	cmp    rax,rsi
   241f8:	je     267e5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x68a5>
   241fe:	mov    QWORD PTR [r12+r8*8],rbx
   24202:	mov    rax,rdx
   24205:	and    rax,rbp
   24208:	cmp    rax,rsi
   2420b:	je     2680f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x68cf>
   24211:	mov    r10,QWORD PTR [rsp+0x18]
   24216:	movabs rbx,0x2002c0000000000
   24220:	mov    QWORD PTR [r12+r8*8+0x8],rdx
   24225:	or     r8,rbx
   24228:	mov    rcx,QWORD PTR [r13+0x8]
   2422c:	test   rcx,rcx
   2422f:	je     26831 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x68f1>
   24235:	mov    rax,QWORD PTR [r12+rcx*8]
   24239:	mov    QWORD PTR [r13+0x8],rax
   2423d:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   24245:	cmp    r8,r9
   24248:	jb     26857 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6917>
   2424e:	lea    r9,[r12+rcx*8]
   24252:	mov    QWORD PTR [r12+rcx*8],r8
   24256:	and    rbp,r10
   24259:	cmp    rbp,rsi
   2425c:	jne    24150 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4210>
   24262:	mov    rdi,r12
   24265:	mov    rsi,r13
   24268:	mov    rdx,r10
   2426b:	mov    r8,rcx
   2426e:	mov    ecx,0x1
   24273:	call   5e661 <rfc_wrap>
   24278:	mov    rcx,r8
   2427b:	mov    r10,rax
   2427e:	jmp    24150 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4210>
   24283:	movabs r9,0x100040000000000
   2428d:	mov    r8,QWORD PTR [r13+0x8]
   24291:	test   r8,r8
   24294:	je     2594e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5a0e>
   2429a:	mov    rax,QWORD PTR [r12+r8*8]
   2429e:	mov    QWORD PTR [r13+0x8],rax
   242a2:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   242aa:	movabs rcx,0xff00000000000000
   242b4:	mov    rax,rdx
   242b7:	shr    rax,0x38
   242bb:	cmp    eax,0x2
   242be:	je     25972 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5a32>
   242c4:	mov    QWORD PTR [r12+r8*8],rdx
   242c8:	mov    rax,rbx
   242cb:	and    rax,rcx
   242ce:	movabs rcx,0x200000000000000
   242d8:	cmp    rax,rcx
   242db:	je     2599a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5a5a>
   242e1:	movabs r10,0x200080000000000
   242eb:	mov    QWORD PTR [r12+r8*8+0x8],rbx
   242f0:	or     r8,r10
   242f3:	mov    rbx,QWORD PTR [r13+0x8]
   242f7:	test   rbx,rbx
   242fa:	je     259bb <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5a7b>
   24300:	mov    rax,QWORD PTR [r12+rbx*8]
   24304:	mov    QWORD PTR [r13+0x8],rax
   24308:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   24310:	mov    rax,r8
   24313:	shr    rax,0x38
   24317:	cmp    eax,0x2
   2431a:	jbe    259e4 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5aa4>
   24320:	mov    QWORD PTR [rsp+0x28],r15
   24325:	mov    QWORD PTR [r12+rbx*8],r8
   24329:	mov    QWORD PTR [r12+rbx*8+0x8],r9
   2432e:	mov    rdx,rbx
   24331:	or     rdx,r10
   24334:	mov    rax,rdx
   24337:	and    rax,r11
   2433a:	cmp    rax,rbp
   2433d:	jne    26fa4 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7064>
   24343:	mov    r14,r11
   24346:	lea    r8,[rsp+0x70]
   2434b:	mov    rdi,r12
   2434e:	mov    rsi,r13
   24351:	mov    ecx,0x2
   24356:	call   e600 <ctr_take>
   2435b:	mov    rdi,r12
   2435e:	mov    rsi,r13
   24361:	mov    edx,0x1
   24366:	mov    rcx,rax
   24369:	call   e5b0 <spare_free>
   2436e:	mov    rdx,QWORD PTR [rsp+0x70]
   24373:	mov    rbx,QWORD PTR [rsp+0x78]
   24378:	mov    rax,rdx
   2437b:	and    rax,r14
   2437e:	cmp    rax,rbp
   24381:	jne    2703b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x70fb>
   24387:	mov    r15,r14
   2438a:	movabs rbp,0x7e00000000000000
   24394:	lea    r8,[rsp+0x60]
   24399:	mov    rdi,r12
   2439c:	mov    rsi,r13
   2439f:	mov    ecx,0x2
   243a4:	call   e600 <ctr_take>
   243a9:	mov    rdi,r12
   243ac:	mov    rsi,r13
   243af:	mov    edx,0x1
   243b4:	mov    rcx,rax
   243b7:	call   e5b0 <spare_free>
   243bc:	mov    rdx,QWORD PTR [rsp+0x60]
   243c1:	mov    r14,QWORD PTR [rsp+0x68]
   243c6:	test   rdx,rbp
   243c9:	sete   al
   243cc:	cmp    rdx,0xffffffffffffffff
   243d0:	sete   cl
   243d3:	or     cl,al
   243d5:	mov    rax,rdx
   243d8:	movabs rsi,0xfffffffe00
   243e2:	and    rax,rsi
   243e5:	cmp    rax,0x3108200
   243eb:	setb   al
   243ee:	or     al,cl
   243f0:	jne    24409 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x44c9>
   243f2:	mov    rdi,r12
   243f5:	mov    rsi,QWORD PTR [rsp+0x8]
   243fa:	call   e8c0 <term_drop>
   243ff:	movabs rsi,0xfffffffe00
   24409:	movabs rdi,0x300000000000000
   24413:	and    r15,rbx
   24416:	movabs rax,0x40000000000
   24420:	cmp    r15,rax
   24423:	jne    24529 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x45e9>
   24429:	mov    rdx,QWORD PTR [rsp+0x18]
   2442e:	test   rdx,rbp
   24431:	sete   al
   24434:	cmp    rdx,0xffffffffffffffff
   24438:	sete   cl
   2443b:	or     cl,al
   2443d:	and    rsi,rdx
   24440:	cmp    rsi,0x3108200
   24447:	setb   al
   2444a:	or     al,cl
   2444c:	mov    rsi,QWORD PTR [rsp+0x8]
   24451:	mov    rbx,QWORD PTR [rsp+0x28]
   24456:	jne    24465 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4525>
   24458:	mov    rdi,r12
   2445b:	call   e8c0 <term_drop>
   24460:	mov    rsi,QWORD PTR [rsp+0x8]
   24465:	mov    rdi,r12
   24468:	mov    rdx,rbx
   2446b:	call   5c510 <term_keep>
   24470:	mov    r13,QWORD PTR [rsp+0x8]
   24475:	mov    rbx,rax
   24478:	mov    r8,QWORD PTR [r13+0x8]
   2447c:	test   r8,r8
   2447f:	mov    rsi,QWORD PTR [rsp+0x30]
   24484:	movabs rbp,0x200000000000000
   2448e:	je     26882 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6942>
   24494:	mov    rax,QWORD PTR [r12+r8*8]
   24498:	mov    QWORD PTR [r13+0x8],rax
   2449c:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   244a4:	mov    rax,r14
   244a7:	movabs rdx,0xff00000000000000
   244b1:	and    rax,rdx
   244b4:	cmp    rax,rbp
   244b7:	movabs rdi,0x300000000000000
   244c1:	je     268a0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6960>
   244c7:	mov    QWORD PTR [r12+r8*8],r14
   244cb:	and    rdx,rbx
   244ce:	mov    rax,rbx
   244d1:	cmp    rdx,rbp
   244d4:	je     268d5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6995>
   244da:	mov    QWORD PTR [r12+r8*8+0x8],rax
   244df:	movabs r9,0x2002c0000000000
   244e9:	or     r9,r8
   244ec:	mov    rcx,QWORD PTR [r13+0x8]
   244f0:	test   rcx,rcx
   244f3:	mov    r10,QWORD PTR [rsp+0x20]
   244f8:	mov    r15d,DWORD PTR [rsp+0x14]
   244fd:	je     26903 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x69c3>
   24503:	mov    rax,QWORD PTR [r12+rcx*8]
   24507:	mov    QWORD PTR [r13+0x8],rax
   2450b:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   24513:	cmp    r9,rdi
   24516:	jb     26935 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x69f5>
   2451c:	lea    r8,[r12+rcx*8]
   24520:	mov    QWORD PTR [r12+rcx*8],r9
   24524:	jmp    2461b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x46db>
   24529:	test   rbx,rbp
   2452c:	sete   al
   2452f:	cmp    rbx,0xffffffffffffffff
   24533:	sete   cl
   24536:	or     cl,al
   24538:	and    rsi,rbx
   2453b:	cmp    rsi,0x3108200
   24542:	setb   al
   24545:	or     al,cl
   24547:	mov    r13,QWORD PTR [rsp+0x8]
   2454c:	mov    r15,QWORD PTR [rsp+0x28]
   24551:	jne    2456c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x462c>
   24553:	mov    rbp,rdi
   24556:	mov    rdi,r12
   24559:	mov    rsi,r13
   2455c:	mov    rdx,rbx
   2455f:	call   e8c0 <term_drop>
   24564:	mov    rdi,rbp
   24567:	mov    r13,QWORD PTR [rsp+0x8]
   2456c:	mov    r8,QWORD PTR [r13+0x8]
   24570:	test   r8,r8
   24573:	mov    rsi,QWORD PTR [rsp+0x30]
   24578:	movabs rbp,0x200000000000000
   24582:	je     2696c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6a2c>
   24588:	mov    rax,QWORD PTR [r12+r8*8]
   2458c:	mov    QWORD PTR [r13+0x8],rax
   24590:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   24598:	mov    rbx,QWORD PTR [rsp+0x18]
   2459d:	mov    rax,r14
   245a0:	movabs rdx,0xff00000000000000
   245aa:	and    rax,rdx
   245ad:	cmp    rax,rbp
   245b0:	je     26990 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6a50>
   245b6:	mov    QWORD PTR [r12+r8*8],r14
   245ba:	mov    rax,r15
   245bd:	and    rax,rdx
   245c0:	cmp    rax,rbp
   245c3:	je     269c1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6a81>
   245c9:	mov    r10,QWORD PTR [rsp+0x20]
   245ce:	mov    r15d,DWORD PTR [rsp+0x14]
   245d3:	mov    rax,QWORD PTR [rsp+0x28]
   245d8:	mov    QWORD PTR [r12+r8*8+0x8],rax
   245dd:	movabs r9,0x2002c0000000000
   245e7:	or     r9,r8
   245ea:	mov    rcx,QWORD PTR [r13+0x8]
   245ee:	test   rcx,rcx
   245f1:	je     269f4 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6ab4>
   245f7:	mov    rax,QWORD PTR [r12+rcx*8]
   245fb:	mov    QWORD PTR [r13+0x8],rax
   245ff:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   24607:	cmp    r9,rdi
   2460a:	jb     26a26 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6ae6>
   24610:	lea    r8,[r12+rcx*8]
   24614:	mov    QWORD PTR [r12+rcx*8],r9
   24618:	and    rdx,rbx
   2461b:	cmp    rdx,rbp
   2461e:	je     25b27 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5be7>
   24624:	mov    QWORD PTR [r8+0x8],rbx
   24628:	movabs rax,0x200080000000000
   24632:	or     rcx,rax
   24635:	movabs rdx,0x1002b0000000000
   2463f:	mov    r14,r10
   24642:	add    rsp,0x80
   24649:	pop    rbp
   2464a:	jmp    1d730 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_104_105_>
   2464f:	movabs r9,0x100040000000000
   24659:	mov    r8,QWORD PTR [r13+0x8]
   2465d:	test   r8,r8
   24660:	jne    231e8 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x32a8>
   24666:	mov    rdi,r12
   24669:	mov    rsi,r13
   2466c:	mov    edx,0x1
   24671:	mov    rcx,r11
   24674:	call   5e35b <heap_alloc_miss>
   24679:	movabs rdx,0x200000000000000
   24683:	mov    r11,rcx
   24686:	mov    r8,rax
   24689:	mov    rax,QWORD PTR [rsp+0x40]
   2468e:	and    rax,rbp
   24691:	cmp    rax,rdx
   24694:	jne    23209 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x32c9>
   2469a:	mov    rdi,r12
   2469d:	mov    rsi,r13
   246a0:	mov    rdx,QWORD PTR [rsp+0x40]
   246a5:	mov    ecx,0x1
   246aa:	mov    r10,r11
   246ad:	call   5e661 <rfc_wrap>
   246b2:	movabs rdx,0x200000000000000
   246bc:	mov    r11,r10
   246bf:	mov    QWORD PTR [rsp+0x40],rax
   246c4:	jmp    23209 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x32c9>
   246c9:	movabs r9,0x100040000000000
   246d3:	mov    r8,QWORD PTR [r13+0x8]
   246d7:	test   r8,r8
   246da:	je     25a70 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5b30>
   246e0:	mov    rax,QWORD PTR [r12+r8*8]
   246e4:	mov    QWORD PTR [r13+0x8],rax
   246e8:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   246f0:	movabs rcx,0xff00000000000000
   246fa:	mov    rax,rdx
   246fd:	shr    rax,0x38
   24701:	cmp    eax,0x2
   24704:	je     25a94 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5b54>
   2470a:	mov    QWORD PTR [r12+r8*8],rdx
   2470e:	mov    rax,r14
   24711:	and    rax,rcx
   24714:	movabs rcx,0x200000000000000
   2471e:	cmp    rax,rcx
   24721:	je     25abc <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5b7c>
   24727:	movabs r10,0x200080000000000
   24731:	mov    QWORD PTR [r12+r8*8+0x8],r14
   24736:	or     r8,r10
   24739:	mov    rbx,QWORD PTR [r13+0x8]
   2473d:	test   rbx,rbx
   24740:	je     25add <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5b9d>
   24746:	mov    rax,QWORD PTR [r12+rbx*8]
   2474a:	mov    QWORD PTR [r13+0x8],rax
   2474e:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   24756:	mov    rax,r8
   24759:	shr    rax,0x38
   2475d:	cmp    eax,0x2
   24760:	jbe    25b06 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5bc6>
   24766:	mov    QWORD PTR [r12+rbx*8],r8
   2476a:	mov    QWORD PTR [r12+rbx*8+0x8],r9
   2476f:	mov    rdx,rbx
   24772:	or     rdx,r10
   24775:	mov    rax,rdx
   24778:	and    rax,r11
   2477b:	cmp    rax,rbp
   2477e:	jne    26fa4 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7064>
   24784:	mov    r14,r11
   24787:	lea    r8,[rsp+0x70]
   2478c:	mov    rdi,r12
   2478f:	mov    rsi,r13
   24792:	mov    ecx,0x2
   24797:	call   e600 <ctr_take>
   2479c:	mov    rdi,r12
   2479f:	mov    rsi,r13
   247a2:	mov    edx,0x1
   247a7:	mov    rcx,rax
   247aa:	call   e5b0 <spare_free>
   247af:	mov    rdx,QWORD PTR [rsp+0x70]
   247b4:	mov    rbx,QWORD PTR [rsp+0x78]
   247b9:	mov    rax,rdx
   247bc:	and    rax,r14
   247bf:	cmp    rax,rbp
   247c2:	jne    2703b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x70fb>
   247c8:	mov    r15,r14
   247cb:	movabs rbp,0x7e00000000000000
   247d5:	lea    r8,[rsp+0x60]
   247da:	mov    rdi,r12
   247dd:	mov    rsi,r13
   247e0:	mov    ecx,0x2
   247e5:	call   e600 <ctr_take>
   247ea:	mov    rdi,r12
   247ed:	mov    rsi,r13
   247f0:	mov    edx,0x1
   247f5:	mov    rcx,rax
   247f8:	call   e5b0 <spare_free>
   247fd:	mov    rdx,QWORD PTR [rsp+0x60]
   24802:	mov    r14,QWORD PTR [rsp+0x68]
   24807:	test   rdx,rbp
   2480a:	sete   al
   2480d:	cmp    rdx,0xffffffffffffffff
   24811:	sete   cl
   24814:	or     cl,al
   24816:	mov    rax,rdx
   24819:	movabs rsi,0xfffffffe00
   24823:	and    rax,rsi
   24826:	cmp    rax,0x3108200
   2482c:	setb   al
   2482f:	or     al,cl
   24831:	jne    2484a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x490a>
   24833:	mov    rdi,r12
   24836:	mov    rsi,QWORD PTR [rsp+0x8]
   2483b:	call   e8c0 <term_drop>
   24840:	movabs rsi,0xfffffffe00
   2484a:	movabs r11,0x300000000000000
   24854:	and    r15,rbx
   24857:	movabs rax,0x40000000000
   24861:	cmp    r15,rax
   24864:	jne    24996 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4a56>
   2486a:	mov    rdx,QWORD PTR [rsp+0x18]
   2486f:	test   rdx,rbp
   24872:	sete   al
   24875:	cmp    rdx,0xffffffffffffffff
   24879:	sete   cl
   2487c:	or     cl,al
   2487e:	and    rsi,rdx
   24881:	cmp    rsi,0x3108200
   24888:	setb   al
   2488b:	or     al,cl
   2488d:	mov    rsi,QWORD PTR [rsp+0x8]
   24892:	jne    248a1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4961>
   24894:	mov    rdi,r12
   24897:	call   e8c0 <term_drop>
   2489c:	mov    rsi,QWORD PTR [rsp+0x8]
   248a1:	mov    rdi,r12
   248a4:	mov    rdx,QWORD PTR [rsp+0x28]
   248a9:	call   5c510 <term_keep>
   248ae:	mov    r13,QWORD PTR [rsp+0x8]
   248b3:	mov    rbx,rax
   248b6:	mov    r8,QWORD PTR [r13+0x8]
   248ba:	test   r8,r8
   248bd:	mov    rsi,QWORD PTR [rsp+0x30]
   248c2:	movabs rbp,0x200000000000000
   248cc:	je     26c0d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6ccd>
   248d2:	mov    rax,QWORD PTR [r12+r8*8]
   248d6:	mov    QWORD PTR [r13+0x8],rax
   248da:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   248e2:	mov    rax,r14
   248e5:	movabs rdx,0xff00000000000000
   248ef:	and    rax,rdx
   248f2:	cmp    rax,rbp
   248f5:	movabs rdi,0x300000000000000
   248ff:	je     26c2b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6ceb>
   24905:	mov    QWORD PTR [r12+r8*8],r14
   24909:	and    rdx,rbx
   2490c:	mov    rax,rbx
   2490f:	cmp    rdx,rbp
   24912:	je     26c60 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6d20>
   24918:	mov    QWORD PTR [r12+r8*8+0x8],rax
   2491d:	movabs r9,0x2002c0000000000
   24927:	or     r9,r8
   2492a:	mov    rcx,QWORD PTR [r13+0x8]
   2492e:	test   rcx,rcx
   24931:	mov    r10,QWORD PTR [rsp+0x20]
   24936:	mov    r15d,DWORD PTR [rsp+0x14]
   2493b:	je     26c8e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6d4e>
   24941:	mov    rax,QWORD PTR [r12+rcx*8]
   24945:	mov    QWORD PTR [r13+0x8],rax
   24949:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   24951:	cmp    r9,rdi
   24954:	jb     26cc0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6d80>
   2495a:	lea    r8,[r12+rcx*8]
   2495e:	mov    QWORD PTR [r12+rcx*8],r9
   24962:	cmp    rdx,rbp
   24965:	je     24a8c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4b4c>
   2496b:	mov    QWORD PTR [r8+0x8],rbx
   2496f:	movabs rax,0x200080000000000
   24979:	or     rcx,rax
   2497c:	movabs rdx,0x1002b0000000000
   24986:	mov    r14,r10
   24989:	add    rsp,0x80
   24990:	pop    rbp
   24991:	jmp    1e7c0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_108_111_>
   24996:	test   rbx,rbp
   24999:	sete   al
   2499c:	cmp    rbx,0xffffffffffffffff
   249a0:	sete   cl
   249a3:	or     cl,al
   249a5:	and    rsi,rbx
   249a8:	cmp    rsi,0x3108200
   249af:	setb   al
   249b2:	or     al,cl
   249b4:	mov    r13,QWORD PTR [rsp+0x8]
   249b9:	jne    249d4 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4a94>
   249bb:	mov    rdi,r12
   249be:	mov    rsi,r13
   249c1:	mov    rdx,rbx
   249c4:	mov    rbx,r11
   249c7:	call   e8c0 <term_drop>
   249cc:	mov    r11,rbx
   249cf:	mov    r13,QWORD PTR [rsp+0x8]
   249d4:	mov    r8,QWORD PTR [r13+0x8]
   249d8:	test   r8,r8
   249db:	mov    rsi,QWORD PTR [rsp+0x30]
   249e0:	movabs rbp,0x200000000000000
   249ea:	je     26d08 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6dc8>
   249f0:	mov    rax,QWORD PTR [r12+r8*8]
   249f4:	mov    QWORD PTR [r13+0x8],rax
   249f8:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   24a00:	mov    rbx,QWORD PTR [rsp+0x18]
   24a05:	mov    rax,r14
   24a08:	movabs rdi,0xff00000000000000
   24a12:	and    rax,rdi
   24a15:	cmp    rax,rbp
   24a18:	mov    rdx,QWORD PTR [rsp+0x28]
   24a1d:	je     26d2c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6dec>
   24a23:	mov    QWORD PTR [r12+r8*8],r14
   24a27:	mov    rax,rdx
   24a2a:	and    rax,rdi
   24a2d:	cmp    rax,rbp
   24a30:	je     26d62 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6e22>
   24a36:	mov    r10,QWORD PTR [rsp+0x20]
   24a3b:	mov    r15d,DWORD PTR [rsp+0x14]
   24a40:	mov    QWORD PTR [r12+r8*8+0x8],rdx
   24a45:	movabs r9,0x2002c0000000000
   24a4f:	or     r9,r8
   24a52:	mov    rcx,QWORD PTR [r13+0x8]
   24a56:	test   rcx,rcx
   24a59:	je     26d90 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6e50>
   24a5f:	mov    rax,QWORD PTR [r12+rcx*8]
   24a63:	mov    QWORD PTR [r13+0x8],rax
   24a67:	add    QWORD PTR [r13+0x108],0xfffffffffffffffe
   24a6f:	cmp    r9,r11
   24a72:	jb     26dc2 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6e82>
   24a78:	lea    r8,[r12+rcx*8]
   24a7c:	mov    QWORD PTR [r12+rcx*8],r9
   24a80:	and    rdi,rbx
   24a83:	cmp    rdi,rbp
   24a86:	jne    2496b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4a2b>
   24a8c:	mov    rdi,r12
   24a8f:	mov    r14,rsi
   24a92:	mov    rsi,r13
   24a95:	mov    rdx,rbx
   24a98:	mov    r9,rcx
   24a9b:	mov    ecx,0x1
   24aa0:	call   5e661 <rfc_wrap>
   24aa5:	mov    rsi,r14
   24aa8:	mov    rcx,r9
   24aab:	mov    rbx,rax
   24aae:	jmp    2496b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4a2b>
   24ab3:	mov    rdi,r12
   24ab6:	mov    rsi,r13
   24ab9:	xor    edx,edx
   24abb:	mov    rax,r11
   24abe:	call   5e231 <heap_hand>
   24ac3:	mov    r11,rax
   24ac6:	movabs rdi,0xfffffffe00
   24ad0:	cmp    rcx,0x3108200
   24ad7:	jae    202a6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x366>
   24add:	jmp    202dd <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x39d>
   24ae2:	mov    rdi,r12
   24ae5:	mov    rsi,r13
   24ae8:	xor    edx,edx
   24aea:	call   5e231 <heap_hand>
   24aef:	movabs rdi,0xfffffffe00
   24af9:	mov    r11,r9
   24afc:	mov    r9,rbx
   24aff:	cmp    rcx,0x3108200
   24b06:	jb     20404 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4c4>
   24b0c:	jmp    203cd <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x48d>
   24b11:	mov    rdi,r12
   24b14:	mov    rcx,rsi
   24b17:	mov    rsi,QWORD PTR [rsp+0x8]
   24b1c:	mov    edx,0x2
   24b21:	call   5e35b <heap_alloc_miss>
   24b26:	mov    rsi,rcx
   24b29:	mov    r9,rax
   24b2c:	jmp    22424 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x24e4>
   24b31:	mov    rdi,r12
   24b34:	mov    rbp,rsi
   24b37:	mov    rsi,QWORD PTR [rsp+0x8]
   24b3c:	mov    rdx,QWORD PTR [rsp+0x30]
   24b41:	mov    ecx,0x1
   24b46:	call   5e661 <rfc_wrap>
   24b4b:	mov    rsi,rbp
   24b4e:	mov    QWORD PTR [rsp+0x30],rax
   24b53:	jmp    2243f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x24ff>
   24b58:	mov    rdi,r12
   24b5b:	mov    rcx,rsi
   24b5e:	mov    rsi,rdx
   24b61:	mov    edx,0x1
   24b66:	call   5e35b <heap_alloc_miss>
   24b6b:	mov    rsi,rcx
   24b6e:	mov    r9,rax
   24b71:	cmp    r8,rbx
   24b74:	jae    22480 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2540>
   24b7a:	mov    rdi,r12
   24b7d:	mov    rbx,rsi
   24b80:	mov    rsi,QWORD PTR [rsp+0x8]
   24b85:	mov    rdx,r8
   24b88:	mov    ecx,0x1
   24b8d:	call   5e661 <rfc_wrap>
   24b92:	mov    rsi,rbx
   24b95:	mov    r8,rax
   24b98:	jmp    22480 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2540>
   24b9d:	mov    rdi,r12
   24ba0:	mov    r8,rsi
   24ba3:	mov    r13,QWORD PTR [rsp+0x8]
   24ba8:	mov    rsi,r13
   24bab:	mov    rdx,rax
   24bae:	mov    ecx,0x1
   24bb3:	call   5e661 <rfc_wrap>
   24bb8:	mov    rsi,r8
   24bbb:	mov    r14,QWORD PTR [rsp+0x20]
   24bc0:	jmp    2249f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x255f>
   24bc5:	mov    rdi,r12
   24bc8:	mov    r8,rsi
   24bcb:	mov    rsi,r13
   24bce:	mov    edx,0x1
   24bd3:	mov    rcx,r11
   24bd6:	call   5e35b <heap_alloc_miss>
   24bdb:	mov    rsi,r8
   24bde:	mov    r11,rcx
   24be1:	mov    r15,rax
   24be4:	jmp    20dfe <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xebe>
   24be9:	mov    rdi,r12
   24bec:	mov    rbx,rsi
   24bef:	mov    rsi,r13
   24bf2:	mov    rdx,r14
   24bf5:	mov    ecx,0x1
   24bfa:	mov    r8,r11
   24bfd:	call   5e661 <rfc_wrap>
   24c02:	mov    rsi,rbx
   24c05:	mov    rdx,QWORD PTR [rsp+0x28]
   24c0a:	mov    r11,r8
   24c0d:	mov    r14,rax
   24c10:	jmp    20e1d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xedd>
   24c15:	mov    rdi,r12
   24c18:	mov    rbx,rsi
   24c1b:	mov    rsi,r13
   24c1e:	mov    ecx,0x1
   24c23:	mov    r8,r11
   24c26:	call   5e661 <rfc_wrap>
   24c2b:	mov    rsi,rbx
   24c2e:	mov    r11,r8
   24c31:	mov    rdx,rax
   24c34:	jmp    20e3a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xefa>
   24c39:	mov    rdi,r12
   24c3c:	mov    rsi,r13
   24c3f:	mov    edx,0x1
   24c44:	call   5e35b <heap_alloc_miss>
   24c49:	mov    r8,rax
   24c4c:	jmp    21165 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1225>
   24c51:	mov    rdi,r12
   24c54:	mov    rsi,r13
   24c57:	mov    rdx,rcx
   24c5a:	mov    ecx,0x1
   24c5f:	call   5e661 <rfc_wrap>
   24c64:	mov    rdx,QWORD PTR [rsp+0x28]
   24c69:	mov    rcx,rax
   24c6c:	jmp    21184 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1244>
   24c71:	mov    rdi,r12
   24c74:	mov    rsi,r13
   24c77:	mov    ecx,0x1
   24c7c:	call   5e661 <rfc_wrap>
   24c81:	mov    rdx,rax
   24c84:	jmp    211a6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1266>
   24c89:	mov    rdi,r12
   24c8c:	mov    r8,rsi
   24c8f:	mov    rsi,r13
   24c92:	mov    edx,0x2
   24c97:	mov    rcx,r11
   24c9a:	call   5e35b <heap_alloc_miss>
   24c9f:	mov    rsi,r8
   24ca2:	mov    r11,rcx
   24ca5:	mov    rcx,rax
   24ca8:	jmp    21390 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1450>
   24cad:	mov    rdi,r12
   24cb0:	mov    rbx,rsi
   24cb3:	mov    rsi,r13
   24cb6:	mov    ecx,0x1
   24cbb:	mov    r8,r11
   24cbe:	call   5e661 <rfc_wrap>
   24cc3:	mov    rsi,rbx
   24cc6:	mov    r11,r8
   24cc9:	mov    rcx,QWORD PTR [rsp+0x58]
   24cce:	mov    rdx,rax
   24cd1:	jmp    213b4 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1474>
   24cd6:	mov    rdi,r12
   24cd9:	mov    rbx,rsi
   24cdc:	mov    rsi,r13
   24cdf:	mov    rdx,r9
   24ce2:	mov    ecx,0x1
   24ce7:	mov    r8,r11
   24cea:	call   5e661 <rfc_wrap>
   24cef:	mov    rsi,rbx
   24cf2:	mov    r11,r8
   24cf5:	mov    rcx,QWORD PTR [rsp+0x58]
   24cfa:	mov    r9,rax
   24cfd:	jmp    213d1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1491>
   24d02:	mov    rdi,r12
   24d05:	mov    r9,rsi
   24d08:	mov    rsi,r13
   24d0b:	mov    rdx,r14
   24d0e:	mov    ecx,0x1
   24d13:	mov    r8,r11
   24d16:	call   5e661 <rfc_wrap>
   24d1b:	mov    rsi,r9
   24d1e:	mov    r11,r8
   24d21:	mov    rcx,QWORD PTR [rsp+0x58]
   24d26:	mov    r14,rax
   24d29:	jmp    213ef <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x14af>
   24d2e:	mov    rdi,r12
   24d31:	mov    rsi,r13
   24d34:	mov    edx,0x2
   24d39:	call   5e35b <heap_alloc_miss>
   24d3e:	mov    r8,rax
   24d41:	jmp    2262a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x26ea>
   24d46:	mov    rdi,r12
   24d49:	mov    rsi,r13
   24d4c:	mov    rdx,rbx
   24d4f:	mov    ecx,0x1
   24d54:	call   5e661 <rfc_wrap>
   24d59:	mov    rcx,QWORD PTR [rsp+0x48]
   24d5e:	jmp    22641 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2701>
   24d63:	mov    rdi,r12
   24d66:	mov    rsi,r13
   24d69:	mov    rdx,rcx
   24d6c:	mov    ecx,0x1
   24d71:	call   5e661 <rfc_wrap>
   24d76:	mov    rcx,rax
   24d79:	mov    QWORD PTR [r12+r8*8+0x8],rcx
   24d7e:	and    r14,QWORD PTR [rsp+0x58]
   24d83:	cmp    r14,r15
   24d86:	jne    22667 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2727>
   24d8c:	mov    rdi,r12
   24d8f:	mov    rsi,r13
   24d92:	mov    rdx,QWORD PTR [rsp+0x58]
   24d97:	mov    ecx,0x1
   24d9c:	call   5e661 <rfc_wrap>
   24da1:	mov    QWORD PTR [rsp+0x58],rax
   24da6:	jmp    22667 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2727>
   24dab:	mov    r8,rdi
   24dae:	mov    rdi,r12
   24db1:	mov    rcx,rsi
   24db4:	mov    rsi,r13
   24db7:	mov    edx,0x2
   24dbc:	call   5e35b <heap_alloc_miss>
   24dc1:	mov    rdi,r8
   24dc4:	mov    rsi,rcx
   24dc7:	mov    rbx,rax
   24dca:	jmp    2167a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x173a>
   24dcf:	mov    r10,rdi
   24dd2:	mov    rdi,r12
   24dd5:	mov    r8,rsi
   24dd8:	mov    rsi,r13
   24ddb:	mov    ecx,0x1
   24de0:	call   5e661 <rfc_wrap>
   24de5:	mov    rdi,r10
   24de8:	movabs rcx,0x200000000000000
   24df2:	mov    rsi,r8
   24df5:	mov    rdx,rax
   24df8:	jmp    21698 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1758>
   24dfd:	mov    r10,rdi
   24e00:	mov    rdi,r12
   24e03:	mov    r8,rsi
   24e06:	mov    rsi,r13
   24e09:	mov    rdx,r9
   24e0c:	mov    ecx,0x1
   24e11:	call   5e661 <rfc_wrap>
   24e16:	mov    rdi,r10
   24e19:	movabs rcx,0x200000000000000
   24e23:	mov    rsi,r8
   24e26:	mov    r9,rax
   24e29:	jmp    216ab <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x176b>
   24e2e:	mov    r9,rdi
   24e31:	mov    rdi,r12
   24e34:	mov    r8,rsi
   24e37:	mov    rsi,r13
   24e3a:	mov    rdx,r14
   24e3d:	mov    ecx,0x1
   24e42:	call   5e661 <rfc_wrap>
   24e47:	mov    rdi,r9
   24e4a:	mov    rsi,r8
   24e4d:	mov    r14,rax
   24e50:	jmp    216bf <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x177f>
   24e55:	mov    rdi,r12
   24e58:	mov    rsi,r13
   24e5b:	mov    edx,0x2
   24e60:	call   5e35b <heap_alloc_miss>
   24e65:	mov    r8,rax
   24e68:	jmp    22786 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2846>
   24e6d:	mov    rdi,r12
   24e70:	mov    rsi,r13
   24e73:	mov    rdx,rbx
   24e76:	mov    ecx,0x1
   24e7b:	call   5e661 <rfc_wrap>
   24e80:	movabs rdx,0x2002d0000000000
   24e8a:	mov    rcx,QWORD PTR [rsp+0x58]
   24e8f:	jmp    227b6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2876>
   24e94:	mov    rdi,r12
   24e97:	mov    rsi,r13
   24e9a:	mov    rdx,r9
   24e9d:	mov    ecx,0x1
   24ea2:	call   5e661 <rfc_wrap>
   24ea7:	movabs rdx,0x2002d0000000000
   24eb1:	mov    rcx,QWORD PTR [rsp+0x58]
   24eb6:	mov    r9,rax
   24eb9:	mov    QWORD PTR [r12+r8*8+0x8],r9
   24ebe:	and    r15,rcx
   24ec1:	cmp    r15,r10
   24ec4:	jne    227da <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x289a>
   24eca:	mov    rdi,r12
   24ecd:	mov    rsi,r13
   24ed0:	mov    rdx,rcx
   24ed3:	mov    ecx,0x1
   24ed8:	call   5e661 <rfc_wrap>
   24edd:	movabs rdx,0x2002d0000000000
   24ee7:	mov    rcx,rax
   24eea:	jmp    227da <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x289a>
   24eef:	mov    rdi,r12
   24ef2:	mov    r8,rsi
   24ef5:	mov    rsi,r13
   24ef8:	mov    edx,0x1
   24efd:	mov    rcx,r11
   24f00:	call   5e35b <heap_alloc_miss>
   24f05:	mov    rsi,r8
   24f08:	mov    r11,rcx
   24f0b:	mov    r15,rax
   24f0e:	jmp    20cd5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xd95>
   24f13:	mov    rdi,r12
   24f16:	mov    rdx,rsi
   24f19:	mov    rsi,r13
   24f1c:	mov    ecx,0x1
   24f21:	mov    r8,r11
   24f24:	call   5e661 <rfc_wrap>
   24f29:	mov    rdx,QWORD PTR [rsp+0x40]
   24f2e:	mov    r11,r8
   24f31:	mov    rsi,rax
   24f34:	jmp    20cf4 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xdb4>
   24f39:	mov    rdi,r12
   24f3c:	mov    rsi,r13
   24f3f:	mov    ecx,0x1
   24f44:	mov    r8,r11
   24f47:	call   5e661 <rfc_wrap>
   24f4c:	mov    r11,r8
   24f4f:	mov    rdx,rax
   24f52:	jmp    20d11 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xdd1>
   24f57:	mov    rdi,r12
   24f5a:	mov    rsi,r13
   24f5d:	mov    edx,0x2
   24f62:	mov    rcx,r11
   24f65:	call   5e35b <heap_alloc_miss>
   24f6a:	mov    rsi,QWORD PTR [rsp+0x48]
   24f6f:	mov    r11,rcx
   24f72:	mov    rdx,QWORD PTR [rsp+0x38]
   24f77:	mov    r9,rax
   24f7a:	jmp    21015 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x10d5>
   24f7f:	mov    rdi,r12
   24f82:	mov    rsi,r13
   24f85:	mov    ecx,0x1
   24f8a:	mov    r8,r11
   24f8d:	call   5e661 <rfc_wrap>
   24f92:	mov    rsi,QWORD PTR [rsp+0x48]
   24f97:	mov    r11,r8
   24f9a:	mov    rdx,rax
   24f9d:	jmp    2102f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x10ef>
   24fa2:	mov    rdi,r12
   24fa5:	mov    rdx,rsi
   24fa8:	mov    rsi,r13
   24fab:	mov    ecx,0x1
   24fb0:	mov    r8,r11
   24fb3:	call   5e661 <rfc_wrap>
   24fb8:	movabs rcx,0x200000000000000
   24fc2:	mov    r11,r8
   24fc5:	mov    rsi,rax
   24fc8:	jmp    2104c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x110c>
   24fcd:	mov    rdi,r12
   24fd0:	mov    rsi,r13
   24fd3:	mov    rdx,rbx
   24fd6:	mov    ecx,0x1
   24fdb:	mov    r8,r11
   24fde:	call   5e661 <rfc_wrap>
   24fe3:	mov    r11,r8
   24fe6:	mov    rbx,rax
   24fe9:	jmp    21060 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1120>
   24fee:	mov    rdi,r12
   24ff1:	mov    rcx,rsi
   24ff4:	mov    rsi,r13
   24ff7:	mov    edx,0x1
   24ffc:	call   5e35b <heap_alloc_miss>
   25001:	mov    rsi,rcx
   25004:	mov    r8,rax
   25007:	jmp    212eb <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x13ab>
   2500c:	mov    rdi,r12
   2500f:	mov    rdx,rsi
   25012:	mov    rsi,r13
   25015:	mov    ecx,0x1
   2501a:	call   5e661 <rfc_wrap>
   2501f:	mov    rcx,QWORD PTR [rsp+0x48]
   25024:	mov    rsi,rax
   25027:	jmp    2130a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x13ca>
   2502c:	mov    rdi,r12
   2502f:	mov    rsi,r13
   25032:	mov    rdx,rcx
   25035:	mov    ecx,0x1
   2503a:	call   5e661 <rfc_wrap>
   2503f:	mov    rdx,QWORD PTR [rsp+0x28]
   25044:	mov    rcx,rax
   25047:	jmp    2132c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x13ec>
   2504c:	mov    rdi,r12
   2504f:	mov    rsi,r13
   25052:	mov    edx,0x2
   25057:	call   5e35b <heap_alloc_miss>
   2505c:	mov    r8,rax
   2505f:	jmp    228d6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2996>
   25064:	mov    rdi,r12
   25067:	mov    rsi,r13
   2506a:	mov    rdx,rbx
   2506d:	mov    ecx,0x1
   25072:	call   5e661 <rfc_wrap>
   25077:	jmp    228e8 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x29a8>
   2507c:	mov    rdi,r12
   2507f:	mov    rsi,r13
   25082:	mov    rdx,r15
   25085:	mov    ecx,0x1
   2508a:	call   5e661 <rfc_wrap>
   2508f:	mov    r15,rax
   25092:	mov    QWORD PTR [r12+r8*8+0x8],r15
   25097:	and    r14,QWORD PTR [rsp+0x40]
   2509c:	cmp    r14,rbp
   2509f:	jne    2290e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x29ce>
   250a5:	mov    rdi,r12
   250a8:	mov    rsi,r13
   250ab:	mov    rdx,QWORD PTR [rsp+0x40]
   250b0:	mov    ecx,0x1
   250b5:	call   5e661 <rfc_wrap>
   250ba:	mov    QWORD PTR [rsp+0x40],rax
   250bf:	jmp    2290e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x29ce>
   250c4:	mov    r8,rdi
   250c7:	mov    rdi,r12
   250ca:	mov    rcx,rsi
   250cd:	mov    rsi,r13
   250d0:	mov    edx,0x2
   250d5:	call   5e35b <heap_alloc_miss>
   250da:	mov    rdi,r8
   250dd:	mov    rsi,rcx
   250e0:	mov    rbx,rax
   250e3:	jmp    215e4 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x16a4>
   250e8:	mov    rdi,r12
   250eb:	mov    r8,rsi
   250ee:	mov    rsi,r13
   250f1:	mov    rdx,rbp
   250f4:	mov    ecx,0x1
   250f9:	call   5e661 <rfc_wrap>
   250fe:	movabs rcx,0x200000000000000
   25108:	movabs rdi,0x2002d0000000000
   25112:	mov    rsi,r8
   25115:	mov    rbp,rax
   25118:	jmp    215fd <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x16bd>
   2511d:	mov    rbp,rdi
   25120:	mov    rdi,r12
   25123:	mov    r8,rsi
   25126:	mov    rsi,r13
   25129:	mov    rdx,r10
   2512c:	mov    ecx,0x1
   25131:	call   5e661 <rfc_wrap>
   25136:	movabs rcx,0x200000000000000
   25140:	mov    rdi,rbp
   25143:	mov    rsi,r8
   25146:	mov    r10,rax
   25149:	jmp    21610 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x16d0>
   2514e:	mov    r8,rdi
   25151:	mov    rdi,r12
   25154:	mov    rdx,rsi
   25157:	mov    rsi,r13
   2515a:	mov    ecx,0x1
   2515f:	call   5e661 <rfc_wrap>
   25164:	mov    rdi,r8
   25167:	mov    rsi,rax
   2516a:	jmp    21624 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x16e4>
   2516f:	mov    rdi,r12
   25172:	mov    rsi,r13
   25175:	mov    edx,0x2
   2517a:	call   5e35b <heap_alloc_miss>
   2517f:	mov    r8,rax
   25182:	jmp    22b93 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2c53>
   25187:	mov    rdi,r12
   2518a:	mov    rsi,r13
   2518d:	mov    rdx,rbx
   25190:	mov    ecx,0x1
   25195:	call   5e661 <rfc_wrap>
   2519a:	movabs rcx,0x200000000000000
   251a4:	movabs rdx,0x2002d0000000000
   251ae:	jmp    22bbc <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2c7c>
   251b3:	mov    rdi,r12
   251b6:	mov    rsi,r13
   251b9:	mov    rdx,rbp
   251bc:	mov    ecx,0x1
   251c1:	call   5e661 <rfc_wrap>
   251c6:	movabs rcx,0x200000000000000
   251d0:	movabs rdx,0x2002d0000000000
   251da:	mov    rbp,rax
   251dd:	mov    QWORD PTR [r12+r8*8+0x8],rbp
   251e2:	and    r15,r14
   251e5:	cmp    r15,rcx
   251e8:	jne    22be0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2ca0>
   251ee:	mov    rdi,r12
   251f1:	mov    rsi,r13
   251f4:	mov    rdx,r14
   251f7:	mov    ecx,0x1
   251fc:	call   5e661 <rfc_wrap>
   25201:	movabs rdx,0x2002d0000000000
   2520b:	jmp    22be3 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2ca3>
   25210:	mov    rdi,r12
   25213:	mov    rsi,r13
   25216:	mov    edx,0x1
   2521b:	call   5e35b <heap_alloc_miss>
   25220:	mov    r8,rax
   25223:	jmp    21bad <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1c6d>
   25228:	mov    rdi,r12
   2522b:	mov    rsi,QWORD PTR [rsp+0x8]
   25230:	mov    rdx,rbx
   25233:	mov    ecx,0x1
   25238:	call   5e661 <rfc_wrap>
   2523d:	mov    rbx,rax
   25240:	jmp    21bc7 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1c87>
   25245:	mov    rdi,r12
   25248:	mov    rsi,QWORD PTR [rsp+0x8]
   2524d:	mov    rdx,r15
   25250:	mov    ecx,0x1
   25255:	call   5e661 <rfc_wrap>
   2525a:	mov    r15,rax
   2525d:	jmp    21be4 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1ca4>
   25262:	mov    rdi,r12
   25265:	mov    edx,0x2
   2526a:	call   5e35b <heap_alloc_miss>
   2526f:	mov    r9,rax
   25272:	jmp    21c15 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1cd5>
   25277:	mov    rdi,r12
   2527a:	mov    rsi,QWORD PTR [rsp+0x8]
   2527f:	mov    rdx,QWORD PTR [rsp+0x30]
   25284:	mov    ecx,0x1
   25289:	call   5e661 <rfc_wrap>
   2528e:	mov    QWORD PTR [rsp+0x30],rax
   25293:	jmp    21c29 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1ce9>
   25298:	mov    rdi,r12
   2529b:	mov    rsi,QWORD PTR [rsp+0x8]
   252a0:	mov    rdx,r8
   252a3:	mov    ecx,0x1
   252a8:	call   5e661 <rfc_wrap>
   252ad:	mov    r8,rax
   252b0:	jmp    21c51 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1d11>
   252b5:	mov    rdi,r12
   252b8:	mov    edx,0x1
   252bd:	call   5e35b <heap_alloc_miss>
   252c2:	mov    r8,rax
   252c5:	cmp    rcx,r15
   252c8:	jae    21c98 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1d58>
   252ce:	mov    rdi,r12
   252d1:	mov    rsi,QWORD PTR [rsp+0x8]
   252d6:	mov    rdx,rcx
   252d9:	mov    ecx,0x1
   252de:	call   5e661 <rfc_wrap>
   252e3:	mov    rcx,rax
   252e6:	jmp    21c98 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1d58>
   252eb:	mov    rdi,r12
   252ee:	mov    r13,QWORD PTR [rsp+0x8]
   252f3:	jmp    2542d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x54ed>
   252f8:	mov    rdi,r12
   252fb:	mov    rcx,rsi
   252fe:	mov    rsi,r13
   25301:	mov    edx,0x2
   25306:	mov    r8,r11
   25309:	call   5e35b <heap_alloc_miss>
   2530e:	mov    r11,r8
   25311:	mov    rsi,rcx
   25314:	mov    r8,rax
   25317:	jmp    22188 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2248>
   2531c:	mov    r14,QWORD PTR [rsp+0x30]
   25321:	mov    rdi,r12
   25324:	mov    rdx,rsi
   25327:	mov    rsi,r13
   2532a:	mov    ecx,0x1
   2532f:	mov    r9,r11
   25332:	call   5e661 <rfc_wrap>
   25337:	mov    r11,r9
   2533a:	mov    rdx,QWORD PTR [rsp+0x28]
   2533f:	mov    rsi,rax
   25342:	jmp    221ac <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x226c>
   25347:	mov    rdi,r12
   2534a:	mov    rsi,r13
   2534d:	mov    rdx,r15
   25350:	mov    ecx,0x1
   25355:	mov    r9,r11
   25358:	call   5e661 <rfc_wrap>
   2535d:	mov    r11,r9
   25360:	mov    rdx,QWORD PTR [rsp+0x28]
   25365:	mov    r15,rax
   25368:	jmp    221c9 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2289>
   2536d:	mov    rdi,r12
   25370:	mov    rsi,r13
   25373:	mov    ecx,0x1
   25378:	mov    r9,r11
   2537b:	call   5e661 <rfc_wrap>
   25380:	mov    r11,r9
   25383:	mov    rdx,rax
   25386:	jmp    221dd <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x229d>
   2538b:	mov    rdi,r12
   2538e:	mov    edx,0x2
   25393:	mov    rcx,r11
   25396:	call   5e35b <heap_alloc_miss>
   2539b:	mov    r11,rcx
   2539e:	mov    r10,rax
   253a1:	jmp    2220c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x22cc>
   253a6:	mov    rdi,r12
   253a9:	mov    rsi,QWORD PTR [rsp+0x8]
   253ae:	mov    rdx,r14
   253b1:	mov    ecx,0x1
   253b6:	mov    r14,r11
   253b9:	call   5e661 <rfc_wrap>
   253be:	mov    r11,r14
   253c1:	mov    r14,rax
   253c4:	jmp    2221e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x22de>
   253c9:	mov    rdi,r12
   253cc:	mov    rsi,QWORD PTR [rsp+0x8]
   253d1:	mov    rdx,r8
   253d4:	mov    ecx,0x1
   253d9:	call   5e661 <rfc_wrap>
   253de:	mov    r8,rax
   253e1:	jmp    22237 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x22f7>
   253e6:	mov    rdi,r12
   253e9:	mov    rsi,r13
   253ec:	mov    edx,0x1
   253f1:	call   5e35b <heap_alloc_miss>
   253f6:	mov    r8,rax
   253f9:	cmp    r9,rcx
   253fc:	jae    2227e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x233e>
   25402:	mov    rdi,r12
   25405:	mov    rsi,r13
   25408:	mov    rdx,r9
   2540b:	mov    ecx,0x1
   25410:	call   5e661 <rfc_wrap>
   25415:	mov    r9,rax
   25418:	mov    QWORD PTR [r12+r8*8],r9
   2541c:	and    rbx,QWORD PTR [rsp+0x18]
   25421:	cmp    rbx,rbp
   25424:	jne    22290 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2350>
   2542a:	mov    rdi,r12
   2542d:	mov    rsi,r13
   25430:	mov    rdx,QWORD PTR [rsp+0x18]
   25435:	mov    ecx,0x1
   2543a:	call   5e661 <rfc_wrap>
   2543f:	jmp    22295 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2355>
   25444:	mov    rdi,r12
   25447:	mov    rsi,r13
   2544a:	mov    edx,0x2
   2544f:	call   5e35b <heap_alloc_miss>
   25454:	mov    rsi,QWORD PTR [rsp+0x20]
   25459:	mov    r8,rax
   2545c:	jmp    22a76 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2b36>
   25461:	mov    rdi,r12
   25464:	mov    rsi,r13
   25467:	mov    rdx,QWORD PTR [rsp+0x20]
   2546c:	mov    ecx,0x1
   25471:	call   5e661 <rfc_wrap>
   25476:	mov    rsi,rax
   25479:	jmp    22a90 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2b50>
   2547e:	mov    rdi,r12
   25481:	mov    rsi,QWORD PTR [rsp+0x8]
   25486:	mov    rdx,r15
   25489:	mov    ecx,0x1
   2548e:	call   5e661 <rfc_wrap>
   25493:	mov    r15,rax
   25496:	jmp    22aad <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2b6d>
   2549b:	mov    rdi,r12
   2549e:	mov    r13,QWORD PTR [rsp+0x8]
   254a3:	mov    rsi,r13
   254a6:	mov    rdx,rax
   254a9:	mov    ecx,0x1
   254ae:	call   5e661 <rfc_wrap>
   254b3:	jmp    22ac8 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2b88>
   254b8:	mov    rdi,r12
   254bb:	mov    rsi,r13
   254be:	mov    rdx,rbx
   254c1:	mov    ecx,0x1
   254c6:	call   5e661 <rfc_wrap>
   254cb:	jmp    22d7c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2e3c>
   254d0:	mov    rdi,r12
   254d3:	mov    rsi,QWORD PTR [rsp+0x8]
   254d8:	mov    rdx,r15
   254db:	mov    ecx,0x1
   254e0:	call   5e661 <rfc_wrap>
   254e5:	mov    r15,rax
   254e8:	mov    QWORD PTR [r12+r8*8+0x8],r15
   254ed:	and    r9,QWORD PTR [rsp+0x40]
   254f2:	cmp    r9,r10
   254f5:	jne    22dac <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2e6c>
   254fb:	mov    rdi,r12
   254fe:	mov    r13,QWORD PTR [rsp+0x8]
   25503:	mov    rsi,r13
   25506:	mov    rdx,QWORD PTR [rsp+0x40]
   2550b:	mov    ecx,0x1
   25510:	call   5e661 <rfc_wrap>
   25515:	mov    rdx,rbx
   25518:	mov    QWORD PTR [rsp+0x40],rax
   2551d:	jmp    22db4 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2e74>
   25522:	mov    rdi,r12
   25525:	mov    rsi,r13
   25528:	mov    edx,0x1
   2552d:	call   5e35b <heap_alloc_miss>
   25532:	mov    r8,rax
   25535:	jmp    21933 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x19f3>
   2553a:	mov    rdi,r12
   2553d:	mov    rsi,QWORD PTR [rsp+0x8]
   25542:	mov    rdx,r14
   25545:	mov    ecx,0x1
   2554a:	call   5e661 <rfc_wrap>
   2554f:	mov    rdx,QWORD PTR [rsp+0x28]
   25554:	mov    r14,rax
   25557:	jmp    21952 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1a12>
   2555c:	mov    rdi,r12
   2555f:	mov    rsi,QWORD PTR [rsp+0x8]
   25564:	mov    ecx,0x1
   25569:	call   5e661 <rfc_wrap>
   2556e:	mov    rdx,rax
   25571:	jmp    2196f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1a2f>
   25576:	mov    rdi,r12
   25579:	mov    edx,0x2
   2557e:	call   5e35b <heap_alloc_miss>
   25583:	mov    r9,rax
   25586:	jmp    219a0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1a60>
   2558b:	mov    rdi,r12
   2558e:	mov    rsi,QWORD PTR [rsp+0x8]
   25593:	mov    rdx,r15
   25596:	mov    ecx,0x1
   2559b:	call   5e661 <rfc_wrap>
   255a0:	mov    r15,rax
   255a3:	jmp    219b2 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1a72>
   255a8:	mov    rdi,r12
   255ab:	mov    rsi,QWORD PTR [rsp+0x8]
   255b0:	mov    rdx,r8
   255b3:	mov    ecx,0x1
   255b8:	call   5e661 <rfc_wrap>
   255bd:	mov    r8,rax
   255c0:	jmp    219c6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1a86>
   255c5:	mov    rdi,r12
   255c8:	mov    edx,0x1
   255cd:	call   5e35b <heap_alloc_miss>
   255d2:	mov    r8,rax
   255d5:	cmp    rcx,r15
   255d8:	jae    21a1c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1adc>
   255de:	mov    rdi,r12
   255e1:	mov    rsi,QWORD PTR [rsp+0x8]
   255e6:	mov    rdx,rcx
   255e9:	mov    ecx,0x1
   255ee:	call   5e661 <rfc_wrap>
   255f3:	mov    rcx,rax
   255f6:	jmp    21a1c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1adc>
   255fb:	mov    rdi,r12
   255fe:	mov    r13,QWORD PTR [rsp+0x8]
   25603:	mov    rsi,r13
   25606:	mov    rdx,QWORD PTR [rsp+0x18]
   2560b:	mov    ecx,0x1
   25610:	call   5e661 <rfc_wrap>
   25615:	jmp    21a3d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1afd>
   2561a:	mov    rdi,r12
   2561d:	mov    rsi,r13
   25620:	mov    edx,0x2
   25625:	call   5e35b <heap_alloc_miss>
   2562a:	mov    r8,rax
   2562d:	jmp    21f2c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1fec>
   25632:	mov    rdi,r12
   25635:	mov    rsi,r13
   25638:	mov    rdx,rcx
   2563b:	mov    ecx,0x1
   25640:	call   5e661 <rfc_wrap>
   25645:	mov    rcx,rax
   25648:	jmp    21f4b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x200b>
   2564d:	mov    rdi,r12
   25650:	mov    rsi,r13
   25653:	mov    rdx,r9
   25656:	mov    ecx,0x1
   2565b:	call   5e661 <rfc_wrap>
   25660:	mov    r9,rax
   25663:	jmp    21f68 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2028>
   25668:	mov    rdi,r12
   2566b:	mov    rsi,r13
   2566e:	mov    rdx,rbp
   25671:	mov    ecx,0x1
   25676:	call   5e661 <rfc_wrap>
   2567b:	mov    rbp,rax
   2567e:	jmp    21f7c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x203c>
   25683:	mov    rdi,r12
   25686:	mov    edx,0x2
   2568b:	call   5e35b <heap_alloc_miss>
   25690:	mov    r10,rax
   25693:	jmp    21fab <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x206b>
   25698:	mov    rdi,r12
   2569b:	mov    rsi,QWORD PTR [rsp+0x8]
   256a0:	mov    ecx,0x1
   256a5:	call   5e661 <rfc_wrap>
   256aa:	mov    rdx,rax
   256ad:	jmp    21fc2 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2082>
   256b2:	mov    rdi,r12
   256b5:	mov    rsi,QWORD PTR [rsp+0x8]
   256ba:	mov    rdx,r8
   256bd:	mov    ecx,0x1
   256c2:	call   5e661 <rfc_wrap>
   256c7:	mov    r8,rax
   256ca:	jmp    21fd6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2096>
   256cf:	mov    rdi,r12
   256d2:	mov    rsi,r13
   256d5:	mov    edx,0x1
   256da:	call   5e35b <heap_alloc_miss>
   256df:	mov    r8,rax
   256e2:	cmp    r9,rcx
   256e5:	jae    22022 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x20e2>
   256eb:	mov    rdi,r12
   256ee:	mov    rsi,r13
   256f1:	mov    rdx,r9
   256f4:	mov    ecx,0x1
   256f9:	call   5e661 <rfc_wrap>
   256fe:	mov    r9,rax
   25701:	mov    QWORD PTR [r12+r8*8],r9
   25705:	and    rbx,QWORD PTR [rsp+0x18]
   2570a:	cmp    rbx,r15
   2570d:	jne    22034 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x20f4>
   25713:	mov    rdi,r12
   25716:	mov    rsi,r13
   25719:	mov    rdx,QWORD PTR [rsp+0x18]
   2571e:	mov    ecx,0x1
   25723:	call   5e661 <rfc_wrap>
   25728:	mov    r15d,DWORD PTR [rsp+0x14]
   2572d:	jmp    22295 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2355>
   25732:	mov    rdi,r12
   25735:	mov    edx,0x1
   2573a:	mov    rcx,r11
   2573d:	call   5e35b <heap_alloc_miss>
   25742:	mov    r11,rcx
   25745:	mov    r8,rax
   25748:	jmp    236c7 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3787>
   2574d:	mov    rdi,r12
   25750:	mov    rsi,QWORD PTR [rsp+0x8]
   25755:	mov    rdx,r9
   25758:	mov    ecx,0x1
   2575d:	mov    r9,r11
   25760:	call   5e661 <rfc_wrap>
   25765:	movabs rdx,0x200000000000000
   2576f:	mov    rcx,r14
   25772:	mov    r11,r9
   25775:	mov    r9,rax
   25778:	jmp    236e3 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x37a3>
   2577d:	mov    rdi,r12
   25780:	mov    rsi,QWORD PTR [rsp+0x8]
   25785:	mov    rdx,rcx
   25788:	mov    ecx,0x1
   2578d:	mov    r9,r11
   25790:	call   5e661 <rfc_wrap>
   25795:	mov    r11,r9
   25798:	mov    rcx,rax
   2579b:	jmp    236f6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x37b6>
   257a0:	mov    rdi,r12
   257a3:	mov    edx,0x1
   257a8:	mov    rcx,r11
   257ab:	call   5e35b <heap_alloc_miss>
   257b0:	mov    r11,rcx
   257b3:	mov    rbx,rax
   257b6:	mov    rax,r8
   257b9:	shr    rax,0x38
   257bd:	cmp    eax,0x2
   257c0:	ja     2373a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x37fa>
   257c6:	mov    rdi,r12
   257c9:	mov    rsi,QWORD PTR [rsp+0x8]
   257ce:	mov    rdx,r8
   257d1:	mov    ecx,0x1
   257d6:	mov    r8,r11
   257d9:	call   5e661 <rfc_wrap>
   257de:	mov    r11,r8
   257e1:	mov    r8,rax
   257e4:	jmp    2373a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x37fa>
   257e9:	mov    rdi,r12
   257ec:	mov    rsi,r13
   257ef:	mov    edx,0x1
   257f4:	mov    rcx,r11
   257f7:	call   5e35b <heap_alloc_miss>
   257fc:	mov    rdx,r14
   257ff:	mov    r11,rcx
   25802:	mov    r8,rax
   25805:	jmp    23aab <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3b6b>
   2580a:	mov    rdi,r12
   2580d:	mov    rsi,r13
   25810:	mov    rdx,QWORD PTR [rsp+0x38]
   25815:	mov    ecx,0x1
   2581a:	mov    r10,r11
   2581d:	call   5e661 <rfc_wrap>
   25822:	mov    rdx,r14
   25825:	mov    r11,r10
   25828:	mov    QWORD PTR [rsp+0x38],rax
   2582d:	jmp    23ac6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3b86>
   25832:	mov    rdi,r12
   25835:	mov    rsi,r13
   25838:	mov    ecx,0x1
   2583d:	mov    r10,r11
   25840:	call   5e661 <rfc_wrap>
   25845:	mov    r11,r10
   25848:	mov    rdx,rax
   2584b:	jmp    23ae8 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3ba8>
   25850:	mov    rdi,r12
   25853:	mov    rsi,r13
   25856:	mov    edx,0x1
   2585b:	mov    rcx,r11
   2585e:	call   5e35b <heap_alloc_miss>
   25863:	mov    r11,rcx
   25866:	mov    rbx,rax
   25869:	mov    rax,r8
   2586c:	shr    rax,0x38
   25870:	cmp    eax,0x2
   25873:	ja     23b27 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3be7>
   25879:	mov    rdi,r12
   2587c:	mov    rsi,r13
   2587f:	mov    rdx,r8
   25882:	mov    ecx,0x1
   25887:	mov    r8,r11
   2588a:	call   5e661 <rfc_wrap>
   2588f:	mov    r11,r8
   25892:	mov    r8,rax
   25895:	jmp    23b27 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3be7>
   2589a:	mov    rdi,r12
   2589d:	mov    edx,0x1
   258a2:	mov    rcx,r11
   258a5:	call   5e35b <heap_alloc_miss>
   258aa:	mov    r11,rcx
   258ad:	mov    r8,rax
   258b0:	jmp    23ecc <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3f8c>
   258b5:	mov    rdi,r12
   258b8:	mov    rsi,QWORD PTR [rsp+0x8]
   258bd:	mov    rdx,r9
   258c0:	mov    ecx,0x1
   258c5:	mov    r9,r11
   258c8:	call   5e661 <rfc_wrap>
   258cd:	movabs rcx,0x200000000000000
   258d7:	mov    r11,r9
   258da:	mov    r9,rax
   258dd:	jmp    23ee5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3fa5>
   258e2:	mov    rdi,r12
   258e5:	mov    rsi,QWORD PTR [rsp+0x8]
   258ea:	mov    rdx,r14
   258ed:	mov    ecx,0x1
   258f2:	mov    r9,r11
   258f5:	call   5e661 <rfc_wrap>
   258fa:	mov    r11,r9
   258fd:	mov    r14,rax
   25900:	jmp    23ef8 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3fb8>
   25905:	mov    rdi,r12
   25908:	mov    edx,0x1
   2590d:	mov    rcx,r11
   25910:	call   5e35b <heap_alloc_miss>
   25915:	mov    r11,rcx
   25918:	mov    rbx,rax
   2591b:	mov    rax,r8
   2591e:	shr    rax,0x38
   25922:	cmp    eax,0x2
   25925:	ja     23f3c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3ffc>
   2592b:	mov    rdi,r12
   2592e:	mov    rsi,QWORD PTR [rsp+0x8]
   25933:	mov    rdx,r8
   25936:	mov    ecx,0x1
   2593b:	mov    r8,r11
   2593e:	call   5e661 <rfc_wrap>
   25943:	mov    r11,r8
   25946:	mov    r8,rax
   25949:	jmp    23f3c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3ffc>
   2594e:	mov    rdi,r12
   25951:	mov    rsi,r13
   25954:	mov    rcx,rdx
   25957:	mov    edx,0x1
   2595c:	mov    r8,r11
   2595f:	call   5e35b <heap_alloc_miss>
   25964:	mov    r11,r8
   25967:	mov    rdx,rcx
   2596a:	mov    r8,rax
   2596d:	jmp    242aa <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x436a>
   25972:	mov    rdi,r12
   25975:	mov    rsi,r13
   25978:	mov    ecx,0x1
   2597d:	mov    r10,r11
   25980:	call   5e661 <rfc_wrap>
   25985:	movabs rcx,0xff00000000000000
   2598f:	mov    r11,r10
   25992:	mov    rdx,rax
   25995:	jmp    242c4 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4384>
   2599a:	mov    rdi,r12
   2599d:	mov    rsi,r13
   259a0:	mov    rdx,rbx
   259a3:	mov    ecx,0x1
   259a8:	mov    r10,r11
   259ab:	call   5e661 <rfc_wrap>
   259b0:	mov    r11,r10
   259b3:	mov    rbx,rax
   259b6:	jmp    242e1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x43a1>
   259bb:	mov    rdi,r12
   259be:	mov    rsi,r13
   259c1:	mov    edx,0x1
   259c6:	mov    rcx,r11
   259c9:	call   5e35b <heap_alloc_miss>
   259ce:	mov    r11,rcx
   259d1:	mov    rbx,rax
   259d4:	mov    rax,r8
   259d7:	shr    rax,0x38
   259db:	cmp    eax,0x2
   259de:	ja     24320 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x43e0>
   259e4:	mov    rdi,r12
   259e7:	mov    rsi,r13
   259ea:	mov    rdx,r8
   259ed:	mov    ecx,0x1
   259f2:	mov    r8,r11
   259f5:	call   5e661 <rfc_wrap>
   259fa:	mov    r11,r8
   259fd:	mov    r8,rax
   25a00:	jmp    24320 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x43e0>
   25a05:	mov    rdi,r12
   25a08:	mov    rsi,r13
   25a0b:	mov    rdx,r14
   25a0e:	mov    ecx,0x1
   25a13:	mov    r10,r11
   25a16:	call   5e661 <rfc_wrap>
   25a1b:	mov    r11,r10
   25a1e:	mov    r14,rax
   25a21:	jmp    23221 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x32e1>
   25a26:	mov    rdi,r12
   25a29:	mov    rsi,r13
   25a2c:	mov    edx,0x1
   25a31:	mov    rcx,r11
   25a34:	call   5e35b <heap_alloc_miss>
   25a39:	mov    r11,rcx
   25a3c:	mov    rbx,rax
   25a3f:	mov    rax,r8
   25a42:	shr    rax,0x38
   25a46:	cmp    eax,0x2
   25a49:	ja     23260 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3320>
   25a4f:	mov    rdi,r12
   25a52:	mov    rsi,r13
   25a55:	mov    rdx,r8
   25a58:	mov    ecx,0x1
   25a5d:	mov    r8,r11
   25a60:	call   5e661 <rfc_wrap>
   25a65:	mov    r11,r8
   25a68:	mov    r8,rax
   25a6b:	jmp    23260 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3320>
   25a70:	mov    rdi,r12
   25a73:	mov    rsi,r13
   25a76:	mov    rcx,rdx
   25a79:	mov    edx,0x1
   25a7e:	mov    r8,r11
   25a81:	call   5e35b <heap_alloc_miss>
   25a86:	mov    r11,r8
   25a89:	mov    rdx,rcx
   25a8c:	mov    r8,rax
   25a8f:	jmp    246f0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x47b0>
   25a94:	mov    rdi,r12
   25a97:	mov    rsi,r13
   25a9a:	mov    ecx,0x1
   25a9f:	mov    r10,r11
   25aa2:	call   5e661 <rfc_wrap>
   25aa7:	movabs rcx,0xff00000000000000
   25ab1:	mov    r11,r10
   25ab4:	mov    rdx,rax
   25ab7:	jmp    2470a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x47ca>
   25abc:	mov    rdi,r12
   25abf:	mov    rsi,r13
   25ac2:	mov    rdx,r14
   25ac5:	mov    ecx,0x1
   25aca:	mov    r10,r11
   25acd:	call   5e661 <rfc_wrap>
   25ad2:	mov    r11,r10
   25ad5:	mov    r14,rax
   25ad8:	jmp    24727 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x47e7>
   25add:	mov    rdi,r12
   25ae0:	mov    rsi,r13
   25ae3:	mov    edx,0x1
   25ae8:	mov    rcx,r11
   25aeb:	call   5e35b <heap_alloc_miss>
   25af0:	mov    r11,rcx
   25af3:	mov    rbx,rax
   25af6:	mov    rax,r8
   25af9:	shr    rax,0x38
   25afd:	cmp    eax,0x2
   25b00:	ja     24766 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4826>
   25b06:	mov    rdi,r12
   25b09:	mov    rsi,r13
   25b0c:	mov    rdx,r8
   25b0f:	mov    ecx,0x1
   25b14:	mov    r8,r11
   25b17:	call   5e661 <rfc_wrap>
   25b1c:	mov    r11,r8
   25b1f:	mov    r8,rax
   25b22:	jmp    24766 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4826>
   25b27:	mov    rdi,r12
   25b2a:	mov    r14,rsi
   25b2d:	mov    rsi,r13
   25b30:	mov    rdx,rbx
   25b33:	mov    r9,rcx
   25b36:	mov    ecx,0x1
   25b3b:	call   5e661 <rfc_wrap>
   25b40:	mov    rsi,r14
   25b43:	mov    rcx,r9
   25b46:	mov    rbx,rax
   25b49:	jmp    24624 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x46e4>
   25b4e:	mov    rdi,r12
   25b51:	mov    rcx,rsi
   25b54:	mov    rsi,r13
   25b57:	mov    edx,0x1
   25b5c:	mov    rax,r11
   25b5f:	call   5e231 <heap_hand>
   25b64:	mov    rsi,rcx
   25b67:	jmp    25d8e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5e4e>
   25b6c:	mov    rdi,r12
   25b6f:	mov    rcx,rsi
   25b72:	mov    rsi,r13
   25b75:	mov    edx,0x2
   25b7a:	mov    rax,r11
   25b7d:	call   5e231 <heap_hand>
   25b82:	mov    rsi,rcx
   25b85:	mov    r11,rax
   25b88:	movabs rdi,0xfffffffe00
   25b92:	jmp    207a5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x865>
   25b97:	mov    rdi,r12
   25b9a:	mov    rcx,rsi
   25b9d:	mov    rsi,r13
   25ba0:	mov    edx,0x1
   25ba5:	mov    rax,r11
   25ba8:	call   5e231 <heap_hand>
   25bad:	mov    rsi,rcx
   25bb0:	jmp    25e2c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5eec>
   25bb5:	mov    rdi,r12
   25bb8:	mov    rcx,rsi
   25bbb:	mov    rsi,r13
   25bbe:	mov    edx,0x2
   25bc3:	mov    rax,r11
   25bc6:	call   5e231 <heap_hand>
   25bcb:	mov    rsi,rcx
   25bce:	mov    r11,rax
   25bd1:	movabs rdi,0xfffffffe00
   25bdb:	jmp    209ab <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xa6b>
   25be0:	mov    rdi,r12
   25be3:	mov    rsi,r13
   25be6:	mov    edx,0x1
   25beb:	mov    rax,r11
   25bee:	call   5e231 <heap_hand>
   25bf3:	jmp    25ec9 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x5f89>
   25bf8:	mov    rdi,r12
   25bfb:	mov    rcx,rsi
   25bfe:	mov    rsi,r13
   25c01:	mov    edx,0x2
   25c06:	mov    rax,r11
   25c09:	call   5e231 <heap_hand>
   25c0e:	mov    rsi,rcx
   25c11:	mov    r11,rax
   25c14:	movabs rdi,0xfffffffe00
   25c1e:	jmp    20b9b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xc5b>
   25c23:	mov    rdi,r12
   25c26:	mov    r8,rsi
   25c29:	mov    rsi,r13
   25c2c:	mov    edx,0x1
   25c31:	mov    rcx,r11
   25c34:	call   5e231 <heap_hand>
   25c39:	mov    rsi,r8
   25c3c:	mov    r11,rcx
   25c3f:	jmp    20c8e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xd4e>
   25c44:	mov    rdi,r12
   25c47:	mov    rsi,r13
   25c4a:	mov    edx,0x1
   25c4f:	mov    rcx,r11
   25c52:	call   5e231 <heap_hand>
   25c57:	mov    rsi,QWORD PTR [rsp+0x48]
   25c5c:	mov    r11,rcx
   25c5f:	jmp    20fc9 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1089>
   25c64:	mov    rdi,r12
   25c67:	mov    r8,rsi
   25c6a:	mov    rsi,r13
   25c6d:	mov    edx,0x1
   25c72:	mov    rcx,r11
   25c75:	call   5e231 <heap_hand>
   25c7a:	mov    rsi,r8
   25c7d:	mov    r11,rcx
   25c80:	jmp    2129f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x135f>
   25c85:	mov    rdi,r12
   25c88:	mov    rcx,rsi
   25c8b:	mov    rsi,r13
   25c8e:	mov    edx,0x1
   25c93:	call   5e231 <heap_hand>
   25c98:	mov    rsi,rcx
   25c9b:	jmp    21589 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1649>
   25ca0:	mov    rdi,r12
   25ca3:	mov    rsi,r13
   25ca6:	mov    rax,rdx
   25ca9:	mov    edx,0x1
   25cae:	mov    rcx,r11
   25cb1:	call   5e231 <heap_hand>
   25cb6:	mov    r11,rcx
   25cb9:	movabs rdi,0xfffffffe00
   25cc3:	mov    rdx,rax
   25cc6:	jmp    217a6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1866>
   25ccb:	mov    rdi,r12
   25cce:	mov    rsi,r13
   25cd1:	mov    rax,rdx
   25cd4:	mov    edx,0x1
   25cd9:	mov    rcx,r11
   25cdc:	call   5e231 <heap_hand>
   25ce1:	mov    r11,rcx
   25ce4:	movabs rdi,0xfffffffe00
   25cee:	mov    rdx,rax
   25cf1:	jmp    21b1b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1bdb>
   25cf6:	mov    rdi,r12
   25cf9:	mov    rsi,r13
   25cfc:	mov    edx,0x1
   25d01:	call   5e231 <heap_hand>
   25d06:	jmp    260d7 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6197>
   25d0b:	mov    rdi,r12
   25d0e:	mov    rcx,rsi
   25d11:	mov    rsi,r13
   25d14:	mov    edx,0x1
   25d19:	call   5e231 <heap_hand>
   25d1e:	mov    rsi,rcx
   25d21:	movabs rdi,0xfffffffe00
   25d2b:	jmp    220ee <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x21ae>
   25d30:	mov    rdi,r12
   25d33:	mov    rsi,r13
   25d36:	mov    rax,rdx
   25d39:	mov    edx,0x1
   25d3e:	call   5e231 <heap_hand>
   25d43:	movabs rdi,0xfffffffe00
   25d4d:	mov    rdx,rax
   25d50:	jmp    22374 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2434>
   25d55:	shl    rcx,0x20
   25d59:	or     rcx,rdx
   25d5c:	shr    rcx,0x18
   25d60:	mov    rbx,QWORD PTR [r12+rcx*8]
   25d64:	mov    rax,QWORD PTR [r12+rcx*8+0x8]
   25d69:	mov    QWORD PTR [rsp+0x40],rax
   25d6e:	mov    rdi,r12
   25d71:	mov    rsi,r13
   25d74:	mov    rdx,r15
   25d77:	mov    r9,r8
   25d7a:	mov    r8d,0x2
   25d80:	mov    rax,r11
   25d83:	call   5e2c2 <span_fade>
   25d88:	mov    rsi,rbx
   25d8b:	mov    r8,r9
   25d8e:	mov    r11,rax
   25d91:	movabs rdi,0xfffffffe00
   25d9b:	jmp    206a7 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x767>
   25da0:	shl    rcx,0x20
   25da4:	or     rcx,rdx
   25da7:	shr    rcx,0x18
   25dab:	mov    rax,QWORD PTR [r12+rcx*8]
   25daf:	mov    QWORD PTR [rsp+0x38],rax
   25db4:	mov    rbp,QWORD PTR [r12+rcx*8+0x8]
   25db9:	mov    rbx,QWORD PTR [r12+rcx*8+0x10]
   25dbe:	mov    rdi,r12
   25dc1:	mov    rsi,r13
   25dc4:	mov    rdx,r15
   25dc7:	mov    rax,r8
   25dca:	mov    r8d,0x3
   25dd0:	call   5e2c2 <span_fade>
   25dd5:	mov    rsi,rbp
   25dd8:	mov    r8,rax
   25ddb:	movabs rdi,0xfffffffe00
   25de5:	mov    r11,r9
   25de8:	jmp    207a5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x865>
   25ded:	shl    rcx,0x20
   25df1:	or     rcx,rdx
   25df4:	shr    rcx,0x18
   25df8:	mov    rbp,QWORD PTR [r12+rcx*8]
   25dfc:	mov    rax,QWORD PTR [r12+rcx*8+0x8]
   25e01:	mov    QWORD PTR [rsp+0x48],rax
   25e06:	mov    rdi,r12
   25e09:	mov    rsi,r13
   25e0c:	mov    rdx,r15
   25e0f:	mov    rbx,r9
   25e12:	mov    r9,r8
   25e15:	mov    r8d,0x2
   25e1b:	mov    rax,r11
   25e1e:	call   5e2c2 <span_fade>
   25e23:	mov    rsi,rbp
   25e26:	mov    r8,r9
   25e29:	mov    r9,rbx
   25e2c:	mov    r11,rax
   25e2f:	movabs rdi,0xfffffffe00
   25e39:	jmp    208a2 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x962>
   25e3e:	shl    rcx,0x20
   25e42:	or     rcx,rdx
   25e45:	shr    rcx,0x18
   25e49:	mov    rbp,QWORD PTR [r12+rcx*8]
   25e4d:	mov    rax,QWORD PTR [r12+rcx*8+0x8]
   25e52:	mov    QWORD PTR [rsp+0x38],rax
   25e57:	mov    rax,QWORD PTR [r12+rcx*8+0x10]
   25e5c:	mov    QWORD PTR [rsp+0x58],rax
   25e61:	mov    rdi,r12
   25e64:	mov    rsi,r13
   25e67:	mov    rdx,r15
   25e6a:	mov    rax,r8
   25e6d:	mov    r8d,0x3
   25e73:	call   5e2c2 <span_fade>
   25e78:	mov    rsi,QWORD PTR [rsp+0x58]
   25e7d:	mov    r8,rax
   25e80:	movabs rdi,0xfffffffe00
   25e8a:	mov    r11,r9
   25e8d:	mov    r9,rbx
   25e90:	jmp    209ab <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xa6b>
   25e95:	shl    rcx,0x20
   25e99:	or     rcx,rdx
   25e9c:	shr    rcx,0x18
   25ea0:	mov    rbx,QWORD PTR [r12+rcx*8]
   25ea4:	mov    rax,QWORD PTR [r12+rcx*8+0x8]
   25ea9:	mov    rdi,r12
   25eac:	mov    rsi,r13
   25eaf:	mov    rdx,r15
   25eb2:	mov    r15,rax
   25eb5:	mov    r9,r8
   25eb8:	mov    r8d,0x2
   25ebe:	mov    rax,r11
   25ec1:	call   5e2c2 <span_fade>
   25ec6:	mov    r8,r9
   25ec9:	mov    r11,rax
   25ecc:	movabs rdi,0xfffffffe00
   25ed6:	jmp    20a9d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xb5d>
   25edb:	shl    rcx,0x20
   25edf:	or     rcx,rdx
   25ee2:	shr    rcx,0x18
   25ee6:	mov    rbx,QWORD PTR [r12+rcx*8]
   25eea:	mov    r11,QWORD PTR [r12+rcx*8+0x8]
   25eef:	mov    rax,QWORD PTR [r12+rcx*8+0x10]
   25ef4:	mov    QWORD PTR [rsp+0x28],rax
   25ef9:	mov    rdi,r12
   25efc:	mov    rsi,r13
   25eff:	mov    rdx,r15
   25f02:	mov    r15,r11
   25f05:	mov    rax,r8
   25f08:	mov    r8d,0x3
   25f0e:	call   5e2c2 <span_fade>
   25f13:	mov    rsi,rbx
   25f16:	mov    r8,rax
   25f19:	movabs rdi,0xfffffffe00
   25f23:	mov    r11,r9
   25f26:	jmp    20b9b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xc5b>
   25f2b:	shl    rcx,0x20
   25f2f:	or     rcx,rax
   25f32:	shr    rcx,0x18
   25f36:	mov    r9,QWORD PTR [r12+rcx*8]
   25f3a:	mov    rax,QWORD PTR [r12+rcx*8+0x8]
   25f3f:	mov    rdi,r12
   25f42:	mov    rsi,r13
   25f45:	mov    rdx,r8
   25f48:	mov    r8d,0x2
   25f4e:	mov    rbx,r10
   25f51:	mov    r10,r11
   25f54:	call   5e2c2 <span_fade>
   25f59:	mov    r11,r10
   25f5c:	mov    r10,rbx
   25f5f:	mov    rsi,r15
   25f62:	jmp    20c8e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xd4e>
   25f67:	shl    rcx,0x20
   25f6b:	or     rcx,rax
   25f6e:	shr    rcx,0x18
   25f72:	mov    rax,QWORD PTR [r12+rcx*8]
   25f76:	mov    QWORD PTR [rsp+0x40],rax
   25f7b:	mov    rax,QWORD PTR [r12+rcx*8+0x8]
   25f80:	mov    rdi,r12
   25f83:	mov    rsi,r13
   25f86:	mov    rdx,r8
   25f89:	mov    r8d,0x2
   25f8f:	mov    r9,r11
   25f92:	call   5e2c2 <span_fade>
   25f97:	mov    r11,r9
   25f9a:	mov    rsi,QWORD PTR [rsp+0x48]
   25f9f:	jmp    20fc9 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1089>
   25fa4:	shl    rcx,0x20
   25fa8:	or     rcx,rax
   25fab:	shr    rcx,0x18
   25faf:	mov    rax,QWORD PTR [r12+rcx*8]
   25fb3:	mov    QWORD PTR [rsp+0x38],rax
   25fb8:	mov    rax,QWORD PTR [r12+rcx*8+0x8]
   25fbd:	mov    rdi,r12
   25fc0:	mov    rsi,r13
   25fc3:	mov    rdx,r8
   25fc6:	mov    r8d,0x2
   25fcc:	mov    QWORD PTR [rsp+0x58],r9
   25fd1:	mov    r9,r11
   25fd4:	call   5e2c2 <span_fade>
   25fd9:	mov    r11,r9
   25fdc:	mov    r9,QWORD PTR [rsp+0x58]
   25fe1:	mov    rsi,rbx
   25fe4:	jmp    2129f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x135f>
   25fe9:	shl    rcx,0x20
   25fed:	or     rcx,rax
   25ff0:	shr    rcx,0x18
   25ff4:	mov    rax,QWORD PTR [r12+rcx*8]
   25ff8:	mov    QWORD PTR [rsp+0x48],rax
   25ffd:	mov    rax,QWORD PTR [r12+rcx*8+0x8]
   26002:	mov    rdi,r12
   26005:	mov    r10,rsi
   26008:	mov    rsi,r13
   2600b:	mov    rdx,r8
   2600e:	mov    r8d,0x2
   26014:	call   5e2c2 <span_fade>
   26019:	mov    rsi,r10
   2601c:	mov    r10,QWORD PTR [rsp+0x38]
   26021:	jmp    21589 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1649>
   26026:	shl    rcx,0x20
   2602a:	or     rcx,rdx
   2602d:	shr    rcx,0x18
   26031:	mov    rax,QWORD PTR [r12+rcx*8]
   26035:	mov    rbx,QWORD PTR [r12+rcx*8+0x8]
   2603a:	mov    rdi,r12
   2603d:	mov    rsi,r13
   26040:	mov    rdx,r8
   26043:	mov    r8d,0x2
   26049:	mov    r9,r11
   2604c:	call   5e2c2 <span_fade>
   26051:	mov    r11,r9
   26054:	mov    rdx,rax
   26057:	movabs rdi,0xfffffffe00
   26061:	jmp    217a6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1866>
   26066:	shl    rcx,0x20
   2606a:	or     rcx,rdx
   2606d:	shr    rcx,0x18
   26071:	mov    rax,QWORD PTR [r12+rcx*8]
   26075:	mov    r9,QWORD PTR [r12+rcx*8+0x8]
   2607a:	mov    rdi,r12
   2607d:	mov    rsi,r13
   26080:	mov    rdx,r8
   26083:	mov    r8d,0x2
   26089:	mov    r14,r10
   2608c:	mov    r10,r11
   2608f:	call   5e2c2 <span_fade>
   26094:	mov    r11,r10
   26097:	mov    r10,r14
   2609a:	mov    rdx,rax
   2609d:	movabs rdi,0xfffffffe00
   260a7:	jmp    21b1b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1bdb>
   260ac:	shl    rcx,0x20
   260b0:	or     rcx,rdx
   260b3:	shr    rcx,0x18
   260b7:	mov    rax,QWORD PTR [r12+rcx*8]
   260bb:	mov    r15,QWORD PTR [r12+rcx*8+0x8]
   260c0:	mov    rdi,r12
   260c3:	mov    rsi,r13
   260c6:	mov    rdx,r8
   260c9:	mov    r8d,0x2
   260cf:	call   5e2c2 <span_fade>
   260d4:	mov    r8,rax
   260d7:	movabs rdi,0xfffffffe00
   260e1:	jmp    21e36 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1ef6>
   260e6:	shl    rcx,0x20
   260ea:	or     rcx,rax
   260ed:	shr    rcx,0x18
   260f1:	mov    rbx,QWORD PTR [r12+rcx*8]
   260f5:	mov    rax,QWORD PTR [r12+rcx*8+0x8]
   260fa:	mov    rdi,r12
   260fd:	mov    rsi,r13
   26100:	mov    rdx,r8
   26103:	mov    r8d,0x2
   26109:	call   5e2c2 <span_fade>
   2610e:	movabs rdi,0xfffffffe00
   26118:	mov    rsi,r9
   2611b:	jmp    220ee <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x21ae>
   26120:	shl    rcx,0x20
   26124:	or     rcx,rax
   26127:	shr    rcx,0x18
   2612b:	mov    rax,QWORD PTR [r12+rcx*8]
   2612f:	mov    r15,QWORD PTR [r12+rcx*8+0x8]
   26134:	mov    rdi,r12
   26137:	mov    rsi,r13
   2613a:	mov    rdx,r8
   2613d:	mov    r8d,0x2
   26143:	call   5e2c2 <span_fade>
   26148:	mov    rdx,rax
   2614b:	movabs rdi,0xfffffffe00
   26155:	jmp    22374 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2434>
   2615a:	mov    rdi,r12
   2615d:	mov    r9,rsi
   26160:	mov    rsi,r13
   26163:	xor    edx,edx
   26165:	mov    rax,r11
   26168:	call   5e231 <heap_hand>
   2616d:	mov    rsi,r9
   26170:	mov    r11,rax
   26173:	movabs rdi,0xfffffffe00
   2617d:	cmp    rcx,0x3108200
   26184:	jae    20670 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x730>
   2618a:	jmp    206a7 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x767>
   2618f:	mov    rdi,r12
   26192:	mov    rax,rsi
   26195:	mov    rsi,r13
   26198:	xor    edx,edx
   2619a:	call   5e231 <heap_hand>
   2619f:	mov    rsi,rax
   261a2:	movabs rdi,0xfffffffe00
   261ac:	mov    r11,r9
   261af:	cmp    rcx,0x3108200
   261b6:	jae    2076e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x82e>
   261bc:	jmp    207a5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x865>
   261c1:	mov    rdi,r12
   261c4:	mov    rbx,rsi
   261c7:	mov    rsi,r13
   261ca:	xor    edx,edx
   261cc:	mov    rax,r11
   261cf:	call   5e231 <heap_hand>
   261d4:	mov    rsi,rbx
   261d7:	mov    r11,rax
   261da:	movabs rdi,0xfffffffe00
   261e4:	cmp    rcx,0x3108200
   261eb:	jae    2086b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x92b>
   261f1:	jmp    208a2 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x962>
   261f6:	mov    rdi,r12
   261f9:	mov    rax,rsi
   261fc:	mov    rsi,r13
   261ff:	xor    edx,edx
   26201:	call   5e231 <heap_hand>
   26206:	mov    rsi,rax
   26209:	movabs rdi,0xfffffffe00
   26213:	mov    r11,r9
   26216:	mov    r9,rbx
   26219:	cmp    rcx,0x3108200
   26220:	jb     209ab <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xa6b>
   26226:	jmp    20974 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xa34>
   2622b:	mov    rdi,r12
   2622e:	mov    rsi,r13
   26231:	xor    edx,edx
   26233:	mov    rax,r11
   26236:	call   5e231 <heap_hand>
   2623b:	mov    r11,rax
   2623e:	movabs rdi,0xfffffffe00
   26248:	cmp    rcx,0x3108200
   2624f:	jae    20a66 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xb26>
   26255:	jmp    20a9d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xb5d>
   2625a:	mov    rdi,r12
   2625d:	mov    rax,rsi
   26260:	mov    rsi,r13
   26263:	xor    edx,edx
   26265:	call   5e231 <heap_hand>
   2626a:	mov    rsi,rax
   2626d:	movabs rdi,0xfffffffe00
   26277:	mov    r11,r9
   2627a:	cmp    rcx,0x3108200
   26281:	jae    20b64 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xc24>
   26287:	jmp    20b9b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xc5b>
   2628c:	mov    rdi,r12
   2628f:	mov    rsi,r13
   26292:	xor    edx,edx
   26294:	mov    r8,r11
   26297:	call   5e231 <heap_hand>
   2629c:	mov    r11,r8
   2629f:	mov    rsi,r15
   262a2:	cmp    rcx,0x3108200
   262a9:	jae    20c56 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xd16>
   262af:	jmp    20c8e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0xd4e>
   262b4:	mov    rdi,r12
   262b7:	mov    rsi,r13
   262ba:	xor    edx,edx
   262bc:	mov    r8,r11
   262bf:	call   5e231 <heap_hand>
   262c4:	mov    r11,r8
   262c7:	mov    rsi,QWORD PTR [rsp+0x48]
   262cc:	cmp    rcx,0x3108200
   262d3:	jae    20f91 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1051>
   262d9:	jmp    20fc9 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1089>
   262de:	mov    rdi,r12
   262e1:	mov    rsi,r13
   262e4:	xor    edx,edx
   262e6:	mov    r8,r11
   262e9:	call   5e231 <heap_hand>
   262ee:	mov    r11,r8
   262f1:	mov    rsi,rbx
   262f4:	cmp    rcx,0x3108200
   262fb:	jae    21267 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1327>
   26301:	jmp    2129f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x135f>
   26306:	mov    rdi,r12
   26309:	mov    r8,rsi
   2630c:	mov    rsi,r13
   2630f:	xor    edx,edx
   26311:	call   5e231 <heap_hand>
   26316:	mov    rsi,r8
   26319:	mov    r10,QWORD PTR [rsp+0x38]
   2631e:	cmp    rcx,0x3108200
   26325:	jae    21551 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1611>
   2632b:	jmp    21589 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1649>
   26330:	mov    rdi,r12
   26333:	mov    rsi,r13
   26336:	mov    rax,rdx
   26339:	xor    edx,edx
   2633b:	mov    r8,r11
   2633e:	call   5e231 <heap_hand>
   26343:	mov    r11,r8
   26346:	mov    rdx,rax
   26349:	movabs rdi,0xfffffffe00
   26353:	cmp    rcx,0x3108200
   2635a:	jae    2176f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x182f>
   26360:	jmp    217a6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1866>
   26365:	mov    rdi,r12
   26368:	mov    rsi,r13
   2636b:	mov    rax,rdx
   2636e:	xor    edx,edx
   26370:	mov    r8,r11
   26373:	call   5e231 <heap_hand>
   26378:	mov    r11,r8
   2637b:	mov    rdx,rax
   2637e:	movabs rdi,0xfffffffe00
   26388:	cmp    rcx,0x3108200
   2638f:	jae    21ae4 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1ba4>
   26395:	jmp    21b1b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1bdb>
   2639a:	mov    rdi,r12
   2639d:	mov    rsi,r13
   263a0:	xor    edx,edx
   263a2:	call   5e231 <heap_hand>
   263a7:	movabs rdi,0xfffffffe00
   263b1:	cmp    rcx,0x3108200
   263b8:	jae    21dff <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1ebf>
   263be:	jmp    21e36 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x1ef6>
   263c3:	mov    rdi,r12
   263c6:	mov    rsi,r13
   263c9:	xor    edx,edx
   263cb:	call   5e231 <heap_hand>
   263d0:	movabs rdi,0xfffffffe00
   263da:	mov    rsi,r9
   263dd:	cmp    rcx,0x3108200
   263e4:	jae    220b6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2176>
   263ea:	jmp    220ee <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x21ae>
   263ef:	mov    rdi,r12
   263f2:	mov    rsi,r13
   263f5:	mov    rax,rdx
   263f8:	xor    edx,edx
   263fa:	call   5e231 <heap_hand>
   263ff:	mov    rdx,rax
   26402:	movabs rdi,0xfffffffe00
   2640c:	cmp    rcx,0x3108200
   26413:	jae    2233d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x23fd>
   26419:	jmp    22374 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2434>
   2641e:	mov    rdi,r12
   26421:	mov    rsi,r13
   26424:	mov    rdx,QWORD PTR [rsp+0x28]
   26429:	mov    ecx,0x2
   2642e:	call   5e661 <rfc_wrap>
   26433:	mov    rcx,rax
   26436:	mov    r8,QWORD PTR [r13+0x10]
   2643a:	mov    r15,r9
   2643d:	test   r8,r8
   26440:	jne    22d4f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2e0f>
   26446:	jmp    22d13 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x2dd3>
   2644b:	mov    rdi,r12
   2644e:	mov    rsi,r13
   26451:	mov    edx,0x1
   26456:	call   5e35b <heap_alloc_miss>
   2645b:	mov    r8,rax
   2645e:	jmp    238cf <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x398f>
   26463:	mov    rdi,r12
   26466:	mov    rsi,r13
   26469:	mov    rdx,rbx
   2646c:	mov    ecx,0x1
   26471:	call   5e661 <rfc_wrap>
   26476:	movabs rdx,0x200000000000000
   26480:	mov    rbx,rax
   26483:	jmp    238f2 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x39b2>
   26488:	mov    rdi,r12
   2648b:	mov    rsi,r13
   2648e:	mov    rdx,r10
   26491:	mov    ecx,0x1
   26496:	call   5e661 <rfc_wrap>
   2649b:	movabs rdx,0x200000000000000
   264a5:	jmp    23905 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x39c5>
   264aa:	mov    rdi,r12
   264ad:	mov    rsi,r13
   264b0:	mov    edx,0x1
   264b5:	call   5e35b <heap_alloc_miss>
   264ba:	movabs rdx,0x200000000000000
   264c4:	mov    rcx,rax
   264c7:	cmp    r8,r9
   264ca:	jae    2393d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x39fd>
   264d0:	mov    rdi,r12
   264d3:	mov    rsi,r13
   264d6:	mov    rdx,r8
   264d9:	mov    r8,rcx
   264dc:	mov    ecx,0x1
   264e1:	call   5e661 <rfc_wrap>
   264e6:	movabs rdx,0x200000000000000
   264f0:	mov    rcx,r8
   264f3:	mov    r8,rax
   264f6:	lea    r9,[r12+rcx*8]
   264fa:	mov    QWORD PTR [r12+rcx*8],r8
   264fe:	cmp    rbp,rdx
   26501:	jne    2394e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3a0e>
   26507:	jmp    23a60 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3b20>
   2650c:	mov    rdi,r12
   2650f:	mov    rsi,r13
   26512:	mov    edx,0x1
   26517:	call   5e35b <heap_alloc_miss>
   2651c:	mov    r8,rax
   2651f:	jmp    239d4 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3a94>
   26524:	mov    rdi,r12
   26527:	mov    rsi,r13
   2652a:	mov    rdx,rbx
   2652d:	mov    ecx,0x1
   26532:	call   5e661 <rfc_wrap>
   26537:	movabs rsi,0x200000000000000
   26541:	mov    rdx,QWORD PTR [rsp+0x40]
   26546:	mov    rbx,rax
   26549:	jmp    239fc <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3abc>
   2654e:	mov    rdi,r12
   26551:	mov    rsi,r13
   26554:	mov    ecx,0x1
   26559:	call   5e661 <rfc_wrap>
   2655e:	movabs rsi,0x200000000000000
   26568:	mov    rdx,rax
   2656b:	jmp    23a0f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3acf>
   26570:	mov    rdi,r12
   26573:	mov    rsi,r13
   26576:	mov    edx,0x1
   2657b:	call   5e35b <heap_alloc_miss>
   26580:	movabs rsi,0x200000000000000
   2658a:	mov    rcx,rax
   2658d:	cmp    r8,r9
   26590:	jae    23a4c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3b0c>
   26596:	mov    rdi,r12
   26599:	mov    rsi,r13
   2659c:	mov    rdx,r8
   2659f:	mov    r8,rcx
   265a2:	mov    ecx,0x1
   265a7:	call   5e661 <rfc_wrap>
   265ac:	movabs rsi,0x200000000000000
   265b6:	mov    rcx,r8
   265b9:	mov    r8,rax
   265bc:	jmp    23a4c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3b0c>
   265c1:	mov    rdi,r12
   265c4:	mov    rsi,r13
   265c7:	mov    edx,0x1
   265cc:	call   5e35b <heap_alloc_miss>
   265d1:	mov    r8,rax
   265d4:	jmp    23ca8 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3d68>
   265d9:	mov    rdi,r12
   265dc:	mov    rsi,r13
   265df:	mov    rdx,r15
   265e2:	mov    ecx,0x1
   265e7:	call   5e661 <rfc_wrap>
   265ec:	movabs rdx,0x300000000000000
   265f6:	mov    r15,rax
   265f9:	jmp    23ccb <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3d8b>
   265fe:	mov    rdi,r12
   26601:	mov    rsi,r13
   26604:	mov    rdx,r10
   26607:	mov    ecx,0x1
   2660c:	call   5e661 <rfc_wrap>
   26611:	movabs rdx,0x300000000000000
   2661b:	jmp    23ce8 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3da8>
   26620:	mov    rdi,r12
   26623:	mov    rsi,r13
   26626:	mov    edx,0x1
   2662b:	call   5e35b <heap_alloc_miss>
   26630:	movabs rdx,0x300000000000000
   2663a:	mov    rcx,rax
   2663d:	cmp    r9,rdx
   26640:	jae    23d2a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3dea>
   26646:	mov    rdi,r12
   26649:	mov    rsi,r13
   2664c:	mov    rdx,r9
   2664f:	mov    r8,rcx
   26652:	mov    ecx,0x1
   26657:	call   5e661 <rfc_wrap>
   2665c:	mov    rcx,r8
   2665f:	mov    r9,rax
   26662:	jmp    23d2a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3dea>
   26667:	mov    rcx,rdi
   2666a:	mov    rdi,r12
   2666d:	mov    rsi,r13
   26670:	mov    edx,0x1
   26675:	call   5e35b <heap_alloc_miss>
   2667a:	mov    rdi,rcx
   2667d:	mov    r8,rax
   26680:	jmp    23dd5 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3e95>
   26685:	mov    r9,rdi
   26688:	mov    rdi,r12
   2668b:	mov    rsi,r13
   2668e:	mov    rdx,r15
   26691:	mov    ecx,0x1
   26696:	call   5e661 <rfc_wrap>
   2669b:	mov    rdi,r9
   2669e:	mov    rdx,QWORD PTR [rsp+0x48]
   266a3:	mov    r15,rax
   266a6:	jmp    23df8 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3eb8>
   266ab:	mov    r9,rdi
   266ae:	mov    rdi,r12
   266b1:	mov    rsi,r13
   266b4:	mov    ecx,0x1
   266b9:	call   5e661 <rfc_wrap>
   266be:	mov    rdi,r9
   266c1:	mov    rdx,rax
   266c4:	jmp    23e15 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3ed5>
   266c9:	mov    rcx,rdi
   266cc:	mov    rdi,r12
   266cf:	mov    rsi,r13
   266d2:	mov    edx,0x1
   266d7:	call   5e35b <heap_alloc_miss>
   266dc:	mov    rdi,rcx
   266df:	mov    rcx,rax
   266e2:	cmp    r9,rdi
   266e5:	jae    23e57 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3f17>
   266eb:	mov    rdi,r12
   266ee:	mov    rsi,r13
   266f1:	mov    rdx,r9
   266f4:	mov    r8,rcx
   266f7:	mov    ecx,0x1
   266fc:	call   5e661 <rfc_wrap>
   26701:	mov    rcx,r8
   26704:	mov    r9,rax
   26707:	jmp    23e57 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3f17>
   2670c:	mov    rdi,r12
   2670f:	mov    rsi,r13
   26712:	mov    edx,0x1
   26717:	call   5e35b <heap_alloc_miss>
   2671c:	mov    r8,rax
   2671f:	jmp    240d1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4191>
   26724:	mov    rdi,r12
   26727:	mov    rsi,r13
   2672a:	mov    rdx,rbx
   2672d:	mov    ecx,0x1
   26732:	call   5e661 <rfc_wrap>
   26737:	movabs rdx,0x200000000000000
   26741:	mov    rbx,rax
   26744:	jmp    240f4 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x41b4>
   26749:	mov    rdi,r12
   2674c:	mov    rsi,r13
   2674f:	mov    rdx,r10
   26752:	mov    ecx,0x1
   26757:	call   5e661 <rfc_wrap>
   2675c:	movabs rdx,0x200000000000000
   26766:	jmp    24107 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x41c7>
   2676b:	mov    rdi,r12
   2676e:	mov    rsi,r13
   26771:	mov    edx,0x1
   26776:	call   5e35b <heap_alloc_miss>
   2677b:	movabs rdx,0x200000000000000
   26785:	mov    rcx,rax
   26788:	cmp    r8,r9
   2678b:	jae    2413f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x41ff>
   26791:	mov    rdi,r12
   26794:	mov    rsi,r13
   26797:	mov    rdx,r8
   2679a:	mov    r8,rcx
   2679d:	mov    ecx,0x1
   267a2:	call   5e661 <rfc_wrap>
   267a7:	movabs rdx,0x200000000000000
   267b1:	mov    rcx,r8
   267b4:	mov    r8,rax
   267b7:	lea    r9,[r12+rcx*8]
   267bb:	mov    QWORD PTR [r12+rcx*8],r8
   267bf:	cmp    rbp,rdx
   267c2:	jne    24150 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4210>
   267c8:	jmp    24262 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4322>
   267cd:	mov    rdi,r12
   267d0:	mov    rsi,r13
   267d3:	mov    edx,0x1
   267d8:	call   5e35b <heap_alloc_miss>
   267dd:	mov    r8,rax
   267e0:	jmp    241d6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4296>
   267e5:	mov    rdi,r12
   267e8:	mov    rsi,r13
   267eb:	mov    rdx,rbx
   267ee:	mov    ecx,0x1
   267f3:	call   5e661 <rfc_wrap>
   267f8:	movabs rsi,0x200000000000000
   26802:	mov    rdx,QWORD PTR [rsp+0x28]
   26807:	mov    rbx,rax
   2680a:	jmp    241fe <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x42be>
   2680f:	mov    rdi,r12
   26812:	mov    rsi,r13
   26815:	mov    ecx,0x1
   2681a:	call   5e661 <rfc_wrap>
   2681f:	movabs rsi,0x200000000000000
   26829:	mov    rdx,rax
   2682c:	jmp    24211 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x42d1>
   26831:	mov    rdi,r12
   26834:	mov    rsi,r13
   26837:	mov    edx,0x1
   2683c:	call   5e35b <heap_alloc_miss>
   26841:	movabs rsi,0x200000000000000
   2684b:	mov    rcx,rax
   2684e:	cmp    r8,r9
   26851:	jae    2424e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x430e>
   26857:	mov    rdi,r12
   2685a:	mov    rsi,r13
   2685d:	mov    rdx,r8
   26860:	mov    r8,rcx
   26863:	mov    ecx,0x1
   26868:	call   5e661 <rfc_wrap>
   2686d:	movabs rsi,0x200000000000000
   26877:	mov    rcx,r8
   2687a:	mov    r8,rax
   2687d:	jmp    2424e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x430e>
   26882:	mov    rdi,r12
   26885:	mov    rcx,rsi
   26888:	mov    rsi,r13
   2688b:	mov    edx,0x1
   26890:	call   5e35b <heap_alloc_miss>
   26895:	mov    rsi,rcx
   26898:	mov    r8,rax
   2689b:	jmp    244a4 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4564>
   268a0:	mov    rdi,r12
   268a3:	mov    r9,rsi
   268a6:	mov    rsi,r13
   268a9:	mov    rdx,r14
   268ac:	mov    ecx,0x1
   268b1:	call   5e661 <rfc_wrap>
   268b6:	movabs rdi,0x300000000000000
   268c0:	movabs rdx,0xff00000000000000
   268ca:	mov    rsi,r9
   268cd:	mov    r14,rax
   268d0:	jmp    244c7 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4587>
   268d5:	mov    r10,rdx
   268d8:	mov    rdi,r12
   268db:	mov    r9,rsi
   268de:	mov    rsi,r13
   268e1:	mov    rdx,rbx
   268e4:	mov    ecx,0x1
   268e9:	call   5e661 <rfc_wrap>
   268ee:	movabs rdi,0x300000000000000
   268f8:	mov    rdx,r10
   268fb:	mov    rsi,r9
   268fe:	jmp    244da <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x459a>
   26903:	mov    r8,rdx
   26906:	mov    rdi,r12
   26909:	mov    rcx,rsi
   2690c:	mov    rsi,r13
   2690f:	mov    edx,0x1
   26914:	call   5e35b <heap_alloc_miss>
   26919:	movabs rdi,0x300000000000000
   26923:	mov    rdx,r8
   26926:	mov    rsi,rcx
   26929:	mov    rcx,rax
   2692c:	cmp    r9,rdi
   2692f:	jae    2451c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x45dc>
   26935:	mov    r14,rdx
   26938:	mov    rdi,r12
   2693b:	mov    rbp,rsi
   2693e:	mov    rsi,r13
   26941:	mov    rdx,r9
   26944:	mov    r8,rcx
   26947:	mov    ecx,0x1
   2694c:	call   5e661 <rfc_wrap>
   26951:	mov    rdx,r14
   26954:	mov    rsi,rbp
   26957:	movabs rbp,0x200000000000000
   26961:	mov    rcx,r8
   26964:	mov    r9,rax
   26967:	jmp    2451c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x45dc>
   2696c:	mov    r8,rdi
   2696f:	mov    rdi,r12
   26972:	mov    rcx,rsi
   26975:	mov    rsi,r13
   26978:	mov    edx,0x1
   2697d:	call   5e35b <heap_alloc_miss>
   26982:	mov    rdi,r8
   26985:	mov    rsi,rcx
   26988:	mov    r8,rax
   2698b:	jmp    24598 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4658>
   26990:	mov    r10,rdi
   26993:	mov    rdi,r12
   26996:	mov    r9,rsi
   26999:	mov    rsi,r13
   2699c:	mov    rdx,r14
   2699f:	mov    ecx,0x1
   269a4:	call   5e661 <rfc_wrap>
   269a9:	mov    rdi,r10
   269ac:	movabs rdx,0xff00000000000000
   269b6:	mov    rsi,r9
   269b9:	mov    r14,rax
   269bc:	jmp    245b6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4676>
   269c1:	mov    r10,rdi
   269c4:	mov    rdi,r12
   269c7:	mov    r9,rsi
   269ca:	mov    rsi,r13
   269cd:	mov    rdx,r15
   269d0:	mov    ecx,0x1
   269d5:	call   5e661 <rfc_wrap>
   269da:	mov    rdi,r10
   269dd:	movabs rdx,0xff00000000000000
   269e7:	mov    rsi,r9
   269ea:	mov    QWORD PTR [rsp+0x28],rax
   269ef:	jmp    245c9 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4689>
   269f4:	mov    r8,rdi
   269f7:	mov    rdi,r12
   269fa:	mov    rcx,rsi
   269fd:	mov    rsi,r13
   26a00:	mov    edx,0x1
   26a05:	call   5e35b <heap_alloc_miss>
   26a0a:	mov    rdi,r8
   26a0d:	movabs rdx,0xff00000000000000
   26a17:	mov    rsi,rcx
   26a1a:	mov    rcx,rax
   26a1d:	cmp    r9,rdi
   26a20:	jae    24610 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x46d0>
   26a26:	mov    rdi,r12
   26a29:	mov    rbp,rsi
   26a2c:	mov    rsi,r13
   26a2f:	mov    rdx,r9
   26a32:	mov    r8,rcx
   26a35:	mov    ecx,0x1
   26a3a:	call   5e661 <rfc_wrap>
   26a3f:	movabs rdx,0xff00000000000000
   26a49:	mov    rsi,rbp
   26a4c:	movabs rbp,0x200000000000000
   26a56:	mov    rcx,r8
   26a59:	mov    r9,rax
   26a5c:	jmp    24610 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x46d0>
   26a61:	mov    rdi,r12
   26a64:	mov    rsi,r13
   26a67:	mov    edx,0x1
   26a6c:	call   5e35b <heap_alloc_miss>
   26a71:	mov    r8,rax
   26a74:	jmp    233e1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x34a1>
   26a79:	mov    rdi,r12
   26a7c:	mov    rsi,r13
   26a7f:	mov    rdx,r15
   26a82:	mov    ecx,0x1
   26a87:	call   5e661 <rfc_wrap>
   26a8c:	movabs rsi,0x300000000000000
   26a96:	movabs rdx,0x200000000000000
   26aa0:	mov    r15,rax
   26aa3:	jmp    23404 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x34c4>
   26aa8:	mov    rdi,r12
   26aab:	mov    rsi,r13
   26aae:	mov    rdx,r10
   26ab1:	mov    ecx,0x1
   26ab6:	call   5e661 <rfc_wrap>
   26abb:	movabs rsi,0x300000000000000
   26ac5:	movabs rdx,0x200000000000000
   26acf:	jmp    23417 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x34d7>
   26ad4:	mov    rdi,r12
   26ad7:	mov    rsi,r13
   26ada:	mov    edx,0x1
   26adf:	call   5e35b <heap_alloc_miss>
   26ae4:	movabs rsi,0x300000000000000
   26aee:	movabs rdx,0x200000000000000
   26af8:	mov    rcx,rax
   26afb:	cmp    r9,rsi
   26afe:	jae    23459 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3519>
   26b04:	mov    rdi,r12
   26b07:	mov    rsi,r13
   26b0a:	mov    rdx,r9
   26b0d:	mov    r8,rcx
   26b10:	mov    ecx,0x1
   26b15:	call   5e661 <rfc_wrap>
   26b1a:	movabs rdx,0x200000000000000
   26b24:	mov    rcx,r8
   26b27:	mov    r9,rax
   26b2a:	lea    r8,[r12+rcx*8]
   26b2e:	mov    QWORD PTR [r12+rcx*8],r9
   26b32:	cmp    rbx,rdx
   26b35:	jne    2346a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x352a>
   26b3b:	jmp    23590 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3650>
   26b40:	mov    rcx,rdi
   26b43:	mov    rdi,r12
   26b46:	mov    rsi,r13
   26b49:	mov    edx,0x1
   26b4e:	call   5e35b <heap_alloc_miss>
   26b53:	mov    rdi,rcx
   26b56:	mov    r8,rax
   26b59:	jmp    234fa <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x35ba>
   26b5e:	mov    r9,rdi
   26b61:	mov    rdi,r12
   26b64:	mov    rsi,r13
   26b67:	mov    rdx,r15
   26b6a:	mov    ecx,0x1
   26b6f:	call   5e661 <rfc_wrap>
   26b74:	mov    rdi,r9
   26b77:	movabs rsi,0x200000000000000
   26b81:	mov    rdx,QWORD PTR [rsp+0x28]
   26b86:	mov    r15,rax
   26b89:	jmp    2351d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x35dd>
   26b8e:	mov    r9,rdi
   26b91:	mov    rdi,r12
   26b94:	mov    rsi,r13
   26b97:	mov    ecx,0x1
   26b9c:	call   5e661 <rfc_wrap>
   26ba1:	mov    rdi,r9
   26ba4:	movabs rsi,0x200000000000000
   26bae:	mov    rdx,rax
   26bb1:	jmp    23530 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x35f0>
   26bb6:	mov    rcx,rdi
   26bb9:	mov    rdi,r12
   26bbc:	mov    rsi,r13
   26bbf:	mov    edx,0x1
   26bc4:	call   5e35b <heap_alloc_miss>
   26bc9:	mov    rdi,rcx
   26bcc:	movabs rsi,0x200000000000000
   26bd6:	mov    rcx,rax
   26bd9:	cmp    r9,rdi
   26bdc:	jae    23572 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3632>
   26be2:	mov    rdi,r12
   26be5:	mov    rsi,r13
   26be8:	mov    rdx,r9
   26beb:	mov    r8,rcx
   26bee:	mov    ecx,0x1
   26bf3:	call   5e661 <rfc_wrap>
   26bf8:	movabs rsi,0x200000000000000
   26c02:	mov    rcx,r8
   26c05:	mov    r9,rax
   26c08:	jmp    23572 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x3632>
   26c0d:	mov    rdi,r12
   26c10:	mov    rcx,rsi
   26c13:	mov    rsi,r13
   26c16:	mov    edx,0x1
   26c1b:	call   5e35b <heap_alloc_miss>
   26c20:	mov    rsi,rcx
   26c23:	mov    r8,rax
   26c26:	jmp    248e2 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x49a2>
   26c2b:	mov    rdi,r12
   26c2e:	mov    r9,rsi
   26c31:	mov    rsi,r13
   26c34:	mov    rdx,r14
   26c37:	mov    ecx,0x1
   26c3c:	call   5e661 <rfc_wrap>
   26c41:	movabs rdi,0x300000000000000
   26c4b:	movabs rdx,0xff00000000000000
   26c55:	mov    rsi,r9
   26c58:	mov    r14,rax
   26c5b:	jmp    24905 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x49c5>
   26c60:	mov    r10,rdx
   26c63:	mov    rdi,r12
   26c66:	mov    r9,rsi
   26c69:	mov    rsi,r13
   26c6c:	mov    rdx,rbx
   26c6f:	mov    ecx,0x1
   26c74:	call   5e661 <rfc_wrap>
   26c79:	movabs rdi,0x300000000000000
   26c83:	mov    rdx,r10
   26c86:	mov    rsi,r9
   26c89:	jmp    24918 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x49d8>
   26c8e:	mov    r8,rdx
   26c91:	mov    rdi,r12
   26c94:	mov    rcx,rsi
   26c97:	mov    rsi,r13
   26c9a:	mov    edx,0x1
   26c9f:	call   5e35b <heap_alloc_miss>
   26ca4:	movabs rdi,0x300000000000000
   26cae:	mov    rdx,r8
   26cb1:	mov    rsi,rcx
   26cb4:	mov    rcx,rax
   26cb7:	cmp    r9,rdi
   26cba:	jae    2495a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4a1a>
   26cc0:	mov    r14,rdx
   26cc3:	mov    rdi,r12
   26cc6:	mov    rbp,rsi
   26cc9:	mov    rsi,r13
   26ccc:	mov    rdx,r9
   26ccf:	mov    r8,rcx
   26cd2:	mov    ecx,0x1
   26cd7:	call   5e661 <rfc_wrap>
   26cdc:	mov    rdx,r14
   26cdf:	mov    rsi,rbp
   26ce2:	movabs rbp,0x200000000000000
   26cec:	mov    rcx,r8
   26cef:	mov    r9,rax
   26cf2:	lea    r8,[r12+rcx*8]
   26cf6:	mov    QWORD PTR [r12+rcx*8],r9
   26cfa:	cmp    rdx,rbp
   26cfd:	jne    2496b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4a2b>
   26d03:	jmp    24a8c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4b4c>
   26d08:	mov    rdi,r12
   26d0b:	mov    rcx,rsi
   26d0e:	mov    rsi,r13
   26d11:	mov    edx,0x1
   26d16:	mov    r8,r11
   26d19:	call   5e35b <heap_alloc_miss>
   26d1e:	mov    r11,r8
   26d21:	mov    rsi,rcx
   26d24:	mov    r8,rax
   26d27:	jmp    24a00 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4ac0>
   26d2c:	mov    rdi,r12
   26d2f:	mov    r9,rsi
   26d32:	mov    rsi,r13
   26d35:	mov    rdx,r14
   26d38:	mov    ecx,0x1
   26d3d:	mov    r10,r11
   26d40:	call   5e661 <rfc_wrap>
   26d45:	mov    r11,r10
   26d48:	movabs rdi,0xff00000000000000
   26d52:	mov    rdx,QWORD PTR [rsp+0x28]
   26d57:	mov    rsi,r9
   26d5a:	mov    r14,rax
   26d5d:	jmp    24a23 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4ae3>
   26d62:	mov    rdi,r12
   26d65:	mov    r9,rsi
   26d68:	mov    rsi,r13
   26d6b:	mov    ecx,0x1
   26d70:	mov    r10,r11
   26d73:	call   5e661 <rfc_wrap>
   26d78:	mov    r11,r10
   26d7b:	movabs rdi,0xff00000000000000
   26d85:	mov    rsi,r9
   26d88:	mov    rdx,rax
   26d8b:	jmp    24a36 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4af6>
   26d90:	mov    rdi,r12
   26d93:	mov    rcx,rsi
   26d96:	mov    rsi,r13
   26d99:	mov    edx,0x1
   26d9e:	mov    r8,r11
   26da1:	call   5e35b <heap_alloc_miss>
   26da6:	mov    r11,r8
   26da9:	movabs rdi,0xff00000000000000
   26db3:	mov    rsi,rcx
   26db6:	mov    rcx,rax
   26db9:	cmp    r9,r11
   26dbc:	jae    24a78 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4b38>
   26dc2:	mov    rdi,r12
   26dc5:	mov    rbp,rsi
   26dc8:	mov    rsi,r13
   26dcb:	mov    rdx,r9
   26dce:	mov    r8,rcx
   26dd1:	mov    ecx,0x1
   26dd6:	call   5e661 <rfc_wrap>
   26ddb:	movabs rdi,0xff00000000000000
   26de5:	mov    rsi,rbp
   26de8:	movabs rbp,0x200000000000000
   26df2:	mov    rcx,r8
   26df5:	mov    r9,rax
   26df8:	jmp    24a78 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x4b38>
   26dfd:	mov    QWORD PTR [rsp+0x50],r8
   26e02:	movabs rax,0x7e00000000000000
   26e0c:	mov    rsi,QWORD PTR [rsp+0x30]
   26e11:	test   rsi,rax
   26e14:	sete   al
   26e17:	cmp    rsi,0xffffffffffffffff
   26e1b:	sete   cl
   26e1e:	or     cl,al
   26e20:	and    rdi,rsi
   26e23:	cmp    rdi,0x3108200
   26e2a:	setb   al
   26e2d:	or     al,cl
   26e2f:	jne    26e41 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x6f01>
   26e31:	mov    rdx,rsi
   26e34:	mov    rdi,r12
   26e37:	mov    rsi,QWORD PTR [rsp+0x8]
   26e3c:	call   e8c0 <term_drop>
   26e41:	cmp    DWORD PTR [rsp+0x14],0x0
   26e46:	jne    26f56 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7016>
   26e4c:	mov    r13,QWORD PTR [rsp+0x20]
   26e51:	mov    rcx,QWORD PTR [r13-0x18]
   26e55:	lea    r14,[r13-0x10]
   26e59:	mov    r8d,DWORD PTR [r13-0x10]
   26e5d:	mov    rdi,r12
   26e60:	mov    rbp,QWORD PTR [rsp+0x8]
   26e65:	mov    rsi,rbp
   26e68:	mov    edx,0xc7
   26e6d:	mov    r9d,0x1
   26e73:	call   ed60 <task_node>
   26e78:	mov    rcx,QWORD PTR [rsp+0x50]
   26e7d:	mov    QWORD PTR [r12+rax*8],rcx
   26e81:	movabs rcx,0x500c70000000000
   26e8b:	or     rcx,rax
   26e8e:	mov    QWORD PTR [r13-0x18],rcx
   26e92:	mov    QWORD PTR [r13-0x10],0x1
   26e9a:	mov    rdi,r12
   26e9d:	mov    rsi,rbp
   26ea0:	mov    edx,0xc8
   26ea5:	mov    r8d,0x1
   26eab:	mov    r9d,0x1
   26eb1:	call   ed60 <task_node>
   26eb6:	mov    rcx,QWORD PTR [rsp+0x18]
   26ebb:	mov    QWORD PTR [r12+rax*8],rcx
   26ebf:	movabs rcx,0x500c80000000000
   26ec9:	or     rcx,rax
   26ecc:	mov    QWORD PTR [r13-0x18],rcx
   26ed0:	mov    QWORD PTR [r13-0x10],0x1
   26ed8:	mov    rdi,r12
   26edb:	mov    rsi,rbp
   26ede:	mov    edx,0xc9
   26ee3:	mov    r8d,0x1
   26ee9:	mov    r9d,0x1
   26eef:	call   ed60 <task_node>
   26ef4:	mov    QWORD PTR [r12+rax*8],r15
   26ef8:	movabs rcx,0x500c90000000000
   26f02:	or     rcx,rax
   26f05:	mov    QWORD PTR [r13-0x18],rcx
   26f09:	mov    QWORD PTR [r13-0x10],0x1
   26f11:	mov    rdi,r12
   26f14:	mov    rsi,rbp
   26f17:	mov    edx,0xca
   26f1c:	mov    r8d,0x1
   26f22:	mov    r9d,0x1
   26f28:	call   ed60 <task_node>
   26f2d:	mov    QWORD PTR [r12+rax*8],rbx
   26f31:	movabs rcx,0x500ca0000000000
   26f3b:	or     rcx,rax
   26f3e:	mov    QWORD PTR [r13-0x18],rcx
   26f42:	mov    eax,0x1
   26f47:	mov    QWORD PTR [r14],rax
   26f4a:	lea    rdi,[rip+0xfffffffffffdef6f]        # 5ec0 <FID_RESW_T+0x510>
   26f51:	call   5e1d0 <err_fail>
   26f56:	mov    r14,QWORD PTR [rsp+0x20]
   26f5b:	mov    rax,QWORD PTR [rsp+0x50]
   26f60:	mov    QWORD PTR [r14],rax
   26f63:	mov    QWORD PTR [r14+0x8],0xc7
   26f6b:	mov    rax,QWORD PTR [rsp+0x18]
   26f70:	mov    QWORD PTR [r14+0x10],rax
   26f74:	mov    QWORD PTR [r14+0x18],0xc8
   26f7c:	mov    QWORD PTR [r14+0x20],r15
   26f80:	mov    QWORD PTR [r14+0x28],0xc9
   26f88:	mov    QWORD PTR [r14+0x30],rbx
   26f8c:	add    r14,0x38
   26f90:	mov    eax,0xca
   26f95:	mov    QWORD PTR [r14],rax
   26f98:	lea    rdi,[rip+0xfffffffffffdef21]        # 5ec0 <FID_RESW_T+0x510>
   26f9f:	call   5e1d0 <err_fail>
   26fa4:	mov    r14,rdx
   26fa7:	movabs r15,0x7e00000000000000
   26fb1:	mov    rdx,QWORD PTR [rsp+0x18]
   26fb6:	test   rdx,r15
   26fb9:	sete   al
   26fbc:	cmp    rdx,0xffffffffffffffff
   26fc0:	sete   cl
   26fc3:	or     cl,al
   26fc5:	mov    rax,rdx
   26fc8:	movabs rdx,0xfffffffe00
   26fd2:	and    rax,rdx
   26fd5:	cmp    rax,0x3108200
   26fdb:	setb   al
   26fde:	or     al,cl
   26fe0:	jne    26ff4 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x70b4>
   26fe2:	mov    rdi,r12
   26fe5:	mov    rsi,QWORD PTR [rsp+0x8]
   26fea:	mov    rdx,QWORD PTR [rsp+0x18]
   26fef:	call   e8c0 <term_drop>
   26ff4:	mov    rdx,QWORD PTR [rsp+0x28]
   26ff9:	test   rdx,r15
   26ffc:	sete   al
   26fff:	cmp    rdx,0xffffffffffffffff
   27003:	sete   cl
   27006:	or     cl,al
   27008:	mov    rax,rdx
   2700b:	movabs rdx,0xfffffffe00
   27015:	and    rax,rdx
   27018:	cmp    rax,0x3108200
   2701e:	setb   al
   27021:	or     al,cl
   27023:	jne    28a00 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8ac0>
   27029:	mov    rdi,r12
   2702c:	mov    rsi,QWORD PTR [rsp+0x8]
   27031:	mov    rdx,QWORD PTR [rsp+0x28]
   27036:	jmp    289fb <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8abb>
   2703b:	mov    r14,rdx
   2703e:	movabs r15,0x7e00000000000000
   27048:	mov    rdx,QWORD PTR [rsp+0x18]
   2704d:	test   rdx,r15
   27050:	sete   al
   27053:	cmp    rdx,0xffffffffffffffff
   27057:	sete   cl
   2705a:	or     cl,al
   2705c:	mov    rax,rdx
   2705f:	movabs rdx,0xfffffffe00
   27069:	and    rax,rdx
   2706c:	cmp    rax,0x3108200
   27072:	setb   al
   27075:	or     al,cl
   27077:	jne    2708b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x714b>
   27079:	mov    rdi,r12
   2707c:	mov    rsi,QWORD PTR [rsp+0x8]
   27081:	mov    rdx,QWORD PTR [rsp+0x18]
   27086:	call   e8c0 <term_drop>
   2708b:	mov    rdx,QWORD PTR [rsp+0x28]
   27090:	test   rdx,r15
   27093:	sete   al
   27096:	cmp    rdx,0xffffffffffffffff
   2709a:	sete   cl
   2709d:	or     cl,al
   2709f:	mov    rax,rdx
   270a2:	movabs rdx,0xfffffffe00
   270ac:	and    rax,rdx
   270af:	cmp    rax,0x3108200
   270b5:	setb   al
   270b8:	or     al,cl
   270ba:	jne    28c32 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8cf2>
   270c0:	mov    rdi,r12
   270c3:	mov    rsi,QWORD PTR [rsp+0x8]
   270c8:	mov    rdx,QWORD PTR [rsp+0x28]
   270cd:	jmp    28c2d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8ced>
   270d2:	mov    QWORD PTR [rsp+0x50],r8
   270d7:	movabs rbx,0x7e00000000000000
   270e1:	mov    rsi,QWORD PTR [rsp+0x30]
   270e6:	test   rsi,rbx
   270e9:	sete   al
   270ec:	cmp    rsi,0xffffffffffffffff
   270f0:	sete   cl
   270f3:	or     cl,al
   270f5:	mov    rax,rsi
   270f8:	and    rax,rdi
   270fb:	cmp    rax,0x3108200
   27101:	setb   al
   27104:	or     al,cl
   27106:	jne    27118 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x71d8>
   27108:	mov    rdx,rsi
   2710b:	mov    rdi,r12
   2710e:	mov    rsi,QWORD PTR [rsp+0x8]
   27113:	call   e8c0 <term_drop>
   27118:	test   r14,rbx
   2711b:	sete   al
   2711e:	cmp    r14,0xffffffffffffffff
   27122:	sete   cl
   27125:	or     cl,al
   27127:	mov    rax,r14
   2712a:	movabs rdx,0xfffffffe00
   27134:	and    rax,rdx
   27137:	cmp    rax,0x3108200
   2713d:	setb   al
   27140:	or     al,cl
   27142:	jne    27154 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7214>
   27144:	mov    rdi,r12
   27147:	mov    rsi,QWORD PTR [rsp+0x8]
   2714c:	mov    rdx,r14
   2714f:	call   e8c0 <term_drop>
   27154:	mov    rdx,QWORD PTR [rsp+0x28]
   27159:	test   rdx,rbx
   2715c:	sete   al
   2715f:	cmp    rdx,0xffffffffffffffff
   27163:	sete   cl
   27166:	or     cl,al
   27168:	movabs rax,0xfffffffe00
   27172:	and    rax,rdx
   27175:	cmp    rax,0x3108200
   2717b:	setb   al
   2717e:	or     al,cl
   27180:	jne    27194 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7254>
   27182:	mov    rdi,r12
   27185:	mov    rsi,QWORD PTR [rsp+0x8]
   2718a:	mov    rdx,QWORD PTR [rsp+0x28]
   2718f:	call   e8c0 <term_drop>
   27194:	cmp    DWORD PTR [rsp+0x14],0x0
   27199:	jne    283d6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8496>
   2719f:	mov    r14,QWORD PTR [rsp+0x20]
   271a4:	mov    rcx,QWORD PTR [r14-0x18]
   271a8:	lea    rbx,[r14-0x10]
   271ac:	mov    r8d,DWORD PTR [r14-0x10]
   271b0:	mov    rdi,r12
   271b3:	mov    r13,QWORD PTR [rsp+0x8]
   271b8:	mov    rsi,r13
   271bb:	mov    edx,0xb3
   271c0:	mov    r9d,0x1
   271c6:	call   ed60 <task_node>
   271cb:	mov    rcx,QWORD PTR [rsp+0x50]
   271d0:	mov    QWORD PTR [r12+rax*8],rcx
   271d4:	movabs rcx,0x500b30000000000
   271de:	or     rcx,rax
   271e1:	mov    QWORD PTR [r14-0x18],rcx
   271e5:	mov    QWORD PTR [r14-0x10],0x1
   271ed:	mov    rdi,r12
   271f0:	mov    rsi,r13
   271f3:	mov    edx,0xb4
   271f8:	mov    r8d,0x1
   271fe:	mov    r9d,0x1
   27204:	call   ed60 <task_node>
   27209:	mov    rcx,QWORD PTR [rsp+0x18]
   2720e:	mov    QWORD PTR [r12+rax*8],rcx
   27212:	movabs rcx,0x500b40000000000
   2721c:	or     rcx,rax
   2721f:	mov    QWORD PTR [r14-0x18],rcx
   27223:	mov    QWORD PTR [r14-0x10],0x1
   2722b:	mov    rdi,r12
   2722e:	mov    rsi,r13
   27231:	mov    edx,0xb5
   27236:	mov    r8d,0x1
   2723c:	mov    r9d,0x1
   27242:	call   ed60 <task_node>
   27247:	mov    QWORD PTR [r12+rax*8],r15
   2724b:	movabs rcx,0x500b50000000000
   27255:	jmp    287ec <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x88ac>
   2725a:	mov    r13,r9
   2725d:	mov    QWORD PTR [rsp+0x50],r8
   27262:	movabs rbx,0x7e00000000000000
   2726c:	mov    rsi,QWORD PTR [rsp+0x30]
   27271:	test   rsi,rbx
   27274:	sete   al
   27277:	cmp    rsi,0xffffffffffffffff
   2727b:	sete   cl
   2727e:	or     cl,al
   27280:	mov    rax,rsi
   27283:	and    rax,rdi
   27286:	cmp    rax,0x3108200
   2728c:	setb   al
   2728f:	or     al,cl
   27291:	jne    272a3 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7363>
   27293:	mov    rdx,rsi
   27296:	mov    rdi,r12
   27299:	mov    rsi,QWORD PTR [rsp+0x8]
   2729e:	call   e8c0 <term_drop>
   272a3:	mov    rdx,QWORD PTR [rsp+0x28]
   272a8:	test   rdx,rbx
   272ab:	sete   al
   272ae:	cmp    rdx,0xffffffffffffffff
   272b2:	sete   cl
   272b5:	or     cl,al
   272b7:	mov    rax,rdx
   272ba:	movabs rdx,0xfffffffe00
   272c4:	and    rax,rdx
   272c7:	cmp    rax,0x3108200
   272cd:	setb   al
   272d0:	or     al,cl
   272d2:	jne    272e6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x73a6>
   272d4:	mov    rdi,r12
   272d7:	mov    rsi,QWORD PTR [rsp+0x8]
   272dc:	mov    rdx,QWORD PTR [rsp+0x28]
   272e1:	call   e8c0 <term_drop>
   272e6:	test   r13,rbx
   272e9:	sete   al
   272ec:	cmp    r13,0xffffffffffffffff
   272f0:	sete   cl
   272f3:	or     cl,al
   272f5:	mov    rax,r13
   272f8:	movabs rdx,0xfffffffe00
   27302:	and    rax,rdx
   27305:	cmp    rax,0x3108200
   2730b:	setb   al
   2730e:	or     al,cl
   27310:	jne    27322 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x73e2>
   27312:	mov    rdi,r12
   27315:	mov    rsi,QWORD PTR [rsp+0x8]
   2731a:	mov    rdx,r13
   2731d:	call   e8c0 <term_drop>
   27322:	test   r14,rbx
   27325:	sete   al
   27328:	cmp    r14,0xffffffffffffffff
   2732c:	sete   cl
   2732f:	or     cl,al
   27331:	movabs rax,0xfffffffe00
   2733b:	and    rax,r14
   2733e:	cmp    rax,0x3108200
   27344:	setb   al
   27347:	or     al,cl
   27349:	jne    2735b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x741b>
   2734b:	mov    rdi,r12
   2734e:	mov    rsi,QWORD PTR [rsp+0x8]
   27353:	mov    rdx,r14
   27356:	call   e8c0 <term_drop>
   2735b:	cmp    DWORD PTR [rsp+0x14],0x0
   27360:	jne    28418 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x84d8>
   27366:	mov    r14,QWORD PTR [rsp+0x20]
   2736b:	mov    rcx,QWORD PTR [r14-0x18]
   2736f:	lea    rbx,[r14-0x10]
   27373:	mov    r8d,DWORD PTR [r14-0x10]
   27377:	mov    rdi,r12
   2737a:	mov    r13,QWORD PTR [rsp+0x8]
   2737f:	mov    rsi,r13
   27382:	mov    edx,0xc4
   27387:	mov    r9d,0x1
   2738d:	call   ed60 <task_node>
   27392:	mov    rcx,QWORD PTR [rsp+0x50]
   27397:	mov    QWORD PTR [r12+rax*8],rcx
   2739b:	movabs rcx,0x500c40000000000
   273a5:	or     rcx,rax
   273a8:	mov    QWORD PTR [r14-0x18],rcx
   273ac:	mov    QWORD PTR [r14-0x10],0x1
   273b4:	mov    rdi,r12
   273b7:	mov    rsi,r13
   273ba:	mov    edx,0xc5
   273bf:	mov    r8d,0x1
   273c5:	mov    r9d,0x1
   273cb:	call   ed60 <task_node>
   273d0:	mov    rcx,QWORD PTR [rsp+0x18]
   273d5:	mov    QWORD PTR [r12+rax*8],rcx
   273d9:	movabs rcx,0x500c50000000000
   273e3:	or     rcx,rax
   273e6:	mov    QWORD PTR [r14-0x18],rcx
   273ea:	mov    QWORD PTR [r14-0x10],0x1
   273f2:	mov    rdi,r12
   273f5:	mov    rsi,r13
   273f8:	mov    edx,0xc6
   273fd:	mov    r8d,0x1
   27403:	mov    r9d,0x1
   27409:	call   ed60 <task_node>
   2740e:	mov    QWORD PTR [r12+rax*8],r15
   27412:	movabs rcx,0x500c60000000000
   2741c:	jmp    287ec <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x88ac>
   27421:	mov    QWORD PTR [rsp+0x50],r8
   27426:	movabs rax,0x7e00000000000000
   27430:	mov    rsi,QWORD PTR [rsp+0x30]
   27435:	test   rsi,rax
   27438:	sete   al
   2743b:	cmp    rsi,0xffffffffffffffff
   2743f:	sete   cl
   27442:	or     cl,al
   27444:	and    rdi,rsi
   27447:	cmp    rdi,0x3108200
   2744e:	setb   al
   27451:	or     al,cl
   27453:	jne    27465 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7525>
   27455:	mov    rdx,rsi
   27458:	mov    rdi,r12
   2745b:	mov    rsi,QWORD PTR [rsp+0x8]
   27460:	call   e8c0 <term_drop>
   27465:	cmp    DWORD PTR [rsp+0x14],0x0
   2746a:	jne    2845a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x851a>
   27470:	mov    r14,QWORD PTR [rsp+0x20]
   27475:	mov    rcx,QWORD PTR [r14-0x18]
   27479:	lea    rbx,[r14-0x10]
   2747d:	mov    r8d,DWORD PTR [r14-0x10]
   27481:	mov    rdi,r12
   27484:	mov    r13,QWORD PTR [rsp+0x8]
   27489:	mov    rsi,r13
   2748c:	mov    edx,0xa8
   27491:	mov    r9d,0x1
   27497:	call   ed60 <task_node>
   2749c:	mov    rcx,QWORD PTR [rsp+0x50]
   274a1:	mov    QWORD PTR [r12+rax*8],rcx
   274a5:	movabs rcx,0x500a80000000000
   274af:	or     rcx,rax
   274b2:	mov    QWORD PTR [r14-0x18],rcx
   274b6:	mov    QWORD PTR [r14-0x10],0x1
   274be:	mov    rdi,r12
   274c1:	mov    rsi,r13
   274c4:	mov    edx,0xa9
   274c9:	mov    r8d,0x1
   274cf:	mov    r9d,0x1
   274d5:	call   ed60 <task_node>
   274da:	mov    rcx,QWORD PTR [rsp+0x18]
   274df:	mov    QWORD PTR [r12+rax*8],rcx
   274e3:	movabs rcx,0x500a90000000000
   274ed:	or     rcx,rax
   274f0:	mov    QWORD PTR [r14-0x18],rcx
   274f4:	mov    QWORD PTR [r14-0x10],0x1
   274fc:	mov    rdi,r12
   274ff:	mov    rsi,r13
   27502:	mov    edx,0xaa
   27507:	mov    r8d,0x1
   2750d:	mov    r9d,0x1
   27513:	call   ed60 <task_node>
   27518:	mov    QWORD PTR [r12+rax*8],r15
   2751c:	movabs rcx,0x500aa0000000000
   27526:	jmp    287ec <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x88ac>
   2752b:	mov    r13,rsi
   2752e:	mov    r15,r8
   27531:	movabs rbx,0x7e00000000000000
   2753b:	mov    rsi,QWORD PTR [rsp+0x30]
   27540:	test   rsi,rbx
   27543:	sete   al
   27546:	cmp    rsi,0xffffffffffffffff
   2754a:	sete   cl
   2754d:	or     cl,al
   2754f:	mov    rax,rsi
   27552:	and    rax,rdi
   27555:	cmp    rax,0x3108200
   2755b:	setb   al
   2755e:	or     al,cl
   27560:	jne    27572 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7632>
   27562:	mov    rdx,rsi
   27565:	mov    rdi,r12
   27568:	mov    rsi,QWORD PTR [rsp+0x8]
   2756d:	call   e8c0 <term_drop>
   27572:	test   r14,rbx
   27575:	sete   al
   27578:	cmp    r14,0xffffffffffffffff
   2757c:	sete   cl
   2757f:	or     cl,al
   27581:	mov    rax,r14
   27584:	movabs rdx,0xfffffffe00
   2758e:	and    rax,rdx
   27591:	cmp    rax,0x3108200
   27597:	setb   al
   2759a:	or     al,cl
   2759c:	jne    275ae <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x766e>
   2759e:	mov    rdi,r12
   275a1:	mov    rsi,QWORD PTR [rsp+0x8]
   275a6:	mov    rdx,r14
   275a9:	call   e8c0 <term_drop>
   275ae:	mov    rdx,QWORD PTR [rsp+0x28]
   275b3:	test   rdx,rbx
   275b6:	sete   al
   275b9:	cmp    rdx,0xffffffffffffffff
   275bd:	sete   cl
   275c0:	or     cl,al
   275c2:	mov    rax,rdx
   275c5:	movabs rdx,0xfffffffe00
   275cf:	and    rax,rdx
   275d2:	cmp    rax,0x3108200
   275d8:	setb   al
   275db:	or     al,cl
   275dd:	jne    275f1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x76b1>
   275df:	mov    rdi,r12
   275e2:	mov    rsi,QWORD PTR [rsp+0x8]
   275e7:	mov    rdx,QWORD PTR [rsp+0x28]
   275ec:	call   e8c0 <term_drop>
   275f1:	mov    rdx,QWORD PTR [rsp+0x18]
   275f6:	test   rdx,rbx
   275f9:	sete   al
   275fc:	cmp    rdx,0xffffffffffffffff
   27600:	sete   cl
   27603:	or     cl,al
   27605:	mov    rax,rdx
   27608:	movabs rdx,0xfffffffe00
   27612:	and    rax,rdx
   27615:	cmp    rax,0x3108200
   2761b:	setb   al
   2761e:	or     al,cl
   27620:	jne    27634 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x76f4>
   27622:	mov    rdi,r12
   27625:	mov    rsi,QWORD PTR [rsp+0x8]
   2762a:	mov    rdx,QWORD PTR [rsp+0x18]
   2762f:	call   e8c0 <term_drop>
   27634:	test   r13,rbx
   27637:	sete   al
   2763a:	cmp    r13,0xffffffffffffffff
   2763e:	sete   cl
   27641:	or     cl,al
   27643:	mov    rax,r13
   27646:	movabs rdx,0xfffffffe00
   27650:	and    rax,rdx
   27653:	cmp    rax,0x3108200
   27659:	setb   al
   2765c:	or     al,cl
   2765e:	jne    27670 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7730>
   27660:	mov    rdi,r12
   27663:	mov    rsi,QWORD PTR [rsp+0x8]
   27668:	mov    rdx,r13
   2766b:	call   e8c0 <term_drop>
   27670:	mov    rdx,QWORD PTR [rsp+0x40]
   27675:	test   rdx,rbx
   27678:	sete   al
   2767b:	cmp    rdx,0xffffffffffffffff
   2767f:	sete   cl
   27682:	or     cl,al
   27684:	movabs rax,0xfffffffe00
   2768e:	and    rax,rdx
   27691:	cmp    rax,0x3108200
   27697:	setb   al
   2769a:	or     al,cl
   2769c:	jne    276b0 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7770>
   2769e:	mov    rdi,r12
   276a1:	mov    rsi,QWORD PTR [rsp+0x8]
   276a6:	mov    rdx,QWORD PTR [rsp+0x40]
   276ab:	call   e8c0 <term_drop>
   276b0:	cmp    DWORD PTR [rsp+0x14],0x0
   276b5:	jne    28610 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x86d0>
   276bb:	mov    r14,QWORD PTR [rsp+0x20]
   276c0:	mov    rcx,QWORD PTR [r14-0x18]
   276c4:	lea    rbx,[r14-0x10]
   276c8:	mov    r8d,DWORD PTR [r14-0x10]
   276cc:	mov    rdi,r12
   276cf:	mov    rsi,QWORD PTR [rsp+0x8]
   276d4:	mov    edx,0xae
   276d9:	mov    r9d,0x1
   276df:	call   ed60 <task_node>
   276e4:	mov    QWORD PTR [r12+rax*8],r15
   276e8:	movabs rcx,0x500ae0000000000
   276f2:	jmp    287ec <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x88ac>
   276f7:	mov    r13,rbx
   276fa:	mov    r15,r8
   276fd:	movabs rbx,0x7e00000000000000
   27707:	mov    rsi,QWORD PTR [rsp+0x30]
   2770c:	test   rsi,rbx
   2770f:	sete   al
   27712:	cmp    rsi,0xffffffffffffffff
   27716:	sete   cl
   27719:	or     cl,al
   2771b:	mov    rax,rsi
   2771e:	and    rax,rdi
   27721:	cmp    rax,0x3108200
   27727:	setb   al
   2772a:	or     al,cl
   2772c:	jne    2773e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x77fe>
   2772e:	mov    rdx,rsi
   27731:	mov    rdi,r12
   27734:	mov    rsi,QWORD PTR [rsp+0x8]
   27739:	call   e8c0 <term_drop>
   2773e:	test   r14,rbx
   27741:	sete   al
   27744:	cmp    r14,0xffffffffffffffff
   27748:	sete   cl
   2774b:	or     cl,al
   2774d:	mov    rax,r14
   27750:	movabs rdx,0xfffffffe00
   2775a:	and    rax,rdx
   2775d:	cmp    rax,0x3108200
   27763:	setb   al
   27766:	or     al,cl
   27768:	jne    2777a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x783a>
   2776a:	mov    rdi,r12
   2776d:	mov    rsi,QWORD PTR [rsp+0x8]
   27772:	mov    rdx,r14
   27775:	call   e8c0 <term_drop>
   2777a:	mov    rdx,QWORD PTR [rsp+0x28]
   2777f:	test   rdx,rbx
   27782:	sete   al
   27785:	cmp    rdx,0xffffffffffffffff
   27789:	sete   cl
   2778c:	or     cl,al
   2778e:	mov    rax,rdx
   27791:	movabs rdx,0xfffffffe00
   2779b:	and    rax,rdx
   2779e:	cmp    rax,0x3108200
   277a4:	setb   al
   277a7:	or     al,cl
   277a9:	jne    277bd <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x787d>
   277ab:	mov    rdi,r12
   277ae:	mov    rsi,QWORD PTR [rsp+0x8]
   277b3:	mov    rdx,QWORD PTR [rsp+0x28]
   277b8:	call   e8c0 <term_drop>
   277bd:	mov    rdx,QWORD PTR [rsp+0x18]
   277c2:	test   rdx,rbx
   277c5:	sete   al
   277c8:	cmp    rdx,0xffffffffffffffff
   277cc:	sete   cl
   277cf:	or     cl,al
   277d1:	mov    rax,rdx
   277d4:	movabs rdx,0xfffffffe00
   277de:	and    rax,rdx
   277e1:	cmp    rax,0x3108200
   277e7:	setb   al
   277ea:	or     al,cl
   277ec:	jne    27800 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x78c0>
   277ee:	mov    rdi,r12
   277f1:	mov    rsi,QWORD PTR [rsp+0x8]
   277f6:	mov    rdx,QWORD PTR [rsp+0x18]
   277fb:	call   e8c0 <term_drop>
   27800:	mov    rdx,QWORD PTR [rsp+0x38]
   27805:	test   rdx,rbx
   27808:	sete   al
   2780b:	cmp    rdx,0xffffffffffffffff
   2780f:	sete   cl
   27812:	or     cl,al
   27814:	mov    rax,rdx
   27817:	movabs rdx,0xfffffffe00
   27821:	and    rax,rdx
   27824:	cmp    rax,0x3108200
   2782a:	setb   al
   2782d:	or     al,cl
   2782f:	jne    27843 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7903>
   27831:	mov    rdi,r12
   27834:	mov    rsi,QWORD PTR [rsp+0x8]
   27839:	mov    rdx,QWORD PTR [rsp+0x38]
   2783e:	call   e8c0 <term_drop>
   27843:	mov    rdx,QWORD PTR [rsp+0x48]
   27848:	test   rdx,rbx
   2784b:	sete   al
   2784e:	cmp    rdx,0xffffffffffffffff
   27852:	sete   cl
   27855:	or     cl,al
   27857:	mov    rax,rdx
   2785a:	movabs rdx,0xfffffffe00
   27864:	and    rax,rdx
   27867:	cmp    rax,0x3108200
   2786d:	setb   al
   27870:	or     al,cl
   27872:	jne    27886 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7946>
   27874:	mov    rdi,r12
   27877:	mov    rsi,QWORD PTR [rsp+0x8]
   2787c:	mov    rdx,QWORD PTR [rsp+0x48]
   27881:	call   e8c0 <term_drop>
   27886:	test   r13,rbx
   27889:	sete   al
   2788c:	cmp    r13,0xffffffffffffffff
   27890:	sete   cl
   27893:	or     cl,al
   27895:	movabs rax,0xfffffffe00
   2789f:	and    rax,r13
   278a2:	cmp    rax,0x3108200
   278a8:	setb   al
   278ab:	or     al,cl
   278ad:	jne    278bf <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x797f>
   278af:	mov    rdi,r12
   278b2:	mov    rsi,QWORD PTR [rsp+0x8]
   278b7:	mov    rdx,r13
   278ba:	call   e8c0 <term_drop>
   278bf:	cmp    DWORD PTR [rsp+0x14],0x0
   278c4:	jne    28630 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x86f0>
   278ca:	mov    r14,QWORD PTR [rsp+0x20]
   278cf:	mov    rcx,QWORD PTR [r14-0x18]
   278d3:	lea    rbx,[r14-0x10]
   278d7:	mov    r8d,DWORD PTR [r14-0x10]
   278db:	mov    rdi,r12
   278de:	mov    rsi,QWORD PTR [rsp+0x8]
   278e3:	mov    edx,0xb2
   278e8:	mov    r9d,0x1
   278ee:	call   ed60 <task_node>
   278f3:	mov    QWORD PTR [r12+rax*8],r15
   278f7:	movabs rcx,0x500b20000000000
   27901:	jmp    287ec <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x88ac>
   27906:	mov    r15,rsi
   27909:	mov    r13,r9
   2790c:	mov    QWORD PTR [rsp+0x50],r8
   27911:	movabs rbx,0x7e00000000000000
   2791b:	mov    rsi,QWORD PTR [rsp+0x30]
   27920:	test   rsi,rbx
   27923:	sete   al
   27926:	cmp    rsi,0xffffffffffffffff
   2792a:	sete   cl
   2792d:	or     cl,al
   2792f:	mov    rax,rsi
   27932:	and    rax,rdi
   27935:	cmp    rax,0x3108200
   2793b:	setb   al
   2793e:	or     al,cl
   27940:	jne    27952 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7a12>
   27942:	mov    rdx,rsi
   27945:	mov    rdi,r12
   27948:	mov    rsi,QWORD PTR [rsp+0x8]
   2794d:	call   e8c0 <term_drop>
   27952:	mov    rdx,QWORD PTR [rsp+0x28]
   27957:	test   rdx,rbx
   2795a:	sete   al
   2795d:	cmp    rdx,0xffffffffffffffff
   27961:	sete   cl
   27964:	or     cl,al
   27966:	mov    rax,rdx
   27969:	movabs rdx,0xfffffffe00
   27973:	and    rax,rdx
   27976:	cmp    rax,0x3108200
   2797c:	setb   al
   2797f:	or     al,cl
   27981:	jne    27995 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7a55>
   27983:	mov    rdi,r12
   27986:	mov    rsi,QWORD PTR [rsp+0x8]
   2798b:	mov    rdx,QWORD PTR [rsp+0x28]
   27990:	call   e8c0 <term_drop>
   27995:	test   r13,rbx
   27998:	sete   al
   2799b:	cmp    r13,0xffffffffffffffff
   2799f:	sete   cl
   279a2:	or     cl,al
   279a4:	mov    rax,r13
   279a7:	movabs rdx,0xfffffffe00
   279b1:	and    rax,rdx
   279b4:	cmp    rax,0x3108200
   279ba:	setb   al
   279bd:	or     al,cl
   279bf:	jne    279d1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7a91>
   279c1:	mov    rdi,r12
   279c4:	mov    rsi,QWORD PTR [rsp+0x8]
   279c9:	mov    rdx,r13
   279cc:	call   e8c0 <term_drop>
   279d1:	test   r14,rbx
   279d4:	sete   al
   279d7:	cmp    r14,0xffffffffffffffff
   279db:	sete   cl
   279de:	or     cl,al
   279e0:	mov    rax,r14
   279e3:	movabs rdx,0xfffffffe00
   279ed:	and    rax,rdx
   279f0:	cmp    rax,0x3108200
   279f6:	setb   al
   279f9:	or     al,cl
   279fb:	jne    27a0d <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7acd>
   279fd:	mov    rdi,r12
   27a00:	mov    rsi,QWORD PTR [rsp+0x8]
   27a05:	mov    rdx,r14
   27a08:	call   e8c0 <term_drop>
   27a0d:	mov    rdx,QWORD PTR [rsp+0x18]
   27a12:	test   rdx,rbx
   27a15:	sete   al
   27a18:	cmp    rdx,0xffffffffffffffff
   27a1c:	sete   cl
   27a1f:	or     cl,al
   27a21:	mov    rax,rdx
   27a24:	movabs rdx,0xfffffffe00
   27a2e:	and    rax,rdx
   27a31:	cmp    rax,0x3108200
   27a37:	setb   al
   27a3a:	or     al,cl
   27a3c:	jne    27a50 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7b10>
   27a3e:	mov    rdi,r12
   27a41:	mov    rsi,QWORD PTR [rsp+0x8]
   27a46:	mov    rdx,QWORD PTR [rsp+0x18]
   27a4b:	call   e8c0 <term_drop>
   27a50:	test   r15,rbx
   27a53:	sete   al
   27a56:	cmp    r15,0xffffffffffffffff
   27a5a:	sete   cl
   27a5d:	or     cl,al
   27a5f:	mov    rax,r15
   27a62:	movabs rdx,0xfffffffe00
   27a6c:	and    rax,rdx
   27a6f:	cmp    rax,0x3108200
   27a75:	setb   al
   27a78:	or     al,cl
   27a7a:	jne    27a8c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7b4c>
   27a7c:	mov    rdi,r12
   27a7f:	mov    rsi,QWORD PTR [rsp+0x8]
   27a84:	mov    rdx,r15
   27a87:	call   e8c0 <term_drop>
   27a8c:	mov    rdx,QWORD PTR [rsp+0x48]
   27a91:	test   rdx,rbx
   27a94:	sete   al
   27a97:	cmp    rdx,0xffffffffffffffff
   27a9b:	sete   cl
   27a9e:	or     cl,al
   27aa0:	movabs rax,0xfffffffe00
   27aaa:	and    rax,rdx
   27aad:	cmp    rax,0x3108200
   27ab3:	setb   al
   27ab6:	or     al,cl
   27ab8:	jne    27acc <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7b8c>
   27aba:	mov    rdi,r12
   27abd:	mov    rsi,QWORD PTR [rsp+0x8]
   27ac2:	mov    rdx,QWORD PTR [rsp+0x48]
   27ac7:	call   e8c0 <term_drop>
   27acc:	cmp    DWORD PTR [rsp+0x14],0x0
   27ad1:	jne    28650 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8710>
   27ad7:	mov    r14,QWORD PTR [rsp+0x20]
   27adc:	mov    rcx,QWORD PTR [r14-0x18]
   27ae0:	lea    rbx,[r14-0x10]
   27ae4:	mov    r8d,DWORD PTR [r14-0x10]
   27ae8:	mov    rdi,r12
   27aeb:	mov    rsi,QWORD PTR [rsp+0x8]
   27af0:	mov    edx,0xbd
   27af5:	mov    r9d,0x1
   27afb:	call   ed60 <task_node>
   27b00:	mov    rcx,QWORD PTR [rsp+0x50]
   27b05:	mov    QWORD PTR [r12+rax*8],rcx
   27b09:	movabs rcx,0x500bd0000000000
   27b13:	jmp    287ec <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x88ac>
   27b18:	mov    r15,r8
   27b1b:	movabs rbx,0x7e00000000000000
   27b25:	mov    rsi,QWORD PTR [rsp+0x30]
   27b2a:	test   rsi,rbx
   27b2d:	sete   al
   27b30:	cmp    rsi,0xffffffffffffffff
   27b34:	sete   cl
   27b37:	or     cl,al
   27b39:	mov    rax,rsi
   27b3c:	and    rax,rdi
   27b3f:	cmp    rax,0x3108200
   27b45:	setb   al
   27b48:	or     al,cl
   27b4a:	jne    27b5c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7c1c>
   27b4c:	mov    rdx,rsi
   27b4f:	mov    rdi,r12
   27b52:	mov    rsi,QWORD PTR [rsp+0x8]
   27b57:	call   e8c0 <term_drop>
   27b5c:	mov    rdx,QWORD PTR [rsp+0x18]
   27b61:	test   rdx,rbx
   27b64:	sete   al
   27b67:	cmp    rdx,0xffffffffffffffff
   27b6b:	sete   cl
   27b6e:	or     cl,al
   27b70:	movabs rax,0xfffffffe00
   27b7a:	and    rax,rdx
   27b7d:	cmp    rax,0x3108200
   27b83:	setb   al
   27b86:	or     al,cl
   27b88:	jne    27b9c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7c5c>
   27b8a:	mov    rdi,r12
   27b8d:	mov    rsi,QWORD PTR [rsp+0x8]
   27b92:	mov    rdx,QWORD PTR [rsp+0x18]
   27b97:	call   e8c0 <term_drop>
   27b9c:	cmp    DWORD PTR [rsp+0x14],0x0
   27ba1:	jne    28807 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x88c7>
   27ba7:	mov    r14,QWORD PTR [rsp+0x20]
   27bac:	mov    rcx,QWORD PTR [r14-0x18]
   27bb0:	lea    rbx,[r14-0x10]
   27bb4:	mov    r8d,DWORD PTR [r14-0x10]
   27bb8:	mov    rdi,r12
   27bbb:	mov    rsi,QWORD PTR [rsp+0x8]
   27bc0:	mov    edx,0xa1
   27bc5:	mov    r9d,0x1
   27bcb:	call   ed60 <task_node>
   27bd0:	mov    QWORD PTR [r12+rax*8],r15
   27bd4:	movabs rcx,0x500a10000000000
   27bde:	jmp    287ec <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x88ac>
   27be3:	mov    r15,r8
   27be6:	movabs rbx,0x7e00000000000000
   27bf0:	mov    rsi,QWORD PTR [rsp+0x30]
   27bf5:	test   rsi,rbx
   27bf8:	sete   al
   27bfb:	cmp    rsi,0xffffffffffffffff
   27bff:	sete   cl
   27c02:	or     cl,al
   27c04:	mov    rax,rsi
   27c07:	and    rax,rdi
   27c0a:	cmp    rax,0x3108200
   27c10:	setb   al
   27c13:	or     al,cl
   27c15:	jne    27c27 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7ce7>
   27c17:	mov    rdx,rsi
   27c1a:	mov    rdi,r12
   27c1d:	mov    rsi,QWORD PTR [rsp+0x8]
   27c22:	call   e8c0 <term_drop>
   27c27:	test   r14,rbx
   27c2a:	sete   al
   27c2d:	cmp    r14,0xffffffffffffffff
   27c31:	sete   cl
   27c34:	or     cl,al
   27c36:	mov    rax,r14
   27c39:	movabs rdx,0xfffffffe00
   27c43:	and    rax,rdx
   27c46:	cmp    rax,0x3108200
   27c4c:	setb   al
   27c4f:	or     al,cl
   27c51:	jne    27c63 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7d23>
   27c53:	mov    rdi,r12
   27c56:	mov    rsi,QWORD PTR [rsp+0x8]
   27c5b:	mov    rdx,r14
   27c5e:	call   e8c0 <term_drop>
   27c63:	mov    rdx,QWORD PTR [rsp+0x28]
   27c68:	test   rdx,rbx
   27c6b:	sete   al
   27c6e:	cmp    rdx,0xffffffffffffffff
   27c72:	sete   cl
   27c75:	or     cl,al
   27c77:	mov    rax,rdx
   27c7a:	movabs rdx,0xfffffffe00
   27c84:	and    rax,rdx
   27c87:	cmp    rax,0x3108200
   27c8d:	setb   al
   27c90:	or     al,cl
   27c92:	jne    27ca6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7d66>
   27c94:	mov    rdi,r12
   27c97:	mov    rsi,QWORD PTR [rsp+0x8]
   27c9c:	mov    rdx,QWORD PTR [rsp+0x28]
   27ca1:	call   e8c0 <term_drop>
   27ca6:	mov    rdx,QWORD PTR [rsp+0x18]
   27cab:	test   rdx,rbx
   27cae:	sete   al
   27cb1:	cmp    rdx,0xffffffffffffffff
   27cb5:	sete   cl
   27cb8:	or     cl,al
   27cba:	movabs rax,0xfffffffe00
   27cc4:	and    rax,rdx
   27cc7:	cmp    rax,0x3108200
   27ccd:	setb   al
   27cd0:	or     al,cl
   27cd2:	jne    27ce6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7da6>
   27cd4:	mov    rdi,r12
   27cd7:	mov    rsi,QWORD PTR [rsp+0x8]
   27cdc:	mov    rdx,QWORD PTR [rsp+0x18]
   27ce1:	call   e8c0 <term_drop>
   27ce6:	cmp    DWORD PTR [rsp+0x14],0x0
   27ceb:	jne    28827 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x88e7>
   27cf1:	mov    r14,QWORD PTR [rsp+0x20]
   27cf6:	mov    rcx,QWORD PTR [r14-0x18]
   27cfa:	lea    rbx,[r14-0x10]
   27cfe:	mov    r8d,DWORD PTR [r14-0x10]
   27d02:	mov    rdi,r12
   27d05:	mov    rsi,QWORD PTR [rsp+0x8]
   27d0a:	mov    edx,0xac
   27d0f:	mov    r9d,0x1
   27d15:	call   ed60 <task_node>
   27d1a:	mov    QWORD PTR [r12+rax*8],r15
   27d1e:	movabs rcx,0x500ac0000000000
   27d28:	jmp    287ec <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x88ac>
   27d2d:	mov    r13,r9
   27d30:	mov    r15,r8
   27d33:	movabs rbx,0x7e00000000000000
   27d3d:	mov    rsi,QWORD PTR [rsp+0x30]
   27d42:	test   rsi,rbx
   27d45:	sete   al
   27d48:	cmp    rsi,0xffffffffffffffff
   27d4c:	sete   cl
   27d4f:	or     cl,al
   27d51:	mov    rax,rsi
   27d54:	and    rax,rdi
   27d57:	cmp    rax,0x3108200
   27d5d:	setb   al
   27d60:	or     al,cl
   27d62:	jne    27d74 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7e34>
   27d64:	mov    rdx,rsi
   27d67:	mov    rdi,r12
   27d6a:	mov    rsi,QWORD PTR [rsp+0x8]
   27d6f:	call   e8c0 <term_drop>
   27d74:	mov    rdx,QWORD PTR [rsp+0x28]
   27d79:	test   rdx,rbx
   27d7c:	sete   al
   27d7f:	cmp    rdx,0xffffffffffffffff
   27d83:	sete   cl
   27d86:	or     cl,al
   27d88:	mov    rax,rdx
   27d8b:	movabs rdx,0xfffffffe00
   27d95:	and    rax,rdx
   27d98:	cmp    rax,0x3108200
   27d9e:	setb   al
   27da1:	or     al,cl
   27da3:	jne    27db7 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7e77>
   27da5:	mov    rdi,r12
   27da8:	mov    rsi,QWORD PTR [rsp+0x8]
   27dad:	mov    rdx,QWORD PTR [rsp+0x28]
   27db2:	call   e8c0 <term_drop>
   27db7:	test   r13,rbx
   27dba:	sete   al
   27dbd:	cmp    r13,0xffffffffffffffff
   27dc1:	sete   cl
   27dc4:	or     cl,al
   27dc6:	mov    rax,r13
   27dc9:	movabs rdx,0xfffffffe00
   27dd3:	and    rax,rdx
   27dd6:	cmp    rax,0x3108200
   27ddc:	setb   al
   27ddf:	or     al,cl
   27de1:	jne    27df3 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7eb3>
   27de3:	mov    rdi,r12
   27de6:	mov    rsi,QWORD PTR [rsp+0x8]
   27deb:	mov    rdx,r13
   27dee:	call   e8c0 <term_drop>
   27df3:	test   r14,rbx
   27df6:	sete   al
   27df9:	cmp    r14,0xffffffffffffffff
   27dfd:	sete   cl
   27e00:	or     cl,al
   27e02:	mov    rax,r14
   27e05:	movabs rdx,0xfffffffe00
   27e0f:	and    rax,rdx
   27e12:	cmp    rax,0x3108200
   27e18:	setb   al
   27e1b:	or     al,cl
   27e1d:	jne    27e2f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7eef>
   27e1f:	mov    rdi,r12
   27e22:	mov    rsi,QWORD PTR [rsp+0x8]
   27e27:	mov    rdx,r14
   27e2a:	call   e8c0 <term_drop>
   27e2f:	mov    rdx,QWORD PTR [rsp+0x18]
   27e34:	test   rdx,rbx
   27e37:	sete   al
   27e3a:	cmp    rdx,0xffffffffffffffff
   27e3e:	sete   cl
   27e41:	or     cl,al
   27e43:	movabs rax,0xfffffffe00
   27e4d:	and    rax,rdx
   27e50:	cmp    rax,0x3108200
   27e56:	setb   al
   27e59:	or     al,cl
   27e5b:	jne    27e6f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7f2f>
   27e5d:	mov    rdi,r12
   27e60:	mov    rsi,QWORD PTR [rsp+0x8]
   27e65:	mov    rdx,QWORD PTR [rsp+0x18]
   27e6a:	call   e8c0 <term_drop>
   27e6f:	cmp    DWORD PTR [rsp+0x14],0x0
   27e74:	jne    28847 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8907>
   27e7a:	mov    r14,QWORD PTR [rsp+0x20]
   27e7f:	mov    rcx,QWORD PTR [r14-0x18]
   27e83:	lea    rbx,[r14-0x10]
   27e87:	mov    r8d,DWORD PTR [r14-0x10]
   27e8b:	mov    rdi,r12
   27e8e:	mov    rsi,QWORD PTR [rsp+0x8]
   27e93:	mov    edx,0xb9
   27e98:	mov    r9d,0x1
   27e9e:	call   ed60 <task_node>
   27ea3:	mov    QWORD PTR [r12+rax*8],r15
   27ea7:	movabs rcx,0x500b90000000000
   27eb1:	jmp    287ec <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x88ac>
   27eb6:	mov    r15,rsi
   27eb9:	mov    r13,r9
   27ebc:	mov    QWORD PTR [rsp+0x50],r8
   27ec1:	movabs rbx,0x7e00000000000000
   27ecb:	mov    rsi,QWORD PTR [rsp+0x30]
   27ed0:	test   rsi,rbx
   27ed3:	sete   al
   27ed6:	cmp    rsi,0xffffffffffffffff
   27eda:	sete   cl
   27edd:	or     cl,al
   27edf:	mov    rax,rsi
   27ee2:	and    rax,rdi
   27ee5:	cmp    rax,0x3108200
   27eeb:	setb   al
   27eee:	or     al,cl
   27ef0:	jne    27f02 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x7fc2>
   27ef2:	mov    rdx,rsi
   27ef5:	mov    rdi,r12
   27ef8:	mov    rsi,QWORD PTR [rsp+0x8]
   27efd:	call   e8c0 <term_drop>
   27f02:	mov    rdx,QWORD PTR [rsp+0x28]
   27f07:	test   rdx,rbx
   27f0a:	sete   al
   27f0d:	cmp    rdx,0xffffffffffffffff
   27f11:	sete   cl
   27f14:	or     cl,al
   27f16:	mov    rax,rdx
   27f19:	movabs rdx,0xfffffffe00
   27f23:	and    rax,rdx
   27f26:	cmp    rax,0x3108200
   27f2c:	setb   al
   27f2f:	or     al,cl
   27f31:	jne    27f45 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8005>
   27f33:	mov    rdi,r12
   27f36:	mov    rsi,QWORD PTR [rsp+0x8]
   27f3b:	mov    rdx,QWORD PTR [rsp+0x28]
   27f40:	call   e8c0 <term_drop>
   27f45:	test   r13,rbx
   27f48:	sete   al
   27f4b:	cmp    r13,0xffffffffffffffff
   27f4f:	sete   cl
   27f52:	or     cl,al
   27f54:	mov    rax,r13
   27f57:	movabs rdx,0xfffffffe00
   27f61:	and    rax,rdx
   27f64:	cmp    rax,0x3108200
   27f6a:	setb   al
   27f6d:	or     al,cl
   27f6f:	jne    27f81 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8041>
   27f71:	mov    rdi,r12
   27f74:	mov    rsi,QWORD PTR [rsp+0x8]
   27f79:	mov    rdx,r13
   27f7c:	call   e8c0 <term_drop>
   27f81:	test   r14,rbx
   27f84:	sete   al
   27f87:	cmp    r14,0xffffffffffffffff
   27f8b:	sete   cl
   27f8e:	or     cl,al
   27f90:	mov    rax,r14
   27f93:	movabs rdx,0xfffffffe00
   27f9d:	and    rax,rdx
   27fa0:	cmp    rax,0x3108200
   27fa6:	setb   al
   27fa9:	or     al,cl
   27fab:	jne    27fbd <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x807d>
   27fad:	mov    rdi,r12
   27fb0:	mov    rsi,QWORD PTR [rsp+0x8]
   27fb5:	mov    rdx,r14
   27fb8:	call   e8c0 <term_drop>
   27fbd:	mov    rdx,QWORD PTR [rsp+0x18]
   27fc2:	test   rdx,rbx
   27fc5:	sete   al
   27fc8:	cmp    rdx,0xffffffffffffffff
   27fcc:	sete   cl
   27fcf:	or     cl,al
   27fd1:	mov    rax,rdx
   27fd4:	movabs rdx,0xfffffffe00
   27fde:	and    rax,rdx
   27fe1:	cmp    rax,0x3108200
   27fe7:	setb   al
   27fea:	or     al,cl
   27fec:	jne    28000 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x80c0>
   27fee:	mov    rdi,r12
   27ff1:	mov    rsi,QWORD PTR [rsp+0x8]
   27ff6:	mov    rdx,QWORD PTR [rsp+0x18]
   27ffb:	call   e8c0 <term_drop>
   28000:	test   rbp,rbx
   28003:	sete   al
   28006:	cmp    rbp,0xffffffffffffffff
   2800a:	sete   cl
   2800d:	or     cl,al
   2800f:	mov    rax,rbp
   28012:	movabs rdx,0xfffffffe00
   2801c:	and    rax,rdx
   2801f:	cmp    rax,0x3108200
   28025:	setb   al
   28028:	or     al,cl
   2802a:	jne    2803c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x80fc>
   2802c:	mov    rdi,r12
   2802f:	mov    rsi,QWORD PTR [rsp+0x8]
   28034:	mov    rdx,rbp
   28037:	call   e8c0 <term_drop>
   2803c:	mov    rdx,QWORD PTR [rsp+0x38]
   28041:	test   rdx,rbx
   28044:	sete   al
   28047:	cmp    rdx,0xffffffffffffffff
   2804b:	sete   cl
   2804e:	or     cl,al
   28050:	mov    rax,rdx
   28053:	movabs rdx,0xfffffffe00
   2805d:	and    rax,rdx
   28060:	cmp    rax,0x3108200
   28066:	setb   al
   28069:	or     al,cl
   2806b:	jne    2807f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x813f>
   2806d:	mov    rdi,r12
   28070:	mov    rsi,QWORD PTR [rsp+0x8]
   28075:	mov    rdx,QWORD PTR [rsp+0x38]
   2807a:	call   e8c0 <term_drop>
   2807f:	test   r15,rbx
   28082:	sete   al
   28085:	cmp    r15,0xffffffffffffffff
   28089:	sete   cl
   2808c:	or     cl,al
   2808e:	movabs rax,0xfffffffe00
   28098:	and    rax,r15
   2809b:	cmp    rax,0x3108200
   280a1:	setb   al
   280a4:	or     al,cl
   280a6:	jne    280b8 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8178>
   280a8:	mov    rdi,r12
   280ab:	mov    rsi,QWORD PTR [rsp+0x8]
   280b0:	mov    rdx,r15
   280b3:	call   e8c0 <term_drop>
   280b8:	cmp    DWORD PTR [rsp+0x14],0x0
   280bd:	jne    28867 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8927>
   280c3:	mov    r14,QWORD PTR [rsp+0x20]
   280c8:	mov    rcx,QWORD PTR [r14-0x18]
   280cc:	lea    rbx,[r14-0x10]
   280d0:	mov    r8d,DWORD PTR [r14-0x10]
   280d4:	mov    rdi,r12
   280d7:	mov    rsi,QWORD PTR [rsp+0x8]
   280dc:	mov    edx,0xc3
   280e1:	mov    r9d,0x1
   280e7:	call   ed60 <task_node>
   280ec:	mov    rcx,QWORD PTR [rsp+0x50]
   280f1:	mov    QWORD PTR [r12+rax*8],rcx
   280f5:	movabs rcx,0x500c30000000000
   280ff:	jmp    287ec <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x88ac>
   28104:	mov    r13,r15
   28107:	mov    r15,r8
   2810a:	movabs r14,0x7e00000000000000
   28114:	mov    rsi,QWORD PTR [rsp+0x30]
   28119:	test   rsi,r14
   2811c:	sete   al
   2811f:	cmp    rsi,0xffffffffffffffff
   28123:	sete   cl
   28126:	or     cl,al
   28128:	mov    rax,rsi
   2812b:	and    rax,rdi
   2812e:	cmp    rax,0x3108200
   28134:	setb   al
   28137:	or     al,cl
   28139:	jne    2814b <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x820b>
   2813b:	mov    rdx,rsi
   2813e:	mov    rdi,r12
   28141:	mov    rsi,QWORD PTR [rsp+0x8]
   28146:	call   e8c0 <term_drop>
   2814b:	mov    rdx,QWORD PTR [rsp+0x18]
   28150:	test   rdx,r14
   28153:	sete   al
   28156:	cmp    rdx,0xffffffffffffffff
   2815a:	sete   cl
   2815d:	or     cl,al
   2815f:	mov    rax,rdx
   28162:	movabs rdx,0xfffffffe00
   2816c:	and    rax,rdx
   2816f:	cmp    rax,0x3108200
   28175:	setb   al
   28178:	or     al,cl
   2817a:	jne    2818e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x824e>
   2817c:	mov    rdi,r12
   2817f:	mov    rsi,QWORD PTR [rsp+0x8]
   28184:	mov    rdx,QWORD PTR [rsp+0x18]
   28189:	call   e8c0 <term_drop>
   2818e:	test   rbx,r14
   28191:	sete   al
   28194:	cmp    rbx,0xffffffffffffffff
   28198:	sete   cl
   2819b:	or     cl,al
   2819d:	mov    rax,rbx
   281a0:	movabs rdx,0xfffffffe00
   281aa:	and    rax,rdx
   281ad:	cmp    rax,0x3108200
   281b3:	setb   al
   281b6:	or     al,cl
   281b8:	jne    281ca <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x828a>
   281ba:	mov    rdi,r12
   281bd:	mov    rsi,QWORD PTR [rsp+0x8]
   281c2:	mov    rdx,rbx
   281c5:	call   e8c0 <term_drop>
   281ca:	test   r13,r14
   281cd:	sete   al
   281d0:	cmp    r13,0xffffffffffffffff
   281d4:	sete   cl
   281d7:	or     cl,al
   281d9:	movabs rax,0xfffffffe00
   281e3:	and    rax,r13
   281e6:	cmp    rax,0x3108200
   281ec:	setb   al
   281ef:	or     al,cl
   281f1:	jne    28203 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x82c3>
   281f3:	mov    rdi,r12
   281f6:	mov    rsi,QWORD PTR [rsp+0x8]
   281fb:	mov    rdx,r13
   281fe:	call   e8c0 <term_drop>
   28203:	cmp    DWORD PTR [rsp+0x14],0x0
   28208:	jne    2888c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x894c>
   2820e:	mov    r14,QWORD PTR [rsp+0x20]
   28213:	mov    rcx,QWORD PTR [r14-0x18]
   28217:	lea    rbx,[r14-0x10]
   2821b:	mov    r8d,DWORD PTR [r14-0x10]
   2821f:	mov    rdi,r12
   28222:	mov    rsi,QWORD PTR [rsp+0x8]
   28227:	mov    edx,0xa3
   2822c:	mov    r9d,0x1
   28232:	call   ed60 <task_node>
   28237:	mov    QWORD PTR [r12+rax*8],r15
   2823b:	movabs rcx,0x500a30000000000
   28245:	jmp    287ec <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x88ac>
   2824a:	mov    r13,r15
   2824d:	mov    r14,rsi
   28250:	mov    r15,r8
   28253:	movabs rbx,0x7e00000000000000
   2825d:	mov    rsi,QWORD PTR [rsp+0x30]
   28262:	test   rsi,rbx
   28265:	sete   al
   28268:	cmp    rsi,0xffffffffffffffff
   2826c:	sete   cl
   2826f:	or     cl,al
   28271:	mov    rax,rsi
   28274:	and    rax,rdi
   28277:	cmp    rax,0x3108200
   2827d:	setb   al
   28280:	or     al,cl
   28282:	jne    28294 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8354>
   28284:	mov    rdx,rsi
   28287:	mov    rdi,r12
   2828a:	mov    rsi,QWORD PTR [rsp+0x8]
   2828f:	call   e8c0 <term_drop>
   28294:	mov    rdx,QWORD PTR [rsp+0x18]
   28299:	test   rdx,rbx
   2829c:	sete   al
   2829f:	cmp    rdx,0xffffffffffffffff
   282a3:	sete   cl
   282a6:	or     cl,al
   282a8:	mov    rax,rdx
   282ab:	movabs rdx,0xfffffffe00
   282b5:	and    rax,rdx
   282b8:	cmp    rax,0x3108200
   282be:	setb   al
   282c1:	or     al,cl
   282c3:	jne    282d7 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8397>
   282c5:	mov    rdi,r12
   282c8:	mov    rsi,QWORD PTR [rsp+0x8]
   282cd:	mov    rdx,QWORD PTR [rsp+0x18]
   282d2:	call   e8c0 <term_drop>
   282d7:	test   r14,rbx
   282da:	sete   al
   282dd:	cmp    r14,0xffffffffffffffff
   282e1:	sete   cl
   282e4:	or     cl,al
   282e6:	mov    rax,r14
   282e9:	movabs rdx,0xfffffffe00
   282f3:	and    rax,rdx
   282f6:	cmp    rax,0x3108200
   282fc:	setb   al
   282ff:	or     al,cl
   28301:	jne    28313 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x83d3>
   28303:	mov    rdi,r12
   28306:	mov    rsi,QWORD PTR [rsp+0x8]
   2830b:	mov    rdx,r14
   2830e:	call   e8c0 <term_drop>
   28313:	test   r13,rbx
   28316:	sete   al
   28319:	cmp    r13,0xffffffffffffffff
   2831d:	sete   cl
   28320:	or     cl,al
   28322:	mov    rax,r13
   28325:	movabs rdx,0xfffffffe00
   2832f:	and    rax,rdx
   28332:	cmp    rax,0x3108200
   28338:	setb   al
   2833b:	or     al,cl
   2833d:	jne    2834f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x840f>
   2833f:	mov    rdi,r12
   28342:	mov    rsi,QWORD PTR [rsp+0x8]
   28347:	mov    rdx,r13
   2834a:	call   e8c0 <term_drop>
   2834f:	mov    rdx,QWORD PTR [rsp+0x28]
   28354:	test   rdx,rbx
   28357:	sete   al
   2835a:	cmp    rdx,0xffffffffffffffff
   2835e:	sete   cl
   28361:	or     cl,al
   28363:	movabs rax,0xfffffffe00
   2836d:	and    rax,rdx
   28370:	cmp    rax,0x3108200
   28376:	setb   al
   28379:	or     al,cl
   2837b:	jne    2838f <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x844f>
   2837d:	mov    rdi,r12
   28380:	mov    rsi,QWORD PTR [rsp+0x8]
   28385:	mov    rdx,QWORD PTR [rsp+0x28]
   2838a:	call   e8c0 <term_drop>
   2838f:	cmp    DWORD PTR [rsp+0x14],0x0
   28394:	jne    288ac <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x896c>
   2839a:	mov    r14,QWORD PTR [rsp+0x20]
   2839f:	mov    rcx,QWORD PTR [r14-0x18]
   283a3:	lea    rbx,[r14-0x10]
   283a7:	mov    r8d,DWORD PTR [r14-0x10]
   283ab:	mov    rdi,r12
   283ae:	mov    rsi,QWORD PTR [rsp+0x8]
   283b3:	mov    edx,0xa7
   283b8:	mov    r9d,0x1
   283be:	call   ed60 <task_node>
   283c3:	mov    QWORD PTR [r12+rax*8],r15
   283c7:	movabs rcx,0x500a70000000000
   283d1:	jmp    287ec <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x88ac>
   283d6:	mov    rbx,QWORD PTR [rsp+0x20]
   283db:	mov    rax,QWORD PTR [rsp+0x50]
   283e0:	mov    QWORD PTR [rbx],rax
   283e3:	mov    QWORD PTR [rbx+0x8],0xb3
   283eb:	mov    rax,QWORD PTR [rsp+0x18]
   283f0:	mov    QWORD PTR [rbx+0x10],rax
   283f4:	mov    QWORD PTR [rbx+0x18],0xb4
   283fc:	mov    QWORD PTR [rbx+0x20],r15
   28400:	add    rbx,0x28
   28404:	mov    eax,0xb5
   28409:	mov    QWORD PTR [rbx],rax
   2840c:	lea    rdi,[rip+0xfffffffffffddaad]        # 5ec0 <FID_RESW_T+0x510>
   28413:	call   5e1d0 <err_fail>
   28418:	mov    rbx,QWORD PTR [rsp+0x20]
   2841d:	mov    rax,QWORD PTR [rsp+0x50]
   28422:	mov    QWORD PTR [rbx],rax
   28425:	mov    QWORD PTR [rbx+0x8],0xc4
   2842d:	mov    rax,QWORD PTR [rsp+0x18]
   28432:	mov    QWORD PTR [rbx+0x10],rax
   28436:	mov    QWORD PTR [rbx+0x18],0xc5
   2843e:	mov    QWORD PTR [rbx+0x20],r15
   28442:	add    rbx,0x28
   28446:	mov    eax,0xc6
   2844b:	mov    QWORD PTR [rbx],rax
   2844e:	lea    rdi,[rip+0xfffffffffffdda6b]        # 5ec0 <FID_RESW_T+0x510>
   28455:	call   5e1d0 <err_fail>
   2845a:	mov    rbx,QWORD PTR [rsp+0x20]
   2845f:	mov    rax,QWORD PTR [rsp+0x50]
   28464:	mov    QWORD PTR [rbx],rax
   28467:	mov    QWORD PTR [rbx+0x8],0xa8
   2846f:	mov    rax,QWORD PTR [rsp+0x18]
   28474:	mov    QWORD PTR [rbx+0x10],rax
   28478:	mov    QWORD PTR [rbx+0x18],0xa9
   28480:	mov    QWORD PTR [rbx+0x20],r15
   28484:	add    rbx,0x28
   28488:	mov    eax,0xaa
   2848d:	mov    QWORD PTR [rbx],rax
   28490:	lea    rdi,[rip+0xfffffffffffdda29]        # 5ec0 <FID_RESW_T+0x510>
   28497:	call   5e1d0 <err_fail>
   2849c:	movabs rax,0x7e00000000000000
   284a6:	test   r15,rax
   284a9:	sete   al
   284ac:	cmp    r15,0xffffffffffffffff
   284b0:	sete   cl
   284b3:	or     cl,al
   284b5:	mov    rdx,r15
   284b8:	and    r15,rdi
   284bb:	cmp    r15,0x3108200
   284c2:	setb   al
   284c5:	or     al,cl
   284c7:	jne    284d6 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8596>
   284c9:	mov    rdi,r12
   284cc:	mov    rsi,QWORD PTR [rsp+0x8]
   284d1:	call   e8c0 <term_drop>
   284d6:	movabs rax,0x7e00000000000000
   284e0:	test   r14,rax
   284e3:	sete   al
   284e6:	cmp    r14,0xffffffffffffffff
   284ea:	sete   cl
   284ed:	or     cl,al
   284ef:	mov    rax,r14
   284f2:	movabs rdx,0xfffffffe00
   284fc:	and    rax,rdx
   284ff:	cmp    rax,0x3108200
   28505:	setb   al
   28508:	or     al,cl
   2850a:	jne    2851c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x85dc>
   2850c:	mov    rdi,r12
   2850f:	mov    rsi,QWORD PTR [rsp+0x8]
   28514:	mov    rdx,r14
   28517:	call   e8c0 <term_drop>
   2851c:	mov    rdx,QWORD PTR [rsp+0x28]
   28521:	movabs rax,0x7e00000000000000
   2852b:	test   rdx,rax
   2852e:	sete   al
   28531:	cmp    rdx,0xffffffffffffffff
   28535:	sete   cl
   28538:	or     cl,al
   2853a:	mov    rax,rdx
   2853d:	movabs rdx,0xfffffffe00
   28547:	and    rax,rdx
   2854a:	cmp    rax,0x3108200
   28550:	setb   al
   28553:	or     al,cl
   28555:	jne    28569 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8629>
   28557:	mov    rdi,r12
   2855a:	mov    rsi,QWORD PTR [rsp+0x8]
   2855f:	mov    rdx,QWORD PTR [rsp+0x28]
   28564:	call   e8c0 <term_drop>
   28569:	mov    rdx,QWORD PTR [rsp+0x18]
   2856e:	movabs rax,0x7e00000000000000
   28578:	test   rdx,rax
   2857b:	sete   al
   2857e:	cmp    rdx,0xffffffffffffffff
   28582:	sete   cl
   28585:	or     cl,al
   28587:	movabs rax,0xfffffffe00
   28591:	and    rax,rdx
   28594:	cmp    rax,0x3108200
   2859a:	setb   al
   2859d:	or     al,cl
   2859f:	jne    285b3 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8673>
   285a1:	mov    rdi,r12
   285a4:	mov    rsi,QWORD PTR [rsp+0x8]
   285a9:	mov    rdx,QWORD PTR [rsp+0x18]
   285ae:	call   e8c0 <term_drop>
   285b3:	cmp    DWORD PTR [rsp+0x14],0x0
   285b8:	jne    28de9 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8ea9>
   285be:	mov    r15,QWORD PTR [rsp+0x20]
   285c3:	mov    rcx,QWORD PTR [r15-0x18]
   285c7:	lea    r14,[r15-0x10]
   285cb:	mov    r8d,DWORD PTR [r15-0x10]
   285cf:	mov    rdi,r12
   285d2:	mov    rsi,QWORD PTR [rsp+0x8]
   285d7:	mov    edx,0xab
   285dc:	mov    r9d,0x1
   285e2:	call   ed60 <task_node>
   285e7:	mov    QWORD PTR [r12+rax*8],rbx
   285eb:	movabs rcx,0x500ab0000000000
   285f5:	or     rcx,rax
   285f8:	mov    QWORD PTR [r15-0x18],rcx
   285fc:	mov    eax,0x1
   28601:	mov    QWORD PTR [r14],rax
   28604:	lea    rdi,[rip+0xfffffffffffdd8b5]        # 5ec0 <FID_RESW_T+0x510>
   2860b:	call   5e1d0 <err_fail>
   28610:	mov    rbx,QWORD PTR [rsp+0x20]
   28615:	mov    QWORD PTR [rbx],r15
   28618:	add    rbx,0x8
   2861c:	mov    eax,0xae
   28621:	mov    QWORD PTR [rbx],rax
   28624:	lea    rdi,[rip+0xfffffffffffdd895]        # 5ec0 <FID_RESW_T+0x510>
   2862b:	call   5e1d0 <err_fail>
   28630:	mov    rbx,QWORD PTR [rsp+0x20]
   28635:	mov    QWORD PTR [rbx],r15
   28638:	add    rbx,0x8
   2863c:	mov    eax,0xb2
   28641:	mov    QWORD PTR [rbx],rax
   28644:	lea    rdi,[rip+0xfffffffffffdd875]        # 5ec0 <FID_RESW_T+0x510>
   2864b:	call   5e1d0 <err_fail>
   28650:	mov    rbx,QWORD PTR [rsp+0x20]
   28655:	mov    rax,QWORD PTR [rsp+0x50]
   2865a:	mov    QWORD PTR [rbx],rax
   2865d:	add    rbx,0x8
   28661:	mov    eax,0xbd
   28666:	mov    QWORD PTR [rbx],rax
   28669:	lea    rdi,[rip+0xfffffffffffdd850]        # 5ec0 <FID_RESW_T+0x510>
   28670:	call   5e1d0 <err_fail>
   28675:	mov    rbx,r9
   28678:	mov    rsi,QWORD PTR [rsp+0x30]
   2867d:	test   rsi,r14
   28680:	sete   al
   28683:	cmp    rsi,0xffffffffffffffff
   28687:	sete   cl
   2868a:	or     cl,al
   2868c:	mov    rax,rsi
   2868f:	and    rax,rdi
   28692:	cmp    rax,0x3108200
   28698:	setb   al
   2869b:	or     al,cl
   2869d:	jne    286af <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x876f>
   2869f:	mov    rdx,rsi
   286a2:	mov    rdi,r12
   286a5:	mov    rsi,QWORD PTR [rsp+0x8]
   286aa:	call   e8c0 <term_drop>
   286af:	mov    rdx,QWORD PTR [rsp+0x28]
   286b4:	test   rdx,r14
   286b7:	sete   al
   286ba:	cmp    rdx,0xffffffffffffffff
   286be:	sete   cl
   286c1:	or     cl,al
   286c3:	mov    rax,rdx
   286c6:	movabs rdx,0xfffffffe00
   286d0:	and    rax,rdx
   286d3:	cmp    rax,0x3108200
   286d9:	setb   al
   286dc:	or     al,cl
   286de:	jne    286f2 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x87b2>
   286e0:	mov    rdi,r12
   286e3:	mov    rsi,QWORD PTR [rsp+0x8]
   286e8:	mov    rdx,QWORD PTR [rsp+0x28]
   286ed:	call   e8c0 <term_drop>
   286f2:	test   rbx,r14
   286f5:	sete   al
   286f8:	cmp    rbx,0xffffffffffffffff
   286fc:	sete   cl
   286ff:	or     cl,al
   28701:	mov    rax,rbx
   28704:	movabs rdx,0xfffffffe00
   2870e:	and    rax,rdx
   28711:	cmp    rax,0x3108200
   28717:	setb   al
   2871a:	or     al,cl
   2871c:	jne    2872e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x87ee>
   2871e:	mov    rdi,r12
   28721:	mov    rsi,QWORD PTR [rsp+0x8]
   28726:	mov    rdx,rbx
   28729:	call   e8c0 <term_drop>
   2872e:	test   rbp,r14
   28731:	sete   al
   28734:	cmp    rbp,0xffffffffffffffff
   28738:	sete   cl
   2873b:	or     cl,al
   2873d:	mov    rax,rbp
   28740:	movabs rdx,0xfffffffe00
   2874a:	and    rax,rdx
   2874d:	cmp    rax,0x3108200
   28753:	setb   al
   28756:	or     al,cl
   28758:	jne    2876a <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x882a>
   2875a:	mov    rdi,r12
   2875d:	mov    rsi,QWORD PTR [rsp+0x8]
   28762:	mov    rdx,rbp
   28765:	call   e8c0 <term_drop>
   2876a:	mov    rdx,QWORD PTR [rsp+0x18]
   2876f:	test   rdx,r14
   28772:	sete   al
   28775:	cmp    rdx,0xffffffffffffffff
   28779:	sete   cl
   2877c:	or     cl,al
   2877e:	movabs rax,0xfffffffe00
   28788:	and    rax,rdx
   2878b:	cmp    rax,0x3108200
   28791:	setb   al
   28794:	or     al,cl
   28796:	jne    287aa <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x886a>
   28798:	mov    rdi,r12
   2879b:	mov    rsi,QWORD PTR [rsp+0x8]
   287a0:	mov    rdx,QWORD PTR [rsp+0x18]
   287a5:	call   e8c0 <term_drop>
   287aa:	cmp    DWORD PTR [rsp+0x14],0x0
   287af:	jne    28e09 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8ec9>
   287b5:	mov    r14,QWORD PTR [rsp+0x20]
   287ba:	mov    rcx,QWORD PTR [r14-0x18]
   287be:	lea    rbx,[r14-0x10]
   287c2:	mov    r8d,DWORD PTR [r14-0x10]
   287c6:	mov    rdi,r12
   287c9:	mov    rsi,QWORD PTR [rsp+0x8]
   287ce:	mov    edx,0xb8
   287d3:	mov    r9d,0x1
   287d9:	call   ed60 <task_node>
   287de:	mov    QWORD PTR [r12+rax*8],r15
   287e2:	movabs rcx,0x500b80000000000
   287ec:	or     rcx,rax
   287ef:	mov    QWORD PTR [r14-0x18],rcx
   287f3:	mov    eax,0x1
   287f8:	mov    QWORD PTR [rbx],rax
   287fb:	lea    rdi,[rip+0xfffffffffffdd6be]        # 5ec0 <FID_RESW_T+0x510>
   28802:	call   5e1d0 <err_fail>
   28807:	mov    rbx,QWORD PTR [rsp+0x20]
   2880c:	mov    QWORD PTR [rbx],r15
   2880f:	add    rbx,0x8
   28813:	mov    eax,0xa1
   28818:	mov    QWORD PTR [rbx],rax
   2881b:	lea    rdi,[rip+0xfffffffffffdd69e]        # 5ec0 <FID_RESW_T+0x510>
   28822:	call   5e1d0 <err_fail>
   28827:	mov    rbx,QWORD PTR [rsp+0x20]
   2882c:	mov    QWORD PTR [rbx],r15
   2882f:	add    rbx,0x8
   28833:	mov    eax,0xac
   28838:	mov    QWORD PTR [rbx],rax
   2883b:	lea    rdi,[rip+0xfffffffffffdd67e]        # 5ec0 <FID_RESW_T+0x510>
   28842:	call   5e1d0 <err_fail>
   28847:	mov    rbx,QWORD PTR [rsp+0x20]
   2884c:	mov    QWORD PTR [rbx],r15
   2884f:	add    rbx,0x8
   28853:	mov    eax,0xb9
   28858:	mov    QWORD PTR [rbx],rax
   2885b:	lea    rdi,[rip+0xfffffffffffdd65e]        # 5ec0 <FID_RESW_T+0x510>
   28862:	call   5e1d0 <err_fail>
   28867:	mov    rbx,QWORD PTR [rsp+0x20]
   2886c:	mov    rax,QWORD PTR [rsp+0x50]
   28871:	mov    QWORD PTR [rbx],rax
   28874:	add    rbx,0x8
   28878:	mov    eax,0xc3
   2887d:	mov    QWORD PTR [rbx],rax
   28880:	lea    rdi,[rip+0xfffffffffffdd639]        # 5ec0 <FID_RESW_T+0x510>
   28887:	call   5e1d0 <err_fail>
   2888c:	mov    rbx,QWORD PTR [rsp+0x20]
   28891:	mov    QWORD PTR [rbx],r15
   28894:	add    rbx,0x8
   28898:	mov    eax,0xa3
   2889d:	mov    QWORD PTR [rbx],rax
   288a0:	lea    rdi,[rip+0xfffffffffffdd619]        # 5ec0 <FID_RESW_T+0x510>
   288a7:	call   5e1d0 <err_fail>
   288ac:	mov    rbx,QWORD PTR [rsp+0x20]
   288b1:	mov    QWORD PTR [rbx],r15
   288b4:	add    rbx,0x8
   288b8:	mov    eax,0xa7
   288bd:	mov    QWORD PTR [rbx],rax
   288c0:	lea    rdi,[rip+0xfffffffffffdd5f9]        # 5ec0 <FID_RESW_T+0x510>
   288c7:	call   5e1d0 <err_fail>
   288cc:	mov    r15,rdx
   288cf:	mov    rdx,QWORD PTR [rsp+0x18]
   288d4:	movabs rax,0x7e00000000000000
   288de:	test   rdx,rax
   288e1:	sete   al
   288e4:	cmp    rdx,0xffffffffffffffff
   288e8:	sete   cl
   288eb:	or     cl,al
   288ed:	mov    rax,rdx
   288f0:	movabs rdx,0xfffffffe00
   288fa:	and    rax,rdx
   288fd:	cmp    rax,0x3108200
   28903:	setb   al
   28906:	or     al,cl
   28908:	jne    2891c <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x89dc>
   2890a:	mov    rdi,r12
   2890d:	mov    rsi,QWORD PTR [rsp+0x8]
   28912:	mov    rdx,QWORD PTR [rsp+0x18]
   28917:	call   e8c0 <term_drop>
   2891c:	mov    rdx,QWORD PTR [rsp+0x40]
   28921:	movabs rax,0x7e00000000000000
   2892b:	test   rdx,rax
   2892e:	sete   al
   28931:	cmp    rdx,0xffffffffffffffff
   28935:	sete   cl
   28938:	or     cl,al
   2893a:	mov    rax,rdx
   2893d:	movabs rdx,0xfffffffe00
   28947:	and    rax,rdx
   2894a:	cmp    rax,0x3108200
   28950:	setb   al
   28953:	or     al,cl
   28955:	jne    28ad3 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8b93>
   2895b:	mov    rdi,r12
   2895e:	mov    rsi,QWORD PTR [rsp+0x8]
   28963:	mov    rdx,QWORD PTR [rsp+0x40]
   28968:	jmp    28ace <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8b8e>
   2896d:	mov    r14,rdx
   28970:	movabs r15,0x7e00000000000000
   2897a:	mov    rdx,QWORD PTR [rsp+0x18]
   2897f:	test   rdx,r15
   28982:	sete   al
   28985:	cmp    rdx,0xffffffffffffffff
   28989:	sete   cl
   2898c:	or     cl,al
   2898e:	mov    rax,rdx
   28991:	movabs rdx,0xfffffffe00
   2899b:	and    rax,rdx
   2899e:	cmp    rax,0x3108200
   289a4:	setb   al
   289a7:	or     al,cl
   289a9:	jne    289bd <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8a7d>
   289ab:	mov    rdi,r12
   289ae:	mov    rsi,QWORD PTR [rsp+0x8]
   289b3:	mov    rdx,QWORD PTR [rsp+0x18]
   289b8:	call   e8c0 <term_drop>
   289bd:	mov    rdx,QWORD PTR [rsp+0x48]
   289c2:	test   rdx,r15
   289c5:	sete   al
   289c8:	cmp    rdx,0xffffffffffffffff
   289cc:	sete   cl
   289cf:	or     cl,al
   289d1:	mov    rax,rdx
   289d4:	movabs rdx,0xfffffffe00
   289de:	and    rax,rdx
   289e1:	cmp    rax,0x3108200
   289e7:	setb   al
   289ea:	or     al,cl
   289ec:	jne    28a00 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8ac0>
   289ee:	mov    rdi,r12
   289f1:	mov    rsi,QWORD PTR [rsp+0x8]
   289f6:	mov    rdx,QWORD PTR [rsp+0x48]
   289fb:	call   e8c0 <term_drop>
   28a00:	cmp    r14,0xffffffffffffffff
   28a04:	sete   al
   28a07:	movabs rcx,0xfffffffe00
   28a11:	and    rbx,rcx
   28a14:	cmp    rbx,0x3108200
   28a1b:	setb   cl
   28a1e:	or     cl,al
   28a20:	jne    28dd1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e91>
   28a26:	mov    rdi,r12
   28a29:	mov    rsi,QWORD PTR [rsp+0x8]
   28a2e:	mov    rdx,r14
   28a31:	jmp    28dcc <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e8c>
   28a36:	mov    r15,rdx
   28a39:	mov    rdx,QWORD PTR [rsp+0x18]
   28a3e:	movabs rax,0x7e00000000000000
   28a48:	test   rdx,rax
   28a4b:	sete   al
   28a4e:	cmp    rdx,0xffffffffffffffff
   28a52:	sete   cl
   28a55:	or     cl,al
   28a57:	mov    rax,rdx
   28a5a:	movabs rdx,0xfffffffe00
   28a64:	and    rax,rdx
   28a67:	cmp    rax,0x3108200
   28a6d:	setb   al
   28a70:	or     al,cl
   28a72:	jne    28a86 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8b46>
   28a74:	mov    rdi,r12
   28a77:	mov    rsi,QWORD PTR [rsp+0x8]
   28a7c:	mov    rdx,QWORD PTR [rsp+0x18]
   28a81:	call   e8c0 <term_drop>
   28a86:	mov    rdx,QWORD PTR [rsp+0x28]
   28a8b:	movabs rax,0x7e00000000000000
   28a95:	test   rdx,rax
   28a98:	sete   al
   28a9b:	cmp    rdx,0xffffffffffffffff
   28a9f:	sete   cl
   28aa2:	or     cl,al
   28aa4:	mov    rax,rdx
   28aa7:	movabs rdx,0xfffffffe00
   28ab1:	and    rax,rdx
   28ab4:	cmp    rax,0x3108200
   28aba:	setb   al
   28abd:	or     al,cl
   28abf:	jne    28ad3 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8b93>
   28ac1:	mov    rdi,r12
   28ac4:	mov    rsi,QWORD PTR [rsp+0x8]
   28ac9:	mov    rdx,QWORD PTR [rsp+0x28]
   28ace:	call   e8c0 <term_drop>
   28ad3:	cmp    r15,0xffffffffffffffff
   28ad7:	sete   al
   28ada:	movabs rcx,0xfffffffe00
   28ae4:	and    rbx,rcx
   28ae7:	cmp    rbx,0x3108200
   28aee:	setb   cl
   28af1:	or     cl,al
   28af3:	je     28dc1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e81>
   28af9:	jmp    28dd1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e91>
   28afe:	mov    rbx,rdx
   28b01:	mov    rdx,QWORD PTR [rsp+0x18]
   28b06:	movabs rax,0x7e00000000000000
   28b10:	test   rdx,rax
   28b13:	sete   al
   28b16:	cmp    rdx,0xffffffffffffffff
   28b1a:	sete   cl
   28b1d:	or     cl,al
   28b1f:	mov    rax,rdx
   28b22:	movabs rdx,0xfffffffe00
   28b2c:	and    rax,rdx
   28b2f:	cmp    rax,0x3108200
   28b35:	setb   al
   28b38:	or     al,cl
   28b3a:	jne    28b4e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8c0e>
   28b3c:	mov    rdi,r12
   28b3f:	mov    rsi,QWORD PTR [rsp+0x8]
   28b44:	mov    rdx,QWORD PTR [rsp+0x18]
   28b49:	call   e8c0 <term_drop>
   28b4e:	mov    rdx,QWORD PTR [rsp+0x40]
   28b53:	movabs rax,0x7e00000000000000
   28b5d:	test   rdx,rax
   28b60:	sete   al
   28b63:	cmp    rdx,0xffffffffffffffff
   28b67:	sete   cl
   28b6a:	or     cl,al
   28b6c:	mov    rax,rdx
   28b6f:	movabs rdx,0xfffffffe00
   28b79:	and    rax,rdx
   28b7c:	cmp    rax,0x3108200
   28b82:	setb   al
   28b85:	or     al,cl
   28b87:	jne    28d48 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e08>
   28b8d:	mov    rdi,r12
   28b90:	mov    rsi,QWORD PTR [rsp+0x8]
   28b95:	mov    rdx,QWORD PTR [rsp+0x40]
   28b9a:	jmp    28d43 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e03>
   28b9f:	mov    r14,rdx
   28ba2:	movabs r15,0x7e00000000000000
   28bac:	mov    rdx,QWORD PTR [rsp+0x18]
   28bb1:	test   rdx,r15
   28bb4:	sete   al
   28bb7:	cmp    rdx,0xffffffffffffffff
   28bbb:	sete   cl
   28bbe:	or     cl,al
   28bc0:	mov    rax,rdx
   28bc3:	movabs rdx,0xfffffffe00
   28bcd:	and    rax,rdx
   28bd0:	cmp    rax,0x3108200
   28bd6:	setb   al
   28bd9:	or     al,cl
   28bdb:	jne    28bef <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8caf>
   28bdd:	mov    rdi,r12
   28be0:	mov    rsi,QWORD PTR [rsp+0x8]
   28be5:	mov    rdx,QWORD PTR [rsp+0x18]
   28bea:	call   e8c0 <term_drop>
   28bef:	mov    rdx,QWORD PTR [rsp+0x48]
   28bf4:	test   rdx,r15
   28bf7:	sete   al
   28bfa:	cmp    rdx,0xffffffffffffffff
   28bfe:	sete   cl
   28c01:	or     cl,al
   28c03:	mov    rax,rdx
   28c06:	movabs rdx,0xfffffffe00
   28c10:	and    rax,rdx
   28c13:	cmp    rax,0x3108200
   28c19:	setb   al
   28c1c:	or     al,cl
   28c1e:	jne    28c32 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8cf2>
   28c20:	mov    rdi,r12
   28c23:	mov    rsi,QWORD PTR [rsp+0x8]
   28c28:	mov    rdx,QWORD PTR [rsp+0x48]
   28c2d:	call   e8c0 <term_drop>
   28c32:	mov    rax,r14
   28c35:	test   r14,r15
   28c38:	sete   cl
   28c3b:	cmp    r14,0xffffffffffffffff
   28c3f:	sete   dl
   28c42:	or     dl,cl
   28c44:	movabs rcx,0xfffffffe00
   28c4e:	and    rax,rcx
   28c51:	cmp    rax,0x3108200
   28c57:	setb   al
   28c5a:	or     al,dl
   28c5c:	jne    28c6e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8d2e>
   28c5e:	mov    rdi,r12
   28c61:	mov    rsi,QWORD PTR [rsp+0x8]
   28c66:	mov    rdx,r14
   28c69:	call   e8c0 <term_drop>
   28c6e:	test   rbx,r15
   28c71:	sete   al
   28c74:	cmp    rbx,0xffffffffffffffff
   28c78:	sete   cl
   28c7b:	or     cl,al
   28c7d:	movabs rax,0xfffffffe00
   28c87:	and    rax,rbx
   28c8a:	cmp    rax,0x3108200
   28c90:	setb   al
   28c93:	or     al,cl
   28c95:	jne    28dd1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e91>
   28c9b:	mov    rdi,r12
   28c9e:	mov    rsi,QWORD PTR [rsp+0x8]
   28ca3:	mov    rdx,rbx
   28ca6:	jmp    28dcc <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e8c>
   28cab:	mov    rbx,rdx
   28cae:	mov    rdx,QWORD PTR [rsp+0x18]
   28cb3:	movabs rax,0x7e00000000000000
   28cbd:	test   rdx,rax
   28cc0:	sete   al
   28cc3:	cmp    rdx,0xffffffffffffffff
   28cc7:	sete   cl
   28cca:	or     cl,al
   28ccc:	mov    rax,rdx
   28ccf:	movabs rdx,0xfffffffe00
   28cd9:	and    rax,rdx
   28cdc:	cmp    rax,0x3108200
   28ce2:	setb   al
   28ce5:	or     al,cl
   28ce7:	jne    28cfb <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8dbb>
   28ce9:	mov    rdi,r12
   28cec:	mov    rsi,QWORD PTR [rsp+0x8]
   28cf1:	mov    rdx,QWORD PTR [rsp+0x18]
   28cf6:	call   e8c0 <term_drop>
   28cfb:	mov    rdx,QWORD PTR [rsp+0x28]
   28d00:	movabs rax,0x7e00000000000000
   28d0a:	test   rdx,rax
   28d0d:	sete   al
   28d10:	cmp    rdx,0xffffffffffffffff
   28d14:	sete   cl
   28d17:	or     cl,al
   28d19:	mov    rax,rdx
   28d1c:	movabs rdx,0xfffffffe00
   28d26:	and    rax,rdx
   28d29:	cmp    rax,0x3108200
   28d2f:	setb   al
   28d32:	or     al,cl
   28d34:	jne    28d48 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e08>
   28d36:	mov    rdi,r12
   28d39:	mov    rsi,QWORD PTR [rsp+0x8]
   28d3e:	mov    rdx,QWORD PTR [rsp+0x28]
   28d43:	call   e8c0 <term_drop>
   28d48:	mov    rax,rbx
   28d4b:	movabs rcx,0x7e00000000000000
   28d55:	test   rbx,rcx
   28d58:	sete   cl
   28d5b:	cmp    rbx,0xffffffffffffffff
   28d5f:	sete   dl
   28d62:	or     dl,cl
   28d64:	movabs rcx,0xfffffffe00
   28d6e:	and    rax,rcx
   28d71:	cmp    rax,0x3108200
   28d77:	setb   al
   28d7a:	or     al,dl
   28d7c:	jne    28d8e <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e4e>
   28d7e:	mov    rdi,r12
   28d81:	mov    rsi,QWORD PTR [rsp+0x8]
   28d86:	mov    rdx,rbx
   28d89:	call   e8c0 <term_drop>
   28d8e:	movabs rax,0x7e00000000000000
   28d98:	test   r15,rax
   28d9b:	sete   al
   28d9e:	cmp    r15,0xffffffffffffffff
   28da2:	sete   cl
   28da5:	or     cl,al
   28da7:	movabs rax,0xfffffffe00
   28db1:	and    rax,r15
   28db4:	cmp    rax,0x3108200
   28dba:	setb   al
   28dbd:	or     al,cl
   28dbf:	jne    28dd1 <WL_FID_36_100_105_114_101_99_116_46_77_97_112_46_103_101_116_46_103_111_+0x8e91>
   28dc1:	mov    rdi,r12
   28dc4:	mov    rsi,QWORD PTR [rsp+0x8]
   28dc9:	mov    rdx,r15
   28dcc:	call   e8c0 <term_drop>
   28dd1:	lea    rdi,[rip+0xfffffffffffdd0e8]        # 5ec0 <FID_RESW_T+0x510>
   28dd8:	call   5e1d0 <err_fail>
   28ddd:	lea    rdi,[rip+0xfffffffffffdd6a5]        # 6489 <FID_RESW_T+0xad9>
   28de4:	call   5e1d0 <err_fail>
   28de9:	mov    r14,QWORD PTR [rsp+0x20]
   28dee:	mov    QWORD PTR [r14],rbx
   28df1:	add    r14,0x8
   28df5:	mov    eax,0xab
   28dfa:	mov    QWORD PTR [r14],rax
   28dfd:	lea    rdi,[rip+0xfffffffffffdd0bc]        # 5ec0 <FID_RESW_T+0x510>
   28e04:	call   5e1d0 <err_fail>
   28e09:	mov    rbx,QWORD PTR [rsp+0x20]
   28e0e:	mov    QWORD PTR [rbx],r15
   28e11:	add    rbx,0x8
   28e15:	mov    eax,0xb8
   28e1a:	mov    QWORD PTR [rbx],rax
   28e1d:	lea    rdi,[rip+0xfffffffffffdd09c]        # 5ec0 <FID_RESW_T+0x510>
   28e24:	call   5e1d0 <err_fail>

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
