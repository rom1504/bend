
/home/ai/bend2/build/publish/bend/selfhost/build/phase99/phase102-runtime-products04/scalar-region-8192/candidate.program:     file format elf64-x86-64


Disassembly of section .text:

0000000000008b00 <WL_FID_110_97_116_105_118_101_95_107_95_53_50_51_54_>:
    8b00:	55                   	push   rbp
    8b01:	48 83 ec 20          	sub    rsp,0x20
    8b05:	4c 89 f1             	mov    rcx,r14
    8b08:	4c 89 e7             	mov    rdi,r12
    8b0b:	4d 8b 46 e8          	mov    r8,QWORD PTR [r14-0x18]
    8b0f:	45 8b 66 f0          	mov    r12d,DWORD PTR [r14-0x10]
    8b13:	41 8b 5e f8          	mov    ebx,DWORD PTR [r14-0x8]
    8b17:	45 85 ff             	test   r15d,r15d
    8b1a:	74 24                	je     8b40 <WL_FID_110_97_116_105_118_101_95_107_95_53_50_51_54_+0x40>
    8b1c:	4c 8d 71 f8          	lea    r14,[rcx-0x8]
    8b20:	48 89 71 e8          	mov    QWORD PTR [rcx-0x18],rsi
    8b24:	48 c7 41 f0 2e 00 00 	mov    QWORD PTR [rcx-0x10],0x2e
    8b2b:	00 
    8b2c:	31 f6                	xor    esi,esi
    8b2e:	4d 85 c0             	test   r8,r8
    8b31:	75 74                	jne    8ba7 <WL_FID_110_97_116_105_118_101_95_107_95_53_50_51_54_+0xa7>
    8b33:	49 89 fc             	mov    r12,rdi
    8b36:	48 83 c4 20          	add    rsp,0x20
    8b3a:	5d                   	pop    rbp
    8b3b:	e9 a0 06 00 00       	jmp    91e0 <WL_FID_36_100_105_114_101_99_116_46_85_51_50_46_115_104_111_119_>
    8b40:	4c 8b 51 d0          	mov    r10,QWORD PTR [rcx-0x30]
    8b44:	4c 8b 49 d8          	mov    r9,QWORD PTR [rcx-0x28]
    8b48:	49 8b 45 10          	mov    rax,QWORD PTR [r13+0x10]
    8b4c:	48 85 c0             	test   rax,rax
    8b4f:	0f 84 5d 01 00 00    	je     8cb2 <WL_FID_110_97_116_105_118_101_95_107_95_53_50_51_54_+0x1b2>
    8b55:	48 8b 14 c7          	mov    rdx,QWORD PTR [rdi+rax*8]
    8b59:	49 89 55 10          	mov    QWORD PTR [r13+0x10],rdx
    8b5d:	49 83 85 10 01 00 00 	add    QWORD PTR [r13+0x110],0xfffffffffffffffc
    8b64:	fc 
    8b65:	4c 8d 71 e8          	lea    r14,[rcx-0x18]
    8b69:	48 c7 44 c7 08 ff ff 	mov    QWORD PTR [rdi+rax*8+0x8],0xffffffffffffffff
    8b70:	ff ff 
    8b72:	4c 89 54 c7 10       	mov    QWORD PTR [rdi+rax*8+0x10],r10
    8b77:	49 c1 e1 20          	shl    r9,0x20
    8b7b:	49 ff c1             	inc    r9
    8b7e:	4c 89 4c c7 18       	mov    QWORD PTR [rdi+rax*8+0x18],r9
    8b83:	48 89 34 c7          	mov    QWORD PTR [rdi+rax*8],rsi
    8b87:	48 ba 00 00 00 00 00 	movabs rdx,0x5002e0000000000
    8b8e:	2e 00 05 
    8b91:	48 09 c2             	or     rdx,rax
    8b94:	48 89 51 d0          	mov    QWORD PTR [rcx-0x30],rdx
    8b98:	48 c7 41 d8 01 00 00 	mov    QWORD PTR [rcx-0x28],0x1
    8b9f:	00 
    8ba0:	31 f6                	xor    esi,esi
    8ba2:	4d 85 c0             	test   r8,r8
    8ba5:	74 8c                	je     8b33 <WL_FID_110_97_116_105_118_101_95_107_95_53_50_51_54_+0x33>
    8ba7:	4d 85 e4             	test   r12,r12
    8baa:	74 87                	je     8b33 <WL_FID_110_97_116_105_118_101_95_107_95_53_50_51_54_+0x33>
    8bac:	4c 89 74 24 10       	mov    QWORD PTR [rsp+0x10],r14
    8bb1:	48 89 7c 24 18       	mov    QWORD PTR [rsp+0x18],rdi
    8bb6:	44 89 7c 24 0c       	mov    DWORD PTR [rsp+0xc],r15d
    8bbb:	89 d8                	mov    eax,ebx
    8bbd:	25 ff 03 00 00       	and    eax,0x3ff
    8bc2:	05 00 fe ff ff       	add    eax,0xfffffe00
    8bc7:	c1 eb 0a             	shr    ebx,0xa
    8bca:	81 e3 ff 03 00 00    	and    ebx,0x3ff
    8bd0:	81 c3 00 fe ff ff    	add    ebx,0xfffffe00
    8bd6:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
    8bdd:	00 00 00 
    8be0:	45 31 db             	xor    r11d,r11d
    8be3:	4c 89 e1             	mov    rcx,r12
    8be6:	31 ff                	xor    edi,edi
    8be8:	45 31 d2             	xor    r10d,r10d
    8beb:	31 d2                	xor    edx,edx
    8bed:	0f 1f 00             	nop    DWORD PTR [rax]
    8bf0:	41 89 f9             	mov    r9d,edi
    8bf3:	45 0f af c9          	imul   r9d,r9d
    8bf7:	44 89 cd             	mov    ebp,r9d
    8bfa:	c1 ed 08             	shr    ebp,0x8
    8bfd:	41 c1 f9 1f          	sar    r9d,0x1f
    8c01:	41 81 e1 00 00 00 ff 	and    r9d,0xff000000
    8c08:	41 09 e9             	or     r9d,ebp
    8c0b:	44 89 dd             	mov    ebp,r11d
    8c0e:	0f af ed             	imul   ebp,ebp
    8c11:	41 89 ee             	mov    r14d,ebp
    8c14:	41 c1 ee 08          	shr    r14d,0x8
    8c18:	c1 fd 1f             	sar    ebp,0x1f
    8c1b:	81 e5 00 00 00 ff    	and    ebp,0xff000000
    8c21:	44 09 f5             	or     ebp,r14d
    8c24:	45 8d 34 29          	lea    r14d,[r9+rbp*1]
    8c28:	45 31 ff             	xor    r15d,r15d
    8c2b:	41 81 fe 01 04 00 00 	cmp    r14d,0x401
    8c32:	41 0f 93 c7          	setae  r15b
    8c36:	01 c5                	add    ebp,eax
    8c38:	44 29 cd             	sub    ebp,r9d
    8c3b:	41 89 f9             	mov    r9d,edi
    8c3e:	45 0f af cb          	imul   r9d,r11d
    8c42:	45 01 c9             	add    r9d,r9d
    8c45:	45 89 ce             	mov    r14d,r9d
    8c48:	41 c1 ee 08          	shr    r14d,0x8
    8c4c:	41 01 de             	add    r14d,ebx
    8c4f:	41 c1 f9 1f          	sar    r9d,0x1f
    8c53:	41 81 e1 00 00 00 ff 	and    r9d,0xff000000
    8c5a:	45 01 f1             	add    r9d,r14d
    8c5d:	45 31 f6             	xor    r14d,r14d
    8c60:	45 09 fa             	or     r10d,r15d
    8c63:	41 0f 45 eb          	cmovne ebp,r11d
    8c67:	41 0f 44 f9          	cmove  edi,r9d
    8c6b:	41 0f 94 c6          	sete   r14b
    8c6f:	44 01 f2             	add    edx,r14d
    8c72:	41 89 eb             	mov    r11d,ebp
    8c75:	48 ff c9             	dec    rcx
    8c78:	0f 85 72 ff ff ff    	jne    8bf0 <WL_FID_110_97_116_105_118_101_95_107_95_53_50_51_54_+0xf0>
    8c7e:	31 c9                	xor    ecx,ecx
    8c80:	81 fa 00 20 00 00    	cmp    edx,0x2000
    8c86:	0f 94 c1             	sete   cl
    8c89:	01 ce                	add    esi,ecx
    8c8b:	49 ff c8             	dec    r8
    8c8e:	0f 85 4c ff ff ff    	jne    8be0 <WL_FID_110_97_116_105_118_101_95_107_95_53_50_51_54_+0xe0>
    8c94:	89 f6                	mov    esi,esi
    8c96:	44 8b 7c 24 0c       	mov    r15d,DWORD PTR [rsp+0xc]
    8c9b:	48 8b 7c 24 18       	mov    rdi,QWORD PTR [rsp+0x18]
    8ca0:	4c 8b 74 24 10       	mov    r14,QWORD PTR [rsp+0x10]
    8ca5:	49 89 fc             	mov    r12,rdi
    8ca8:	48 83 c4 20          	add    rsp,0x20
    8cac:	5d                   	pop    rbp
    8cad:	e9 2e 05 00 00       	jmp    91e0 <WL_FID_36_100_105_114_101_99_116_46_85_51_50_46_115_104_111_119_>
    8cb2:	48 89 f5             	mov    rbp,rsi
    8cb5:	4c 89 ee             	mov    rsi,r13
    8cb8:	ba 02 00 00 00       	mov    edx,0x2
    8cbd:	e8 26 82 00 00       	call   10ee8 <heap_alloc_miss>
    8cc2:	48 89 ee             	mov    rsi,rbp
    8cc5:	e9 9b fe ff ff       	jmp    8b65 <WL_FID_110_97_116_105_118_101_95_107_95_53_50_51_54_+0x65>

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
