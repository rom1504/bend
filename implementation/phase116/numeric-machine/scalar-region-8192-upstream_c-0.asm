
/home/ai/bend2/build/publish/bend/selfhost/build/phase93/broad01/scalar-region-8192/upstream.program:     file format elf64-x86-64


Disassembly of section .text:

0000000000009970 <WL_FID_MAIN_C101>:
    9970:	55                   	push   rbp
    9971:	48 83 ec 30          	sub    rsp,0x30
    9975:	48 85 f6             	test   rsi,rsi
    9978:	0f 84 5f 01 00 00    	je     9add <WL_FID_MAIN_C101+0x16d>
    997e:	48 c7 44 24 08 00 00 	mov    QWORD PTR [rsp+0x8],0x0
    9985:	00 00 
    9987:	b8 ff ff ff ff       	mov    eax,0xffffffff
    998c:	48 21 c2             	and    rdx,rax
    998f:	0f 84 25 01 00 00    	je     9aba <WL_FID_MAIN_C101+0x14a>
    9995:	4c 89 64 24 18       	mov    QWORD PTR [rsp+0x18],r12
    999a:	44 89 7c 24 14       	mov    DWORD PTR [rsp+0x14],r15d
    999f:	4c 89 44 24 20       	mov    QWORD PTR [rsp+0x20],r8
    99a4:	4c 89 6c 24 28       	mov    QWORD PTR [rsp+0x28],r13
    99a9:	41 89 cd             	mov    r13d,ecx
    99ac:	41 81 e5 ff 03 00 00 	and    r13d,0x3ff
    99b3:	41 81 c5 00 fe ff ff 	add    r13d,0xfffffe00
    99ba:	c1 e9 0a             	shr    ecx,0xa
    99bd:	81 e1 ff 03 00 00    	and    ecx,0x3ff
    99c3:	81 c1 00 fe ff ff    	add    ecx,0xfffffe00
    99c9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    99d0:	45 31 c9             	xor    r9d,r9d
    99d3:	31 db                	xor    ebx,ebx
    99d5:	45 31 d2             	xor    r10d,r10d
    99d8:	45 31 db             	xor    r11d,r11d
    99db:	49 89 d4             	mov    r12,rdx
    99de:	48 89 d5             	mov    rbp,rdx
    99e1:	66 66 66 66 66 66 2e 	data16 data16 data16 data16 data16 nop WORD PTR cs:[rax+rax*1+0x0]
    99e8:	0f 1f 84 00 00 00 00 
    99ef:	00 
    99f0:	44 89 d8             	mov    eax,r11d
    99f3:	0f af c0             	imul   eax,eax
    99f6:	41 89 c0             	mov    r8d,eax
    99f9:	41 c1 f8 1f          	sar    r8d,0x1f
    99fd:	41 81 e0 00 00 00 ff 	and    r8d,0xff000000
    9a04:	c1 e8 08             	shr    eax,0x8
    9a07:	44 09 c0             	or     eax,r8d
    9a0a:	45 89 c8             	mov    r8d,r9d
    9a0d:	45 0f af c0          	imul   r8d,r8d
    9a11:	44 89 c2             	mov    edx,r8d
    9a14:	c1 fa 1f             	sar    edx,0x1f
    9a17:	81 e2 00 00 00 ff    	and    edx,0xff000000
    9a1d:	41 c1 e8 08          	shr    r8d,0x8
    9a21:	41 09 d0             	or     r8d,edx
    9a24:	42 8d 14 00          	lea    edx,[rax+r8*1]
    9a28:	31 ff                	xor    edi,edi
    9a2a:	81 fa 01 04 00 00    	cmp    edx,0x401
    9a30:	40 0f 93 c7          	setae  dil
    9a34:	44 89 da             	mov    edx,r11d
    9a37:	41 0f af d1          	imul   edx,r9d
    9a3b:	01 d2                	add    edx,edx
    9a3d:	41 89 d7             	mov    r15d,edx
    9a40:	41 c1 ff 1f          	sar    r15d,0x1f
    9a44:	41 81 e7 00 00 00 ff 	and    r15d,0xff000000
    9a4b:	c1 ea 08             	shr    edx,0x8
    9a4e:	01 ca                	add    edx,ecx
    9a50:	44 01 fa             	add    edx,r15d
    9a53:	45 89 ef             	mov    r15d,r13d
    9a56:	45 29 c7             	sub    r15d,r8d
    9a59:	41 01 c7             	add    r15d,eax
    9a5c:	31 c0                	xor    eax,eax
    9a5e:	41 09 fa             	or     r10d,edi
    9a61:	0f 94 c0             	sete   al
    9a64:	45 0f 44 df          	cmove  r11d,r15d
    9a68:	44 0f 44 ca          	cmove  r9d,edx
    9a6c:	01 c3                	add    ebx,eax
    9a6e:	48 ff cd             	dec    rbp
    9a71:	0f 85 79 ff ff ff    	jne    99f0 <WL_FID_MAIN_C101+0x80>
    9a77:	31 c0                	xor    eax,eax
    9a79:	81 fb 00 20 00 00    	cmp    ebx,0x2000
    9a7f:	0f 94 c0             	sete   al
    9a82:	48 8b 54 24 08       	mov    rdx,QWORD PTR [rsp+0x8]
    9a87:	01 c2                	add    edx,eax
    9a89:	48 89 54 24 08       	mov    QWORD PTR [rsp+0x8],rdx
    9a8e:	48 ff ce             	dec    rsi
    9a91:	4c 89 e2             	mov    rdx,r12
    9a94:	0f 85 36 ff ff ff    	jne    99d0 <WL_FID_MAIN_C101+0x60>
    9a9a:	48 8b 44 24 08       	mov    rax,QWORD PTR [rsp+0x8]
    9a9f:	89 c0                	mov    eax,eax
    9aa1:	48 89 44 24 08       	mov    QWORD PTR [rsp+0x8],rax
    9aa6:	4c 8b 6c 24 28       	mov    r13,QWORD PTR [rsp+0x28]
    9aab:	4c 8b 44 24 20       	mov    r8,QWORD PTR [rsp+0x20]
    9ab0:	44 8b 7c 24 14       	mov    r15d,DWORD PTR [rsp+0x14]
    9ab5:	4c 8b 64 24 18       	mov    r12,QWORD PTR [rsp+0x18]
    9aba:	45 85 ff             	test   r15d,r15d
    9abd:	74 2c                	je     9aeb <WL_FID_MAIN_C101+0x17b>
    9abf:	4d 89 06             	mov    QWORD PTR [r14],r8
    9ac2:	49 c7 46 08 2c 00 00 	mov    QWORD PTR [r14+0x8],0x2c
    9ac9:	00 
    9aca:	49 83 c6 10          	add    r14,0x10
    9ace:	48 8b 74 24 08       	mov    rsi,QWORD PTR [rsp+0x8]
    9ad3:	48 83 c4 30          	add    rsp,0x30
    9ad7:	5d                   	pop    rbp
    9ad8:	e9 33 e3 ff ff       	jmp    7e10 <WL_FID_U32_SHOW>
    9add:	48 c7 44 24 08 00 00 	mov    QWORD PTR [rsp+0x8],0x0
    9ae4:	00 00 
    9ae6:	45 85 ff             	test   r15d,r15d
    9ae9:	75 d4                	jne    9abf <WL_FID_MAIN_C101+0x14f>
    9aeb:	4d 8b 4e e8          	mov    r9,QWORD PTR [r14-0x18]
    9aef:	49 8b 4e f0          	mov    rcx,QWORD PTR [r14-0x10]
    9af3:	49 8b 45 10          	mov    rax,QWORD PTR [r13+0x10]
    9af7:	48 85 c0             	test   rax,rax
    9afa:	0f 84 93 00 00 00    	je     9b93 <WL_FID_MAIN_C101+0x223>
    9b00:	49 8b 14 c4          	mov    rdx,QWORD PTR [r12+rax*8]
    9b04:	49 89 55 10          	mov    QWORD PTR [r13+0x10],rdx
    9b08:	49 83 85 10 01 00 00 	add    QWORD PTR [r13+0x110],0xfffffffffffffffc
    9b0f:	fc 
    9b10:	49 c7 44 c4 08 ff ff 	mov    QWORD PTR [r12+rax*8+0x8],0xffffffffffffffff
    9b17:	ff ff 
    9b19:	4d 89 4c c4 10       	mov    QWORD PTR [r12+rax*8+0x10],r9
    9b1e:	48 c1 e1 20          	shl    rcx,0x20
    9b22:	48 ff c1             	inc    rcx
    9b25:	49 89 4c c4 18       	mov    QWORD PTR [r12+rax*8+0x18],rcx
    9b2a:	4d 89 04 c4          	mov    QWORD PTR [r12+rax*8],r8
    9b2e:	48 b9 00 00 00 00 00 	movabs rcx,0x5002c0000000000
    9b35:	2c 00 05 
    9b38:	48 09 c1             	or     rcx,rax
    9b3b:	49 89 4e e8          	mov    QWORD PTR [r14-0x18],rcx
    9b3f:	49 c7 46 f0 01 00 00 	mov    QWORD PTR [r14-0x10],0x1
    9b46:	00 
    9b47:	49 8b 45 10          	mov    rax,QWORD PTR [r13+0x10]
    9b4b:	48 85 c0             	test   rax,rax
    9b4e:	74 58                	je     9ba8 <WL_FID_MAIN_C101+0x238>
    9b50:	49 8b 14 c4          	mov    rdx,QWORD PTR [r12+rax*8]
    9b54:	49 89 55 10          	mov    QWORD PTR [r13+0x10],rdx
    9b58:	49 83 85 10 01 00 00 	add    QWORD PTR [r13+0x110],0xfffffffffffffffc
    9b5f:	fc 
    9b60:	49 89 4c c4 08       	mov    QWORD PTR [r12+rax*8+0x8],rcx
    9b65:	48 b9 00 00 00 00 01 	movabs rcx,0x100000000
    9b6c:	00 00 00 
    9b6f:	49 89 4c c4 10       	mov    QWORD PTR [r12+rax*8+0x10],rcx
    9b74:	48 8b 4c 24 08       	mov    rcx,QWORD PTR [rsp+0x8]
    9b79:	49 89 0c c4          	mov    QWORD PTR [r12+rax*8],rcx
    9b7d:	48 b9 00 00 00 00 00 	movabs rcx,0x500130000000000
    9b84:	13 00 05 
    9b87:	48 09 c1             	or     rcx,rax
    9b8a:	48 89 c8             	mov    rax,rcx
    9b8d:	48 83 c4 30          	add    rsp,0x30
    9b91:	5d                   	pop    rbp
    9b92:	c3                   	ret    
    9b93:	4c 89 e7             	mov    rdi,r12
    9b96:	4c 89 ee             	mov    rsi,r13
    9b99:	ba 02 00 00 00       	mov    edx,0x2
    9b9e:	e8 83 17 00 00       	call   b326 <heap_alloc_miss>
    9ba3:	e9 68 ff ff ff       	jmp    9b10 <WL_FID_MAIN_C101+0x1a0>
    9ba8:	4c 89 e7             	mov    rdi,r12
    9bab:	4c 89 ee             	mov    rsi,r13
    9bae:	ba 02 00 00 00       	mov    edx,0x2
    9bb3:	e8 6e 17 00 00       	call   b326 <heap_alloc_miss>
    9bb8:	eb a6                	jmp    9b60 <WL_FID_MAIN_C101+0x1f0>

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
