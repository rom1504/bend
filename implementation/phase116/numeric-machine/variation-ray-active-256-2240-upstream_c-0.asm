
/home/ai/bend2/build/publish/bend/selfhost/build/phase93/broad01/variation-ray-active-256-2240/upstream.program:     file format elf64-x86-64


Disassembly of section .text:

000000000000a8d0 <spin_22>:
    a8d0:	55                   	push   rbp
    a8d1:	41 57                	push   r15
    a8d3:	41 56                	push   r14
    a8d5:	41 55                	push   r13
    a8d7:	41 54                	push   r12
    a8d9:	53                   	push   rbx
    a8da:	48 81 ec e8 01 00 00 	sub    rsp,0x1e8
    a8e1:	48 89 bc 24 b8 01 00 	mov    QWORD PTR [rsp+0x1b8],rdi
    a8e8:	00 
    a8e9:	66 0f 6e f6          	movd   xmm6,esi
    a8ed:	66 0f 6f c6          	movdqa xmm0,xmm6
    a8f1:	f3 0f 59 c6          	mulss  xmm0,xmm6
    a8f5:	66 0f 6e ca          	movd   xmm1,edx
    a8f9:	0f 28 15 80 6e ff ff 	movaps xmm2,XMMWORD PTR [rip+0xffffffffffff6e80]        # 1780 <_IO_stdin_used+0xf4>
    a900:	f3 0f 10 d1          	movss  xmm2,xmm1
    a904:	f3 0f 59 c9          	mulss  xmm1,xmm1
    a908:	f3 0f 58 c8          	addss  xmm1,xmm0
    a90c:	f3 0f 58 0d 24 6d ff 	addss  xmm1,DWORD PTR [rip+0xffffffffffff6d24]        # 1638 <_IO_stdin_used-0x54>
    a913:	ff 
    a914:	0f 57 c0             	xorps  xmm0,xmm0
    a917:	f3 0f 51 c1          	sqrtss xmm0,xmm1
    a91b:	f3 0f 5e f0          	divss  xmm6,xmm0
    a91f:	0f c6 c0 00          	shufps xmm0,xmm0,0x0
    a923:	0f 5e d0             	divps  xmm2,xmm0
    a926:	f3 0f 10 0d 7e 6d ff 	movss  xmm1,DWORD PTR [rip+0xffffffffffff6d7e]        # 16ac <_IO_stdin_used+0x20>
    a92d:	ff 
    a92e:	f3 0f 59 ce          	mulss  xmm1,xmm6
    a932:	f2 0f 10 05 56 6e ff 	movsd  xmm0,QWORD PTR [rip+0xffffffffffff6e56]        # 1790 <_IO_stdin_used+0x104>
    a939:	ff 
    a93a:	0f 29 54 24 70       	movaps XMMWORD PTR [rsp+0x70],xmm2
    a93f:	0f 59 c2             	mulps  xmm0,xmm2
    a942:	f3 0f 5c c8          	subss  xmm1,xmm0
    a946:	0f c6 c0 55          	shufps xmm0,xmm0,0x55
    a94a:	f3 0f 5c c8          	subss  xmm1,xmm0
    a94e:	0f 28 c1             	movaps xmm0,xmm1
    a951:	f3 0f 59 c1          	mulss  xmm0,xmm1
    a955:	f3 0f 58 05 f3 6c ff 	addss  xmm0,DWORD PTR [rip+0xffffffffffff6cf3]        # 1650 <_IO_stdin_used-0x3c>
    a95c:	ff 
    a95d:	bb 28 6b 6e 4e       	mov    ebx,0x4e6e6b28
    a962:	0f 57 d2             	xorps  xmm2,xmm2
    a965:	0f 2e d0             	ucomiss xmm2,xmm0
    a968:	bd 28 6b 6e 4e       	mov    ebp,0x4e6e6b28
    a96d:	f3 0f 11 74 24 0c    	movss  DWORD PTR [rsp+0xc],xmm6
    a973:	77 47                	ja     a9bc <spin_22+0xec>
    a975:	0f 57 db             	xorps  xmm3,xmm3
    a978:	f3 0f 5c d9          	subss  xmm3,xmm1
    a97c:	0f 2e c2             	ucomiss xmm0,xmm2
    a97f:	72 06                	jb     a987 <spin_22+0xb7>
    a981:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    a985:	eb 1a                	jmp    a9a1 <spin_22+0xd1>
    a987:	f3 0f 11 5c 24 20    	movss  DWORD PTR [rsp+0x20],xmm3
    a98d:	e8 9e 43 00 00       	call   ed30 <sqrtf@plt>
    a992:	f3 0f 10 5c 24 20    	movss  xmm3,DWORD PTR [rsp+0x20]
    a998:	0f 57 d2             	xorps  xmm2,xmm2
    a99b:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    a9a1:	f3 0f 5c d8          	subss  xmm3,xmm0
    a9a5:	66 0f 7e d8          	movd   eax,xmm3
    a9a9:	f3 0f 10 05 ff 6c ff 	movss  xmm0,DWORD PTR [rip+0xffffffffffff6cff]        # 16b0 <_IO_stdin_used+0x24>
    a9b0:	ff 
    a9b1:	0f 2e c3             	ucomiss xmm0,xmm3
    a9b4:	bd 28 6b 6e 4e       	mov    ebp,0x4e6e6b28
    a9b9:	0f 46 e8             	cmovbe ebp,eax
    a9bc:	66 0f 6e c5          	movd   xmm0,ebp
    a9c0:	f3 0f 10 0d dc 6c ff 	movss  xmm1,DWORD PTR [rip+0xffffffffffff6cdc]        # 16a4 <_IO_stdin_used+0x18>
    a9c7:	ff 
    a9c8:	45 31 f6             	xor    r14d,r14d
    a9cb:	0f 2e c8             	ucomiss xmm1,xmm0
    a9ce:	41 0f 96 c6          	setbe  r14b
    a9d2:	f3 0f 10 05 9e 6c ff 	movss  xmm0,DWORD PTR [rip+0xffffffffffff6c9e]        # 1678 <_IO_stdin_used-0x14>
    a9d9:	ff 
    a9da:	f3 0f 59 c6          	mulss  xmm0,xmm6
    a9de:	f2 0f 10 0d da 6c ff 	movsd  xmm1,QWORD PTR [rip+0xffffffffffff6cda]        # 16c0 <_IO_stdin_used+0x34>
    a9e5:	ff 
    a9e6:	0f 59 4c 24 70       	mulps  xmm1,XMMWORD PTR [rsp+0x70]
    a9eb:	f3 0f 58 c1          	addss  xmm0,xmm1
    a9ef:	0f c6 c9 55          	shufps xmm1,xmm1,0x55
    a9f3:	f3 0f 58 c8          	addss  xmm1,xmm0
    a9f7:	0f 28 c1             	movaps xmm0,xmm1
    a9fa:	f3 0f 59 c1          	mulss  xmm0,xmm1
    a9fe:	f3 0f 58 05 4a 6c ff 	addss  xmm0,DWORD PTR [rip+0xffffffffffff6c4a]        # 1650 <_IO_stdin_used-0x3c>
    aa05:	ff 
    aa06:	0f 46 eb             	cmovbe ebp,ebx
    aa09:	41 83 ce 08          	or     r14d,0x8
    aa0d:	0f 2e d0             	ucomiss xmm2,xmm0
    aa10:	77 41                	ja     aa53 <spin_22+0x183>
    aa12:	0f 2e c2             	ucomiss xmm0,xmm2
    aa15:	f3 0f 5c d1          	subss  xmm2,xmm1
    aa19:	72 06                	jb     aa21 <spin_22+0x151>
    aa1b:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    aa1f:	eb 17                	jmp    aa38 <spin_22+0x168>
    aa21:	f3 0f 11 54 24 20    	movss  DWORD PTR [rsp+0x20],xmm2
    aa27:	e8 04 43 00 00       	call   ed30 <sqrtf@plt>
    aa2c:	f3 0f 10 54 24 20    	movss  xmm2,DWORD PTR [rsp+0x20]
    aa32:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    aa38:	f3 0f 5c d0          	subss  xmm2,xmm0
    aa3c:	66 0f 7e d0          	movd   eax,xmm2
    aa40:	f3 0f 10 05 68 6c ff 	movss  xmm0,DWORD PTR [rip+0xffffffffffff6c68]        # 16b0 <_IO_stdin_used+0x24>
    aa47:	ff 
    aa48:	0f 2e c2             	ucomiss xmm0,xmm2
    aa4b:	bb 28 6b 6e 4e       	mov    ebx,0x4e6e6b28
    aa50:	0f 46 d8             	cmovbe ebx,eax
    aa53:	66 0f 6e c3          	movd   xmm0,ebx
    aa57:	66 0f 6e cd          	movd   xmm1,ebp
    aa5b:	0f 2e c8             	ucomiss xmm1,xmm0
    aa5e:	0f 57 db             	xorps  xmm3,xmm3
    aa61:	0f 28 d6             	movaps xmm2,xmm6
    aa64:	f3 0f 59 d3          	mulss  xmm2,xmm3
    aa68:	f2 0f 10 0d 30 6d ff 	movsd  xmm1,QWORD PTR [rip+0xffffffffffff6d30]        # 17a0 <_IO_stdin_used+0x114>
    aa6f:	ff 
    aa70:	0f 59 4c 24 70       	mulps  xmm1,XMMWORD PTR [rsp+0x70]
    aa75:	0f 28 c2             	movaps xmm0,xmm2
    aa78:	f3 0f 58 c1          	addss  xmm0,xmm1
    aa7c:	0f c6 c9 55          	shufps xmm1,xmm1,0x55
    aa80:	f3 0f 58 c8          	addss  xmm1,xmm0
    aa84:	0f 28 c1             	movaps xmm0,xmm1
    aa87:	f3 0f 59 c1          	mulss  xmm0,xmm1
    aa8b:	f3 0f 58 05 a1 6b ff 	addss  xmm0,DWORD PTR [rip+0xffffffffffff6ba1]        # 1634 <_IO_stdin_used-0x58>
    aa92:	ff 
    aa93:	0f 46 dd             	cmovbe ebx,ebp
    aa96:	41 bf 07 00 00 00    	mov    r15d,0x7
    aa9c:	45 0f 46 fe          	cmovbe r15d,r14d
    aaa0:	0f 2e d8             	ucomiss xmm3,xmm0
    aaa3:	bd 28 6b 6e 4e       	mov    ebp,0x4e6e6b28
    aaa8:	41 be 28 6b 6e 4e    	mov    r14d,0x4e6e6b28
    aaae:	f3 0f 11 54 24 20    	movss  DWORD PTR [rsp+0x20],xmm2
    aab4:	77 4f                	ja     ab05 <spin_22+0x235>
    aab6:	0f 57 e4             	xorps  xmm4,xmm4
    aab9:	f3 0f 5c e1          	subss  xmm4,xmm1
    aabd:	0f 2e c3             	ucomiss xmm0,xmm3
    aac0:	72 06                	jb     aac8 <spin_22+0x1f8>
    aac2:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    aac6:	eb 20                	jmp    aae8 <spin_22+0x218>
    aac8:	f3 0f 11 64 24 10    	movss  DWORD PTR [rsp+0x10],xmm4
    aace:	e8 5d 42 00 00       	call   ed30 <sqrtf@plt>
    aad3:	f3 0f 10 64 24 10    	movss  xmm4,DWORD PTR [rsp+0x10]
    aad9:	0f 57 db             	xorps  xmm3,xmm3
    aadc:	f3 0f 10 54 24 20    	movss  xmm2,DWORD PTR [rsp+0x20]
    aae2:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    aae8:	f3 0f 5c e0          	subss  xmm4,xmm0
    aaec:	66 0f 7e e0          	movd   eax,xmm4
    aaf0:	f3 0f 10 05 b8 6b ff 	movss  xmm0,DWORD PTR [rip+0xffffffffffff6bb8]        # 16b0 <_IO_stdin_used+0x24>
    aaf7:	ff 
    aaf8:	0f 2e c4             	ucomiss xmm0,xmm4
    aafb:	41 be 28 6b 6e 4e    	mov    r14d,0x4e6e6b28
    ab01:	44 0f 46 f0          	cmovbe r14d,eax
    ab05:	66 41 0f 6e c6       	movd   xmm0,r14d
    ab0a:	66 0f 6e cb          	movd   xmm1,ebx
    ab0e:	0f 2e c8             	ucomiss xmm1,xmm0
    ab11:	f2 0f 10 25 c7 6b ff 	movsd  xmm4,QWORD PTR [rip+0xffffffffffff6bc7]        # 16e0 <_IO_stdin_used+0x54>
    ab18:	ff 
    ab19:	0f 59 64 24 70       	mulps  xmm4,XMMWORD PTR [rsp+0x70]
    ab1e:	0f 28 c6             	movaps xmm0,xmm6
    ab21:	f3 0f 58 c4          	addss  xmm0,xmm4
    ab25:	0f 28 cc             	movaps xmm1,xmm4
    ab28:	0f c6 cc 55          	shufps xmm1,xmm4,0x55
    ab2c:	0f 28 e9             	movaps xmm5,xmm1
    ab2f:	f3 0f 58 c8          	addss  xmm1,xmm0
    ab33:	0f 28 c1             	movaps xmm0,xmm1
    ab36:	f3 0f 59 c1          	mulss  xmm0,xmm1
    ab3a:	44 0f 46 f3          	cmovbe r14d,ebx
    ab3e:	bb 06 00 00 00       	mov    ebx,0x6
    ab43:	41 0f 46 df          	cmovbe ebx,r15d
    ab47:	f3 0f 58 05 f9 6a ff 	addss  xmm0,DWORD PTR [rip+0xffffffffffff6af9]        # 1648 <_IO_stdin_used-0x44>
    ab4e:	ff 
    ab4f:	0f 2e d8             	ucomiss xmm3,xmm0
    ab52:	77 5d                	ja     abb1 <spin_22+0x2e1>
    ab54:	0f 2e c3             	ucomiss xmm0,xmm3
    ab57:	f3 0f 5c d9          	subss  xmm3,xmm1
    ab5b:	72 06                	jb     ab63 <spin_22+0x293>
    ab5d:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    ab61:	eb 33                	jmp    ab96 <spin_22+0x2c6>
    ab63:	0f 29 64 24 10       	movaps XMMWORD PTR [rsp+0x10],xmm4
    ab68:	f3 0f 11 6c 24 30    	movss  DWORD PTR [rsp+0x30],xmm5
    ab6e:	f3 0f 11 5c 24 60    	movss  DWORD PTR [rsp+0x60],xmm3
    ab74:	e8 b7 41 00 00       	call   ed30 <sqrtf@plt>
    ab79:	f3 0f 10 5c 24 60    	movss  xmm3,DWORD PTR [rsp+0x60]
    ab7f:	f3 0f 10 6c 24 30    	movss  xmm5,DWORD PTR [rsp+0x30]
    ab85:	0f 28 64 24 10       	movaps xmm4,XMMWORD PTR [rsp+0x10]
    ab8a:	f3 0f 10 54 24 20    	movss  xmm2,DWORD PTR [rsp+0x20]
    ab90:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    ab96:	f3 0f 5c d8          	subss  xmm3,xmm0
    ab9a:	66 0f 7e d8          	movd   eax,xmm3
    ab9e:	f3 0f 10 05 0a 6b ff 	movss  xmm0,DWORD PTR [rip+0xffffffffffff6b0a]        # 16b0 <_IO_stdin_used+0x24>
    aba5:	ff 
    aba6:	0f 2e c3             	ucomiss xmm0,xmm3
    aba9:	bd 28 6b 6e 4e       	mov    ebp,0x4e6e6b28
    abae:	0f 46 e8             	cmovbe ebp,eax
    abb1:	66 0f 6e c5          	movd   xmm0,ebp
    abb5:	66 41 0f 6e ce       	movd   xmm1,r14d
    abba:	0f 2e c8             	ucomiss xmm1,xmm0
    abbd:	f3 0f 5c e6          	subss  xmm4,xmm6
    abc1:	f3 0f 58 e5          	addss  xmm4,xmm5
    abc5:	0f 28 c4             	movaps xmm0,xmm4
    abc8:	f3 0f 59 c4          	mulss  xmm0,xmm4
    abcc:	f3 0f 58 05 74 6a ff 	addss  xmm0,DWORD PTR [rip+0xffffffffffff6a74]        # 1648 <_IO_stdin_used-0x44>
    abd3:	ff 
    abd4:	41 0f 46 ee          	cmovbe ebp,r14d
    abd8:	41 bf 05 00 00 00    	mov    r15d,0x5
    abde:	44 0f 46 fb          	cmovbe r15d,ebx
    abe2:	0f 57 ed             	xorps  xmm5,xmm5
    abe5:	0f 2e e8             	ucomiss xmm5,xmm0
    abe8:	bb 28 6b 6e 4e       	mov    ebx,0x4e6e6b28
    abed:	41 be 28 6b 6e 4e    	mov    r14d,0x4e6e6b28
    abf3:	77 4f                	ja     ac44 <spin_22+0x374>
    abf5:	0f 57 c9             	xorps  xmm1,xmm1
    abf8:	f3 0f 5c cc          	subss  xmm1,xmm4
    abfc:	0f 2e c5             	ucomiss xmm0,xmm5
    abff:	72 06                	jb     ac07 <spin_22+0x337>
    ac01:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    ac05:	eb 20                	jmp    ac27 <spin_22+0x357>
    ac07:	f3 0f 11 4c 24 10    	movss  DWORD PTR [rsp+0x10],xmm1
    ac0d:	e8 1e 41 00 00       	call   ed30 <sqrtf@plt>
    ac12:	f3 0f 10 4c 24 10    	movss  xmm1,DWORD PTR [rsp+0x10]
    ac18:	0f 57 ed             	xorps  xmm5,xmm5
    ac1b:	f3 0f 10 54 24 20    	movss  xmm2,DWORD PTR [rsp+0x20]
    ac21:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    ac27:	f3 0f 5c c8          	subss  xmm1,xmm0
    ac2b:	66 0f 7e c8          	movd   eax,xmm1
    ac2f:	f3 0f 10 05 79 6a ff 	movss  xmm0,DWORD PTR [rip+0xffffffffffff6a79]        # 16b0 <_IO_stdin_used+0x24>
    ac36:	ff 
    ac37:	0f 2e c1             	ucomiss xmm0,xmm1
    ac3a:	41 be 28 6b 6e 4e    	mov    r14d,0x4e6e6b28
    ac40:	44 0f 46 f0          	cmovbe r14d,eax
    ac44:	66 41 0f 6e c6       	movd   xmm0,r14d
    ac49:	66 0f 6e cd          	movd   xmm1,ebp
    ac4d:	0f 2e c8             	ucomiss xmm1,xmm0
    ac50:	0f 28 e6             	movaps xmm4,xmm6
    ac53:	f3 0f 58 e6          	addss  xmm4,xmm6
    ac57:	f2 0f 10 1d f1 6a ff 	movsd  xmm3,QWORD PTR [rip+0xffffffffffff6af1]        # 1750 <_IO_stdin_used+0xc4>
    ac5e:	ff 
    ac5f:	0f 59 5c 24 70       	mulps  xmm3,XMMWORD PTR [rsp+0x70]
    ac64:	0f 28 c4             	movaps xmm0,xmm4
    ac67:	f3 0f 58 c3          	addss  xmm0,xmm3
    ac6b:	0f 28 cb             	movaps xmm1,xmm3
    ac6e:	0f c6 cb 55          	shufps xmm1,xmm3,0x55
    ac72:	0f 28 f9             	movaps xmm7,xmm1
    ac75:	f3 0f 58 c8          	addss  xmm1,xmm0
    ac79:	0f 28 c1             	movaps xmm0,xmm1
    ac7c:	f3 0f 59 c1          	mulss  xmm0,xmm1
    ac80:	44 0f 46 f5          	cmovbe r14d,ebp
    ac84:	bd 04 00 00 00       	mov    ebp,0x4
    ac89:	41 0f 46 ef          	cmovbe ebp,r15d
    ac8d:	f3 0f 58 05 c7 69 ff 	addss  xmm0,DWORD PTR [rip+0xffffffffffff69c7]        # 165c <_IO_stdin_used-0x30>
    ac94:	ff 
    ac95:	0f 2e e8             	ucomiss xmm5,xmm0
    ac98:	77 6f                	ja     ad09 <spin_22+0x439>
    ac9a:	0f 2e c5             	ucomiss xmm0,xmm5
    ac9d:	f3 0f 5c e9          	subss  xmm5,xmm1
    aca1:	72 06                	jb     aca9 <spin_22+0x3d9>
    aca3:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    aca7:	eb 45                	jmp    acee <spin_22+0x41e>
    aca9:	0f 29 5c 24 10       	movaps XMMWORD PTR [rsp+0x10],xmm3
    acae:	f3 0f 11 64 24 30    	movss  DWORD PTR [rsp+0x30],xmm4
    acb4:	f3 0f 11 7c 24 60    	movss  DWORD PTR [rsp+0x60],xmm7
    acba:	f3 0f 11 ac 24 c0 00 	movss  DWORD PTR [rsp+0xc0],xmm5
    acc1:	00 00 
    acc3:	e8 68 40 00 00       	call   ed30 <sqrtf@plt>
    acc8:	f3 0f 10 ac 24 c0 00 	movss  xmm5,DWORD PTR [rsp+0xc0]
    accf:	00 00 
    acd1:	f3 0f 10 7c 24 60    	movss  xmm7,DWORD PTR [rsp+0x60]
    acd7:	f3 0f 10 64 24 30    	movss  xmm4,DWORD PTR [rsp+0x30]
    acdd:	0f 28 5c 24 10       	movaps xmm3,XMMWORD PTR [rsp+0x10]
    ace2:	f3 0f 10 54 24 20    	movss  xmm2,DWORD PTR [rsp+0x20]
    ace8:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    acee:	f3 0f 5c e8          	subss  xmm5,xmm0
    acf2:	66 0f 7e e8          	movd   eax,xmm5
    acf6:	f3 0f 10 05 b2 69 ff 	movss  xmm0,DWORD PTR [rip+0xffffffffffff69b2]        # 16b0 <_IO_stdin_used+0x24>
    acfd:	ff 
    acfe:	0f 2e c5             	ucomiss xmm0,xmm5
    ad01:	bb 28 6b 6e 4e       	mov    ebx,0x4e6e6b28
    ad06:	0f 46 d8             	cmovbe ebx,eax
    ad09:	66 0f 6e c3          	movd   xmm0,ebx
    ad0d:	66 41 0f 6e ce       	movd   xmm1,r14d
    ad12:	0f 2e c8             	ucomiss xmm1,xmm0
    ad15:	f3 0f 5c dc          	subss  xmm3,xmm4
    ad19:	f3 0f 58 df          	addss  xmm3,xmm7
    ad1d:	0f 28 c3             	movaps xmm0,xmm3
    ad20:	f3 0f 59 c3          	mulss  xmm0,xmm3
    ad24:	f3 0f 58 05 30 69 ff 	addss  xmm0,DWORD PTR [rip+0xffffffffffff6930]        # 165c <_IO_stdin_used-0x30>
    ad2b:	ff 
    ad2c:	41 0f 46 de          	cmovbe ebx,r14d
    ad30:	41 bc 03 00 00 00    	mov    r12d,0x3
    ad36:	44 0f 46 e5          	cmovbe r12d,ebp
    ad3a:	0f 57 e4             	xorps  xmm4,xmm4
    ad3d:	0f 2e e0             	ucomiss xmm4,xmm0
    ad40:	bd 28 6b 6e 4e       	mov    ebp,0x4e6e6b28
    ad45:	41 be 28 6b 6e 4e    	mov    r14d,0x4e6e6b28
    ad4b:	77 4f                	ja     ad9c <spin_22+0x4cc>
    ad4d:	0f 57 c9             	xorps  xmm1,xmm1
    ad50:	f3 0f 5c cb          	subss  xmm1,xmm3
    ad54:	0f 2e c4             	ucomiss xmm0,xmm4
    ad57:	72 06                	jb     ad5f <spin_22+0x48f>
    ad59:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    ad5d:	eb 20                	jmp    ad7f <spin_22+0x4af>
    ad5f:	f3 0f 11 4c 24 10    	movss  DWORD PTR [rsp+0x10],xmm1
    ad65:	e8 c6 3f 00 00       	call   ed30 <sqrtf@plt>
    ad6a:	f3 0f 10 4c 24 10    	movss  xmm1,DWORD PTR [rsp+0x10]
    ad70:	0f 57 e4             	xorps  xmm4,xmm4
    ad73:	f3 0f 10 54 24 20    	movss  xmm2,DWORD PTR [rsp+0x20]
    ad79:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    ad7f:	f3 0f 5c c8          	subss  xmm1,xmm0
    ad83:	66 0f 7e c8          	movd   eax,xmm1
    ad87:	f3 0f 10 05 21 69 ff 	movss  xmm0,DWORD PTR [rip+0xffffffffffff6921]        # 16b0 <_IO_stdin_used+0x24>
    ad8e:	ff 
    ad8f:	0f 2e c1             	ucomiss xmm0,xmm1
    ad92:	41 be 28 6b 6e 4e    	mov    r14d,0x4e6e6b28
    ad98:	44 0f 46 f0          	cmovbe r14d,eax
    ad9c:	66 41 0f 6e c6       	movd   xmm0,r14d
    ada1:	66 0f 6e cb          	movd   xmm1,ebx
    ada5:	0f 2e c8             	ucomiss xmm1,xmm0
    ada8:	f2 0f 10 0d b0 69 ff 	movsd  xmm1,QWORD PTR [rip+0xffffffffffff69b0]        # 1760 <_IO_stdin_used+0xd4>
    adaf:	ff 
    adb0:	0f 59 4c 24 70       	mulps  xmm1,XMMWORD PTR [rsp+0x70]
    adb5:	0f 28 c2             	movaps xmm0,xmm2
    adb8:	f3 0f 58 c1          	addss  xmm0,xmm1
    adbc:	0f c6 c9 55          	shufps xmm1,xmm1,0x55
    adc0:	0f 28 d9             	movaps xmm3,xmm1
    adc3:	f3 0f 58 c8          	addss  xmm1,xmm0
    adc7:	0f 28 c1             	movaps xmm0,xmm1
    adca:	f3 0f 59 c1          	mulss  xmm0,xmm1
    adce:	44 0f 46 f3          	cmovbe r14d,ebx
    add2:	41 bf 02 00 00 00    	mov    r15d,0x2
    add8:	45 0f 46 fc          	cmovbe r15d,r12d
    addc:	f3 0f 58 05 4c 68 ff 	addss  xmm0,DWORD PTR [rip+0xffffffffffff684c]        # 1630 <_IO_stdin_used-0x5c>
    ade3:	ff 
    ade4:	0f 2e e0             	ucomiss xmm4,xmm0
    ade7:	77 53                	ja     ae3c <spin_22+0x56c>
    ade9:	0f 2e c4             	ucomiss xmm0,xmm4
    adec:	f3 0f 5c e1          	subss  xmm4,xmm1
    adf0:	72 06                	jb     adf8 <spin_22+0x528>
    adf2:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    adf6:	eb 29                	jmp    ae21 <spin_22+0x551>
    adf8:	f3 0f 11 5c 24 10    	movss  DWORD PTR [rsp+0x10],xmm3
    adfe:	f3 0f 11 64 24 30    	movss  DWORD PTR [rsp+0x30],xmm4
    ae04:	e8 27 3f 00 00       	call   ed30 <sqrtf@plt>
    ae09:	f3 0f 10 64 24 30    	movss  xmm4,DWORD PTR [rsp+0x30]
    ae0f:	f3 0f 10 5c 24 10    	movss  xmm3,DWORD PTR [rsp+0x10]
    ae15:	f3 0f 10 54 24 20    	movss  xmm2,DWORD PTR [rsp+0x20]
    ae1b:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    ae21:	f3 0f 5c e0          	subss  xmm4,xmm0
    ae25:	66 0f 7e e0          	movd   eax,xmm4
    ae29:	f3 0f 10 05 7f 68 ff 	movss  xmm0,DWORD PTR [rip+0xffffffffffff687f]        # 16b0 <_IO_stdin_used+0x24>
    ae30:	ff 
    ae31:	0f 2e c4             	ucomiss xmm0,xmm4
    ae34:	bd 28 6b 6e 4e       	mov    ebp,0x4e6e6b28
    ae39:	0f 46 e8             	cmovbe ebp,eax
    ae3c:	66 0f 6e c5          	movd   xmm0,ebp
    ae40:	66 41 0f 6e ce       	movd   xmm1,r14d
    ae45:	0f 2e c8             	ucomiss xmm1,xmm0
    ae48:	f3 0f 10 05 10 68 ff 	movss  xmm0,DWORD PTR [rip+0xffffffffffff6810]        # 1660 <_IO_stdin_used-0x2c>
    ae4f:	ff 
    ae50:	f3 0f 59 44 24 70    	mulss  xmm0,DWORD PTR [rsp+0x70]
    ae56:	f3 0f 58 d0          	addss  xmm2,xmm0
    ae5a:	f3 0f 58 d3          	addss  xmm2,xmm3
    ae5e:	0f 28 c2             	movaps xmm0,xmm2
    ae61:	f3 0f 59 c2          	mulss  xmm0,xmm2
    ae65:	f3 0f 58 05 2f 68 ff 	addss  xmm0,DWORD PTR [rip+0xffffffffffff682f]        # 169c <_IO_stdin_used+0x10>
    ae6c:	ff 
    ae6d:	41 0f 46 ee          	cmovbe ebp,r14d
    ae71:	b8 01 00 00 00       	mov    eax,0x1
    ae76:	44 0f 47 f8          	cmova  r15d,eax
    ae7a:	0f 57 ff             	xorps  xmm7,xmm7
    ae7d:	0f 2e f8             	ucomiss xmm7,xmm0
    ae80:	41 be 28 6b 6e 4e    	mov    r14d,0x4e6e6b28
    ae86:	b8 28 6b 6e 4e       	mov    eax,0x4e6e6b28
    ae8b:	77 47                	ja     aed4 <spin_22+0x604>
    ae8d:	0f 57 c9             	xorps  xmm1,xmm1
    ae90:	0f 2e c1             	ucomiss xmm0,xmm1
    ae93:	f3 0f 5c ca          	subss  xmm1,xmm2
    ae97:	72 06                	jb     ae9f <spin_22+0x5cf>
    ae99:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    ae9d:	eb 1a                	jmp    aeb9 <spin_22+0x5e9>
    ae9f:	f3 0f 11 4c 24 20    	movss  DWORD PTR [rsp+0x20],xmm1
    aea5:	e8 86 3e 00 00       	call   ed30 <sqrtf@plt>
    aeaa:	f3 0f 10 4c 24 20    	movss  xmm1,DWORD PTR [rsp+0x20]
    aeb0:	0f 57 ff             	xorps  xmm7,xmm7
    aeb3:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    aeb9:	f3 0f 5c c8          	subss  xmm1,xmm0
    aebd:	66 0f 7e c9          	movd   ecx,xmm1
    aec1:	f3 0f 10 05 e7 67 ff 	movss  xmm0,DWORD PTR [rip+0xffffffffffff67e7]        # 16b0 <_IO_stdin_used+0x24>
    aec8:	ff 
    aec9:	0f 2e c1             	ucomiss xmm0,xmm1
    aecc:	b8 28 6b 6e 4e       	mov    eax,0x4e6e6b28
    aed1:	0f 46 c1             	cmovbe eax,ecx
    aed4:	66 0f 6e c0          	movd   xmm0,eax
    aed8:	66 0f 6e cd          	movd   xmm1,ebp
    aedc:	41 83 ff 09          	cmp    r15d,0x9
    aee0:	0f 94 c2             	sete   dl
    aee3:	31 f6                	xor    esi,esi
    aee5:	0f 2e c8             	ucomiss xmm1,xmm0
    aee8:	0f 96 c1             	setbe  cl
    aeeb:	0f 46 c5             	cmovbe eax,ebp
    aeee:	44 0f 47 fe          	cmova  r15d,esi
    aef2:	20 d1                	and    cl,dl
    aef4:	0f 57 c0             	xorps  xmm0,xmm0
    aef7:	0f 29 44 24 20       	movaps XMMWORD PTR [rsp+0x20],xmm0
    aefc:	f3 0f 10 05 34 67 ff 	movss  xmm0,DWORD PTR [rip+0xffffffffffff6734]        # 1638 <_IO_stdin_used-0x54>
    af03:	ff 
    af04:	48 c7 c3 fc ff ff ff 	mov    rbx,0xfffffffffffffffc
    af0b:	f3 0f 10 2d 9d 67 ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff679d]        # 16b0 <_IO_stdin_used+0x24>
    af12:	ff 
    af13:	31 d2                	xor    edx,edx
    af15:	0f 57 e4             	xorps  xmm4,xmm4
    af18:	f3 0f 11 84 24 dc 00 	movss  DWORD PTR [rsp+0xdc],xmm0
    af1f:	00 00 
    af21:	e9 bf 00 00 00       	jmp    afe5 <spin_22+0x715>
    af26:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
    af2d:	00 00 00 
    af30:	f3 0f 11 54 24 50    	movss  DWORD PTR [rsp+0x50],xmm2
    af36:	e8 f5 3d 00 00       	call   ed30 <sqrtf@plt>
    af3b:	f3 0f 10 54 24 50    	movss  xmm2,DWORD PTR [rsp+0x50]
    af41:	44 0f 28 44 24 10    	movaps xmm8,XMMWORD PTR [rsp+0x10]
    af47:	0f 28 64 24 30       	movaps xmm4,XMMWORD PTR [rsp+0x30]
    af4c:	0f 57 ff             	xorps  xmm7,xmm7
    af4f:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    af55:	f3 0f 10 2d 53 67 ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff6753]        # 16b0 <_IO_stdin_used+0x24>
    af5c:	ff 
    af5d:	0f 57 c9             	xorps  xmm1,xmm1
    af60:	f3 0f 5c ca          	subss  xmm1,xmm2
    af64:	f3 0f 5c c8          	subss  xmm1,xmm0
    af68:	0f 2e e9             	ucomiss xmm5,xmm1
    af6b:	66 0f 7e c8          	movd   eax,xmm1
    af6f:	41 0f 47 c6          	cmova  eax,r14d
    af73:	66 0f 6e c0          	movd   xmm0,eax
    af77:	66 0f 6e cd          	movd   xmm1,ebp
    af7b:	41 83 ff 09          	cmp    r15d,0x9
    af7f:	0f 94 c2             	sete   dl
    af82:	0f 2e c8             	ucomiss xmm1,xmm0
    af85:	0f 96 c1             	setbe  cl
    af88:	0f 46 c5             	cmovbe eax,ebp
    af8b:	be 00 00 00 00       	mov    esi,0x0
    af90:	44 0f 47 fe          	cmova  r15d,esi
    af94:	20 d1                	and    cl,dl
    af96:	f3 0f 10 84 24 4c 01 	movss  xmm0,DWORD PTR [rsp+0x14c]
    af9d:	00 00 
    af9f:	f3 0f 10 94 24 dc 00 	movss  xmm2,DWORD PTR [rsp+0xdc]
    afa6:	00 00 
    afa8:	f3 44 0f 59 c2       	mulss  xmm8,xmm2
    afad:	f3 0f 10 8c 24 98 00 	movss  xmm1,DWORD PTR [rsp+0x98]
    afb4:	00 00 
    afb6:	f3 0f 10 1d 7a 66 ff 	movss  xmm3,DWORD PTR [rip+0xffffffffffff667a]        # 1638 <_IO_stdin_used-0x54>
    afbd:	ff 
    afbe:	f3 0f 5c d9          	subss  xmm3,xmm1
    afc2:	f3 41 0f 59 d8       	mulss  xmm3,xmm8
    afc7:	f3 0f 58 d8          	addss  xmm3,xmm0
    afcb:	66 0f 7e da          	movd   edx,xmm3
    afcf:	f3 0f 59 d1          	mulss  xmm2,xmm1
    afd3:	f3 0f 11 94 24 dc 00 	movss  DWORD PTR [rsp+0xdc],xmm2
    afda:	00 00 
    afdc:	48 ff c3             	inc    rbx
    afdf:	0f 84 04 12 00 00    	je     c1e9 <spin_22+0x1919>
    afe5:	f6 c1 01             	test   cl,0x1
    afe8:	0f 85 c8 1c 00 00    	jne    ccb6 <spin_22+0x23e6>
    afee:	89 94 24 4c 01 00 00 	mov    DWORD PTR [rsp+0x14c],edx
    aff5:	41 83 ff 08          	cmp    r15d,0x8
    aff9:	b9 08 00 00 00       	mov    ecx,0x8
    affe:	44 0f 43 f9          	cmovae r15d,ecx
    b002:	42 8d 0c fd 00 00 00 	lea    ecx,[r15*8+0x0]
    b009:	00 
    b00a:	66 0f 6e d0          	movd   xmm2,eax
    b00e:	0f 28 c6             	movaps xmm0,xmm6
    b011:	f3 0f 59 c2          	mulss  xmm0,xmm2
    b015:	0f 28 cc             	movaps xmm1,xmm4
    b018:	f3 0f 58 c8          	addss  xmm1,xmm0
    b01c:	0f c6 d2 00          	shufps xmm2,xmm2,0x0
    b020:	0f 59 54 24 70       	mulps  xmm2,XMMWORD PTR [rsp+0x70]
    b025:	0f 28 44 24 20       	movaps xmm0,XMMWORD PTR [rsp+0x20]
    b02a:	0f 58 c2             	addps  xmm0,xmm2
    b02d:	48 8d 05 6c 69 ff ff 	lea    rax,[rip+0xffffffffffff696c]        # 19a0 <TAB_3>
    b034:	f3 0f 10 14 01       	movss  xmm2,DWORD PTR [rcx+rax*1]
    b039:	48 8d 05 10 69 ff ff 	lea    rax,[rip+0xffffffffffff6910]        # 1950 <TAB_2>
    b040:	f3 0f 10 1c 01       	movss  xmm3,DWORD PTR [rcx+rax*1]
    b045:	0f 14 da             	unpcklps xmm3,xmm2
    b048:	44 0f 28 c8          	movaps xmm9,xmm0
    b04c:	44 0f 5c cb          	subps  xmm9,xmm3
    b050:	48 8d 05 99 69 ff ff 	lea    rax,[rip+0xffffffffffff6999]        # 19f0 <TAB_4>
    b057:	f3 0f 10 14 01       	movss  xmm2,DWORD PTR [rcx+rax*1]
    b05c:	f2 44 0f 10 05 5b 67 	movsd  xmm8,QWORD PTR [rip+0xffffffffffff675b]        # 17c0 <_IO_stdin_used+0x134>
    b063:	ff ff 
    b065:	44 0f 5c c0          	subps  xmm8,xmm0
    b069:	41 0f 28 d8          	movaps xmm3,xmm8
    b06d:	41 0f 59 d8          	mulps  xmm3,xmm8
    b071:	f3 44 0f 10 15 06 66 	movss  xmm10,DWORD PTR [rip+0xffffffffffff6606]        # 1680 <_IO_stdin_used-0xc>
    b078:	ff ff 
    b07a:	f3 44 0f 5c d1       	subss  xmm10,xmm1
    b07f:	41 0f 28 e2          	movaps xmm4,xmm10
    b083:	f3 41 0f 59 e2       	mulss  xmm4,xmm10
    b088:	f3 0f 58 e3          	addss  xmm4,xmm3
    b08c:	0f c6 db 55          	shufps xmm3,xmm3,0x55
    b090:	f3 0f 58 dc          	addss  xmm3,xmm4
    b094:	f3 44 0f 51 db       	sqrtss xmm11,xmm3
    b099:	41 0f 28 db          	movaps xmm3,xmm11
    b09d:	0f 14 da             	unpcklps xmm3,xmm2
    b0a0:	0f c6 d2 00          	shufps xmm2,xmm2,0x0
    b0a4:	44 0f 5e ca          	divps  xmm9,xmm2
    b0a8:	0f 28 d1             	movaps xmm2,xmm1
    b0ab:	48 8d 05 4e 68 ff ff 	lea    rax,[rip+0xffffffffffff684e]        # 1900 <TAB_1>
    b0b2:	f3 0f 5c 14 01       	subss  xmm2,DWORD PTR [rcx+rax*1]
    b0b7:	44 0f 14 d2          	unpcklps xmm10,xmm2
    b0bb:	44 0f 5e d3          	divps  xmm10,xmm3
    b0bf:	41 0f 28 e2          	movaps xmm4,xmm10
    b0c3:	41 0f c6 e2 55       	shufps xmm4,xmm10,0x55
    b0c8:	0f 29 a4 24 f0 00 00 	movaps XMMWORD PTR [rsp+0xf0],xmm4
    b0cf:	00 
    b0d0:	f3 0f 59 e5          	mulss  xmm4,xmm5
    b0d4:	f3 0f 58 e1          	addss  xmm4,xmm1
    b0d8:	44 0f 29 9c 24 d0 01 	movaps XMMWORD PTR [rsp+0x1d0],xmm11
    b0df:	00 00 
    b0e1:	41 0f 28 cb          	movaps xmm1,xmm11
    b0e5:	41 0f c6 cb 00       	shufps xmm1,xmm11,0x0
    b0ea:	44 0f 5e c1          	divps  xmm8,xmm1
    b0ee:	44 0f 29 8c 24 50 01 	movaps XMMWORD PTR [rsp+0x150],xmm9
    b0f5:	00 00 
    b0f7:	41 0f 28 c9          	movaps xmm1,xmm9
    b0fb:	0f 59 0d fe 65 ff ff 	mulps  xmm1,XMMWORD PTR [rip+0xffffffffffff65fe]        # 1700 <_IO_stdin_used+0x74>
    b102:	0f 58 c8             	addps  xmm1,xmm0
    b105:	0f 28 c4             	movaps xmm0,xmm4
    b108:	f3 0f 58 05 9c 65 ff 	addss  xmm0,DWORD PTR [rip+0xffffffffffff659c]        # 16ac <_IO_stdin_used+0x20>
    b10f:	ff 
    b110:	0f 29 4c 24 20       	movaps XMMWORD PTR [rsp+0x20],xmm1
    b115:	0f 28 d1             	movaps xmm2,xmm1
    b118:	0f 58 15 a1 65 ff ff 	addps  xmm2,XMMWORD PTR [rip+0xffffffffffff65a1]        # 16c0 <_IO_stdin_used+0x34>
    b11f:	45 0f 28 ea          	movaps xmm13,xmm10
    b123:	f3 44 0f 59 e8       	mulss  xmm13,xmm0
    b128:	41 0f 28 d8          	movaps xmm3,xmm8
    b12c:	0f 59 da             	mulps  xmm3,xmm2
    b12f:	f3 44 0f 58 eb       	addss  xmm13,xmm3
    b134:	44 0f 28 cb          	movaps xmm9,xmm3
    b138:	44 0f c6 cb 55       	shufps xmm9,xmm3,0x55
    b13d:	f3 45 0f 58 e9       	addss  xmm13,xmm9
    b142:	f3 0f 11 84 24 20 01 	movss  DWORD PTR [rsp+0x120],xmm0
    b149:	00 00 
    b14b:	f3 0f 59 c0          	mulss  xmm0,xmm0
    b14f:	44 0f 28 da          	movaps xmm11,xmm2
    b153:	44 0f 59 da          	mulps  xmm11,xmm2
    b157:	f3 41 0f 58 c3       	addss  xmm0,xmm11
    b15c:	45 0f 28 e3          	movaps xmm12,xmm11
    b160:	45 0f c6 e3 55       	shufps xmm12,xmm11,0x55
    b165:	f3 41 0f 58 c4       	addss  xmm0,xmm12
    b16a:	f3 0f 10 0d c6 64 ff 	movss  xmm1,DWORD PTR [rip+0xffffffffffff64c6]        # 1638 <_IO_stdin_used-0x54>
    b171:	ff 
    b172:	f3 0f 5c c8          	subss  xmm1,xmm0
    b176:	41 0f 28 c5          	movaps xmm0,xmm13
    b17a:	f3 41 0f 59 c5       	mulss  xmm0,xmm13
    b17f:	f3 0f 11 8c 24 48 01 	movss  DWORD PTR [rsp+0x148],xmm1
    b186:	00 00 
    b188:	f3 0f 58 c1          	addss  xmm0,xmm1
    b18c:	41 bd 28 6b 6e 4e    	mov    r13d,0x4e6e6b28
    b192:	0f 2e f8             	ucomiss xmm7,xmm0
    b195:	bd 28 6b 6e 4e       	mov    ebp,0x4e6e6b28
    b19a:	f3 0f 11 74 24 0c    	movss  DWORD PTR [rsp+0xc],xmm6
    b1a0:	0f 29 64 24 30       	movaps XMMWORD PTR [rsp+0x30],xmm4
    b1a5:	44 0f 29 44 24 10    	movaps XMMWORD PTR [rsp+0x10],xmm8
    b1ab:	44 0f 29 54 24 50    	movaps XMMWORD PTR [rsp+0x50],xmm10
    b1b1:	0f 29 94 24 a0 01 00 	movaps XMMWORD PTR [rsp+0x1a0],xmm2
    b1b8:	00 
    b1b9:	0f 87 a1 00 00 00    	ja     b260 <spin_22+0x990>
    b1bf:	0f 2e c7             	ucomiss xmm0,xmm7
    b1c2:	72 0c                	jb     b1d0 <spin_22+0x900>
    b1c4:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    b1c8:	eb 7f                	jmp    b249 <spin_22+0x979>
    b1ca:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
    b1d0:	0f 29 5c 24 60       	movaps XMMWORD PTR [rsp+0x60],xmm3
    b1d5:	44 0f 29 8c 24 c0 00 	movaps XMMWORD PTR [rsp+0xc0],xmm9
    b1dc:	00 00 
    b1de:	44 0f 29 9c 24 80 00 	movaps XMMWORD PTR [rsp+0x80],xmm11
    b1e5:	00 00 
    b1e7:	44 0f 29 a4 24 a0 00 	movaps XMMWORD PTR [rsp+0xa0],xmm12
    b1ee:	00 00 
    b1f0:	44 0f 29 ac 24 e0 00 	movaps XMMWORD PTR [rsp+0xe0],xmm13
    b1f7:	00 00 
    b1f9:	e8 32 3b 00 00       	call   ed30 <sqrtf@plt>
    b1fe:	44 0f 28 ac 24 e0 00 	movaps xmm13,XMMWORD PTR [rsp+0xe0]
    b205:	00 00 
    b207:	44 0f 28 a4 24 a0 00 	movaps xmm12,XMMWORD PTR [rsp+0xa0]
    b20e:	00 00 
    b210:	44 0f 28 9c 24 80 00 	movaps xmm11,XMMWORD PTR [rsp+0x80]
    b217:	00 00 
    b219:	44 0f 28 8c 24 c0 00 	movaps xmm9,XMMWORD PTR [rsp+0xc0]
    b220:	00 00 
    b222:	0f 28 5c 24 60       	movaps xmm3,XMMWORD PTR [rsp+0x60]
    b227:	44 0f 28 54 24 50    	movaps xmm10,XMMWORD PTR [rsp+0x50]
    b22d:	44 0f 28 44 24 10    	movaps xmm8,XMMWORD PTR [rsp+0x10]
    b233:	0f 28 64 24 30       	movaps xmm4,XMMWORD PTR [rsp+0x30]
    b238:	0f 57 ff             	xorps  xmm7,xmm7
    b23b:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    b241:	f3 0f 10 2d 67 64 ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff6467]        # 16b0 <_IO_stdin_used+0x24>
    b248:	ff 
    b249:	0f 57 c9             	xorps  xmm1,xmm1
    b24c:	f3 41 0f 5c cd       	subss  xmm1,xmm13
    b251:	f3 0f 5c c8          	subss  xmm1,xmm0
    b255:	0f 2e e9             	ucomiss xmm5,xmm1
    b258:	66 0f 7e cd          	movd   ebp,xmm1
    b25c:	41 0f 47 ee          	cmova  ebp,r14d
    b260:	66 0f 6e c5          	movd   xmm0,ebp
    b264:	f3 0f 10 0d 38 64 ff 	movss  xmm1,DWORD PTR [rip+0xffffffffffff6438]        # 16a4 <_IO_stdin_used+0x18>
    b26b:	ff 
    b26c:	0f 2e c8             	ucomiss xmm1,xmm0
    b26f:	0f 28 cc             	movaps xmm1,xmm4
    b272:	f3 0f 58 0d fe 63 ff 	addss  xmm1,DWORD PTR [rip+0xffffffffffff63fe]        # 1678 <_IO_stdin_used-0x14>
    b279:	ff 
    b27a:	45 0f 28 ea          	movaps xmm13,xmm10
    b27e:	f3 44 0f 59 e9       	mulss  xmm13,xmm1
    b283:	f3 44 0f 58 eb       	addss  xmm13,xmm3
    b288:	f3 45 0f 58 e9       	addss  xmm13,xmm9
    b28d:	41 0f 28 c5          	movaps xmm0,xmm13
    b291:	f3 41 0f 59 c5       	mulss  xmm0,xmm13
    b296:	f3 0f 11 8c 24 a0 00 	movss  DWORD PTR [rsp+0xa0],xmm1
    b29d:	00 00 
    b29f:	f3 0f 59 c9          	mulss  xmm1,xmm1
    b2a3:	f3 41 0f 58 cb       	addss  xmm1,xmm11
    b2a8:	f3 41 0f 58 cc       	addss  xmm1,xmm12
    b2ad:	f3 0f 10 15 83 63 ff 	movss  xmm2,DWORD PTR [rip+0xffffffffffff6383]        # 1638 <_IO_stdin_used-0x54>
    b2b4:	ff 
    b2b5:	41 0f 46 ed          	cmovbe ebp,r13d
    b2b9:	f3 0f 5c d1          	subss  xmm2,xmm1
    b2bd:	f3 0f 11 94 24 44 01 	movss  DWORD PTR [rsp+0x144],xmm2
    b2c4:	00 00 
    b2c6:	f3 0f 58 c2          	addss  xmm0,xmm2
    b2ca:	0f 2e f8             	ucomiss xmm7,xmm0
    b2cd:	77 5e                	ja     b32d <spin_22+0xa5d>
    b2cf:	0f 2e c7             	ucomiss xmm0,xmm7
    b2d2:	72 0c                	jb     b2e0 <spin_22+0xa10>
    b2d4:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    b2d8:	eb 3b                	jmp    b315 <spin_22+0xa45>
    b2da:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
    b2e0:	f3 44 0f 11 6c 24 60 	movss  DWORD PTR [rsp+0x60],xmm13
    b2e7:	e8 44 3a 00 00       	call   ed30 <sqrtf@plt>
    b2ec:	f3 44 0f 10 6c 24 60 	movss  xmm13,DWORD PTR [rsp+0x60]
    b2f3:	44 0f 28 54 24 50    	movaps xmm10,XMMWORD PTR [rsp+0x50]
    b2f9:	44 0f 28 44 24 10    	movaps xmm8,XMMWORD PTR [rsp+0x10]
    b2ff:	0f 28 64 24 30       	movaps xmm4,XMMWORD PTR [rsp+0x30]
    b304:	0f 57 ff             	xorps  xmm7,xmm7
    b307:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    b30d:	f3 0f 10 2d 9b 63 ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff639b]        # 16b0 <_IO_stdin_used+0x24>
    b314:	ff 
    b315:	0f 57 c9             	xorps  xmm1,xmm1
    b318:	f3 41 0f 5c cd       	subss  xmm1,xmm13
    b31d:	f3 0f 5c c8          	subss  xmm1,xmm0
    b321:	0f 2e e9             	ucomiss xmm5,xmm1
    b324:	66 41 0f 7e cd       	movd   r13d,xmm1
    b329:	45 0f 47 ee          	cmova  r13d,r14d
    b32d:	66 41 0f 6e c5       	movd   xmm0,r13d
    b332:	66 0f 6e cd          	movd   xmm1,ebp
    b336:	0f 2e c8             	ucomiss xmm1,xmm0
    b339:	0f 28 4c 24 20       	movaps xmm1,XMMWORD PTR [rsp+0x20]
    b33e:	0f 58 0d 5b 64 ff ff 	addps  xmm1,XMMWORD PTR [rip+0xffffffffffff645b]        # 17a0 <_IO_stdin_used+0x114>
    b345:	41 0f 28 da          	movaps xmm3,xmm10
    b349:	f3 0f 59 dc          	mulss  xmm3,xmm4
    b34d:	45 0f 28 c8          	movaps xmm9,xmm8
    b351:	44 0f 59 c9          	mulps  xmm9,xmm1
    b355:	0f 28 c3             	movaps xmm0,xmm3
    b358:	f3 41 0f 58 c1       	addss  xmm0,xmm9
    b35d:	45 0f c6 c9 55       	shufps xmm9,xmm9,0x55
    b362:	f3 44 0f 58 c8       	addss  xmm9,xmm0
    b367:	41 0f 28 c1          	movaps xmm0,xmm9
    b36b:	f3 41 0f 59 c1       	mulss  xmm0,xmm9
    b370:	0f 28 d4             	movaps xmm2,xmm4
    b373:	f3 0f 59 d4          	mulss  xmm2,xmm4
    b377:	0f 29 8c 24 e0 00 00 	movaps XMMWORD PTR [rsp+0xe0],xmm1
    b37e:	00 
    b37f:	0f 59 c9             	mulps  xmm1,xmm1
    b382:	f3 0f 11 94 24 bc 00 	movss  DWORD PTR [rsp+0xbc],xmm2
    b389:	00 00 
    b38b:	f3 0f 58 d1          	addss  xmm2,xmm1
    b38f:	0f c6 c9 55          	shufps xmm1,xmm1,0x55
    b393:	f3 0f 58 ca          	addss  xmm1,xmm2
    b397:	f3 0f 10 15 01 63 ff 	movss  xmm2,DWORD PTR [rip+0xffffffffffff6301]        # 16a0 <_IO_stdin_used+0x14>
    b39e:	ff 
    b39f:	f3 0f 5c d1          	subss  xmm2,xmm1
    b3a3:	f3 0f 11 94 24 40 01 	movss  DWORD PTR [rsp+0x140],xmm2
    b3aa:	00 00 
    b3ac:	f3 0f 58 c2          	addss  xmm0,xmm2
    b3b0:	44 0f 46 ed          	cmovbe r13d,ebp
    b3b4:	0f 2e f8             	ucomiss xmm7,xmm0
    b3b7:	41 bc 28 6b 6e 4e    	mov    r12d,0x4e6e6b28
    b3bd:	bd 28 6b 6e 4e       	mov    ebp,0x4e6e6b28
    b3c2:	f3 0f 11 9c 24 98 00 	movss  DWORD PTR [rsp+0x98],xmm3
    b3c9:	00 00 
    b3cb:	77 66                	ja     b433 <spin_22+0xb63>
    b3cd:	0f 2e c7             	ucomiss xmm0,xmm7
    b3d0:	72 0e                	jb     b3e0 <spin_22+0xb10>
    b3d2:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    b3d6:	eb 44                	jmp    b41c <spin_22+0xb4c>
    b3d8:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
    b3df:	00 
    b3e0:	44 0f 29 4c 24 60    	movaps XMMWORD PTR [rsp+0x60],xmm9
    b3e6:	e8 45 39 00 00       	call   ed30 <sqrtf@plt>
    b3eb:	44 0f 28 4c 24 60    	movaps xmm9,XMMWORD PTR [rsp+0x60]
    b3f1:	f3 0f 10 9c 24 98 00 	movss  xmm3,DWORD PTR [rsp+0x98]
    b3f8:	00 00 
    b3fa:	44 0f 28 54 24 50    	movaps xmm10,XMMWORD PTR [rsp+0x50]
    b400:	44 0f 28 44 24 10    	movaps xmm8,XMMWORD PTR [rsp+0x10]
    b406:	0f 28 64 24 30       	movaps xmm4,XMMWORD PTR [rsp+0x30]
    b40b:	0f 57 ff             	xorps  xmm7,xmm7
    b40e:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    b414:	f3 0f 10 2d 94 62 ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff6294]        # 16b0 <_IO_stdin_used+0x24>
    b41b:	ff 
    b41c:	0f 57 c9             	xorps  xmm1,xmm1
    b41f:	f3 41 0f 5c c9       	subss  xmm1,xmm9
    b424:	f3 0f 5c c8          	subss  xmm1,xmm0
    b428:	0f 2e e9             	ucomiss xmm5,xmm1
    b42b:	66 0f 7e cd          	movd   ebp,xmm1
    b42f:	41 0f 47 ee          	cmova  ebp,r14d
    b433:	66 0f 6e c5          	movd   xmm0,ebp
    b437:	66 41 0f 6e cd       	movd   xmm1,r13d
    b43c:	0f 2e c8             	ucomiss xmm1,xmm0
    b43f:	0f 28 c4             	movaps xmm0,xmm4
    b442:	f3 0f 58 05 ee 61 ff 	addss  xmm0,DWORD PTR [rip+0xffffffffffff61ee]        # 1638 <_IO_stdin_used-0x54>
    b449:	ff 
    b44a:	0f 28 4c 24 20       	movaps xmm1,XMMWORD PTR [rsp+0x20]
    b44f:	0f 58 0d 8a 62 ff ff 	addps  xmm1,XMMWORD PTR [rip+0xffffffffffff628a]        # 16e0 <_IO_stdin_used+0x54>
    b456:	45 0f 28 ea          	movaps xmm13,xmm10
    b45a:	f3 44 0f 59 e8       	mulss  xmm13,xmm0
    b45f:	41 0f 28 d0          	movaps xmm2,xmm8
    b463:	0f 59 d1             	mulps  xmm2,xmm1
    b466:	f3 44 0f 58 ea       	addss  xmm13,xmm2
    b46b:	44 0f 28 ca          	movaps xmm9,xmm2
    b46f:	44 0f c6 ca 55       	shufps xmm9,xmm2,0x55
    b474:	f3 45 0f 58 e9       	addss  xmm13,xmm9
    b479:	f3 0f 11 44 24 4c    	movss  DWORD PTR [rsp+0x4c],xmm0
    b47f:	f3 0f 59 c0          	mulss  xmm0,xmm0
    b483:	0f 29 4c 24 60       	movaps XMMWORD PTR [rsp+0x60],xmm1
    b488:	44 0f 28 d9          	movaps xmm11,xmm1
    b48c:	44 0f 59 d9          	mulps  xmm11,xmm1
    b490:	f3 41 0f 58 c3       	addss  xmm0,xmm11
    b495:	45 0f 28 e3          	movaps xmm12,xmm11
    b499:	45 0f c6 e3 55       	shufps xmm12,xmm11,0x55
    b49e:	f3 41 0f 58 c4       	addss  xmm0,xmm12
    b4a3:	f3 0f 10 0d e9 61 ff 	movss  xmm1,DWORD PTR [rip+0xffffffffffff61e9]        # 1694 <_IO_stdin_used+0x8>
    b4aa:	ff 
    b4ab:	f3 0f 5c c8          	subss  xmm1,xmm0
    b4af:	41 0f 28 c5          	movaps xmm0,xmm13
    b4b3:	41 0f 46 ed          	cmovbe ebp,r13d
    b4b7:	f3 41 0f 59 c5       	mulss  xmm0,xmm13
    b4bc:	f3 0f 11 8c 24 3c 01 	movss  DWORD PTR [rsp+0x13c],xmm1
    b4c3:	00 00 
    b4c5:	f3 0f 58 c1          	addss  xmm0,xmm1
    b4c9:	0f 2e f8             	ucomiss xmm7,xmm0
    b4cc:	0f 87 b0 00 00 00    	ja     b582 <spin_22+0xcb2>
    b4d2:	0f 2e c7             	ucomiss xmm0,xmm7
    b4d5:	72 09                	jb     b4e0 <spin_22+0xc10>
    b4d7:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    b4db:	e9 8a 00 00 00       	jmp    b56a <spin_22+0xc9a>
    b4e0:	0f 29 94 24 c0 00 00 	movaps XMMWORD PTR [rsp+0xc0],xmm2
    b4e7:	00 
    b4e8:	44 0f 29 8c 24 80 00 	movaps XMMWORD PTR [rsp+0x80],xmm9
    b4ef:	00 00 
    b4f1:	44 0f 29 9c 24 10 01 	movaps XMMWORD PTR [rsp+0x110],xmm11
    b4f8:	00 00 
    b4fa:	44 0f 29 a4 24 70 01 	movaps XMMWORD PTR [rsp+0x170],xmm12
    b501:	00 00 
    b503:	f3 44 0f 11 ac 24 00 	movss  DWORD PTR [rsp+0x100],xmm13
    b50a:	01 00 00 
    b50d:	e8 1e 38 00 00       	call   ed30 <sqrtf@plt>
    b512:	f3 44 0f 10 ac 24 00 	movss  xmm13,DWORD PTR [rsp+0x100]
    b519:	01 00 00 
    b51c:	44 0f 28 a4 24 70 01 	movaps xmm12,XMMWORD PTR [rsp+0x170]
    b523:	00 00 
    b525:	44 0f 28 9c 24 10 01 	movaps xmm11,XMMWORD PTR [rsp+0x110]
    b52c:	00 00 
    b52e:	44 0f 28 8c 24 80 00 	movaps xmm9,XMMWORD PTR [rsp+0x80]
    b535:	00 00 
    b537:	0f 28 94 24 c0 00 00 	movaps xmm2,XMMWORD PTR [rsp+0xc0]
    b53e:	00 
    b53f:	f3 0f 10 9c 24 98 00 	movss  xmm3,DWORD PTR [rsp+0x98]
    b546:	00 00 
    b548:	44 0f 28 54 24 50    	movaps xmm10,XMMWORD PTR [rsp+0x50]
    b54e:	44 0f 28 44 24 10    	movaps xmm8,XMMWORD PTR [rsp+0x10]
    b554:	0f 28 64 24 30       	movaps xmm4,XMMWORD PTR [rsp+0x30]
    b559:	0f 57 ff             	xorps  xmm7,xmm7
    b55c:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    b562:	f3 0f 10 2d 46 61 ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff6146]        # 16b0 <_IO_stdin_used+0x24>
    b569:	ff 
    b56a:	0f 57 c9             	xorps  xmm1,xmm1
    b56d:	f3 41 0f 5c cd       	subss  xmm1,xmm13
    b572:	f3 0f 5c c8          	subss  xmm1,xmm0
    b576:	0f 2e e9             	ucomiss xmm5,xmm1
    b579:	66 41 0f 7e cc       	movd   r12d,xmm1
    b57e:	45 0f 47 e6          	cmova  r12d,r14d
    b582:	66 41 0f 6e c4       	movd   xmm0,r12d
    b587:	66 0f 6e cd          	movd   xmm1,ebp
    b58b:	0f 2e c8             	ucomiss xmm1,xmm0
    b58e:	0f 28 cc             	movaps xmm1,xmm4
    b591:	f3 0f 58 0d bb 60 ff 	addss  xmm1,DWORD PTR [rip+0xffffffffffff60bb]        # 1654 <_IO_stdin_used-0x38>
    b598:	ff 
    b599:	45 0f 28 ea          	movaps xmm13,xmm10
    b59d:	f3 44 0f 59 e9       	mulss  xmm13,xmm1
    b5a2:	f3 44 0f 58 ea       	addss  xmm13,xmm2
    b5a7:	f3 45 0f 58 e9       	addss  xmm13,xmm9
    b5ac:	41 0f 28 c5          	movaps xmm0,xmm13
    b5b0:	f3 41 0f 59 c5       	mulss  xmm0,xmm13
    b5b5:	f3 0f 11 8c 24 10 01 	movss  DWORD PTR [rsp+0x110],xmm1
    b5bc:	00 00 
    b5be:	f3 0f 59 c9          	mulss  xmm1,xmm1
    b5c2:	f3 41 0f 58 cb       	addss  xmm1,xmm11
    b5c7:	f3 41 0f 58 cc       	addss  xmm1,xmm12
    b5cc:	f3 0f 10 15 c0 60 ff 	movss  xmm2,DWORD PTR [rip+0xffffffffffff60c0]        # 1694 <_IO_stdin_used+0x8>
    b5d3:	ff 
    b5d4:	f3 0f 5c d1          	subss  xmm2,xmm1
    b5d8:	f3 0f 11 94 24 38 01 	movss  DWORD PTR [rsp+0x138],xmm2
    b5df:	00 00 
    b5e1:	f3 0f 58 c2          	addss  xmm0,xmm2
    b5e5:	44 0f 46 e5          	cmovbe r12d,ebp
    b5e9:	0f 2e f8             	ucomiss xmm7,xmm0
    b5ec:	41 bd 28 6b 6e 4e    	mov    r13d,0x4e6e6b28
    b5f2:	bd 28 6b 6e 4e       	mov    ebp,0x4e6e6b28
    b5f7:	77 72                	ja     b66b <spin_22+0xd9b>
    b5f9:	0f 2e c7             	ucomiss xmm0,xmm7
    b5fc:	72 12                	jb     b610 <spin_22+0xd40>
    b5fe:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    b602:	eb 50                	jmp    b654 <spin_22+0xd84>
    b604:	66 66 66 2e 0f 1f 84 	data16 data16 nop WORD PTR cs:[rax+rax*1+0x0]
    b60b:	00 00 00 00 00 
    b610:	f3 44 0f 11 ac 24 c0 	movss  DWORD PTR [rsp+0xc0],xmm13
    b617:	00 00 00 
    b61a:	e8 11 37 00 00       	call   ed30 <sqrtf@plt>
    b61f:	f3 44 0f 10 ac 24 c0 	movss  xmm13,DWORD PTR [rsp+0xc0]
    b626:	00 00 00 
    b629:	f3 0f 10 9c 24 98 00 	movss  xmm3,DWORD PTR [rsp+0x98]
    b630:	00 00 
    b632:	44 0f 28 54 24 50    	movaps xmm10,XMMWORD PTR [rsp+0x50]
    b638:	44 0f 28 44 24 10    	movaps xmm8,XMMWORD PTR [rsp+0x10]
    b63e:	0f 28 64 24 30       	movaps xmm4,XMMWORD PTR [rsp+0x30]
    b643:	0f 57 ff             	xorps  xmm7,xmm7
    b646:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    b64c:	f3 0f 10 2d 5c 60 ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff605c]        # 16b0 <_IO_stdin_used+0x24>
    b653:	ff 
    b654:	0f 57 c9             	xorps  xmm1,xmm1
    b657:	f3 41 0f 5c cd       	subss  xmm1,xmm13
    b65c:	f3 0f 5c c8          	subss  xmm1,xmm0
    b660:	0f 2e e9             	ucomiss xmm5,xmm1
    b663:	66 0f 7e cd          	movd   ebp,xmm1
    b667:	41 0f 47 ee          	cmova  ebp,r14d
    b66b:	66 0f 6e c5          	movd   xmm0,ebp
    b66f:	66 41 0f 6e cc       	movd   xmm1,r12d
    b674:	0f 2e c8             	ucomiss xmm1,xmm0
    b677:	0f 28 c4             	movaps xmm0,xmm4
    b67a:	f3 0f 58 05 ea 5f ff 	addss  xmm0,DWORD PTR [rip+0xffffffffffff5fea]        # 166c <_IO_stdin_used-0x20>
    b681:	ff 
    b682:	0f 28 4c 24 20       	movaps xmm1,XMMWORD PTR [rsp+0x20]
    b687:	0f 58 0d c2 60 ff ff 	addps  xmm1,XMMWORD PTR [rip+0xffffffffffff60c2]        # 1750 <_IO_stdin_used+0xc4>
    b68e:	45 0f 28 ea          	movaps xmm13,xmm10
    b692:	f3 44 0f 59 e8       	mulss  xmm13,xmm0
    b697:	41 0f 28 d0          	movaps xmm2,xmm8
    b69b:	0f 59 d1             	mulps  xmm2,xmm1
    b69e:	f3 44 0f 58 ea       	addss  xmm13,xmm2
    b6a3:	44 0f 28 ca          	movaps xmm9,xmm2
    b6a7:	44 0f c6 ca 55       	shufps xmm9,xmm2,0x55
    b6ac:	f3 45 0f 58 e9       	addss  xmm13,xmm9
    b6b1:	f3 0f 11 84 24 70 01 	movss  DWORD PTR [rsp+0x170],xmm0
    b6b8:	00 00 
    b6ba:	f3 0f 59 c0          	mulss  xmm0,xmm0
    b6be:	0f 29 8c 24 c0 00 00 	movaps XMMWORD PTR [rsp+0xc0],xmm1
    b6c5:	00 
    b6c6:	44 0f 28 d9          	movaps xmm11,xmm1
    b6ca:	44 0f 59 d9          	mulps  xmm11,xmm1
    b6ce:	f3 41 0f 58 c3       	addss  xmm0,xmm11
    b6d3:	45 0f 28 e3          	movaps xmm12,xmm11
    b6d7:	45 0f c6 e3 55       	shufps xmm12,xmm11,0x55
    b6dc:	f3 41 0f 58 c4       	addss  xmm0,xmm12
    b6e1:	f3 0f 10 0d 4f 5f ff 	movss  xmm1,DWORD PTR [rip+0xffffffffffff5f4f]        # 1638 <_IO_stdin_used-0x54>
    b6e8:	ff 
    b6e9:	f3 0f 5c c8          	subss  xmm1,xmm0
    b6ed:	41 0f 28 c5          	movaps xmm0,xmm13
    b6f1:	41 0f 46 ec          	cmovbe ebp,r12d
    b6f5:	f3 41 0f 59 c5       	mulss  xmm0,xmm13
    b6fa:	f3 0f 11 8c 24 34 01 	movss  DWORD PTR [rsp+0x134],xmm1
    b701:	00 00 
    b703:	f3 0f 58 c1          	addss  xmm0,xmm1
    b707:	0f 2e f8             	ucomiss xmm7,xmm0
    b70a:	0f 87 b2 00 00 00    	ja     b7c2 <spin_22+0xef2>
    b710:	0f 2e c7             	ucomiss xmm0,xmm7
    b713:	72 0b                	jb     b720 <spin_22+0xe50>
    b715:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    b719:	e9 8c 00 00 00       	jmp    b7aa <spin_22+0xeda>
    b71e:	66 90                	xchg   ax,ax
    b720:	0f 29 94 24 80 00 00 	movaps XMMWORD PTR [rsp+0x80],xmm2
    b727:	00 
    b728:	44 0f 29 8c 24 00 01 	movaps XMMWORD PTR [rsp+0x100],xmm9
    b72f:	00 00 
    b731:	44 0f 29 9c 24 90 01 	movaps XMMWORD PTR [rsp+0x190],xmm11
    b738:	00 00 
    b73a:	44 0f 29 a4 24 80 01 	movaps XMMWORD PTR [rsp+0x180],xmm12
    b741:	00 00 
    b743:	f3 44 0f 11 ac 24 60 	movss  DWORD PTR [rsp+0x160],xmm13
    b74a:	01 00 00 
    b74d:	e8 de 35 00 00       	call   ed30 <sqrtf@plt>
    b752:	f3 44 0f 10 ac 24 60 	movss  xmm13,DWORD PTR [rsp+0x160]
    b759:	01 00 00 
    b75c:	44 0f 28 a4 24 80 01 	movaps xmm12,XMMWORD PTR [rsp+0x180]
    b763:	00 00 
    b765:	44 0f 28 9c 24 90 01 	movaps xmm11,XMMWORD PTR [rsp+0x190]
    b76c:	00 00 
    b76e:	44 0f 28 8c 24 00 01 	movaps xmm9,XMMWORD PTR [rsp+0x100]
    b775:	00 00 
    b777:	0f 28 94 24 80 00 00 	movaps xmm2,XMMWORD PTR [rsp+0x80]
    b77e:	00 
    b77f:	f3 0f 10 9c 24 98 00 	movss  xmm3,DWORD PTR [rsp+0x98]
    b786:	00 00 
    b788:	44 0f 28 54 24 50    	movaps xmm10,XMMWORD PTR [rsp+0x50]
    b78e:	44 0f 28 44 24 10    	movaps xmm8,XMMWORD PTR [rsp+0x10]
    b794:	0f 28 64 24 30       	movaps xmm4,XMMWORD PTR [rsp+0x30]
    b799:	0f 57 ff             	xorps  xmm7,xmm7
    b79c:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    b7a2:	f3 0f 10 2d 06 5f ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff5f06]        # 16b0 <_IO_stdin_used+0x24>
    b7a9:	ff 
    b7aa:	0f 57 c9             	xorps  xmm1,xmm1
    b7ad:	f3 41 0f 5c cd       	subss  xmm1,xmm13
    b7b2:	f3 0f 5c c8          	subss  xmm1,xmm0
    b7b6:	0f 2e e9             	ucomiss xmm5,xmm1
    b7b9:	66 41 0f 7e cd       	movd   r13d,xmm1
    b7be:	45 0f 47 ee          	cmova  r13d,r14d
    b7c2:	66 41 0f 6e c5       	movd   xmm0,r13d
    b7c7:	66 0f 6e cd          	movd   xmm1,ebp
    b7cb:	0f 2e c8             	ucomiss xmm1,xmm0
    b7ce:	0f 28 cc             	movaps xmm1,xmm4
    b7d1:	f3 0f 58 0d 67 5e ff 	addss  xmm1,DWORD PTR [rip+0xffffffffffff5e67]        # 1640 <_IO_stdin_used-0x4c>
    b7d8:	ff 
    b7d9:	45 0f 28 ea          	movaps xmm13,xmm10
    b7dd:	f3 44 0f 59 e9       	mulss  xmm13,xmm1
    b7e2:	f3 44 0f 58 ea       	addss  xmm13,xmm2
    b7e7:	f3 45 0f 58 e9       	addss  xmm13,xmm9
    b7ec:	41 0f 28 c5          	movaps xmm0,xmm13
    b7f0:	f3 41 0f 59 c5       	mulss  xmm0,xmm13
    b7f5:	f3 0f 11 8c 24 00 01 	movss  DWORD PTR [rsp+0x100],xmm1
    b7fc:	00 00 
    b7fe:	f3 0f 59 c9          	mulss  xmm1,xmm1
    b802:	f3 41 0f 58 cb       	addss  xmm1,xmm11
    b807:	f3 41 0f 58 cc       	addss  xmm1,xmm12
    b80c:	f3 0f 10 15 24 5e ff 	movss  xmm2,DWORD PTR [rip+0xffffffffffff5e24]        # 1638 <_IO_stdin_used-0x54>
    b813:	ff 
    b814:	f3 0f 5c d1          	subss  xmm2,xmm1
    b818:	f3 0f 11 94 24 90 01 	movss  DWORD PTR [rsp+0x190],xmm2
    b81f:	00 00 
    b821:	f3 0f 58 c2          	addss  xmm0,xmm2
    b825:	44 0f 46 ed          	cmovbe r13d,ebp
    b829:	0f 2e f8             	ucomiss xmm7,xmm0
    b82c:	41 bc 28 6b 6e 4e    	mov    r12d,0x4e6e6b28
    b832:	bd 28 6b 6e 4e       	mov    ebp,0x4e6e6b28
    b837:	77 72                	ja     b8ab <spin_22+0xfdb>
    b839:	0f 2e c7             	ucomiss xmm0,xmm7
    b83c:	72 12                	jb     b850 <spin_22+0xf80>
    b83e:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    b842:	eb 50                	jmp    b894 <spin_22+0xfc4>
    b844:	66 66 66 2e 0f 1f 84 	data16 data16 nop WORD PTR cs:[rax+rax*1+0x0]
    b84b:	00 00 00 00 00 
    b850:	f3 44 0f 11 ac 24 80 	movss  DWORD PTR [rsp+0x80],xmm13
    b857:	00 00 00 
    b85a:	e8 d1 34 00 00       	call   ed30 <sqrtf@plt>
    b85f:	f3 44 0f 10 ac 24 80 	movss  xmm13,DWORD PTR [rsp+0x80]
    b866:	00 00 00 
    b869:	f3 0f 10 9c 24 98 00 	movss  xmm3,DWORD PTR [rsp+0x98]
    b870:	00 00 
    b872:	44 0f 28 54 24 50    	movaps xmm10,XMMWORD PTR [rsp+0x50]
    b878:	44 0f 28 44 24 10    	movaps xmm8,XMMWORD PTR [rsp+0x10]
    b87e:	0f 28 64 24 30       	movaps xmm4,XMMWORD PTR [rsp+0x30]
    b883:	0f 57 ff             	xorps  xmm7,xmm7
    b886:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    b88c:	f3 0f 10 2d 1c 5e ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff5e1c]        # 16b0 <_IO_stdin_used+0x24>
    b893:	ff 
    b894:	0f 57 c9             	xorps  xmm1,xmm1
    b897:	f3 41 0f 5c cd       	subss  xmm1,xmm13
    b89c:	f3 0f 5c c8          	subss  xmm1,xmm0
    b8a0:	0f 2e e9             	ucomiss xmm5,xmm1
    b8a3:	66 0f 7e cd          	movd   ebp,xmm1
    b8a7:	41 0f 47 ee          	cmova  ebp,r14d
    b8ab:	66 0f 6e c5          	movd   xmm0,ebp
    b8af:	66 41 0f 6e cd       	movd   xmm1,r13d
    b8b4:	0f 2e c8             	ucomiss xmm1,xmm0
    b8b7:	0f 28 4c 24 20       	movaps xmm1,XMMWORD PTR [rsp+0x20]
    b8bc:	0f 28 d1             	movaps xmm2,xmm1
    b8bf:	0f 58 15 6a 5e ff ff 	addps  xmm2,XMMWORD PTR [rip+0xffffffffffff5e6a]        # 1730 <_IO_stdin_used+0xa4>
    b8c6:	45 0f 28 c8          	movaps xmm9,xmm8
    b8ca:	44 0f 59 ca          	mulps  xmm9,xmm2
    b8ce:	44 0f 28 e3          	movaps xmm12,xmm3
    b8d2:	f3 45 0f 58 e1       	addss  xmm12,xmm9
    b8d7:	45 0f c6 c9 55       	shufps xmm9,xmm9,0x55
    b8dc:	f3 45 0f 58 e1       	addss  xmm12,xmm9
    b8e1:	41 0f 28 c4          	movaps xmm0,xmm12
    b8e5:	f3 41 0f 59 c4       	mulss  xmm0,xmm12
    b8ea:	f3 0f 59 c9          	mulss  xmm1,xmm1
    b8ee:	f3 0f 58 8c 24 bc 00 	addss  xmm1,DWORD PTR [rsp+0xbc]
    b8f5:	00 00 
    b8f7:	0f 29 94 24 80 00 00 	movaps XMMWORD PTR [rsp+0x80],xmm2
    b8fe:	00 
    b8ff:	44 0f 28 da          	movaps xmm11,xmm2
    b903:	44 0f 59 da          	mulps  xmm11,xmm2
    b907:	45 0f c6 db 55       	shufps xmm11,xmm11,0x55
    b90c:	f3 41 0f 58 cb       	addss  xmm1,xmm11
    b911:	f3 0f 10 15 1f 5d ff 	movss  xmm2,DWORD PTR [rip+0xffffffffffff5d1f]        # 1638 <_IO_stdin_used-0x54>
    b918:	ff 
    b919:	41 0f 46 ed          	cmovbe ebp,r13d
    b91d:	f3 0f 5c d1          	subss  xmm2,xmm1
    b921:	f3 0f 11 94 24 80 01 	movss  DWORD PTR [rsp+0x180],xmm2
    b928:	00 00 
    b92a:	f3 0f 58 c2          	addss  xmm0,xmm2
    b92e:	0f 2e f8             	ucomiss xmm7,xmm0
    b931:	0f 87 99 00 00 00    	ja     b9d0 <spin_22+0x1100>
    b937:	0f 2e c7             	ucomiss xmm0,xmm7
    b93a:	72 14                	jb     b950 <spin_22+0x1080>
    b93c:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    b940:	eb 76                	jmp    b9b8 <spin_22+0x10e8>
    b942:	66 66 66 66 66 2e 0f 	data16 data16 data16 data16 nop WORD PTR cs:[rax+rax*1+0x0]
    b949:	1f 84 00 00 00 00 00 
    b950:	44 0f 29 8c 24 60 01 	movaps XMMWORD PTR [rsp+0x160],xmm9
    b957:	00 00 
    b959:	44 0f 29 9c 24 c0 01 	movaps XMMWORD PTR [rsp+0x1c0],xmm11
    b960:	00 00 
    b962:	f3 44 0f 11 a4 24 30 	movss  DWORD PTR [rsp+0x130],xmm12
    b969:	01 00 00 
    b96c:	e8 bf 33 00 00       	call   ed30 <sqrtf@plt>
    b971:	f3 44 0f 10 a4 24 30 	movss  xmm12,DWORD PTR [rsp+0x130]
    b978:	01 00 00 
    b97b:	44 0f 28 9c 24 c0 01 	movaps xmm11,XMMWORD PTR [rsp+0x1c0]
    b982:	00 00 
    b984:	44 0f 28 8c 24 60 01 	movaps xmm9,XMMWORD PTR [rsp+0x160]
    b98b:	00 00 
    b98d:	f3 0f 10 9c 24 98 00 	movss  xmm3,DWORD PTR [rsp+0x98]
    b994:	00 00 
    b996:	44 0f 28 54 24 50    	movaps xmm10,XMMWORD PTR [rsp+0x50]
    b99c:	44 0f 28 44 24 10    	movaps xmm8,XMMWORD PTR [rsp+0x10]
    b9a2:	0f 28 64 24 30       	movaps xmm4,XMMWORD PTR [rsp+0x30]
    b9a7:	0f 57 ff             	xorps  xmm7,xmm7
    b9aa:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    b9b0:	f3 0f 10 2d f8 5c ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff5cf8]        # 16b0 <_IO_stdin_used+0x24>
    b9b7:	ff 
    b9b8:	0f 57 c9             	xorps  xmm1,xmm1
    b9bb:	f3 41 0f 5c cc       	subss  xmm1,xmm12
    b9c0:	f3 0f 5c c8          	subss  xmm1,xmm0
    b9c4:	0f 2e e9             	ucomiss xmm5,xmm1
    b9c7:	66 41 0f 7e cc       	movd   r12d,xmm1
    b9cc:	45 0f 47 e6          	cmova  r12d,r14d
    b9d0:	66 41 0f 6e c4       	movd   xmm0,r12d
    b9d5:	66 0f 6e cd          	movd   xmm1,ebp
    b9d9:	0f 2e c8             	ucomiss xmm1,xmm0
    b9dc:	0f 28 4c 24 20       	movaps xmm1,XMMWORD PTR [rsp+0x20]
    b9e1:	f3 0f 58 0d 77 5c ff 	addss  xmm1,DWORD PTR [rip+0xffffffffffff5c77]        # 1660 <_IO_stdin_used-0x2c>
    b9e8:	ff 
    b9e9:	41 0f 28 c0          	movaps xmm0,xmm8
    b9ed:	f3 0f 59 c1          	mulss  xmm0,xmm1
    b9f1:	f3 0f 58 d8          	addss  xmm3,xmm0
    b9f5:	f3 41 0f 58 d9       	addss  xmm3,xmm9
    b9fa:	0f 28 c3             	movaps xmm0,xmm3
    b9fd:	f3 0f 59 c3          	mulss  xmm0,xmm3
    ba01:	f3 0f 11 8c 24 60 01 	movss  DWORD PTR [rsp+0x160],xmm1
    ba08:	00 00 
    ba0a:	f3 0f 59 c9          	mulss  xmm1,xmm1
    ba0e:	f3 0f 10 94 24 bc 00 	movss  xmm2,DWORD PTR [rsp+0xbc]
    ba15:	00 00 
    ba17:	f3 0f 58 d1          	addss  xmm2,xmm1
    ba1b:	f3 41 0f 58 d3       	addss  xmm2,xmm11
    ba20:	f3 0f 10 0d 5c 5c ff 	movss  xmm1,DWORD PTR [rip+0xffffffffffff5c5c]        # 1684 <_IO_stdin_used-0x8>
    ba27:	ff 
    ba28:	f3 0f 5c ca          	subss  xmm1,xmm2
    ba2c:	44 0f 46 e5          	cmovbe r12d,ebp
    ba30:	f3 0f 11 8c 24 bc 00 	movss  DWORD PTR [rsp+0xbc],xmm1
    ba37:	00 00 
    ba39:	f3 0f 58 c1          	addss  xmm0,xmm1
    ba3d:	0f 2e f8             	ucomiss xmm7,xmm0
    ba40:	b8 28 6b 6e 4e       	mov    eax,0x4e6e6b28
    ba45:	77 68                	ja     baaf <spin_22+0x11df>
    ba47:	0f 2e c7             	ucomiss xmm0,xmm7
    ba4a:	72 14                	jb     ba60 <spin_22+0x1190>
    ba4c:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    ba50:	eb 47                	jmp    ba99 <spin_22+0x11c9>
    ba52:	66 66 66 66 66 2e 0f 	data16 data16 data16 data16 nop WORD PTR cs:[rax+rax*1+0x0]
    ba59:	1f 84 00 00 00 00 00 
    ba60:	f3 0f 11 9c 24 98 00 	movss  DWORD PTR [rsp+0x98],xmm3
    ba67:	00 00 
    ba69:	e8 c2 32 00 00       	call   ed30 <sqrtf@plt>
    ba6e:	f3 0f 10 9c 24 98 00 	movss  xmm3,DWORD PTR [rsp+0x98]
    ba75:	00 00 
    ba77:	44 0f 28 54 24 50    	movaps xmm10,XMMWORD PTR [rsp+0x50]
    ba7d:	44 0f 28 44 24 10    	movaps xmm8,XMMWORD PTR [rsp+0x10]
    ba83:	0f 28 64 24 30       	movaps xmm4,XMMWORD PTR [rsp+0x30]
    ba88:	0f 57 ff             	xorps  xmm7,xmm7
    ba8b:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    ba91:	f3 0f 10 2d 17 5c ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff5c17]        # 16b0 <_IO_stdin_used+0x24>
    ba98:	ff 
    ba99:	0f 57 c9             	xorps  xmm1,xmm1
    ba9c:	f3 0f 5c cb          	subss  xmm1,xmm3
    baa0:	f3 0f 5c c8          	subss  xmm1,xmm0
    baa4:	0f 2e e9             	ucomiss xmm5,xmm1
    baa7:	66 0f 7e c8          	movd   eax,xmm1
    baab:	41 0f 47 c6          	cmova  eax,r14d
    baaf:	66 0f 6e c0          	movd   xmm0,eax
    bab3:	66 41 0f 6e cc       	movd   xmm1,r12d
    bab8:	0f 2e c8             	ucomiss xmm1,xmm0
    babb:	f3 44 0f 59 94 24 f0 	mulss  xmm10,DWORD PTR [rsp+0xf0]
    bac2:	00 00 00 
    bac5:	44 0f 59 84 24 50 01 	mulps  xmm8,XMMWORD PTR [rsp+0x150]
    bacc:	00 00 
    bace:	f3 45 0f 58 d0       	addss  xmm10,xmm8
    bad3:	45 0f c6 c0 55       	shufps xmm8,xmm8,0x55
    bad8:	f3 45 0f 58 c2       	addss  xmm8,xmm10
    badd:	41 0f 46 c4          	cmovbe eax,r12d
    bae1:	66 0f 6e c0          	movd   xmm0,eax
    bae5:	41 0f 28 c8          	movaps xmm1,xmm8
    bae9:	f3 0f c2 cf 05       	cmpnltss xmm1,xmm7
    baee:	f3 0f c2 84 24 d0 01 	cmpnltss xmm0,DWORD PTR [rsp+0x1d0]
    baf5:	00 00 05 
    baf8:	0f 54 c1             	andps  xmm0,xmm1
    bafb:	66 0f 7e c0          	movd   eax,xmm0
    baff:	f3 44 0f 59 05 5c 5b 	mulss  xmm8,DWORD PTR [rip+0xffffffffffff5b5c]        # 1664 <_IO_stdin_used-0x28>
    bb06:	ff ff 
    bb08:	a8 01                	test   al,0x1
    bb0a:	75 14                	jne    bb20 <spin_22+0x1250>
    bb0c:	f3 44 0f 10 05 83 5b 	movss  xmm8,DWORD PTR [rip+0xffffffffffff5b83]        # 1698 <_IO_stdin_used+0xc>
    bb13:	ff ff 
    bb15:	eb 12                	jmp    bb29 <spin_22+0x1259>
    bb17:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
    bb1e:	00 00 
    bb20:	f3 44 0f 58 05 6f 5b 	addss  xmm8,DWORD PTR [rip+0xffffffffffff5b6f]        # 1698 <_IO_stdin_used+0xc>
    bb27:	ff ff 
    bb29:	48 8d 05 10 5f ff ff 	lea    rax,[rip+0xffffffffffff5f10]        # 1a40 <TAB_0>
    bb30:	4a 8b 04 f8          	mov    rax,QWORD PTR [rax+r15*8]
    bb34:	48 89 84 24 98 00 00 	mov    QWORD PTR [rsp+0x98],rax
    bb3b:	00 
    bb3c:	0f 28 c6             	movaps xmm0,xmm6
    bb3f:	44 0f 28 8c 24 f0 00 	movaps xmm9,XMMWORD PTR [rsp+0xf0]
    bb46:	00 00 
    bb48:	f3 41 0f 59 c1       	mulss  xmm0,xmm9
    bb4d:	0f 28 54 24 70       	movaps xmm2,XMMWORD PTR [rsp+0x70]
    bb52:	0f 28 ca             	movaps xmm1,xmm2
    bb55:	0f 28 9c 24 50 01 00 	movaps xmm3,XMMWORD PTR [rsp+0x150]
    bb5c:	00 
    bb5d:	0f 59 cb             	mulps  xmm1,xmm3
    bb60:	f3 0f 58 c1          	addss  xmm0,xmm1
    bb64:	0f c6 c9 55          	shufps xmm1,xmm1,0x55
    bb68:	f3 0f 58 c8          	addss  xmm1,xmm0
    bb6c:	f3 0f 58 c9          	addss  xmm1,xmm1
    bb70:	f3 44 0f 59 c9       	mulss  xmm9,xmm1
    bb75:	f3 41 0f 5c f1       	subss  xmm6,xmm9
    bb7a:	0f c6 c9 00          	shufps xmm1,xmm1,0x0
    bb7e:	0f 59 cb             	mulps  xmm1,xmm3
    bb81:	0f 5c d1             	subps  xmm2,xmm1
    bb84:	f3 0f 10 8c 24 20 01 	movss  xmm1,DWORD PTR [rsp+0x120]
    bb8b:	00 00 
    bb8d:	f3 0f 59 ce          	mulss  xmm1,xmm6
    bb91:	0f 29 54 24 70       	movaps XMMWORD PTR [rsp+0x70],xmm2
    bb96:	0f 28 84 24 a0 01 00 	movaps xmm0,XMMWORD PTR [rsp+0x1a0]
    bb9d:	00 
    bb9e:	0f 59 c2             	mulps  xmm0,xmm2
    bba1:	0f 28 d0             	movaps xmm2,xmm0
    bba4:	f3 0f 58 c8          	addss  xmm1,xmm0
    bba8:	44 0f 28 c8          	movaps xmm9,xmm0
    bbac:	44 0f c6 c8 55       	shufps xmm9,xmm0,0x55
    bbb1:	f3 41 0f 58 c9       	addss  xmm1,xmm9
    bbb6:	0f 28 c1             	movaps xmm0,xmm1
    bbb9:	f3 0f 59 c1          	mulss  xmm0,xmm1
    bbbd:	f3 0f 10 9c 24 48 01 	movss  xmm3,DWORD PTR [rsp+0x148]
    bbc4:	00 00 
    bbc6:	f3 0f 58 d8          	addss  xmm3,xmm0
    bbca:	41 bd 28 6b 6e 4e    	mov    r13d,0x4e6e6b28
    bbd0:	0f 2e fb             	ucomiss xmm7,xmm3
    bbd3:	bd 28 6b 6e 4e       	mov    ebp,0x4e6e6b28
    bbd8:	f3 0f 11 74 24 0c    	movss  DWORD PTR [rsp+0xc],xmm6
    bbde:	44 0f 29 44 24 10    	movaps XMMWORD PTR [rsp+0x10],xmm8
    bbe4:	77 72                	ja     bc58 <spin_22+0x1388>
    bbe6:	0f 28 c3             	movaps xmm0,xmm3
    bbe9:	f3 0f 11 8c 24 20 01 	movss  DWORD PTR [rsp+0x120],xmm1
    bbf0:	00 00 
    bbf2:	0f 2e df             	ucomiss xmm3,xmm7
    bbf5:	72 09                	jb     bc00 <spin_22+0x1330>
    bbf7:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    bbfb:	eb 40                	jmp    bc3d <spin_22+0x136d>
    bbfd:	0f 1f 00             	nop    DWORD PTR [rax]
    bc00:	0f 29 94 24 a0 01 00 	movaps XMMWORD PTR [rsp+0x1a0],xmm2
    bc07:	00 
    bc08:	44 0f 29 4c 24 50    	movaps XMMWORD PTR [rsp+0x50],xmm9
    bc0e:	e8 1d 31 00 00       	call   ed30 <sqrtf@plt>
    bc13:	44 0f 28 4c 24 50    	movaps xmm9,XMMWORD PTR [rsp+0x50]
    bc19:	0f 28 94 24 a0 01 00 	movaps xmm2,XMMWORD PTR [rsp+0x1a0]
    bc20:	00 
    bc21:	44 0f 28 44 24 10    	movaps xmm8,XMMWORD PTR [rsp+0x10]
    bc27:	0f 28 64 24 30       	movaps xmm4,XMMWORD PTR [rsp+0x30]
    bc2c:	0f 57 ff             	xorps  xmm7,xmm7
    bc2f:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    bc35:	f3 0f 10 2d 73 5a ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff5a73]        # 16b0 <_IO_stdin_used+0x24>
    bc3c:	ff 
    bc3d:	0f 57 c9             	xorps  xmm1,xmm1
    bc40:	f3 0f 5c 8c 24 20 01 	subss  xmm1,DWORD PTR [rsp+0x120]
    bc47:	00 00 
    bc49:	f3 0f 5c c8          	subss  xmm1,xmm0
    bc4d:	0f 2e e9             	ucomiss xmm5,xmm1
    bc50:	66 0f 7e cd          	movd   ebp,xmm1
    bc54:	41 0f 47 ee          	cmova  ebp,r14d
    bc58:	41 bc 28 6b 6e 4e    	mov    r12d,0x4e6e6b28
    bc5e:	66 0f 6e c5          	movd   xmm0,ebp
    bc62:	45 31 ff             	xor    r15d,r15d
    bc65:	f3 0f 10 0d 37 5a ff 	movss  xmm1,DWORD PTR [rip+0xffffffffffff5a37]        # 16a4 <_IO_stdin_used+0x18>
    bc6c:	ff 
    bc6d:	0f 2e c8             	ucomiss xmm1,xmm0
    bc70:	41 0f 96 c6          	setbe  r14b
    bc74:	f3 0f 10 8c 24 a0 00 	movss  xmm1,DWORD PTR [rsp+0xa0]
    bc7b:	00 00 
    bc7d:	f3 0f 59 ce          	mulss  xmm1,xmm6
    bc81:	f3 0f 58 ca          	addss  xmm1,xmm2
    bc85:	f3 41 0f 58 c9       	addss  xmm1,xmm9
    bc8a:	0f 28 c1             	movaps xmm0,xmm1
    bc8d:	41 0f 46 ed          	cmovbe ebp,r13d
    bc91:	f3 0f 59 c1          	mulss  xmm0,xmm1
    bc95:	f3 0f 10 94 24 44 01 	movss  xmm2,DWORD PTR [rsp+0x144]
    bc9c:	00 00 
    bc9e:	f3 0f 58 d0          	addss  xmm2,xmm0
    bca2:	0f 2e fa             	ucomiss xmm7,xmm2
    bca5:	77 56                	ja     bcfd <spin_22+0x142d>
    bca7:	0f 28 c2             	movaps xmm0,xmm2
    bcaa:	f3 0f 11 8c 24 a0 00 	movss  DWORD PTR [rsp+0xa0],xmm1
    bcb1:	00 00 
    bcb3:	0f 2e d7             	ucomiss xmm2,xmm7
    bcb6:	72 08                	jb     bcc0 <spin_22+0x13f0>
    bcb8:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    bcbc:	eb 23                	jmp    bce1 <spin_22+0x1411>
    bcbe:	66 90                	xchg   ax,ax
    bcc0:	e8 6b 30 00 00       	call   ed30 <sqrtf@plt>
    bcc5:	44 0f 28 44 24 10    	movaps xmm8,XMMWORD PTR [rsp+0x10]
    bccb:	0f 28 64 24 30       	movaps xmm4,XMMWORD PTR [rsp+0x30]
    bcd0:	0f 57 ff             	xorps  xmm7,xmm7
    bcd3:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    bcd9:	f3 0f 10 2d cf 59 ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff59cf]        # 16b0 <_IO_stdin_used+0x24>
    bce0:	ff 
    bce1:	0f 57 c9             	xorps  xmm1,xmm1
    bce4:	f3 0f 5c 8c 24 a0 00 	subss  xmm1,DWORD PTR [rsp+0xa0]
    bceb:	00 00 
    bced:	f3 0f 5c c8          	subss  xmm1,xmm0
    bcf1:	0f 2e e9             	ucomiss xmm5,xmm1
    bcf4:	66 41 0f 7e cd       	movd   r13d,xmm1
    bcf9:	45 0f 47 ec          	cmova  r13d,r12d
    bcfd:	45 88 f7             	mov    r15b,r14b
    bd00:	41 83 cf 08          	or     r15d,0x8
    bd04:	66 41 0f 6e c5       	movd   xmm0,r13d
    bd09:	66 0f 6e cd          	movd   xmm1,ebp
    bd0d:	0f 2e c8             	ucomiss xmm1,xmm0
    bd10:	0f 28 c4             	movaps xmm0,xmm4
    bd13:	f3 0f 59 c6          	mulss  xmm0,xmm6
    bd17:	0f 28 8c 24 e0 00 00 	movaps xmm1,XMMWORD PTR [rsp+0xe0]
    bd1e:	00 
    bd1f:	0f 59 4c 24 70       	mulps  xmm1,XMMWORD PTR [rsp+0x70]
    bd24:	f3 0f 11 44 24 50    	movss  DWORD PTR [rsp+0x50],xmm0
    bd2a:	f3 0f 58 c1          	addss  xmm0,xmm1
    bd2e:	0f c6 c9 55          	shufps xmm1,xmm1,0x55
    bd32:	f3 0f 58 c8          	addss  xmm1,xmm0
    bd36:	0f 28 c1             	movaps xmm0,xmm1
    bd39:	f3 0f 59 c1          	mulss  xmm0,xmm1
    bd3d:	44 0f 46 ed          	cmovbe r13d,ebp
    bd41:	f3 0f 10 94 24 40 01 	movss  xmm2,DWORD PTR [rsp+0x140]
    bd48:	00 00 
    bd4a:	f3 0f 58 d0          	addss  xmm2,xmm0
    bd4e:	b8 07 00 00 00       	mov    eax,0x7
    bd53:	44 0f 47 f8          	cmova  r15d,eax
    bd57:	0f 2e fa             	ucomiss xmm7,xmm2
    bd5a:	bd 28 6b 6e 4e       	mov    ebp,0x4e6e6b28
    bd5f:	41 be 28 6b 6e 4e    	mov    r14d,0x4e6e6b28
    bd65:	77 56                	ja     bdbd <spin_22+0x14ed>
    bd67:	0f 28 c2             	movaps xmm0,xmm2
    bd6a:	0f 29 8c 24 e0 00 00 	movaps XMMWORD PTR [rsp+0xe0],xmm1
    bd71:	00 
    bd72:	0f 2e d7             	ucomiss xmm2,xmm7
    bd75:	72 09                	jb     bd80 <spin_22+0x14b0>
    bd77:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    bd7b:	eb 24                	jmp    bda1 <spin_22+0x14d1>
    bd7d:	0f 1f 00             	nop    DWORD PTR [rax]
    bd80:	e8 ab 2f 00 00       	call   ed30 <sqrtf@plt>
    bd85:	44 0f 28 44 24 10    	movaps xmm8,XMMWORD PTR [rsp+0x10]
    bd8b:	0f 28 64 24 30       	movaps xmm4,XMMWORD PTR [rsp+0x30]
    bd90:	0f 57 ff             	xorps  xmm7,xmm7
    bd93:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    bd99:	f3 0f 10 2d 0f 59 ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff590f]        # 16b0 <_IO_stdin_used+0x24>
    bda0:	ff 
    bda1:	0f 57 c9             	xorps  xmm1,xmm1
    bda4:	f3 0f 5c 8c 24 e0 00 	subss  xmm1,DWORD PTR [rsp+0xe0]
    bdab:	00 00 
    bdad:	f3 0f 5c c8          	subss  xmm1,xmm0
    bdb1:	0f 2e e9             	ucomiss xmm5,xmm1
    bdb4:	66 41 0f 7e ce       	movd   r14d,xmm1
    bdb9:	45 0f 47 f4          	cmova  r14d,r12d
    bdbd:	66 41 0f 6e c6       	movd   xmm0,r14d
    bdc2:	66 41 0f 6e cd       	movd   xmm1,r13d
    bdc7:	0f 2e c8             	ucomiss xmm1,xmm0
    bdca:	f3 0f 10 4c 24 4c    	movss  xmm1,DWORD PTR [rsp+0x4c]
    bdd0:	f3 0f 59 ce          	mulss  xmm1,xmm6
    bdd4:	0f 28 44 24 60       	movaps xmm0,XMMWORD PTR [rsp+0x60]
    bdd9:	0f 59 44 24 70       	mulps  xmm0,XMMWORD PTR [rsp+0x70]
    bdde:	f3 0f 58 c8          	addss  xmm1,xmm0
    bde2:	0f 29 44 24 60       	movaps XMMWORD PTR [rsp+0x60],xmm0
    bde7:	0f 28 d8             	movaps xmm3,xmm0
    bdea:	0f c6 d8 55          	shufps xmm3,xmm0,0x55
    bdee:	f3 0f 58 cb          	addss  xmm1,xmm3
    bdf2:	45 0f 46 f5          	cmovbe r14d,r13d
    bdf6:	0f 28 c1             	movaps xmm0,xmm1
    bdf9:	b8 06 00 00 00       	mov    eax,0x6
    bdfe:	44 0f 47 f8          	cmova  r15d,eax
    be02:	f3 0f 59 c1          	mulss  xmm0,xmm1
    be06:	f3 0f 10 94 24 3c 01 	movss  xmm2,DWORD PTR [rsp+0x13c]
    be0d:	00 00 
    be0f:	f3 0f 58 d0          	addss  xmm2,xmm0
    be13:	0f 2e fa             	ucomiss xmm7,xmm2
    be16:	77 61                	ja     be79 <spin_22+0x15a9>
    be18:	0f 28 c2             	movaps xmm0,xmm2
    be1b:	f3 0f 11 4c 24 4c    	movss  DWORD PTR [rsp+0x4c],xmm1
    be21:	0f 2e d7             	ucomiss xmm2,xmm7
    be24:	72 0a                	jb     be30 <spin_22+0x1560>
    be26:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    be2a:	eb 35                	jmp    be61 <spin_22+0x1591>
    be2c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
    be30:	0f 29 9c 24 50 01 00 	movaps XMMWORD PTR [rsp+0x150],xmm3
    be37:	00 
    be38:	e8 f3 2e 00 00       	call   ed30 <sqrtf@plt>
    be3d:	0f 28 9c 24 50 01 00 	movaps xmm3,XMMWORD PTR [rsp+0x150]
    be44:	00 
    be45:	44 0f 28 44 24 10    	movaps xmm8,XMMWORD PTR [rsp+0x10]
    be4b:	0f 28 64 24 30       	movaps xmm4,XMMWORD PTR [rsp+0x30]
    be50:	0f 57 ff             	xorps  xmm7,xmm7
    be53:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    be59:	f3 0f 10 2d 4f 58 ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff584f]        # 16b0 <_IO_stdin_used+0x24>
    be60:	ff 
    be61:	0f 57 c9             	xorps  xmm1,xmm1
    be64:	f3 0f 5c 4c 24 4c    	subss  xmm1,DWORD PTR [rsp+0x4c]
    be6a:	f3 0f 5c c8          	subss  xmm1,xmm0
    be6e:	0f 2e e9             	ucomiss xmm5,xmm1
    be71:	66 0f 7e cd          	movd   ebp,xmm1
    be75:	41 0f 47 ec          	cmova  ebp,r12d
    be79:	66 0f 6e c5          	movd   xmm0,ebp
    be7d:	66 41 0f 6e ce       	movd   xmm1,r14d
    be82:	0f 2e c8             	ucomiss xmm1,xmm0
    be85:	f3 0f 10 8c 24 10 01 	movss  xmm1,DWORD PTR [rsp+0x110]
    be8c:	00 00 
    be8e:	f3 0f 59 ce          	mulss  xmm1,xmm6
    be92:	f3 0f 58 4c 24 60    	addss  xmm1,DWORD PTR [rsp+0x60]
    be98:	f3 0f 58 cb          	addss  xmm1,xmm3
    be9c:	0f 28 c1             	movaps xmm0,xmm1
    be9f:	f3 0f 59 c1          	mulss  xmm0,xmm1
    bea3:	41 0f 46 ee          	cmovbe ebp,r14d
    bea7:	f3 0f 10 94 24 38 01 	movss  xmm2,DWORD PTR [rsp+0x138]
    beae:	00 00 
    beb0:	f3 0f 58 d0          	addss  xmm2,xmm0
    beb4:	b8 05 00 00 00       	mov    eax,0x5
    beb9:	44 0f 47 f8          	cmova  r15d,eax
    bebd:	0f 2e fa             	ucomiss xmm7,xmm2
    bec0:	41 bd 28 6b 6e 4e    	mov    r13d,0x4e6e6b28
    bec6:	41 be 28 6b 6e 4e    	mov    r14d,0x4e6e6b28
    becc:	77 5f                	ja     bf2d <spin_22+0x165d>
    bece:	0f 28 c2             	movaps xmm0,xmm2
    bed1:	f3 0f 11 8c 24 10 01 	movss  DWORD PTR [rsp+0x110],xmm1
    bed8:	00 00 
    beda:	0f 2e d7             	ucomiss xmm2,xmm7
    bedd:	72 11                	jb     bef0 <spin_22+0x1620>
    bedf:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    bee3:	eb 2c                	jmp    bf11 <spin_22+0x1641>
    bee5:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
    beec:	00 00 00 00 
    bef0:	e8 3b 2e 00 00       	call   ed30 <sqrtf@plt>
    bef5:	44 0f 28 44 24 10    	movaps xmm8,XMMWORD PTR [rsp+0x10]
    befb:	0f 28 64 24 30       	movaps xmm4,XMMWORD PTR [rsp+0x30]
    bf00:	0f 57 ff             	xorps  xmm7,xmm7
    bf03:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    bf09:	f3 0f 10 2d 9f 57 ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff579f]        # 16b0 <_IO_stdin_used+0x24>
    bf10:	ff 
    bf11:	0f 57 c9             	xorps  xmm1,xmm1
    bf14:	f3 0f 5c 8c 24 10 01 	subss  xmm1,DWORD PTR [rsp+0x110]
    bf1b:	00 00 
    bf1d:	f3 0f 5c c8          	subss  xmm1,xmm0
    bf21:	0f 2e e9             	ucomiss xmm5,xmm1
    bf24:	66 41 0f 7e ce       	movd   r14d,xmm1
    bf29:	45 0f 47 f4          	cmova  r14d,r12d
    bf2d:	66 41 0f 6e c6       	movd   xmm0,r14d
    bf32:	66 0f 6e cd          	movd   xmm1,ebp
    bf36:	0f 2e c8             	ucomiss xmm1,xmm0
    bf39:	f3 0f 10 8c 24 70 01 	movss  xmm1,DWORD PTR [rsp+0x170]
    bf40:	00 00 
    bf42:	f3 0f 59 ce          	mulss  xmm1,xmm6
    bf46:	0f 28 84 24 c0 00 00 	movaps xmm0,XMMWORD PTR [rsp+0xc0]
    bf4d:	00 
    bf4e:	0f 59 44 24 70       	mulps  xmm0,XMMWORD PTR [rsp+0x70]
    bf53:	f3 0f 58 c8          	addss  xmm1,xmm0
    bf57:	0f 29 84 24 c0 00 00 	movaps XMMWORD PTR [rsp+0xc0],xmm0
    bf5e:	00 
    bf5f:	0f 28 d8             	movaps xmm3,xmm0
    bf62:	0f c6 d8 55          	shufps xmm3,xmm0,0x55
    bf66:	f3 0f 58 cb          	addss  xmm1,xmm3
    bf6a:	44 0f 46 f5          	cmovbe r14d,ebp
    bf6e:	0f 28 c1             	movaps xmm0,xmm1
    bf71:	b8 04 00 00 00       	mov    eax,0x4
    bf76:	44 0f 47 f8          	cmova  r15d,eax
    bf7a:	f3 0f 59 c1          	mulss  xmm0,xmm1
    bf7e:	f3 0f 10 94 24 34 01 	movss  xmm2,DWORD PTR [rsp+0x134]
    bf85:	00 00 
    bf87:	f3 0f 58 d0          	addss  xmm2,xmm0
    bf8b:	0f 2e fa             	ucomiss xmm7,xmm2
    bf8e:	77 67                	ja     bff7 <spin_22+0x1727>
    bf90:	0f 28 c2             	movaps xmm0,xmm2
    bf93:	f3 0f 11 8c 24 70 01 	movss  DWORD PTR [rsp+0x170],xmm1
    bf9a:	00 00 
    bf9c:	0f 2e d7             	ucomiss xmm2,xmm7
    bf9f:	72 0f                	jb     bfb0 <spin_22+0x16e0>
    bfa1:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    bfa5:	eb 34                	jmp    bfdb <spin_22+0x170b>
    bfa7:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
    bfae:	00 00 
    bfb0:	0f 29 5c 24 60       	movaps XMMWORD PTR [rsp+0x60],xmm3
    bfb5:	e8 76 2d 00 00       	call   ed30 <sqrtf@plt>
    bfba:	0f 28 5c 24 60       	movaps xmm3,XMMWORD PTR [rsp+0x60]
    bfbf:	44 0f 28 44 24 10    	movaps xmm8,XMMWORD PTR [rsp+0x10]
    bfc5:	0f 28 64 24 30       	movaps xmm4,XMMWORD PTR [rsp+0x30]
    bfca:	0f 57 ff             	xorps  xmm7,xmm7
    bfcd:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    bfd3:	f3 0f 10 2d d5 56 ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff56d5]        # 16b0 <_IO_stdin_used+0x24>
    bfda:	ff 
    bfdb:	0f 57 c9             	xorps  xmm1,xmm1
    bfde:	f3 0f 5c 8c 24 70 01 	subss  xmm1,DWORD PTR [rsp+0x170]
    bfe5:	00 00 
    bfe7:	f3 0f 5c c8          	subss  xmm1,xmm0
    bfeb:	0f 2e e9             	ucomiss xmm5,xmm1
    bfee:	66 41 0f 7e cd       	movd   r13d,xmm1
    bff3:	45 0f 47 ec          	cmova  r13d,r12d
    bff7:	66 41 0f 6e c5       	movd   xmm0,r13d
    bffc:	66 41 0f 6e ce       	movd   xmm1,r14d
    c001:	0f 2e c8             	ucomiss xmm1,xmm0
    c004:	f3 0f 10 8c 24 00 01 	movss  xmm1,DWORD PTR [rsp+0x100]
    c00b:	00 00 
    c00d:	f3 0f 59 ce          	mulss  xmm1,xmm6
    c011:	f3 0f 58 8c 24 c0 00 	addss  xmm1,DWORD PTR [rsp+0xc0]
    c018:	00 00 
    c01a:	f3 0f 58 cb          	addss  xmm1,xmm3
    c01e:	0f 28 c1             	movaps xmm0,xmm1
    c021:	f3 0f 59 c1          	mulss  xmm0,xmm1
    c025:	45 0f 46 ee          	cmovbe r13d,r14d
    c029:	f3 0f 10 94 24 90 01 	movss  xmm2,DWORD PTR [rsp+0x190]
    c030:	00 00 
    c032:	f3 0f 58 d0          	addss  xmm2,xmm0
    c036:	0f 28 c2             	movaps xmm0,xmm2
    c039:	b8 03 00 00 00       	mov    eax,0x3
    c03e:	44 0f 47 f8          	cmova  r15d,eax
    c042:	0f 2e fa             	ucomiss xmm7,xmm2
    c045:	bd 28 6b 6e 4e       	mov    ebp,0x4e6e6b28
    c04a:	41 be 28 6b 6e 4e    	mov    r14d,0x4e6e6b28
    c050:	f3 0f 10 54 24 50    	movss  xmm2,DWORD PTR [rsp+0x50]
    c056:	77 5b                	ja     c0b3 <spin_22+0x17e3>
    c058:	f3 0f 11 8c 24 00 01 	movss  DWORD PTR [rsp+0x100],xmm1
    c05f:	00 00 
    c061:	0f 2e c7             	ucomiss xmm0,xmm7
    c064:	72 0a                	jb     c070 <spin_22+0x17a0>
    c066:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    c06a:	eb 2b                	jmp    c097 <spin_22+0x17c7>
    c06c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
    c070:	e8 bb 2c 00 00       	call   ed30 <sqrtf@plt>
    c075:	f3 0f 10 54 24 50    	movss  xmm2,DWORD PTR [rsp+0x50]
    c07b:	44 0f 28 44 24 10    	movaps xmm8,XMMWORD PTR [rsp+0x10]
    c081:	0f 28 64 24 30       	movaps xmm4,XMMWORD PTR [rsp+0x30]
    c086:	0f 57 ff             	xorps  xmm7,xmm7
    c089:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    c08f:	f3 0f 10 2d 19 56 ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff5619]        # 16b0 <_IO_stdin_used+0x24>
    c096:	ff 
    c097:	0f 57 c9             	xorps  xmm1,xmm1
    c09a:	f3 0f 5c 8c 24 00 01 	subss  xmm1,DWORD PTR [rsp+0x100]
    c0a1:	00 00 
    c0a3:	f3 0f 5c c8          	subss  xmm1,xmm0
    c0a7:	0f 2e e9             	ucomiss xmm5,xmm1
    c0aa:	66 41 0f 7e ce       	movd   r14d,xmm1
    c0af:	45 0f 47 f4          	cmova  r14d,r12d
    c0b3:	66 41 0f 6e c6       	movd   xmm0,r14d
    c0b8:	66 41 0f 6e cd       	movd   xmm1,r13d
    c0bd:	0f 2e c8             	ucomiss xmm1,xmm0
    c0c0:	0f 28 5c 24 20       	movaps xmm3,XMMWORD PTR [rsp+0x20]
    c0c5:	0f 28 44 24 70       	movaps xmm0,XMMWORD PTR [rsp+0x70]
    c0ca:	f3 0f 59 d8          	mulss  xmm3,xmm0
    c0ce:	f3 0f 58 da          	addss  xmm3,xmm2
    c0d2:	0f 28 8c 24 80 00 00 	movaps xmm1,XMMWORD PTR [rsp+0x80]
    c0d9:	00 
    c0da:	0f 59 c8             	mulps  xmm1,xmm0
    c0dd:	0f c6 c9 55          	shufps xmm1,xmm1,0x55
    c0e1:	0f 29 8c 24 80 00 00 	movaps XMMWORD PTR [rsp+0x80],xmm1
    c0e8:	00 
    c0e9:	f3 0f 58 d9          	addss  xmm3,xmm1
    c0ed:	45 0f 46 f5          	cmovbe r14d,r13d
    c0f1:	0f 28 c3             	movaps xmm0,xmm3
    c0f4:	b8 02 00 00 00       	mov    eax,0x2
    c0f9:	44 0f 47 f8          	cmova  r15d,eax
    c0fd:	f3 0f 59 c3          	mulss  xmm0,xmm3
    c101:	f3 0f 10 8c 24 80 01 	movss  xmm1,DWORD PTR [rsp+0x180]
    c108:	00 00 
    c10a:	f3 0f 58 c8          	addss  xmm1,xmm0
    c10e:	0f 2e f9             	ucomiss xmm7,xmm1
    c111:	77 64                	ja     c177 <spin_22+0x18a7>
    c113:	0f 28 c1             	movaps xmm0,xmm1
    c116:	0f 2e cf             	ucomiss xmm1,xmm7
    c119:	72 15                	jb     c130 <spin_22+0x1860>
    c11b:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    c11f:	eb 40                	jmp    c161 <spin_22+0x1891>
    c121:	66 66 66 66 66 66 2e 	data16 data16 data16 data16 data16 nop WORD PTR cs:[rax+rax*1+0x0]
    c128:	0f 1f 84 00 00 00 00 
    c12f:	00 
    c130:	0f 29 5c 24 60       	movaps XMMWORD PTR [rsp+0x60],xmm3
    c135:	e8 f6 2b 00 00       	call   ed30 <sqrtf@plt>
    c13a:	0f 28 5c 24 60       	movaps xmm3,XMMWORD PTR [rsp+0x60]
    c13f:	f3 0f 10 54 24 50    	movss  xmm2,DWORD PTR [rsp+0x50]
    c145:	44 0f 28 44 24 10    	movaps xmm8,XMMWORD PTR [rsp+0x10]
    c14b:	0f 28 64 24 30       	movaps xmm4,XMMWORD PTR [rsp+0x30]
    c150:	0f 57 ff             	xorps  xmm7,xmm7
    c153:	f3 0f 10 74 24 0c    	movss  xmm6,DWORD PTR [rsp+0xc]
    c159:	f3 0f 10 2d 4f 55 ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff554f]        # 16b0 <_IO_stdin_used+0x24>
    c160:	ff 
    c161:	0f 57 c9             	xorps  xmm1,xmm1
    c164:	f3 0f 5c cb          	subss  xmm1,xmm3
    c168:	f3 0f 5c c8          	subss  xmm1,xmm0
    c16c:	0f 2e e9             	ucomiss xmm5,xmm1
    c16f:	66 0f 7e cd          	movd   ebp,xmm1
    c173:	41 0f 47 ec          	cmova  ebp,r12d
    c177:	66 0f 6e c5          	movd   xmm0,ebp
    c17b:	66 41 0f 6e ce       	movd   xmm1,r14d
    c180:	0f 2e c8             	ucomiss xmm1,xmm0
    c183:	f3 0f 10 84 24 60 01 	movss  xmm0,DWORD PTR [rsp+0x160]
    c18a:	00 00 
    c18c:	f3 0f 59 44 24 70    	mulss  xmm0,DWORD PTR [rsp+0x70]
    c192:	f3 0f 58 d0          	addss  xmm2,xmm0
    c196:	f3 0f 58 94 24 80 00 	addss  xmm2,DWORD PTR [rsp+0x80]
    c19d:	00 00 
    c19f:	0f 28 c2             	movaps xmm0,xmm2
    c1a2:	41 0f 46 ee          	cmovbe ebp,r14d
    c1a6:	f3 0f 59 c2          	mulss  xmm0,xmm2
    c1aa:	b8 01 00 00 00       	mov    eax,0x1
    c1af:	44 0f 47 f8          	cmova  r15d,eax
    c1b3:	f3 0f 10 8c 24 bc 00 	movss  xmm1,DWORD PTR [rsp+0xbc]
    c1ba:	00 00 
    c1bc:	f3 0f 58 c8          	addss  xmm1,xmm0
    c1c0:	0f 2e f9             	ucomiss xmm7,xmm1
    c1c3:	b8 28 6b 6e 4e       	mov    eax,0x4e6e6b28
    c1c8:	41 be 28 6b 6e 4e    	mov    r14d,0x4e6e6b28
    c1ce:	0f 87 9f ed ff ff    	ja     af73 <spin_22+0x6a3>
    c1d4:	0f 28 c1             	movaps xmm0,xmm1
    c1d7:	0f 2e cf             	ucomiss xmm1,xmm7
    c1da:	0f 82 50 ed ff ff    	jb     af30 <spin_22+0x660>
    c1e0:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    c1e4:	e9 74 ed ff ff       	jmp    af5d <spin_22+0x68d>
    c1e9:	84 c9                	test   cl,cl
    c1eb:	0f 85 c5 0a 00 00    	jne    ccb6 <spin_22+0x23e6>
    c1f1:	f3 0f 11 5c 24 0c    	movss  DWORD PTR [rsp+0xc],xmm3
    c1f7:	41 83 ff 08          	cmp    r15d,0x8
    c1fb:	b9 08 00 00 00       	mov    ecx,0x8
    c200:	41 0f 42 cf          	cmovb  ecx,r15d
    c204:	c1 e1 03             	shl    ecx,0x3
    c207:	66 0f 6e c0          	movd   xmm0,eax
    c20b:	f3 0f 59 f0          	mulss  xmm6,xmm0
    c20f:	f3 0f 58 e6          	addss  xmm4,xmm6
    c213:	0f 28 d4             	movaps xmm2,xmm4
    c216:	48 8d 05 e3 56 ff ff 	lea    rax,[rip+0xffffffffffff56e3]        # 1900 <TAB_1>
    c21d:	f3 0f 5c 14 01       	subss  xmm2,DWORD PTR [rcx+rax*1]
    c222:	48 8d 05 c7 57 ff ff 	lea    rax,[rip+0xffffffffffff57c7]        # 19f0 <TAB_4>
    c229:	f3 0f 10 0c 01       	movss  xmm1,DWORD PTR [rcx+rax*1]
    c22e:	f3 0f 5e d1          	divss  xmm2,xmm1
    c232:	f3 44 0f 10 15 75 54 	movss  xmm10,DWORD PTR [rip+0xffffffffffff5475]        # 16b0 <_IO_stdin_used+0x24>
    c239:	ff ff 
    c23b:	0f 29 94 24 20 01 00 	movaps XMMWORD PTR [rsp+0x120],xmm2
    c242:	00 
    c243:	f3 44 0f 59 d2       	mulss  xmm10,xmm2
    c248:	f3 44 0f 58 d4       	addss  xmm10,xmm4
    c24d:	0f c6 c0 00          	shufps xmm0,xmm0,0x0
    c251:	0f 28 54 24 70       	movaps xmm2,XMMWORD PTR [rsp+0x70]
    c256:	0f 59 d0             	mulps  xmm2,xmm0
    c259:	0f 28 5c 24 20       	movaps xmm3,XMMWORD PTR [rsp+0x20]
    c25e:	0f 58 da             	addps  xmm3,xmm2
    c261:	48 8d 05 38 57 ff ff 	lea    rax,[rip+0xffffffffffff5738]        # 19a0 <TAB_3>
    c268:	f3 0f 10 04 01       	movss  xmm0,DWORD PTR [rcx+rax*1]
    c26d:	48 8d 05 dc 56 ff ff 	lea    rax,[rip+0xffffffffffff56dc]        # 1950 <TAB_2>
    c274:	f3 0f 10 14 01       	movss  xmm2,DWORD PTR [rcx+rax*1]
    c279:	0f 14 d0             	unpcklps xmm2,xmm0
    c27c:	0f 28 f3             	movaps xmm6,xmm3
    c27f:	0f 5c f2             	subps  xmm6,xmm2
    c282:	0f c6 c9 00          	shufps xmm1,xmm1,0x0
    c286:	0f 5e f1             	divps  xmm6,xmm1
    c289:	f3 44 0f 10 05 b2 53 	movss  xmm8,DWORD PTR [rip+0xffffffffffff53b2]        # 1644 <_IO_stdin_used-0x48>
    c290:	ff ff 
    c292:	f3 44 0f 5c c3       	subss  xmm8,xmm3
    c297:	41 0f 28 c0          	movaps xmm0,xmm8
    c29b:	f3 41 0f 59 c0       	mulss  xmm0,xmm8
    c2a0:	44 0f 28 0d 58 54 ff 	movaps xmm9,XMMWORD PTR [rip+0xffffffffffff5458]        # 1700 <_IO_stdin_used+0x74>
    c2a7:	ff 
    c2a8:	0f 29 74 24 70       	movaps XMMWORD PTR [rsp+0x70],xmm6
    c2ad:	44 0f 59 ce          	mulps  xmm9,xmm6
    c2b1:	0f 28 cb             	movaps xmm1,xmm3
    c2b4:	f3 0f 10 cc          	movss  xmm1,xmm4
    c2b8:	f2 0f 10 3d 50 54 ff 	movsd  xmm7,QWORD PTR [rip+0xffffffffffff5450]        # 1710 <_IO_stdin_used+0x84>
    c2bf:	ff 
    c2c0:	0f 5c f9             	subps  xmm7,xmm1
    c2c3:	0f 28 cf             	movaps xmm1,xmm7
    c2c6:	0f 59 cf             	mulps  xmm1,xmm7
    c2c9:	f3 0f 58 c1          	addss  xmm0,xmm1
    c2cd:	0f c6 c9 55          	shufps xmm1,xmm1,0x55
    c2d1:	f3 0f 58 c8          	addss  xmm1,xmm0
    c2d5:	0f 57 c0             	xorps  xmm0,xmm0
    c2d8:	f3 0f 51 c1          	sqrtss xmm0,xmm1
    c2dc:	f3 44 0f 5e c0       	divss  xmm8,xmm0
    c2e1:	0f 29 84 24 50 01 00 	movaps XMMWORD PTR [rsp+0x150],xmm0
    c2e8:	00 
    c2e9:	0f c6 c0 00          	shufps xmm0,xmm0,0x0
    c2ed:	0f 5e f8             	divps  xmm7,xmm0
    c2f0:	44 0f 58 cb          	addps  xmm9,xmm3
    c2f4:	f3 44 0f 10 2d 73 53 	movss  xmm13,DWORD PTR [rip+0xffffffffffff5373]        # 1670 <_IO_stdin_used-0x1c>
    c2fb:	ff ff 
    c2fd:	f3 45 0f 58 e9       	addss  xmm13,xmm9
    c302:	41 0f 28 d8          	movaps xmm3,xmm8
    c306:	f3 41 0f 59 dd       	mulss  xmm3,xmm13
    c30b:	f3 45 0f 59 ed       	mulss  xmm13,xmm13
    c310:	45 0f 28 e1          	movaps xmm12,xmm9
    c314:	f3 45 0f 10 e2       	movss  xmm12,xmm10
    c319:	f2 44 0f 10 35 ae 53 	movsd  xmm14,QWORD PTR [rip+0xffffffffffff53ae]        # 16d0 <_IO_stdin_used+0x44>
    c320:	ff ff 
    c322:	45 0f 58 f4          	addps  xmm14,xmm12
    c326:	0f 28 cf             	movaps xmm1,xmm7
    c329:	41 0f 59 ce          	mulps  xmm1,xmm14
    c32d:	0f 28 c1             	movaps xmm0,xmm1
    c330:	f3 0f 58 c3          	addss  xmm0,xmm3
    c334:	0f c6 c9 55          	shufps xmm1,xmm1,0x55
    c338:	44 0f 28 f9          	movaps xmm15,xmm1
    c33c:	f3 0f 58 c8          	addss  xmm1,xmm0
    c340:	45 0f 59 f6          	mulps  xmm14,xmm14
    c344:	41 0f 28 c6          	movaps xmm0,xmm14
    c348:	f3 41 0f 58 c5       	addss  xmm0,xmm13
    c34d:	45 0f c6 f6 55       	shufps xmm14,xmm14,0x55
    c352:	41 0f 28 d6          	movaps xmm2,xmm14
    c356:	f3 0f 58 d0          	addss  xmm2,xmm0
    c35a:	f3 0f 10 05 d6 52 ff 	movss  xmm0,DWORD PTR [rip+0xffffffffffff52d6]        # 1638 <_IO_stdin_used-0x54>
    c361:	ff 
    c362:	f3 0f 5c c2          	subss  xmm0,xmm2
    c366:	0f 28 d1             	movaps xmm2,xmm1
    c369:	f3 0f 59 d1          	mulss  xmm2,xmm1
    c36d:	f3 0f 58 c2          	addss  xmm0,xmm2
    c371:	bb 28 6b 6e 4e       	mov    ebx,0x4e6e6b28
    c376:	0f 57 d2             	xorps  xmm2,xmm2
    c379:	0f 2e d0             	ucomiss xmm2,xmm0
    c37c:	bd 28 6b 6e 4e       	mov    ebp,0x4e6e6b28
    c381:	f3 0f 10 25 0b 53 ff 	movss  xmm4,DWORD PTR [rip+0xffffffffffff530b]        # 1694 <_IO_stdin_used+0x8>
    c388:	ff 
    c389:	f3 0f 10 35 0f 53 ff 	movss  xmm6,DWORD PTR [rip+0xffffffffffff530f]        # 16a0 <_IO_stdin_used+0x14>
    c390:	ff 
    c391:	0f 29 7c 24 20       	movaps XMMWORD PTR [rsp+0x20],xmm7
    c396:	f3 44 0f 11 44 24 10 	movss  DWORD PTR [rsp+0x10],xmm8
    c39d:	44 0f 29 4c 24 30    	movaps XMMWORD PTR [rsp+0x30],xmm9
    c3a3:	44 0f 29 54 24 50    	movaps XMMWORD PTR [rsp+0x50],xmm10
    c3a9:	44 0f 29 a4 24 80 00 	movaps XMMWORD PTR [rsp+0x80],xmm12
    c3b0:	00 00 
    c3b2:	0f 87 c1 00 00 00    	ja     c479 <spin_22+0x1ba9>
    c3b8:	45 0f 57 db          	xorps  xmm11,xmm11
    c3bc:	f3 44 0f 5c d9       	subss  xmm11,xmm1
    c3c1:	f3 44 0f 11 5c 24 60 	movss  DWORD PTR [rsp+0x60],xmm11
    c3c8:	0f 2e c2             	ucomiss xmm0,xmm2
    c3cb:	72 09                	jb     c3d6 <spin_22+0x1b06>
    c3cd:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    c3d1:	e9 8a 00 00 00       	jmp    c460 <spin_22+0x1b90>
    c3d6:	f3 44 0f 11 ac 24 c0 	movss  DWORD PTR [rsp+0xc0],xmm13
    c3dd:	00 00 00 
    c3e0:	44 0f 29 b4 24 a0 00 	movaps XMMWORD PTR [rsp+0xa0],xmm14
    c3e7:	00 00 
    c3e9:	f3 0f 11 9c 24 e0 00 	movss  DWORD PTR [rsp+0xe0],xmm3
    c3f0:	00 00 
    c3f2:	f3 44 0f 11 bc 24 f0 	movss  DWORD PTR [rsp+0xf0],xmm15
    c3f9:	00 00 00 
    c3fc:	e8 2f 29 00 00       	call   ed30 <sqrtf@plt>
    c401:	f3 44 0f 10 bc 24 f0 	movss  xmm15,DWORD PTR [rsp+0xf0]
    c408:	00 00 00 
    c40b:	f3 0f 10 9c 24 e0 00 	movss  xmm3,DWORD PTR [rsp+0xe0]
    c412:	00 00 
    c414:	44 0f 28 b4 24 a0 00 	movaps xmm14,XMMWORD PTR [rsp+0xa0]
    c41b:	00 00 
    c41d:	f3 44 0f 10 ac 24 c0 	movss  xmm13,DWORD PTR [rsp+0xc0]
    c424:	00 00 00 
    c427:	44 0f 28 a4 24 80 00 	movaps xmm12,XMMWORD PTR [rsp+0x80]
    c42e:	00 00 
    c430:	44 0f 28 54 24 50    	movaps xmm10,XMMWORD PTR [rsp+0x50]
    c436:	44 0f 28 4c 24 30    	movaps xmm9,XMMWORD PTR [rsp+0x30]
    c43c:	f3 44 0f 10 44 24 10 	movss  xmm8,DWORD PTR [rsp+0x10]
    c443:	0f 28 7c 24 20       	movaps xmm7,XMMWORD PTR [rsp+0x20]
    c448:	f3 0f 10 35 50 52 ff 	movss  xmm6,DWORD PTR [rip+0xffffffffffff5250]        # 16a0 <_IO_stdin_used+0x14>
    c44f:	ff 
    c450:	f3 0f 10 25 3c 52 ff 	movss  xmm4,DWORD PTR [rip+0xffffffffffff523c]        # 1694 <_IO_stdin_used+0x8>
    c457:	ff 
    c458:	f3 0f 10 2d 50 52 ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff5250]        # 16b0 <_IO_stdin_used+0x24>
    c45f:	ff 
    c460:	f3 0f 10 4c 24 60    	movss  xmm1,DWORD PTR [rsp+0x60]
    c466:	f3 0f 5c c8          	subss  xmm1,xmm0
    c46a:	66 0f 7e c8          	movd   eax,xmm1
    c46e:	0f 2e e9             	ucomiss xmm5,xmm1
    c471:	bd 28 6b 6e 4e       	mov    ebp,0x4e6e6b28
    c476:	0f 46 e8             	cmovbe ebp,eax
    c479:	66 0f 6e c5          	movd   xmm0,ebp
    c47d:	f3 0f 10 0d 1f 52 ff 	movss  xmm1,DWORD PTR [rip+0xffffffffffff521f]        # 16a4 <_IO_stdin_used+0x18>
    c484:	ff 
    c485:	0f 2e c8             	ucomiss xmm1,xmm0
    c488:	45 0f 57 db          	xorps  xmm11,xmm11
    c48c:	f3 0f 10 15 e4 51 ff 	movss  xmm2,DWORD PTR [rip+0xffffffffffff51e4]        # 1678 <_IO_stdin_used-0x14>
    c493:	ff 
    c494:	f3 41 0f 58 d2       	addss  xmm2,xmm10
    c499:	0f 28 cf             	movaps xmm1,xmm7
    c49c:	f3 0f 59 ca          	mulss  xmm1,xmm2
    c4a0:	f3 0f 58 cb          	addss  xmm1,xmm3
    c4a4:	f3 41 0f 58 cf       	addss  xmm1,xmm15
    c4a9:	0f 28 d9             	movaps xmm3,xmm1
    c4ac:	f3 0f 59 d9          	mulss  xmm3,xmm1
    c4b0:	f3 0f 59 d2          	mulss  xmm2,xmm2
    c4b4:	f3 41 0f 58 d5       	addss  xmm2,xmm13
    c4b9:	f3 41 0f 58 d6       	addss  xmm2,xmm14
    c4be:	f3 0f 10 05 72 51 ff 	movss  xmm0,DWORD PTR [rip+0xffffffffffff5172]        # 1638 <_IO_stdin_used-0x54>
    c4c5:	ff 
    c4c6:	0f 46 eb             	cmovbe ebp,ebx
    c4c9:	f3 0f 5c c2          	subss  xmm0,xmm2
    c4cd:	f3 0f 58 c3          	addss  xmm0,xmm3
    c4d1:	44 0f 2e d8          	ucomiss xmm11,xmm0
    c4d5:	77 6f                	ja     c546 <spin_22+0x1c76>
    c4d7:	0f 57 d2             	xorps  xmm2,xmm2
    c4da:	0f 2e c2             	ucomiss xmm0,xmm2
    c4dd:	f3 0f 5c d1          	subss  xmm2,xmm1
    c4e1:	72 06                	jb     c4e9 <spin_22+0x1c19>
    c4e3:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    c4e7:	eb 4a                	jmp    c533 <spin_22+0x1c63>
    c4e9:	f3 0f 11 54 24 60    	movss  DWORD PTR [rsp+0x60],xmm2
    c4ef:	e8 3c 28 00 00       	call   ed30 <sqrtf@plt>
    c4f4:	f3 0f 10 54 24 60    	movss  xmm2,DWORD PTR [rsp+0x60]
    c4fa:	44 0f 28 a4 24 80 00 	movaps xmm12,XMMWORD PTR [rsp+0x80]
    c501:	00 00 
    c503:	44 0f 28 54 24 50    	movaps xmm10,XMMWORD PTR [rsp+0x50]
    c509:	44 0f 28 4c 24 30    	movaps xmm9,XMMWORD PTR [rsp+0x30]
    c50f:	f3 44 0f 10 44 24 10 	movss  xmm8,DWORD PTR [rsp+0x10]
    c516:	0f 28 7c 24 20       	movaps xmm7,XMMWORD PTR [rsp+0x20]
    c51b:	f3 0f 10 35 7d 51 ff 	movss  xmm6,DWORD PTR [rip+0xffffffffffff517d]        # 16a0 <_IO_stdin_used+0x14>
    c522:	ff 
    c523:	f3 0f 10 25 69 51 ff 	movss  xmm4,DWORD PTR [rip+0xffffffffffff5169]        # 1694 <_IO_stdin_used+0x8>
    c52a:	ff 
    c52b:	f3 0f 10 2d 7d 51 ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff517d]        # 16b0 <_IO_stdin_used+0x24>
    c532:	ff 
    c533:	f3 0f 5c d0          	subss  xmm2,xmm0
    c537:	66 0f 7e d0          	movd   eax,xmm2
    c53b:	0f 2e ea             	ucomiss xmm5,xmm2
    c53e:	bb 28 6b 6e 4e       	mov    ebx,0x4e6e6b28
    c543:	0f 46 d8             	cmovbe ebx,eax
    c546:	66 0f 6e c3          	movd   xmm0,ebx
    c54a:	66 0f 6e cd          	movd   xmm1,ebp
    c54e:	0f 2e c8             	ucomiss xmm1,xmm0
    c551:	41 0f 28 da          	movaps xmm3,xmm10
    c555:	f3 41 0f 59 da       	mulss  xmm3,xmm10
    c55a:	f2 0f 10 0d 3e 52 ff 	movsd  xmm1,QWORD PTR [rip+0xffffffffffff523e]        # 17a0 <_IO_stdin_used+0x114>
    c561:	ff 
    c562:	41 0f 58 c9          	addps  xmm1,xmm9
    c566:	41 0f 28 d0          	movaps xmm2,xmm8
    c56a:	f3 0f 59 d1          	mulss  xmm2,xmm1
    c56e:	0f 28 c1             	movaps xmm0,xmm1
    c571:	f3 41 0f 10 c2       	movss  xmm0,xmm10
    c576:	0f 59 c7             	mulps  xmm0,xmm7
    c579:	f3 0f 58 d0          	addss  xmm2,xmm0
    c57d:	0f 29 84 24 c0 00 00 	movaps XMMWORD PTR [rsp+0xc0],xmm0
    c584:	00 
    c585:	0f c6 c0 55          	shufps xmm0,xmm0,0x55
    c589:	f3 0f 58 c2          	addss  xmm0,xmm2
    c58d:	0f 28 d0             	movaps xmm2,xmm0
    c590:	f3 0f 59 d0          	mulss  xmm2,xmm0
    c594:	0f 59 c9             	mulps  xmm1,xmm1
    c597:	0f 29 5c 24 60       	movaps XMMWORD PTR [rsp+0x60],xmm3
    c59c:	f3 0f 58 d9          	addss  xmm3,xmm1
    c5a0:	0f c6 c9 55          	shufps xmm1,xmm1,0x55
    c5a4:	f3 0f 58 cb          	addss  xmm1,xmm3
    c5a8:	f3 0f 5c f1          	subss  xmm6,xmm1
    c5ac:	f3 0f 58 f2          	addss  xmm6,xmm2
    c5b0:	0f 46 dd             	cmovbe ebx,ebp
    c5b3:	45 0f 57 ff          	xorps  xmm15,xmm15
    c5b7:	44 0f 2e fe          	ucomiss xmm15,xmm6
    c5bb:	bd 28 6b 6e 4e       	mov    ebp,0x4e6e6b28
    c5c0:	41 be 28 6b 6e 4e    	mov    r14d,0x4e6e6b28
    c5c6:	77 7a                	ja     c642 <spin_22+0x1d72>
    c5c8:	0f 57 c9             	xorps  xmm1,xmm1
    c5cb:	f3 0f 5c c8          	subss  xmm1,xmm0
    c5cf:	41 0f 2e f7          	ucomiss xmm6,xmm15
    c5d3:	72 09                	jb     c5de <spin_22+0x1d0e>
    c5d5:	0f 57 c0             	xorps  xmm0,xmm0
    c5d8:	f3 0f 51 c6          	sqrtss xmm0,xmm6
    c5dc:	eb 4f                	jmp    c62d <spin_22+0x1d5d>
    c5de:	0f 28 c6             	movaps xmm0,xmm6
    c5e1:	f3 0f 11 8c 24 a0 00 	movss  DWORD PTR [rsp+0xa0],xmm1
    c5e8:	00 00 
    c5ea:	e8 41 27 00 00       	call   ed30 <sqrtf@plt>
    c5ef:	f3 0f 10 8c 24 a0 00 	movss  xmm1,DWORD PTR [rsp+0xa0]
    c5f6:	00 00 
    c5f8:	45 0f 57 ff          	xorps  xmm15,xmm15
    c5fc:	44 0f 28 a4 24 80 00 	movaps xmm12,XMMWORD PTR [rsp+0x80]
    c603:	00 00 
    c605:	44 0f 28 54 24 50    	movaps xmm10,XMMWORD PTR [rsp+0x50]
    c60b:	44 0f 28 4c 24 30    	movaps xmm9,XMMWORD PTR [rsp+0x30]
    c611:	f3 44 0f 10 44 24 10 	movss  xmm8,DWORD PTR [rsp+0x10]
    c618:	0f 28 7c 24 20       	movaps xmm7,XMMWORD PTR [rsp+0x20]
    c61d:	f3 0f 10 25 6f 50 ff 	movss  xmm4,DWORD PTR [rip+0xffffffffffff506f]        # 1694 <_IO_stdin_used+0x8>
    c624:	ff 
    c625:	f3 0f 10 2d 83 50 ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff5083]        # 16b0 <_IO_stdin_used+0x24>
    c62c:	ff 
    c62d:	f3 0f 5c c8          	subss  xmm1,xmm0
    c631:	66 0f 7e c8          	movd   eax,xmm1
    c635:	0f 2e e9             	ucomiss xmm5,xmm1
    c638:	41 be 28 6b 6e 4e    	mov    r14d,0x4e6e6b28
    c63e:	44 0f 46 f0          	cmovbe r14d,eax
    c642:	66 41 0f 6e c6       	movd   xmm0,r14d
    c647:	66 0f 6e cb          	movd   xmm1,ebx
    c64b:	0f 2e c8             	ucomiss xmm1,xmm0
    c64e:	f3 0f 10 35 f6 4f ff 	movss  xmm6,DWORD PTR [rip+0xffffffffffff4ff6]        # 164c <_IO_stdin_used-0x40>
    c655:	ff 
    c656:	f3 41 0f 58 f1       	addss  xmm6,xmm9
    c65b:	45 0f 28 f0          	movaps xmm14,xmm8
    c65f:	f3 44 0f 59 f6       	mulss  xmm14,xmm6
    c664:	f3 0f 59 f6          	mulss  xmm6,xmm6
    c668:	f2 44 0f 10 2d ff 50 	movsd  xmm13,QWORD PTR [rip+0xffffffffffff50ff]        # 1770 <_IO_stdin_used+0xe4>
    c66f:	ff ff 
    c671:	45 0f 58 ec          	addps  xmm13,xmm12
    c675:	0f 28 cf             	movaps xmm1,xmm7
    c678:	41 0f 59 cd          	mulps  xmm1,xmm13
    c67c:	0f 28 c1             	movaps xmm0,xmm1
    c67f:	f3 41 0f 58 c6       	addss  xmm0,xmm14
    c684:	0f c6 c9 55          	shufps xmm1,xmm1,0x55
    c688:	f3 0f 11 8c 24 a0 00 	movss  DWORD PTR [rsp+0xa0],xmm1
    c68f:	00 00 
    c691:	f3 0f 58 c8          	addss  xmm1,xmm0
    c695:	0f 28 d1             	movaps xmm2,xmm1
    c698:	f3 0f 59 d1          	mulss  xmm2,xmm1
    c69c:	45 0f 59 ed          	mulps  xmm13,xmm13
    c6a0:	41 0f 28 c5          	movaps xmm0,xmm13
    c6a4:	f3 0f 58 c6          	addss  xmm0,xmm6
    c6a8:	45 0f c6 ed 55       	shufps xmm13,xmm13,0x55
    c6ad:	41 0f 28 dd          	movaps xmm3,xmm13
    c6b1:	f3 0f 58 d8          	addss  xmm3,xmm0
    c6b5:	0f 28 c4             	movaps xmm0,xmm4
    c6b8:	44 0f 46 f3          	cmovbe r14d,ebx
    c6bc:	f3 0f 5c c3          	subss  xmm0,xmm3
    c6c0:	f3 0f 58 c2          	addss  xmm0,xmm2
    c6c4:	44 0f 2e f8          	ucomiss xmm15,xmm0
    c6c8:	0f 87 9f 00 00 00    	ja     c76d <spin_22+0x1e9d>
    c6ce:	0f 57 d2             	xorps  xmm2,xmm2
    c6d1:	0f 2e c2             	ucomiss xmm0,xmm2
    c6d4:	f3 0f 5c d1          	subss  xmm2,xmm1
    c6d8:	72 06                	jb     c6e0 <spin_22+0x1e10>
    c6da:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    c6de:	eb 7a                	jmp    c75a <spin_22+0x1e8a>
    c6e0:	f3 0f 11 b4 24 e0 00 	movss  DWORD PTR [rsp+0xe0],xmm6
    c6e7:	00 00 
    c6e9:	44 0f 29 ac 24 f0 00 	movaps XMMWORD PTR [rsp+0xf0],xmm13
    c6f0:	00 00 
    c6f2:	f3 44 0f 11 74 24 4c 	movss  DWORD PTR [rsp+0x4c],xmm14
    c6f9:	f3 0f 11 94 24 10 01 	movss  DWORD PTR [rsp+0x110],xmm2
    c700:	00 00 
    c702:	e8 29 26 00 00       	call   ed30 <sqrtf@plt>
    c707:	f3 0f 10 94 24 10 01 	movss  xmm2,DWORD PTR [rsp+0x110]
    c70e:	00 00 
    c710:	f3 44 0f 10 74 24 4c 	movss  xmm14,DWORD PTR [rsp+0x4c]
    c717:	44 0f 28 ac 24 f0 00 	movaps xmm13,XMMWORD PTR [rsp+0xf0]
    c71e:	00 00 
    c720:	f3 0f 10 b4 24 e0 00 	movss  xmm6,DWORD PTR [rsp+0xe0]
    c727:	00 00 
    c729:	44 0f 28 a4 24 80 00 	movaps xmm12,XMMWORD PTR [rsp+0x80]
    c730:	00 00 
    c732:	44 0f 28 54 24 50    	movaps xmm10,XMMWORD PTR [rsp+0x50]
    c738:	44 0f 28 4c 24 30    	movaps xmm9,XMMWORD PTR [rsp+0x30]
    c73e:	f3 44 0f 10 44 24 10 	movss  xmm8,DWORD PTR [rsp+0x10]
    c745:	0f 28 7c 24 20       	movaps xmm7,XMMWORD PTR [rsp+0x20]
    c74a:	f3 0f 10 25 42 4f ff 	movss  xmm4,DWORD PTR [rip+0xffffffffffff4f42]        # 1694 <_IO_stdin_used+0x8>
    c751:	ff 
    c752:	f3 0f 10 2d 56 4f ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff4f56]        # 16b0 <_IO_stdin_used+0x24>
    c759:	ff 
    c75a:	f3 0f 5c d0          	subss  xmm2,xmm0
    c75e:	66 0f 7e d0          	movd   eax,xmm2
    c762:	0f 2e ea             	ucomiss xmm5,xmm2
    c765:	bd 28 6b 6e 4e       	mov    ebp,0x4e6e6b28
    c76a:	0f 46 e8             	cmovbe ebp,eax
    c76d:	66 0f 6e c5          	movd   xmm0,ebp
    c771:	66 41 0f 6e ce       	movd   xmm1,r14d
    c776:	0f 2e c8             	ucomiss xmm1,xmm0
    c779:	f3 0f 10 0d d3 4e ff 	movss  xmm1,DWORD PTR [rip+0xffffffffffff4ed3]        # 1654 <_IO_stdin_used-0x38>
    c780:	ff 
    c781:	f3 41 0f 58 ca       	addss  xmm1,xmm10
    c786:	0f 28 c7             	movaps xmm0,xmm7
    c789:	f3 0f 59 c1          	mulss  xmm0,xmm1
    c78d:	f3 41 0f 58 c6       	addss  xmm0,xmm14
    c792:	f3 0f 58 84 24 a0 00 	addss  xmm0,DWORD PTR [rsp+0xa0]
    c799:	00 00 
    c79b:	0f 28 d0             	movaps xmm2,xmm0
    c79e:	f3 0f 59 d0          	mulss  xmm2,xmm0
    c7a2:	f3 0f 59 c9          	mulss  xmm1,xmm1
    c7a6:	f3 0f 58 ce          	addss  xmm1,xmm6
    c7aa:	f3 41 0f 58 cd       	addss  xmm1,xmm13
    c7af:	f3 0f 5c e1          	subss  xmm4,xmm1
    c7b3:	f3 0f 58 e2          	addss  xmm4,xmm2
    c7b7:	41 0f 46 ee          	cmovbe ebp,r14d
    c7bb:	45 0f 57 ff          	xorps  xmm15,xmm15
    c7bf:	44 0f 2e fc          	ucomiss xmm15,xmm4
    c7c3:	bb 28 6b 6e 4e       	mov    ebx,0x4e6e6b28
    c7c8:	41 be 28 6b 6e 4e    	mov    r14d,0x4e6e6b28
    c7ce:	77 72                	ja     c842 <spin_22+0x1f72>
    c7d0:	0f 57 c9             	xorps  xmm1,xmm1
    c7d3:	f3 0f 5c c8          	subss  xmm1,xmm0
    c7d7:	41 0f 2e e7          	ucomiss xmm4,xmm15
    c7db:	72 09                	jb     c7e6 <spin_22+0x1f16>
    c7dd:	0f 57 c0             	xorps  xmm0,xmm0
    c7e0:	f3 0f 51 c4          	sqrtss xmm0,xmm4
    c7e4:	eb 47                	jmp    c82d <spin_22+0x1f5d>
    c7e6:	0f 28 c4             	movaps xmm0,xmm4
    c7e9:	f3 0f 11 8c 24 a0 00 	movss  DWORD PTR [rsp+0xa0],xmm1
    c7f0:	00 00 
    c7f2:	e8 39 25 00 00       	call   ed30 <sqrtf@plt>
    c7f7:	f3 0f 10 8c 24 a0 00 	movss  xmm1,DWORD PTR [rsp+0xa0]
    c7fe:	00 00 
    c800:	45 0f 57 ff          	xorps  xmm15,xmm15
    c804:	44 0f 28 a4 24 80 00 	movaps xmm12,XMMWORD PTR [rsp+0x80]
    c80b:	00 00 
    c80d:	44 0f 28 54 24 50    	movaps xmm10,XMMWORD PTR [rsp+0x50]
    c813:	44 0f 28 4c 24 30    	movaps xmm9,XMMWORD PTR [rsp+0x30]
    c819:	f3 44 0f 10 44 24 10 	movss  xmm8,DWORD PTR [rsp+0x10]
    c820:	0f 28 7c 24 20       	movaps xmm7,XMMWORD PTR [rsp+0x20]
    c825:	f3 0f 10 2d 83 4e ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff4e83]        # 16b0 <_IO_stdin_used+0x24>
    c82c:	ff 
    c82d:	f3 0f 5c c8          	subss  xmm1,xmm0
    c831:	66 0f 7e c8          	movd   eax,xmm1
    c835:	0f 2e e9             	ucomiss xmm5,xmm1
    c838:	41 be 28 6b 6e 4e    	mov    r14d,0x4e6e6b28
    c83e:	44 0f 46 f0          	cmovbe r14d,eax
    c842:	0f 28 64 24 70       	movaps xmm4,XMMWORD PTR [rsp+0x70]
    c847:	0f 28 f4             	movaps xmm6,xmm4
    c84a:	0f 28 84 24 20 01 00 	movaps xmm0,XMMWORD PTR [rsp+0x120]
    c851:	00 
    c852:	f3 0f 10 f0          	movss  xmm6,xmm0
    c856:	66 41 0f 6e c6       	movd   xmm0,r14d
    c85b:	66 0f 6e cd          	movd   xmm1,ebp
    c85f:	0f 2e c8             	ucomiss xmm1,xmm0
    c862:	f3 44 0f 10 2d 09 4e 	movss  xmm13,DWORD PTR [rip+0xffffffffffff4e09]        # 1674 <_IO_stdin_used-0x18>
    c869:	ff ff 
    c86b:	f3 45 0f 58 e9       	addss  xmm13,xmm9
    c870:	45 0f 28 f0          	movaps xmm14,xmm8
    c874:	f3 45 0f 59 f5       	mulss  xmm14,xmm13
    c879:	44 0f 58 25 9f 4e ff 	addps  xmm12,XMMWORD PTR [rip+0xffffffffffff4e9f]        # 1720 <_IO_stdin_used+0x94>
    c880:	ff 
    c881:	f3 45 0f 59 ed       	mulss  xmm13,xmm13
    c886:	0f 28 cf             	movaps xmm1,xmm7
    c889:	41 0f 59 cc          	mulps  xmm1,xmm12
    c88d:	0f 28 c1             	movaps xmm0,xmm1
    c890:	f3 41 0f 58 c6       	addss  xmm0,xmm14
    c895:	0f c6 c9 55          	shufps xmm1,xmm1,0x55
    c899:	f3 0f 11 8c 24 20 01 	movss  DWORD PTR [rsp+0x120],xmm1
    c8a0:	00 00 
    c8a2:	f3 0f 58 c8          	addss  xmm1,xmm0
    c8a6:	0f 28 d1             	movaps xmm2,xmm1
    c8a9:	f3 0f 59 d1          	mulss  xmm2,xmm1
    c8ad:	45 0f 59 e4          	mulps  xmm12,xmm12
    c8b1:	41 0f 28 c4          	movaps xmm0,xmm12
    c8b5:	f3 41 0f 58 c5       	addss  xmm0,xmm13
    c8ba:	45 0f c6 e4 55       	shufps xmm12,xmm12,0x55
    c8bf:	41 0f 28 dc          	movaps xmm3,xmm12
    c8c3:	f3 0f 58 d8          	addss  xmm3,xmm0
    c8c7:	f3 0f 10 05 69 4d ff 	movss  xmm0,DWORD PTR [rip+0xffffffffffff4d69]        # 1638 <_IO_stdin_used-0x54>
    c8ce:	ff 
    c8cf:	44 0f 46 f5          	cmovbe r14d,ebp
    c8d3:	f3 0f 5c c3          	subss  xmm0,xmm3
    c8d7:	f3 0f 58 c2          	addss  xmm0,xmm2
    c8db:	44 0f 2e f8          	ucomiss xmm15,xmm0
    c8df:	f3 0f 10 5c 24 0c    	movss  xmm3,DWORD PTR [rsp+0xc]
    c8e5:	0f 87 ae 00 00 00    	ja     c999 <spin_22+0x20c9>
    c8eb:	0f 57 d2             	xorps  xmm2,xmm2
    c8ee:	0f 2e c2             	ucomiss xmm0,xmm2
    c8f1:	f3 0f 5c d1          	subss  xmm2,xmm1
    c8f5:	72 09                	jb     c900 <spin_22+0x2030>
    c8f7:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    c8fb:	e9 86 00 00 00       	jmp    c986 <spin_22+0x20b6>
    c900:	44 0f 29 a4 24 80 00 	movaps XMMWORD PTR [rsp+0x80],xmm12
    c907:	00 00 
    c909:	0f 29 b4 24 a0 00 00 	movaps XMMWORD PTR [rsp+0xa0],xmm6
    c910:	00 
    c911:	f3 44 0f 11 ac 24 e0 	movss  DWORD PTR [rsp+0xe0],xmm13
    c918:	00 00 00 
    c91b:	f3 44 0f 11 b4 24 f0 	movss  DWORD PTR [rsp+0xf0],xmm14
    c922:	00 00 00 
    c925:	f3 0f 11 54 24 4c    	movss  DWORD PTR [rsp+0x4c],xmm2
    c92b:	e8 00 24 00 00       	call   ed30 <sqrtf@plt>
    c930:	f3 0f 10 54 24 4c    	movss  xmm2,DWORD PTR [rsp+0x4c]
    c936:	f3 44 0f 10 b4 24 f0 	movss  xmm14,DWORD PTR [rsp+0xf0]
    c93d:	00 00 00 
    c940:	f3 44 0f 10 ac 24 e0 	movss  xmm13,DWORD PTR [rsp+0xe0]
    c947:	00 00 00 
    c94a:	0f 28 b4 24 a0 00 00 	movaps xmm6,XMMWORD PTR [rsp+0xa0]
    c951:	00 
    c952:	44 0f 28 a4 24 80 00 	movaps xmm12,XMMWORD PTR [rsp+0x80]
    c959:	00 00 
    c95b:	44 0f 28 54 24 50    	movaps xmm10,XMMWORD PTR [rsp+0x50]
    c961:	44 0f 28 4c 24 30    	movaps xmm9,XMMWORD PTR [rsp+0x30]
    c967:	f3 44 0f 10 44 24 10 	movss  xmm8,DWORD PTR [rsp+0x10]
    c96e:	0f 28 7c 24 20       	movaps xmm7,XMMWORD PTR [rsp+0x20]
    c973:	0f 28 64 24 70       	movaps xmm4,XMMWORD PTR [rsp+0x70]
    c978:	f3 0f 10 5c 24 0c    	movss  xmm3,DWORD PTR [rsp+0xc]
    c97e:	f3 0f 10 2d 2a 4d ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff4d2a]        # 16b0 <_IO_stdin_used+0x24>
    c985:	ff 
    c986:	f3 0f 5c d0          	subss  xmm2,xmm0
    c98a:	66 0f 7e d0          	movd   eax,xmm2
    c98e:	0f 2e ea             	ucomiss xmm5,xmm2
    c991:	bb 28 6b 6e 4e       	mov    ebx,0x4e6e6b28
    c996:	0f 46 d8             	cmovbe ebx,eax
    c999:	f3 41 0f 59 e0       	mulss  xmm4,xmm8
    c99e:	0f 59 f7             	mulps  xmm6,xmm7
    c9a1:	66 0f 6e c3          	movd   xmm0,ebx
    c9a5:	66 41 0f 6e ce       	movd   xmm1,r14d
    c9aa:	0f 2e c8             	ucomiss xmm1,xmm0
    c9ad:	f3 44 0f 58 15 8a 4c 	addss  xmm10,DWORD PTR [rip+0xffffffffffff4c8a]        # 1640 <_IO_stdin_used-0x4c>
    c9b4:	ff ff 
    c9b6:	0f 28 cf             	movaps xmm1,xmm7
    c9b9:	f3 41 0f 59 ca       	mulss  xmm1,xmm10
    c9be:	f3 41 0f 58 ce       	addss  xmm1,xmm14
    c9c3:	f3 0f 58 8c 24 20 01 	addss  xmm1,DWORD PTR [rsp+0x120]
    c9ca:	00 00 
    c9cc:	0f 28 d1             	movaps xmm2,xmm1
    c9cf:	f3 0f 59 d1          	mulss  xmm2,xmm1
    c9d3:	f3 45 0f 59 d2       	mulss  xmm10,xmm10
    c9d8:	f3 45 0f 58 d5       	addss  xmm10,xmm13
    c9dd:	f3 45 0f 58 d4       	addss  xmm10,xmm12
    c9e2:	f3 0f 10 05 4e 4c ff 	movss  xmm0,DWORD PTR [rip+0xffffffffffff4c4e]        # 1638 <_IO_stdin_used-0x54>
    c9e9:	ff 
    c9ea:	f3 41 0f 5c c2       	subss  xmm0,xmm10
    c9ef:	f3 0f 58 c2          	addss  xmm0,xmm2
    c9f3:	41 0f 46 de          	cmovbe ebx,r14d
    c9f7:	45 0f 57 e4          	xorps  xmm12,xmm12
    c9fb:	44 0f 2e e0          	ucomiss xmm12,xmm0
    c9ff:	bd 28 6b 6e 4e       	mov    ebp,0x4e6e6b28
    ca04:	41 be 28 6b 6e 4e    	mov    r14d,0x4e6e6b28
    ca0a:	77 7d                	ja     ca89 <spin_22+0x21b9>
    ca0c:	0f 57 d2             	xorps  xmm2,xmm2
    ca0f:	f3 0f 5c d1          	subss  xmm2,xmm1
    ca13:	41 0f 2e c4          	ucomiss xmm0,xmm12
    ca17:	72 06                	jb     ca1f <spin_22+0x214f>
    ca19:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    ca1d:	eb 55                	jmp    ca74 <spin_22+0x21a4>
    ca1f:	0f 29 64 24 70       	movaps XMMWORD PTR [rsp+0x70],xmm4
    ca24:	0f 29 b4 24 a0 00 00 	movaps XMMWORD PTR [rsp+0xa0],xmm6
    ca2b:	00 
    ca2c:	f3 0f 11 94 24 80 00 	movss  DWORD PTR [rsp+0x80],xmm2
    ca33:	00 00 
    ca35:	e8 f6 22 00 00       	call   ed30 <sqrtf@plt>
    ca3a:	f3 0f 10 94 24 80 00 	movss  xmm2,DWORD PTR [rsp+0x80]
    ca41:	00 00 
    ca43:	45 0f 57 e4          	xorps  xmm12,xmm12
    ca47:	0f 28 b4 24 a0 00 00 	movaps xmm6,XMMWORD PTR [rsp+0xa0]
    ca4e:	00 
    ca4f:	44 0f 28 4c 24 30    	movaps xmm9,XMMWORD PTR [rsp+0x30]
    ca55:	f3 44 0f 10 44 24 10 	movss  xmm8,DWORD PTR [rsp+0x10]
    ca5c:	0f 28 7c 24 20       	movaps xmm7,XMMWORD PTR [rsp+0x20]
    ca61:	0f 28 64 24 70       	movaps xmm4,XMMWORD PTR [rsp+0x70]
    ca66:	f3 0f 10 5c 24 0c    	movss  xmm3,DWORD PTR [rsp+0xc]
    ca6c:	f3 0f 10 2d 3c 4c ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff4c3c]        # 16b0 <_IO_stdin_used+0x24>
    ca73:	ff 
    ca74:	f3 0f 5c d0          	subss  xmm2,xmm0
    ca78:	66 0f 7e d0          	movd   eax,xmm2
    ca7c:	0f 2e ea             	ucomiss xmm5,xmm2
    ca7f:	41 be 28 6b 6e 4e    	mov    r14d,0x4e6e6b28
    ca85:	44 0f 46 f0          	cmovbe r14d,eax
    ca89:	f3 0f 58 e6          	addss  xmm4,xmm6
    ca8d:	0f c6 f6 55          	shufps xmm6,xmm6,0x55
    ca91:	66 41 0f 6e c6       	movd   xmm0,r14d
    ca96:	66 0f 6e cb          	movd   xmm1,ebx
    ca9a:	0f 2e c8             	ucomiss xmm1,xmm0
    ca9d:	41 0f 28 c0          	movaps xmm0,xmm8
    caa1:	f3 41 0f 59 c1       	mulss  xmm0,xmm9
    caa6:	f3 0f 58 84 24 c0 00 	addss  xmm0,DWORD PTR [rsp+0xc0]
    caad:	00 00 
    caaf:	f2 44 0f 10 15 78 4c 	movsd  xmm10,QWORD PTR [rip+0xffffffffffff4c78]        # 1730 <_IO_stdin_used+0xa4>
    cab6:	ff ff 
    cab8:	45 0f 58 d1          	addps  xmm10,xmm9
    cabc:	41 0f c6 f9 01       	shufps xmm7,xmm9,0x1
    cac1:	41 0f c6 f9 e2       	shufps xmm7,xmm9,0xe2
    cac6:	41 0f 59 fa          	mulps  xmm7,xmm10
    caca:	0f 28 4c 24 60       	movaps xmm1,XMMWORD PTR [rsp+0x60]
    cacf:	0f 14 c8             	unpcklps xmm1,xmm0
    cad2:	0f 58 cf             	addps  xmm1,xmm7
    cad5:	45 0f 59 d2          	mulps  xmm10,xmm10
    cad9:	45 0f c6 d2 55       	shufps xmm10,xmm10,0x55
    cade:	0f 28 c1             	movaps xmm0,xmm1
    cae1:	0f 59 c1             	mulps  xmm0,xmm1
    cae4:	41 0f 28 d2          	movaps xmm2,xmm10
    cae8:	f3 0f 58 d1          	addss  xmm2,xmm1
    caec:	f3 44 0f 10 1d 43 4b 	movss  xmm11,DWORD PTR [rip+0xffffffffffff4b43]        # 1638 <_IO_stdin_used-0x54>
    caf3:	ff ff 
    caf5:	f3 44 0f 5c da       	subss  xmm11,xmm2
    cafa:	44 0f 46 f3          	cmovbe r14d,ebx
    cafe:	0f c6 c0 55          	shufps xmm0,xmm0,0x55
    cb02:	f3 41 0f 58 c3       	addss  xmm0,xmm11
    cb07:	44 0f 2e e0          	ucomiss xmm12,xmm0
    cb0b:	0f 87 8b 00 00 00    	ja     cb9c <spin_22+0x22cc>
    cb11:	0f c6 c9 55          	shufps xmm1,xmm1,0x55
    cb15:	0f 57 d2             	xorps  xmm2,xmm2
    cb18:	0f 2e c2             	ucomiss xmm0,xmm2
    cb1b:	f3 0f 5c d1          	subss  xmm2,xmm1
    cb1f:	72 06                	jb     cb27 <spin_22+0x2257>
    cb21:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    cb25:	eb 62                	jmp    cb89 <spin_22+0x22b9>
    cb27:	0f 29 64 24 70       	movaps XMMWORD PTR [rsp+0x70],xmm4
    cb2c:	0f 29 7c 24 20       	movaps XMMWORD PTR [rsp+0x20],xmm7
    cb31:	0f 29 b4 24 a0 00 00 	movaps XMMWORD PTR [rsp+0xa0],xmm6
    cb38:	00 
    cb39:	44 0f 29 94 24 80 00 	movaps XMMWORD PTR [rsp+0x80],xmm10
    cb40:	00 00 
    cb42:	f3 0f 11 54 24 50    	movss  DWORD PTR [rsp+0x50],xmm2
    cb48:	e8 e3 21 00 00       	call   ed30 <sqrtf@plt>
    cb4d:	f3 0f 10 54 24 50    	movss  xmm2,DWORD PTR [rsp+0x50]
    cb53:	44 0f 28 94 24 80 00 	movaps xmm10,XMMWORD PTR [rsp+0x80]
    cb5a:	00 00 
    cb5c:	0f 28 b4 24 a0 00 00 	movaps xmm6,XMMWORD PTR [rsp+0xa0]
    cb63:	00 
    cb64:	44 0f 28 4c 24 30    	movaps xmm9,XMMWORD PTR [rsp+0x30]
    cb6a:	f3 44 0f 10 44 24 10 	movss  xmm8,DWORD PTR [rsp+0x10]
    cb71:	0f 28 7c 24 20       	movaps xmm7,XMMWORD PTR [rsp+0x20]
    cb76:	0f 28 64 24 70       	movaps xmm4,XMMWORD PTR [rsp+0x70]
    cb7b:	f3 0f 10 5c 24 0c    	movss  xmm3,DWORD PTR [rsp+0xc]
    cb81:	f3 0f 10 2d 27 4b ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff4b27]        # 16b0 <_IO_stdin_used+0x24>
    cb88:	ff 
    cb89:	f3 0f 5c d0          	subss  xmm2,xmm0
    cb8d:	66 0f 7e d0          	movd   eax,xmm2
    cb91:	0f 2e ea             	ucomiss xmm5,xmm2
    cb94:	bd 28 6b 6e 4e       	mov    ebp,0x4e6e6b28
    cb99:	0f 46 e8             	cmovbe ebp,eax
    cb9c:	f3 0f 58 e6          	addss  xmm4,xmm6
    cba0:	66 0f 6e c5          	movd   xmm0,ebp
    cba4:	66 41 0f 6e ce       	movd   xmm1,r14d
    cba9:	0f 2e c8             	ucomiss xmm1,xmm0
    cbac:	f3 0f 10 05 ac 4a ff 	movss  xmm0,DWORD PTR [rip+0xffffffffffff4aac]        # 1660 <_IO_stdin_used-0x2c>
    cbb3:	ff 
    cbb4:	f3 41 0f 58 c1       	addss  xmm0,xmm9
    cbb9:	f3 44 0f 59 c0       	mulss  xmm8,xmm0
    cbbe:	0f 28 8c 24 c0 00 00 	movaps xmm1,XMMWORD PTR [rsp+0xc0]
    cbc5:	00 
    cbc6:	f3 41 0f 58 c8       	addss  xmm1,xmm8
    cbcb:	0f c6 ff 55          	shufps xmm7,xmm7,0x55
    cbcf:	f3 0f 58 f9          	addss  xmm7,xmm1
    cbd3:	0f 28 cf             	movaps xmm1,xmm7
    cbd6:	f3 0f 59 cf          	mulss  xmm1,xmm7
    cbda:	f3 0f 59 c0          	mulss  xmm0,xmm0
    cbde:	0f 28 54 24 60       	movaps xmm2,XMMWORD PTR [rsp+0x60]
    cbe3:	f3 0f 58 d0          	addss  xmm2,xmm0
    cbe7:	f3 41 0f 58 d2       	addss  xmm2,xmm10
    cbec:	f3 0f 10 05 90 4a ff 	movss  xmm0,DWORD PTR [rip+0xffffffffffff4a90]        # 1684 <_IO_stdin_used-0x8>
    cbf3:	ff 
    cbf4:	f3 0f 5c c2          	subss  xmm0,xmm2
    cbf8:	f3 0f 58 c1          	addss  xmm0,xmm1
    cbfc:	41 0f 46 ee          	cmovbe ebp,r14d
    cc00:	0f 57 d2             	xorps  xmm2,xmm2
    cc03:	0f 2e d0             	ucomiss xmm2,xmm0
    cc06:	b8 28 6b 6e 4e       	mov    eax,0x4e6e6b28
    cc0b:	77 51                	ja     cc5e <spin_22+0x238e>
    cc0d:	0f 57 c9             	xorps  xmm1,xmm1
    cc10:	f3 0f 5c cf          	subss  xmm1,xmm7
    cc14:	0f 2e c2             	ucomiss xmm0,xmm2
    cc17:	72 06                	jb     cc1f <spin_22+0x234f>
    cc19:	f3 0f 51 c0          	sqrtss xmm0,xmm0
    cc1d:	eb 2c                	jmp    cc4b <spin_22+0x237b>
    cc1f:	0f 29 64 24 70       	movaps XMMWORD PTR [rsp+0x70],xmm4
    cc24:	f3 0f 11 4c 24 20    	movss  DWORD PTR [rsp+0x20],xmm1
    cc2a:	e8 01 21 00 00       	call   ed30 <sqrtf@plt>
    cc2f:	f3 0f 10 4c 24 20    	movss  xmm1,DWORD PTR [rsp+0x20]
    cc35:	0f 57 d2             	xorps  xmm2,xmm2
    cc38:	0f 28 64 24 70       	movaps xmm4,XMMWORD PTR [rsp+0x70]
    cc3d:	f3 0f 10 5c 24 0c    	movss  xmm3,DWORD PTR [rsp+0xc]
    cc43:	f3 0f 10 2d 65 4a ff 	movss  xmm5,DWORD PTR [rip+0xffffffffffff4a65]        # 16b0 <_IO_stdin_used+0x24>
    cc4a:	ff 
    cc4b:	f3 0f 5c c8          	subss  xmm1,xmm0
    cc4f:	66 0f 7e c9          	movd   ecx,xmm1
    cc53:	0f 2e e9             	ucomiss xmm5,xmm1
    cc56:	b8 28 6b 6e 4e       	mov    eax,0x4e6e6b28
    cc5b:	0f 46 c1             	cmovbe eax,ecx
    cc5e:	66 0f 6e c0          	movd   xmm0,eax
    cc62:	66 0f 6e cd          	movd   xmm1,ebp
    cc66:	0f 2e c8             	ucomiss xmm1,xmm0
    cc69:	0f 46 c5             	cmovbe eax,ebp
    cc6c:	66 0f 6e c0          	movd   xmm0,eax
    cc70:	0f 28 cc             	movaps xmm1,xmm4
    cc73:	f3 0f c2 ca 05       	cmpnltss xmm1,xmm2
    cc78:	f3 0f c2 84 24 50 01 	cmpnltss xmm0,DWORD PTR [rsp+0x150]
    cc7f:	00 00 05 
    cc82:	0f 54 c1             	andps  xmm0,xmm1
    cc85:	66 0f 7e c0          	movd   eax,xmm0
    cc89:	f3 0f 10 05 07 4a ff 	movss  xmm0,DWORD PTR [rip+0xffffffffffff4a07]        # 1698 <_IO_stdin_used+0xc>
    cc90:	ff 
    cc91:	a8 01                	test   al,0x1
    cc93:	74 0c                	je     cca1 <spin_22+0x23d1>
    cc95:	f3 0f 59 25 c7 49 ff 	mulss  xmm4,DWORD PTR [rip+0xffffffffffff49c7]        # 1664 <_IO_stdin_used-0x28>
    cc9c:	ff 
    cc9d:	f3 0f 58 c4          	addss  xmm0,xmm4
    cca1:	f3 0f 10 8c 24 dc 00 	movss  xmm1,DWORD PTR [rsp+0xdc]
    cca8:	00 00 
    ccaa:	f3 0f 59 c8          	mulss  xmm1,xmm0
    ccae:	f3 0f 58 d9          	addss  xmm3,xmm1
    ccb2:	66 0f 7e da          	movd   edx,xmm3
    ccb6:	89 d0                	mov    eax,edx
    ccb8:	48 8b 8c 24 b8 01 00 	mov    rcx,QWORD PTR [rsp+0x1b8]
    ccbf:	00 
    ccc0:	48 89 01             	mov    QWORD PTR [rcx],rax
    ccc3:	48 81 c4 e8 01 00 00 	add    rsp,0x1e8
    ccca:	5b                   	pop    rbx
    cccb:	41 5c                	pop    r12
    cccd:	41 5d                	pop    r13
    cccf:	41 5e                	pop    r14
    ccd1:	41 5f                	pop    r15
    ccd3:	5d                   	pop    rbp
    ccd4:	c3                   	ret    

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
