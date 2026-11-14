
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/native45-02/variation-ray-active-64-2440/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000409b58 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>:
  409b58:	push   rbp
  409b59:	mov    rbp,rsp
  409b5c:	sub    rsp,0xd30
  409b63:	mov    QWORD PTR [rbp-0x10],r12
  409b67:	mov    QWORD PTR [rbp-0x8],rbx
  409b6b:	mov    QWORD PTR [rbp-0x18],r13
  409b6f:	mov    QWORD PTR [rbp-0x20],r14
  409b73:	mov    QWORD PTR [rbp-0x28],r15
  409b77:	mov    rax,rdi
  409b7a:	mov    r12,rax
  409b7d:	mov    rax,rsi
  409b80:	mov    QWORD PTR [rbp-0x30],rax
  409b84:	mov    rax,rdx
  409b87:	mov    rbx,rax
  409b8a:	mov    rax,rcx
  409b8d:	mov    r15,rax
  409b90:	mov    rax,r8
  409b93:	mov    QWORD PTR [rbp-0x48],rax
  409b97:	mov    rax,r9
  409b9a:	mov    QWORD PTR [rbp-0x50],rax
  409b9e:	mov    rax,QWORD PTR [rbp+0x10]
  409ba2:	mov    QWORD PTR [rbp-0x58],rax
  409ba6:	mov    rax,QWORD PTR [rbp+0x18]
  409baa:	mov    QWORD PTR [rbp-0x60],rax
  409bae:	mov    rax,QWORD PTR [rbp+0x20]
  409bb2:	mov    QWORD PTR [rbp-0x68],rax
  409bb6:	mov    rax,QWORD PTR [rbp+0x28]
  409bba:	mov    r13,rax
  409bbd:	mov    rax,QWORD PTR [rbp+0x30]
  409bc1:	mov    QWORD PTR [rbp-0x78],rax
  409bc5:	mov    rax,QWORD PTR [rbp+0x38]
  409bc9:	mov    r14,rax
  409bcc:	mov    rax,QWORD PTR [rbp+0x40]
  409bd0:	mov    QWORD PTR [rbp-0x88],rax
  409bd7:	mov    rax,QWORD PTR [rbp+0x48]
  409bdb:	mov    rsi,rax
  409bde:	mov    rdi,rbx
  409be1:	cmp    rdi,0x0
  409be8:	sete   dil
  409bec:	movzx  edi,dil
  409bf0:	mov    r10,rdi
  409bf3:	test   r10d,r10d
  409bf6:	je     409dc5 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x26d>
  409bfc:	mov    r8,rsi
  409bff:	cmp    r8,0x1
  409c06:	sete   r8b
  409c0a:	movzx  r8d,r8b
  409c0e:	mov    rdi,rsi
  409c11:	shr    rdi,0x28
  409c15:	and    rdi,0x7fffff
  409c1c:	movabs rdx,0x2
  409c26:	or     rdx,0x10000
  409c2d:	cmp    rdi,rdx
  409c30:	sete   dil
  409c34:	movzx  edi,dil
  409c38:	or     edi,r8d
  409c3b:	xor    edi,0x1
  409c41:	mov    r10,rdi
  409c44:	test   r10d,r10d
  409c47:	je     409cb0 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x158>
  409c4d:	mov    r10,QWORD PTR [rbp-0x88]
  409c54:	mov    r10d,r10d
  409c57:	mov    QWORD PTR [rbp-0x970],r10
  409c5e:	cmp    r10,0x9
  409c65:	sete   r10b
  409c69:	movzx  r10d,r10b
  409c6d:	mov    QWORD PTR [rbp-0x978],r10
  409c74:	mov    r11,QWORD PTR [rbp-0x30]
  409c78:	mov    QWORD PTR [r11],r10
  409c7b:	mov    r10,r14
  409c7e:	mov    r11,QWORD PTR [rbp-0x30]
  409c82:	mov    QWORD PTR [r11+0x8],r10
  409c86:	mov    r10,QWORD PTR [rbp-0x88]
  409c8d:	mov    r11,QWORD PTR [rbp-0x30]
  409c91:	mov    QWORD PTR [r11+0x10],r10
  409c95:	xor    eax,eax
  409c97:	mov    r12,QWORD PTR [rbp-0x10]
  409c9b:	mov    rbx,QWORD PTR [rbp-0x8]
  409c9f:	mov    r13,QWORD PTR [rbp-0x18]
  409ca3:	mov    r14,QWORD PTR [rbp-0x20]
  409ca7:	mov    r15,QWORD PTR [rbp-0x28]
  409cab:	mov    rsp,rbp
  409cae:	pop    rbp
  409caf:	ret    
  409cb0:	mov    r8,rsi
  409cb3:	cmp    r8,0x1
  409cba:	sete   r8b
  409cbe:	movzx  r8d,r8b
  409cc2:	mov    rdi,rsi
  409cc5:	shr    rdi,0x28
  409cc9:	and    rdi,0x7fffff
  409cd0:	movabs rdx,0x2
  409cda:	or     rdx,0x10000
  409ce1:	cmp    rdi,rdx
  409ce4:	sete   dil
  409ce8:	movzx  edi,dil
  409cec:	or     edi,r8d
  409cef:	mov    r10,rdi
  409cf2:	test   r10d,r10d
  409cf5:	je     409d58 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x200>
  409cfb:	mov    r10,QWORD PTR [rbp-0x78]
  409cff:	mov    r10d,r10d
  409d02:	mov    QWORD PTR [rbp-0x970],r10
  409d09:	cmp    r10,0x9
  409d10:	sete   r10b
  409d14:	movzx  r10d,r10b
  409d18:	mov    QWORD PTR [rbp-0x978],r10
  409d1f:	mov    r11,QWORD PTR [rbp-0x30]
  409d23:	mov    QWORD PTR [r11],r10
  409d26:	mov    r10,r13
  409d29:	mov    r11,QWORD PTR [rbp-0x30]
  409d2d:	mov    QWORD PTR [r11+0x8],r10
  409d31:	mov    r10,QWORD PTR [rbp-0x78]
  409d35:	mov    r11,QWORD PTR [rbp-0x30]
  409d39:	mov    QWORD PTR [r11+0x10],r10
  409d3d:	xor    eax,eax
  409d3f:	mov    r12,QWORD PTR [rbp-0x10]
  409d43:	mov    rbx,QWORD PTR [rbp-0x8]
  409d47:	mov    r13,QWORD PTR [rbp-0x18]
  409d4b:	mov    r14,QWORD PTR [rbp-0x20]
  409d4f:	mov    r15,QWORD PTR [rbp-0x28]
  409d53:	mov    rsp,rbp
  409d56:	pop    rbp
  409d57:	ret    
  409d58:	mov    rdi,r12
  409d5b:	movabs rsi,0x4
  409d65:	mov    esi,esi
  409d67:	xor    eax,eax
  409d69:	call   420a90 <p111_rt_fail>
  409d6e:	mov    QWORD PTR [rbp-0x980],rax
  409d75:	movabs r10,0x0
  409d7f:	mov    r11,QWORD PTR [rbp-0x30]
  409d83:	mov    QWORD PTR [r11],r10
  409d86:	movabs r10,0x0
  409d90:	mov    r11,QWORD PTR [rbp-0x30]
  409d94:	mov    QWORD PTR [r11+0x8],r10
  409d98:	movabs r10,0x0
  409da2:	mov    r11,QWORD PTR [rbp-0x30]
  409da6:	mov    QWORD PTR [r11+0x10],r10
  409daa:	xor    eax,eax
  409dac:	mov    r12,QWORD PTR [rbp-0x10]
  409db0:	mov    rbx,QWORD PTR [rbp-0x8]
  409db4:	mov    r13,QWORD PTR [rbp-0x18]
  409db8:	mov    r14,QWORD PTR [rbp-0x20]
  409dbc:	mov    r15,QWORD PTR [rbp-0x28]
  409dc0:	mov    rsp,rbp
  409dc3:	pop    rbp
  409dc4:	ret    
  409dc5:	mov    rdi,rbx
  409dc8:	cmp    rdi,0x0
  409dcf:	setne  dil
  409dd3:	movzx  edi,dil
  409dd7:	mov    r10,rdi
  409dda:	test   r10d,r10d
  409ddd:	je     40a8d4 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xd7c>
  409de3:	sub    rbx,0x1
  409dea:	mov    r8,rsi
  409ded:	cmp    r8,0x1
  409df4:	sete   r8b
  409df8:	movzx  r8d,r8b
  409dfc:	mov    rdi,rsi
  409dff:	shr    rdi,0x28
  409e03:	and    rdi,0x7fffff
  409e0a:	movabs rdx,0x2
  409e14:	or     rdx,0x10000
  409e1b:	cmp    rdi,rdx
  409e1e:	sete   dil
  409e22:	movzx  edi,dil
  409e26:	or     edi,r8d
  409e29:	xor    edi,0x1
  409e2f:	mov    r10,rdi
  409e32:	test   r10d,r10d
  409e35:	je     40a26c <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x714>
  409e3b:	mov    rdi,r12
  409e3e:	mov    rsi,rbx
  409e41:	xor    eax,eax
  409e43:	call   408ea5 <p113d_FID_36_100_105_114_101_99_116_46_115_120_>
  409e48:	mov    QWORD PTR [rbp-0x990],rax
  409e4f:	mov    rdi,r12
  409e52:	mov    rsi,rbx
  409e55:	xor    eax,eax
  409e57:	call   408d77 <p113d_FID_36_100_105_114_101_99_116_46_115_121_>
  409e5c:	mov    QWORD PTR [rbp-0x998],rax
  409e63:	mov    rdi,r12
  409e66:	mov    rsi,rbx
  409e69:	xor    eax,eax
  409e6b:	call   408c49 <p113d_FID_36_100_105_114_101_99_116_46_115_122_>
  409e70:	mov    QWORD PTR [rbp-0x9a0],rax
  409e77:	mov    rdi,r12
  409e7a:	mov    rsi,rbx
  409e7d:	xor    eax,eax
  409e7f:	call   408b1b <p113d_FID_36_100_105_114_101_99_116_46_115_114_>
  409e84:	mov    r9,rax
  409e87:	movd   xmm1,DWORD PTR [rbp-0x990]
  409e8f:	movd   xmm2,r15d
  409e94:	subss  xmm2,xmm1
  409e98:	movaps xmm3,xmm2
  409e9b:	movd   xmm1,DWORD PTR [rbp-0x998]
  409ea3:	movd   xmm2,DWORD PTR [rbp-0x48]
  409ea8:	subss  xmm2,xmm1
  409eac:	movaps xmm4,xmm2
  409eaf:	movd   xmm1,DWORD PTR [rbp-0x9a0]
  409eb7:	movd   xmm2,DWORD PTR [rbp-0x50]
  409ebc:	subss  xmm2,xmm1
  409ec0:	movaps xmm5,xmm2
  409ec3:	movd   xmm1,DWORD PTR [rbp-0x58]
  409ec8:	movaps xmm2,xmm3
  409ecb:	mulss  xmm2,xmm1
  409ecf:	movaps xmm6,xmm2
  409ed2:	movd   xmm1,DWORD PTR [rbp-0x60]
  409ed7:	movaps xmm2,xmm4
  409eda:	mulss  xmm2,xmm1
  409ede:	movaps xmm7,xmm6
  409ee1:	addss  xmm7,xmm2
  409ee5:	movaps xmm2,xmm7
  409ee8:	movd   xmm1,DWORD PTR [rbp-0x68]
  409eed:	movaps xmm6,xmm5
  409ef0:	mulss  xmm6,xmm1
  409ef4:	movaps xmm7,xmm2
  409ef7:	addss  xmm7,xmm6
  409efb:	movd   r13d,xmm7
  409f00:	movaps xmm2,xmm7
  409f03:	mulss  xmm2,xmm7
  409f07:	movaps xmm6,xmm2
  409f0a:	movaps xmm2,xmm3
  409f0d:	mulss  xmm2,xmm3
  409f11:	movaps xmm3,xmm2
  409f14:	movaps xmm2,xmm4
  409f17:	mulss  xmm2,xmm4
  409f1b:	movaps xmm4,xmm3
  409f1e:	addss  xmm4,xmm2
  409f22:	movaps xmm2,xmm4
  409f25:	movaps xmm3,xmm5
  409f28:	mulss  xmm3,xmm5
  409f2c:	movaps xmm4,xmm2
  409f2f:	addss  xmm4,xmm3
  409f33:	movaps xmm2,xmm4
  409f36:	movd   xmm1,r9d
  409f3b:	movd   xmm3,r9d
  409f40:	mulss  xmm3,xmm1
  409f44:	movaps xmm4,xmm2
  409f47:	subss  xmm4,xmm3
  409f4b:	movaps xmm2,xmm6
  409f4e:	subss  xmm2,xmm4
  409f52:	movd   esi,xmm2
  409f56:	movabs r10,0x0
  409f60:	movd   xmm0,r10d
  409f65:	movd   r10d,xmm0
  409f6a:	pxor   xmm0,xmm0
  409f6e:	cvtsi2ss xmm0,r10
  409f73:	movd   r10d,xmm0
  409f78:	movd   xmm2,r10d
  409f7d:	movd   xmm0,esi
  409f81:	movaps xmm1,xmm2
  409f84:	ucomiss xmm0,xmm1
  409f87:	setb   r10b
  409f8b:	setnp  r11b
  409f8f:	and    r10b,r11b
  409f92:	movzx  r10d,r10b
  409f96:	mov    QWORD PTR [rbp-0xa98],r10
  409f9d:	cmp    r10,0x1
  409fa4:	sete   r10b
  409fa8:	movzx  r10d,r10b
  409fac:	mov    QWORD PTR [rbp-0xab0],r10
  409fb3:	test   r10d,r10d
  409fb6:	je     40a004 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x4ac>
  409fbc:	lea    r10,[rbp-0xaa8]
  409fc3:	movabs r11,0x3b9aca00
  409fcd:	mov    QWORD PTR [r10],r11
  409fd0:	movabs r10,0x3b9aca00
  409fda:	movd   xmm0,r10d
  409fdf:	movd   r10d,xmm0
  409fe4:	pxor   xmm0,xmm0
  409fe8:	cvtsi2ss xmm0,r10
  409fed:	movd   r10d,xmm0
  409ff2:	mov    rdi,r10
  409ff5:	mov    r10,rdi
  409ff8:	mov    QWORD PTR [rbp-0xac0],r10
  409fff:	jmp    40a1d8 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x680>
  40a004:	lea    r10,[rbp-0xaa8]
  40a00b:	movabs r11,0x0
  40a015:	mov    QWORD PTR [r10],r11
  40a018:	movabs r10,0x0
  40a022:	movd   xmm0,r10d
  40a027:	movd   r10d,xmm0
  40a02c:	pxor   xmm0,xmm0
  40a030:	cvtsi2ss xmm0,r10
  40a035:	movd   r10d,xmm0
  40a03a:	mov    rdi,r10
  40a03d:	lea    r10,[rbp-0xaa8]
  40a044:	mov    r11,rdi
  40a047:	mov    QWORD PTR [r10],r11
  40a04a:	lea    r10,[rbp-0xaa8]
  40a051:	mov    r11,r13
  40a054:	mov    QWORD PTR [r10+0x8],r11
  40a058:	movd   xmm1,r13d
  40a05d:	movd   xmm0,edi
  40a061:	subss  xmm0,xmm1
  40a065:	movd   edi,xmm0
  40a069:	mov    r10,rdi
  40a06c:	mov    QWORD PTR [rbp-0xac8],r10
  40a073:	lea    r10,[rbp-0xaa8]
  40a07a:	mov    r11,rsi
  40a07d:	mov    QWORD PTR [r10],r11
  40a080:	mov    rdi,r12
  40a083:	movabs rsi,0x24
  40a08d:	mov    esi,esi
  40a08f:	lea    rdx,[rbp-0xaa8]
  40a096:	movabs rcx,0x1
  40a0a0:	mov    ecx,ecx
  40a0a2:	xor    eax,eax
  40a0a4:	call   420ab0 <p111_rt_op>
  40a0a9:	mov    rdi,rax
  40a0ac:	lea    r10,[rbp-0xaa8]
  40a0b3:	mov    r11,QWORD PTR [rbp-0xac8]
  40a0ba:	mov    QWORD PTR [r10],r11
  40a0bd:	lea    r10,[rbp-0xaa8]
  40a0c4:	mov    r11,rdi
  40a0c7:	mov    QWORD PTR [r10+0x8],r11
  40a0cb:	movd   xmm1,edi
  40a0cf:	movd   xmm0,DWORD PTR [rbp-0xac8]
  40a0d7:	subss  xmm0,xmm1
  40a0db:	movd   edi,xmm0
  40a0df:	mov    r10,rdi
  40a0e2:	mov    QWORD PTR [rbp-0xad0],r10
  40a0e9:	movabs r10,0x1
  40a0f3:	movd   xmm0,r10d
  40a0f8:	movd   r10d,xmm0
  40a0fd:	pxor   xmm0,xmm0
  40a101:	cvtsi2ss xmm0,r10
  40a106:	movd   r10d,xmm0
  40a10b:	movd   xmm2,r10d
  40a110:	movaps xmm3,xmm2
  40a113:	movabs r10,0x3e8
  40a11d:	movd   xmm0,r10d
  40a122:	movd   r10d,xmm0
  40a127:	pxor   xmm0,xmm0
  40a12b:	cvtsi2ss xmm0,r10
  40a130:	movd   r10d,xmm0
  40a135:	movd   xmm2,r10d
  40a13a:	movaps xmm4,xmm3
  40a13d:	divss  xmm4,xmm2
  40a141:	movd   xmm0,DWORD PTR [rbp-0xad0]
  40a149:	movaps xmm1,xmm4
  40a14c:	ucomiss xmm0,xmm1
  40a14f:	setb   r10b
  40a153:	setnp  r11b
  40a157:	and    r10b,r11b
  40a15a:	movzx  r10d,r10b
  40a15e:	mov    QWORD PTR [rbp-0xaf8],r10
  40a165:	cmp    r10,0x1
  40a16c:	sete   r10b
  40a170:	movzx  r10d,r10b
  40a174:	mov    QWORD PTR [rbp-0xb00],r10
  40a17b:	test   r10d,r10d
  40a17e:	je     40a1bc <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x664>
  40a184:	movabs r10,0x3b9aca00
  40a18e:	movd   xmm0,r10d
  40a193:	movd   r10d,xmm0
  40a198:	pxor   xmm0,xmm0
  40a19c:	cvtsi2ss xmm0,r10
  40a1a1:	movd   r10d,xmm0
  40a1a6:	movd   xmm2,r10d
  40a1ab:	movd   r10d,xmm2
  40a1b0:	mov    QWORD PTR [rbp-0xb10],r10
  40a1b7:	jmp    40a1ca <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x672>
  40a1bc:	mov    r10,QWORD PTR [rbp-0xad0]
  40a1c3:	mov    QWORD PTR [rbp-0xb10],r10
  40a1ca:	mov    r10,QWORD PTR [rbp-0xb10]
  40a1d1:	mov    QWORD PTR [rbp-0xac0],r10
  40a1d8:	mov    r13,QWORD PTR [rbp-0xac0]
  40a1df:	lea    r10,[rbp-0x890]
  40a1e6:	mov    r11,rbx
  40a1e9:	mov    QWORD PTR [r10],r11
  40a1ec:	mov    rdi,r12
  40a1ef:	movabs rsi,0x19
  40a1f9:	mov    esi,esi
  40a1fb:	lea    rdx,[rbp-0x890]
  40a202:	movabs rcx,0x1
  40a20c:	mov    ecx,ecx
  40a20e:	xor    eax,eax
  40a210:	call   420ab0 <p111_rt_op>
  40a215:	mov    rsi,rax
  40a218:	mov    r10,rsi
  40a21b:	mov    QWORD PTR [rbp-0xb28],r10
  40a222:	lea    r10,[rbp-0x890]
  40a229:	mov    r11,r13
  40a22c:	mov    QWORD PTR [r10],r11
  40a22f:	lea    r10,[rbp-0x890]
  40a236:	mov    r11,r14
  40a239:	mov    QWORD PTR [r10+0x8],r11
  40a23d:	movd   xmm0,r13d
  40a242:	movd   xmm1,r14d
  40a247:	ucomiss xmm0,xmm1
  40a24a:	setb   r10b
  40a24e:	setnp  r11b
  40a252:	and    r10b,r11b
  40a255:	movzx  r10d,r10b
  40a259:	mov    rsi,r10
  40a25c:	mov    r10,QWORD PTR [rbp-0xb28]
  40a263:	mov    QWORD PTR [rbp-0x78],r10
  40a267:	jmp    409bde <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x86>
  40a26c:	mov    r8,rsi
  40a26f:	cmp    r8,0x1
  40a276:	sete   r8b
  40a27a:	movzx  r8d,r8b
  40a27e:	mov    rdi,rsi
  40a281:	shr    rdi,0x28
  40a285:	and    rdi,0x7fffff
  40a28c:	movabs rdx,0x2
  40a296:	or     rdx,0x10000
  40a29d:	cmp    rdi,rdx
  40a2a0:	sete   dil
  40a2a4:	movzx  edi,dil
  40a2a8:	or     edi,r8d
  40a2ab:	mov    r10,rdi
  40a2ae:	test   r10d,r10d
  40a2b1:	je     40a867 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xd0f>
  40a2b7:	mov    rdi,r12
  40a2ba:	mov    rsi,rbx
  40a2bd:	xor    eax,eax
  40a2bf:	call   408ea5 <p113d_FID_36_100_105_114_101_99_116_46_115_120_>
  40a2c4:	mov    QWORD PTR [rbp-0xb30],rax
  40a2cb:	mov    rdi,r12
  40a2ce:	mov    rsi,rbx
  40a2d1:	xor    eax,eax
  40a2d3:	call   408d77 <p113d_FID_36_100_105_114_101_99_116_46_115_121_>
  40a2d8:	mov    QWORD PTR [rbp-0xb38],rax
  40a2df:	mov    rdi,r12
  40a2e2:	mov    rsi,rbx
  40a2e5:	xor    eax,eax
  40a2e7:	call   408c49 <p113d_FID_36_100_105_114_101_99_116_46_115_122_>
  40a2ec:	mov    QWORD PTR [rbp-0xb40],rax
  40a2f3:	mov    rdi,r12
  40a2f6:	mov    rsi,rbx
  40a2f9:	xor    eax,eax
  40a2fb:	call   408b1b <p113d_FID_36_100_105_114_101_99_116_46_115_114_>
  40a300:	mov    QWORD PTR [rbp-0xb48],rax
  40a307:	movd   xmm1,DWORD PTR [rbp-0xb30]
  40a30f:	movd   xmm2,r15d
  40a314:	subss  xmm2,xmm1
  40a318:	movaps xmm3,xmm2
  40a31b:	movd   xmm1,DWORD PTR [rbp-0xb38]
  40a323:	movd   xmm2,DWORD PTR [rbp-0x48]
  40a328:	subss  xmm2,xmm1
  40a32c:	movaps xmm4,xmm2
  40a32f:	movd   xmm1,DWORD PTR [rbp-0xb40]
  40a337:	movd   xmm2,DWORD PTR [rbp-0x50]
  40a33c:	subss  xmm2,xmm1
  40a340:	movaps xmm5,xmm2
  40a343:	movd   xmm1,DWORD PTR [rbp-0x58]
  40a348:	movaps xmm2,xmm3
  40a34b:	mulss  xmm2,xmm1
  40a34f:	movaps xmm6,xmm2
  40a352:	movd   xmm1,DWORD PTR [rbp-0x60]
  40a357:	movaps xmm2,xmm4
  40a35a:	mulss  xmm2,xmm1
  40a35e:	movaps xmm7,xmm6
  40a361:	addss  xmm7,xmm2
  40a365:	movaps xmm2,xmm7
  40a368:	movd   xmm1,DWORD PTR [rbp-0x68]
  40a36d:	movaps xmm6,xmm5
  40a370:	mulss  xmm6,xmm1
  40a374:	movaps xmm7,xmm2
  40a377:	addss  xmm7,xmm6
  40a37b:	movd   r10d,xmm7
  40a380:	mov    QWORD PTR [rbp-0xbb8],r10
  40a387:	movaps xmm2,xmm7
  40a38a:	mulss  xmm2,xmm7
  40a38e:	movaps xmm6,xmm2
  40a391:	movaps xmm2,xmm3
  40a394:	mulss  xmm2,xmm3
  40a398:	movaps xmm3,xmm2
  40a39b:	movaps xmm2,xmm4
  40a39e:	mulss  xmm2,xmm4
  40a3a2:	movaps xmm4,xmm3
  40a3a5:	addss  xmm4,xmm2
  40a3a9:	movaps xmm2,xmm4
  40a3ac:	movaps xmm3,xmm5
  40a3af:	mulss  xmm3,xmm5
  40a3b3:	movaps xmm4,xmm2
  40a3b6:	addss  xmm4,xmm3
  40a3ba:	movaps xmm2,xmm4
  40a3bd:	movd   xmm1,DWORD PTR [rbp-0xb48]
  40a3c5:	movd   xmm3,DWORD PTR [rbp-0xb48]
  40a3cd:	mulss  xmm3,xmm1
  40a3d1:	movaps xmm4,xmm2
  40a3d4:	subss  xmm4,xmm3
  40a3d8:	movaps xmm2,xmm6
  40a3db:	subss  xmm2,xmm4
  40a3df:	movd   r10d,xmm2
  40a3e4:	mov    QWORD PTR [rbp-0xc28],r10
  40a3eb:	movabs r10,0x0
  40a3f5:	movd   xmm0,r10d
  40a3fa:	movd   r10d,xmm0
  40a3ff:	pxor   xmm0,xmm0
  40a403:	cvtsi2ss xmm0,r10
  40a408:	movd   r10d,xmm0
  40a40d:	movd   xmm2,r10d
  40a412:	movd   xmm0,DWORD PTR [rbp-0xc28]
  40a41a:	movaps xmm1,xmm2
  40a41d:	ucomiss xmm0,xmm1
  40a420:	setb   r10b
  40a424:	setnp  r11b
  40a428:	and    r10b,r11b
  40a42b:	movzx  r10d,r10b
  40a42f:	mov    QWORD PTR [rbp-0xc38],r10
  40a436:	cmp    r10,0x1
  40a43d:	sete   r10b
  40a441:	movzx  r10d,r10b
  40a445:	mov    QWORD PTR [rbp-0xc50],r10
  40a44c:	test   r10d,r10d
  40a44f:	je     40a49d <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x945>
  40a455:	lea    r10,[rbp-0xc48]
  40a45c:	movabs r11,0x3b9aca00
  40a466:	mov    QWORD PTR [r10],r11
  40a469:	movabs r10,0x3b9aca00
  40a473:	movd   xmm0,r10d
  40a478:	movd   r10d,xmm0
  40a47d:	pxor   xmm0,xmm0
  40a481:	cvtsi2ss xmm0,r10
  40a486:	movd   r10d,xmm0
  40a48b:	mov    rdi,r10
  40a48e:	mov    r10,rdi
  40a491:	mov    QWORD PTR [rbp-0xc60],r10
  40a498:	jmp    40a67c <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xb24>
  40a49d:	lea    r10,[rbp-0xc48]
  40a4a4:	movabs r11,0x0
  40a4ae:	mov    QWORD PTR [r10],r11
  40a4b1:	movabs r10,0x0
  40a4bb:	movd   xmm0,r10d
  40a4c0:	movd   r10d,xmm0
  40a4c5:	pxor   xmm0,xmm0
  40a4c9:	cvtsi2ss xmm0,r10
  40a4ce:	movd   r10d,xmm0
  40a4d3:	mov    rdi,r10
  40a4d6:	lea    r10,[rbp-0xc48]
  40a4dd:	mov    r11,rdi
  40a4e0:	mov    QWORD PTR [r10],r11
  40a4e3:	lea    r10,[rbp-0xc48]
  40a4ea:	mov    r11,QWORD PTR [rbp-0xbb8]
  40a4f1:	mov    QWORD PTR [r10+0x8],r11
  40a4f5:	movd   xmm1,DWORD PTR [rbp-0xbb8]
  40a4fd:	movd   xmm0,edi
  40a501:	subss  xmm0,xmm1
  40a505:	movd   edi,xmm0
  40a509:	mov    r10,rdi
  40a50c:	mov    QWORD PTR [rbp-0xc68],r10
  40a513:	lea    r10,[rbp-0xc48]
  40a51a:	mov    r11,QWORD PTR [rbp-0xc28]
  40a521:	mov    QWORD PTR [r10],r11
  40a524:	mov    rdi,r12
  40a527:	movabs rsi,0x24
  40a531:	mov    esi,esi
  40a533:	lea    rdx,[rbp-0xc48]
  40a53a:	movabs rcx,0x1
  40a544:	mov    ecx,ecx
  40a546:	xor    eax,eax
  40a548:	call   420ab0 <p111_rt_op>
  40a54d:	mov    rdi,rax
  40a550:	lea    r10,[rbp-0xc48]
  40a557:	mov    r11,QWORD PTR [rbp-0xc68]
  40a55e:	mov    QWORD PTR [r10],r11
  40a561:	lea    r10,[rbp-0xc48]
  40a568:	mov    r11,rdi
  40a56b:	mov    QWORD PTR [r10+0x8],r11
  40a56f:	movd   xmm1,edi
  40a573:	movd   xmm0,DWORD PTR [rbp-0xc68]
  40a57b:	subss  xmm0,xmm1
  40a57f:	movd   edi,xmm0
  40a583:	mov    r10,rdi
  40a586:	mov    QWORD PTR [rbp-0xc70],r10
  40a58d:	movabs r10,0x1
  40a597:	movd   xmm0,r10d
  40a59c:	movd   r10d,xmm0
  40a5a1:	pxor   xmm0,xmm0
  40a5a5:	cvtsi2ss xmm0,r10
  40a5aa:	movd   r10d,xmm0
  40a5af:	movd   xmm2,r10d
  40a5b4:	movaps xmm3,xmm2
  40a5b7:	movabs r10,0x3e8
  40a5c1:	movd   xmm0,r10d
  40a5c6:	movd   r10d,xmm0
  40a5cb:	pxor   xmm0,xmm0
  40a5cf:	cvtsi2ss xmm0,r10
  40a5d4:	movd   r10d,xmm0
  40a5d9:	movd   xmm2,r10d
  40a5de:	movaps xmm4,xmm3
  40a5e1:	divss  xmm4,xmm2
  40a5e5:	movd   xmm0,DWORD PTR [rbp-0xc70]
  40a5ed:	movaps xmm1,xmm4
  40a5f0:	ucomiss xmm0,xmm1
  40a5f3:	setb   r10b
  40a5f7:	setnp  r11b
  40a5fb:	and    r10b,r11b
  40a5fe:	movzx  r10d,r10b
  40a602:	mov    QWORD PTR [rbp-0xc98],r10
  40a609:	cmp    r10,0x1
  40a610:	sete   r10b
  40a614:	movzx  r10d,r10b
  40a618:	mov    QWORD PTR [rbp-0xca0],r10
  40a61f:	test   r10d,r10d
  40a622:	je     40a660 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xb08>
  40a628:	movabs r10,0x3b9aca00
  40a632:	movd   xmm0,r10d
  40a637:	movd   r10d,xmm0
  40a63c:	pxor   xmm0,xmm0
  40a640:	cvtsi2ss xmm0,r10
  40a645:	movd   r10d,xmm0
  40a64a:	movd   xmm2,r10d
  40a64f:	movd   r10d,xmm2
  40a654:	mov    QWORD PTR [rbp-0xcb0],r10
  40a65b:	jmp    40a66e <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0xb16>
  40a660:	mov    r10,QWORD PTR [rbp-0xc70]
  40a667:	mov    QWORD PTR [rbp-0xcb0],r10
  40a66e:	mov    r10,QWORD PTR [rbp-0xcb0]
  40a675:	mov    QWORD PTR [rbp-0xc60],r10
  40a67c:	mov    r14,QWORD PTR [rbp-0xc60]
  40a683:	lea    r10,[rbp-0x890]
  40a68a:	mov    r11,rbx
  40a68d:	mov    QWORD PTR [r10],r11
  40a690:	mov    rdi,r12
  40a693:	movabs rsi,0x19
  40a69d:	mov    esi,esi
  40a69f:	lea    rdx,[rbp-0x890]
  40a6a6:	movabs rcx,0x1
  40a6b0:	mov    ecx,ecx
  40a6b2:	xor    eax,eax
  40a6b4:	call   420ab0 <p111_rt_op>
  40a6b9:	mov    rsi,rax
  40a6bc:	mov    r10,rsi
  40a6bf:	mov    QWORD PTR [rbp-0xcc0],r10
  40a6c6:	lea    r10,[rbp-0x890]
  40a6cd:	mov    r11,r14
  40a6d0:	mov    QWORD PTR [r10],r11
  40a6d3:	lea    r10,[rbp-0x890]
  40a6da:	mov    r11,r13
  40a6dd:	mov    QWORD PTR [r10+0x8],r11
  40a6e1:	movd   xmm0,r14d
  40a6e6:	movd   xmm1,r13d
  40a6eb:	ucomiss xmm0,xmm1
  40a6ee:	setb   r10b
  40a6f2:	setnp  r11b
  40a6f6:	and    r10b,r11b
  40a6f9:	movzx  r10d,r10b
  40a6fd:	mov    rsi,r10
  40a700:	mov    r10,rbx
  40a703:	lea    r11,[rbp-0x940]
  40a70a:	mov    QWORD PTR [r11],r10
  40a70d:	mov    r10,r15
  40a710:	lea    r11,[rbp-0x940]
  40a717:	mov    QWORD PTR [r11+0x8],r10
  40a71b:	mov    r10,QWORD PTR [rbp-0x48]
  40a71f:	lea    r11,[rbp-0x940]
  40a726:	mov    QWORD PTR [r11+0x10],r10
  40a72a:	mov    r10,QWORD PTR [rbp-0x50]
  40a72e:	lea    r11,[rbp-0x940]
  40a735:	mov    QWORD PTR [r11+0x18],r10
  40a739:	mov    r10,QWORD PTR [rbp-0x58]
  40a73d:	lea    r11,[rbp-0x940]
  40a744:	mov    QWORD PTR [r11+0x20],r10
  40a748:	mov    r10,QWORD PTR [rbp-0x60]
  40a74c:	lea    r11,[rbp-0x940]
  40a753:	mov    QWORD PTR [r11+0x28],r10
  40a757:	mov    r10,QWORD PTR [rbp-0x68]
  40a75b:	lea    r11,[rbp-0x940]
  40a762:	mov    QWORD PTR [r11+0x30],r10
  40a766:	mov    r10,r14
  40a769:	lea    r11,[rbp-0x940]
  40a770:	mov    QWORD PTR [r11+0x38],r10
  40a774:	mov    r10,QWORD PTR [rbp-0xcc0]
  40a77b:	lea    r11,[rbp-0x940]
  40a782:	mov    QWORD PTR [r11+0x40],r10
  40a786:	mov    r10,r13
  40a789:	lea    r11,[rbp-0x940]
  40a790:	mov    QWORD PTR [r11+0x48],r10
  40a794:	mov    r10,QWORD PTR [rbp-0x78]
  40a798:	lea    r11,[rbp-0x940]
  40a79f:	mov    QWORD PTR [r11+0x50],r10
  40a7a3:	mov    r10,rsi
  40a7a6:	lea    r11,[rbp-0x940]
  40a7ad:	mov    QWORD PTR [r11+0x58],r10
  40a7b1:	lea    r11,[rbp-0x940]
  40a7b8:	mov    rax,QWORD PTR [r11]
  40a7bb:	mov    rbx,rax
  40a7be:	lea    r11,[rbp-0x940]
  40a7c5:	mov    rax,QWORD PTR [r11+0x8]
  40a7c9:	mov    r15,rax
  40a7cc:	lea    r11,[rbp-0x940]
  40a7d3:	mov    rax,QWORD PTR [r11+0x10]
  40a7d7:	mov    QWORD PTR [rbp-0x48],rax
  40a7db:	lea    r11,[rbp-0x940]
  40a7e2:	mov    rax,QWORD PTR [r11+0x18]
  40a7e6:	mov    QWORD PTR [rbp-0x50],rax
  40a7ea:	lea    r11,[rbp-0x940]
  40a7f1:	mov    rax,QWORD PTR [r11+0x20]
  40a7f5:	mov    QWORD PTR [rbp-0x58],rax
  40a7f9:	lea    r11,[rbp-0x940]
  40a800:	mov    rax,QWORD PTR [r11+0x28]
  40a804:	mov    QWORD PTR [rbp-0x60],rax
  40a808:	lea    r11,[rbp-0x940]
  40a80f:	mov    rax,QWORD PTR [r11+0x30]
  40a813:	mov    QWORD PTR [rbp-0x68],rax
  40a817:	lea    r11,[rbp-0x940]
  40a81e:	mov    rax,QWORD PTR [r11+0x38]
  40a822:	mov    r13,rax
  40a825:	lea    r11,[rbp-0x940]
  40a82c:	mov    rax,QWORD PTR [r11+0x40]
  40a830:	mov    QWORD PTR [rbp-0x78],rax
  40a834:	lea    r11,[rbp-0x940]
  40a83b:	mov    rax,QWORD PTR [r11+0x48]
  40a83f:	mov    r14,rax
  40a842:	lea    r11,[rbp-0x940]
  40a849:	mov    rax,QWORD PTR [r11+0x50]
  40a84d:	mov    QWORD PTR [rbp-0x88],rax
  40a854:	lea    r11,[rbp-0x940]
  40a85b:	mov    rax,QWORD PTR [r11+0x58]
  40a85f:	mov    rsi,rax
  40a862:	jmp    409bde <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x86>
  40a867:	mov    rdi,r12
  40a86a:	movabs rsi,0x4
  40a874:	mov    esi,esi
  40a876:	xor    eax,eax
  40a878:	call   420a90 <p111_rt_fail>
  40a87d:	mov    QWORD PTR [rbp-0x980],rax
  40a884:	movabs r10,0x0
  40a88e:	mov    r11,QWORD PTR [rbp-0x30]
  40a892:	mov    QWORD PTR [r11],r10
  40a895:	movabs r10,0x0
  40a89f:	mov    r11,QWORD PTR [rbp-0x30]
  40a8a3:	mov    QWORD PTR [r11+0x8],r10
  40a8a7:	movabs r10,0x0
  40a8b1:	mov    r11,QWORD PTR [rbp-0x30]
  40a8b5:	mov    QWORD PTR [r11+0x10],r10
  40a8b9:	xor    eax,eax
  40a8bb:	mov    r12,QWORD PTR [rbp-0x10]
  40a8bf:	mov    rbx,QWORD PTR [rbp-0x8]
  40a8c3:	mov    r13,QWORD PTR [rbp-0x18]
  40a8c7:	mov    r14,QWORD PTR [rbp-0x20]
  40a8cb:	mov    r15,QWORD PTR [rbp-0x28]
  40a8cf:	mov    rsp,rbp
  40a8d2:	pop    rbp
  40a8d3:	ret    
  40a8d4:	mov    rdi,r12
  40a8d7:	movabs rsi,0x4
  40a8e1:	mov    esi,esi
  40a8e3:	xor    eax,eax
  40a8e5:	call   420a90 <p111_rt_fail>
  40a8ea:	mov    QWORD PTR [rbp-0x980],rax
  40a8f1:	movabs r10,0x0
  40a8fb:	mov    r11,QWORD PTR [rbp-0x30]
  40a8ff:	mov    QWORD PTR [r11],r10
  40a902:	movabs r10,0x0
  40a90c:	mov    r11,QWORD PTR [rbp-0x30]
  40a910:	mov    QWORD PTR [r11+0x8],r10
  40a914:	movabs r10,0x0
  40a91e:	mov    r11,QWORD PTR [rbp-0x30]
  40a922:	mov    QWORD PTR [r11+0x10],r10
  40a926:	xor    eax,eax
  40a928:	mov    r12,QWORD PTR [rbp-0x10]
  40a92c:	mov    rbx,QWORD PTR [rbp-0x8]
  40a930:	mov    r13,QWORD PTR [rbp-0x18]
  40a934:	mov    r14,QWORD PTR [rbp-0x20]
  40a938:	mov    r15,QWORD PTR [rbp-0x28]
  40a93c:	mov    rsp,rbp
  40a93f:	pop    rbp
  40a940:	ret    

Disassembly of section .fini:
