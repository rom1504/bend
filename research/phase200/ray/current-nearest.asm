<p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>:
    485c:	push   rbp
    485d:	mov    rbp,rsp
    4860:	sub    rsp,0xd20
    4867:	mov    QWORD PTR [rbp-0x10],r12
    486b:	mov    QWORD PTR [rbp-0x8],rbx
    486f:	mov    QWORD PTR [rbp-0x18],r13
    4873:	mov    QWORD PTR [rbp-0x20],r14
    4877:	mov    QWORD PTR [rbp-0x28],r15
    487b:	mov    rax,rdi
    487e:	mov    r12,rax
    4881:	mov    rax,rsi
    4884:	mov    QWORD PTR [rbp-0x30],rax
    4888:	mov    rax,rdx
    488b:	mov    rbx,rax
    488e:	mov    rax,rcx
    4891:	mov    r13,rax
    4894:	mov    rax,r8
    4897:	mov    r14,rax
    489a:	mov    rax,r9
    489d:	mov    r15,rax
    48a0:	mov    rax,QWORD PTR [rbp+0x10]
    48a4:	mov    QWORD PTR [rbp-0x58],rax
    48a8:	mov    rax,QWORD PTR [rbp+0x18]
    48ac:	mov    QWORD PTR [rbp-0x60],rax
    48b0:	mov    rax,QWORD PTR [rbp+0x20]
    48b4:	mov    QWORD PTR [rbp-0x68],rax
    48b8:	mov    rax,QWORD PTR [rbp+0x28]
    48bc:	mov    QWORD PTR [rbp-0x70],rax
    48c0:	mov    rax,QWORD PTR [rbp+0x30]
    48c4:	mov    QWORD PTR [rbp-0x78],rax
    48c8:	mov    rax,QWORD PTR [rbp+0x38]
    48cc:	mov    QWORD PTR [rbp-0x80],rax
    48d0:	mov    rax,QWORD PTR [rbp+0x40]
    48d4:	mov    QWORD PTR [rbp-0x88],rax
    48db:	mov    rax,QWORD PTR [rbp+0x48]
    48df:	mov    rsi,rax
    48e2:	mov    rdi,rbx
    48e5:	cmp    rdi,0x0
    48ec:	sete   dil
    48f0:	movzx  edi,dil
    48f4:	mov    r10,rdi
    48f7:	test   r10d,r10d
    48fa:	je     4acb <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x26f>
    4900:	mov    r8,rsi
    4903:	cmp    r8,0x1
    490a:	sete   r8b
    490e:	movzx  r8d,r8b
    4912:	mov    rdi,rsi
    4915:	shr    rdi,0x28
    4919:	and    rdi,0x7fffff
    4920:	movabs rdx,0x2
    492a:	or     rdx,0x10000
    4931:	cmp    rdi,rdx
    4934:	sete   dil
    4938:	movzx  edi,dil
    493c:	or     edi,r8d
    493f:	xor    edi,0x1
    4945:	mov    r10,rdi
    4948:	test   r10d,r10d
    494b:	je     49b5 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x159>
    4951:	mov    r10,QWORD PTR [rbp-0x88]
    4958:	mov    r10d,r10d
    495b:	mov    QWORD PTR [rbp-0x970],r10
    4962:	cmp    r10,0x9
    4969:	sete   r10b
    496d:	movzx  r10d,r10b
    4971:	mov    QWORD PTR [rbp-0x978],r10
    4978:	mov    r11,QWORD PTR [rbp-0x30]
    497c:	mov    QWORD PTR [r11],r10
    497f:	mov    r10,QWORD PTR [rbp-0x80]
    4983:	mov    r11,QWORD PTR [rbp-0x30]
    4987:	mov    QWORD PTR [r11+0x8],r10
    498b:	mov    r10,QWORD PTR [rbp-0x88]
    4992:	mov    r11,QWORD PTR [rbp-0x30]
    4996:	mov    QWORD PTR [r11+0x10],r10
    499a:	xor    eax,eax
    499c:	mov    r12,QWORD PTR [rbp-0x10]
    49a0:	mov    rbx,QWORD PTR [rbp-0x8]
    49a4:	mov    r13,QWORD PTR [rbp-0x18]
    49a8:	mov    r14,QWORD PTR [rbp-0x20]
    49ac:	mov    r15,QWORD PTR [rbp-0x28]
    49b0:	mov    rsp,rbp
    49b3:	pop    rbp
    49b4:	ret    
    49b5:	mov    r8,rsi
    49b8:	cmp    r8,0x1
    49bf:	sete   r8b
    49c3:	movzx  r8d,r8b
    49c7:	mov    rdi,rsi
    49ca:	shr    rdi,0x28
    49ce:	and    rdi,0x7fffff
    49d5:	movabs rdx,0x2
    49df:	or     rdx,0x10000
    49e6:	cmp    rdi,rdx
    49e9:	sete   dil
    49ed:	movzx  edi,dil
    49f1:	or     edi,r8d
    49f4:	mov    r10,rdi
    49f7:	test   r10d,r10d
    49fa:	je     4a5e <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x202>
    4a00:	mov    r10,QWORD PTR [rbp-0x78]
    4a04:	mov    r10d,r10d
    4a07:	mov    QWORD PTR [rbp-0x970],r10
    4a0e:	cmp    r10,0x9
    4a15:	sete   r10b
    4a19:	movzx  r10d,r10b
    4a1d:	mov    QWORD PTR [rbp-0x978],r10
    4a24:	mov    r11,QWORD PTR [rbp-0x30]
    4a28:	mov    QWORD PTR [r11],r10
    4a2b:	mov    r10,QWORD PTR [rbp-0x70]
    4a2f:	mov    r11,QWORD PTR [rbp-0x30]
    4a33:	mov    QWORD PTR [r11+0x8],r10
    4a37:	mov    r10,QWORD PTR [rbp-0x78]
    4a3b:	mov    r11,QWORD PTR [rbp-0x30]
    4a3f:	mov    QWORD PTR [r11+0x10],r10
    4a43:	xor    eax,eax
    4a45:	mov    r12,QWORD PTR [rbp-0x10]
    4a49:	mov    rbx,QWORD PTR [rbp-0x8]
    4a4d:	mov    r13,QWORD PTR [rbp-0x18]
    4a51:	mov    r14,QWORD PTR [rbp-0x20]
    4a55:	mov    r15,QWORD PTR [rbp-0x28]
    4a59:	mov    rsp,rbp
    4a5c:	pop    rbp
    4a5d:	ret    
    4a5e:	mov    rdi,r12
    4a61:	movabs rsi,0x4
    4a6b:	mov    esi,esi
    4a6d:	xor    eax,eax
    4a6f:	call   4a74 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x218>
    4a74:	mov    QWORD PTR [rbp-0x980],rax
    4a7b:	movabs r10,0x0
    4a85:	mov    r11,QWORD PTR [rbp-0x30]
    4a89:	mov    QWORD PTR [r11],r10
    4a8c:	movabs r10,0x0
    4a96:	mov    r11,QWORD PTR [rbp-0x30]
    4a9a:	mov    QWORD PTR [r11+0x8],r10
    4a9e:	movabs r10,0x0
    4aa8:	mov    r11,QWORD PTR [rbp-0x30]
    4aac:	mov    QWORD PTR [r11+0x10],r10
    4ab0:	xor    eax,eax
    4ab2:	mov    r12,QWORD PTR [rbp-0x10]
    4ab6:	mov    rbx,QWORD PTR [rbp-0x8]
    4aba:	mov    r13,QWORD PTR [rbp-0x18]
    4abe:	mov    r14,QWORD PTR [rbp-0x20]
    4ac2:	mov    r15,QWORD PTR [rbp-0x28]
    4ac6:	mov    rsp,rbp
    4ac9:	pop    rbp
    4aca:	ret    
    4acb:	mov    rdi,rbx
    4ace:	cmp    rdi,0x0
    4ad5:	setne  dil
    4ad9:	movzx  edi,dil
    4add:	mov    r10,rdi
    4ae0:	test   r10d,r10d
    4ae3:	je     55b2 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xd56>
    4ae9:	sub    rbx,0x1
    4af0:	mov    r8,rsi
    4af3:	cmp    r8,0x1
    4afa:	sete   r8b
    4afe:	movzx  r8d,r8b
    4b02:	mov    rdi,rsi
    4b05:	shr    rdi,0x28
    4b09:	and    rdi,0x7fffff
    4b10:	movabs rdx,0x2
    4b1a:	or     rdx,0x10000
    4b21:	cmp    rdi,rdx
    4b24:	sete   dil
    4b28:	movzx  edi,dil
    4b2c:	or     edi,r8d
    4b2f:	xor    edi,0x1
    4b35:	mov    r10,rdi
    4b38:	test   r10d,r10d
    4b3b:	je     5004 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x7a8>
    4b41:	mov    rdi,rbx
    4b44:	cmp    rdi,0x8
    4b4b:	setb   dil
    4b4f:	movzx  edi,dil
    4b53:	mov    r10,rdi
    4b56:	test   r10d,r10d
    4b59:	je     4b67 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x30b>
    4b5f:	mov    rdi,rbx
    4b62:	jmp    4b71 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x315>
    4b67:	movabs rdi,0x8
    4b71:	shl    rdi,0x3
    4b75:	mov    r11,rdi
    4b78:	lea    rdi,[rip+0x0]        # 4b7f <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x323>
    4b7f:	add    rdi,r11
    4b82:	mov    r10,rdi
    4b85:	mov    r10,QWORD PTR [r10]
    4b88:	mov    QWORD PTR [rbp-0x9b0],r10
    4b8f:	mov    rdi,rbx
    4b92:	cmp    rdi,0x8
    4b99:	setb   dil
    4b9d:	movzx  edi,dil
    4ba1:	mov    r10,rdi
    4ba4:	test   r10d,r10d
    4ba7:	je     4bb5 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x359>
    4bad:	mov    rdi,rbx
    4bb0:	jmp    4bbf <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x363>
    4bb5:	movabs rdi,0x8
    4bbf:	shl    rdi,0x3
    4bc3:	mov    r11,rdi
    4bc6:	lea    rdi,[rip+0x0]        # 4bcd <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x371>
    4bcd:	add    rdi,r11
    4bd0:	mov    r10,rdi
    4bd3:	mov    r10,QWORD PTR [r10]
    4bd6:	mov    QWORD PTR [rbp-0x9b8],r10
    4bdd:	mov    rdi,rbx
    4be0:	cmp    rdi,0x8
    4be7:	setb   dil
    4beb:	movzx  edi,dil
    4bef:	mov    r10,rdi
    4bf2:	test   r10d,r10d
    4bf5:	je     4c03 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3a7>
    4bfb:	mov    rdi,rbx
    4bfe:	jmp    4c0d <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3b1>
    4c03:	movabs rdi,0x8
    4c0d:	shl    rdi,0x3
    4c11:	mov    r11,rdi
    4c14:	lea    rdi,[rip+0x0]        # 4c1b <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3bf>
    4c1b:	add    rdi,r11
    4c1e:	mov    r10,rdi
    4c21:	mov    r10,QWORD PTR [r10]
    4c24:	mov    QWORD PTR [rbp-0x9c0],r10
    4c2b:	mov    rdi,rbx
    4c2e:	cmp    rdi,0x8
    4c35:	setb   dil
    4c39:	movzx  edi,dil
    4c3d:	mov    r10,rdi
    4c40:	test   r10d,r10d
    4c43:	je     4c51 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3f5>
    4c49:	mov    rdi,rbx
    4c4c:	jmp    4c5b <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3ff>
    4c51:	movabs rdi,0x8
    4c5b:	shl    rdi,0x3
    4c5f:	mov    r11,rdi
    4c62:	lea    rdi,[rip+0x0]        # 4c69 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x40d>
    4c69:	add    rdi,r11
    4c6c:	mov    r9,QWORD PTR [rdi]
    4c6f:	movd   xmm1,DWORD PTR [rbp-0x9b0]
    4c77:	movd   xmm2,r13d
    4c7c:	subss  xmm2,xmm1
    4c80:	movaps xmm3,xmm2
    4c83:	movd   xmm1,DWORD PTR [rbp-0x9b8]
    4c8b:	movd   xmm2,r14d
    4c90:	subss  xmm2,xmm1
    4c94:	movaps xmm4,xmm2
    4c97:	movd   xmm1,DWORD PTR [rbp-0x9c0]
    4c9f:	movd   xmm2,r15d
    4ca4:	subss  xmm2,xmm1
    4ca8:	movaps xmm5,xmm2
    4cab:	movd   xmm1,DWORD PTR [rbp-0x58]
    4cb0:	movaps xmm2,xmm3
    4cb3:	mulss  xmm2,xmm1
    4cb7:	movaps xmm6,xmm2
    4cba:	movd   xmm1,DWORD PTR [rbp-0x60]
    4cbf:	movaps xmm2,xmm4
    4cc2:	mulss  xmm2,xmm1
    4cc6:	movaps xmm7,xmm6
    4cc9:	addss  xmm7,xmm2
    4ccd:	movaps xmm2,xmm7
    4cd0:	movd   xmm1,DWORD PTR [rbp-0x68]
    4cd5:	movaps xmm6,xmm5
    4cd8:	mulss  xmm6,xmm1
    4cdc:	movaps xmm7,xmm2
    4cdf:	addss  xmm7,xmm6
    4ce3:	movd   r10d,xmm7
    4ce8:	mov    QWORD PTR [rbp-0xa38],r10
    4cef:	movaps xmm2,xmm7
    4cf2:	mulss  xmm2,xmm7
    4cf6:	movaps xmm6,xmm2
    4cf9:	movaps xmm2,xmm3
    4cfc:	mulss  xmm2,xmm3
    4d00:	movaps xmm3,xmm2
    4d03:	movaps xmm2,xmm4
    4d06:	mulss  xmm2,xmm4
    4d0a:	movaps xmm4,xmm3
    4d0d:	addss  xmm4,xmm2
    4d11:	movaps xmm2,xmm4
    4d14:	movaps xmm3,xmm5
    4d17:	mulss  xmm3,xmm5
    4d1b:	movaps xmm4,xmm2
    4d1e:	addss  xmm4,xmm3
    4d22:	movaps xmm2,xmm4
    4d25:	movd   xmm1,r9d
    4d2a:	movd   xmm3,r9d
    4d2f:	mulss  xmm3,xmm1
    4d33:	movaps xmm4,xmm2
    4d36:	subss  xmm4,xmm3
    4d3a:	movaps xmm0,xmm6
    4d3d:	subss  xmm0,xmm4
    4d41:	movd   esi,xmm0
    4d45:	movabs r10,0x0
    4d4f:	movd   xmm0,r10d
    4d54:	movd   r10d,xmm0
    4d59:	pxor   xmm0,xmm0
    4d5d:	cvtsi2ss xmm0,r10
    4d62:	movd   r10d,xmm0
    4d67:	movd   xmm2,r10d
    4d6c:	movd   xmm0,esi
    4d70:	movaps xmm1,xmm2
    4d73:	ucomiss xmm0,xmm1
    4d76:	setb   r10b
    4d7a:	setnp  r11b
    4d7e:	and    r10b,r11b
    4d81:	movzx  r10d,r10b
    4d85:	mov    QWORD PTR [rbp-0xab0],r10
    4d8c:	cmp    r10,0x1
    4d93:	sete   r10b
    4d97:	movzx  r10d,r10b
    4d9b:	mov    QWORD PTR [rbp-0xac8],r10
    4da2:	test   r10d,r10d
    4da5:	je     4df3 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x597>
    4dab:	lea    r10,[rbp-0xac0]
    4db2:	movabs r11,0x3b9aca00
    4dbc:	mov    QWORD PTR [r10],r11
    4dbf:	movabs r10,0x3b9aca00
    4dc9:	movd   xmm0,r10d
    4dce:	movd   r10d,xmm0
    4dd3:	pxor   xmm0,xmm0
    4dd7:	cvtsi2ss xmm0,r10
    4ddc:	movd   r10d,xmm0
    4de1:	mov    rdi,r10
    4de4:	mov    r10,rdi
    4de7:	mov    QWORD PTR [rbp-0xad8],r10
    4dee:	jmp    4fbb <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x75f>
    4df3:	lea    r10,[rbp-0xac0]
    4dfa:	movabs r11,0x0
    4e04:	mov    QWORD PTR [r10],r11
    4e07:	movabs r10,0x0
    4e11:	movd   xmm0,r10d
    4e16:	movd   r10d,xmm0
    4e1b:	pxor   xmm0,xmm0
    4e1f:	cvtsi2ss xmm0,r10
    4e24:	movd   r10d,xmm0
    4e29:	mov    rdi,r10
    4e2c:	lea    r10,[rbp-0xac0]
    4e33:	mov    r11,rdi
    4e36:	mov    QWORD PTR [r10],r11
    4e39:	lea    r10,[rbp-0xac0]
    4e40:	mov    r11,QWORD PTR [rbp-0xa38]
    4e47:	mov    QWORD PTR [r10+0x8],r11
    4e4b:	movd   xmm1,DWORD PTR [rbp-0xa38]
    4e53:	movd   xmm0,edi
    4e57:	subss  xmm0,xmm1
    4e5b:	movd   edi,xmm0
    4e5f:	mov    r10,rdi
    4e62:	mov    QWORD PTR [rbp-0xae0],r10
    4e69:	lea    r10,[rbp-0xac0]
    4e70:	mov    r11,rsi
    4e73:	mov    QWORD PTR [r10],r11
    4e76:	lea    r10,[rbp-0xac0]
    4e7d:	movd   xmm0,DWORD PTR [r10]
    4e82:	pxor   xmm1,xmm1
    4e86:	ucomiss xmm1,xmm0
    4e89:	ja     4e98 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x63c>
    4e8f:	sqrtss xmm0,xmm0
    4e93:	jmp    4e9d <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x641>
    4e98:	call   4e9d <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x641>
    4e9d:	movd   edi,xmm0
    4ea1:	lea    r10,[rbp-0xac0]
    4ea8:	mov    r11,QWORD PTR [rbp-0xae0]
    4eaf:	mov    QWORD PTR [r10],r11
    4eb2:	lea    r10,[rbp-0xac0]
    4eb9:	mov    r11,rdi
    4ebc:	mov    QWORD PTR [r10+0x8],r11
    4ec0:	movd   xmm1,edi
    4ec4:	movd   xmm0,DWORD PTR [rbp-0xae0]
    4ecc:	subss  xmm0,xmm1
    4ed0:	movd   edi,xmm0
    4ed4:	movabs r10,0x1
    4ede:	movd   xmm0,r10d
    4ee3:	movd   r10d,xmm0
    4ee8:	pxor   xmm0,xmm0
    4eec:	cvtsi2ss xmm0,r10
    4ef1:	movd   r10d,xmm0
    4ef6:	movd   xmm2,r10d
    4efb:	movaps xmm3,xmm2
    4efe:	movabs r10,0x3e8
    4f08:	movd   xmm0,r10d
    4f0d:	movd   r10d,xmm0
    4f12:	pxor   xmm0,xmm0
    4f16:	cvtsi2ss xmm0,r10
    4f1b:	movd   r10d,xmm0
    4f20:	movd   xmm2,r10d
    4f25:	movaps xmm4,xmm3
    4f28:	divss  xmm4,xmm2
    4f2c:	movd   xmm0,edi
    4f30:	movaps xmm1,xmm4
    4f33:	ucomiss xmm0,xmm1
    4f36:	setb   r10b
    4f3a:	setnp  r11b
    4f3e:	and    r10b,r11b
    4f41:	movzx  r10d,r10b
    4f45:	mov    QWORD PTR [rbp-0xb08],r10
    4f4c:	cmp    r10,0x1
    4f53:	sete   r10b
    4f57:	movzx  r10d,r10b
    4f5b:	mov    QWORD PTR [rbp-0xb10],r10
    4f62:	test   r10d,r10d
    4f65:	je     4fa3 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x747>
    4f6b:	movabs r10,0x3b9aca00
    4f75:	movd   xmm0,r10d
    4f7a:	movd   r10d,xmm0
    4f7f:	pxor   xmm0,xmm0
    4f83:	cvtsi2ss xmm0,r10
    4f88:	movd   r10d,xmm0
    4f8d:	movd   xmm2,r10d
    4f92:	movd   r10d,xmm2
    4f97:	mov    QWORD PTR [rbp-0xb20],r10
    4f9e:	jmp    4fad <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x751>
    4fa3:	mov    r10,rdi
    4fa6:	mov    QWORD PTR [rbp-0xb20],r10
    4fad:	mov    r10,QWORD PTR [rbp-0xb20]
    4fb4:	mov    QWORD PTR [rbp-0xad8],r10
    4fbb:	mov    esi,ebx
    4fbd:	mov    r10,rsi
    4fc0:	mov    QWORD PTR [rbp-0xb30],r10
    4fc7:	movd   xmm0,DWORD PTR [rbp-0xad8]
    4fcf:	movd   xmm1,DWORD PTR [rbp-0x80]
    4fd4:	ucomiss xmm0,xmm1
    4fd7:	setb   r10b
    4fdb:	setnp  r11b
    4fdf:	and    r10b,r11b
    4fe2:	movzx  r10d,r10b
    4fe6:	mov    rsi,r10
    4fe9:	mov    r10,QWORD PTR [rbp-0xad8]
    4ff0:	mov    QWORD PTR [rbp-0x70],r10
    4ff4:	mov    r10,QWORD PTR [rbp-0xb30]
    4ffb:	mov    QWORD PTR [rbp-0x78],r10
    4fff:	jmp    48e2 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x86>
    5004:	mov    r8,rsi
    5007:	cmp    r8,0x1
    500e:	sete   r8b
    5012:	movzx  r8d,r8b
    5016:	mov    rdi,rsi
    5019:	shr    rdi,0x28
    501d:	and    rdi,0x7fffff
    5024:	movabs rdx,0x2
    502e:	or     rdx,0x10000
    5035:	cmp    rdi,rdx
    5038:	sete   dil
    503c:	movzx  edi,dil
    5040:	or     edi,r8d
    5043:	mov    r10,rdi
    5046:	test   r10d,r10d
    5049:	je     5545 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xce9>
    504f:	mov    rdi,rbx
    5052:	cmp    rdi,0x8
    5059:	setb   dil
    505d:	movzx  edi,dil
    5061:	mov    r10,rdi
    5064:	test   r10d,r10d
    5067:	je     5075 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x819>
    506d:	mov    rdi,rbx
    5070:	jmp    507f <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x823>
    5075:	movabs rdi,0x8
    507f:	shl    rdi,0x3
    5083:	mov    r11,rdi
    5086:	lea    rdi,[rip+0x0]        # 508d <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x831>
    508d:	add    rdi,r11
    5090:	mov    r10,rdi
    5093:	mov    r10,QWORD PTR [r10]
    5096:	mov    QWORD PTR [rbp-0xb38],r10
    509d:	mov    rdi,rbx
    50a0:	cmp    rdi,0x8
    50a7:	setb   dil
    50ab:	movzx  edi,dil
    50af:	mov    r10,rdi
    50b2:	test   r10d,r10d
    50b5:	je     50c3 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x867>
    50bb:	mov    rdi,rbx
    50be:	jmp    50cd <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x871>
    50c3:	movabs rdi,0x8
    50cd:	shl    rdi,0x3
    50d1:	mov    r11,rdi
    50d4:	lea    rdi,[rip+0x0]        # 50db <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x87f>
    50db:	add    rdi,r11
    50de:	mov    r10,rdi
    50e1:	mov    r10,QWORD PTR [r10]
    50e4:	mov    QWORD PTR [rbp-0xb40],r10
    50eb:	mov    rdi,rbx
    50ee:	cmp    rdi,0x8
    50f5:	setb   dil
    50f9:	movzx  edi,dil
    50fd:	mov    r10,rdi
    5100:	test   r10d,r10d
    5103:	je     5111 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x8b5>
    5109:	mov    rdi,rbx
    510c:	jmp    511b <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x8bf>
    5111:	movabs rdi,0x8
    511b:	shl    rdi,0x3
    511f:	mov    r11,rdi
    5122:	lea    rdi,[rip+0x0]        # 5129 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x8cd>
    5129:	add    rdi,r11
    512c:	mov    r10,rdi
    512f:	mov    r10,QWORD PTR [r10]
    5132:	mov    QWORD PTR [rbp-0xb48],r10
    5139:	mov    rdi,rbx
    513c:	cmp    rdi,0x8
    5143:	setb   dil
    5147:	movzx  edi,dil
    514b:	mov    r10,rdi
    514e:	test   r10d,r10d
    5151:	je     515f <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x903>
    5157:	mov    rdi,rbx
    515a:	jmp    5169 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x90d>
    515f:	movabs rdi,0x8
    5169:	shl    rdi,0x3
    516d:	mov    r11,rdi
    5170:	lea    rdi,[rip+0x0]        # 5177 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x91b>
    5177:	add    rdi,r11
    517a:	mov    r10,rdi
    517d:	mov    r10,QWORD PTR [r10]
    5180:	mov    QWORD PTR [rbp-0xb50],r10
    5187:	movd   xmm1,DWORD PTR [rbp-0xb38]
    518f:	movd   xmm2,r13d
    5194:	subss  xmm2,xmm1
    5198:	movaps xmm3,xmm2
    519b:	movd   xmm1,DWORD PTR [rbp-0xb40]
    51a3:	movd   xmm2,r14d
    51a8:	subss  xmm2,xmm1
    51ac:	movaps xmm4,xmm2
    51af:	movd   xmm1,DWORD PTR [rbp-0xb48]
    51b7:	movd   xmm2,r15d
    51bc:	subss  xmm2,xmm1
    51c0:	movaps xmm5,xmm2
    51c3:	movd   xmm1,DWORD PTR [rbp-0x58]
    51c8:	movaps xmm2,xmm3
    51cb:	mulss  xmm2,xmm1
    51cf:	movaps xmm6,xmm2
    51d2:	movd   xmm1,DWORD PTR [rbp-0x60]
    51d7:	movaps xmm2,xmm4
    51da:	mulss  xmm2,xmm1
    51de:	movaps xmm7,xmm6
    51e1:	addss  xmm7,xmm2
    51e5:	movaps xmm2,xmm7
    51e8:	movd   xmm1,DWORD PTR [rbp-0x68]
    51ed:	movaps xmm6,xmm5
    51f0:	mulss  xmm6,xmm1
    51f4:	movaps xmm7,xmm2
    51f7:	addss  xmm7,xmm6
    51fb:	movd   r10d,xmm7
    5200:	mov    QWORD PTR [rbp-0xbc0],r10
    5207:	movaps xmm2,xmm7
    520a:	mulss  xmm2,xmm7
    520e:	movaps xmm6,xmm2
    5211:	movaps xmm2,xmm3
    5214:	mulss  xmm2,xmm3
    5218:	movaps xmm3,xmm2
    521b:	movaps xmm2,xmm4
    521e:	mulss  xmm2,xmm4
    5222:	movaps xmm4,xmm3
    5225:	addss  xmm4,xmm2
    5229:	movaps xmm2,xmm4
    522c:	movaps xmm3,xmm5
    522f:	mulss  xmm3,xmm5
    5233:	movaps xmm4,xmm2
    5236:	addss  xmm4,xmm3
    523a:	movaps xmm2,xmm4
    523d:	movd   xmm1,DWORD PTR [rbp-0xb50]
    5245:	movd   xmm3,DWORD PTR [rbp-0xb50]
    524d:	mulss  xmm3,xmm1
    5251:	movaps xmm4,xmm2
    5254:	subss  xmm4,xmm3
    5258:	movaps xmm0,xmm6
    525b:	subss  xmm0,xmm4
    525f:	movd   r10d,xmm0
    5264:	mov    QWORD PTR [rbp-0xc28],r10
    526b:	movabs r10,0x0
    5275:	movd   xmm0,r10d
    527a:	movd   r10d,xmm0
    527f:	pxor   xmm0,xmm0
    5283:	cvtsi2ss xmm0,r10
    5288:	movd   r10d,xmm0
    528d:	movd   xmm2,r10d
    5292:	movd   xmm0,DWORD PTR [rbp-0xc28]
    529a:	movaps xmm1,xmm2
    529d:	ucomiss xmm0,xmm1
    52a0:	setb   r10b
    52a4:	setnp  r11b
    52a8:	and    r10b,r11b
    52ab:	movzx  r10d,r10b
    52af:	mov    QWORD PTR [rbp-0xc38],r10
    52b6:	cmp    r10,0x1
    52bd:	sete   r10b
    52c1:	movzx  r10d,r10b
    52c5:	mov    QWORD PTR [rbp-0xc50],r10
    52cc:	test   r10d,r10d
    52cf:	je     531d <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xac1>
    52d5:	lea    r10,[rbp-0xc48]
    52dc:	movabs r11,0x3b9aca00
    52e6:	mov    QWORD PTR [r10],r11
    52e9:	movabs r10,0x3b9aca00
    52f3:	movd   xmm0,r10d
    52f8:	movd   r10d,xmm0
    52fd:	pxor   xmm0,xmm0
    5301:	cvtsi2ss xmm0,r10
    5306:	movd   r10d,xmm0
    530b:	mov    rdi,r10
    530e:	mov    r10,rdi
    5311:	mov    QWORD PTR [rbp-0xc60],r10
    5318:	jmp    54e9 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xc8d>
    531d:	lea    r10,[rbp-0xc48]
    5324:	movabs r11,0x0
    532e:	mov    QWORD PTR [r10],r11
    5331:	movabs r10,0x0
    533b:	movd   xmm0,r10d
    5340:	movd   r10d,xmm0
    5345:	pxor   xmm0,xmm0
    5349:	cvtsi2ss xmm0,r10
    534e:	movd   r10d,xmm0
    5353:	mov    rdi,r10
    5356:	lea    r10,[rbp-0xc48]
    535d:	mov    r11,rdi
    5360:	mov    QWORD PTR [r10],r11
    5363:	lea    r10,[rbp-0xc48]
    536a:	mov    r11,QWORD PTR [rbp-0xbc0]
    5371:	mov    QWORD PTR [r10+0x8],r11
    5375:	movd   xmm1,DWORD PTR [rbp-0xbc0]
    537d:	movd   xmm0,edi
    5381:	subss  xmm0,xmm1
    5385:	movd   edi,xmm0
    5389:	mov    r10,rdi
    538c:	mov    QWORD PTR [rbp-0xc68],r10
    5393:	lea    r10,[rbp-0xc48]
    539a:	mov    r11,QWORD PTR [rbp-0xc28]
    53a1:	mov    QWORD PTR [r10],r11
    53a4:	lea    r10,[rbp-0xc48]
    53ab:	movd   xmm0,DWORD PTR [r10]
    53b0:	pxor   xmm1,xmm1
    53b4:	ucomiss xmm1,xmm0
    53b7:	ja     53c6 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xb6a>
    53bd:	sqrtss xmm0,xmm0
    53c1:	jmp    53cb <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xb6f>
    53c6:	call   53cb <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xb6f>
    53cb:	movd   edi,xmm0
    53cf:	lea    r10,[rbp-0xc48]
    53d6:	mov    r11,QWORD PTR [rbp-0xc68]
    53dd:	mov    QWORD PTR [r10],r11
    53e0:	lea    r10,[rbp-0xc48]
    53e7:	mov    r11,rdi
    53ea:	mov    QWORD PTR [r10+0x8],r11
    53ee:	movd   xmm1,edi
    53f2:	movd   xmm0,DWORD PTR [rbp-0xc68]
    53fa:	subss  xmm0,xmm1
    53fe:	movd   edi,xmm0
    5402:	movabs r10,0x1
    540c:	movd   xmm0,r10d
    5411:	movd   r10d,xmm0
    5416:	pxor   xmm0,xmm0
    541a:	cvtsi2ss xmm0,r10
    541f:	movd   r10d,xmm0
    5424:	movd   xmm2,r10d
    5429:	movaps xmm3,xmm2
    542c:	movabs r10,0x3e8
    5436:	movd   xmm0,r10d
    543b:	movd   r10d,xmm0
    5440:	pxor   xmm0,xmm0
    5444:	cvtsi2ss xmm0,r10
    5449:	movd   r10d,xmm0
    544e:	movd   xmm2,r10d
    5453:	movaps xmm4,xmm3
    5456:	divss  xmm4,xmm2
    545a:	movd   xmm0,edi
    545e:	movaps xmm1,xmm4
    5461:	ucomiss xmm0,xmm1
    5464:	setb   r10b
    5468:	setnp  r11b
    546c:	and    r10b,r11b
    546f:	movzx  r10d,r10b
    5473:	mov    QWORD PTR [rbp-0xc90],r10
    547a:	cmp    r10,0x1
    5481:	sete   r10b
    5485:	movzx  r10d,r10b
    5489:	mov    QWORD PTR [rbp-0xc98],r10
    5490:	test   r10d,r10d
    5493:	je     54d1 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xc75>
    5499:	movabs r10,0x3b9aca00
    54a3:	movd   xmm0,r10d
    54a8:	movd   r10d,xmm0
    54ad:	pxor   xmm0,xmm0
    54b1:	cvtsi2ss xmm0,r10
    54b6:	movd   r10d,xmm0
    54bb:	movd   xmm2,r10d
    54c0:	movd   r10d,xmm2
    54c5:	mov    QWORD PTR [rbp-0xca8],r10
    54cc:	jmp    54db <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xc7f>
    54d1:	mov    r10,rdi
    54d4:	mov    QWORD PTR [rbp-0xca8],r10
    54db:	mov    r10,QWORD PTR [rbp-0xca8]
    54e2:	mov    QWORD PTR [rbp-0xc60],r10
    54e9:	mov    esi,ebx
    54eb:	mov    r10,rsi
    54ee:	mov    QWORD PTR [rbp-0xcb0],r10
    54f5:	movd   xmm0,DWORD PTR [rbp-0xc60]
    54fd:	movd   xmm1,DWORD PTR [rbp-0x70]
    5502:	ucomiss xmm0,xmm1
    5505:	setb   r10b
    5509:	setnp  r11b
    550d:	and    r10b,r11b
    5510:	movzx  r10d,r10b
    5514:	mov    rsi,r10
    5517:	mov    r10,QWORD PTR [rbp-0x70]
    551b:	mov    QWORD PTR [rbp-0x80],r10
    551f:	mov    r10,QWORD PTR [rbp-0xc60]
    5526:	mov    QWORD PTR [rbp-0x70],r10
    552a:	mov    r10,QWORD PTR [rbp-0x78]
    552e:	mov    QWORD PTR [rbp-0x88],r10
    5535:	mov    r10,QWORD PTR [rbp-0xcb0]
    553c:	mov    QWORD PTR [rbp-0x78],r10
    5540:	jmp    48e2 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x86>
    5545:	mov    rdi,r12
    5548:	movabs rsi,0x4
    5552:	mov    esi,esi
    5554:	xor    eax,eax
    5556:	call   555b <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xcff>
    555b:	mov    QWORD PTR [rbp-0x980],rax
    5562:	movabs r10,0x0
    556c:	mov    r11,QWORD PTR [rbp-0x30]
    5570:	mov    QWORD PTR [r11],r10
    5573:	movabs r10,0x0
    557d:	mov    r11,QWORD PTR [rbp-0x30]
    5581:	mov    QWORD PTR [r11+0x8],r10
    5585:	movabs r10,0x0
    558f:	mov    r11,QWORD PTR [rbp-0x30]
    5593:	mov    QWORD PTR [r11+0x10],r10
    5597:	xor    eax,eax
    5599:	mov    r12,QWORD PTR [rbp-0x10]
    559d:	mov    rbx,QWORD PTR [rbp-0x8]
    55a1:	mov    r13,QWORD PTR [rbp-0x18]
    55a5:	mov    r14,QWORD PTR [rbp-0x20]
    55a9:	mov    r15,QWORD PTR [rbp-0x28]
    55ad:	mov    rsp,rbp
    55b0:	pop    rbp
    55b1:	ret    
    55b2:	mov    rdi,r12
    55b5:	movabs rsi,0x4
    55bf:	mov    esi,esi
    55c1:	xor    eax,eax
    55c3:	call   55c8 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xd6c>
    55c8:	mov    QWORD PTR [rbp-0x980],rax
    55cf:	movabs r10,0x0
    55d9:	mov    r11,QWORD PTR [rbp-0x30]
    55dd:	mov    QWORD PTR [r11],r10
    55e0:	movabs r10,0x0
    55ea:	mov    r11,QWORD PTR [rbp-0x30]
    55ee:	mov    QWORD PTR [r11+0x8],r10
    55f2:	movabs r10,0x0
    55fc:	mov    r11,QWORD PTR [rbp-0x30]
    5600:	mov    QWORD PTR [r11+0x10],r10
    5604:	xor    eax,eax
    5606:	mov    r12,QWORD PTR [rbp-0x10]
    560a:	mov    rbx,QWORD PTR [rbp-0x8]
    560e:	mov    r13,QWORD PTR [rbp-0x18]
    5612:	mov    r14,QWORD PTR [rbp-0x20]
    5616:	mov    r15,QWORD PTR [rbp-0x28]
    561a:	mov    rsp,rbp
    561d:	pop    rbp
    561e:	ret    
