
/home/ai/bend2/build/publish/bend/selfhost/build/phase93/broad01/variation-ray-active-256-2240/upstream.program:     file format elf64-x86-64


Disassembly of section .text:

000000000000a6f0 <spin_32>:
    a6f0:	31 c0                	xor    eax,eax
    a6f2:	85 f6                	test   esi,esi
    a6f4:	0f 84 cf 01 00 00    	je     a8c9 <spin_32+0x1d9>
    a6fa:	55                   	push   rbp
    a6fb:	41 57                	push   r15
    a6fd:	41 56                	push   r14
    a6ff:	41 55                	push   r13
    a701:	41 54                	push   r12
    a703:	53                   	push   rbx
    a704:	48 83 ec 48          	sub    rsp,0x48
    a708:	89 d5                	mov    ebp,edx
    a70a:	48 89 7c 24 20       	mov    QWORD PTR [rsp+0x20],rdi
    a70f:	41 89 f5             	mov    r13d,esi
    a712:	45 31 e4             	xor    r12d,r12d
    a715:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
    a71c:	00 00 00 00 
    a720:	89 e8                	mov    eax,ebp
    a722:	b9 cd cc cc cc       	mov    ecx,0xcccccccd
    a727:	48 0f af c1          	imul   rax,rcx
    a72b:	48 c1 e8 26          	shr    rax,0x26
    a72f:	f3 0f 2a d8          	cvtsi2ss xmm3,eax
    a733:	f3 0f 11 5c 24 10    	movss  DWORD PTR [rsp+0x10],xmm3
    a739:	c1 e0 04             	shl    eax,0x4
    a73c:	8d 04 80             	lea    eax,[rax+rax*4]
    a73f:	89 e9                	mov    ecx,ebp
    a741:	29 c1                	sub    ecx,eax
    a743:	0f 57 c0             	xorps  xmm0,xmm0
    a746:	f3 0f 2a c1          	cvtsi2ss xmm0,ecx
    a74a:	f3 0f 11 44 24 0c    	movss  DWORD PTR [rsp+0xc],xmm0
    a750:	f3 0f 10 15 00 6f ff 	movss  xmm2,DWORD PTR [rip+0xffffffffffff6f00]        # 1658 <_IO_stdin_used-0x34>
    a757:	ff 
    a758:	f3 0f 58 c2          	addss  xmm0,xmm2
    a75c:	f3 0f 10 0d 04 6f ff 	movss  xmm1,DWORD PTR [rip+0xffffffffffff6f04]        # 1668 <_IO_stdin_used-0x24>
    a763:	ff 
    a764:	f3 0f 58 c1          	addss  xmm0,xmm1
    a768:	f3 0f 10 25 0c 6f ff 	movss  xmm4,DWORD PTR [rip+0xffffffffffff6f0c]        # 167c <_IO_stdin_used-0x10>
    a76f:	ff 
    a770:	f3 0f 5e c4          	divss  xmm0,xmm4
    a774:	66 0f 7e c3          	movd   ebx,xmm0
    a778:	0f 28 c3             	movaps xmm0,xmm3
    a77b:	f3 0f 58 c2          	addss  xmm0,xmm2
    a77f:	f3 0f 10 0d 21 6f ff 	movss  xmm1,DWORD PTR [rip+0xffffffffffff6f21]        # 16a8 <_IO_stdin_used+0x1c>
    a786:	ff 
    a787:	f3 0f 5c c8          	subss  xmm1,xmm0
    a78b:	f3 0f 5e cc          	divss  xmm1,xmm4
    a78f:	66 41 0f 7e ce       	movd   r14d,xmm1
    a794:	48 8d 7c 24 40       	lea    rdi,[rsp+0x40]
    a799:	89 de                	mov    esi,ebx
    a79b:	44 89 f2             	mov    edx,r14d
    a79e:	e8 2d 01 00 00       	call   a8d0 <spin_22>
    a7a3:	f3 0f 10 44 24 40    	movss  xmm0,DWORD PTR [rsp+0x40]
    a7a9:	f3 0f 11 44 24 08    	movss  DWORD PTR [rsp+0x8],xmm0
    a7af:	f3 0f 10 0d d9 6e ff 	movss  xmm1,DWORD PTR [rip+0xffffffffffff6ed9]        # 1690 <_IO_stdin_used+0x4>
    a7b6:	ff 
    a7b7:	f3 0f 10 44 24 0c    	movss  xmm0,DWORD PTR [rsp+0xc]
    a7bd:	f3 0f 58 c1          	addss  xmm0,xmm1
    a7c1:	f3 0f 58 05 9f 6e ff 	addss  xmm0,DWORD PTR [rip+0xffffffffffff6e9f]        # 1668 <_IO_stdin_used-0x24>
    a7c8:	ff 
    a7c9:	f3 0f 5e 05 ab 6e ff 	divss  xmm0,DWORD PTR [rip+0xffffffffffff6eab]        # 167c <_IO_stdin_used-0x10>
    a7d0:	ff 
    a7d1:	66 41 0f 7e c7       	movd   r15d,xmm0
    a7d6:	48 8d 7c 24 38       	lea    rdi,[rsp+0x38]
    a7db:	44 89 fe             	mov    esi,r15d
    a7de:	44 89 f2             	mov    edx,r14d
    a7e1:	e8 ea 00 00 00       	call   a8d0 <spin_22>
    a7e6:	f3 0f 10 44 24 08    	movss  xmm0,DWORD PTR [rsp+0x8]
    a7ec:	f3 0f 58 44 24 38    	addss  xmm0,DWORD PTR [rsp+0x38]
    a7f2:	f3 0f 11 44 24 08    	movss  DWORD PTR [rsp+0x8],xmm0
    a7f8:	f3 0f 10 4c 24 10    	movss  xmm1,DWORD PTR [rsp+0x10]
    a7fe:	f3 0f 58 0d 8a 6e ff 	addss  xmm1,DWORD PTR [rip+0xffffffffffff6e8a]        # 1690 <_IO_stdin_used+0x4>
    a805:	ff 
    a806:	f3 0f 10 05 9a 6e ff 	movss  xmm0,DWORD PTR [rip+0xffffffffffff6e9a]        # 16a8 <_IO_stdin_used+0x1c>
    a80d:	ff 
    a80e:	f3 0f 5c c1          	subss  xmm0,xmm1
    a812:	f3 0f 5e 05 62 6e ff 	divss  xmm0,DWORD PTR [rip+0xffffffffffff6e62]        # 167c <_IO_stdin_used-0x10>
    a819:	ff 
    a81a:	66 41 0f 7e c6       	movd   r14d,xmm0
    a81f:	48 8d 7c 24 30       	lea    rdi,[rsp+0x30]
    a824:	89 de                	mov    esi,ebx
    a826:	44 89 f2             	mov    edx,r14d
    a829:	e8 a2 00 00 00       	call   a8d0 <spin_22>
    a82e:	f3 0f 10 44 24 30    	movss  xmm0,DWORD PTR [rsp+0x30]
    a834:	0f 29 44 24 10       	movaps XMMWORD PTR [rsp+0x10],xmm0
    a839:	48 8d 7c 24 28       	lea    rdi,[rsp+0x28]
    a83e:	44 89 fe             	mov    esi,r15d
    a841:	44 89 f2             	mov    edx,r14d
    a844:	e8 87 00 00 00       	call   a8d0 <spin_22>
    a849:	31 c9                	xor    ecx,ecx
    a84b:	0f 28 54 24 10       	movaps xmm2,XMMWORD PTR [rsp+0x10]
    a850:	f3 0f 58 54 24 28    	addss  xmm2,DWORD PTR [rsp+0x28]
    a856:	f3 0f 58 54 24 08    	addss  xmm2,DWORD PTR [rsp+0x8]
    a85c:	f3 0f 59 15 f4 6d ff 	mulss  xmm2,DWORD PTR [rip+0xffffffffffff6df4]        # 1658 <_IO_stdin_used-0x34>
    a863:	ff 
    a864:	f3 0f 10 05 cc 6d ff 	movss  xmm0,DWORD PTR [rip+0xffffffffffff6dcc]        # 1638 <_IO_stdin_used-0x54>
    a86b:	ff 
    a86c:	f3 0f 5d c2          	minss  xmm0,xmm2
    a870:	f3 0f 59 05 10 6e ff 	mulss  xmm0,DWORD PTR [rip+0xffffffffffff6e10]        # 1688 <_IO_stdin_used-0x4>
    a877:	ff 
    a878:	0f 57 c9             	xorps  xmm1,xmm1
    a87b:	f3 0f c2 d1 05       	cmpnltss xmm2,xmm1
    a880:	0f 54 d0             	andps  xmm2,xmm0
    a883:	41 69 c4 93 01 00 01 	imul   eax,r12d,0x1000193
    a88a:	f3 0f 10 05 aa 6d ff 	movss  xmm0,DWORD PTR [rip+0xffffffffffff6daa]        # 163c <_IO_stdin_used-0x50>
    a891:	ff 
    a892:	0f 2e c2             	ucomiss xmm0,xmm2
    a895:	f3 4c 0f 2c e2       	cvttss2si r12,xmm2
    a89a:	44 0f 46 e1          	cmovbe r12d,ecx
    a89e:	0f 2e d1             	ucomiss xmm2,xmm1
    a8a1:	44 0f 42 e1          	cmovb  r12d,ecx
    a8a5:	41 01 c4             	add    r12d,eax
    a8a8:	ff c5                	inc    ebp
    a8aa:	49 ff cd             	dec    r13
    a8ad:	0f 85 6d fe ff ff    	jne    a720 <spin_32+0x30>
    a8b3:	44 89 e0             	mov    eax,r12d
    a8b6:	48 8b 7c 24 20       	mov    rdi,QWORD PTR [rsp+0x20]
    a8bb:	48 83 c4 48          	add    rsp,0x48
    a8bf:	5b                   	pop    rbx
    a8c0:	41 5c                	pop    r12
    a8c2:	41 5d                	pop    r13
    a8c4:	41 5e                	pop    r14
    a8c6:	41 5f                	pop    r15
    a8c8:	5d                   	pop    rbp
    a8c9:	48 89 07             	mov    QWORD PTR [rdi],rax
    a8cc:	c3                   	ret    

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
