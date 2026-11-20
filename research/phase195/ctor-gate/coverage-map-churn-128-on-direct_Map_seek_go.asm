0000000000441986 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_>:
  441986:	push   rbp
  441987:	mov    rbp,rsp
  44198a:	sub    rsp,0x6020
  441991:	mov    QWORD PTR [rbp-0x10],r12
  441995:	mov    QWORD PTR [rbp-0x8],rbx
  441999:	mov    QWORD PTR [rbp-0x18],r13
  44199d:	mov    QWORD PTR [rbp-0x20],r14
  4419a1:	mov    QWORD PTR [rbp-0x28],r15
  4419a5:	mov    rax,rdi
  4419a8:	mov    r12,rax
  4419ab:	mov    r10,r12
  4419ae:	mov    r10,QWORD PTR [r10+0x28]
  4419b2:	mov    QWORD PTR [rbp-0x880],r10
  4419b9:	mov    r14,QWORD PTR [r12+0x30]
  4419be:	mov    r15,QWORD PTR [rbp-0x880]
  4419c5:	shr    r15,0x28
  4419c9:	and    r15,0xffff
  4419d0:	movabs r11,0x2d
  4419da:	mov    r13,r15
  4419dd:	cmp    r13,r11
  4419e0:	sete   r13b
  4419e4:	movzx  r13d,r13b
  4419e8:	mov    r10,r13
  4419eb:	test   r10d,r10d
  4419ee:	je     449ff2 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x866c>
  4419f4:	mov    rdi,r12
  4419f7:	mov    rsi,QWORD PTR [rbp-0x880]
  4419fe:	lea    rdx,[rbp-0x830]
  441a05:	xor    eax,eax
  441a07:	call   467a10 <p125_rt_take3>
  441a0c:	mov    QWORD PTR [rbp-0x8a0],rax
  441a13:	lea    r10,[rbp-0x830]
  441a1a:	mov    r10,QWORD PTR [r10]
  441a1d:	mov    QWORD PTR [rbp-0x8a8],r10
  441a24:	lea    r10,[rbp-0x830]
  441a2b:	mov    r10,QWORD PTR [r10+0x8]
  441a2f:	mov    QWORD PTR [rbp-0x8b0],r10
  441a36:	lea    r10,[rbp-0x830]
  441a3d:	mov    r10,QWORD PTR [r10+0x10]
  441a41:	mov    QWORD PTR [rbp-0x8b8],r10
  441a48:	mov    r15,QWORD PTR [rbp-0x8b0]
  441a4f:	shr    r15,0x28
  441a53:	and    r15,0xffff
  441a5a:	movabs r11,0x2b
  441a64:	mov    r13,r15
  441a67:	cmp    r13,r11
  441a6a:	sete   r13b
  441a6e:	movzx  r13d,r13b
  441a72:	mov    r10,r13
  441a75:	test   r10d,r10d
  441a78:	je     44424d <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x28c7>
  441a7e:	mov    r15,QWORD PTR [rbp-0x8b8]
  441a85:	shr    r15,0x28
  441a89:	and    r15,0xffff
  441a90:	movabs r11,0x2b
  441a9a:	mov    r13,r15
  441a9d:	cmp    r13,r11
  441aa0:	sete   r13b
  441aa4:	movzx  r13d,r13b
  441aa8:	mov    r10,r13
  441aab:	test   r10d,r10d
  441aae:	je     4425fa <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0xc74>
  441ab4:	mov    r15,r14
  441ab7:	shr    r15,0x28
  441abb:	and    r15,0xffff
  441ac2:	movabs r11,0x8
  441acc:	mov    r13,r15
  441acf:	cmp    r13,r11
  441ad2:	sete   r13b
  441ad6:	movzx  r13d,r13b
  441ada:	mov    r10,r13
  441add:	test   r10d,r10d
  441ae0:	je     442577 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0xbf1>
  441ae6:	mov    rdi,r12
  441ae9:	mov    rsi,r14
  441aec:	lea    rdx,[rbp-0x830]
  441af3:	xor    eax,eax
  441af5:	call   4677b0 <p125_rt_take2>
  441afa:	mov    QWORD PTR [rbp-0x8a0],rax
  441b01:	lea    r10,[rbp-0x830]
  441b08:	mov    r10,QWORD PTR [r10]
  441b0b:	mov    QWORD PTR [rbp-0x8c0],r10
  441b12:	lea    r10,[rbp-0x830]
  441b19:	mov    r10,QWORD PTR [r10+0x8]
  441b1d:	mov    QWORD PTR [rbp-0x8c8],r10
  441b24:	cmp    r10,0x1
  441b2b:	sete   r10b
  441b2f:	movzx  r10d,r10b
  441b33:	mov    QWORD PTR [rbp-0x8d0],r10
  441b3a:	mov    r10,QWORD PTR [rbp-0x8c8]
  441b41:	shr    r10,0x28
  441b45:	mov    QWORD PTR [rbp-0x8d8],r10
  441b4c:	and    r10,0x7fffff
  441b53:	mov    QWORD PTR [rbp-0x8d8],r10
  441b5a:	movabs r10,0x2
  441b64:	or     r10,0x10000
  441b6b:	mov    QWORD PTR [rbp-0x8e0],r10
  441b72:	mov    r10,QWORD PTR [rbp-0x8d8]
  441b79:	mov    r11,QWORD PTR [rbp-0x8e0]
  441b80:	cmp    r10,r11
  441b83:	sete   r10b
  441b87:	movzx  r10d,r10b
  441b8b:	mov    QWORD PTR [rbp-0x8e8],r10
  441b92:	mov    r11,r10
  441b95:	mov    r13,QWORD PTR [rbp-0x8d0]
  441b9c:	or     r13d,r11d
  441b9f:	xor    r13d,0x1
  441ba6:	mov    r10,r13
  441ba9:	test   r10d,r10d
  441bac:	je     441ff9 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x673>
  441bb2:	movabs rdi,0x1002b0000000000
  441bbc:	movabs rsi,0x1002b0000000000
  441bc6:	lea    r10,[rbp-0x830]
  441bcd:	mov    r11,QWORD PTR [rbp-0x8a8]
  441bd4:	mov    QWORD PTR [r10],r11
  441bd7:	lea    r10,[rbp-0x830]
  441bde:	mov    r11,rdi
  441be1:	mov    QWORD PTR [r10+0x8],r11
  441be5:	lea    r10,[rbp-0x830]
  441bec:	mov    r11,rsi
  441bef:	mov    QWORD PTR [r10+0x10],r11
  441bf3:	mov    r10,r12
  441bf6:	mov    r10,QWORD PTR [r10+0x8]
  441bfa:	mov    QWORD PTR [rbp-0x900],r10
  441c01:	mov    r10,QWORD PTR [r10+0x10]
  441c05:	mov    QWORD PTR [rbp-0x908],r10
  441c0c:	cmp    r10,0x0
  441c13:	je     441cd4 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x34e>
  441c19:	mov    rdi,QWORD PTR [r12]
  441c1d:	mov    rsi,QWORD PTR [rbp-0x908]
  441c24:	shl    rsi,0x3
  441c28:	mov    rdx,rdi
  441c2b:	add    rdx,rsi
  441c2e:	mov    rdi,QWORD PTR [rdx]
  441c31:	mov    r10,QWORD PTR [rbp-0x900]
  441c38:	mov    rsi,QWORD PTR [r10+0x110]
  441c3f:	lea    r10,[rbp-0x830]
  441c46:	mov    r8,QWORD PTR [r10]
  441c49:	lea    r10,[rbp-0x830]
  441c50:	mov    r9,QWORD PTR [r10+0x8]
  441c54:	lea    r10,[rbp-0x830]
  441c5b:	mov    r10,QWORD PTR [r10+0x10]
  441c5f:	mov    QWORD PTR [rbp-0x950],r10
  441c66:	mov    r10,QWORD PTR [rbp-0x900]
  441c6d:	mov    r11,rdi
  441c70:	mov    QWORD PTR [r10+0x10],r11
  441c74:	mov    rdi,rsi
  441c77:	sub    rdi,0x4
  441c7e:	mov    r10,QWORD PTR [rbp-0x900]
  441c85:	mov    r11,rdi
  441c88:	mov    QWORD PTR [r10+0x110],r11
  441c8f:	mov    QWORD PTR [rdx],r8
  441c92:	mov    QWORD PTR [rdx+0x8],r9
  441c96:	mov    r10,rdx
  441c99:	mov    r11,QWORD PTR [rbp-0x950]
  441ca0:	mov    QWORD PTR [r10+0x10],r11
  441ca4:	movabs rdi,0x2d
  441cae:	shl    rdi,0x28
  441cb2:	movabs r11,0x200000000000000
  441cbc:	mov    rsi,rdi
  441cbf:	or     rsi,r11
  441cc2:	mov    r11,QWORD PTR [rbp-0x908]
  441cc9:	mov    rbx,rsi
  441ccc:	or     rbx,r11
  441ccf:	jmp    441d00 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x37a>
  441cd4:	mov    rdi,r12
  441cd7:	movabs rsi,0x2d
  441ce1:	mov    esi,esi
  441ce3:	lea    rdx,[rbp-0x830]
  441cea:	movabs rcx,0x3
  441cf4:	mov    ecx,ecx
  441cf6:	xor    eax,eax
  441cf8:	call   461a80 <p111_rt_ctor>
  441cfd:	mov    rbx,rax
  441d00:	mov    r10,rbx
  441d03:	mov    QWORD PTR [rbp-0x978],r10
  441d0a:	movabs rdi,0x1000b0000000000
  441d14:	lea    r10,[rbp-0x830]
  441d1b:	mov    r11,QWORD PTR [rbp-0x8c0]
  441d22:	mov    QWORD PTR [r10],r11
  441d25:	lea    r10,[rbp-0x830]
  441d2c:	mov    r11,rdi
  441d2f:	mov    QWORD PTR [r10+0x8],r11
  441d33:	mov    r10,r12
  441d36:	mov    r10,QWORD PTR [r10+0x8]
  441d3a:	mov    QWORD PTR [rbp-0x988],r10
  441d41:	mov    r10,QWORD PTR [r10+0x8]
  441d45:	mov    QWORD PTR [rbp-0x990],r10
  441d4c:	cmp    r10,0x0
  441d53:	je     441df4 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x46e>
  441d59:	mov    rdi,QWORD PTR [r12]
  441d5d:	mov    rsi,QWORD PTR [rbp-0x990]
  441d64:	shl    rsi,0x3
  441d68:	mov    rdx,rdi
  441d6b:	add    rdx,rsi
  441d6e:	mov    rdi,QWORD PTR [rdx]
  441d71:	mov    r10,QWORD PTR [rbp-0x988]
  441d78:	mov    rsi,QWORD PTR [r10+0x108]
  441d7f:	lea    r10,[rbp-0x830]
  441d86:	mov    r8,QWORD PTR [r10]
  441d89:	lea    r10,[rbp-0x830]
  441d90:	mov    r9,QWORD PTR [r10+0x8]
  441d94:	mov    r10,QWORD PTR [rbp-0x988]
  441d9b:	mov    r11,rdi
  441d9e:	mov    QWORD PTR [r10+0x8],r11
  441da2:	mov    rdi,rsi
  441da5:	sub    rdi,0x2
  441dac:	mov    r10,QWORD PTR [rbp-0x988]
  441db3:	mov    r11,rdi
  441db6:	mov    QWORD PTR [r10+0x108],r11
  441dbd:	mov    QWORD PTR [rdx],r8
  441dc0:	mov    QWORD PTR [rdx+0x8],r9
  441dc4:	movabs rdi,0x8
  441dce:	shl    rdi,0x28
  441dd2:	movabs r11,0x200000000000000
  441ddc:	mov    rsi,rdi
  441ddf:	or     rsi,r11
  441de2:	mov    r11,QWORD PTR [rbp-0x990]
  441de9:	mov    rbx,rsi
  441dec:	or     rbx,r11
  441def:	jmp    441e20 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x49a>
  441df4:	mov    rdi,r12
  441df7:	movabs rsi,0x8
  441e01:	mov    esi,esi
  441e03:	lea    rdx,[rbp-0x830]
  441e0a:	movabs rcx,0x2
  441e14:	mov    ecx,ecx
  441e16:	xor    eax,eax
  441e18:	call   461a80 <p111_rt_ctor>
  441e1d:	mov    rbx,rax
  441e20:	mov    rdi,rbx
  441e23:	lea    r10,[rbp-0x830]
  441e2a:	mov    r11,QWORD PTR [rbp-0x978]
  441e31:	mov    QWORD PTR [r10],r11
  441e34:	lea    r10,[rbp-0x830]
  441e3b:	mov    r11,rdi
  441e3e:	mov    QWORD PTR [r10+0x8],r11
  441e42:	mov    r10,r12
  441e45:	mov    r10,QWORD PTR [r10+0x8]
  441e49:	mov    QWORD PTR [rbp-0x9f8],r10
  441e50:	mov    r10,QWORD PTR [r10+0x8]
  441e54:	mov    QWORD PTR [rbp-0xa00],r10
  441e5b:	cmp    r10,0x0
  441e62:	je     441f03 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x57d>
  441e68:	mov    rdi,QWORD PTR [r12]
  441e6c:	mov    rsi,QWORD PTR [rbp-0xa00]
  441e73:	shl    rsi,0x3
  441e77:	mov    rdx,rdi
  441e7a:	add    rdx,rsi
  441e7d:	mov    rdi,QWORD PTR [rdx]
  441e80:	mov    r10,QWORD PTR [rbp-0x9f8]
  441e87:	mov    rsi,QWORD PTR [r10+0x108]
  441e8e:	lea    r10,[rbp-0x830]
  441e95:	mov    r8,QWORD PTR [r10]
  441e98:	lea    r10,[rbp-0x830]
  441e9f:	mov    r9,QWORD PTR [r10+0x8]
  441ea3:	mov    r10,QWORD PTR [rbp-0x9f8]
  441eaa:	mov    r11,rdi
  441ead:	mov    QWORD PTR [r10+0x8],r11
  441eb1:	mov    rdi,rsi
  441eb4:	sub    rdi,0x2
  441ebb:	mov    r10,QWORD PTR [rbp-0x9f8]
  441ec2:	mov    r11,rdi
  441ec5:	mov    QWORD PTR [r10+0x108],r11
  441ecc:	mov    QWORD PTR [rdx],r8
  441ecf:	mov    QWORD PTR [rdx+0x8],r9
  441ed3:	movabs rdi,0x8
  441edd:	shl    rdi,0x28
  441ee1:	movabs r11,0x200000000000000
  441eeb:	mov    rsi,rdi
  441eee:	or     rsi,r11
  441ef1:	mov    r11,QWORD PTR [rbp-0xa00]
  441ef8:	mov    rbx,rsi
  441efb:	or     rbx,r11
  441efe:	jmp    441f2f <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x5a9>
  441f03:	mov    rdi,r12
  441f06:	movabs rsi,0x8
  441f10:	mov    esi,esi
  441f12:	lea    rdx,[rbp-0x830]
  441f19:	movabs rcx,0x2
  441f23:	mov    ecx,ecx
  441f25:	xor    eax,eax
  441f27:	call   461a80 <p111_rt_ctor>
  441f2c:	mov    rbx,rax
  441f2f:	lea    r10,[rbp-0x830]
  441f36:	mov    r11,rbx
  441f39:	mov    QWORD PTR [r10],r11
  441f3c:	lea    r10,[rip+0x2ec9d]        # 470be0 <p111_program>
  441f43:	movabs rdi,0x4
  441f4d:	and    rdi,QWORD PTR [r10+0x58]
  441f51:	mov    r10,rdi
  441f54:	test   r10d,r10d
  441f57:	je     441fb5 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x62f>
  441f5d:	lea    r10,[rbp-0x830]
  441f64:	mov    rdi,QWORD PTR [r10]
  441f67:	mov    QWORD PTR [r12+0x28],rdi
  441f6c:	mov    r10,r12
  441f6f:	movabs r11,0x1
  441f79:	mov    DWORD PTR [r10+0x1c],r11d
  441f7d:	mov    rdi,QWORD PTR [r12+0x10]
  441f82:	movabs r11,0xfffffffffffffff8
  441f8c:	mov    rsi,rdi
  441f8f:	add    rsi,r11
  441f92:	mov    QWORD PTR [r12+0x10],rsi
  441f97:	mov    rdi,QWORD PTR [rsi]
  441f9a:	mov    DWORD PTR [r12+0x20],edi
  441f9f:	movabs r10,0x0
  441fa9:	mov    QWORD PTR [rbp-0xa90],r10
  441fb0:	jmp    441fd9 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x653>
  441fb5:	mov    rdi,r12
  441fb8:	lea    rsi,[rbp-0x830]
  441fbf:	movabs rdx,0x1
  441fc9:	mov    edx,edx
  441fcb:	xor    eax,eax
  441fcd:	call   462030 <p111_rt_return>
  441fd2:	mov    QWORD PTR [rbp-0xa90],rax
  441fd9:	mov    rax,QWORD PTR [rbp-0xa90]
  441fe0:	mov    r12,QWORD PTR [rbp-0x10]
  441fe4:	mov    rbx,QWORD PTR [rbp-0x8]
  441fe8:	mov    r13,QWORD PTR [rbp-0x18]
  441fec:	mov    r14,QWORD PTR [rbp-0x20]
  441ff0:	mov    r15,QWORD PTR [rbp-0x28]
  441ff4:	mov    rsp,rbp
  441ff7:	pop    rbp
  441ff8:	ret    
  441ff9:	mov    r10,QWORD PTR [rbp-0x8c8]
  442000:	cmp    r10,0x1
  442007:	sete   r10b
  44200b:	movzx  r10d,r10b
  44200f:	mov    QWORD PTR [rbp-0x8d0],r10
  442016:	mov    r10,QWORD PTR [rbp-0x8c8]
  44201d:	shr    r10,0x28
  442021:	mov    QWORD PTR [rbp-0x8d8],r10
  442028:	and    r10,0x7fffff
  44202f:	mov    QWORD PTR [rbp-0x8d8],r10
  442036:	movabs r10,0x2
  442040:	or     r10,0x10000
  442047:	mov    QWORD PTR [rbp-0x8e0],r10
  44204e:	mov    r10,QWORD PTR [rbp-0x8d8]
  442055:	mov    r11,QWORD PTR [rbp-0x8e0]
  44205c:	cmp    r10,r11
  44205f:	sete   r10b
  442063:	movzx  r10d,r10b
  442067:	mov    QWORD PTR [rbp-0x8e8],r10
  44206e:	mov    r11,r10
  442071:	mov    r13,QWORD PTR [rbp-0x8d0]
  442078:	or     r13d,r11d
  44207b:	mov    r10,r13
  44207e:	test   r10d,r10d
  442081:	je     4424ce <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0xb48>
  442087:	movabs rdi,0x1002b0000000000
  442091:	movabs rsi,0x1002b0000000000
  44209b:	lea    r10,[rbp-0x830]
  4420a2:	mov    r11,QWORD PTR [rbp-0x8a8]
  4420a9:	mov    QWORD PTR [r10],r11
  4420ac:	lea    r10,[rbp-0x830]
  4420b3:	mov    r11,rdi
  4420b6:	mov    QWORD PTR [r10+0x8],r11
  4420ba:	lea    r10,[rbp-0x830]
  4420c1:	mov    r11,rsi
  4420c4:	mov    QWORD PTR [r10+0x10],r11
  4420c8:	mov    r10,r12
  4420cb:	mov    r10,QWORD PTR [r10+0x8]
  4420cf:	mov    QWORD PTR [rbp-0xaa8],r10
  4420d6:	mov    r10,QWORD PTR [r10+0x10]
  4420da:	mov    QWORD PTR [rbp-0xab0],r10
  4420e1:	cmp    r10,0x0
  4420e8:	je     4421a9 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x823>
  4420ee:	mov    rdi,QWORD PTR [r12]
  4420f2:	mov    rsi,QWORD PTR [rbp-0xab0]
  4420f9:	shl    rsi,0x3
  4420fd:	mov    rdx,rdi
  442100:	add    rdx,rsi
  442103:	mov    rdi,QWORD PTR [rdx]
  442106:	mov    r10,QWORD PTR [rbp-0xaa8]
  44210d:	mov    rsi,QWORD PTR [r10+0x110]
  442114:	lea    r10,[rbp-0x830]
  44211b:	mov    r8,QWORD PTR [r10]
  44211e:	lea    r10,[rbp-0x830]
  442125:	mov    r9,QWORD PTR [r10+0x8]
  442129:	lea    r10,[rbp-0x830]
  442130:	mov    r10,QWORD PTR [r10+0x10]
  442134:	mov    QWORD PTR [rbp-0xaf8],r10
  44213b:	mov    r10,QWORD PTR [rbp-0xaa8]
  442142:	mov    r11,rdi
  442145:	mov    QWORD PTR [r10+0x10],r11
  442149:	mov    rdi,rsi
  44214c:	sub    rdi,0x4
  442153:	mov    r10,QWORD PTR [rbp-0xaa8]
  44215a:	mov    r11,rdi
  44215d:	mov    QWORD PTR [r10+0x110],r11
  442164:	mov    QWORD PTR [rdx],r8
  442167:	mov    QWORD PTR [rdx+0x8],r9
  44216b:	mov    r10,rdx
  44216e:	mov    r11,QWORD PTR [rbp-0xaf8]
  442175:	mov    QWORD PTR [r10+0x10],r11
  442179:	movabs rdi,0x2d
  442183:	shl    rdi,0x28
  442187:	movabs r11,0x200000000000000
  442191:	mov    rsi,rdi
  442194:	or     rsi,r11
  442197:	mov    r11,QWORD PTR [rbp-0xab0]
  44219e:	mov    rbx,rsi
  4421a1:	or     rbx,r11
  4421a4:	jmp    4421d5 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x84f>
  4421a9:	mov    rdi,r12
  4421ac:	movabs rsi,0x2d
  4421b6:	mov    esi,esi
  4421b8:	lea    rdx,[rbp-0x830]
  4421bf:	movabs rcx,0x3
  4421c9:	mov    ecx,ecx
  4421cb:	xor    eax,eax
  4421cd:	call   461a80 <p111_rt_ctor>
  4421d2:	mov    rbx,rax
  4421d5:	mov    r10,rbx
  4421d8:	mov    QWORD PTR [rbp-0xb18],r10
  4421df:	movabs rdi,0x1000b0000000000
  4421e9:	lea    r10,[rbp-0x830]
  4421f0:	mov    r11,QWORD PTR [rbp-0x8c0]
  4421f7:	mov    QWORD PTR [r10],r11
  4421fa:	lea    r10,[rbp-0x830]
  442201:	mov    r11,rdi
  442204:	mov    QWORD PTR [r10+0x8],r11
  442208:	mov    r10,r12
  44220b:	mov    r10,QWORD PTR [r10+0x8]
  44220f:	mov    QWORD PTR [rbp-0xb28],r10
  442216:	mov    r10,QWORD PTR [r10+0x8]
  44221a:	mov    QWORD PTR [rbp-0xb30],r10
  442221:	cmp    r10,0x0
  442228:	je     4422c9 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x943>
  44222e:	mov    rdi,QWORD PTR [r12]
  442232:	mov    rsi,QWORD PTR [rbp-0xb30]
  442239:	shl    rsi,0x3
  44223d:	mov    rdx,rdi
  442240:	add    rdx,rsi
  442243:	mov    rdi,QWORD PTR [rdx]
  442246:	mov    r10,QWORD PTR [rbp-0xb28]
  44224d:	mov    rsi,QWORD PTR [r10+0x108]
  442254:	lea    r10,[rbp-0x830]
  44225b:	mov    r8,QWORD PTR [r10]
  44225e:	lea    r10,[rbp-0x830]
  442265:	mov    r9,QWORD PTR [r10+0x8]
  442269:	mov    r10,QWORD PTR [rbp-0xb28]
  442270:	mov    r11,rdi
  442273:	mov    QWORD PTR [r10+0x8],r11
  442277:	mov    rdi,rsi
  44227a:	sub    rdi,0x2
  442281:	mov    r10,QWORD PTR [rbp-0xb28]
  442288:	mov    r11,rdi
  44228b:	mov    QWORD PTR [r10+0x108],r11
  442292:	mov    QWORD PTR [rdx],r8
  442295:	mov    QWORD PTR [rdx+0x8],r9
  442299:	movabs rdi,0x8
  4422a3:	shl    rdi,0x28
  4422a7:	movabs r11,0x200000000000000
  4422b1:	mov    rsi,rdi
  4422b4:	or     rsi,r11
  4422b7:	mov    r11,QWORD PTR [rbp-0xb30]
  4422be:	mov    rbx,rsi
  4422c1:	or     rbx,r11
  4422c4:	jmp    4422f5 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x96f>
  4422c9:	mov    rdi,r12
  4422cc:	movabs rsi,0x8
  4422d6:	mov    esi,esi
  4422d8:	lea    rdx,[rbp-0x830]
  4422df:	movabs rcx,0x2
  4422e9:	mov    ecx,ecx
  4422eb:	xor    eax,eax
  4422ed:	call   461a80 <p111_rt_ctor>
  4422f2:	mov    rbx,rax
  4422f5:	mov    rdi,rbx
  4422f8:	lea    r10,[rbp-0x830]
  4422ff:	mov    r11,QWORD PTR [rbp-0xb18]
  442306:	mov    QWORD PTR [r10],r11
  442309:	lea    r10,[rbp-0x830]
  442310:	mov    r11,rdi
  442313:	mov    QWORD PTR [r10+0x8],r11
  442317:	mov    r10,r12
  44231a:	mov    r10,QWORD PTR [r10+0x8]
  44231e:	mov    QWORD PTR [rbp-0xb98],r10
  442325:	mov    r10,QWORD PTR [r10+0x8]
  442329:	mov    QWORD PTR [rbp-0xba0],r10
  442330:	cmp    r10,0x0
  442337:	je     4423d8 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0xa52>
  44233d:	mov    rdi,QWORD PTR [r12]
  442341:	mov    rsi,QWORD PTR [rbp-0xba0]
  442348:	shl    rsi,0x3
  44234c:	mov    rdx,rdi
  44234f:	add    rdx,rsi
  442352:	mov    rdi,QWORD PTR [rdx]
  442355:	mov    r10,QWORD PTR [rbp-0xb98]
  44235c:	mov    rsi,QWORD PTR [r10+0x108]
  442363:	lea    r10,[rbp-0x830]
  44236a:	mov    r8,QWORD PTR [r10]
  44236d:	lea    r10,[rbp-0x830]
  442374:	mov    r9,QWORD PTR [r10+0x8]
  442378:	mov    r10,QWORD PTR [rbp-0xb98]
  44237f:	mov    r11,rdi
  442382:	mov    QWORD PTR [r10+0x8],r11
  442386:	mov    rdi,rsi
  442389:	sub    rdi,0x2
  442390:	mov    r10,QWORD PTR [rbp-0xb98]
  442397:	mov    r11,rdi
  44239a:	mov    QWORD PTR [r10+0x108],r11
  4423a1:	mov    QWORD PTR [rdx],r8
  4423a4:	mov    QWORD PTR [rdx+0x8],r9
  4423a8:	movabs rdi,0x8
  4423b2:	shl    rdi,0x28
  4423b6:	movabs r11,0x200000000000000
  4423c0:	mov    rsi,rdi
  4423c3:	or     rsi,r11
  4423c6:	mov    r11,QWORD PTR [rbp-0xba0]
  4423cd:	mov    rbx,rsi
  4423d0:	or     rbx,r11
  4423d3:	jmp    442404 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0xa7e>
  4423d8:	mov    rdi,r12
  4423db:	movabs rsi,0x8
  4423e5:	mov    esi,esi
  4423e7:	lea    rdx,[rbp-0x830]
  4423ee:	movabs rcx,0x2
  4423f8:	mov    ecx,ecx
  4423fa:	xor    eax,eax
  4423fc:	call   461a80 <p111_rt_ctor>
  442401:	mov    rbx,rax
  442404:	lea    r10,[rbp-0x830]
  44240b:	mov    r11,rbx
  44240e:	mov    QWORD PTR [r10],r11
  442411:	lea    r10,[rip+0x2e7c8]        # 470be0 <p111_program>
  442418:	movabs rdi,0x4
  442422:	and    rdi,QWORD PTR [r10+0x58]
  442426:	mov    r10,rdi
  442429:	test   r10d,r10d
  44242c:	je     44248a <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0xb04>
  442432:	lea    r10,[rbp-0x830]
  442439:	mov    rdi,QWORD PTR [r10]
  44243c:	mov    QWORD PTR [r12+0x28],rdi
  442441:	mov    r10,r12
  442444:	movabs r11,0x1
  44244e:	mov    DWORD PTR [r10+0x1c],r11d
  442452:	mov    rdi,QWORD PTR [r12+0x10]
  442457:	movabs r11,0xfffffffffffffff8
  442461:	mov    rsi,rdi
  442464:	add    rsi,r11
  442467:	mov    QWORD PTR [r12+0x10],rsi
  44246c:	mov    rdi,QWORD PTR [rsi]
  44246f:	mov    DWORD PTR [r12+0x20],edi
  442474:	movabs r10,0x0
  44247e:	mov    QWORD PTR [rbp-0xa90],r10
  442485:	jmp    4424ae <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0xb28>
  44248a:	mov    rdi,r12
  44248d:	lea    rsi,[rbp-0x830]
  442494:	movabs rdx,0x1
  44249e:	mov    edx,edx
  4424a0:	xor    eax,eax
  4424a2:	call   462030 <p111_rt_return>
  4424a7:	mov    QWORD PTR [rbp-0xa90],rax
  4424ae:	mov    rax,QWORD PTR [rbp-0xa90]
  4424b5:	mov    r12,QWORD PTR [rbp-0x10]
  4424b9:	mov    rbx,QWORD PTR [rbp-0x8]
  4424bd:	mov    r13,QWORD PTR [rbp-0x18]
  4424c1:	mov    r14,QWORD PTR [rbp-0x20]
  4424c5:	mov    r15,QWORD PTR [rbp-0x28]
  4424c9:	mov    rsp,rbp
  4424cc:	pop    rbp
  4424cd:	ret    
  4424ce:	mov    rdi,r12
  4424d1:	mov    rsi,QWORD PTR [rbp-0x8a8]
  4424d8:	xor    eax,eax
  4424da:	call   461a10 <p111_rt_sink>
  4424df:	mov    QWORD PTR [rbp-0x8a0],rax
  4424e6:	mov    rdi,r12
  4424e9:	mov    rsi,QWORD PTR [rbp-0x8c0]
  4424f0:	xor    eax,eax
  4424f2:	call   461a10 <p111_rt_sink>
  4424f7:	mov    QWORD PTR [rbp-0x8a0],rax
  4424fe:	lea    r10,[rbp-0x830]
  442505:	mov    r11,QWORD PTR [rbp-0x8c8]
  44250c:	mov    QWORD PTR [r10],r11
  44250f:	mov    rdi,QWORD PTR [r12+0x10]
  442514:	mov    r10,rdi
  442517:	mov    r11,QWORD PTR [rbp-0x8c8]
  44251e:	mov    QWORD PTR [r10],r11
  442521:	mov    r10,rdi
  442524:	movabs r11,0x152
  44252e:	mov    QWORD PTR [r10+0x8],r11
  442532:	mov    rsi,rdi
  442535:	add    rsi,0x10
  44253c:	mov    QWORD PTR [r12+0x10],rsi
  442541:	mov    rdi,r12
  442544:	movabs rsi,0x4
  44254e:	mov    esi,esi
  442550:	xor    eax,eax
  442552:	call   4621a0 <p111_rt_fail>
  442557:	mov    QWORD PTR [rbp-0xa90],rax
  44255e:	mov    r12,QWORD PTR [rbp-0x10]
  442562:	mov    rbx,QWORD PTR [rbp-0x8]
  442566:	mov    r13,QWORD PTR [rbp-0x18]
  44256a:	mov    r14,QWORD PTR [rbp-0x20]
  44256e:	mov    r15,QWORD PTR [rbp-0x28]
  442572:	mov    rsp,rbp
  442575:	pop    rbp
  442576:	ret    
  442577:	mov    rdi,r12
  44257a:	mov    rsi,QWORD PTR [rbp-0x8a8]
  442581:	xor    eax,eax
  442583:	call   461a10 <p111_rt_sink>
  442588:	mov    QWORD PTR [rbp-0x8a0],rax
  44258f:	lea    r10,[rbp-0x830]
  442596:	mov    r11,r14
  442599:	mov    QWORD PTR [r10],r11
  44259c:	mov    rdi,QWORD PTR [r12+0x10]
  4425a1:	mov    QWORD PTR [rdi],r14
  4425a4:	mov    r10,rdi
  4425a7:	movabs r11,0x153
  4425b1:	mov    QWORD PTR [r10+0x8],r11
  4425b5:	mov    rsi,rdi
  4425b8:	add    rsi,0x10
  4425bf:	mov    QWORD PTR [r12+0x10],rsi
  4425c4:	mov    rdi,r12
  4425c7:	movabs rsi,0x4
  4425d1:	mov    esi,esi
  4425d3:	xor    eax,eax
  4425d5:	call   4621a0 <p111_rt_fail>
  4425da:	mov    QWORD PTR [rbp-0xa90],rax
  4425e1:	mov    r12,QWORD PTR [rbp-0x10]
  4425e5:	mov    rbx,QWORD PTR [rbp-0x8]
  4425e9:	mov    r13,QWORD PTR [rbp-0x18]
  4425ed:	mov    r14,QWORD PTR [rbp-0x20]
  4425f1:	mov    r15,QWORD PTR [rbp-0x28]
  4425f5:	mov    rsp,rbp
  4425f8:	pop    rbp
  4425f9:	ret    
  4425fa:	mov    r15,QWORD PTR [rbp-0x8b8]
  442601:	shr    r15,0x28
  442605:	and    r15,0xffff
  44260c:	movabs r11,0x2c
  442616:	mov    r13,r15
  442619:	cmp    r13,r11
  44261c:	sete   r13b
  442620:	movzx  r13d,r13b
  442624:	mov    r10,r13
  442627:	test   r10d,r10d
  44262a:	je     443543 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1bbd>
  442630:	mov    rdi,r12
  442633:	mov    rsi,QWORD PTR [rbp-0x8b8]
  44263a:	lea    rdx,[rbp-0x830]
  442641:	xor    eax,eax
  442643:	call   4677b0 <p125_rt_take2>
  442648:	mov    QWORD PTR [rbp-0x8a0],rax
  44264f:	lea    r10,[rbp-0x830]
  442656:	mov    r10,QWORD PTR [r10]
  442659:	mov    QWORD PTR [rbp-0xc50],r10
  442660:	lea    r10,[rbp-0x830]
  442667:	mov    r10,QWORD PTR [r10+0x8]
  44266b:	mov    QWORD PTR [rbp-0xc58],r10
  442672:	mov    r15,r14
  442675:	shr    r15,0x28
  442679:	and    r15,0xffff
  442680:	movabs r11,0x8
  44268a:	mov    r13,r15
  44268d:	cmp    r13,r11
  442690:	sete   r13b
  442694:	movzx  r13d,r13b
  442698:	mov    r10,r13
  44269b:	test   r10d,r10d
  44269e:	je     443490 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1b0a>
  4426a4:	mov    rdi,r12
  4426a7:	mov    rsi,r14
  4426aa:	lea    rdx,[rbp-0x830]
  4426b1:	xor    eax,eax
  4426b3:	call   4677b0 <p125_rt_take2>
  4426b8:	mov    QWORD PTR [rbp-0x8a0],rax
  4426bf:	lea    r10,[rbp-0x830]
  4426c6:	mov    r10,QWORD PTR [r10]
  4426c9:	mov    QWORD PTR [rbp-0xc60],r10
  4426d0:	lea    r10,[rbp-0x830]
  4426d7:	mov    r10,QWORD PTR [r10+0x8]
  4426db:	mov    QWORD PTR [rbp-0xc68],r10
  4426e2:	cmp    r10,0x1
  4426e9:	sete   r10b
  4426ed:	movzx  r10d,r10b
  4426f1:	mov    QWORD PTR [rbp-0x8d0],r10
  4426f8:	mov    r10,QWORD PTR [rbp-0xc68]
  4426ff:	shr    r10,0x28
  442703:	mov    QWORD PTR [rbp-0x8d8],r10
  44270a:	and    r10,0x7fffff
  442711:	mov    QWORD PTR [rbp-0x8d8],r10
  442718:	movabs r10,0x2
  442722:	or     r10,0x10000
  442729:	mov    QWORD PTR [rbp-0x8e0],r10
  442730:	mov    r10,QWORD PTR [rbp-0x8d8]
  442737:	mov    r11,QWORD PTR [rbp-0x8e0]
  44273e:	cmp    r10,r11
  442741:	sete   r10b
  442745:	movzx  r10d,r10b
  442749:	mov    QWORD PTR [rbp-0x8e8],r10
  442750:	mov    r11,r10
  442753:	mov    r13,QWORD PTR [rbp-0x8d0]
  44275a:	or     r13d,r11d
  44275d:	xor    r13d,0x1
  442764:	mov    r10,r13
  442767:	test   r10d,r10d
  44276a:	je     442cce <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1348>
  442770:	movabs r10,0x1002b0000000000
  44277a:	mov    QWORD PTR [rbp-0xc70],r10
  442781:	mov    rdi,QWORD PTR [rbp-0xc50]
  442788:	lea    r10,[rbp-0x830]
  44278f:	mov    r11,rdi
  442792:	mov    QWORD PTR [r10],r11
  442795:	lea    r10,[rbp-0x830]
  44279c:	mov    r11,QWORD PTR [rbp-0xc58]
  4427a3:	mov    QWORD PTR [r10+0x8],r11
  4427a7:	mov    r10,r12
  4427aa:	mov    r10,QWORD PTR [r10+0x8]
  4427ae:	mov    QWORD PTR [rbp-0xc80],r10
  4427b5:	mov    r10,QWORD PTR [r10+0x8]
  4427b9:	mov    QWORD PTR [rbp-0xc88],r10
  4427c0:	cmp    r10,0x0
  4427c7:	je     442868 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0xee2>
  4427cd:	mov    rdi,QWORD PTR [r12]
  4427d1:	mov    rsi,QWORD PTR [rbp-0xc88]
  4427d8:	shl    rsi,0x3
  4427dc:	mov    rdx,rdi
  4427df:	add    rdx,rsi
  4427e2:	mov    rdi,QWORD PTR [rdx]
  4427e5:	mov    r10,QWORD PTR [rbp-0xc80]
  4427ec:	mov    rsi,QWORD PTR [r10+0x108]
  4427f3:	lea    r10,[rbp-0x830]
  4427fa:	mov    r8,QWORD PTR [r10]
  4427fd:	lea    r10,[rbp-0x830]
  442804:	mov    r9,QWORD PTR [r10+0x8]
  442808:	mov    r10,QWORD PTR [rbp-0xc80]
  44280f:	mov    r11,rdi
  442812:	mov    QWORD PTR [r10+0x8],r11
  442816:	mov    rdi,rsi
  442819:	sub    rdi,0x2
  442820:	mov    r10,QWORD PTR [rbp-0xc80]
  442827:	mov    r11,rdi
  44282a:	mov    QWORD PTR [r10+0x108],r11
  442831:	mov    QWORD PTR [rdx],r8
  442834:	mov    QWORD PTR [rdx+0x8],r9
  442838:	movabs rdi,0x2c
  442842:	shl    rdi,0x28
  442846:	movabs r11,0x200000000000000
  442850:	mov    rsi,rdi
  442853:	or     rsi,r11
  442856:	mov    r11,QWORD PTR [rbp-0xc88]
  44285d:	mov    rbx,rsi
  442860:	or     rbx,r11
  442863:	jmp    442894 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0xf0e>
  442868:	mov    rdi,r12
  44286b:	movabs rsi,0x2c
  442875:	mov    esi,esi
  442877:	lea    rdx,[rbp-0x830]
  44287e:	movabs rcx,0x2
  442888:	mov    ecx,ecx
  44288a:	xor    eax,eax
  44288c:	call   461a80 <p111_rt_ctor>
  442891:	mov    rbx,rax
  442894:	mov    rdi,rbx
  442897:	lea    r10,[rbp-0x830]
  44289e:	mov    r11,QWORD PTR [rbp-0x8a8]
  4428a5:	mov    QWORD PTR [r10],r11
  4428a8:	lea    r10,[rbp-0x830]
  4428af:	mov    r11,QWORD PTR [rbp-0xc70]
  4428b6:	mov    QWORD PTR [r10+0x8],r11
  4428ba:	lea    r10,[rbp-0x830]
  4428c1:	mov    r11,rdi
  4428c4:	mov    QWORD PTR [r10+0x10],r11
  4428c8:	mov    r10,r12
  4428cb:	mov    r10,QWORD PTR [r10+0x8]
  4428cf:	mov    QWORD PTR [rbp-0xcf0],r10
  4428d6:	mov    r10,QWORD PTR [r10+0x10]
  4428da:	mov    QWORD PTR [rbp-0xcf8],r10
  4428e1:	cmp    r10,0x0
  4428e8:	je     4429a9 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1023>
  4428ee:	mov    rdi,QWORD PTR [r12]
  4428f2:	mov    rsi,QWORD PTR [rbp-0xcf8]
  4428f9:	shl    rsi,0x3
  4428fd:	mov    rdx,rdi
  442900:	add    rdx,rsi
  442903:	mov    rdi,QWORD PTR [rdx]
  442906:	mov    r10,QWORD PTR [rbp-0xcf0]
  44290d:	mov    rsi,QWORD PTR [r10+0x110]
  442914:	lea    r10,[rbp-0x830]
  44291b:	mov    r8,QWORD PTR [r10]
  44291e:	lea    r10,[rbp-0x830]
  442925:	mov    r9,QWORD PTR [r10+0x8]
  442929:	lea    r10,[rbp-0x830]
  442930:	mov    r10,QWORD PTR [r10+0x10]
  442934:	mov    QWORD PTR [rbp-0xd40],r10
  44293b:	mov    r10,QWORD PTR [rbp-0xcf0]
  442942:	mov    r11,rdi
  442945:	mov    QWORD PTR [r10+0x10],r11
  442949:	mov    rdi,rsi
  44294c:	sub    rdi,0x4
  442953:	mov    r10,QWORD PTR [rbp-0xcf0]
  44295a:	mov    r11,rdi
  44295d:	mov    QWORD PTR [r10+0x110],r11
  442964:	mov    QWORD PTR [rdx],r8
  442967:	mov    QWORD PTR [rdx+0x8],r9
  44296b:	mov    r10,rdx
  44296e:	mov    r11,QWORD PTR [rbp-0xd40]
  442975:	mov    QWORD PTR [r10+0x10],r11
  442979:	movabs rdi,0x2d
  442983:	shl    rdi,0x28
  442987:	movabs r11,0x200000000000000
  442991:	mov    rsi,rdi
  442994:	or     rsi,r11
  442997:	mov    r11,QWORD PTR [rbp-0xcf8]
  44299e:	mov    rbx,rsi
  4429a1:	or     rbx,r11
  4429a4:	jmp    4429d5 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x104f>
  4429a9:	mov    rdi,r12
  4429ac:	movabs rsi,0x2d
  4429b6:	mov    esi,esi
  4429b8:	lea    rdx,[rbp-0x830]
  4429bf:	movabs rcx,0x3
  4429c9:	mov    ecx,ecx
  4429cb:	xor    eax,eax
  4429cd:	call   461a80 <p111_rt_ctor>
  4429d2:	mov    rbx,rax
  4429d5:	mov    r10,rbx
  4429d8:	mov    QWORD PTR [rbp-0xd60],r10
  4429df:	movabs rdi,0x1000b0000000000
  4429e9:	lea    r10,[rbp-0x830]
  4429f0:	mov    r11,QWORD PTR [rbp-0xc60]
  4429f7:	mov    QWORD PTR [r10],r11
  4429fa:	lea    r10,[rbp-0x830]
  442a01:	mov    r11,rdi
  442a04:	mov    QWORD PTR [r10+0x8],r11
  442a08:	mov    r10,r12
  442a0b:	mov    r10,QWORD PTR [r10+0x8]
  442a0f:	mov    QWORD PTR [rbp-0xd70],r10
  442a16:	mov    r10,QWORD PTR [r10+0x8]
  442a1a:	mov    QWORD PTR [rbp-0xd78],r10
  442a21:	cmp    r10,0x0
  442a28:	je     442ac9 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1143>
  442a2e:	mov    rdi,QWORD PTR [r12]
  442a32:	mov    rsi,QWORD PTR [rbp-0xd78]
  442a39:	shl    rsi,0x3
  442a3d:	mov    rdx,rdi
  442a40:	add    rdx,rsi
  442a43:	mov    rdi,QWORD PTR [rdx]
  442a46:	mov    r10,QWORD PTR [rbp-0xd70]
  442a4d:	mov    rsi,QWORD PTR [r10+0x108]
  442a54:	lea    r10,[rbp-0x830]
  442a5b:	mov    r8,QWORD PTR [r10]
  442a5e:	lea    r10,[rbp-0x830]
  442a65:	mov    r9,QWORD PTR [r10+0x8]
  442a69:	mov    r10,QWORD PTR [rbp-0xd70]
  442a70:	mov    r11,rdi
  442a73:	mov    QWORD PTR [r10+0x8],r11
  442a77:	mov    rdi,rsi
  442a7a:	sub    rdi,0x2
  442a81:	mov    r10,QWORD PTR [rbp-0xd70]
  442a88:	mov    r11,rdi
  442a8b:	mov    QWORD PTR [r10+0x108],r11
  442a92:	mov    QWORD PTR [rdx],r8
  442a95:	mov    QWORD PTR [rdx+0x8],r9
  442a99:	movabs rdi,0x8
  442aa3:	shl    rdi,0x28
  442aa7:	movabs r11,0x200000000000000
  442ab1:	mov    rsi,rdi
  442ab4:	or     rsi,r11
  442ab7:	mov    r11,QWORD PTR [rbp-0xd78]
  442abe:	mov    rbx,rsi
  442ac1:	or     rbx,r11
  442ac4:	jmp    442af5 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x116f>
  442ac9:	mov    rdi,r12
  442acc:	movabs rsi,0x8
  442ad6:	mov    esi,esi
  442ad8:	lea    rdx,[rbp-0x830]
  442adf:	movabs rcx,0x2
  442ae9:	mov    ecx,ecx
  442aeb:	xor    eax,eax
  442aed:	call   461a80 <p111_rt_ctor>
  442af2:	mov    rbx,rax
  442af5:	mov    rdi,rbx
  442af8:	lea    r10,[rbp-0x830]
  442aff:	mov    r11,QWORD PTR [rbp-0xd60]
  442b06:	mov    QWORD PTR [r10],r11
  442b09:	lea    r10,[rbp-0x830]
  442b10:	mov    r11,rdi
  442b13:	mov    QWORD PTR [r10+0x8],r11
  442b17:	mov    r10,r12
  442b1a:	mov    r10,QWORD PTR [r10+0x8]
  442b1e:	mov    QWORD PTR [rbp-0xde0],r10
  442b25:	mov    r10,QWORD PTR [r10+0x8]
  442b29:	mov    QWORD PTR [rbp-0xde8],r10
  442b30:	cmp    r10,0x0
  442b37:	je     442bd8 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1252>
  442b3d:	mov    rdi,QWORD PTR [r12]
  442b41:	mov    rsi,QWORD PTR [rbp-0xde8]
  442b48:	shl    rsi,0x3
  442b4c:	mov    rdx,rdi
  442b4f:	add    rdx,rsi
  442b52:	mov    rdi,QWORD PTR [rdx]
  442b55:	mov    r10,QWORD PTR [rbp-0xde0]
  442b5c:	mov    rsi,QWORD PTR [r10+0x108]
  442b63:	lea    r10,[rbp-0x830]
  442b6a:	mov    r8,QWORD PTR [r10]
  442b6d:	lea    r10,[rbp-0x830]
  442b74:	mov    r9,QWORD PTR [r10+0x8]
  442b78:	mov    r10,QWORD PTR [rbp-0xde0]
  442b7f:	mov    r11,rdi
  442b82:	mov    QWORD PTR [r10+0x8],r11
  442b86:	mov    rdi,rsi
  442b89:	sub    rdi,0x2
  442b90:	mov    r10,QWORD PTR [rbp-0xde0]
  442b97:	mov    r11,rdi
  442b9a:	mov    QWORD PTR [r10+0x108],r11
  442ba1:	mov    QWORD PTR [rdx],r8
  442ba4:	mov    QWORD PTR [rdx+0x8],r9
  442ba8:	movabs rdi,0x8
  442bb2:	shl    rdi,0x28
  442bb6:	movabs r11,0x200000000000000
  442bc0:	mov    rsi,rdi
  442bc3:	or     rsi,r11
  442bc6:	mov    r11,QWORD PTR [rbp-0xde8]
  442bcd:	mov    rbx,rsi
  442bd0:	or     rbx,r11
  442bd3:	jmp    442c04 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x127e>
  442bd8:	mov    rdi,r12
  442bdb:	movabs rsi,0x8
  442be5:	mov    esi,esi
  442be7:	lea    rdx,[rbp-0x830]
  442bee:	movabs rcx,0x2
  442bf8:	mov    ecx,ecx
  442bfa:	xor    eax,eax
  442bfc:	call   461a80 <p111_rt_ctor>
  442c01:	mov    rbx,rax
  442c04:	lea    r10,[rbp-0x830]
  442c0b:	mov    r11,rbx
  442c0e:	mov    QWORD PTR [r10],r11
  442c11:	lea    r10,[rip+0x2dfc8]        # 470be0 <p111_program>
  442c18:	movabs rdi,0x4
  442c22:	and    rdi,QWORD PTR [r10+0x58]
  442c26:	mov    r10,rdi
  442c29:	test   r10d,r10d
  442c2c:	je     442c8a <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1304>
  442c32:	lea    r10,[rbp-0x830]
  442c39:	mov    rdi,QWORD PTR [r10]
  442c3c:	mov    QWORD PTR [r12+0x28],rdi
  442c41:	mov    r10,r12
  442c44:	movabs r11,0x1
  442c4e:	mov    DWORD PTR [r10+0x1c],r11d
  442c52:	mov    rdi,QWORD PTR [r12+0x10]
  442c57:	movabs r11,0xfffffffffffffff8
  442c61:	mov    rsi,rdi
  442c64:	add    rsi,r11
  442c67:	mov    QWORD PTR [r12+0x10],rsi
  442c6c:	mov    rdi,QWORD PTR [rsi]
  442c6f:	mov    DWORD PTR [r12+0x20],edi
  442c74:	movabs r10,0x0
  442c7e:	mov    QWORD PTR [rbp-0xa90],r10
  442c85:	jmp    442cae <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1328>
  442c8a:	mov    rdi,r12
  442c8d:	lea    rsi,[rbp-0x830]
  442c94:	movabs rdx,0x1
  442c9e:	mov    edx,edx
  442ca0:	xor    eax,eax
  442ca2:	call   462030 <p111_rt_return>
  442ca7:	mov    QWORD PTR [rbp-0xa90],rax
  442cae:	mov    rax,QWORD PTR [rbp-0xa90]
  442cb5:	mov    r12,QWORD PTR [rbp-0x10]
  442cb9:	mov    rbx,QWORD PTR [rbp-0x8]
  442cbd:	mov    r13,QWORD PTR [rbp-0x18]
  442cc1:	mov    r14,QWORD PTR [rbp-0x20]
  442cc5:	mov    r15,QWORD PTR [rbp-0x28]
  442cc9:	mov    rsp,rbp
  442ccc:	pop    rbp
  442ccd:	ret    
  442cce:	mov    r10,QWORD PTR [rbp-0xc68]
  442cd5:	cmp    r10,0x1
  442cdc:	sete   r10b
  442ce0:	movzx  r10d,r10b
  442ce4:	mov    QWORD PTR [rbp-0x8d0],r10
  442ceb:	mov    r10,QWORD PTR [rbp-0xc68]
  442cf2:	shr    r10,0x28
  442cf6:	mov    QWORD PTR [rbp-0x8d8],r10
  442cfd:	and    r10,0x7fffff
  442d04:	mov    QWORD PTR [rbp-0x8d8],r10
  442d0b:	movabs r10,0x2
  442d15:	or     r10,0x10000
  442d1c:	mov    QWORD PTR [rbp-0x8e0],r10
  442d23:	mov    r10,QWORD PTR [rbp-0x8d8]
  442d2a:	mov    r11,QWORD PTR [rbp-0x8e0]
  442d31:	cmp    r10,r11
  442d34:	sete   r10b
  442d38:	movzx  r10d,r10b
  442d3c:	mov    QWORD PTR [rbp-0x8e8],r10
  442d43:	mov    r11,r10
  442d46:	mov    r13,QWORD PTR [rbp-0x8d0]
  442d4d:	or     r13d,r11d
  442d50:	mov    r10,r13
  442d53:	test   r10d,r10d
  442d56:	je     4433b7 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1a31>
  442d5c:	movabs r10,0x1002b0000000000
  442d66:	mov    QWORD PTR [rbp-0xe78],r10
  442d6d:	mov    rdi,r12
  442d70:	mov    rsi,QWORD PTR [rbp-0xc50]
  442d77:	xor    eax,eax
  442d79:	call   461980 <p111_rt_keep>
  442d7e:	mov    QWORD PTR [rbp-0xc50],rax
  442d85:	mov    rdi,rax
  442d88:	lea    r10,[rbp-0x830]
  442d8f:	mov    r11,rdi
  442d92:	mov    QWORD PTR [r10],r11
  442d95:	lea    r10,[rbp-0x830]
  442d9c:	mov    r11,QWORD PTR [rbp-0xc58]
  442da3:	mov    QWORD PTR [r10+0x8],r11
  442da7:	mov    r10,r12
  442daa:	mov    r10,QWORD PTR [r10+0x8]
  442dae:	mov    QWORD PTR [rbp-0xe88],r10
  442db5:	mov    r10,QWORD PTR [r10+0x8]
  442db9:	mov    QWORD PTR [rbp-0xe90],r10
  442dc0:	cmp    r10,0x0
  442dc7:	je     442e68 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x14e2>
  442dcd:	mov    rdi,QWORD PTR [r12]
  442dd1:	mov    rsi,QWORD PTR [rbp-0xe90]
  442dd8:	shl    rsi,0x3
  442ddc:	mov    rdx,rdi
  442ddf:	add    rdx,rsi
  442de2:	mov    rdi,QWORD PTR [rdx]
  442de5:	mov    r10,QWORD PTR [rbp-0xe88]
  442dec:	mov    rsi,QWORD PTR [r10+0x108]
  442df3:	lea    r10,[rbp-0x830]
  442dfa:	mov    r8,QWORD PTR [r10]
  442dfd:	lea    r10,[rbp-0x830]
  442e04:	mov    r9,QWORD PTR [r10+0x8]
  442e08:	mov    r10,QWORD PTR [rbp-0xe88]
  442e0f:	mov    r11,rdi
  442e12:	mov    QWORD PTR [r10+0x8],r11
  442e16:	mov    rdi,rsi
  442e19:	sub    rdi,0x2
  442e20:	mov    r10,QWORD PTR [rbp-0xe88]
  442e27:	mov    r11,rdi
  442e2a:	mov    QWORD PTR [r10+0x108],r11
  442e31:	mov    QWORD PTR [rdx],r8
  442e34:	mov    QWORD PTR [rdx+0x8],r9
  442e38:	movabs rdi,0x2c
  442e42:	shl    rdi,0x28
  442e46:	movabs r11,0x200000000000000
  442e50:	mov    rsi,rdi
  442e53:	or     rsi,r11
  442e56:	mov    r11,QWORD PTR [rbp-0xe90]
  442e5d:	mov    rbx,rsi
  442e60:	or     rbx,r11
  442e63:	jmp    442e94 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x150e>
  442e68:	mov    rdi,r12
  442e6b:	movabs rsi,0x2c
  442e75:	mov    esi,esi
  442e77:	lea    rdx,[rbp-0x830]
  442e7e:	movabs rcx,0x2
  442e88:	mov    ecx,ecx
  442e8a:	xor    eax,eax
  442e8c:	call   461a80 <p111_rt_ctor>
  442e91:	mov    rbx,rax
  442e94:	mov    rdi,rbx
  442e97:	lea    r10,[rbp-0x830]
  442e9e:	mov    r11,QWORD PTR [rbp-0x8a8]
  442ea5:	mov    QWORD PTR [r10],r11
  442ea8:	lea    r10,[rbp-0x830]
  442eaf:	mov    r11,QWORD PTR [rbp-0xe78]
  442eb6:	mov    QWORD PTR [r10+0x8],r11
  442eba:	lea    r10,[rbp-0x830]
  442ec1:	mov    r11,rdi
  442ec4:	mov    QWORD PTR [r10+0x10],r11
  442ec8:	mov    r10,r12
  442ecb:	mov    r10,QWORD PTR [r10+0x8]
  442ecf:	mov    QWORD PTR [rbp-0xef8],r10
  442ed6:	mov    r10,QWORD PTR [r10+0x10]
  442eda:	mov    QWORD PTR [rbp-0xf00],r10
  442ee1:	cmp    r10,0x0
  442ee8:	je     442fa9 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1623>
  442eee:	mov    rdi,QWORD PTR [r12]
  442ef2:	mov    rsi,QWORD PTR [rbp-0xf00]
  442ef9:	shl    rsi,0x3
  442efd:	mov    rdx,rdi
  442f00:	add    rdx,rsi
  442f03:	mov    rdi,QWORD PTR [rdx]
  442f06:	mov    r10,QWORD PTR [rbp-0xef8]
  442f0d:	mov    rsi,QWORD PTR [r10+0x110]
  442f14:	lea    r10,[rbp-0x830]
  442f1b:	mov    r8,QWORD PTR [r10]
  442f1e:	lea    r10,[rbp-0x830]
  442f25:	mov    r9,QWORD PTR [r10+0x8]
  442f29:	lea    r10,[rbp-0x830]
  442f30:	mov    r10,QWORD PTR [r10+0x10]
  442f34:	mov    QWORD PTR [rbp-0xf48],r10
  442f3b:	mov    r10,QWORD PTR [rbp-0xef8]
  442f42:	mov    r11,rdi
  442f45:	mov    QWORD PTR [r10+0x10],r11
  442f49:	mov    rdi,rsi
  442f4c:	sub    rdi,0x4
  442f53:	mov    r10,QWORD PTR [rbp-0xef8]
  442f5a:	mov    r11,rdi
  442f5d:	mov    QWORD PTR [r10+0x110],r11
  442f64:	mov    QWORD PTR [rdx],r8
  442f67:	mov    QWORD PTR [rdx+0x8],r9
  442f6b:	mov    r10,rdx
  442f6e:	mov    r11,QWORD PTR [rbp-0xf48]
  442f75:	mov    QWORD PTR [r10+0x10],r11
  442f79:	movabs rdi,0x2d
  442f83:	shl    rdi,0x28
  442f87:	movabs r11,0x200000000000000
  442f91:	mov    rsi,rdi
  442f94:	or     rsi,r11
  442f97:	mov    r11,QWORD PTR [rbp-0xf00]
  442f9e:	mov    rbx,rsi
  442fa1:	or     rbx,r11
  442fa4:	jmp    442fd5 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x164f>
  442fa9:	mov    rdi,r12
  442fac:	movabs rsi,0x2d
  442fb6:	mov    esi,esi
  442fb8:	lea    rdx,[rbp-0x830]
  442fbf:	movabs rcx,0x3
  442fc9:	mov    ecx,ecx
  442fcb:	xor    eax,eax
  442fcd:	call   461a80 <p111_rt_ctor>
  442fd2:	mov    rbx,rax
  442fd5:	mov    r10,rbx
  442fd8:	mov    QWORD PTR [rbp-0xf68],r10
  442fdf:	mov    rdi,QWORD PTR [rbp-0xc50]
  442fe6:	lea    r10,[rbp-0x830]
  442fed:	mov    r11,rdi
  442ff0:	mov    QWORD PTR [r10],r11
  442ff3:	mov    r10,r12
  442ff6:	mov    r10,QWORD PTR [r10+0x8]
  442ffa:	mov    QWORD PTR [rbp-0xf78],r10
  443001:	mov    r10,QWORD PTR [r10]
  443004:	mov    QWORD PTR [rbp-0xf80],r10
  44300b:	cmp    r10,0x0
  443012:	je     4430a3 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x171d>
  443018:	mov    rdi,QWORD PTR [r12]
  44301c:	mov    rsi,QWORD PTR [rbp-0xf80]
  443023:	shl    rsi,0x3
  443027:	mov    rdx,rdi
  44302a:	add    rdx,rsi
  44302d:	mov    rdi,QWORD PTR [rdx]
  443030:	mov    r10,QWORD PTR [rbp-0xf78]
  443037:	mov    rsi,QWORD PTR [r10+0x100]
  44303e:	lea    r10,[rbp-0x830]
  443045:	mov    r8,QWORD PTR [r10]
  443048:	mov    r10,QWORD PTR [rbp-0xf78]
  44304f:	mov    r11,rdi
  443052:	mov    QWORD PTR [r10],r11
  443055:	mov    rdi,rsi
  443058:	sub    rdi,0x1
  44305f:	mov    r10,QWORD PTR [rbp-0xf78]
  443066:	mov    r11,rdi
  443069:	mov    QWORD PTR [r10+0x100],r11
  443070:	mov    QWORD PTR [rdx],r8
  443073:	movabs rdi,0xc
  44307d:	shl    rdi,0x28
  443081:	movabs r11,0x200000000000000
  44308b:	mov    rsi,rdi
  44308e:	or     rsi,r11
  443091:	mov    r11,QWORD PTR [rbp-0xf80]
  443098:	mov    rbx,rsi
  44309b:	or     rbx,r11
  44309e:	jmp    4430cf <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1749>
  4430a3:	mov    rdi,r12
  4430a6:	movabs rsi,0xc
  4430b0:	mov    esi,esi
  4430b2:	lea    rdx,[rbp-0x830]
  4430b9:	movabs rcx,0x1
  4430c3:	mov    ecx,ecx
  4430c5:	xor    eax,eax
  4430c7:	call   461a80 <p111_rt_ctor>
  4430cc:	mov    rbx,rax
  4430cf:	mov    rdi,rbx
  4430d2:	lea    r10,[rbp-0x830]
  4430d9:	mov    r11,QWORD PTR [rbp-0xc60]
  4430e0:	mov    QWORD PTR [r10],r11
  4430e3:	lea    r10,[rbp-0x830]
  4430ea:	mov    r11,rdi
  4430ed:	mov    QWORD PTR [r10+0x8],r11
  4430f1:	mov    r10,r12
  4430f4:	mov    r10,QWORD PTR [r10+0x8]
  4430f8:	mov    QWORD PTR [rbp-0xfe0],r10
  4430ff:	mov    r10,QWORD PTR [r10+0x8]
  443103:	mov    QWORD PTR [rbp-0xfe8],r10
  44310a:	cmp    r10,0x0
  443111:	je     4431b2 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x182c>
  443117:	mov    rdi,QWORD PTR [r12]
  44311b:	mov    rsi,QWORD PTR [rbp-0xfe8]
  443122:	shl    rsi,0x3
  443126:	mov    rdx,rdi
  443129:	add    rdx,rsi
  44312c:	mov    rdi,QWORD PTR [rdx]
  44312f:	mov    r10,QWORD PTR [rbp-0xfe0]
  443136:	mov    rsi,QWORD PTR [r10+0x108]
  44313d:	lea    r10,[rbp-0x830]
  443144:	mov    r8,QWORD PTR [r10]
  443147:	lea    r10,[rbp-0x830]
  44314e:	mov    r9,QWORD PTR [r10+0x8]
  443152:	mov    r10,QWORD PTR [rbp-0xfe0]
  443159:	mov    r11,rdi
  44315c:	mov    QWORD PTR [r10+0x8],r11
  443160:	mov    rdi,rsi
  443163:	sub    rdi,0x2
  44316a:	mov    r10,QWORD PTR [rbp-0xfe0]
  443171:	mov    r11,rdi
  443174:	mov    QWORD PTR [r10+0x108],r11
  44317b:	mov    QWORD PTR [rdx],r8
  44317e:	mov    QWORD PTR [rdx+0x8],r9
  443182:	movabs rdi,0x8
  44318c:	shl    rdi,0x28
  443190:	movabs r11,0x200000000000000
  44319a:	mov    rsi,rdi
  44319d:	or     rsi,r11
  4431a0:	mov    r11,QWORD PTR [rbp-0xfe8]
  4431a7:	mov    rbx,rsi
  4431aa:	or     rbx,r11
  4431ad:	jmp    4431de <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1858>
  4431b2:	mov    rdi,r12
  4431b5:	movabs rsi,0x8
  4431bf:	mov    esi,esi
  4431c1:	lea    rdx,[rbp-0x830]
  4431c8:	movabs rcx,0x2
  4431d2:	mov    ecx,ecx
  4431d4:	xor    eax,eax
  4431d6:	call   461a80 <p111_rt_ctor>
  4431db:	mov    rbx,rax
  4431de:	mov    rdi,rbx
  4431e1:	lea    r10,[rbp-0x830]
  4431e8:	mov    r11,QWORD PTR [rbp-0xf68]
  4431ef:	mov    QWORD PTR [r10],r11
  4431f2:	lea    r10,[rbp-0x830]
  4431f9:	mov    r11,rdi
  4431fc:	mov    QWORD PTR [r10+0x8],r11
  443200:	mov    r10,r12
  443203:	mov    r10,QWORD PTR [r10+0x8]
  443207:	mov    QWORD PTR [rbp-0x1050],r10
  44320e:	mov    r10,QWORD PTR [r10+0x8]
  443212:	mov    QWORD PTR [rbp-0x1058],r10
  443219:	cmp    r10,0x0
  443220:	je     4432c1 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x193b>
  443226:	mov    rdi,QWORD PTR [r12]
  44322a:	mov    rsi,QWORD PTR [rbp-0x1058]
  443231:	shl    rsi,0x3
  443235:	mov    rdx,rdi
  443238:	add    rdx,rsi
  44323b:	mov    rdi,QWORD PTR [rdx]
  44323e:	mov    r10,QWORD PTR [rbp-0x1050]
  443245:	mov    rsi,QWORD PTR [r10+0x108]
  44324c:	lea    r10,[rbp-0x830]
  443253:	mov    r8,QWORD PTR [r10]
  443256:	lea    r10,[rbp-0x830]
  44325d:	mov    r9,QWORD PTR [r10+0x8]
  443261:	mov    r10,QWORD PTR [rbp-0x1050]
  443268:	mov    r11,rdi
  44326b:	mov    QWORD PTR [r10+0x8],r11
  44326f:	mov    rdi,rsi
  443272:	sub    rdi,0x2
  443279:	mov    r10,QWORD PTR [rbp-0x1050]
  443280:	mov    r11,rdi
  443283:	mov    QWORD PTR [r10+0x108],r11
  44328a:	mov    QWORD PTR [rdx],r8
  44328d:	mov    QWORD PTR [rdx+0x8],r9
  443291:	movabs rdi,0x8
  44329b:	shl    rdi,0x28
  44329f:	movabs r11,0x200000000000000
  4432a9:	mov    rsi,rdi
  4432ac:	or     rsi,r11
  4432af:	mov    r11,QWORD PTR [rbp-0x1058]
  4432b6:	mov    rbx,rsi
  4432b9:	or     rbx,r11
  4432bc:	jmp    4432ed <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1967>
  4432c1:	mov    rdi,r12
  4432c4:	movabs rsi,0x8
  4432ce:	mov    esi,esi
  4432d0:	lea    rdx,[rbp-0x830]
  4432d7:	movabs rcx,0x2
  4432e1:	mov    ecx,ecx
  4432e3:	xor    eax,eax
  4432e5:	call   461a80 <p111_rt_ctor>
  4432ea:	mov    rbx,rax
  4432ed:	lea    r10,[rbp-0x830]
  4432f4:	mov    r11,rbx
  4432f7:	mov    QWORD PTR [r10],r11
  4432fa:	lea    r10,[rip+0x2d8df]        # 470be0 <p111_program>
  443301:	movabs rdi,0x4
  44330b:	and    rdi,QWORD PTR [r10+0x58]
  44330f:	mov    r10,rdi
  443312:	test   r10d,r10d
  443315:	je     443373 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x19ed>
  44331b:	lea    r10,[rbp-0x830]
  443322:	mov    rdi,QWORD PTR [r10]
  443325:	mov    QWORD PTR [r12+0x28],rdi
  44332a:	mov    r10,r12
  44332d:	movabs r11,0x1
  443337:	mov    DWORD PTR [r10+0x1c],r11d
  44333b:	mov    rdi,QWORD PTR [r12+0x10]
  443340:	movabs r11,0xfffffffffffffff8
  44334a:	mov    rsi,rdi
  44334d:	add    rsi,r11
  443350:	mov    QWORD PTR [r12+0x10],rsi
  443355:	mov    rdi,QWORD PTR [rsi]
  443358:	mov    DWORD PTR [r12+0x20],edi
  44335d:	movabs r10,0x0
  443367:	mov    QWORD PTR [rbp-0xa90],r10
  44336e:	jmp    443397 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1a11>
  443373:	mov    rdi,r12
  443376:	lea    rsi,[rbp-0x830]
  44337d:	movabs rdx,0x1
  443387:	mov    edx,edx
  443389:	xor    eax,eax
  44338b:	call   462030 <p111_rt_return>
  443390:	mov    QWORD PTR [rbp-0xa90],rax
  443397:	mov    rax,QWORD PTR [rbp-0xa90]
  44339e:	mov    r12,QWORD PTR [rbp-0x10]
  4433a2:	mov    rbx,QWORD PTR [rbp-0x8]
  4433a6:	mov    r13,QWORD PTR [rbp-0x18]
  4433aa:	mov    r14,QWORD PTR [rbp-0x20]
  4433ae:	mov    r15,QWORD PTR [rbp-0x28]
  4433b2:	mov    rsp,rbp
  4433b5:	pop    rbp
  4433b6:	ret    
  4433b7:	mov    rdi,r12
  4433ba:	mov    rsi,QWORD PTR [rbp-0x8a8]
  4433c1:	xor    eax,eax
  4433c3:	call   461a10 <p111_rt_sink>
  4433c8:	mov    QWORD PTR [rbp-0x8a0],rax
  4433cf:	mov    rdi,r12
  4433d2:	mov    rsi,QWORD PTR [rbp-0xc50]
  4433d9:	xor    eax,eax
  4433db:	call   461a10 <p111_rt_sink>
  4433e0:	mov    QWORD PTR [rbp-0x8a0],rax
  4433e7:	mov    rdi,r12
  4433ea:	mov    rsi,QWORD PTR [rbp-0xc58]
  4433f1:	xor    eax,eax
  4433f3:	call   461a10 <p111_rt_sink>
  4433f8:	mov    QWORD PTR [rbp-0x8a0],rax
  4433ff:	mov    rdi,r12
  443402:	mov    rsi,QWORD PTR [rbp-0xc60]
  443409:	xor    eax,eax
  44340b:	call   461a10 <p111_rt_sink>
  443410:	mov    QWORD PTR [rbp-0x8a0],rax
  443417:	lea    r10,[rbp-0x830]
  44341e:	mov    r11,QWORD PTR [rbp-0xc68]
  443425:	mov    QWORD PTR [r10],r11
  443428:	mov    rdi,QWORD PTR [r12+0x10]
  44342d:	mov    r10,rdi
  443430:	mov    r11,QWORD PTR [rbp-0xc68]
  443437:	mov    QWORD PTR [r10],r11
  44343a:	mov    r10,rdi
  44343d:	movabs r11,0x154
  443447:	mov    QWORD PTR [r10+0x8],r11
  44344b:	mov    rsi,rdi
  44344e:	add    rsi,0x10
  443455:	mov    QWORD PTR [r12+0x10],rsi
  44345a:	mov    rdi,r12
  44345d:	movabs rsi,0x4
  443467:	mov    esi,esi
  443469:	xor    eax,eax
  44346b:	call   4621a0 <p111_rt_fail>
  443470:	mov    QWORD PTR [rbp-0xa90],rax
  443477:	mov    r12,QWORD PTR [rbp-0x10]
  44347b:	mov    rbx,QWORD PTR [rbp-0x8]
  44347f:	mov    r13,QWORD PTR [rbp-0x18]
  443483:	mov    r14,QWORD PTR [rbp-0x20]
  443487:	mov    r15,QWORD PTR [rbp-0x28]
  44348b:	mov    rsp,rbp
  44348e:	pop    rbp
  44348f:	ret    
  443490:	mov    rdi,r12
  443493:	mov    rsi,QWORD PTR [rbp-0x8a8]
  44349a:	xor    eax,eax
  44349c:	call   461a10 <p111_rt_sink>
  4434a1:	mov    QWORD PTR [rbp-0x8a0],rax
  4434a8:	mov    rdi,r12
  4434ab:	mov    rsi,QWORD PTR [rbp-0xc50]
  4434b2:	xor    eax,eax
  4434b4:	call   461a10 <p111_rt_sink>
  4434b9:	mov    QWORD PTR [rbp-0x8a0],rax
  4434c0:	mov    rdi,r12
  4434c3:	mov    rsi,QWORD PTR [rbp-0xc58]
  4434ca:	xor    eax,eax
  4434cc:	call   461a10 <p111_rt_sink>
  4434d1:	mov    QWORD PTR [rbp-0x8a0],rax
  4434d8:	lea    r10,[rbp-0x830]
  4434df:	mov    r11,r14
  4434e2:	mov    QWORD PTR [r10],r11
  4434e5:	mov    rdi,QWORD PTR [r12+0x10]
  4434ea:	mov    QWORD PTR [rdi],r14
  4434ed:	mov    r10,rdi
  4434f0:	movabs r11,0x155
  4434fa:	mov    QWORD PTR [r10+0x8],r11
  4434fe:	mov    rsi,rdi
  443501:	add    rsi,0x10
  443508:	mov    QWORD PTR [r12+0x10],rsi
  44350d:	mov    rdi,r12
  443510:	movabs rsi,0x4
  44351a:	mov    esi,esi
  44351c:	xor    eax,eax
  44351e:	call   4621a0 <p111_rt_fail>
  443523:	mov    QWORD PTR [rbp-0xa90],rax
  44352a:	mov    r12,QWORD PTR [rbp-0x10]
  44352e:	mov    rbx,QWORD PTR [rbp-0x8]
  443532:	mov    r13,QWORD PTR [rbp-0x18]
  443536:	mov    r14,QWORD PTR [rbp-0x20]
  44353a:	mov    r15,QWORD PTR [rbp-0x28]
  44353e:	mov    rsp,rbp
  443541:	pop    rbp
  443542:	ret    
  443543:	mov    r15,QWORD PTR [rbp-0x8b8]
  44354a:	shr    r15,0x28
  44354e:	and    r15,0xffff
  443555:	movabs r11,0x2d
  44355f:	mov    r13,r15
  443562:	cmp    r13,r11
  443565:	sete   r13b
  443569:	movzx  r13d,r13b
  44356d:	mov    r10,r13
  443570:	test   r10d,r10d
  443573:	je     444187 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x2801>
  443579:	mov    rdi,r12
  44357c:	mov    rsi,QWORD PTR [rbp-0x8b8]
  443583:	lea    rdx,[rbp-0x830]
  44358a:	xor    eax,eax
  44358c:	call   467a10 <p125_rt_take3>
  443591:	mov    QWORD PTR [rbp-0x8a0],rax
  443598:	lea    r10,[rbp-0x830]
  44359f:	mov    r10,QWORD PTR [r10]
  4435a2:	mov    QWORD PTR [rbp-0x1108],r10
  4435a9:	lea    r10,[rbp-0x830]
  4435b0:	mov    r10,QWORD PTR [r10+0x8]
  4435b4:	mov    QWORD PTR [rbp-0x1110],r10
  4435bb:	lea    r10,[rbp-0x830]
  4435c2:	mov    r10,QWORD PTR [r10+0x10]
  4435c6:	mov    QWORD PTR [rbp-0x1118],r10
  4435cd:	mov    r15,r14
  4435d0:	shr    r15,0x28
  4435d4:	and    r15,0xffff
  4435db:	movabs r11,0x8
  4435e5:	mov    r13,r15
  4435e8:	cmp    r13,r11
  4435eb:	sete   r13b
  4435ef:	movzx  r13d,r13b
  4435f3:	mov    r10,r13
  4435f6:	test   r10d,r10d
  4435f9:	je     4440bc <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x2736>
  4435ff:	mov    rdi,r12
  443602:	mov    rsi,r14
  443605:	lea    rdx,[rbp-0x830]
  44360c:	xor    eax,eax
  44360e:	call   4677b0 <p125_rt_take2>
  443613:	mov    QWORD PTR [rbp-0x8a0],rax
  44361a:	lea    r10,[rbp-0x830]
  443621:	mov    r10,QWORD PTR [r10]
  443624:	mov    QWORD PTR [rbp-0x1120],r10
  44362b:	lea    r10,[rbp-0x830]
  443632:	mov    r10,QWORD PTR [r10+0x8]
  443636:	mov    QWORD PTR [rbp-0x1128],r10
  44363d:	cmp    r10,0x1
  443644:	sete   r10b
  443648:	movzx  r10d,r10b
  44364c:	mov    QWORD PTR [rbp-0x8d0],r10
  443653:	mov    r10,QWORD PTR [rbp-0x1128]
  44365a:	shr    r10,0x28
  44365e:	mov    QWORD PTR [rbp-0x8d8],r10
  443665:	and    r10,0x7fffff
  44366c:	mov    QWORD PTR [rbp-0x8d8],r10
  443673:	movabs r10,0x2
  44367d:	or     r10,0x10000
  443684:	mov    QWORD PTR [rbp-0x8e0],r10
  44368b:	mov    r10,QWORD PTR [rbp-0x8d8]
  443692:	mov    r11,QWORD PTR [rbp-0x8e0]
  443699:	cmp    r10,r11
  44369c:	sete   r10b
  4436a0:	movzx  r10d,r10b
  4436a4:	mov    QWORD PTR [rbp-0x8e8],r10
  4436ab:	mov    r11,r10
  4436ae:	mov    r13,QWORD PTR [rbp-0x8d0]
  4436b5:	or     r13d,r11d
  4436b8:	xor    r13d,0x1
  4436bf:	mov    r10,r13
  4436c2:	test   r10d,r10d
  4436c5:	je     443c5b <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x22d5>
  4436cb:	movabs r10,0x1002b0000000000
  4436d5:	mov    QWORD PTR [rbp-0x1130],r10
  4436dc:	mov    rdi,QWORD PTR [rbp-0x1108]
  4436e3:	lea    r10,[rbp-0x830]
  4436ea:	mov    r11,rdi
  4436ed:	mov    QWORD PTR [r10],r11
  4436f0:	lea    r10,[rbp-0x830]
  4436f7:	mov    r11,QWORD PTR [rbp-0x1110]
  4436fe:	mov    QWORD PTR [r10+0x8],r11
  443702:	lea    r10,[rbp-0x830]
  443709:	mov    r11,QWORD PTR [rbp-0x1118]
  443710:	mov    QWORD PTR [r10+0x10],r11
  443714:	mov    r10,r12
  443717:	mov    r10,QWORD PTR [r10+0x8]
  44371b:	mov    QWORD PTR [rbp-0x1140],r10
  443722:	mov    r10,QWORD PTR [r10+0x10]
  443726:	mov    QWORD PTR [rbp-0x1148],r10
  44372d:	cmp    r10,0x0
  443734:	je     4437f5 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1e6f>
  44373a:	mov    rdi,QWORD PTR [r12]
  44373e:	mov    rsi,QWORD PTR [rbp-0x1148]
  443745:	shl    rsi,0x3
  443749:	mov    rdx,rdi
  44374c:	add    rdx,rsi
  44374f:	mov    rdi,QWORD PTR [rdx]
  443752:	mov    r10,QWORD PTR [rbp-0x1140]
  443759:	mov    rsi,QWORD PTR [r10+0x110]
  443760:	lea    r10,[rbp-0x830]
  443767:	mov    r8,QWORD PTR [r10]
  44376a:	lea    r10,[rbp-0x830]
  443771:	mov    r9,QWORD PTR [r10+0x8]
  443775:	lea    r10,[rbp-0x830]
  44377c:	mov    r10,QWORD PTR [r10+0x10]
  443780:	mov    QWORD PTR [rbp-0x1190],r10
  443787:	mov    r10,QWORD PTR [rbp-0x1140]
  44378e:	mov    r11,rdi
  443791:	mov    QWORD PTR [r10+0x10],r11
  443795:	mov    rdi,rsi
  443798:	sub    rdi,0x4
  44379f:	mov    r10,QWORD PTR [rbp-0x1140]
  4437a6:	mov    r11,rdi
  4437a9:	mov    QWORD PTR [r10+0x110],r11
  4437b0:	mov    QWORD PTR [rdx],r8
  4437b3:	mov    QWORD PTR [rdx+0x8],r9
  4437b7:	mov    r10,rdx
  4437ba:	mov    r11,QWORD PTR [rbp-0x1190]
  4437c1:	mov    QWORD PTR [r10+0x10],r11
  4437c5:	movabs rdi,0x2d
  4437cf:	shl    rdi,0x28
  4437d3:	movabs r11,0x200000000000000
  4437dd:	mov    rsi,rdi
  4437e0:	or     rsi,r11
  4437e3:	mov    r11,QWORD PTR [rbp-0x1148]
  4437ea:	mov    rbx,rsi
  4437ed:	or     rbx,r11
  4437f0:	jmp    443821 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1e9b>
  4437f5:	mov    rdi,r12
  4437f8:	movabs rsi,0x2d
  443802:	mov    esi,esi
  443804:	lea    rdx,[rbp-0x830]
  44380b:	movabs rcx,0x3
  443815:	mov    ecx,ecx
  443817:	xor    eax,eax
  443819:	call   461a80 <p111_rt_ctor>
  44381e:	mov    rbx,rax
  443821:	mov    rdi,rbx
  443824:	lea    r10,[rbp-0x830]
  44382b:	mov    r11,QWORD PTR [rbp-0x8a8]
  443832:	mov    QWORD PTR [r10],r11
  443835:	lea    r10,[rbp-0x830]
  44383c:	mov    r11,QWORD PTR [rbp-0x1130]
  443843:	mov    QWORD PTR [r10+0x8],r11
  443847:	lea    r10,[rbp-0x830]
  44384e:	mov    r11,rdi
  443851:	mov    QWORD PTR [r10+0x10],r11
  443855:	mov    r10,r12
  443858:	mov    r10,QWORD PTR [r10+0x8]
  44385c:	mov    QWORD PTR [rbp-0x11b8],r10
  443863:	mov    r10,QWORD PTR [r10+0x10]
  443867:	mov    QWORD PTR [rbp-0x11c0],r10
  44386e:	cmp    r10,0x0
  443875:	je     443936 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1fb0>
  44387b:	mov    rdi,QWORD PTR [r12]
  44387f:	mov    rsi,QWORD PTR [rbp-0x11c0]
  443886:	shl    rsi,0x3
  44388a:	mov    rdx,rdi
  44388d:	add    rdx,rsi
  443890:	mov    rdi,QWORD PTR [rdx]
  443893:	mov    r10,QWORD PTR [rbp-0x11b8]
  44389a:	mov    rsi,QWORD PTR [r10+0x110]
  4438a1:	lea    r10,[rbp-0x830]
  4438a8:	mov    r8,QWORD PTR [r10]
  4438ab:	lea    r10,[rbp-0x830]
  4438b2:	mov    r9,QWORD PTR [r10+0x8]
  4438b6:	lea    r10,[rbp-0x830]
  4438bd:	mov    r10,QWORD PTR [r10+0x10]
  4438c1:	mov    QWORD PTR [rbp-0x1208],r10
  4438c8:	mov    r10,QWORD PTR [rbp-0x11b8]
  4438cf:	mov    r11,rdi
  4438d2:	mov    QWORD PTR [r10+0x10],r11
  4438d6:	mov    rdi,rsi
  4438d9:	sub    rdi,0x4
  4438e0:	mov    r10,QWORD PTR [rbp-0x11b8]
  4438e7:	mov    r11,rdi
  4438ea:	mov    QWORD PTR [r10+0x110],r11
  4438f1:	mov    QWORD PTR [rdx],r8
  4438f4:	mov    QWORD PTR [rdx+0x8],r9
  4438f8:	mov    r10,rdx
  4438fb:	mov    r11,QWORD PTR [rbp-0x1208]
  443902:	mov    QWORD PTR [r10+0x10],r11
  443906:	movabs rdi,0x2d
  443910:	shl    rdi,0x28
  443914:	movabs r11,0x200000000000000
  44391e:	mov    rsi,rdi
  443921:	or     rsi,r11
  443924:	mov    r11,QWORD PTR [rbp-0x11c0]
  44392b:	mov    rbx,rsi
  44392e:	or     rbx,r11
  443931:	jmp    443962 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x1fdc>
  443936:	mov    rdi,r12
  443939:	movabs rsi,0x2d
  443943:	mov    esi,esi
  443945:	lea    rdx,[rbp-0x830]
  44394c:	movabs rcx,0x3
  443956:	mov    ecx,ecx
  443958:	xor    eax,eax
  44395a:	call   461a80 <p111_rt_ctor>
  44395f:	mov    rbx,rax
  443962:	mov    r10,rbx
  443965:	mov    QWORD PTR [rbp-0x1228],r10
  44396c:	movabs rdi,0x1000b0000000000
  443976:	lea    r10,[rbp-0x830]
  44397d:	mov    r11,QWORD PTR [rbp-0x1120]
  443984:	mov    QWORD PTR [r10],r11
  443987:	lea    r10,[rbp-0x830]
  44398e:	mov    r11,rdi
  443991:	mov    QWORD PTR [r10+0x8],r11
  443995:	mov    r10,r12
  443998:	mov    r10,QWORD PTR [r10+0x8]
  44399c:	mov    QWORD PTR [rbp-0x1238],r10
  4439a3:	mov    r10,QWORD PTR [r10+0x8]
  4439a7:	mov    QWORD PTR [rbp-0x1240],r10
  4439ae:	cmp    r10,0x0
  4439b5:	je     443a56 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x20d0>
  4439bb:	mov    rdi,QWORD PTR [r12]
  4439bf:	mov    rsi,QWORD PTR [rbp-0x1240]
  4439c6:	shl    rsi,0x3
  4439ca:	mov    rdx,rdi
  4439cd:	add    rdx,rsi
  4439d0:	mov    rdi,QWORD PTR [rdx]
  4439d3:	mov    r10,QWORD PTR [rbp-0x1238]
  4439da:	mov    rsi,QWORD PTR [r10+0x108]
  4439e1:	lea    r10,[rbp-0x830]
  4439e8:	mov    r8,QWORD PTR [r10]
  4439eb:	lea    r10,[rbp-0x830]
  4439f2:	mov    r9,QWORD PTR [r10+0x8]
  4439f6:	mov    r10,QWORD PTR [rbp-0x1238]
  4439fd:	mov    r11,rdi
  443a00:	mov    QWORD PTR [r10+0x8],r11
  443a04:	mov    rdi,rsi
  443a07:	sub    rdi,0x2
  443a0e:	mov    r10,QWORD PTR [rbp-0x1238]
  443a15:	mov    r11,rdi
  443a18:	mov    QWORD PTR [r10+0x108],r11
  443a1f:	mov    QWORD PTR [rdx],r8
  443a22:	mov    QWORD PTR [rdx+0x8],r9
  443a26:	movabs rdi,0x8
  443a30:	shl    rdi,0x28
  443a34:	movabs r11,0x200000000000000
  443a3e:	mov    rsi,rdi
  443a41:	or     rsi,r11
  443a44:	mov    r11,QWORD PTR [rbp-0x1240]
  443a4b:	mov    rbx,rsi
  443a4e:	or     rbx,r11
  443a51:	jmp    443a82 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x20fc>
  443a56:	mov    rdi,r12
  443a59:	movabs rsi,0x8
  443a63:	mov    esi,esi
  443a65:	lea    rdx,[rbp-0x830]
  443a6c:	movabs rcx,0x2
  443a76:	mov    ecx,ecx
  443a78:	xor    eax,eax
  443a7a:	call   461a80 <p111_rt_ctor>
  443a7f:	mov    rbx,rax
  443a82:	mov    rdi,rbx
  443a85:	lea    r10,[rbp-0x830]
  443a8c:	mov    r11,QWORD PTR [rbp-0x1228]
  443a93:	mov    QWORD PTR [r10],r11
  443a96:	lea    r10,[rbp-0x830]
  443a9d:	mov    r11,rdi
  443aa0:	mov    QWORD PTR [r10+0x8],r11
  443aa4:	mov    r10,r12
  443aa7:	mov    r10,QWORD PTR [r10+0x8]
  443aab:	mov    QWORD PTR [rbp-0x12a8],r10
  443ab2:	mov    r10,QWORD PTR [r10+0x8]
  443ab6:	mov    QWORD PTR [rbp-0x12b0],r10
  443abd:	cmp    r10,0x0
  443ac4:	je     443b65 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x21df>
  443aca:	mov    rdi,QWORD PTR [r12]
  443ace:	mov    rsi,QWORD PTR [rbp-0x12b0]
  443ad5:	shl    rsi,0x3
  443ad9:	mov    rdx,rdi
  443adc:	add    rdx,rsi
  443adf:	mov    rdi,QWORD PTR [rdx]
  443ae2:	mov    r10,QWORD PTR [rbp-0x12a8]
  443ae9:	mov    rsi,QWORD PTR [r10+0x108]
  443af0:	lea    r10,[rbp-0x830]
  443af7:	mov    r8,QWORD PTR [r10]
  443afa:	lea    r10,[rbp-0x830]
  443b01:	mov    r9,QWORD PTR [r10+0x8]
  443b05:	mov    r10,QWORD PTR [rbp-0x12a8]
  443b0c:	mov    r11,rdi
  443b0f:	mov    QWORD PTR [r10+0x8],r11
  443b13:	mov    rdi,rsi
  443b16:	sub    rdi,0x2
  443b1d:	mov    r10,QWORD PTR [rbp-0x12a8]
  443b24:	mov    r11,rdi
  443b27:	mov    QWORD PTR [r10+0x108],r11
  443b2e:	mov    QWORD PTR [rdx],r8
  443b31:	mov    QWORD PTR [rdx+0x8],r9
  443b35:	movabs rdi,0x8
  443b3f:	shl    rdi,0x28
  443b43:	movabs r11,0x200000000000000
  443b4d:	mov    rsi,rdi
  443b50:	or     rsi,r11
  443b53:	mov    r11,QWORD PTR [rbp-0x12b0]
  443b5a:	mov    rbx,rsi
  443b5d:	or     rbx,r11
  443b60:	jmp    443b91 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x220b>
  443b65:	mov    rdi,r12
  443b68:	movabs rsi,0x8
  443b72:	mov    esi,esi
  443b74:	lea    rdx,[rbp-0x830]
  443b7b:	movabs rcx,0x2
  443b85:	mov    ecx,ecx
  443b87:	xor    eax,eax
  443b89:	call   461a80 <p111_rt_ctor>
  443b8e:	mov    rbx,rax
  443b91:	lea    r10,[rbp-0x830]
  443b98:	mov    r11,rbx
  443b9b:	mov    QWORD PTR [r10],r11
  443b9e:	lea    r10,[rip+0x2d03b]        # 470be0 <p111_program>
  443ba5:	movabs rdi,0x4
  443baf:	and    rdi,QWORD PTR [r10+0x58]
  443bb3:	mov    r10,rdi
  443bb6:	test   r10d,r10d
  443bb9:	je     443c17 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x2291>
  443bbf:	lea    r10,[rbp-0x830]
  443bc6:	mov    rdi,QWORD PTR [r10]
  443bc9:	mov    QWORD PTR [r12+0x28],rdi
  443bce:	mov    r10,r12
  443bd1:	movabs r11,0x1
  443bdb:	mov    DWORD PTR [r10+0x1c],r11d
  443bdf:	mov    rdi,QWORD PTR [r12+0x10]
  443be4:	movabs r11,0xfffffffffffffff8
  443bee:	mov    rsi,rdi
  443bf1:	add    rsi,r11
  443bf4:	mov    QWORD PTR [r12+0x10],rsi
  443bf9:	mov    rdi,QWORD PTR [rsi]
  443bfc:	mov    DWORD PTR [r12+0x20],edi
  443c01:	movabs r10,0x0
  443c0b:	mov    QWORD PTR [rbp-0xa90],r10
  443c12:	jmp    443c3b <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x22b5>
  443c17:	mov    rdi,r12
  443c1a:	lea    rsi,[rbp-0x830]
  443c21:	movabs rdx,0x1
  443c2b:	mov    edx,edx
  443c2d:	xor    eax,eax
  443c2f:	call   462030 <p111_rt_return>
  443c34:	mov    QWORD PTR [rbp-0xa90],rax
  443c3b:	mov    rax,QWORD PTR [rbp-0xa90]
  443c42:	mov    r12,QWORD PTR [rbp-0x10]
  443c46:	mov    rbx,QWORD PTR [rbp-0x8]
  443c4a:	mov    r13,QWORD PTR [rbp-0x18]
  443c4e:	mov    r14,QWORD PTR [rbp-0x20]
  443c52:	mov    r15,QWORD PTR [rbp-0x28]
  443c56:	mov    rsp,rbp
  443c59:	pop    rbp
  443c5a:	ret    
  443c5b:	mov    r10,QWORD PTR [rbp-0x1128]
  443c62:	cmp    r10,0x1
  443c69:	sete   r10b
  443c6d:	movzx  r10d,r10b
  443c71:	mov    QWORD PTR [rbp-0x8d0],r10
  443c78:	mov    r10,QWORD PTR [rbp-0x1128]
  443c7f:	shr    r10,0x28
  443c83:	mov    QWORD PTR [rbp-0x8d8],r10
  443c8a:	and    r10,0x7fffff
  443c91:	mov    QWORD PTR [rbp-0x8d8],r10
  443c98:	movabs r10,0x2
  443ca2:	or     r10,0x10000
  443ca9:	mov    QWORD PTR [rbp-0x8e0],r10
  443cb0:	mov    r10,QWORD PTR [rbp-0x8d8]
  443cb7:	mov    r11,QWORD PTR [rbp-0x8e0]
  443cbe:	cmp    r10,r11
  443cc1:	sete   r10b
  443cc5:	movzx  r10d,r10b
  443cc9:	mov    QWORD PTR [rbp-0x8e8],r10
  443cd0:	mov    r11,r10
  443cd3:	mov    r13,QWORD PTR [rbp-0x8d0]
  443cda:	or     r13d,r11d
  443cdd:	mov    r10,r13
  443ce0:	test   r10d,r10d
  443ce3:	je     443fcb <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x2645>
  443ce9:	movabs rdi,0x1002b0000000000
  443cf3:	lea    r10,[rbp-0x830]
  443cfa:	mov    r11,QWORD PTR [rbp-0x8a8]
  443d01:	mov    QWORD PTR [r10],r11
  443d04:	lea    r10,[rbp-0x830]
  443d0b:	mov    r11,rdi
  443d0e:	mov    QWORD PTR [r10+0x8],r11
  443d12:	mov    rdi,QWORD PTR [r12+0x10]
  443d17:	mov    rsi,QWORD PTR [rbp-0x8a8]
  443d1e:	mov    QWORD PTR [rdi],rsi
  443d21:	lea    r10,[rbp-0x830]
  443d28:	mov    rsi,QWORD PTR [r10+0x8]
  443d2c:	mov    QWORD PTR [rdi+0x8],rsi
  443d30:	mov    r10,rdi
  443d33:	movabs r11,0x156
  443d3d:	mov    QWORD PTR [r10+0x10],r11
  443d41:	mov    rsi,rdi
  443d44:	add    rsi,0x18
  443d4b:	mov    QWORD PTR [r12+0x10],rsi
  443d50:	mov    rdi,r12
  443d53:	mov    rsi,QWORD PTR [rbp-0x1108]
  443d5a:	xor    eax,eax
  443d5c:	call   461980 <p111_rt_keep>
  443d61:	mov    QWORD PTR [rbp-0x1108],rax
  443d68:	mov    rdi,rax
  443d6b:	lea    r10,[rbp-0x830]
  443d72:	mov    r11,rdi
  443d75:	mov    QWORD PTR [r10],r11
  443d78:	lea    r10,[rbp-0x830]
  443d7f:	mov    r11,QWORD PTR [rbp-0x1110]
  443d86:	mov    QWORD PTR [r10+0x8],r11
  443d8a:	lea    r10,[rbp-0x830]
  443d91:	mov    r11,QWORD PTR [rbp-0x1118]
  443d98:	mov    QWORD PTR [r10+0x10],r11
  443d9c:	mov    r10,r12
  443d9f:	mov    r10,QWORD PTR [r10+0x8]
  443da3:	mov    QWORD PTR [rbp-0x1368],r10
  443daa:	mov    r10,QWORD PTR [r10+0x10]
  443dae:	mov    QWORD PTR [rbp-0x1370],r10
  443db5:	cmp    r10,0x0
  443dbc:	je     443e7d <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x24f7>
  443dc2:	mov    rdi,QWORD PTR [r12]
  443dc6:	mov    rsi,QWORD PTR [rbp-0x1370]
  443dcd:	shl    rsi,0x3
  443dd1:	mov    rdx,rdi
  443dd4:	add    rdx,rsi
  443dd7:	mov    rdi,QWORD PTR [rdx]
  443dda:	mov    r10,QWORD PTR [rbp-0x1368]
  443de1:	mov    rsi,QWORD PTR [r10+0x110]
  443de8:	lea    r10,[rbp-0x830]
  443def:	mov    r8,QWORD PTR [r10]
  443df2:	lea    r10,[rbp-0x830]
  443df9:	mov    r9,QWORD PTR [r10+0x8]
  443dfd:	lea    r10,[rbp-0x830]
  443e04:	mov    r10,QWORD PTR [r10+0x10]
  443e08:	mov    QWORD PTR [rbp-0x13b8],r10
  443e0f:	mov    r10,QWORD PTR [rbp-0x1368]
  443e16:	mov    r11,rdi
  443e19:	mov    QWORD PTR [r10+0x10],r11
  443e1d:	mov    rdi,rsi
  443e20:	sub    rdi,0x4
  443e27:	mov    r10,QWORD PTR [rbp-0x1368]
  443e2e:	mov    r11,rdi
  443e31:	mov    QWORD PTR [r10+0x110],r11
  443e38:	mov    QWORD PTR [rdx],r8
  443e3b:	mov    QWORD PTR [rdx+0x8],r9
  443e3f:	mov    r10,rdx
  443e42:	mov    r11,QWORD PTR [rbp-0x13b8]
  443e49:	mov    QWORD PTR [r10+0x10],r11
  443e4d:	movabs rdi,0x2d
  443e57:	shl    rdi,0x28
  443e5b:	movabs r11,0x200000000000000
  443e65:	mov    rsi,rdi
  443e68:	or     rsi,r11
  443e6b:	mov    r11,QWORD PTR [rbp-0x1370]
  443e72:	mov    rbx,rsi
  443e75:	or     rbx,r11
  443e78:	jmp    443ea9 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x2523>
  443e7d:	mov    rdi,r12
  443e80:	movabs rsi,0x2d
  443e8a:	mov    esi,esi
  443e8c:	lea    rdx,[rbp-0x830]
  443e93:	movabs rcx,0x3
  443e9d:	mov    ecx,ecx
  443e9f:	xor    eax,eax
  443ea1:	call   461a80 <p111_rt_ctor>
  443ea6:	mov    rbx,rax
  443ea9:	mov    r10,rbx
  443eac:	mov    QWORD PTR [rbp-0x13d8],r10
  443eb3:	mov    r10,QWORD PTR [rbp-0x1108]
  443eba:	mov    QWORD PTR [rbp-0x13e0],r10
  443ec1:	mov    rdi,r12
  443ec4:	mov    rsi,QWORD PTR [rbp-0x1120]
  443ecb:	mov    rdx,QWORD PTR [rbp-0x13e0]
  443ed2:	xor    eax,eax
  443ed4:	call   40eddf <p112w_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_>
  443ed9:	mov    QWORD PTR [rbp-0x13e8],rax
  443ee0:	lea    r10,[rbp-0x1be8]
  443ee7:	mov    r11,QWORD PTR [rbp-0x13d8]
  443eee:	mov    QWORD PTR [r10],r11
  443ef1:	lea    r10,[rbp-0x1be8]
  443ef8:	mov    r11,QWORD PTR [rbp-0x13e8]
  443eff:	mov    QWORD PTR [r10+0x8],r11
  443f03:	lea    r10,[rip+0x2ccd6]        # 470be0 <p111_program>
  443f0a:	movabs rdi,0x4
  443f14:	and    rdi,QWORD PTR [r10+0x58]
  443f18:	mov    r10,rdi
  443f1b:	test   r10d,r10d
  443f1e:	je     443f7b <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x25f5>
  443f24:	lea    r10,[rbp-0x1be8]
  443f2b:	mov    rdi,QWORD PTR [r10]
  443f2e:	lea    r10,[rbp-0x1be8]
  443f35:	mov    rsi,QWORD PTR [r10+0x8]
  443f39:	mov    QWORD PTR [r12+0x28],rdi
  443f3e:	mov    QWORD PTR [r12+0x30],rsi
  443f43:	mov    r10,r12
  443f46:	movabs r11,0x0
  443f50:	mov    DWORD PTR [r10+0x1c],r11d
  443f54:	mov    r10,r12
  443f57:	movabs r11,0x151
  443f61:	mov    DWORD PTR [r10+0x20],r11d
  443f65:	movabs r10,0x0
  443f6f:	mov    QWORD PTR [rbp-0x1c10],r10
  443f76:	jmp    443fab <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x2625>
  443f7b:	mov    rdi,r12
  443f7e:	movabs rsi,0x151
  443f88:	mov    esi,esi
  443f8a:	lea    rdx,[rbp-0x1be8]
  443f91:	movabs rcx,0x2
  443f9b:	mov    ecx,ecx
  443f9d:	xor    eax,eax
  443f9f:	call   461fd0 <p111_rt_jump>
  443fa4:	mov    QWORD PTR [rbp-0x1c10],rax
  443fab:	mov    rax,QWORD PTR [rbp-0x1c10]
  443fb2:	mov    r12,QWORD PTR [rbp-0x10]
  443fb6:	mov    rbx,QWORD PTR [rbp-0x8]
  443fba:	mov    r13,QWORD PTR [rbp-0x18]
  443fbe:	mov    r14,QWORD PTR [rbp-0x20]
  443fc2:	mov    r15,QWORD PTR [rbp-0x28]
  443fc6:	mov    rsp,rbp
  443fc9:	pop    rbp
  443fca:	ret    
  443fcb:	mov    rdi,r12
  443fce:	mov    rsi,QWORD PTR [rbp-0x8a8]
  443fd5:	xor    eax,eax
  443fd7:	call   461a10 <p111_rt_sink>
  443fdc:	mov    QWORD PTR [rbp-0x8a0],rax
  443fe3:	mov    rdi,r12
  443fe6:	mov    rsi,QWORD PTR [rbp-0x1108]
  443fed:	xor    eax,eax
  443fef:	call   461a10 <p111_rt_sink>
  443ff4:	mov    QWORD PTR [rbp-0x8a0],rax
  443ffb:	mov    rdi,r12
  443ffe:	mov    rsi,QWORD PTR [rbp-0x1110]
  444005:	xor    eax,eax
  444007:	call   461a10 <p111_rt_sink>
  44400c:	mov    QWORD PTR [rbp-0x8a0],rax
  444013:	mov    rdi,r12
  444016:	mov    rsi,QWORD PTR [rbp-0x1118]
  44401d:	xor    eax,eax
  44401f:	call   461a10 <p111_rt_sink>
  444024:	mov    QWORD PTR [rbp-0x8a0],rax
  44402b:	mov    rdi,r12
  44402e:	mov    rsi,QWORD PTR [rbp-0x1120]
  444035:	xor    eax,eax
  444037:	call   461a10 <p111_rt_sink>
  44403c:	mov    QWORD PTR [rbp-0x8a0],rax
  444043:	lea    r10,[rbp-0x830]
  44404a:	mov    r11,QWORD PTR [rbp-0x1128]
  444051:	mov    QWORD PTR [r10],r11
  444054:	mov    rdi,QWORD PTR [r12+0x10]
  444059:	mov    r10,rdi
  44405c:	mov    r11,QWORD PTR [rbp-0x1128]
  444063:	mov    QWORD PTR [r10],r11
  444066:	mov    r10,rdi
  444069:	movabs r11,0x158
  444073:	mov    QWORD PTR [r10+0x8],r11
  444077:	mov    rsi,rdi
  44407a:	add    rsi,0x10
  444081:	mov    QWORD PTR [r12+0x10],rsi
  444086:	mov    rdi,r12
  444089:	movabs rsi,0x4
  444093:	mov    esi,esi
  444095:	xor    eax,eax
  444097:	call   4621a0 <p111_rt_fail>
  44409c:	mov    QWORD PTR [rbp-0xa90],rax
  4440a3:	mov    r12,QWORD PTR [rbp-0x10]
  4440a7:	mov    rbx,QWORD PTR [rbp-0x8]
  4440ab:	mov    r13,QWORD PTR [rbp-0x18]
  4440af:	mov    r14,QWORD PTR [rbp-0x20]
  4440b3:	mov    r15,QWORD PTR [rbp-0x28]
  4440b7:	mov    rsp,rbp
  4440ba:	pop    rbp
  4440bb:	ret    
  4440bc:	mov    rdi,r12
  4440bf:	mov    rsi,QWORD PTR [rbp-0x8a8]
  4440c6:	xor    eax,eax
  4440c8:	call   461a10 <p111_rt_sink>
  4440cd:	mov    QWORD PTR [rbp-0x8a0],rax
  4440d4:	mov    rdi,r12
  4440d7:	mov    rsi,QWORD PTR [rbp-0x1108]
  4440de:	xor    eax,eax
  4440e0:	call   461a10 <p111_rt_sink>
  4440e5:	mov    QWORD PTR [rbp-0x8a0],rax
  4440ec:	mov    rdi,r12
  4440ef:	mov    rsi,QWORD PTR [rbp-0x1110]
  4440f6:	xor    eax,eax
  4440f8:	call   461a10 <p111_rt_sink>
  4440fd:	mov    QWORD PTR [rbp-0x8a0],rax
  444104:	mov    rdi,r12
  444107:	mov    rsi,QWORD PTR [rbp-0x1118]
  44410e:	xor    eax,eax
  444110:	call   461a10 <p111_rt_sink>
  444115:	mov    QWORD PTR [rbp-0x8a0],rax
  44411c:	lea    r10,[rbp-0x830]
  444123:	mov    r11,r14
  444126:	mov    QWORD PTR [r10],r11
  444129:	mov    rdi,QWORD PTR [r12+0x10]
  44412e:	mov    QWORD PTR [rdi],r14
  444131:	mov    r10,rdi
  444134:	movabs r11,0x159
  44413e:	mov    QWORD PTR [r10+0x8],r11
  444142:	mov    rsi,rdi
  444145:	add    rsi,0x10
  44414c:	mov    QWORD PTR [r12+0x10],rsi
  444151:	mov    rdi,r12
  444154:	movabs rsi,0x4
  44415e:	mov    esi,esi
  444160:	xor    eax,eax
  444162:	call   4621a0 <p111_rt_fail>
  444167:	mov    QWORD PTR [rbp-0xa90],rax
  44416e:	mov    r12,QWORD PTR [rbp-0x10]
  444172:	mov    rbx,QWORD PTR [rbp-0x8]
  444176:	mov    r13,QWORD PTR [rbp-0x18]
  44417a:	mov    r14,QWORD PTR [rbp-0x20]
  44417e:	mov    r15,QWORD PTR [rbp-0x28]
  444182:	mov    rsp,rbp
  444185:	pop    rbp
  444186:	ret    
  444187:	mov    rdi,r12
  44418a:	mov    rsi,QWORD PTR [rbp-0x8a8]
  444191:	xor    eax,eax
  444193:	call   461a10 <p111_rt_sink>
  444198:	mov    QWORD PTR [rbp-0x8a0],rax
  44419f:	lea    r10,[rbp-0x830]
  4441a6:	mov    r11,r14
  4441a9:	mov    QWORD PTR [r10],r11
  4441ac:	mov    rdi,QWORD PTR [r12+0x10]
  4441b1:	mov    QWORD PTR [rdi],r14
  4441b4:	mov    r10,rdi
  4441b7:	movabs r11,0x15a
  4441c1:	mov    QWORD PTR [r10+0x8],r11
  4441c5:	mov    rsi,rdi
  4441c8:	add    rsi,0x10
  4441cf:	mov    QWORD PTR [r12+0x10],rsi
  4441d4:	lea    r10,[rbp-0x830]
  4441db:	mov    r11,QWORD PTR [rbp-0x8b8]
  4441e2:	mov    QWORD PTR [r10],r11
  4441e5:	mov    rdi,QWORD PTR [r12+0x10]
  4441ea:	mov    r10,rdi
  4441ed:	mov    r11,QWORD PTR [rbp-0x8b8]
  4441f4:	mov    QWORD PTR [r10],r11
  4441f7:	mov    r10,rdi
  4441fa:	movabs r11,0x15b
  444204:	mov    QWORD PTR [r10+0x8],r11
  444208:	mov    rsi,rdi
  44420b:	add    rsi,0x10
  444212:	mov    QWORD PTR [r12+0x10],rsi
  444217:	mov    rdi,r12
  44421a:	movabs rsi,0x4
  444224:	mov    esi,esi
  444226:	xor    eax,eax
  444228:	call   4621a0 <p111_rt_fail>
  44422d:	mov    QWORD PTR [rbp-0xa90],rax
  444234:	mov    r12,QWORD PTR [rbp-0x10]
  444238:	mov    rbx,QWORD PTR [rbp-0x8]
  44423c:	mov    r13,QWORD PTR [rbp-0x18]
  444240:	mov    r14,QWORD PTR [rbp-0x20]
  444244:	mov    r15,QWORD PTR [rbp-0x28]
  444248:	mov    rsp,rbp
  44424b:	pop    rbp
  44424c:	ret    
  44424d:	mov    r15,QWORD PTR [rbp-0x8b0]
  444254:	shr    r15,0x28
  444258:	and    r15,0xffff
  44425f:	movabs r11,0x2c
  444269:	mov    r13,r15
  44426c:	cmp    r13,r11
  44426f:	sete   r13b
  444273:	movzx  r13d,r13b
  444277:	mov    r10,r13
  44427a:	test   r10d,r10d
  44427d:	je     447523 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x5b9d>
  444283:	mov    rdi,r12
  444286:	mov    rsi,QWORD PTR [rbp-0x8b0]
  44428d:	lea    rdx,[rbp-0x830]
  444294:	xor    eax,eax
  444296:	call   4677b0 <p125_rt_take2>
  44429b:	mov    QWORD PTR [rbp-0x8a0],rax
  4442a2:	lea    r10,[rbp-0x830]
  4442a9:	mov    r10,QWORD PTR [r10]
  4442ac:	mov    QWORD PTR [rbp-0x1c58],r10
  4442b3:	lea    r10,[rbp-0x830]
  4442ba:	mov    r10,QWORD PTR [r10+0x8]
  4442be:	mov    QWORD PTR [rbp-0x1c60],r10
  4442c5:	mov    r15,QWORD PTR [rbp-0x8b8]
  4442cc:	shr    r15,0x28
  4442d0:	and    r15,0xffff
  4442d7:	movabs r11,0x2b
  4442e1:	mov    r13,r15
  4442e4:	cmp    r13,r11
  4442e7:	sete   r13b
  4442eb:	movzx  r13d,r13b
  4442ef:	mov    r10,r13
  4442f2:	test   r10d,r10d
  4442f5:	je     4451b6 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3830>
  4442fb:	mov    r15,r14
  4442fe:	shr    r15,0x28
  444302:	and    r15,0xffff
  444309:	movabs r11,0x8
  444313:	mov    r13,r15
  444316:	cmp    r13,r11
  444319:	sete   r13b
  44431d:	movzx  r13d,r13b
  444321:	mov    r10,r13
  444324:	test   r10d,r10d
  444327:	je     445103 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x377d>
  44432d:	mov    rdi,r12
  444330:	mov    rsi,r14
  444333:	lea    rdx,[rbp-0x830]
  44433a:	xor    eax,eax
  44433c:	call   4677b0 <p125_rt_take2>
  444341:	mov    QWORD PTR [rbp-0x8a0],rax
  444348:	lea    r10,[rbp-0x830]
  44434f:	mov    r10,QWORD PTR [r10]
  444352:	mov    QWORD PTR [rbp-0x1c68],r10
  444359:	lea    r10,[rbp-0x830]
  444360:	mov    r10,QWORD PTR [r10+0x8]
  444364:	mov    QWORD PTR [rbp-0x1c70],r10
  44436b:	cmp    r10,0x1
  444372:	sete   r10b
  444376:	movzx  r10d,r10b
  44437a:	mov    QWORD PTR [rbp-0x8d0],r10
  444381:	mov    r10,QWORD PTR [rbp-0x1c70]
  444388:	shr    r10,0x28
  44438c:	mov    QWORD PTR [rbp-0x8d8],r10
  444393:	and    r10,0x7fffff
  44439a:	mov    QWORD PTR [rbp-0x8d8],r10
  4443a1:	movabs r10,0x2
  4443ab:	or     r10,0x10000
  4443b2:	mov    QWORD PTR [rbp-0x8e0],r10
  4443b9:	mov    r10,QWORD PTR [rbp-0x8d8]
  4443c0:	mov    r11,QWORD PTR [rbp-0x8e0]
  4443c7:	cmp    r10,r11
  4443ca:	sete   r10b
  4443ce:	movzx  r10d,r10b
  4443d2:	mov    QWORD PTR [rbp-0x8e8],r10
  4443d9:	mov    r11,r10
  4443dc:	mov    r13,QWORD PTR [rbp-0x8d0]
  4443e3:	or     r13d,r11d
  4443e6:	xor    r13d,0x1
  4443ed:	mov    r10,r13
  4443f0:	test   r10d,r10d
  4443f3:	je     444a49 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x30c3>
  4443f9:	mov    rdi,r12
  4443fc:	mov    rsi,QWORD PTR [rbp-0x1c58]
  444403:	xor    eax,eax
  444405:	call   461980 <p111_rt_keep>
  44440a:	mov    QWORD PTR [rbp-0x1c58],rax
  444411:	mov    rdi,rax
  444414:	lea    r10,[rbp-0x830]
  44441b:	mov    r11,rdi
  44441e:	mov    QWORD PTR [r10],r11
  444421:	lea    r10,[rbp-0x830]
  444428:	mov    r11,QWORD PTR [rbp-0x1c60]
  44442f:	mov    QWORD PTR [r10+0x8],r11
  444433:	mov    r10,r12
  444436:	mov    r10,QWORD PTR [r10+0x8]
  44443a:	mov    QWORD PTR [rbp-0x1c80],r10
  444441:	mov    r10,QWORD PTR [r10+0x8]
  444445:	mov    QWORD PTR [rbp-0x1c88],r10
  44444c:	cmp    r10,0x0
  444453:	je     4444f4 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x2b6e>
  444459:	mov    rdi,QWORD PTR [r12]
  44445d:	mov    rsi,QWORD PTR [rbp-0x1c88]
  444464:	shl    rsi,0x3
  444468:	mov    rdx,rdi
  44446b:	add    rdx,rsi
  44446e:	mov    rdi,QWORD PTR [rdx]
  444471:	mov    r10,QWORD PTR [rbp-0x1c80]
  444478:	mov    rsi,QWORD PTR [r10+0x108]
  44447f:	lea    r10,[rbp-0x830]
  444486:	mov    r8,QWORD PTR [r10]
  444489:	lea    r10,[rbp-0x830]
  444490:	mov    r9,QWORD PTR [r10+0x8]
  444494:	mov    r10,QWORD PTR [rbp-0x1c80]
  44449b:	mov    r11,rdi
  44449e:	mov    QWORD PTR [r10+0x8],r11
  4444a2:	mov    rdi,rsi
  4444a5:	sub    rdi,0x2
  4444ac:	mov    r10,QWORD PTR [rbp-0x1c80]
  4444b3:	mov    r11,rdi
  4444b6:	mov    QWORD PTR [r10+0x108],r11
  4444bd:	mov    QWORD PTR [rdx],r8
  4444c0:	mov    QWORD PTR [rdx+0x8],r9
  4444c4:	movabs rdi,0x2c
  4444ce:	shl    rdi,0x28
  4444d2:	movabs r11,0x200000000000000
  4444dc:	mov    rsi,rdi
  4444df:	or     rsi,r11
  4444e2:	mov    r11,QWORD PTR [rbp-0x1c88]
  4444e9:	mov    rbx,rsi
  4444ec:	or     rbx,r11
  4444ef:	jmp    444520 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x2b9a>
  4444f4:	mov    rdi,r12
  4444f7:	movabs rsi,0x2c
  444501:	mov    esi,esi
  444503:	lea    rdx,[rbp-0x830]
  44450a:	movabs rcx,0x2
  444514:	mov    ecx,ecx
  444516:	xor    eax,eax
  444518:	call   461a80 <p111_rt_ctor>
  44451d:	mov    rbx,rax
  444520:	mov    rdi,rbx
  444523:	movabs rsi,0x1002b0000000000
  44452d:	lea    r10,[rbp-0x830]
  444534:	mov    r11,QWORD PTR [rbp-0x8a8]
  44453b:	mov    QWORD PTR [r10],r11
  44453e:	lea    r10,[rbp-0x830]
  444545:	mov    r11,rdi
  444548:	mov    QWORD PTR [r10+0x8],r11
  44454c:	lea    r10,[rbp-0x830]
  444553:	mov    r11,rsi
  444556:	mov    QWORD PTR [r10+0x10],r11
  44455a:	mov    r10,r12
  44455d:	mov    r10,QWORD PTR [r10+0x8]
  444561:	mov    QWORD PTR [rbp-0x1cf8],r10
  444568:	mov    r10,QWORD PTR [r10+0x10]
  44456c:	mov    QWORD PTR [rbp-0x1d00],r10
  444573:	cmp    r10,0x0
  44457a:	je     44463b <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x2cb5>
  444580:	mov    rdi,QWORD PTR [r12]
  444584:	mov    rsi,QWORD PTR [rbp-0x1d00]
  44458b:	shl    rsi,0x3
  44458f:	mov    rdx,rdi
  444592:	add    rdx,rsi
  444595:	mov    rdi,QWORD PTR [rdx]
  444598:	mov    r10,QWORD PTR [rbp-0x1cf8]
  44459f:	mov    rsi,QWORD PTR [r10+0x110]
  4445a6:	lea    r10,[rbp-0x830]
  4445ad:	mov    r8,QWORD PTR [r10]
  4445b0:	lea    r10,[rbp-0x830]
  4445b7:	mov    r9,QWORD PTR [r10+0x8]
  4445bb:	lea    r10,[rbp-0x830]
  4445c2:	mov    r10,QWORD PTR [r10+0x10]
  4445c6:	mov    QWORD PTR [rbp-0x1d48],r10
  4445cd:	mov    r10,QWORD PTR [rbp-0x1cf8]
  4445d4:	mov    r11,rdi
  4445d7:	mov    QWORD PTR [r10+0x10],r11
  4445db:	mov    rdi,rsi
  4445de:	sub    rdi,0x4
  4445e5:	mov    r10,QWORD PTR [rbp-0x1cf8]
  4445ec:	mov    r11,rdi
  4445ef:	mov    QWORD PTR [r10+0x110],r11
  4445f6:	mov    QWORD PTR [rdx],r8
  4445f9:	mov    QWORD PTR [rdx+0x8],r9
  4445fd:	mov    r10,rdx
  444600:	mov    r11,QWORD PTR [rbp-0x1d48]
  444607:	mov    QWORD PTR [r10+0x10],r11
  44460b:	movabs rdi,0x2d
  444615:	shl    rdi,0x28
  444619:	movabs r11,0x200000000000000
  444623:	mov    rsi,rdi
  444626:	or     rsi,r11
  444629:	mov    r11,QWORD PTR [rbp-0x1d00]
  444630:	mov    rbx,rsi
  444633:	or     rbx,r11
  444636:	jmp    444667 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x2ce1>
  44463b:	mov    rdi,r12
  44463e:	movabs rsi,0x2d
  444648:	mov    esi,esi
  44464a:	lea    rdx,[rbp-0x830]
  444651:	movabs rcx,0x3
  44465b:	mov    ecx,ecx
  44465d:	xor    eax,eax
  44465f:	call   461a80 <p111_rt_ctor>
  444664:	mov    rbx,rax
  444667:	mov    r10,rbx
  44466a:	mov    QWORD PTR [rbp-0x1d68],r10
  444671:	mov    rdi,QWORD PTR [rbp-0x1c58]
  444678:	lea    r10,[rbp-0x830]
  44467f:	mov    r11,rdi
  444682:	mov    QWORD PTR [r10],r11
  444685:	mov    r10,r12
  444688:	mov    r10,QWORD PTR [r10+0x8]
  44468c:	mov    QWORD PTR [rbp-0x1d78],r10
  444693:	mov    r10,QWORD PTR [r10]
  444696:	mov    QWORD PTR [rbp-0x1d80],r10
  44469d:	cmp    r10,0x0
  4446a4:	je     444735 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x2daf>
  4446aa:	mov    rdi,QWORD PTR [r12]
  4446ae:	mov    rsi,QWORD PTR [rbp-0x1d80]
  4446b5:	shl    rsi,0x3
  4446b9:	mov    rdx,rdi
  4446bc:	add    rdx,rsi
  4446bf:	mov    rdi,QWORD PTR [rdx]
  4446c2:	mov    r10,QWORD PTR [rbp-0x1d78]
  4446c9:	mov    rsi,QWORD PTR [r10+0x100]
  4446d0:	lea    r10,[rbp-0x830]
  4446d7:	mov    r8,QWORD PTR [r10]
  4446da:	mov    r10,QWORD PTR [rbp-0x1d78]
  4446e1:	mov    r11,rdi
  4446e4:	mov    QWORD PTR [r10],r11
  4446e7:	mov    rdi,rsi
  4446ea:	sub    rdi,0x1
  4446f1:	mov    r10,QWORD PTR [rbp-0x1d78]
  4446f8:	mov    r11,rdi
  4446fb:	mov    QWORD PTR [r10+0x100],r11
  444702:	mov    QWORD PTR [rdx],r8
  444705:	movabs rdi,0xc
  44470f:	shl    rdi,0x28
  444713:	movabs r11,0x200000000000000
  44471d:	mov    rsi,rdi
  444720:	or     rsi,r11
  444723:	mov    r11,QWORD PTR [rbp-0x1d80]
  44472a:	mov    rbx,rsi
  44472d:	or     rbx,r11
  444730:	jmp    444761 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x2ddb>
  444735:	mov    rdi,r12
  444738:	movabs rsi,0xc
  444742:	mov    esi,esi
  444744:	lea    rdx,[rbp-0x830]
  44474b:	movabs rcx,0x1
  444755:	mov    ecx,ecx
  444757:	xor    eax,eax
  444759:	call   461a80 <p111_rt_ctor>
  44475e:	mov    rbx,rax
  444761:	mov    rdi,rbx
  444764:	lea    r10,[rbp-0x830]
  44476b:	mov    r11,QWORD PTR [rbp-0x1c68]
  444772:	mov    QWORD PTR [r10],r11
  444775:	lea    r10,[rbp-0x830]
  44477c:	mov    r11,rdi
  44477f:	mov    QWORD PTR [r10+0x8],r11
  444783:	mov    r10,r12
  444786:	mov    r10,QWORD PTR [r10+0x8]
  44478a:	mov    QWORD PTR [rbp-0x1de0],r10
  444791:	mov    r10,QWORD PTR [r10+0x8]
  444795:	mov    QWORD PTR [rbp-0x1de8],r10
  44479c:	cmp    r10,0x0
  4447a3:	je     444844 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x2ebe>
  4447a9:	mov    rdi,QWORD PTR [r12]
  4447ad:	mov    rsi,QWORD PTR [rbp-0x1de8]
  4447b4:	shl    rsi,0x3
  4447b8:	mov    rdx,rdi
  4447bb:	add    rdx,rsi
  4447be:	mov    rdi,QWORD PTR [rdx]
  4447c1:	mov    r10,QWORD PTR [rbp-0x1de0]
  4447c8:	mov    rsi,QWORD PTR [r10+0x108]
  4447cf:	lea    r10,[rbp-0x830]
  4447d6:	mov    r8,QWORD PTR [r10]
  4447d9:	lea    r10,[rbp-0x830]
  4447e0:	mov    r9,QWORD PTR [r10+0x8]
  4447e4:	mov    r10,QWORD PTR [rbp-0x1de0]
  4447eb:	mov    r11,rdi
  4447ee:	mov    QWORD PTR [r10+0x8],r11
  4447f2:	mov    rdi,rsi
  4447f5:	sub    rdi,0x2
  4447fc:	mov    r10,QWORD PTR [rbp-0x1de0]
  444803:	mov    r11,rdi
  444806:	mov    QWORD PTR [r10+0x108],r11
  44480d:	mov    QWORD PTR [rdx],r8
  444810:	mov    QWORD PTR [rdx+0x8],r9
  444814:	movabs rdi,0x8
  44481e:	shl    rdi,0x28
  444822:	movabs r11,0x200000000000000
  44482c:	mov    rsi,rdi
  44482f:	or     rsi,r11
  444832:	mov    r11,QWORD PTR [rbp-0x1de8]
  444839:	mov    rbx,rsi
  44483c:	or     rbx,r11
  44483f:	jmp    444870 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x2eea>
  444844:	mov    rdi,r12
  444847:	movabs rsi,0x8
  444851:	mov    esi,esi
  444853:	lea    rdx,[rbp-0x830]
  44485a:	movabs rcx,0x2
  444864:	mov    ecx,ecx
  444866:	xor    eax,eax
  444868:	call   461a80 <p111_rt_ctor>
  44486d:	mov    rbx,rax
  444870:	mov    rdi,rbx
  444873:	lea    r10,[rbp-0x830]
  44487a:	mov    r11,QWORD PTR [rbp-0x1d68]
  444881:	mov    QWORD PTR [r10],r11
  444884:	lea    r10,[rbp-0x830]
  44488b:	mov    r11,rdi
  44488e:	mov    QWORD PTR [r10+0x8],r11
  444892:	mov    r10,r12
  444895:	mov    r10,QWORD PTR [r10+0x8]
  444899:	mov    QWORD PTR [rbp-0x1e50],r10
  4448a0:	mov    r10,QWORD PTR [r10+0x8]
  4448a4:	mov    QWORD PTR [rbp-0x1e58],r10
  4448ab:	cmp    r10,0x0
  4448b2:	je     444953 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x2fcd>
  4448b8:	mov    rdi,QWORD PTR [r12]
  4448bc:	mov    rsi,QWORD PTR [rbp-0x1e58]
  4448c3:	shl    rsi,0x3
  4448c7:	mov    rdx,rdi
  4448ca:	add    rdx,rsi
  4448cd:	mov    rdi,QWORD PTR [rdx]
  4448d0:	mov    r10,QWORD PTR [rbp-0x1e50]
  4448d7:	mov    rsi,QWORD PTR [r10+0x108]
  4448de:	lea    r10,[rbp-0x830]
  4448e5:	mov    r8,QWORD PTR [r10]
  4448e8:	lea    r10,[rbp-0x830]
  4448ef:	mov    r9,QWORD PTR [r10+0x8]
  4448f3:	mov    r10,QWORD PTR [rbp-0x1e50]
  4448fa:	mov    r11,rdi
  4448fd:	mov    QWORD PTR [r10+0x8],r11
  444901:	mov    rdi,rsi
  444904:	sub    rdi,0x2
  44490b:	mov    r10,QWORD PTR [rbp-0x1e50]
  444912:	mov    r11,rdi
  444915:	mov    QWORD PTR [r10+0x108],r11
  44491c:	mov    QWORD PTR [rdx],r8
  44491f:	mov    QWORD PTR [rdx+0x8],r9
  444923:	movabs rdi,0x8
  44492d:	shl    rdi,0x28
  444931:	movabs r11,0x200000000000000
  44493b:	mov    rsi,rdi
  44493e:	or     rsi,r11
  444941:	mov    r11,QWORD PTR [rbp-0x1e58]
  444948:	mov    rbx,rsi
  44494b:	or     rbx,r11
  44494e:	jmp    44497f <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x2ff9>
  444953:	mov    rdi,r12
  444956:	movabs rsi,0x8
  444960:	mov    esi,esi
  444962:	lea    rdx,[rbp-0x830]
  444969:	movabs rcx,0x2
  444973:	mov    ecx,ecx
  444975:	xor    eax,eax
  444977:	call   461a80 <p111_rt_ctor>
  44497c:	mov    rbx,rax
  44497f:	lea    r10,[rbp-0x830]
  444986:	mov    r11,rbx
  444989:	mov    QWORD PTR [r10],r11
  44498c:	lea    r10,[rip+0x2c24d]        # 470be0 <p111_program>
  444993:	movabs rdi,0x4
  44499d:	and    rdi,QWORD PTR [r10+0x58]
  4449a1:	mov    r10,rdi
  4449a4:	test   r10d,r10d
  4449a7:	je     444a05 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x307f>
  4449ad:	lea    r10,[rbp-0x830]
  4449b4:	mov    rdi,QWORD PTR [r10]
  4449b7:	mov    QWORD PTR [r12+0x28],rdi
  4449bc:	mov    r10,r12
  4449bf:	movabs r11,0x1
  4449c9:	mov    DWORD PTR [r10+0x1c],r11d
  4449cd:	mov    rdi,QWORD PTR [r12+0x10]
  4449d2:	movabs r11,0xfffffffffffffff8
  4449dc:	mov    rsi,rdi
  4449df:	add    rsi,r11
  4449e2:	mov    QWORD PTR [r12+0x10],rsi
  4449e7:	mov    rdi,QWORD PTR [rsi]
  4449ea:	mov    DWORD PTR [r12+0x20],edi
  4449ef:	movabs r10,0x0
  4449f9:	mov    QWORD PTR [rbp-0xa90],r10
  444a00:	jmp    444a29 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x30a3>
  444a05:	mov    rdi,r12
  444a08:	lea    rsi,[rbp-0x830]
  444a0f:	movabs rdx,0x1
  444a19:	mov    edx,edx
  444a1b:	xor    eax,eax
  444a1d:	call   462030 <p111_rt_return>
  444a22:	mov    QWORD PTR [rbp-0xa90],rax
  444a29:	mov    rax,QWORD PTR [rbp-0xa90]
  444a30:	mov    r12,QWORD PTR [rbp-0x10]
  444a34:	mov    rbx,QWORD PTR [rbp-0x8]
  444a38:	mov    r13,QWORD PTR [rbp-0x18]
  444a3c:	mov    r14,QWORD PTR [rbp-0x20]
  444a40:	mov    r15,QWORD PTR [rbp-0x28]
  444a44:	mov    rsp,rbp
  444a47:	pop    rbp
  444a48:	ret    
  444a49:	mov    r10,QWORD PTR [rbp-0x1c70]
  444a50:	cmp    r10,0x1
  444a57:	sete   r10b
  444a5b:	movzx  r10d,r10b
  444a5f:	mov    QWORD PTR [rbp-0x8d0],r10
  444a66:	mov    r10,QWORD PTR [rbp-0x1c70]
  444a6d:	shr    r10,0x28
  444a71:	mov    QWORD PTR [rbp-0x8d8],r10
  444a78:	and    r10,0x7fffff
  444a7f:	mov    QWORD PTR [rbp-0x8d8],r10
  444a86:	movabs r10,0x2
  444a90:	or     r10,0x10000
  444a97:	mov    QWORD PTR [rbp-0x8e0],r10
  444a9e:	mov    r10,QWORD PTR [rbp-0x8d8]
  444aa5:	mov    r11,QWORD PTR [rbp-0x8e0]
  444aac:	cmp    r10,r11
  444aaf:	sete   r10b
  444ab3:	movzx  r10d,r10b
  444ab7:	mov    QWORD PTR [rbp-0x8e8],r10
  444abe:	mov    r11,r10
  444ac1:	mov    r13,QWORD PTR [rbp-0x8d0]
  444ac8:	or     r13d,r11d
  444acb:	mov    r10,r13
  444ace:	test   r10d,r10d
  444ad1:	je     44502a <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x36a4>
  444ad7:	mov    rdi,QWORD PTR [rbp-0x1c58]
  444ade:	lea    r10,[rbp-0x830]
  444ae5:	mov    r11,rdi
  444ae8:	mov    QWORD PTR [r10],r11
  444aeb:	lea    r10,[rbp-0x830]
  444af2:	mov    r11,QWORD PTR [rbp-0x1c60]
  444af9:	mov    QWORD PTR [r10+0x8],r11
  444afd:	mov    r10,r12
  444b00:	mov    r10,QWORD PTR [r10+0x8]
  444b04:	mov    QWORD PTR [rbp-0x1ef0],r10
  444b0b:	mov    r10,QWORD PTR [r10+0x8]
  444b0f:	mov    QWORD PTR [rbp-0x1ef8],r10
  444b16:	cmp    r10,0x0
  444b1d:	je     444bbe <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3238>
  444b23:	mov    rdi,QWORD PTR [r12]
  444b27:	mov    rsi,QWORD PTR [rbp-0x1ef8]
  444b2e:	shl    rsi,0x3
  444b32:	mov    rdx,rdi
  444b35:	add    rdx,rsi
  444b38:	mov    rdi,QWORD PTR [rdx]
  444b3b:	mov    r10,QWORD PTR [rbp-0x1ef0]
  444b42:	mov    rsi,QWORD PTR [r10+0x108]
  444b49:	lea    r10,[rbp-0x830]
  444b50:	mov    r8,QWORD PTR [r10]
  444b53:	lea    r10,[rbp-0x830]
  444b5a:	mov    r9,QWORD PTR [r10+0x8]
  444b5e:	mov    r10,QWORD PTR [rbp-0x1ef0]
  444b65:	mov    r11,rdi
  444b68:	mov    QWORD PTR [r10+0x8],r11
  444b6c:	mov    rdi,rsi
  444b6f:	sub    rdi,0x2
  444b76:	mov    r10,QWORD PTR [rbp-0x1ef0]
  444b7d:	mov    r11,rdi
  444b80:	mov    QWORD PTR [r10+0x108],r11
  444b87:	mov    QWORD PTR [rdx],r8
  444b8a:	mov    QWORD PTR [rdx+0x8],r9
  444b8e:	movabs rdi,0x2c
  444b98:	shl    rdi,0x28
  444b9c:	movabs r11,0x200000000000000
  444ba6:	mov    rsi,rdi
  444ba9:	or     rsi,r11
  444bac:	mov    r11,QWORD PTR [rbp-0x1ef8]
  444bb3:	mov    rbx,rsi
  444bb6:	or     rbx,r11
  444bb9:	jmp    444bea <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3264>
  444bbe:	mov    rdi,r12
  444bc1:	movabs rsi,0x2c
  444bcb:	mov    esi,esi
  444bcd:	lea    rdx,[rbp-0x830]
  444bd4:	movabs rcx,0x2
  444bde:	mov    ecx,ecx
  444be0:	xor    eax,eax
  444be2:	call   461a80 <p111_rt_ctor>
  444be7:	mov    rbx,rax
  444bea:	mov    rdi,rbx
  444bed:	movabs rsi,0x1002b0000000000
  444bf7:	lea    r10,[rbp-0x830]
  444bfe:	mov    r11,QWORD PTR [rbp-0x8a8]
  444c05:	mov    QWORD PTR [r10],r11
  444c08:	lea    r10,[rbp-0x830]
  444c0f:	mov    r11,rdi
  444c12:	mov    QWORD PTR [r10+0x8],r11
  444c16:	lea    r10,[rbp-0x830]
  444c1d:	mov    r11,rsi
  444c20:	mov    QWORD PTR [r10+0x10],r11
  444c24:	mov    r10,r12
  444c27:	mov    r10,QWORD PTR [r10+0x8]
  444c2b:	mov    QWORD PTR [rbp-0x1f68],r10
  444c32:	mov    r10,QWORD PTR [r10+0x10]
  444c36:	mov    QWORD PTR [rbp-0x1f70],r10
  444c3d:	cmp    r10,0x0
  444c44:	je     444d05 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x337f>
  444c4a:	mov    rdi,QWORD PTR [r12]
  444c4e:	mov    rsi,QWORD PTR [rbp-0x1f70]
  444c55:	shl    rsi,0x3
  444c59:	mov    rdx,rdi
  444c5c:	add    rdx,rsi
  444c5f:	mov    rdi,QWORD PTR [rdx]
  444c62:	mov    r10,QWORD PTR [rbp-0x1f68]
  444c69:	mov    rsi,QWORD PTR [r10+0x110]
  444c70:	lea    r10,[rbp-0x830]
  444c77:	mov    r8,QWORD PTR [r10]
  444c7a:	lea    r10,[rbp-0x830]
  444c81:	mov    r9,QWORD PTR [r10+0x8]
  444c85:	lea    r10,[rbp-0x830]
  444c8c:	mov    r10,QWORD PTR [r10+0x10]
  444c90:	mov    QWORD PTR [rbp-0x1fb8],r10
  444c97:	mov    r10,QWORD PTR [rbp-0x1f68]
  444c9e:	mov    r11,rdi
  444ca1:	mov    QWORD PTR [r10+0x10],r11
  444ca5:	mov    rdi,rsi
  444ca8:	sub    rdi,0x4
  444caf:	mov    r10,QWORD PTR [rbp-0x1f68]
  444cb6:	mov    r11,rdi
  444cb9:	mov    QWORD PTR [r10+0x110],r11
  444cc0:	mov    QWORD PTR [rdx],r8
  444cc3:	mov    QWORD PTR [rdx+0x8],r9
  444cc7:	mov    r10,rdx
  444cca:	mov    r11,QWORD PTR [rbp-0x1fb8]
  444cd1:	mov    QWORD PTR [r10+0x10],r11
  444cd5:	movabs rdi,0x2d
  444cdf:	shl    rdi,0x28
  444ce3:	movabs r11,0x200000000000000
  444ced:	mov    rsi,rdi
  444cf0:	or     rsi,r11
  444cf3:	mov    r11,QWORD PTR [rbp-0x1f70]
  444cfa:	mov    rbx,rsi
  444cfd:	or     rbx,r11
  444d00:	jmp    444d31 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x33ab>
  444d05:	mov    rdi,r12
  444d08:	movabs rsi,0x2d
  444d12:	mov    esi,esi
  444d14:	lea    rdx,[rbp-0x830]
  444d1b:	movabs rcx,0x3
  444d25:	mov    ecx,ecx
  444d27:	xor    eax,eax
  444d29:	call   461a80 <p111_rt_ctor>
  444d2e:	mov    rbx,rax
  444d31:	mov    r10,rbx
  444d34:	mov    QWORD PTR [rbp-0x1fd8],r10
  444d3b:	movabs rdi,0x1000b0000000000
  444d45:	lea    r10,[rbp-0x830]
  444d4c:	mov    r11,QWORD PTR [rbp-0x1c68]
  444d53:	mov    QWORD PTR [r10],r11
  444d56:	lea    r10,[rbp-0x830]
  444d5d:	mov    r11,rdi
  444d60:	mov    QWORD PTR [r10+0x8],r11
  444d64:	mov    r10,r12
  444d67:	mov    r10,QWORD PTR [r10+0x8]
  444d6b:	mov    QWORD PTR [rbp-0x1fe8],r10
  444d72:	mov    r10,QWORD PTR [r10+0x8]
  444d76:	mov    QWORD PTR [rbp-0x1ff0],r10
  444d7d:	cmp    r10,0x0
  444d84:	je     444e25 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x349f>
  444d8a:	mov    rdi,QWORD PTR [r12]
  444d8e:	mov    rsi,QWORD PTR [rbp-0x1ff0]
  444d95:	shl    rsi,0x3
  444d99:	mov    rdx,rdi
  444d9c:	add    rdx,rsi
  444d9f:	mov    rdi,QWORD PTR [rdx]
  444da2:	mov    r10,QWORD PTR [rbp-0x1fe8]
  444da9:	mov    rsi,QWORD PTR [r10+0x108]
  444db0:	lea    r10,[rbp-0x830]
  444db7:	mov    r8,QWORD PTR [r10]
  444dba:	lea    r10,[rbp-0x830]
  444dc1:	mov    r9,QWORD PTR [r10+0x8]
  444dc5:	mov    r10,QWORD PTR [rbp-0x1fe8]
  444dcc:	mov    r11,rdi
  444dcf:	mov    QWORD PTR [r10+0x8],r11
  444dd3:	mov    rdi,rsi
  444dd6:	sub    rdi,0x2
  444ddd:	mov    r10,QWORD PTR [rbp-0x1fe8]
  444de4:	mov    r11,rdi
  444de7:	mov    QWORD PTR [r10+0x108],r11
  444dee:	mov    QWORD PTR [rdx],r8
  444df1:	mov    QWORD PTR [rdx+0x8],r9
  444df5:	movabs rdi,0x8
  444dff:	shl    rdi,0x28
  444e03:	movabs r11,0x200000000000000
  444e0d:	mov    rsi,rdi
  444e10:	or     rsi,r11
  444e13:	mov    r11,QWORD PTR [rbp-0x1ff0]
  444e1a:	mov    rbx,rsi
  444e1d:	or     rbx,r11
  444e20:	jmp    444e51 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x34cb>
  444e25:	mov    rdi,r12
  444e28:	movabs rsi,0x8
  444e32:	mov    esi,esi
  444e34:	lea    rdx,[rbp-0x830]
  444e3b:	movabs rcx,0x2
  444e45:	mov    ecx,ecx
  444e47:	xor    eax,eax
  444e49:	call   461a80 <p111_rt_ctor>
  444e4e:	mov    rbx,rax
  444e51:	mov    rdi,rbx
  444e54:	lea    r10,[rbp-0x830]
  444e5b:	mov    r11,QWORD PTR [rbp-0x1fd8]
  444e62:	mov    QWORD PTR [r10],r11
  444e65:	lea    r10,[rbp-0x830]
  444e6c:	mov    r11,rdi
  444e6f:	mov    QWORD PTR [r10+0x8],r11
  444e73:	mov    r10,r12
  444e76:	mov    r10,QWORD PTR [r10+0x8]
  444e7a:	mov    QWORD PTR [rbp-0x2058],r10
  444e81:	mov    r10,QWORD PTR [r10+0x8]
  444e85:	mov    QWORD PTR [rbp-0x2060],r10
  444e8c:	cmp    r10,0x0
  444e93:	je     444f34 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x35ae>
  444e99:	mov    rdi,QWORD PTR [r12]
  444e9d:	mov    rsi,QWORD PTR [rbp-0x2060]
  444ea4:	shl    rsi,0x3
  444ea8:	mov    rdx,rdi
  444eab:	add    rdx,rsi
  444eae:	mov    rdi,QWORD PTR [rdx]
  444eb1:	mov    r10,QWORD PTR [rbp-0x2058]
  444eb8:	mov    rsi,QWORD PTR [r10+0x108]
  444ebf:	lea    r10,[rbp-0x830]
  444ec6:	mov    r8,QWORD PTR [r10]
  444ec9:	lea    r10,[rbp-0x830]
  444ed0:	mov    r9,QWORD PTR [r10+0x8]
  444ed4:	mov    r10,QWORD PTR [rbp-0x2058]
  444edb:	mov    r11,rdi
  444ede:	mov    QWORD PTR [r10+0x8],r11
  444ee2:	mov    rdi,rsi
  444ee5:	sub    rdi,0x2
  444eec:	mov    r10,QWORD PTR [rbp-0x2058]
  444ef3:	mov    r11,rdi
  444ef6:	mov    QWORD PTR [r10+0x108],r11
  444efd:	mov    QWORD PTR [rdx],r8
  444f00:	mov    QWORD PTR [rdx+0x8],r9
  444f04:	movabs rdi,0x8
  444f0e:	shl    rdi,0x28
  444f12:	movabs r11,0x200000000000000
  444f1c:	mov    rsi,rdi
  444f1f:	or     rsi,r11
  444f22:	mov    r11,QWORD PTR [rbp-0x2060]
  444f29:	mov    rbx,rsi
  444f2c:	or     rbx,r11
  444f2f:	jmp    444f60 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x35da>
  444f34:	mov    rdi,r12
  444f37:	movabs rsi,0x8
  444f41:	mov    esi,esi
  444f43:	lea    rdx,[rbp-0x830]
  444f4a:	movabs rcx,0x2
  444f54:	mov    ecx,ecx
  444f56:	xor    eax,eax
  444f58:	call   461a80 <p111_rt_ctor>
  444f5d:	mov    rbx,rax
  444f60:	lea    r10,[rbp-0x830]
  444f67:	mov    r11,rbx
  444f6a:	mov    QWORD PTR [r10],r11
  444f6d:	lea    r10,[rip+0x2bc6c]        # 470be0 <p111_program>
  444f74:	movabs rdi,0x4
  444f7e:	and    rdi,QWORD PTR [r10+0x58]
  444f82:	mov    r10,rdi
  444f85:	test   r10d,r10d
  444f88:	je     444fe6 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3660>
  444f8e:	lea    r10,[rbp-0x830]
  444f95:	mov    rdi,QWORD PTR [r10]
  444f98:	mov    QWORD PTR [r12+0x28],rdi
  444f9d:	mov    r10,r12
  444fa0:	movabs r11,0x1
  444faa:	mov    DWORD PTR [r10+0x1c],r11d
  444fae:	mov    rdi,QWORD PTR [r12+0x10]
  444fb3:	movabs r11,0xfffffffffffffff8
  444fbd:	mov    rsi,rdi
  444fc0:	add    rsi,r11
  444fc3:	mov    QWORD PTR [r12+0x10],rsi
  444fc8:	mov    rdi,QWORD PTR [rsi]
  444fcb:	mov    DWORD PTR [r12+0x20],edi
  444fd0:	movabs r10,0x0
  444fda:	mov    QWORD PTR [rbp-0xa90],r10
  444fe1:	jmp    44500a <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3684>
  444fe6:	mov    rdi,r12
  444fe9:	lea    rsi,[rbp-0x830]
  444ff0:	movabs rdx,0x1
  444ffa:	mov    edx,edx
  444ffc:	xor    eax,eax
  444ffe:	call   462030 <p111_rt_return>
  445003:	mov    QWORD PTR [rbp-0xa90],rax
  44500a:	mov    rax,QWORD PTR [rbp-0xa90]
  445011:	mov    r12,QWORD PTR [rbp-0x10]
  445015:	mov    rbx,QWORD PTR [rbp-0x8]
  445019:	mov    r13,QWORD PTR [rbp-0x18]
  44501d:	mov    r14,QWORD PTR [rbp-0x20]
  445021:	mov    r15,QWORD PTR [rbp-0x28]
  445025:	mov    rsp,rbp
  445028:	pop    rbp
  445029:	ret    
  44502a:	mov    rdi,r12
  44502d:	mov    rsi,QWORD PTR [rbp-0x8a8]
  445034:	xor    eax,eax
  445036:	call   461a10 <p111_rt_sink>
  44503b:	mov    QWORD PTR [rbp-0x8a0],rax
  445042:	mov    rdi,r12
  445045:	mov    rsi,QWORD PTR [rbp-0x1c58]
  44504c:	xor    eax,eax
  44504e:	call   461a10 <p111_rt_sink>
  445053:	mov    QWORD PTR [rbp-0x8a0],rax
  44505a:	mov    rdi,r12
  44505d:	mov    rsi,QWORD PTR [rbp-0x1c60]
  445064:	xor    eax,eax
  445066:	call   461a10 <p111_rt_sink>
  44506b:	mov    QWORD PTR [rbp-0x8a0],rax
  445072:	mov    rdi,r12
  445075:	mov    rsi,QWORD PTR [rbp-0x1c68]
  44507c:	xor    eax,eax
  44507e:	call   461a10 <p111_rt_sink>
  445083:	mov    QWORD PTR [rbp-0x8a0],rax
  44508a:	lea    r10,[rbp-0x830]
  445091:	mov    r11,QWORD PTR [rbp-0x1c70]
  445098:	mov    QWORD PTR [r10],r11
  44509b:	mov    rdi,QWORD PTR [r12+0x10]
  4450a0:	mov    r10,rdi
  4450a3:	mov    r11,QWORD PTR [rbp-0x1c70]
  4450aa:	mov    QWORD PTR [r10],r11
  4450ad:	mov    r10,rdi
  4450b0:	movabs r11,0x15c
  4450ba:	mov    QWORD PTR [r10+0x8],r11
  4450be:	mov    rsi,rdi
  4450c1:	add    rsi,0x10
  4450c8:	mov    QWORD PTR [r12+0x10],rsi
  4450cd:	mov    rdi,r12
  4450d0:	movabs rsi,0x4
  4450da:	mov    esi,esi
  4450dc:	xor    eax,eax
  4450de:	call   4621a0 <p111_rt_fail>
  4450e3:	mov    QWORD PTR [rbp-0xa90],rax
  4450ea:	mov    r12,QWORD PTR [rbp-0x10]
  4450ee:	mov    rbx,QWORD PTR [rbp-0x8]
  4450f2:	mov    r13,QWORD PTR [rbp-0x18]
  4450f6:	mov    r14,QWORD PTR [rbp-0x20]
  4450fa:	mov    r15,QWORD PTR [rbp-0x28]
  4450fe:	mov    rsp,rbp
  445101:	pop    rbp
  445102:	ret    
  445103:	mov    rdi,r12
  445106:	mov    rsi,QWORD PTR [rbp-0x8a8]
  44510d:	xor    eax,eax
  44510f:	call   461a10 <p111_rt_sink>
  445114:	mov    QWORD PTR [rbp-0x8a0],rax
  44511b:	mov    rdi,r12
  44511e:	mov    rsi,QWORD PTR [rbp-0x1c58]
  445125:	xor    eax,eax
  445127:	call   461a10 <p111_rt_sink>
  44512c:	mov    QWORD PTR [rbp-0x8a0],rax
  445133:	mov    rdi,r12
  445136:	mov    rsi,QWORD PTR [rbp-0x1c60]
  44513d:	xor    eax,eax
  44513f:	call   461a10 <p111_rt_sink>
  445144:	mov    QWORD PTR [rbp-0x8a0],rax
  44514b:	lea    r10,[rbp-0x830]
  445152:	mov    r11,r14
  445155:	mov    QWORD PTR [r10],r11
  445158:	mov    rdi,QWORD PTR [r12+0x10]
  44515d:	mov    QWORD PTR [rdi],r14
  445160:	mov    r10,rdi
  445163:	movabs r11,0x15d
  44516d:	mov    QWORD PTR [r10+0x8],r11
  445171:	mov    rsi,rdi
  445174:	add    rsi,0x10
  44517b:	mov    QWORD PTR [r12+0x10],rsi
  445180:	mov    rdi,r12
  445183:	movabs rsi,0x4
  44518d:	mov    esi,esi
  44518f:	xor    eax,eax
  445191:	call   4621a0 <p111_rt_fail>
  445196:	mov    QWORD PTR [rbp-0xa90],rax
  44519d:	mov    r12,QWORD PTR [rbp-0x10]
  4451a1:	mov    rbx,QWORD PTR [rbp-0x8]
  4451a5:	mov    r13,QWORD PTR [rbp-0x18]
  4451a9:	mov    r14,QWORD PTR [rbp-0x20]
  4451ad:	mov    r15,QWORD PTR [rbp-0x28]
  4451b1:	mov    rsp,rbp
  4451b4:	pop    rbp
  4451b5:	ret    
  4451b6:	mov    r15,QWORD PTR [rbp-0x8b8]
  4451bd:	shr    r15,0x28
  4451c1:	and    r15,0xffff
  4451c8:	movabs r11,0x2c
  4451d2:	mov    r13,r15
  4451d5:	cmp    r13,r11
  4451d8:	sete   r13b
  4451dc:	movzx  r13d,r13b
  4451e0:	mov    r10,r13
  4451e3:	test   r10d,r10d
  4451e6:	je     446474 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x4aee>
  4451ec:	mov    rdi,r12
  4451ef:	mov    rsi,QWORD PTR [rbp-0x8b8]
  4451f6:	lea    rdx,[rbp-0x830]
  4451fd:	xor    eax,eax
  4451ff:	call   4677b0 <p125_rt_take2>
  445204:	mov    QWORD PTR [rbp-0x8a0],rax
  44520b:	lea    r10,[rbp-0x830]
  445212:	mov    r10,QWORD PTR [r10]
  445215:	mov    QWORD PTR [rbp-0x2110],r10
  44521c:	lea    r10,[rbp-0x830]
  445223:	mov    r10,QWORD PTR [r10+0x8]
  445227:	mov    QWORD PTR [rbp-0x2118],r10
  44522e:	mov    r15,r14
  445231:	shr    r15,0x28
  445235:	and    r15,0xffff
  44523c:	movabs r11,0x8
  445246:	mov    r13,r15
  445249:	cmp    r13,r11
  44524c:	sete   r13b
  445250:	movzx  r13d,r13b
  445254:	mov    r10,r13
  445257:	test   r10d,r10d
  44525a:	je     446391 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x4a0b>
  445260:	mov    rdi,r12
  445263:	mov    rsi,r14
  445266:	lea    rdx,[rbp-0x830]
  44526d:	xor    eax,eax
  44526f:	call   4677b0 <p125_rt_take2>
  445274:	mov    QWORD PTR [rbp-0x8a0],rax
  44527b:	lea    r10,[rbp-0x830]
  445282:	mov    r10,QWORD PTR [r10]
  445285:	mov    QWORD PTR [rbp-0x2120],r10
  44528c:	lea    r10,[rbp-0x830]
  445293:	mov    r10,QWORD PTR [r10+0x8]
  445297:	mov    QWORD PTR [rbp-0x2128],r10
  44529e:	cmp    r10,0x1
  4452a5:	sete   r10b
  4452a9:	movzx  r10d,r10b
  4452ad:	mov    QWORD PTR [rbp-0x8d0],r10
  4452b4:	mov    r10,QWORD PTR [rbp-0x2128]
  4452bb:	shr    r10,0x28
  4452bf:	mov    QWORD PTR [rbp-0x8d8],r10
  4452c6:	and    r10,0x7fffff
  4452cd:	mov    QWORD PTR [rbp-0x8d8],r10
  4452d4:	movabs r10,0x2
  4452de:	or     r10,0x10000
  4452e5:	mov    QWORD PTR [rbp-0x8e0],r10
  4452ec:	mov    r10,QWORD PTR [rbp-0x8d8]
  4452f3:	mov    r11,QWORD PTR [rbp-0x8e0]
  4452fa:	cmp    r10,r11
  4452fd:	sete   r10b
  445301:	movzx  r10d,r10b
  445305:	mov    QWORD PTR [rbp-0x8e8],r10
  44530c:	mov    r11,r10
  44530f:	mov    r13,QWORD PTR [rbp-0x8d0]
  445316:	or     r13d,r11d
  445319:	xor    r13d,0x1
  445320:	mov    r10,r13
  445323:	test   r10d,r10d
  445326:	je     445a93 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x410d>
  44532c:	mov    rdi,r12
  44532f:	mov    rsi,QWORD PTR [rbp-0x1c58]
  445336:	xor    eax,eax
  445338:	call   461980 <p111_rt_keep>
  44533d:	mov    QWORD PTR [rbp-0x1c58],rax
  445344:	mov    rdi,rax
  445347:	lea    r10,[rbp-0x830]
  44534e:	mov    r11,rdi
  445351:	mov    QWORD PTR [r10],r11
  445354:	lea    r10,[rbp-0x830]
  44535b:	mov    r11,QWORD PTR [rbp-0x1c60]
  445362:	mov    QWORD PTR [r10+0x8],r11
  445366:	mov    r10,r12
  445369:	mov    r10,QWORD PTR [r10+0x8]
  44536d:	mov    QWORD PTR [rbp-0x2138],r10
  445374:	mov    r10,QWORD PTR [r10+0x8]
  445378:	mov    QWORD PTR [rbp-0x2140],r10
  44537f:	cmp    r10,0x0
  445386:	je     445427 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3aa1>
  44538c:	mov    rdi,QWORD PTR [r12]
  445390:	mov    rsi,QWORD PTR [rbp-0x2140]
  445397:	shl    rsi,0x3
  44539b:	mov    rdx,rdi
  44539e:	add    rdx,rsi
  4453a1:	mov    rdi,QWORD PTR [rdx]
  4453a4:	mov    r10,QWORD PTR [rbp-0x2138]
  4453ab:	mov    rsi,QWORD PTR [r10+0x108]
  4453b2:	lea    r10,[rbp-0x830]
  4453b9:	mov    r8,QWORD PTR [r10]
  4453bc:	lea    r10,[rbp-0x830]
  4453c3:	mov    r9,QWORD PTR [r10+0x8]
  4453c7:	mov    r10,QWORD PTR [rbp-0x2138]
  4453ce:	mov    r11,rdi
  4453d1:	mov    QWORD PTR [r10+0x8],r11
  4453d5:	mov    rdi,rsi
  4453d8:	sub    rdi,0x2
  4453df:	mov    r10,QWORD PTR [rbp-0x2138]
  4453e6:	mov    r11,rdi
  4453e9:	mov    QWORD PTR [r10+0x108],r11
  4453f0:	mov    QWORD PTR [rdx],r8
  4453f3:	mov    QWORD PTR [rdx+0x8],r9
  4453f7:	movabs rdi,0x2c
  445401:	shl    rdi,0x28
  445405:	movabs r11,0x200000000000000
  44540f:	mov    rsi,rdi
  445412:	or     rsi,r11
  445415:	mov    r11,QWORD PTR [rbp-0x2140]
  44541c:	mov    rbx,rsi
  44541f:	or     rbx,r11
  445422:	jmp    445453 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3acd>
  445427:	mov    rdi,r12
  44542a:	movabs rsi,0x2c
  445434:	mov    esi,esi
  445436:	lea    rdx,[rbp-0x830]
  44543d:	movabs rcx,0x2
  445447:	mov    ecx,ecx
  445449:	xor    eax,eax
  44544b:	call   461a80 <p111_rt_ctor>
  445450:	mov    rbx,rax
  445453:	mov    r10,rbx
  445456:	mov    QWORD PTR [rbp-0x21a0],r10
  44545d:	mov    rdi,QWORD PTR [rbp-0x2110]
  445464:	lea    r10,[rbp-0x830]
  44546b:	mov    r11,rdi
  44546e:	mov    QWORD PTR [r10],r11
  445471:	lea    r10,[rbp-0x830]
  445478:	mov    r11,QWORD PTR [rbp-0x2118]
  44547f:	mov    QWORD PTR [r10+0x8],r11
  445483:	mov    r10,r12
  445486:	mov    r10,QWORD PTR [r10+0x8]
  44548a:	mov    QWORD PTR [rbp-0x21b0],r10
  445491:	mov    r10,QWORD PTR [r10+0x8]
  445495:	mov    QWORD PTR [rbp-0x21b8],r10
  44549c:	cmp    r10,0x0
  4454a3:	je     445544 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3bbe>
  4454a9:	mov    rdi,QWORD PTR [r12]
  4454ad:	mov    rsi,QWORD PTR [rbp-0x21b8]
  4454b4:	shl    rsi,0x3
  4454b8:	mov    rdx,rdi
  4454bb:	add    rdx,rsi
  4454be:	mov    rdi,QWORD PTR [rdx]
  4454c1:	mov    r10,QWORD PTR [rbp-0x21b0]
  4454c8:	mov    rsi,QWORD PTR [r10+0x108]
  4454cf:	lea    r10,[rbp-0x830]
  4454d6:	mov    r8,QWORD PTR [r10]
  4454d9:	lea    r10,[rbp-0x830]
  4454e0:	mov    r9,QWORD PTR [r10+0x8]
  4454e4:	mov    r10,QWORD PTR [rbp-0x21b0]
  4454eb:	mov    r11,rdi
  4454ee:	mov    QWORD PTR [r10+0x8],r11
  4454f2:	mov    rdi,rsi
  4454f5:	sub    rdi,0x2
  4454fc:	mov    r10,QWORD PTR [rbp-0x21b0]
  445503:	mov    r11,rdi
  445506:	mov    QWORD PTR [r10+0x108],r11
  44550d:	mov    QWORD PTR [rdx],r8
  445510:	mov    QWORD PTR [rdx+0x8],r9
  445514:	movabs rdi,0x2c
  44551e:	shl    rdi,0x28
  445522:	movabs r11,0x200000000000000
  44552c:	mov    rsi,rdi
  44552f:	or     rsi,r11
  445532:	mov    r11,QWORD PTR [rbp-0x21b8]
  445539:	mov    rbx,rsi
  44553c:	or     rbx,r11
  44553f:	jmp    445570 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3bea>
  445544:	mov    rdi,r12
  445547:	movabs rsi,0x2c
  445551:	mov    esi,esi
  445553:	lea    rdx,[rbp-0x830]
  44555a:	movabs rcx,0x2
  445564:	mov    ecx,ecx
  445566:	xor    eax,eax
  445568:	call   461a80 <p111_rt_ctor>
  44556d:	mov    rbx,rax
  445570:	mov    rdi,rbx
  445573:	lea    r10,[rbp-0x830]
  44557a:	mov    r11,QWORD PTR [rbp-0x8a8]
  445581:	mov    QWORD PTR [r10],r11
  445584:	lea    r10,[rbp-0x830]
  44558b:	mov    r11,QWORD PTR [rbp-0x21a0]
  445592:	mov    QWORD PTR [r10+0x8],r11
  445596:	lea    r10,[rbp-0x830]
  44559d:	mov    r11,rdi
  4455a0:	mov    QWORD PTR [r10+0x10],r11
  4455a4:	mov    r10,r12
  4455a7:	mov    r10,QWORD PTR [r10+0x8]
  4455ab:	mov    QWORD PTR [rbp-0x2220],r10
  4455b2:	mov    r10,QWORD PTR [r10+0x10]
  4455b6:	mov    QWORD PTR [rbp-0x2228],r10
  4455bd:	cmp    r10,0x0
  4455c4:	je     445685 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3cff>
  4455ca:	mov    rdi,QWORD PTR [r12]
  4455ce:	mov    rsi,QWORD PTR [rbp-0x2228]
  4455d5:	shl    rsi,0x3
  4455d9:	mov    rdx,rdi
  4455dc:	add    rdx,rsi
  4455df:	mov    rdi,QWORD PTR [rdx]
  4455e2:	mov    r10,QWORD PTR [rbp-0x2220]
  4455e9:	mov    rsi,QWORD PTR [r10+0x110]
  4455f0:	lea    r10,[rbp-0x830]
  4455f7:	mov    r8,QWORD PTR [r10]
  4455fa:	lea    r10,[rbp-0x830]
  445601:	mov    r9,QWORD PTR [r10+0x8]
  445605:	lea    r10,[rbp-0x830]
  44560c:	mov    r10,QWORD PTR [r10+0x10]
  445610:	mov    QWORD PTR [rbp-0x2270],r10
  445617:	mov    r10,QWORD PTR [rbp-0x2220]
  44561e:	mov    r11,rdi
  445621:	mov    QWORD PTR [r10+0x10],r11
  445625:	mov    rdi,rsi
  445628:	sub    rdi,0x4
  44562f:	mov    r10,QWORD PTR [rbp-0x2220]
  445636:	mov    r11,rdi
  445639:	mov    QWORD PTR [r10+0x110],r11
  445640:	mov    QWORD PTR [rdx],r8
  445643:	mov    QWORD PTR [rdx+0x8],r9
  445647:	mov    r10,rdx
  44564a:	mov    r11,QWORD PTR [rbp-0x2270]
  445651:	mov    QWORD PTR [r10+0x10],r11
  445655:	movabs rdi,0x2d
  44565f:	shl    rdi,0x28
  445663:	movabs r11,0x200000000000000
  44566d:	mov    rsi,rdi
  445670:	or     rsi,r11
  445673:	mov    r11,QWORD PTR [rbp-0x2228]
  44567a:	mov    rbx,rsi
  44567d:	or     rbx,r11
  445680:	jmp    4456b1 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3d2b>
  445685:	mov    rdi,r12
  445688:	movabs rsi,0x2d
  445692:	mov    esi,esi
  445694:	lea    rdx,[rbp-0x830]
  44569b:	movabs rcx,0x3
  4456a5:	mov    ecx,ecx
  4456a7:	xor    eax,eax
  4456a9:	call   461a80 <p111_rt_ctor>
  4456ae:	mov    rbx,rax
  4456b1:	mov    r10,rbx
  4456b4:	mov    QWORD PTR [rbp-0x2290],r10
  4456bb:	mov    rdi,QWORD PTR [rbp-0x1c58]
  4456c2:	lea    r10,[rbp-0x830]
  4456c9:	mov    r11,rdi
  4456cc:	mov    QWORD PTR [r10],r11
  4456cf:	mov    r10,r12
  4456d2:	mov    r10,QWORD PTR [r10+0x8]
  4456d6:	mov    QWORD PTR [rbp-0x22a0],r10
  4456dd:	mov    r10,QWORD PTR [r10]
  4456e0:	mov    QWORD PTR [rbp-0x22a8],r10
  4456e7:	cmp    r10,0x0
  4456ee:	je     44577f <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3df9>
  4456f4:	mov    rdi,QWORD PTR [r12]
  4456f8:	mov    rsi,QWORD PTR [rbp-0x22a8]
  4456ff:	shl    rsi,0x3
  445703:	mov    rdx,rdi
  445706:	add    rdx,rsi
  445709:	mov    rdi,QWORD PTR [rdx]
  44570c:	mov    r10,QWORD PTR [rbp-0x22a0]
  445713:	mov    rsi,QWORD PTR [r10+0x100]
  44571a:	lea    r10,[rbp-0x830]
  445721:	mov    r8,QWORD PTR [r10]
  445724:	mov    r10,QWORD PTR [rbp-0x22a0]
  44572b:	mov    r11,rdi
  44572e:	mov    QWORD PTR [r10],r11
  445731:	mov    rdi,rsi
  445734:	sub    rdi,0x1
  44573b:	mov    r10,QWORD PTR [rbp-0x22a0]
  445742:	mov    r11,rdi
  445745:	mov    QWORD PTR [r10+0x100],r11
  44574c:	mov    QWORD PTR [rdx],r8
  44574f:	movabs rdi,0xc
  445759:	shl    rdi,0x28
  44575d:	movabs r11,0x200000000000000
  445767:	mov    rsi,rdi
  44576a:	or     rsi,r11
  44576d:	mov    r11,QWORD PTR [rbp-0x22a8]
  445774:	mov    rbx,rsi
  445777:	or     rbx,r11
  44577a:	jmp    4457ab <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3e25>
  44577f:	mov    rdi,r12
  445782:	movabs rsi,0xc
  44578c:	mov    esi,esi
  44578e:	lea    rdx,[rbp-0x830]
  445795:	movabs rcx,0x1
  44579f:	mov    ecx,ecx
  4457a1:	xor    eax,eax
  4457a3:	call   461a80 <p111_rt_ctor>
  4457a8:	mov    rbx,rax
  4457ab:	mov    rdi,rbx
  4457ae:	lea    r10,[rbp-0x830]
  4457b5:	mov    r11,QWORD PTR [rbp-0x2120]
  4457bc:	mov    QWORD PTR [r10],r11
  4457bf:	lea    r10,[rbp-0x830]
  4457c6:	mov    r11,rdi
  4457c9:	mov    QWORD PTR [r10+0x8],r11
  4457cd:	mov    r10,r12
  4457d0:	mov    r10,QWORD PTR [r10+0x8]
  4457d4:	mov    QWORD PTR [rbp-0x2308],r10
  4457db:	mov    r10,QWORD PTR [r10+0x8]
  4457df:	mov    QWORD PTR [rbp-0x2310],r10
  4457e6:	cmp    r10,0x0
  4457ed:	je     44588e <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3f08>
  4457f3:	mov    rdi,QWORD PTR [r12]
  4457f7:	mov    rsi,QWORD PTR [rbp-0x2310]
  4457fe:	shl    rsi,0x3
  445802:	mov    rdx,rdi
  445805:	add    rdx,rsi
  445808:	mov    rdi,QWORD PTR [rdx]
  44580b:	mov    r10,QWORD PTR [rbp-0x2308]
  445812:	mov    rsi,QWORD PTR [r10+0x108]
  445819:	lea    r10,[rbp-0x830]
  445820:	mov    r8,QWORD PTR [r10]
  445823:	lea    r10,[rbp-0x830]
  44582a:	mov    r9,QWORD PTR [r10+0x8]
  44582e:	mov    r10,QWORD PTR [rbp-0x2308]
  445835:	mov    r11,rdi
  445838:	mov    QWORD PTR [r10+0x8],r11
  44583c:	mov    rdi,rsi
  44583f:	sub    rdi,0x2
  445846:	mov    r10,QWORD PTR [rbp-0x2308]
  44584d:	mov    r11,rdi
  445850:	mov    QWORD PTR [r10+0x108],r11
  445857:	mov    QWORD PTR [rdx],r8
  44585a:	mov    QWORD PTR [rdx+0x8],r9
  44585e:	movabs rdi,0x8
  445868:	shl    rdi,0x28
  44586c:	movabs r11,0x200000000000000
  445876:	mov    rsi,rdi
  445879:	or     rsi,r11
  44587c:	mov    r11,QWORD PTR [rbp-0x2310]
  445883:	mov    rbx,rsi
  445886:	or     rbx,r11
  445889:	jmp    4458ba <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x3f34>
  44588e:	mov    rdi,r12
  445891:	movabs rsi,0x8
  44589b:	mov    esi,esi
  44589d:	lea    rdx,[rbp-0x830]
  4458a4:	movabs rcx,0x2
  4458ae:	mov    ecx,ecx
  4458b0:	xor    eax,eax
  4458b2:	call   461a80 <p111_rt_ctor>
  4458b7:	mov    rbx,rax
  4458ba:	mov    rdi,rbx
  4458bd:	lea    r10,[rbp-0x830]
  4458c4:	mov    r11,QWORD PTR [rbp-0x2290]
  4458cb:	mov    QWORD PTR [r10],r11
  4458ce:	lea    r10,[rbp-0x830]
  4458d5:	mov    r11,rdi
  4458d8:	mov    QWORD PTR [r10+0x8],r11
  4458dc:	mov    r10,r12
  4458df:	mov    r10,QWORD PTR [r10+0x8]
  4458e3:	mov    QWORD PTR [rbp-0x2378],r10
  4458ea:	mov    r10,QWORD PTR [r10+0x8]
  4458ee:	mov    QWORD PTR [rbp-0x2380],r10
  4458f5:	cmp    r10,0x0
  4458fc:	je     44599d <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x4017>
  445902:	mov    rdi,QWORD PTR [r12]
  445906:	mov    rsi,QWORD PTR [rbp-0x2380]
  44590d:	shl    rsi,0x3
  445911:	mov    rdx,rdi
  445914:	add    rdx,rsi
  445917:	mov    rdi,QWORD PTR [rdx]
  44591a:	mov    r10,QWORD PTR [rbp-0x2378]
  445921:	mov    rsi,QWORD PTR [r10+0x108]
  445928:	lea    r10,[rbp-0x830]
  44592f:	mov    r8,QWORD PTR [r10]
  445932:	lea    r10,[rbp-0x830]
  445939:	mov    r9,QWORD PTR [r10+0x8]
  44593d:	mov    r10,QWORD PTR [rbp-0x2378]
  445944:	mov    r11,rdi
  445947:	mov    QWORD PTR [r10+0x8],r11
  44594b:	mov    rdi,rsi
  44594e:	sub    rdi,0x2
  445955:	mov    r10,QWORD PTR [rbp-0x2378]
  44595c:	mov    r11,rdi
  44595f:	mov    QWORD PTR [r10+0x108],r11
  445966:	mov    QWORD PTR [rdx],r8
  445969:	mov    QWORD PTR [rdx+0x8],r9
  44596d:	movabs rdi,0x8
  445977:	shl    rdi,0x28
  44597b:	movabs r11,0x200000000000000
  445985:	mov    rsi,rdi
  445988:	or     rsi,r11
  44598b:	mov    r11,QWORD PTR [rbp-0x2380]
  445992:	mov    rbx,rsi
  445995:	or     rbx,r11
  445998:	jmp    4459c9 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x4043>
  44599d:	mov    rdi,r12
  4459a0:	movabs rsi,0x8
  4459aa:	mov    esi,esi
  4459ac:	lea    rdx,[rbp-0x830]
  4459b3:	movabs rcx,0x2
  4459bd:	mov    ecx,ecx
  4459bf:	xor    eax,eax
  4459c1:	call   461a80 <p111_rt_ctor>
  4459c6:	mov    rbx,rax
  4459c9:	lea    r10,[rbp-0x830]
  4459d0:	mov    r11,rbx
  4459d3:	mov    QWORD PTR [r10],r11
  4459d6:	lea    r10,[rip+0x2b203]        # 470be0 <p111_program>
  4459dd:	movabs rdi,0x4
  4459e7:	and    rdi,QWORD PTR [r10+0x58]
  4459eb:	mov    r10,rdi
  4459ee:	test   r10d,r10d
  4459f1:	je     445a4f <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x40c9>
  4459f7:	lea    r10,[rbp-0x830]
  4459fe:	mov    rdi,QWORD PTR [r10]
  445a01:	mov    QWORD PTR [r12+0x28],rdi
  445a06:	mov    r10,r12
  445a09:	movabs r11,0x1
  445a13:	mov    DWORD PTR [r10+0x1c],r11d
  445a17:	mov    rdi,QWORD PTR [r12+0x10]
  445a1c:	movabs r11,0xfffffffffffffff8
  445a26:	mov    rsi,rdi
  445a29:	add    rsi,r11
  445a2c:	mov    QWORD PTR [r12+0x10],rsi
  445a31:	mov    rdi,QWORD PTR [rsi]
  445a34:	mov    DWORD PTR [r12+0x20],edi
  445a39:	movabs r10,0x0
  445a43:	mov    QWORD PTR [rbp-0xa90],r10
  445a4a:	jmp    445a73 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x40ed>
  445a4f:	mov    rdi,r12
  445a52:	lea    rsi,[rbp-0x830]
  445a59:	movabs rdx,0x1
  445a63:	mov    edx,edx
  445a65:	xor    eax,eax
  445a67:	call   462030 <p111_rt_return>
  445a6c:	mov    QWORD PTR [rbp-0xa90],rax
  445a73:	mov    rax,QWORD PTR [rbp-0xa90]
  445a7a:	mov    r12,QWORD PTR [rbp-0x10]
  445a7e:	mov    rbx,QWORD PTR [rbp-0x8]
  445a82:	mov    r13,QWORD PTR [rbp-0x18]
  445a86:	mov    r14,QWORD PTR [rbp-0x20]
  445a8a:	mov    r15,QWORD PTR [rbp-0x28]
  445a8e:	mov    rsp,rbp
  445a91:	pop    rbp
  445a92:	ret    
  445a93:	mov    r10,QWORD PTR [rbp-0x2128]
  445a9a:	cmp    r10,0x1
  445aa1:	sete   r10b
  445aa5:	movzx  r10d,r10b
  445aa9:	mov    QWORD PTR [rbp-0x8d0],r10
  445ab0:	mov    r10,QWORD PTR [rbp-0x2128]
  445ab7:	shr    r10,0x28
  445abb:	mov    QWORD PTR [rbp-0x8d8],r10
  445ac2:	and    r10,0x7fffff
  445ac9:	mov    QWORD PTR [rbp-0x8d8],r10
  445ad0:	movabs r10,0x2
  445ada:	or     r10,0x10000
  445ae1:	mov    QWORD PTR [rbp-0x8e0],r10
  445ae8:	mov    r10,QWORD PTR [rbp-0x8d8]
  445aef:	mov    r11,QWORD PTR [rbp-0x8e0]
  445af6:	cmp    r10,r11
  445af9:	sete   r10b
  445afd:	movzx  r10d,r10b
  445b01:	mov    QWORD PTR [rbp-0x8e8],r10
  445b08:	mov    r11,r10
  445b0b:	mov    r13,QWORD PTR [rbp-0x8d0]
  445b12:	or     r13d,r11d
  445b15:	mov    r10,r13
  445b18:	test   r10d,r10d
  445b1b:	je     446288 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x4902>
  445b21:	mov    rdi,QWORD PTR [rbp-0x1c58]
  445b28:	lea    r10,[rbp-0x830]
  445b2f:	mov    r11,rdi
  445b32:	mov    QWORD PTR [r10],r11
  445b35:	lea    r10,[rbp-0x830]
  445b3c:	mov    r11,QWORD PTR [rbp-0x1c60]
  445b43:	mov    QWORD PTR [r10+0x8],r11
  445b47:	mov    r10,r12
  445b4a:	mov    r10,QWORD PTR [r10+0x8]
  445b4e:	mov    QWORD PTR [rbp-0x2418],r10
  445b55:	mov    r10,QWORD PTR [r10+0x8]
  445b59:	mov    QWORD PTR [rbp-0x2420],r10
  445b60:	cmp    r10,0x0
  445b67:	je     445c08 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x4282>
  445b6d:	mov    rdi,QWORD PTR [r12]
  445b71:	mov    rsi,QWORD PTR [rbp-0x2420]
  445b78:	shl    rsi,0x3
  445b7c:	mov    rdx,rdi
  445b7f:	add    rdx,rsi
  445b82:	mov    rdi,QWORD PTR [rdx]
  445b85:	mov    r10,QWORD PTR [rbp-0x2418]
  445b8c:	mov    rsi,QWORD PTR [r10+0x108]
  445b93:	lea    r10,[rbp-0x830]
  445b9a:	mov    r8,QWORD PTR [r10]
  445b9d:	lea    r10,[rbp-0x830]
  445ba4:	mov    r9,QWORD PTR [r10+0x8]
  445ba8:	mov    r10,QWORD PTR [rbp-0x2418]
  445baf:	mov    r11,rdi
  445bb2:	mov    QWORD PTR [r10+0x8],r11
  445bb6:	mov    rdi,rsi
  445bb9:	sub    rdi,0x2
  445bc0:	mov    r10,QWORD PTR [rbp-0x2418]
  445bc7:	mov    r11,rdi
  445bca:	mov    QWORD PTR [r10+0x108],r11
  445bd1:	mov    QWORD PTR [rdx],r8
  445bd4:	mov    QWORD PTR [rdx+0x8],r9
  445bd8:	movabs rdi,0x2c
  445be2:	shl    rdi,0x28
  445be6:	movabs r11,0x200000000000000
  445bf0:	mov    rsi,rdi
  445bf3:	or     rsi,r11
  445bf6:	mov    r11,QWORD PTR [rbp-0x2420]
  445bfd:	mov    rbx,rsi
  445c00:	or     rbx,r11
  445c03:	jmp    445c34 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x42ae>
  445c08:	mov    rdi,r12
  445c0b:	movabs rsi,0x2c
  445c15:	mov    esi,esi
  445c17:	lea    rdx,[rbp-0x830]
  445c1e:	movabs rcx,0x2
  445c28:	mov    ecx,ecx
  445c2a:	xor    eax,eax
  445c2c:	call   461a80 <p111_rt_ctor>
  445c31:	mov    rbx,rax
  445c34:	mov    r10,rbx
  445c37:	mov    QWORD PTR [rbp-0x2480],r10
  445c3e:	mov    rdi,r12
  445c41:	mov    rsi,QWORD PTR [rbp-0x2110]
  445c48:	xor    eax,eax
  445c4a:	call   461980 <p111_rt_keep>
  445c4f:	mov    QWORD PTR [rbp-0x2110],rax
  445c56:	mov    rdi,rax
  445c59:	lea    r10,[rbp-0x830]
  445c60:	mov    r11,rdi
  445c63:	mov    QWORD PTR [r10],r11
  445c66:	lea    r10,[rbp-0x830]
  445c6d:	mov    r11,QWORD PTR [rbp-0x2118]
  445c74:	mov    QWORD PTR [r10+0x8],r11
  445c78:	mov    r10,r12
  445c7b:	mov    r10,QWORD PTR [r10+0x8]
  445c7f:	mov    QWORD PTR [rbp-0x2490],r10
  445c86:	mov    r10,QWORD PTR [r10+0x8]
  445c8a:	mov    QWORD PTR [rbp-0x2498],r10
  445c91:	cmp    r10,0x0
  445c98:	je     445d39 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x43b3>
  445c9e:	mov    rdi,QWORD PTR [r12]
  445ca2:	mov    rsi,QWORD PTR [rbp-0x2498]
  445ca9:	shl    rsi,0x3
  445cad:	mov    rdx,rdi
  445cb0:	add    rdx,rsi
  445cb3:	mov    rdi,QWORD PTR [rdx]
  445cb6:	mov    r10,QWORD PTR [rbp-0x2490]
  445cbd:	mov    rsi,QWORD PTR [r10+0x108]
  445cc4:	lea    r10,[rbp-0x830]
  445ccb:	mov    r8,QWORD PTR [r10]
  445cce:	lea    r10,[rbp-0x830]
  445cd5:	mov    r9,QWORD PTR [r10+0x8]
  445cd9:	mov    r10,QWORD PTR [rbp-0x2490]
  445ce0:	mov    r11,rdi
  445ce3:	mov    QWORD PTR [r10+0x8],r11
  445ce7:	mov    rdi,rsi
  445cea:	sub    rdi,0x2
  445cf1:	mov    r10,QWORD PTR [rbp-0x2490]
  445cf8:	mov    r11,rdi
  445cfb:	mov    QWORD PTR [r10+0x108],r11
  445d02:	mov    QWORD PTR [rdx],r8
  445d05:	mov    QWORD PTR [rdx+0x8],r9
  445d09:	movabs rdi,0x2c
  445d13:	shl    rdi,0x28
  445d17:	movabs r11,0x200000000000000
  445d21:	mov    rsi,rdi
  445d24:	or     rsi,r11
  445d27:	mov    r11,QWORD PTR [rbp-0x2498]
  445d2e:	mov    rbx,rsi
  445d31:	or     rbx,r11
  445d34:	jmp    445d65 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x43df>
  445d39:	mov    rdi,r12
  445d3c:	movabs rsi,0x2c
  445d46:	mov    esi,esi
  445d48:	lea    rdx,[rbp-0x830]
  445d4f:	movabs rcx,0x2
  445d59:	mov    ecx,ecx
  445d5b:	xor    eax,eax
  445d5d:	call   461a80 <p111_rt_ctor>
  445d62:	mov    rbx,rax
  445d65:	mov    rdi,rbx
  445d68:	lea    r10,[rbp-0x830]
  445d6f:	mov    r11,QWORD PTR [rbp-0x8a8]
  445d76:	mov    QWORD PTR [r10],r11
  445d79:	lea    r10,[rbp-0x830]
  445d80:	mov    r11,QWORD PTR [rbp-0x2480]
  445d87:	mov    QWORD PTR [r10+0x8],r11
  445d8b:	lea    r10,[rbp-0x830]
  445d92:	mov    r11,rdi
  445d95:	mov    QWORD PTR [r10+0x10],r11
  445d99:	mov    r10,r12
  445d9c:	mov    r10,QWORD PTR [r10+0x8]
  445da0:	mov    QWORD PTR [rbp-0x2500],r10
  445da7:	mov    r10,QWORD PTR [r10+0x10]
  445dab:	mov    QWORD PTR [rbp-0x2508],r10
  445db2:	cmp    r10,0x0
  445db9:	je     445e7a <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x44f4>
  445dbf:	mov    rdi,QWORD PTR [r12]
  445dc3:	mov    rsi,QWORD PTR [rbp-0x2508]
  445dca:	shl    rsi,0x3
  445dce:	mov    rdx,rdi
  445dd1:	add    rdx,rsi
  445dd4:	mov    rdi,QWORD PTR [rdx]
  445dd7:	mov    r10,QWORD PTR [rbp-0x2500]
  445dde:	mov    rsi,QWORD PTR [r10+0x110]
  445de5:	lea    r10,[rbp-0x830]
  445dec:	mov    r8,QWORD PTR [r10]
  445def:	lea    r10,[rbp-0x830]
  445df6:	mov    r9,QWORD PTR [r10+0x8]
  445dfa:	lea    r10,[rbp-0x830]
  445e01:	mov    r10,QWORD PTR [r10+0x10]
  445e05:	mov    QWORD PTR [rbp-0x2550],r10
  445e0c:	mov    r10,QWORD PTR [rbp-0x2500]
  445e13:	mov    r11,rdi
  445e16:	mov    QWORD PTR [r10+0x10],r11
  445e1a:	mov    rdi,rsi
  445e1d:	sub    rdi,0x4
  445e24:	mov    r10,QWORD PTR [rbp-0x2500]
  445e2b:	mov    r11,rdi
  445e2e:	mov    QWORD PTR [r10+0x110],r11
  445e35:	mov    QWORD PTR [rdx],r8
  445e38:	mov    QWORD PTR [rdx+0x8],r9
  445e3c:	mov    r10,rdx
  445e3f:	mov    r11,QWORD PTR [rbp-0x2550]
  445e46:	mov    QWORD PTR [r10+0x10],r11
  445e4a:	movabs rdi,0x2d
  445e54:	shl    rdi,0x28
  445e58:	movabs r11,0x200000000000000
  445e62:	mov    rsi,rdi
  445e65:	or     rsi,r11
  445e68:	mov    r11,QWORD PTR [rbp-0x2508]
  445e6f:	mov    rbx,rsi
  445e72:	or     rbx,r11
  445e75:	jmp    445ea6 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x4520>
  445e7a:	mov    rdi,r12
  445e7d:	movabs rsi,0x2d
  445e87:	mov    esi,esi
  445e89:	lea    rdx,[rbp-0x830]
  445e90:	movabs rcx,0x3
  445e9a:	mov    ecx,ecx
  445e9c:	xor    eax,eax
  445e9e:	call   461a80 <p111_rt_ctor>
  445ea3:	mov    rbx,rax
  445ea6:	mov    r10,rbx
  445ea9:	mov    QWORD PTR [rbp-0x2570],r10
  445eb0:	mov    rdi,QWORD PTR [rbp-0x2110]
  445eb7:	lea    r10,[rbp-0x830]
  445ebe:	mov    r11,rdi
  445ec1:	mov    QWORD PTR [r10],r11
  445ec4:	mov    r10,r12
  445ec7:	mov    r10,QWORD PTR [r10+0x8]
  445ecb:	mov    QWORD PTR [rbp-0x2580],r10
  445ed2:	mov    r10,QWORD PTR [r10]
  445ed5:	mov    QWORD PTR [rbp-0x2588],r10
  445edc:	cmp    r10,0x0
  445ee3:	je     445f74 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x45ee>
  445ee9:	mov    rdi,QWORD PTR [r12]
  445eed:	mov    rsi,QWORD PTR [rbp-0x2588]
  445ef4:	shl    rsi,0x3
  445ef8:	mov    rdx,rdi
  445efb:	add    rdx,rsi
  445efe:	mov    rdi,QWORD PTR [rdx]
  445f01:	mov    r10,QWORD PTR [rbp-0x2580]
  445f08:	mov    rsi,QWORD PTR [r10+0x100]
  445f0f:	lea    r10,[rbp-0x830]
  445f16:	mov    r8,QWORD PTR [r10]
  445f19:	mov    r10,QWORD PTR [rbp-0x2580]
  445f20:	mov    r11,rdi
  445f23:	mov    QWORD PTR [r10],r11
  445f26:	mov    rdi,rsi
  445f29:	sub    rdi,0x1
  445f30:	mov    r10,QWORD PTR [rbp-0x2580]
  445f37:	mov    r11,rdi
  445f3a:	mov    QWORD PTR [r10+0x100],r11
  445f41:	mov    QWORD PTR [rdx],r8
  445f44:	movabs rdi,0xc
  445f4e:	shl    rdi,0x28
  445f52:	movabs r11,0x200000000000000
  445f5c:	mov    rsi,rdi
  445f5f:	or     rsi,r11
  445f62:	mov    r11,QWORD PTR [rbp-0x2588]
  445f69:	mov    rbx,rsi
  445f6c:	or     rbx,r11
  445f6f:	jmp    445fa0 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x461a>
  445f74:	mov    rdi,r12
  445f77:	movabs rsi,0xc
  445f81:	mov    esi,esi
  445f83:	lea    rdx,[rbp-0x830]
  445f8a:	movabs rcx,0x1
  445f94:	mov    ecx,ecx
  445f96:	xor    eax,eax
  445f98:	call   461a80 <p111_rt_ctor>
  445f9d:	mov    rbx,rax
  445fa0:	mov    rdi,rbx
  445fa3:	lea    r10,[rbp-0x830]
  445faa:	mov    r11,QWORD PTR [rbp-0x2120]
  445fb1:	mov    QWORD PTR [r10],r11
  445fb4:	lea    r10,[rbp-0x830]
  445fbb:	mov    r11,rdi
  445fbe:	mov    QWORD PTR [r10+0x8],r11
  445fc2:	mov    r10,r12
  445fc5:	mov    r10,QWORD PTR [r10+0x8]
  445fc9:	mov    QWORD PTR [rbp-0x25e8],r10
  445fd0:	mov    r10,QWORD PTR [r10+0x8]
  445fd4:	mov    QWORD PTR [rbp-0x25f0],r10
  445fdb:	cmp    r10,0x0
  445fe2:	je     446083 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x46fd>
  445fe8:	mov    rdi,QWORD PTR [r12]
  445fec:	mov    rsi,QWORD PTR [rbp-0x25f0]
  445ff3:	shl    rsi,0x3
  445ff7:	mov    rdx,rdi
  445ffa:	add    rdx,rsi
  445ffd:	mov    rdi,QWORD PTR [rdx]
  446000:	mov    r10,QWORD PTR [rbp-0x25e8]
  446007:	mov    rsi,QWORD PTR [r10+0x108]
  44600e:	lea    r10,[rbp-0x830]
  446015:	mov    r8,QWORD PTR [r10]
  446018:	lea    r10,[rbp-0x830]
  44601f:	mov    r9,QWORD PTR [r10+0x8]
  446023:	mov    r10,QWORD PTR [rbp-0x25e8]
  44602a:	mov    r11,rdi
  44602d:	mov    QWORD PTR [r10+0x8],r11
  446031:	mov    rdi,rsi
  446034:	sub    rdi,0x2
  44603b:	mov    r10,QWORD PTR [rbp-0x25e8]
  446042:	mov    r11,rdi
  446045:	mov    QWORD PTR [r10+0x108],r11
  44604c:	mov    QWORD PTR [rdx],r8
  44604f:	mov    QWORD PTR [rdx+0x8],r9
  446053:	movabs rdi,0x8
  44605d:	shl    rdi,0x28
  446061:	movabs r11,0x200000000000000
  44606b:	mov    rsi,rdi
  44606e:	or     rsi,r11
  446071:	mov    r11,QWORD PTR [rbp-0x25f0]
  446078:	mov    rbx,rsi
  44607b:	or     rbx,r11
  44607e:	jmp    4460af <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x4729>
  446083:	mov    rdi,r12
  446086:	movabs rsi,0x8
  446090:	mov    esi,esi
  446092:	lea    rdx,[rbp-0x830]
  446099:	movabs rcx,0x2
  4460a3:	mov    ecx,ecx
  4460a5:	xor    eax,eax
  4460a7:	call   461a80 <p111_rt_ctor>
  4460ac:	mov    rbx,rax
  4460af:	mov    rdi,rbx
  4460b2:	lea    r10,[rbp-0x830]
  4460b9:	mov    r11,QWORD PTR [rbp-0x2570]
  4460c0:	mov    QWORD PTR [r10],r11
  4460c3:	lea    r10,[rbp-0x830]
  4460ca:	mov    r11,rdi
  4460cd:	mov    QWORD PTR [r10+0x8],r11
  4460d1:	mov    r10,r12
  4460d4:	mov    r10,QWORD PTR [r10+0x8]
  4460d8:	mov    QWORD PTR [rbp-0x2658],r10
  4460df:	mov    r10,QWORD PTR [r10+0x8]
  4460e3:	mov    QWORD PTR [rbp-0x2660],r10
  4460ea:	cmp    r10,0x0
  4460f1:	je     446192 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x480c>
  4460f7:	mov    rdi,QWORD PTR [r12]
  4460fb:	mov    rsi,QWORD PTR [rbp-0x2660]
  446102:	shl    rsi,0x3
  446106:	mov    rdx,rdi
  446109:	add    rdx,rsi
  44610c:	mov    rdi,QWORD PTR [rdx]
  44610f:	mov    r10,QWORD PTR [rbp-0x2658]
  446116:	mov    rsi,QWORD PTR [r10+0x108]
  44611d:	lea    r10,[rbp-0x830]
  446124:	mov    r8,QWORD PTR [r10]
  446127:	lea    r10,[rbp-0x830]
  44612e:	mov    r9,QWORD PTR [r10+0x8]
  446132:	mov    r10,QWORD PTR [rbp-0x2658]
  446139:	mov    r11,rdi
  44613c:	mov    QWORD PTR [r10+0x8],r11
  446140:	mov    rdi,rsi
  446143:	sub    rdi,0x2
  44614a:	mov    r10,QWORD PTR [rbp-0x2658]
  446151:	mov    r11,rdi
  446154:	mov    QWORD PTR [r10+0x108],r11
  44615b:	mov    QWORD PTR [rdx],r8
  44615e:	mov    QWORD PTR [rdx+0x8],r9
  446162:	movabs rdi,0x8
  44616c:	shl    rdi,0x28
  446170:	movabs r11,0x200000000000000
  44617a:	mov    rsi,rdi
  44617d:	or     rsi,r11
  446180:	mov    r11,QWORD PTR [rbp-0x2660]
  446187:	mov    rbx,rsi
  44618a:	or     rbx,r11
  44618d:	jmp    4461be <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x4838>
  446192:	mov    rdi,r12
  446195:	movabs rsi,0x8
  44619f:	mov    esi,esi
  4461a1:	lea    rdx,[rbp-0x830]
  4461a8:	movabs rcx,0x2
  4461b2:	mov    ecx,ecx
  4461b4:	xor    eax,eax
  4461b6:	call   461a80 <p111_rt_ctor>
  4461bb:	mov    rbx,rax
  4461be:	lea    r10,[rbp-0x830]
  4461c5:	mov    r11,rbx
  4461c8:	mov    QWORD PTR [r10],r11
  4461cb:	lea    r10,[rip+0x2aa0e]        # 470be0 <p111_program>
  4461d2:	movabs rdi,0x4
  4461dc:	and    rdi,QWORD PTR [r10+0x58]
  4461e0:	mov    r10,rdi
  4461e3:	test   r10d,r10d
  4461e6:	je     446244 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x48be>
  4461ec:	lea    r10,[rbp-0x830]
  4461f3:	mov    rdi,QWORD PTR [r10]
  4461f6:	mov    QWORD PTR [r12+0x28],rdi
  4461fb:	mov    r10,r12
  4461fe:	movabs r11,0x1
  446208:	mov    DWORD PTR [r10+0x1c],r11d
  44620c:	mov    rdi,QWORD PTR [r12+0x10]
  446211:	movabs r11,0xfffffffffffffff8
  44621b:	mov    rsi,rdi
  44621e:	add    rsi,r11
  446221:	mov    QWORD PTR [r12+0x10],rsi
  446226:	mov    rdi,QWORD PTR [rsi]
  446229:	mov    DWORD PTR [r12+0x20],edi
  44622e:	movabs r10,0x0
  446238:	mov    QWORD PTR [rbp-0xa90],r10
  44623f:	jmp    446268 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x48e2>
  446244:	mov    rdi,r12
  446247:	lea    rsi,[rbp-0x830]
  44624e:	movabs rdx,0x1
  446258:	mov    edx,edx
  44625a:	xor    eax,eax
  44625c:	call   462030 <p111_rt_return>
  446261:	mov    QWORD PTR [rbp-0xa90],rax
  446268:	mov    rax,QWORD PTR [rbp-0xa90]
  44626f:	mov    r12,QWORD PTR [rbp-0x10]
  446273:	mov    rbx,QWORD PTR [rbp-0x8]
  446277:	mov    r13,QWORD PTR [rbp-0x18]
  44627b:	mov    r14,QWORD PTR [rbp-0x20]
  44627f:	mov    r15,QWORD PTR [rbp-0x28]
  446283:	mov    rsp,rbp
  446286:	pop    rbp
  446287:	ret    
  446288:	mov    rdi,r12
  44628b:	mov    rsi,QWORD PTR [rbp-0x8a8]
  446292:	xor    eax,eax
  446294:	call   461a10 <p111_rt_sink>
  446299:	mov    QWORD PTR [rbp-0x8a0],rax
  4462a0:	mov    rdi,r12
  4462a3:	mov    rsi,QWORD PTR [rbp-0x1c58]
  4462aa:	xor    eax,eax
  4462ac:	call   461a10 <p111_rt_sink>
  4462b1:	mov    QWORD PTR [rbp-0x8a0],rax
  4462b8:	mov    rdi,r12
  4462bb:	mov    rsi,QWORD PTR [rbp-0x1c60]
  4462c2:	xor    eax,eax
  4462c4:	call   461a10 <p111_rt_sink>
  4462c9:	mov    QWORD PTR [rbp-0x8a0],rax
  4462d0:	mov    rdi,r12
  4462d3:	mov    rsi,QWORD PTR [rbp-0x2110]
  4462da:	xor    eax,eax
  4462dc:	call   461a10 <p111_rt_sink>
  4462e1:	mov    QWORD PTR [rbp-0x8a0],rax
  4462e8:	mov    rdi,r12
  4462eb:	mov    rsi,QWORD PTR [rbp-0x2118]
  4462f2:	xor    eax,eax
  4462f4:	call   461a10 <p111_rt_sink>
  4462f9:	mov    QWORD PTR [rbp-0x8a0],rax
  446300:	mov    rdi,r12
  446303:	mov    rsi,QWORD PTR [rbp-0x2120]
  44630a:	xor    eax,eax
  44630c:	call   461a10 <p111_rt_sink>
  446311:	mov    QWORD PTR [rbp-0x8a0],rax
  446318:	lea    r10,[rbp-0x830]
  44631f:	mov    r11,QWORD PTR [rbp-0x2128]
  446326:	mov    QWORD PTR [r10],r11
  446329:	mov    rdi,QWORD PTR [r12+0x10]
  44632e:	mov    r10,rdi
  446331:	mov    r11,QWORD PTR [rbp-0x2128]
  446338:	mov    QWORD PTR [r10],r11
  44633b:	mov    r10,rdi
  44633e:	movabs r11,0x15e
  446348:	mov    QWORD PTR [r10+0x8],r11
  44634c:	mov    rsi,rdi
  44634f:	add    rsi,0x10
  446356:	mov    QWORD PTR [r12+0x10],rsi
  44635b:	mov    rdi,r12
  44635e:	movabs rsi,0x4
  446368:	mov    esi,esi
  44636a:	xor    eax,eax
  44636c:	call   4621a0 <p111_rt_fail>
  446371:	mov    QWORD PTR [rbp-0xa90],rax
  446378:	mov    r12,QWORD PTR [rbp-0x10]
  44637c:	mov    rbx,QWORD PTR [rbp-0x8]
  446380:	mov    r13,QWORD PTR [rbp-0x18]
  446384:	mov    r14,QWORD PTR [rbp-0x20]
  446388:	mov    r15,QWORD PTR [rbp-0x28]
  44638c:	mov    rsp,rbp
  44638f:	pop    rbp
  446390:	ret    
  446391:	mov    rdi,r12
  446394:	mov    rsi,QWORD PTR [rbp-0x8a8]
  44639b:	xor    eax,eax
  44639d:	call   461a10 <p111_rt_sink>
  4463a2:	mov    QWORD PTR [rbp-0x8a0],rax
  4463a9:	mov    rdi,r12
  4463ac:	mov    rsi,QWORD PTR [rbp-0x1c58]
  4463b3:	xor    eax,eax
  4463b5:	call   461a10 <p111_rt_sink>
  4463ba:	mov    QWORD PTR [rbp-0x8a0],rax
  4463c1:	mov    rdi,r12
  4463c4:	mov    rsi,QWORD PTR [rbp-0x1c60]
  4463cb:	xor    eax,eax
  4463cd:	call   461a10 <p111_rt_sink>
  4463d2:	mov    QWORD PTR [rbp-0x8a0],rax
  4463d9:	mov    rdi,r12
  4463dc:	mov    rsi,QWORD PTR [rbp-0x2110]
  4463e3:	xor    eax,eax
  4463e5:	call   461a10 <p111_rt_sink>
  4463ea:	mov    QWORD PTR [rbp-0x8a0],rax
  4463f1:	mov    rdi,r12
  4463f4:	mov    rsi,QWORD PTR [rbp-0x2118]
  4463fb:	xor    eax,eax
  4463fd:	call   461a10 <p111_rt_sink>
  446402:	mov    QWORD PTR [rbp-0x8a0],rax
  446409:	lea    r10,[rbp-0x830]
  446410:	mov    r11,r14
  446413:	mov    QWORD PTR [r10],r11
  446416:	mov    rdi,QWORD PTR [r12+0x10]
  44641b:	mov    QWORD PTR [rdi],r14
  44641e:	mov    r10,rdi
  446421:	movabs r11,0x15f
  44642b:	mov    QWORD PTR [r10+0x8],r11
  44642f:	mov    rsi,rdi
  446432:	add    rsi,0x10
  446439:	mov    QWORD PTR [r12+0x10],rsi
  44643e:	mov    rdi,r12
  446441:	movabs rsi,0x4
  44644b:	mov    esi,esi
  44644d:	xor    eax,eax
  44644f:	call   4621a0 <p111_rt_fail>
  446454:	mov    QWORD PTR [rbp-0xa90],rax
  44645b:	mov    r12,QWORD PTR [rbp-0x10]
  44645f:	mov    rbx,QWORD PTR [rbp-0x8]
  446463:	mov    r13,QWORD PTR [rbp-0x18]
  446467:	mov    r14,QWORD PTR [rbp-0x20]
  44646b:	mov    r15,QWORD PTR [rbp-0x28]
  44646f:	mov    rsp,rbp
  446472:	pop    rbp
  446473:	ret    
  446474:	mov    r15,QWORD PTR [rbp-0x8b8]
  44647b:	shr    r15,0x28
  44647f:	and    r15,0xffff
  446486:	movabs r11,0x2d
  446490:	mov    r13,r15
  446493:	cmp    r13,r11
  446496:	sete   r13b
  44649a:	movzx  r13d,r13b
  44649e:	mov    r10,r13
  4464a1:	test   r10d,r10d
  4464a4:	je     44742d <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x5aa7>
  4464aa:	mov    rdi,r12
  4464ad:	mov    rsi,QWORD PTR [rbp-0x8b8]
  4464b4:	lea    rdx,[rbp-0x830]
  4464bb:	xor    eax,eax
  4464bd:	call   467a10 <p125_rt_take3>
  4464c2:	mov    QWORD PTR [rbp-0x8a0],rax
  4464c9:	lea    r10,[rbp-0x830]
  4464d0:	mov    r10,QWORD PTR [r10]
  4464d3:	mov    QWORD PTR [rbp-0x2710],r10
  4464da:	lea    r10,[rbp-0x830]
  4464e1:	mov    r10,QWORD PTR [r10+0x8]
  4464e5:	mov    QWORD PTR [rbp-0x2718],r10
  4464ec:	lea    r10,[rbp-0x830]
  4464f3:	mov    r10,QWORD PTR [r10+0x10]
  4464f7:	mov    QWORD PTR [rbp-0x2720],r10
  4464fe:	mov    r15,r14
  446501:	shr    r15,0x28
  446505:	and    r15,0xffff
  44650c:	movabs r11,0x8
  446516:	mov    r13,r15
  446519:	cmp    r13,r11
  44651c:	sete   r13b
  446520:	movzx  r13d,r13b
  446524:	mov    r10,r13
  446527:	test   r10d,r10d
  44652a:	je     447332 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x59ac>
  446530:	mov    rdi,r12
  446533:	mov    rsi,r14
  446536:	lea    rdx,[rbp-0x830]
  44653d:	xor    eax,eax
  44653f:	call   4677b0 <p125_rt_take2>
  446544:	mov    QWORD PTR [rbp-0x8a0],rax
  44654b:	lea    r10,[rbp-0x830]
  446552:	mov    r10,QWORD PTR [r10]
  446555:	mov    QWORD PTR [rbp-0x2728],r10
  44655c:	lea    r10,[rbp-0x830]
  446563:	mov    r10,QWORD PTR [r10+0x8]
  446567:	mov    QWORD PTR [rbp-0x2730],r10
  44656e:	cmp    r10,0x1
  446575:	sete   r10b
  446579:	movzx  r10d,r10b
  44657d:	mov    QWORD PTR [rbp-0x8d0],r10
  446584:	mov    r10,QWORD PTR [rbp-0x2730]
  44658b:	shr    r10,0x28
  44658f:	mov    QWORD PTR [rbp-0x8d8],r10
  446596:	and    r10,0x7fffff
  44659d:	mov    QWORD PTR [rbp-0x8d8],r10
  4465a4:	movabs r10,0x2
  4465ae:	or     r10,0x10000
  4465b5:	mov    QWORD PTR [rbp-0x8e0],r10
  4465bc:	mov    r10,QWORD PTR [rbp-0x8d8]
  4465c3:	mov    r11,QWORD PTR [rbp-0x8e0]
  4465ca:	cmp    r10,r11
  4465cd:	sete   r10b
  4465d1:	movzx  r10d,r10b
  4465d5:	mov    QWORD PTR [rbp-0x8e8],r10
  4465dc:	mov    r11,r10
  4465df:	mov    r13,QWORD PTR [rbp-0x8d0]
  4465e6:	or     r13d,r11d
  4465e9:	xor    r13d,0x1
  4465f0:	mov    r10,r13
  4465f3:	test   r10d,r10d
  4465f6:	je     446d95 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x540f>
  4465fc:	mov    rdi,r12
  4465ff:	mov    rsi,QWORD PTR [rbp-0x1c58]
  446606:	xor    eax,eax
  446608:	call   461980 <p111_rt_keep>
  44660d:	mov    QWORD PTR [rbp-0x1c58],rax
  446614:	mov    rdi,rax
  446617:	lea    r10,[rbp-0x830]
  44661e:	mov    r11,rdi
  446621:	mov    QWORD PTR [r10],r11
  446624:	lea    r10,[rbp-0x830]
  44662b:	mov    r11,QWORD PTR [rbp-0x1c60]
  446632:	mov    QWORD PTR [r10+0x8],r11
  446636:	mov    r10,r12
  446639:	mov    r10,QWORD PTR [r10+0x8]
  44663d:	mov    QWORD PTR [rbp-0x2740],r10
  446644:	mov    r10,QWORD PTR [r10+0x8]
  446648:	mov    QWORD PTR [rbp-0x2748],r10
  44664f:	cmp    r10,0x0
  446656:	je     4466f7 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x4d71>
  44665c:	mov    rdi,QWORD PTR [r12]
  446660:	mov    rsi,QWORD PTR [rbp-0x2748]
  446667:	shl    rsi,0x3
  44666b:	mov    rdx,rdi
  44666e:	add    rdx,rsi
  446671:	mov    rdi,QWORD PTR [rdx]
  446674:	mov    r10,QWORD PTR [rbp-0x2740]
  44667b:	mov    rsi,QWORD PTR [r10+0x108]
  446682:	lea    r10,[rbp-0x830]
  446689:	mov    r8,QWORD PTR [r10]
  44668c:	lea    r10,[rbp-0x830]
  446693:	mov    r9,QWORD PTR [r10+0x8]
  446697:	mov    r10,QWORD PTR [rbp-0x2740]
  44669e:	mov    r11,rdi
  4466a1:	mov    QWORD PTR [r10+0x8],r11
  4466a5:	mov    rdi,rsi
  4466a8:	sub    rdi,0x2
  4466af:	mov    r10,QWORD PTR [rbp-0x2740]
  4466b6:	mov    r11,rdi
  4466b9:	mov    QWORD PTR [r10+0x108],r11
  4466c0:	mov    QWORD PTR [rdx],r8
  4466c3:	mov    QWORD PTR [rdx+0x8],r9
  4466c7:	movabs rdi,0x2c
  4466d1:	shl    rdi,0x28
  4466d5:	movabs r11,0x200000000000000
  4466df:	mov    rsi,rdi
  4466e2:	or     rsi,r11
  4466e5:	mov    r11,QWORD PTR [rbp-0x2748]
  4466ec:	mov    rbx,rsi
  4466ef:	or     rbx,r11
  4466f2:	jmp    446723 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x4d9d>
  4466f7:	mov    rdi,r12
  4466fa:	movabs rsi,0x2c
  446704:	mov    esi,esi
  446706:	lea    rdx,[rbp-0x830]
  44670d:	movabs rcx,0x2
  446717:	mov    ecx,ecx
  446719:	xor    eax,eax
  44671b:	call   461a80 <p111_rt_ctor>
  446720:	mov    rbx,rax
  446723:	mov    r10,rbx
  446726:	mov    QWORD PTR [rbp-0x27a8],r10
  44672d:	mov    rdi,QWORD PTR [rbp-0x2710]
  446734:	lea    r10,[rbp-0x830]
  44673b:	mov    r11,rdi
  44673e:	mov    QWORD PTR [r10],r11
  446741:	lea    r10,[rbp-0x830]
  446748:	mov    r11,QWORD PTR [rbp-0x2718]
  44674f:	mov    QWORD PTR [r10+0x8],r11
  446753:	lea    r10,[rbp-0x830]
  44675a:	mov    r11,QWORD PTR [rbp-0x2720]
  446761:	mov    QWORD PTR [r10+0x10],r11
  446765:	mov    r10,r12
  446768:	mov    r10,QWORD PTR [r10+0x8]
  44676c:	mov    QWORD PTR [rbp-0x27b8],r10
  446773:	mov    r10,QWORD PTR [r10+0x10]
  446777:	mov    QWORD PTR [rbp-0x27c0],r10
  44677e:	cmp    r10,0x0
  446785:	je     446846 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x4ec0>
  44678b:	mov    rdi,QWORD PTR [r12]
  44678f:	mov    rsi,QWORD PTR [rbp-0x27c0]
  446796:	shl    rsi,0x3
  44679a:	mov    rdx,rdi
  44679d:	add    rdx,rsi
  4467a0:	mov    rdi,QWORD PTR [rdx]
  4467a3:	mov    r10,QWORD PTR [rbp-0x27b8]
  4467aa:	mov    rsi,QWORD PTR [r10+0x110]
  4467b1:	lea    r10,[rbp-0x830]
  4467b8:	mov    r8,QWORD PTR [r10]
  4467bb:	lea    r10,[rbp-0x830]
  4467c2:	mov    r9,QWORD PTR [r10+0x8]
  4467c6:	lea    r10,[rbp-0x830]
  4467cd:	mov    r10,QWORD PTR [r10+0x10]
  4467d1:	mov    QWORD PTR [rbp-0x2808],r10
  4467d8:	mov    r10,QWORD PTR [rbp-0x27b8]
  4467df:	mov    r11,rdi
  4467e2:	mov    QWORD PTR [r10+0x10],r11
  4467e6:	mov    rdi,rsi
  4467e9:	sub    rdi,0x4
  4467f0:	mov    r10,QWORD PTR [rbp-0x27b8]
  4467f7:	mov    r11,rdi
  4467fa:	mov    QWORD PTR [r10+0x110],r11
  446801:	mov    QWORD PTR [rdx],r8
  446804:	mov    QWORD PTR [rdx+0x8],r9
  446808:	mov    r10,rdx
  44680b:	mov    r11,QWORD PTR [rbp-0x2808]
  446812:	mov    QWORD PTR [r10+0x10],r11
  446816:	movabs rdi,0x2d
  446820:	shl    rdi,0x28
  446824:	movabs r11,0x200000000000000
  44682e:	mov    rsi,rdi
  446831:	or     rsi,r11
  446834:	mov    r11,QWORD PTR [rbp-0x27c0]
  44683b:	mov    rbx,rsi
  44683e:	or     rbx,r11
  446841:	jmp    446872 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x4eec>
  446846:	mov    rdi,r12
  446849:	movabs rsi,0x2d
  446853:	mov    esi,esi
  446855:	lea    rdx,[rbp-0x830]
  44685c:	movabs rcx,0x3
  446866:	mov    ecx,ecx
  446868:	xor    eax,eax
  44686a:	call   461a80 <p111_rt_ctor>
  44686f:	mov    rbx,rax
  446872:	mov    rdi,rbx
  446875:	lea    r10,[rbp-0x830]
  44687c:	mov    r11,QWORD PTR [rbp-0x8a8]
  446883:	mov    QWORD PTR [r10],r11
  446886:	lea    r10,[rbp-0x830]
  44688d:	mov    r11,QWORD PTR [rbp-0x27a8]
  446894:	mov    QWORD PTR [r10+0x8],r11
  446898:	lea    r10,[rbp-0x830]
  44689f:	mov    r11,rdi
  4468a2:	mov    QWORD PTR [r10+0x10],r11
  4468a6:	mov    r10,r12
  4468a9:	mov    r10,QWORD PTR [r10+0x8]
  4468ad:	mov    QWORD PTR [rbp-0x2830],r10
  4468b4:	mov    r10,QWORD PTR [r10+0x10]
  4468b8:	mov    QWORD PTR [rbp-0x2838],r10
  4468bf:	cmp    r10,0x0
  4468c6:	je     446987 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x5001>
  4468cc:	mov    rdi,QWORD PTR [r12]
  4468d0:	mov    rsi,QWORD PTR [rbp-0x2838]
  4468d7:	shl    rsi,0x3
  4468db:	mov    rdx,rdi
  4468de:	add    rdx,rsi
  4468e1:	mov    rdi,QWORD PTR [rdx]
  4468e4:	mov    r10,QWORD PTR [rbp-0x2830]
  4468eb:	mov    rsi,QWORD PTR [r10+0x110]
  4468f2:	lea    r10,[rbp-0x830]
  4468f9:	mov    r8,QWORD PTR [r10]
  4468fc:	lea    r10,[rbp-0x830]
  446903:	mov    r9,QWORD PTR [r10+0x8]
  446907:	lea    r10,[rbp-0x830]
  44690e:	mov    r10,QWORD PTR [r10+0x10]
  446912:	mov    QWORD PTR [rbp-0x2880],r10
  446919:	mov    r10,QWORD PTR [rbp-0x2830]
  446920:	mov    r11,rdi
  446923:	mov    QWORD PTR [r10+0x10],r11
  446927:	mov    rdi,rsi
  44692a:	sub    rdi,0x4
  446931:	mov    r10,QWORD PTR [rbp-0x2830]
  446938:	mov    r11,rdi
  44693b:	mov    QWORD PTR [r10+0x110],r11
  446942:	mov    QWORD PTR [rdx],r8
  446945:	mov    QWORD PTR [rdx+0x8],r9
  446949:	mov    r10,rdx
  44694c:	mov    r11,QWORD PTR [rbp-0x2880]
  446953:	mov    QWORD PTR [r10+0x10],r11
  446957:	movabs rdi,0x2d
  446961:	shl    rdi,0x28
  446965:	movabs r11,0x200000000000000
  44696f:	mov    rsi,rdi
  446972:	or     rsi,r11
  446975:	mov    r11,QWORD PTR [rbp-0x2838]
  44697c:	mov    rbx,rsi
  44697f:	or     rbx,r11
  446982:	jmp    4469b3 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x502d>
  446987:	mov    rdi,r12
  44698a:	movabs rsi,0x2d
  446994:	mov    esi,esi
  446996:	lea    rdx,[rbp-0x830]
  44699d:	movabs rcx,0x3
  4469a7:	mov    ecx,ecx
  4469a9:	xor    eax,eax
  4469ab:	call   461a80 <p111_rt_ctor>
  4469b0:	mov    rbx,rax
  4469b3:	mov    r10,rbx
  4469b6:	mov    QWORD PTR [rbp-0x28a0],r10
  4469bd:	mov    rdi,QWORD PTR [rbp-0x1c58]
  4469c4:	lea    r10,[rbp-0x830]
  4469cb:	mov    r11,rdi
  4469ce:	mov    QWORD PTR [r10],r11
  4469d1:	mov    r10,r12
  4469d4:	mov    r10,QWORD PTR [r10+0x8]
  4469d8:	mov    QWORD PTR [rbp-0x28b0],r10
  4469df:	mov    r10,QWORD PTR [r10]
  4469e2:	mov    QWORD PTR [rbp-0x28b8],r10
  4469e9:	cmp    r10,0x0
  4469f0:	je     446a81 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x50fb>
  4469f6:	mov    rdi,QWORD PTR [r12]
  4469fa:	mov    rsi,QWORD PTR [rbp-0x28b8]
  446a01:	shl    rsi,0x3
  446a05:	mov    rdx,rdi
  446a08:	add    rdx,rsi
  446a0b:	mov    rdi,QWORD PTR [rdx]
  446a0e:	mov    r10,QWORD PTR [rbp-0x28b0]
  446a15:	mov    rsi,QWORD PTR [r10+0x100]
  446a1c:	lea    r10,[rbp-0x830]
  446a23:	mov    r8,QWORD PTR [r10]
  446a26:	mov    r10,QWORD PTR [rbp-0x28b0]
  446a2d:	mov    r11,rdi
  446a30:	mov    QWORD PTR [r10],r11
  446a33:	mov    rdi,rsi
  446a36:	sub    rdi,0x1
  446a3d:	mov    r10,QWORD PTR [rbp-0x28b0]
  446a44:	mov    r11,rdi
  446a47:	mov    QWORD PTR [r10+0x100],r11
  446a4e:	mov    QWORD PTR [rdx],r8
  446a51:	movabs rdi,0xc
  446a5b:	shl    rdi,0x28
  446a5f:	movabs r11,0x200000000000000
  446a69:	mov    rsi,rdi
  446a6c:	or     rsi,r11
  446a6f:	mov    r11,QWORD PTR [rbp-0x28b8]
  446a76:	mov    rbx,rsi
  446a79:	or     rbx,r11
  446a7c:	jmp    446aad <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x5127>
  446a81:	mov    rdi,r12
  446a84:	movabs rsi,0xc
  446a8e:	mov    esi,esi
  446a90:	lea    rdx,[rbp-0x830]
  446a97:	movabs rcx,0x1
  446aa1:	mov    ecx,ecx
  446aa3:	xor    eax,eax
  446aa5:	call   461a80 <p111_rt_ctor>
  446aaa:	mov    rbx,rax
  446aad:	mov    rdi,rbx
  446ab0:	lea    r10,[rbp-0x830]
  446ab7:	mov    r11,QWORD PTR [rbp-0x2728]
  446abe:	mov    QWORD PTR [r10],r11
  446ac1:	lea    r10,[rbp-0x830]
  446ac8:	mov    r11,rdi
  446acb:	mov    QWORD PTR [r10+0x8],r11
  446acf:	mov    r10,r12
  446ad2:	mov    r10,QWORD PTR [r10+0x8]
  446ad6:	mov    QWORD PTR [rbp-0x2918],r10
  446add:	mov    r10,QWORD PTR [r10+0x8]
  446ae1:	mov    QWORD PTR [rbp-0x2920],r10
  446ae8:	cmp    r10,0x0
  446aef:	je     446b90 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x520a>
  446af5:	mov    rdi,QWORD PTR [r12]
  446af9:	mov    rsi,QWORD PTR [rbp-0x2920]
  446b00:	shl    rsi,0x3
  446b04:	mov    rdx,rdi
  446b07:	add    rdx,rsi
  446b0a:	mov    rdi,QWORD PTR [rdx]
  446b0d:	mov    r10,QWORD PTR [rbp-0x2918]
  446b14:	mov    rsi,QWORD PTR [r10+0x108]
  446b1b:	lea    r10,[rbp-0x830]
  446b22:	mov    r8,QWORD PTR [r10]
  446b25:	lea    r10,[rbp-0x830]
  446b2c:	mov    r9,QWORD PTR [r10+0x8]
  446b30:	mov    r10,QWORD PTR [rbp-0x2918]
  446b37:	mov    r11,rdi
  446b3a:	mov    QWORD PTR [r10+0x8],r11
  446b3e:	mov    rdi,rsi
  446b41:	sub    rdi,0x2
  446b48:	mov    r10,QWORD PTR [rbp-0x2918]
  446b4f:	mov    r11,rdi
  446b52:	mov    QWORD PTR [r10+0x108],r11
  446b59:	mov    QWORD PTR [rdx],r8
  446b5c:	mov    QWORD PTR [rdx+0x8],r9
  446b60:	movabs rdi,0x8
  446b6a:	shl    rdi,0x28
  446b6e:	movabs r11,0x200000000000000
  446b78:	mov    rsi,rdi
  446b7b:	or     rsi,r11
  446b7e:	mov    r11,QWORD PTR [rbp-0x2920]
  446b85:	mov    rbx,rsi
  446b88:	or     rbx,r11
  446b8b:	jmp    446bbc <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x5236>
  446b90:	mov    rdi,r12
  446b93:	movabs rsi,0x8
  446b9d:	mov    esi,esi
  446b9f:	lea    rdx,[rbp-0x830]
  446ba6:	movabs rcx,0x2
  446bb0:	mov    ecx,ecx
  446bb2:	xor    eax,eax
  446bb4:	call   461a80 <p111_rt_ctor>
  446bb9:	mov    rbx,rax
  446bbc:	mov    rdi,rbx
  446bbf:	lea    r10,[rbp-0x830]
  446bc6:	mov    r11,QWORD PTR [rbp-0x28a0]
  446bcd:	mov    QWORD PTR [r10],r11
  446bd0:	lea    r10,[rbp-0x830]
  446bd7:	mov    r11,rdi
  446bda:	mov    QWORD PTR [r10+0x8],r11
  446bde:	mov    r10,r12
  446be1:	mov    r10,QWORD PTR [r10+0x8]
  446be5:	mov    QWORD PTR [rbp-0x2988],r10
  446bec:	mov    r10,QWORD PTR [r10+0x8]
  446bf0:	mov    QWORD PTR [rbp-0x2990],r10
  446bf7:	cmp    r10,0x0
  446bfe:	je     446c9f <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x5319>
  446c04:	mov    rdi,QWORD PTR [r12]
  446c08:	mov    rsi,QWORD PTR [rbp-0x2990]
  446c0f:	shl    rsi,0x3
  446c13:	mov    rdx,rdi
  446c16:	add    rdx,rsi
  446c19:	mov    rdi,QWORD PTR [rdx]
  446c1c:	mov    r10,QWORD PTR [rbp-0x2988]
  446c23:	mov    rsi,QWORD PTR [r10+0x108]
  446c2a:	lea    r10,[rbp-0x830]
  446c31:	mov    r8,QWORD PTR [r10]
  446c34:	lea    r10,[rbp-0x830]
  446c3b:	mov    r9,QWORD PTR [r10+0x8]
  446c3f:	mov    r10,QWORD PTR [rbp-0x2988]
  446c46:	mov    r11,rdi
  446c49:	mov    QWORD PTR [r10+0x8],r11
  446c4d:	mov    rdi,rsi
  446c50:	sub    rdi,0x2
  446c57:	mov    r10,QWORD PTR [rbp-0x2988]
  446c5e:	mov    r11,rdi
  446c61:	mov    QWORD PTR [r10+0x108],r11
  446c68:	mov    QWORD PTR [rdx],r8
  446c6b:	mov    QWORD PTR [rdx+0x8],r9
  446c6f:	movabs rdi,0x8
  446c79:	shl    rdi,0x28
  446c7d:	movabs r11,0x200000000000000
  446c87:	mov    rsi,rdi
  446c8a:	or     rsi,r11
  446c8d:	mov    r11,QWORD PTR [rbp-0x2990]
  446c94:	mov    rbx,rsi
  446c97:	or     rbx,r11
  446c9a:	jmp    446ccb <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x5345>
  446c9f:	mov    rdi,r12
  446ca2:	movabs rsi,0x8
  446cac:	mov    esi,esi
  446cae:	lea    rdx,[rbp-0x830]
  446cb5:	movabs rcx,0x2
  446cbf:	mov    ecx,ecx
  446cc1:	xor    eax,eax
  446cc3:	call   461a80 <p111_rt_ctor>
  446cc8:	mov    rbx,rax
  446ccb:	lea    r10,[rbp-0x830]
  446cd2:	mov    r11,rbx
  446cd5:	mov    QWORD PTR [r10],r11
  446cd8:	lea    r10,[rip+0x29f01]        # 470be0 <p111_program>
  446cdf:	movabs rdi,0x4
  446ce9:	and    rdi,QWORD PTR [r10+0x58]
  446ced:	mov    r10,rdi
  446cf0:	test   r10d,r10d
  446cf3:	je     446d51 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x53cb>
  446cf9:	lea    r10,[rbp-0x830]
  446d00:	mov    rdi,QWORD PTR [r10]
  446d03:	mov    QWORD PTR [r12+0x28],rdi
  446d08:	mov    r10,r12
  446d0b:	movabs r11,0x1
  446d15:	mov    DWORD PTR [r10+0x1c],r11d
  446d19:	mov    rdi,QWORD PTR [r12+0x10]
  446d1e:	movabs r11,0xfffffffffffffff8
  446d28:	mov    rsi,rdi
  446d2b:	add    rsi,r11
  446d2e:	mov    QWORD PTR [r12+0x10],rsi
  446d33:	mov    rdi,QWORD PTR [rsi]
  446d36:	mov    DWORD PTR [r12+0x20],edi
  446d3b:	movabs r10,0x0
  446d45:	mov    QWORD PTR [rbp-0xa90],r10
  446d4c:	jmp    446d75 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x53ef>
  446d51:	mov    rdi,r12
  446d54:	lea    rsi,[rbp-0x830]
  446d5b:	movabs rdx,0x1
  446d65:	mov    edx,edx
  446d67:	xor    eax,eax
  446d69:	call   462030 <p111_rt_return>
  446d6e:	mov    QWORD PTR [rbp-0xa90],rax
  446d75:	mov    rax,QWORD PTR [rbp-0xa90]
  446d7c:	mov    r12,QWORD PTR [rbp-0x10]
  446d80:	mov    rbx,QWORD PTR [rbp-0x8]
  446d84:	mov    r13,QWORD PTR [rbp-0x18]
  446d88:	mov    r14,QWORD PTR [rbp-0x20]
  446d8c:	mov    r15,QWORD PTR [rbp-0x28]
  446d90:	mov    rsp,rbp
  446d93:	pop    rbp
  446d94:	ret    
  446d95:	mov    r10,QWORD PTR [rbp-0x2730]
  446d9c:	cmp    r10,0x1
  446da3:	sete   r10b
  446da7:	movzx  r10d,r10b
  446dab:	mov    QWORD PTR [rbp-0x8d0],r10
  446db2:	mov    r10,QWORD PTR [rbp-0x2730]
  446db9:	shr    r10,0x28
  446dbd:	mov    QWORD PTR [rbp-0x8d8],r10
  446dc4:	and    r10,0x7fffff
  446dcb:	mov    QWORD PTR [rbp-0x8d8],r10
  446dd2:	movabs r10,0x2
  446ddc:	or     r10,0x10000
  446de3:	mov    QWORD PTR [rbp-0x8e0],r10
  446dea:	mov    r10,QWORD PTR [rbp-0x8d8]
  446df1:	mov    r11,QWORD PTR [rbp-0x8e0]
  446df8:	cmp    r10,r11
  446dfb:	sete   r10b
  446dff:	movzx  r10d,r10b
  446e03:	mov    QWORD PTR [rbp-0x8e8],r10
  446e0a:	mov    r11,r10
  446e0d:	mov    r13,QWORD PTR [rbp-0x8d0]
  446e14:	or     r13d,r11d
  446e17:	mov    r10,r13
  446e1a:	test   r10d,r10d
  446e1d:	je     447211 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x588b>
  446e23:	mov    rdi,QWORD PTR [rbp-0x1c58]
  446e2a:	lea    r10,[rbp-0x830]
  446e31:	mov    r11,rdi
  446e34:	mov    QWORD PTR [r10],r11
  446e37:	lea    r10,[rbp-0x830]
  446e3e:	mov    r11,QWORD PTR [rbp-0x1c60]
  446e45:	mov    QWORD PTR [r10+0x8],r11
  446e49:	mov    r10,r12
  446e4c:	mov    r10,QWORD PTR [r10+0x8]
  446e50:	mov    QWORD PTR [rbp-0x2a28],r10
  446e57:	mov    r10,QWORD PTR [r10+0x8]
  446e5b:	mov    QWORD PTR [rbp-0x2a30],r10
  446e62:	cmp    r10,0x0
  446e69:	je     446f0a <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x5584>
  446e6f:	mov    rdi,QWORD PTR [r12]
  446e73:	mov    rsi,QWORD PTR [rbp-0x2a30]
  446e7a:	shl    rsi,0x3
  446e7e:	mov    rdx,rdi
  446e81:	add    rdx,rsi
  446e84:	mov    rdi,QWORD PTR [rdx]
  446e87:	mov    r10,QWORD PTR [rbp-0x2a28]
  446e8e:	mov    rsi,QWORD PTR [r10+0x108]
  446e95:	lea    r10,[rbp-0x830]
  446e9c:	mov    r8,QWORD PTR [r10]
  446e9f:	lea    r10,[rbp-0x830]
  446ea6:	mov    r9,QWORD PTR [r10+0x8]
  446eaa:	mov    r10,QWORD PTR [rbp-0x2a28]
  446eb1:	mov    r11,rdi
  446eb4:	mov    QWORD PTR [r10+0x8],r11
  446eb8:	mov    rdi,rsi
  446ebb:	sub    rdi,0x2
  446ec2:	mov    r10,QWORD PTR [rbp-0x2a28]
  446ec9:	mov    r11,rdi
  446ecc:	mov    QWORD PTR [r10+0x108],r11
  446ed3:	mov    QWORD PTR [rdx],r8
  446ed6:	mov    QWORD PTR [rdx+0x8],r9
  446eda:	movabs rdi,0x2c
  446ee4:	shl    rdi,0x28
  446ee8:	movabs r11,0x200000000000000
  446ef2:	mov    rsi,rdi
  446ef5:	or     rsi,r11
  446ef8:	mov    r11,QWORD PTR [rbp-0x2a30]
  446eff:	mov    rbx,rsi
  446f02:	or     rbx,r11
  446f05:	jmp    446f36 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x55b0>
  446f0a:	mov    rdi,r12
  446f0d:	movabs rsi,0x2c
  446f17:	mov    esi,esi
  446f19:	lea    rdx,[rbp-0x830]
  446f20:	movabs rcx,0x2
  446f2a:	mov    ecx,ecx
  446f2c:	xor    eax,eax
  446f2e:	call   461a80 <p111_rt_ctor>
  446f33:	mov    rbx,rax
  446f36:	mov    rdi,rbx
  446f39:	lea    r10,[rbp-0x830]
  446f40:	mov    r11,QWORD PTR [rbp-0x8a8]
  446f47:	mov    QWORD PTR [r10],r11
  446f4a:	lea    r10,[rbp-0x830]
  446f51:	mov    r11,rdi
  446f54:	mov    QWORD PTR [r10+0x8],r11
  446f58:	mov    rdi,QWORD PTR [r12+0x10]
  446f5d:	mov    rsi,QWORD PTR [rbp-0x8a8]
  446f64:	mov    QWORD PTR [rdi],rsi
  446f67:	lea    r10,[rbp-0x830]
  446f6e:	mov    rsi,QWORD PTR [r10+0x8]
  446f72:	mov    QWORD PTR [rdi+0x8],rsi
  446f76:	mov    r10,rdi
  446f79:	movabs r11,0x160
  446f83:	mov    QWORD PTR [r10+0x10],r11
  446f87:	mov    rsi,rdi
  446f8a:	add    rsi,0x18
  446f91:	mov    QWORD PTR [r12+0x10],rsi
  446f96:	mov    rdi,r12
  446f99:	mov    rsi,QWORD PTR [rbp-0x2710]
  446fa0:	xor    eax,eax
  446fa2:	call   461980 <p111_rt_keep>
  446fa7:	mov    QWORD PTR [rbp-0x2710],rax
  446fae:	mov    rdi,rax
  446fb1:	lea    r10,[rbp-0x830]
  446fb8:	mov    r11,rdi
  446fbb:	mov    QWORD PTR [r10],r11
  446fbe:	lea    r10,[rbp-0x830]
  446fc5:	mov    r11,QWORD PTR [rbp-0x2718]
  446fcc:	mov    QWORD PTR [r10+0x8],r11
  446fd0:	lea    r10,[rbp-0x830]
  446fd7:	mov    r11,QWORD PTR [rbp-0x2720]
  446fde:	mov    QWORD PTR [r10+0x10],r11
  446fe2:	mov    r10,r12
  446fe5:	mov    r10,QWORD PTR [r10+0x8]
  446fe9:	mov    QWORD PTR [rbp-0x2ab8],r10
  446ff0:	mov    r10,QWORD PTR [r10+0x10]
  446ff4:	mov    QWORD PTR [rbp-0x2ac0],r10
  446ffb:	cmp    r10,0x0
  447002:	je     4470c3 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x573d>
  447008:	mov    rdi,QWORD PTR [r12]
  44700c:	mov    rsi,QWORD PTR [rbp-0x2ac0]
  447013:	shl    rsi,0x3
  447017:	mov    rdx,rdi
  44701a:	add    rdx,rsi
  44701d:	mov    rdi,QWORD PTR [rdx]
  447020:	mov    r10,QWORD PTR [rbp-0x2ab8]
  447027:	mov    rsi,QWORD PTR [r10+0x110]
  44702e:	lea    r10,[rbp-0x830]
  447035:	mov    r8,QWORD PTR [r10]
  447038:	lea    r10,[rbp-0x830]
  44703f:	mov    r9,QWORD PTR [r10+0x8]
  447043:	lea    r10,[rbp-0x830]
  44704a:	mov    r10,QWORD PTR [r10+0x10]
  44704e:	mov    QWORD PTR [rbp-0x2b08],r10
  447055:	mov    r10,QWORD PTR [rbp-0x2ab8]
  44705c:	mov    r11,rdi
  44705f:	mov    QWORD PTR [r10+0x10],r11
  447063:	mov    rdi,rsi
  447066:	sub    rdi,0x4
  44706d:	mov    r10,QWORD PTR [rbp-0x2ab8]
  447074:	mov    r11,rdi
  447077:	mov    QWORD PTR [r10+0x110],r11
  44707e:	mov    QWORD PTR [rdx],r8
  447081:	mov    QWORD PTR [rdx+0x8],r9
  447085:	mov    r10,rdx
  447088:	mov    r11,QWORD PTR [rbp-0x2b08]
  44708f:	mov    QWORD PTR [r10+0x10],r11
  447093:	movabs rdi,0x2d
  44709d:	shl    rdi,0x28
  4470a1:	movabs r11,0x200000000000000
  4470ab:	mov    rsi,rdi
  4470ae:	or     rsi,r11
  4470b1:	mov    r11,QWORD PTR [rbp-0x2ac0]
  4470b8:	mov    rbx,rsi
  4470bb:	or     rbx,r11
  4470be:	jmp    4470ef <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x5769>
  4470c3:	mov    rdi,r12
  4470c6:	movabs rsi,0x2d
  4470d0:	mov    esi,esi
  4470d2:	lea    rdx,[rbp-0x830]
  4470d9:	movabs rcx,0x3
  4470e3:	mov    ecx,ecx
  4470e5:	xor    eax,eax
  4470e7:	call   461a80 <p111_rt_ctor>
  4470ec:	mov    rbx,rax
  4470ef:	mov    r10,rbx
  4470f2:	mov    QWORD PTR [rbp-0x2b28],r10
  4470f9:	mov    r10,QWORD PTR [rbp-0x2710]
  447100:	mov    QWORD PTR [rbp-0x2b30],r10
  447107:	mov    rdi,r12
  44710a:	mov    rsi,QWORD PTR [rbp-0x2728]
  447111:	mov    rdx,QWORD PTR [rbp-0x2b30]
  447118:	xor    eax,eax
  44711a:	call   40eddf <p112w_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_>
  44711f:	mov    QWORD PTR [rbp-0x2b38],rax
  447126:	lea    r10,[rbp-0x3338]
  44712d:	mov    r11,QWORD PTR [rbp-0x2b28]
  447134:	mov    QWORD PTR [r10],r11
  447137:	lea    r10,[rbp-0x3338]
  44713e:	mov    r11,QWORD PTR [rbp-0x2b38]
  447145:	mov    QWORD PTR [r10+0x8],r11
  447149:	lea    r10,[rip+0x29a90]        # 470be0 <p111_program>
  447150:	movabs rdi,0x4
  44715a:	and    rdi,QWORD PTR [r10+0x58]
  44715e:	mov    r10,rdi
  447161:	test   r10d,r10d
  447164:	je     4471c1 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x583b>
  44716a:	lea    r10,[rbp-0x3338]
  447171:	mov    rdi,QWORD PTR [r10]
  447174:	lea    r10,[rbp-0x3338]
  44717b:	mov    rsi,QWORD PTR [r10+0x8]
  44717f:	mov    QWORD PTR [r12+0x28],rdi
  447184:	mov    QWORD PTR [r12+0x30],rsi
  447189:	mov    r10,r12
  44718c:	movabs r11,0x0
  447196:	mov    DWORD PTR [r10+0x1c],r11d
  44719a:	mov    r10,r12
  44719d:	movabs r11,0x151
  4471a7:	mov    DWORD PTR [r10+0x20],r11d
  4471ab:	movabs r10,0x0
  4471b5:	mov    QWORD PTR [rbp-0x3360],r10
  4471bc:	jmp    4471f1 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x586b>
  4471c1:	mov    rdi,r12
  4471c4:	movabs rsi,0x151
  4471ce:	mov    esi,esi
  4471d0:	lea    rdx,[rbp-0x3338]
  4471d7:	movabs rcx,0x2
  4471e1:	mov    ecx,ecx
  4471e3:	xor    eax,eax
  4471e5:	call   461fd0 <p111_rt_jump>
  4471ea:	mov    QWORD PTR [rbp-0x3360],rax
  4471f1:	mov    rax,QWORD PTR [rbp-0x3360]
  4471f8:	mov    r12,QWORD PTR [rbp-0x10]
  4471fc:	mov    rbx,QWORD PTR [rbp-0x8]
  447200:	mov    r13,QWORD PTR [rbp-0x18]
  447204:	mov    r14,QWORD PTR [rbp-0x20]
  447208:	mov    r15,QWORD PTR [rbp-0x28]
  44720c:	mov    rsp,rbp
  44720f:	pop    rbp
  447210:	ret    
  447211:	mov    rdi,r12
  447214:	mov    rsi,QWORD PTR [rbp-0x8a8]
  44721b:	xor    eax,eax
  44721d:	call   461a10 <p111_rt_sink>
  447222:	mov    QWORD PTR [rbp-0x8a0],rax
  447229:	mov    rdi,r12
  44722c:	mov    rsi,QWORD PTR [rbp-0x1c58]
  447233:	xor    eax,eax
  447235:	call   461a10 <p111_rt_sink>
  44723a:	mov    QWORD PTR [rbp-0x8a0],rax
  447241:	mov    rdi,r12
  447244:	mov    rsi,QWORD PTR [rbp-0x1c60]
  44724b:	xor    eax,eax
  44724d:	call   461a10 <p111_rt_sink>
  447252:	mov    QWORD PTR [rbp-0x8a0],rax
  447259:	mov    rdi,r12
  44725c:	mov    rsi,QWORD PTR [rbp-0x2710]
  447263:	xor    eax,eax
  447265:	call   461a10 <p111_rt_sink>
  44726a:	mov    QWORD PTR [rbp-0x8a0],rax
  447271:	mov    rdi,r12
  447274:	mov    rsi,QWORD PTR [rbp-0x2718]
  44727b:	xor    eax,eax
  44727d:	call   461a10 <p111_rt_sink>
  447282:	mov    QWORD PTR [rbp-0x8a0],rax
  447289:	mov    rdi,r12
  44728c:	mov    rsi,QWORD PTR [rbp-0x2720]
  447293:	xor    eax,eax
  447295:	call   461a10 <p111_rt_sink>
  44729a:	mov    QWORD PTR [rbp-0x8a0],rax
  4472a1:	mov    rdi,r12
  4472a4:	mov    rsi,QWORD PTR [rbp-0x2728]
  4472ab:	xor    eax,eax
  4472ad:	call   461a10 <p111_rt_sink>
  4472b2:	mov    QWORD PTR [rbp-0x8a0],rax
  4472b9:	lea    r10,[rbp-0x830]
  4472c0:	mov    r11,QWORD PTR [rbp-0x2730]
  4472c7:	mov    QWORD PTR [r10],r11
  4472ca:	mov    rdi,QWORD PTR [r12+0x10]
  4472cf:	mov    r10,rdi
  4472d2:	mov    r11,QWORD PTR [rbp-0x2730]
  4472d9:	mov    QWORD PTR [r10],r11
  4472dc:	mov    r10,rdi
  4472df:	movabs r11,0x162
  4472e9:	mov    QWORD PTR [r10+0x8],r11
  4472ed:	mov    rsi,rdi
  4472f0:	add    rsi,0x10
  4472f7:	mov    QWORD PTR [r12+0x10],rsi
  4472fc:	mov    rdi,r12
  4472ff:	movabs rsi,0x4
  447309:	mov    esi,esi
  44730b:	xor    eax,eax
  44730d:	call   4621a0 <p111_rt_fail>
  447312:	mov    QWORD PTR [rbp-0xa90],rax
  447319:	mov    r12,QWORD PTR [rbp-0x10]
  44731d:	mov    rbx,QWORD PTR [rbp-0x8]
  447321:	mov    r13,QWORD PTR [rbp-0x18]
  447325:	mov    r14,QWORD PTR [rbp-0x20]
  447329:	mov    r15,QWORD PTR [rbp-0x28]
  44732d:	mov    rsp,rbp
  447330:	pop    rbp
  447331:	ret    
  447332:	mov    rdi,r12
  447335:	mov    rsi,QWORD PTR [rbp-0x8a8]
  44733c:	xor    eax,eax
  44733e:	call   461a10 <p111_rt_sink>
  447343:	mov    QWORD PTR [rbp-0x8a0],rax
  44734a:	mov    rdi,r12
  44734d:	mov    rsi,QWORD PTR [rbp-0x1c58]
  447354:	xor    eax,eax
  447356:	call   461a10 <p111_rt_sink>
  44735b:	mov    QWORD PTR [rbp-0x8a0],rax
  447362:	mov    rdi,r12
  447365:	mov    rsi,QWORD PTR [rbp-0x1c60]
  44736c:	xor    eax,eax
  44736e:	call   461a10 <p111_rt_sink>
  447373:	mov    QWORD PTR [rbp-0x8a0],rax
  44737a:	mov    rdi,r12
  44737d:	mov    rsi,QWORD PTR [rbp-0x2710]
  447384:	xor    eax,eax
  447386:	call   461a10 <p111_rt_sink>
  44738b:	mov    QWORD PTR [rbp-0x8a0],rax
  447392:	mov    rdi,r12
  447395:	mov    rsi,QWORD PTR [rbp-0x2718]
  44739c:	xor    eax,eax
  44739e:	call   461a10 <p111_rt_sink>
  4473a3:	mov    QWORD PTR [rbp-0x8a0],rax
  4473aa:	mov    rdi,r12
  4473ad:	mov    rsi,QWORD PTR [rbp-0x2720]
  4473b4:	xor    eax,eax
  4473b6:	call   461a10 <p111_rt_sink>
  4473bb:	mov    QWORD PTR [rbp-0x8a0],rax
  4473c2:	lea    r10,[rbp-0x830]
  4473c9:	mov    r11,r14
  4473cc:	mov    QWORD PTR [r10],r11
  4473cf:	mov    rdi,QWORD PTR [r12+0x10]
  4473d4:	mov    QWORD PTR [rdi],r14
  4473d7:	mov    r10,rdi
  4473da:	movabs r11,0x163
  4473e4:	mov    QWORD PTR [r10+0x8],r11
  4473e8:	mov    rsi,rdi
  4473eb:	add    rsi,0x10
  4473f2:	mov    QWORD PTR [r12+0x10],rsi
  4473f7:	mov    rdi,r12
  4473fa:	movabs rsi,0x4
  447404:	mov    esi,esi
  447406:	xor    eax,eax
  447408:	call   4621a0 <p111_rt_fail>
  44740d:	mov    QWORD PTR [rbp-0xa90],rax
  447414:	mov    r12,QWORD PTR [rbp-0x10]
  447418:	mov    rbx,QWORD PTR [rbp-0x8]
  44741c:	mov    r13,QWORD PTR [rbp-0x18]
  447420:	mov    r14,QWORD PTR [rbp-0x20]
  447424:	mov    r15,QWORD PTR [rbp-0x28]
  447428:	mov    rsp,rbp
  44742b:	pop    rbp
  44742c:	ret    
  44742d:	mov    rdi,r12
  447430:	mov    rsi,QWORD PTR [rbp-0x8a8]
  447437:	xor    eax,eax
  447439:	call   461a10 <p111_rt_sink>
  44743e:	mov    QWORD PTR [rbp-0x8a0],rax
  447445:	mov    rdi,r12
  447448:	mov    rsi,QWORD PTR [rbp-0x1c58]
  44744f:	xor    eax,eax
  447451:	call   461a10 <p111_rt_sink>
  447456:	mov    QWORD PTR [rbp-0x8a0],rax
  44745d:	mov    rdi,r12
  447460:	mov    rsi,QWORD PTR [rbp-0x1c60]
  447467:	xor    eax,eax
  447469:	call   461a10 <p111_rt_sink>
  44746e:	mov    QWORD PTR [rbp-0x8a0],rax
  447475:	lea    r10,[rbp-0x830]
  44747c:	mov    r11,r14
  44747f:	mov    QWORD PTR [r10],r11
  447482:	mov    rdi,QWORD PTR [r12+0x10]
  447487:	mov    QWORD PTR [rdi],r14
  44748a:	mov    r10,rdi
  44748d:	movabs r11,0x164
  447497:	mov    QWORD PTR [r10+0x8],r11
  44749b:	mov    rsi,rdi
  44749e:	add    rsi,0x10
  4474a5:	mov    QWORD PTR [r12+0x10],rsi
  4474aa:	lea    r10,[rbp-0x830]
  4474b1:	mov    r11,QWORD PTR [rbp-0x8b8]
  4474b8:	mov    QWORD PTR [r10],r11
  4474bb:	mov    rdi,QWORD PTR [r12+0x10]
  4474c0:	mov    r10,rdi
  4474c3:	mov    r11,QWORD PTR [rbp-0x8b8]
  4474ca:	mov    QWORD PTR [r10],r11
  4474cd:	mov    r10,rdi
  4474d0:	movabs r11,0x165
  4474da:	mov    QWORD PTR [r10+0x8],r11
  4474de:	mov    rsi,rdi
  4474e1:	add    rsi,0x10
  4474e8:	mov    QWORD PTR [r12+0x10],rsi
  4474ed:	mov    rdi,r12
  4474f0:	movabs rsi,0x4
  4474fa:	mov    esi,esi
  4474fc:	xor    eax,eax
  4474fe:	call   4621a0 <p111_rt_fail>
  447503:	mov    QWORD PTR [rbp-0xa90],rax
  44750a:	mov    r12,QWORD PTR [rbp-0x10]
  44750e:	mov    rbx,QWORD PTR [rbp-0x8]
  447512:	mov    r13,QWORD PTR [rbp-0x18]
  447516:	mov    r14,QWORD PTR [rbp-0x20]
  44751a:	mov    r15,QWORD PTR [rbp-0x28]
  44751e:	mov    rsp,rbp
  447521:	pop    rbp
  447522:	ret    
  447523:	mov    r15,QWORD PTR [rbp-0x8b0]
  44752a:	shr    r15,0x28
  44752e:	and    r15,0xffff
  447535:	movabs r11,0x2d
  44753f:	mov    r13,r15
  447542:	cmp    r13,r11
  447545:	sete   r13b
  447549:	movzx  r13d,r13b
  44754d:	mov    r10,r13
  447550:	test   r10d,r10d
  447553:	je     449ee9 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x8563>
  447559:	mov    rdi,r12
  44755c:	mov    rsi,QWORD PTR [rbp-0x8b0]
  447563:	lea    rdx,[rbp-0x830]
  44756a:	xor    eax,eax
  44756c:	call   467a10 <p125_rt_take3>
  447571:	mov    QWORD PTR [rbp-0x8a0],rax
  447578:	lea    r10,[rbp-0x830]
  44757f:	mov    r10,QWORD PTR [r10]
  447582:	mov    QWORD PTR [rbp-0x33a8],r10
  447589:	lea    r10,[rbp-0x830]
  447590:	mov    r10,QWORD PTR [r10+0x8]
  447594:	mov    QWORD PTR [rbp-0x33b0],r10
  44759b:	lea    r10,[rbp-0x830]
  4475a2:	mov    r10,QWORD PTR [r10+0x10]
  4475a6:	mov    QWORD PTR [rbp-0x33b8],r10
  4475ad:	mov    r15,QWORD PTR [rbp-0x8b8]
  4475b4:	shr    r15,0x28
  4475b8:	and    r15,0xffff
  4475bf:	movabs r11,0x2b
  4475c9:	mov    r13,r15
  4475cc:	cmp    r13,r11
  4475cf:	sete   r13b
  4475d3:	movzx  r13d,r13b
  4475d7:	mov    r10,r13
  4475da:	test   r10d,r10d
  4475dd:	je     448192 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x680c>
  4475e3:	mov    r15,r14
  4475e6:	shr    r15,0x28
  4475ea:	and    r15,0xffff
  4475f1:	movabs r11,0x8
  4475fb:	mov    r13,r15
  4475fe:	cmp    r13,r11
  447601:	sete   r13b
  447605:	movzx  r13d,r13b
  447609:	mov    r10,r13
  44760c:	test   r10d,r10d
  44760f:	je     4480c7 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x6741>
  447615:	mov    rdi,r12
  447618:	mov    rsi,r14
  44761b:	lea    rdx,[rbp-0x830]
  447622:	xor    eax,eax
  447624:	call   4677b0 <p125_rt_take2>
  447629:	mov    QWORD PTR [rbp-0x8a0],rax
  447630:	lea    r10,[rbp-0x830]
  447637:	mov    r10,QWORD PTR [r10]
  44763a:	mov    QWORD PTR [rbp-0x33c0],r10
  447641:	lea    r10,[rbp-0x830]
  447648:	mov    r10,QWORD PTR [r10+0x8]
  44764c:	mov    QWORD PTR [rbp-0x33c8],r10
  447653:	cmp    r10,0x1
  44765a:	sete   r10b
  44765e:	movzx  r10d,r10b
  447662:	mov    QWORD PTR [rbp-0x8d0],r10
  447669:	mov    r10,QWORD PTR [rbp-0x33c8]
  447670:	shr    r10,0x28
  447674:	mov    QWORD PTR [rbp-0x8d8],r10
  44767b:	and    r10,0x7fffff
  447682:	mov    QWORD PTR [rbp-0x8d8],r10
  447689:	movabs r10,0x2
  447693:	or     r10,0x10000
  44769a:	mov    QWORD PTR [rbp-0x8e0],r10
  4476a1:	mov    r10,QWORD PTR [rbp-0x8d8]
  4476a8:	mov    r11,QWORD PTR [rbp-0x8e0]
  4476af:	cmp    r10,r11
  4476b2:	sete   r10b
  4476b6:	movzx  r10d,r10b
  4476ba:	mov    QWORD PTR [rbp-0x8e8],r10
  4476c1:	mov    r11,r10
  4476c4:	mov    r13,QWORD PTR [rbp-0x8d0]
  4476cb:	or     r13d,r11d
  4476ce:	xor    r13d,0x1
  4476d5:	mov    r10,r13
  4476d8:	test   r10d,r10d
  4476db:	je     4479c3 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x603d>
  4476e1:	movabs rdi,0x1002b0000000000
  4476eb:	lea    r10,[rbp-0x830]
  4476f2:	mov    r11,QWORD PTR [rbp-0x8a8]
  4476f9:	mov    QWORD PTR [r10],r11
  4476fc:	lea    r10,[rbp-0x830]
  447703:	mov    r11,rdi
  447706:	mov    QWORD PTR [r10+0x8],r11
  44770a:	mov    rdi,QWORD PTR [r12+0x10]
  44770f:	mov    rsi,QWORD PTR [rbp-0x8a8]
  447716:	mov    QWORD PTR [rdi],rsi
  447719:	lea    r10,[rbp-0x830]
  447720:	mov    rsi,QWORD PTR [r10+0x8]
  447724:	mov    QWORD PTR [rdi+0x8],rsi
  447728:	mov    r10,rdi
  44772b:	movabs r11,0x166
  447735:	mov    QWORD PTR [r10+0x10],r11
  447739:	mov    rsi,rdi
  44773c:	add    rsi,0x18
  447743:	mov    QWORD PTR [r12+0x10],rsi
  447748:	mov    rdi,r12
  44774b:	mov    rsi,QWORD PTR [rbp-0x33a8]
  447752:	xor    eax,eax
  447754:	call   461980 <p111_rt_keep>
  447759:	mov    QWORD PTR [rbp-0x33a8],rax
  447760:	mov    rdi,rax
  447763:	lea    r10,[rbp-0x830]
  44776a:	mov    r11,rdi
  44776d:	mov    QWORD PTR [r10],r11
  447770:	lea    r10,[rbp-0x830]
  447777:	mov    r11,QWORD PTR [rbp-0x33b0]
  44777e:	mov    QWORD PTR [r10+0x8],r11
  447782:	lea    r10,[rbp-0x830]
  447789:	mov    r11,QWORD PTR [rbp-0x33b8]
  447790:	mov    QWORD PTR [r10+0x10],r11
  447794:	mov    r10,r12
  447797:	mov    r10,QWORD PTR [r10+0x8]
  44779b:	mov    QWORD PTR [rbp-0x33f8],r10
  4477a2:	mov    r10,QWORD PTR [r10+0x10]
  4477a6:	mov    QWORD PTR [rbp-0x3400],r10
  4477ad:	cmp    r10,0x0
  4477b4:	je     447875 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x5eef>
  4477ba:	mov    rdi,QWORD PTR [r12]
  4477be:	mov    rsi,QWORD PTR [rbp-0x3400]
  4477c5:	shl    rsi,0x3
  4477c9:	mov    rdx,rdi
  4477cc:	add    rdx,rsi
  4477cf:	mov    rdi,QWORD PTR [rdx]
  4477d2:	mov    r10,QWORD PTR [rbp-0x33f8]
  4477d9:	mov    rsi,QWORD PTR [r10+0x110]
  4477e0:	lea    r10,[rbp-0x830]
  4477e7:	mov    r8,QWORD PTR [r10]
  4477ea:	lea    r10,[rbp-0x830]
  4477f1:	mov    r9,QWORD PTR [r10+0x8]
  4477f5:	lea    r10,[rbp-0x830]
  4477fc:	mov    r10,QWORD PTR [r10+0x10]
  447800:	mov    QWORD PTR [rbp-0x3448],r10
  447807:	mov    r10,QWORD PTR [rbp-0x33f8]
  44780e:	mov    r11,rdi
  447811:	mov    QWORD PTR [r10+0x10],r11
  447815:	mov    rdi,rsi
  447818:	sub    rdi,0x4
  44781f:	mov    r10,QWORD PTR [rbp-0x33f8]
  447826:	mov    r11,rdi
  447829:	mov    QWORD PTR [r10+0x110],r11
  447830:	mov    QWORD PTR [rdx],r8
  447833:	mov    QWORD PTR [rdx+0x8],r9
  447837:	mov    r10,rdx
  44783a:	mov    r11,QWORD PTR [rbp-0x3448]
  447841:	mov    QWORD PTR [r10+0x10],r11
  447845:	movabs rdi,0x2d
  44784f:	shl    rdi,0x28
  447853:	movabs r11,0x200000000000000
  44785d:	mov    rsi,rdi
  447860:	or     rsi,r11
  447863:	mov    r11,QWORD PTR [rbp-0x3400]
  44786a:	mov    rbx,rsi
  44786d:	or     rbx,r11
  447870:	jmp    4478a1 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x5f1b>
  447875:	mov    rdi,r12
  447878:	movabs rsi,0x2d
  447882:	mov    esi,esi
  447884:	lea    rdx,[rbp-0x830]
  44788b:	movabs rcx,0x3
  447895:	mov    ecx,ecx
  447897:	xor    eax,eax
  447899:	call   461a80 <p111_rt_ctor>
  44789e:	mov    rbx,rax
  4478a1:	mov    r10,rbx
  4478a4:	mov    QWORD PTR [rbp-0x3468],r10
  4478ab:	mov    r10,QWORD PTR [rbp-0x33a8]
  4478b2:	mov    QWORD PTR [rbp-0x3470],r10
  4478b9:	mov    rdi,r12
  4478bc:	mov    rsi,QWORD PTR [rbp-0x33c0]
  4478c3:	mov    rdx,QWORD PTR [rbp-0x3470]
  4478ca:	xor    eax,eax
  4478cc:	call   40eddf <p112w_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_>
  4478d1:	mov    QWORD PTR [rbp-0x3478],rax
  4478d8:	lea    r10,[rbp-0x3c78]
  4478df:	mov    r11,QWORD PTR [rbp-0x3468]
  4478e6:	mov    QWORD PTR [r10],r11
  4478e9:	lea    r10,[rbp-0x3c78]
  4478f0:	mov    r11,QWORD PTR [rbp-0x3478]
  4478f7:	mov    QWORD PTR [r10+0x8],r11
  4478fb:	lea    r10,[rip+0x292de]        # 470be0 <p111_program>
  447902:	movabs rdi,0x4
  44790c:	and    rdi,QWORD PTR [r10+0x58]
  447910:	mov    r10,rdi
  447913:	test   r10d,r10d
  447916:	je     447973 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x5fed>
  44791c:	lea    r10,[rbp-0x3c78]
  447923:	mov    rdi,QWORD PTR [r10]
  447926:	lea    r10,[rbp-0x3c78]
  44792d:	mov    rsi,QWORD PTR [r10+0x8]
  447931:	mov    QWORD PTR [r12+0x28],rdi
  447936:	mov    QWORD PTR [r12+0x30],rsi
  44793b:	mov    r10,r12
  44793e:	movabs r11,0x0
  447948:	mov    DWORD PTR [r10+0x1c],r11d
  44794c:	mov    r10,r12
  44794f:	movabs r11,0x151
  447959:	mov    DWORD PTR [r10+0x20],r11d
  44795d:	movabs r10,0x0
  447967:	mov    QWORD PTR [rbp-0x3ca0],r10
  44796e:	jmp    4479a3 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x601d>
  447973:	mov    rdi,r12
  447976:	movabs rsi,0x151
  447980:	mov    esi,esi
  447982:	lea    rdx,[rbp-0x3c78]
  447989:	movabs rcx,0x2
  447993:	mov    ecx,ecx
  447995:	xor    eax,eax
  447997:	call   461fd0 <p111_rt_jump>
  44799c:	mov    QWORD PTR [rbp-0x3ca0],rax
  4479a3:	mov    rax,QWORD PTR [rbp-0x3ca0]
  4479aa:	mov    r12,QWORD PTR [rbp-0x10]
  4479ae:	mov    rbx,QWORD PTR [rbp-0x8]
  4479b2:	mov    r13,QWORD PTR [rbp-0x18]
  4479b6:	mov    r14,QWORD PTR [rbp-0x20]
  4479ba:	mov    r15,QWORD PTR [rbp-0x28]
  4479be:	mov    rsp,rbp
  4479c1:	pop    rbp
  4479c2:	ret    
  4479c3:	mov    r10,QWORD PTR [rbp-0x33c8]
  4479ca:	cmp    r10,0x1
  4479d1:	sete   r10b
  4479d5:	movzx  r10d,r10b
  4479d9:	mov    QWORD PTR [rbp-0x8d0],r10
  4479e0:	mov    r10,QWORD PTR [rbp-0x33c8]
  4479e7:	shr    r10,0x28
  4479eb:	mov    QWORD PTR [rbp-0x8d8],r10
  4479f2:	and    r10,0x7fffff
  4479f9:	mov    QWORD PTR [rbp-0x8d8],r10
  447a00:	movabs r10,0x2
  447a0a:	or     r10,0x10000
  447a11:	mov    QWORD PTR [rbp-0x8e0],r10
  447a18:	mov    r10,QWORD PTR [rbp-0x8d8]
  447a1f:	mov    r11,QWORD PTR [rbp-0x8e0]
  447a26:	cmp    r10,r11
  447a29:	sete   r10b
  447a2d:	movzx  r10d,r10b
  447a31:	mov    QWORD PTR [rbp-0x8e8],r10
  447a38:	mov    r11,r10
  447a3b:	mov    r13,QWORD PTR [rbp-0x8d0]
  447a42:	or     r13d,r11d
  447a45:	mov    r10,r13
  447a48:	test   r10d,r10d
  447a4b:	je     447fd6 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x6650>
  447a51:	mov    rdi,QWORD PTR [rbp-0x33a8]
  447a58:	lea    r10,[rbp-0x830]
  447a5f:	mov    r11,rdi
  447a62:	mov    QWORD PTR [r10],r11
  447a65:	lea    r10,[rbp-0x830]
  447a6c:	mov    r11,QWORD PTR [rbp-0x33b0]
  447a73:	mov    QWORD PTR [r10+0x8],r11
  447a77:	lea    r10,[rbp-0x830]
  447a7e:	mov    r11,QWORD PTR [rbp-0x33b8]
  447a85:	mov    QWORD PTR [r10+0x10],r11
  447a89:	mov    r10,r12
  447a8c:	mov    r10,QWORD PTR [r10+0x8]
  447a90:	mov    QWORD PTR [rbp-0x3cb0],r10
  447a97:	mov    r10,QWORD PTR [r10+0x10]
  447a9b:	mov    QWORD PTR [rbp-0x3cb8],r10
  447aa2:	cmp    r10,0x0
  447aa9:	je     447b6a <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x61e4>
  447aaf:	mov    rdi,QWORD PTR [r12]
  447ab3:	mov    rsi,QWORD PTR [rbp-0x3cb8]
  447aba:	shl    rsi,0x3
  447abe:	mov    rdx,rdi
  447ac1:	add    rdx,rsi
  447ac4:	mov    rdi,QWORD PTR [rdx]
  447ac7:	mov    r10,QWORD PTR [rbp-0x3cb0]
  447ace:	mov    rsi,QWORD PTR [r10+0x110]
  447ad5:	lea    r10,[rbp-0x830]
  447adc:	mov    r8,QWORD PTR [r10]
  447adf:	lea    r10,[rbp-0x830]
  447ae6:	mov    r9,QWORD PTR [r10+0x8]
  447aea:	lea    r10,[rbp-0x830]
  447af1:	mov    r10,QWORD PTR [r10+0x10]
  447af5:	mov    QWORD PTR [rbp-0x3d00],r10
  447afc:	mov    r10,QWORD PTR [rbp-0x3cb0]
  447b03:	mov    r11,rdi
  447b06:	mov    QWORD PTR [r10+0x10],r11
  447b0a:	mov    rdi,rsi
  447b0d:	sub    rdi,0x4
  447b14:	mov    r10,QWORD PTR [rbp-0x3cb0]
  447b1b:	mov    r11,rdi
  447b1e:	mov    QWORD PTR [r10+0x110],r11
  447b25:	mov    QWORD PTR [rdx],r8
  447b28:	mov    QWORD PTR [rdx+0x8],r9
  447b2c:	mov    r10,rdx
  447b2f:	mov    r11,QWORD PTR [rbp-0x3d00]
  447b36:	mov    QWORD PTR [r10+0x10],r11
  447b3a:	movabs rdi,0x2d
  447b44:	shl    rdi,0x28
  447b48:	movabs r11,0x200000000000000
  447b52:	mov    rsi,rdi
  447b55:	or     rsi,r11
  447b58:	mov    r11,QWORD PTR [rbp-0x3cb8]
  447b5f:	mov    rbx,rsi
  447b62:	or     rbx,r11
  447b65:	jmp    447b96 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x6210>
  447b6a:	mov    rdi,r12
  447b6d:	movabs rsi,0x2d
  447b77:	mov    esi,esi
  447b79:	lea    rdx,[rbp-0x830]
  447b80:	movabs rcx,0x3
  447b8a:	mov    ecx,ecx
  447b8c:	xor    eax,eax
  447b8e:	call   461a80 <p111_rt_ctor>
  447b93:	mov    rbx,rax
  447b96:	mov    rdi,rbx
  447b99:	movabs rsi,0x1002b0000000000
  447ba3:	lea    r10,[rbp-0x830]
  447baa:	mov    r11,QWORD PTR [rbp-0x8a8]
  447bb1:	mov    QWORD PTR [r10],r11
  447bb4:	lea    r10,[rbp-0x830]
  447bbb:	mov    r11,rdi
  447bbe:	mov    QWORD PTR [r10+0x8],r11
  447bc2:	lea    r10,[rbp-0x830]
  447bc9:	mov    r11,rsi
  447bcc:	mov    QWORD PTR [r10+0x10],r11
  447bd0:	mov    r10,r12
  447bd3:	mov    r10,QWORD PTR [r10+0x8]
  447bd7:	mov    QWORD PTR [rbp-0x3d30],r10
  447bde:	mov    r10,QWORD PTR [r10+0x10]
  447be2:	mov    QWORD PTR [rbp-0x3d38],r10
  447be9:	cmp    r10,0x0
  447bf0:	je     447cb1 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x632b>
  447bf6:	mov    rdi,QWORD PTR [r12]
  447bfa:	mov    rsi,QWORD PTR [rbp-0x3d38]
  447c01:	shl    rsi,0x3
  447c05:	mov    rdx,rdi
  447c08:	add    rdx,rsi
  447c0b:	mov    rdi,QWORD PTR [rdx]
  447c0e:	mov    r10,QWORD PTR [rbp-0x3d30]
  447c15:	mov    rsi,QWORD PTR [r10+0x110]
  447c1c:	lea    r10,[rbp-0x830]
  447c23:	mov    r8,QWORD PTR [r10]
  447c26:	lea    r10,[rbp-0x830]
  447c2d:	mov    r9,QWORD PTR [r10+0x8]
  447c31:	lea    r10,[rbp-0x830]
  447c38:	mov    r10,QWORD PTR [r10+0x10]
  447c3c:	mov    QWORD PTR [rbp-0x3d80],r10
  447c43:	mov    r10,QWORD PTR [rbp-0x3d30]
  447c4a:	mov    r11,rdi
  447c4d:	mov    QWORD PTR [r10+0x10],r11
  447c51:	mov    rdi,rsi
  447c54:	sub    rdi,0x4
  447c5b:	mov    r10,QWORD PTR [rbp-0x3d30]
  447c62:	mov    r11,rdi
  447c65:	mov    QWORD PTR [r10+0x110],r11
  447c6c:	mov    QWORD PTR [rdx],r8
  447c6f:	mov    QWORD PTR [rdx+0x8],r9
  447c73:	mov    r10,rdx
  447c76:	mov    r11,QWORD PTR [rbp-0x3d80]
  447c7d:	mov    QWORD PTR [r10+0x10],r11
  447c81:	movabs rdi,0x2d
  447c8b:	shl    rdi,0x28
  447c8f:	movabs r11,0x200000000000000
  447c99:	mov    rsi,rdi
  447c9c:	or     rsi,r11
  447c9f:	mov    r11,QWORD PTR [rbp-0x3d38]
  447ca6:	mov    rbx,rsi
  447ca9:	or     rbx,r11
  447cac:	jmp    447cdd <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x6357>
  447cb1:	mov    rdi,r12
  447cb4:	movabs rsi,0x2d
  447cbe:	mov    esi,esi
  447cc0:	lea    rdx,[rbp-0x830]
  447cc7:	movabs rcx,0x3
  447cd1:	mov    ecx,ecx
  447cd3:	xor    eax,eax
  447cd5:	call   461a80 <p111_rt_ctor>
  447cda:	mov    rbx,rax
  447cdd:	mov    r10,rbx
  447ce0:	mov    QWORD PTR [rbp-0x3da0],r10
  447ce7:	movabs rdi,0x1000b0000000000
  447cf1:	lea    r10,[rbp-0x830]
  447cf8:	mov    r11,QWORD PTR [rbp-0x33c0]
  447cff:	mov    QWORD PTR [r10],r11
  447d02:	lea    r10,[rbp-0x830]
  447d09:	mov    r11,rdi
  447d0c:	mov    QWORD PTR [r10+0x8],r11
  447d10:	mov    r10,r12
  447d13:	mov    r10,QWORD PTR [r10+0x8]
  447d17:	mov    QWORD PTR [rbp-0x3db0],r10
  447d1e:	mov    r10,QWORD PTR [r10+0x8]
  447d22:	mov    QWORD PTR [rbp-0x3db8],r10
  447d29:	cmp    r10,0x0
  447d30:	je     447dd1 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x644b>
  447d36:	mov    rdi,QWORD PTR [r12]
  447d3a:	mov    rsi,QWORD PTR [rbp-0x3db8]
  447d41:	shl    rsi,0x3
  447d45:	mov    rdx,rdi
  447d48:	add    rdx,rsi
  447d4b:	mov    rdi,QWORD PTR [rdx]
  447d4e:	mov    r10,QWORD PTR [rbp-0x3db0]
  447d55:	mov    rsi,QWORD PTR [r10+0x108]
  447d5c:	lea    r10,[rbp-0x830]
  447d63:	mov    r8,QWORD PTR [r10]
  447d66:	lea    r10,[rbp-0x830]
  447d6d:	mov    r9,QWORD PTR [r10+0x8]
  447d71:	mov    r10,QWORD PTR [rbp-0x3db0]
  447d78:	mov    r11,rdi
  447d7b:	mov    QWORD PTR [r10+0x8],r11
  447d7f:	mov    rdi,rsi
  447d82:	sub    rdi,0x2
  447d89:	mov    r10,QWORD PTR [rbp-0x3db0]
  447d90:	mov    r11,rdi
  447d93:	mov    QWORD PTR [r10+0x108],r11
  447d9a:	mov    QWORD PTR [rdx],r8
  447d9d:	mov    QWORD PTR [rdx+0x8],r9
  447da1:	movabs rdi,0x8
  447dab:	shl    rdi,0x28
  447daf:	movabs r11,0x200000000000000
  447db9:	mov    rsi,rdi
  447dbc:	or     rsi,r11
  447dbf:	mov    r11,QWORD PTR [rbp-0x3db8]
  447dc6:	mov    rbx,rsi
  447dc9:	or     rbx,r11
  447dcc:	jmp    447dfd <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x6477>
  447dd1:	mov    rdi,r12
  447dd4:	movabs rsi,0x8
  447dde:	mov    esi,esi
  447de0:	lea    rdx,[rbp-0x830]
  447de7:	movabs rcx,0x2
  447df1:	mov    ecx,ecx
  447df3:	xor    eax,eax
  447df5:	call   461a80 <p111_rt_ctor>
  447dfa:	mov    rbx,rax
  447dfd:	mov    rdi,rbx
  447e00:	lea    r10,[rbp-0x830]
  447e07:	mov    r11,QWORD PTR [rbp-0x3da0]
  447e0e:	mov    QWORD PTR [r10],r11
  447e11:	lea    r10,[rbp-0x830]
  447e18:	mov    r11,rdi
  447e1b:	mov    QWORD PTR [r10+0x8],r11
  447e1f:	mov    r10,r12
  447e22:	mov    r10,QWORD PTR [r10+0x8]
  447e26:	mov    QWORD PTR [rbp-0x3e20],r10
  447e2d:	mov    r10,QWORD PTR [r10+0x8]
  447e31:	mov    QWORD PTR [rbp-0x3e28],r10
  447e38:	cmp    r10,0x0
  447e3f:	je     447ee0 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x655a>
  447e45:	mov    rdi,QWORD PTR [r12]
  447e49:	mov    rsi,QWORD PTR [rbp-0x3e28]
  447e50:	shl    rsi,0x3
  447e54:	mov    rdx,rdi
  447e57:	add    rdx,rsi
  447e5a:	mov    rdi,QWORD PTR [rdx]
  447e5d:	mov    r10,QWORD PTR [rbp-0x3e20]
  447e64:	mov    rsi,QWORD PTR [r10+0x108]
  447e6b:	lea    r10,[rbp-0x830]
  447e72:	mov    r8,QWORD PTR [r10]
  447e75:	lea    r10,[rbp-0x830]
  447e7c:	mov    r9,QWORD PTR [r10+0x8]
  447e80:	mov    r10,QWORD PTR [rbp-0x3e20]
  447e87:	mov    r11,rdi
  447e8a:	mov    QWORD PTR [r10+0x8],r11
  447e8e:	mov    rdi,rsi
  447e91:	sub    rdi,0x2
  447e98:	mov    r10,QWORD PTR [rbp-0x3e20]
  447e9f:	mov    r11,rdi
  447ea2:	mov    QWORD PTR [r10+0x108],r11
  447ea9:	mov    QWORD PTR [rdx],r8
  447eac:	mov    QWORD PTR [rdx+0x8],r9
  447eb0:	movabs rdi,0x8
  447eba:	shl    rdi,0x28
  447ebe:	movabs r11,0x200000000000000
  447ec8:	mov    rsi,rdi
  447ecb:	or     rsi,r11
  447ece:	mov    r11,QWORD PTR [rbp-0x3e28]
  447ed5:	mov    rbx,rsi
  447ed8:	or     rbx,r11
  447edb:	jmp    447f0c <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x6586>
  447ee0:	mov    rdi,r12
  447ee3:	movabs rsi,0x8
  447eed:	mov    esi,esi
  447eef:	lea    rdx,[rbp-0x830]
  447ef6:	movabs rcx,0x2
  447f00:	mov    ecx,ecx
  447f02:	xor    eax,eax
  447f04:	call   461a80 <p111_rt_ctor>
  447f09:	mov    rbx,rax
  447f0c:	lea    r10,[rbp-0x830]
  447f13:	mov    r11,rbx
  447f16:	mov    QWORD PTR [r10],r11
  447f19:	lea    r10,[rip+0x28cc0]        # 470be0 <p111_program>
  447f20:	movabs rdi,0x4
  447f2a:	and    rdi,QWORD PTR [r10+0x58]
  447f2e:	mov    r10,rdi
  447f31:	test   r10d,r10d
  447f34:	je     447f92 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x660c>
  447f3a:	lea    r10,[rbp-0x830]
  447f41:	mov    rdi,QWORD PTR [r10]
  447f44:	mov    QWORD PTR [r12+0x28],rdi
  447f49:	mov    r10,r12
  447f4c:	movabs r11,0x1
  447f56:	mov    DWORD PTR [r10+0x1c],r11d
  447f5a:	mov    rdi,QWORD PTR [r12+0x10]
  447f5f:	movabs r11,0xfffffffffffffff8
  447f69:	mov    rsi,rdi
  447f6c:	add    rsi,r11
  447f6f:	mov    QWORD PTR [r12+0x10],rsi
  447f74:	mov    rdi,QWORD PTR [rsi]
  447f77:	mov    DWORD PTR [r12+0x20],edi
  447f7c:	movabs r10,0x0
  447f86:	mov    QWORD PTR [rbp-0xa90],r10
  447f8d:	jmp    447fb6 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x6630>
  447f92:	mov    rdi,r12
  447f95:	lea    rsi,[rbp-0x830]
  447f9c:	movabs rdx,0x1
  447fa6:	mov    edx,edx
  447fa8:	xor    eax,eax
  447faa:	call   462030 <p111_rt_return>
  447faf:	mov    QWORD PTR [rbp-0xa90],rax
  447fb6:	mov    rax,QWORD PTR [rbp-0xa90]
  447fbd:	mov    r12,QWORD PTR [rbp-0x10]
  447fc1:	mov    rbx,QWORD PTR [rbp-0x8]
  447fc5:	mov    r13,QWORD PTR [rbp-0x18]
  447fc9:	mov    r14,QWORD PTR [rbp-0x20]
  447fcd:	mov    r15,QWORD PTR [rbp-0x28]
  447fd1:	mov    rsp,rbp
  447fd4:	pop    rbp
  447fd5:	ret    
  447fd6:	mov    rdi,r12
  447fd9:	mov    rsi,QWORD PTR [rbp-0x8a8]
  447fe0:	xor    eax,eax
  447fe2:	call   461a10 <p111_rt_sink>
  447fe7:	mov    QWORD PTR [rbp-0x8a0],rax
  447fee:	mov    rdi,r12
  447ff1:	mov    rsi,QWORD PTR [rbp-0x33a8]
  447ff8:	xor    eax,eax
  447ffa:	call   461a10 <p111_rt_sink>
  447fff:	mov    QWORD PTR [rbp-0x8a0],rax
  448006:	mov    rdi,r12
  448009:	mov    rsi,QWORD PTR [rbp-0x33b0]
  448010:	xor    eax,eax
  448012:	call   461a10 <p111_rt_sink>
  448017:	mov    QWORD PTR [rbp-0x8a0],rax
  44801e:	mov    rdi,r12
  448021:	mov    rsi,QWORD PTR [rbp-0x33b8]
  448028:	xor    eax,eax
  44802a:	call   461a10 <p111_rt_sink>
  44802f:	mov    QWORD PTR [rbp-0x8a0],rax
  448036:	mov    rdi,r12
  448039:	mov    rsi,QWORD PTR [rbp-0x33c0]
  448040:	xor    eax,eax
  448042:	call   461a10 <p111_rt_sink>
  448047:	mov    QWORD PTR [rbp-0x8a0],rax
  44804e:	lea    r10,[rbp-0x830]
  448055:	mov    r11,QWORD PTR [rbp-0x33c8]
  44805c:	mov    QWORD PTR [r10],r11
  44805f:	mov    rdi,QWORD PTR [r12+0x10]
  448064:	mov    r10,rdi
  448067:	mov    r11,QWORD PTR [rbp-0x33c8]
  44806e:	mov    QWORD PTR [r10],r11
  448071:	mov    r10,rdi
  448074:	movabs r11,0x168
  44807e:	mov    QWORD PTR [r10+0x8],r11
  448082:	mov    rsi,rdi
  448085:	add    rsi,0x10
  44808c:	mov    QWORD PTR [r12+0x10],rsi
  448091:	mov    rdi,r12
  448094:	movabs rsi,0x4
  44809e:	mov    esi,esi
  4480a0:	xor    eax,eax
  4480a2:	call   4621a0 <p111_rt_fail>
  4480a7:	mov    QWORD PTR [rbp-0xa90],rax
  4480ae:	mov    r12,QWORD PTR [rbp-0x10]
  4480b2:	mov    rbx,QWORD PTR [rbp-0x8]
  4480b6:	mov    r13,QWORD PTR [rbp-0x18]
  4480ba:	mov    r14,QWORD PTR [rbp-0x20]
  4480be:	mov    r15,QWORD PTR [rbp-0x28]
  4480c2:	mov    rsp,rbp
  4480c5:	pop    rbp
  4480c6:	ret    
  4480c7:	mov    rdi,r12
  4480ca:	mov    rsi,QWORD PTR [rbp-0x8a8]
  4480d1:	xor    eax,eax
  4480d3:	call   461a10 <p111_rt_sink>
  4480d8:	mov    QWORD PTR [rbp-0x8a0],rax
  4480df:	mov    rdi,r12
  4480e2:	mov    rsi,QWORD PTR [rbp-0x33a8]
  4480e9:	xor    eax,eax
  4480eb:	call   461a10 <p111_rt_sink>
  4480f0:	mov    QWORD PTR [rbp-0x8a0],rax
  4480f7:	mov    rdi,r12
  4480fa:	mov    rsi,QWORD PTR [rbp-0x33b0]
  448101:	xor    eax,eax
  448103:	call   461a10 <p111_rt_sink>
  448108:	mov    QWORD PTR [rbp-0x8a0],rax
  44810f:	mov    rdi,r12
  448112:	mov    rsi,QWORD PTR [rbp-0x33b8]
  448119:	xor    eax,eax
  44811b:	call   461a10 <p111_rt_sink>
  448120:	mov    QWORD PTR [rbp-0x8a0],rax
  448127:	lea    r10,[rbp-0x830]
  44812e:	mov    r11,r14
  448131:	mov    QWORD PTR [r10],r11
  448134:	mov    rdi,QWORD PTR [r12+0x10]
  448139:	mov    QWORD PTR [rdi],r14
  44813c:	mov    r10,rdi
  44813f:	movabs r11,0x169
  448149:	mov    QWORD PTR [r10+0x8],r11
  44814d:	mov    rsi,rdi
  448150:	add    rsi,0x10
  448157:	mov    QWORD PTR [r12+0x10],rsi
  44815c:	mov    rdi,r12
  44815f:	movabs rsi,0x4
  448169:	mov    esi,esi
  44816b:	xor    eax,eax
  44816d:	call   4621a0 <p111_rt_fail>
  448172:	mov    QWORD PTR [rbp-0xa90],rax
  448179:	mov    r12,QWORD PTR [rbp-0x10]
  44817d:	mov    rbx,QWORD PTR [rbp-0x8]
  448181:	mov    r13,QWORD PTR [rbp-0x18]
  448185:	mov    r14,QWORD PTR [rbp-0x20]
  448189:	mov    r15,QWORD PTR [rbp-0x28]
  44818d:	mov    rsp,rbp
  448190:	pop    rbp
  448191:	ret    
  448192:	mov    r15,QWORD PTR [rbp-0x8b8]
  448199:	shr    r15,0x28
  44819d:	and    r15,0xffff
  4481a4:	movabs r11,0x2c
  4481ae:	mov    r13,r15
  4481b1:	cmp    r13,r11
  4481b4:	sete   r13b
  4481b8:	movzx  r13d,r13b
  4481bc:	mov    r10,r13
  4481bf:	test   r10d,r10d
  4481c2:	je     449139 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x77b3>
  4481c8:	mov    rdi,r12
  4481cb:	mov    rsi,QWORD PTR [rbp-0x8b8]
  4481d2:	lea    rdx,[rbp-0x830]
  4481d9:	xor    eax,eax
  4481db:	call   4677b0 <p125_rt_take2>
  4481e0:	mov    QWORD PTR [rbp-0x8a0],rax
  4481e7:	lea    r10,[rbp-0x830]
  4481ee:	mov    r10,QWORD PTR [r10]
  4481f1:	mov    QWORD PTR [rbp-0x3ed8],r10
  4481f8:	lea    r10,[rbp-0x830]
  4481ff:	mov    r10,QWORD PTR [r10+0x8]
  448203:	mov    QWORD PTR [rbp-0x3ee0],r10
  44820a:	mov    r15,r14
  44820d:	shr    r15,0x28
  448211:	and    r15,0xffff
  448218:	movabs r11,0x8
  448222:	mov    r13,r15
  448225:	cmp    r13,r11
  448228:	sete   r13b
  44822c:	movzx  r13d,r13b
  448230:	mov    r10,r13
  448233:	test   r10d,r10d
  448236:	je     44903e <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x76b8>
  44823c:	mov    rdi,r12
  44823f:	mov    rsi,r14
  448242:	lea    rdx,[rbp-0x830]
  448249:	xor    eax,eax
  44824b:	call   4677b0 <p125_rt_take2>
  448250:	mov    QWORD PTR [rbp-0x8a0],rax
  448257:	lea    r10,[rbp-0x830]
  44825e:	mov    r10,QWORD PTR [r10]
  448261:	mov    QWORD PTR [rbp-0x3ee8],r10
  448268:	lea    r10,[rbp-0x830]
  44826f:	mov    r10,QWORD PTR [r10+0x8]
  448273:	mov    QWORD PTR [rbp-0x3ef0],r10
  44827a:	cmp    r10,0x1
  448281:	sete   r10b
  448285:	movzx  r10d,r10b
  448289:	mov    QWORD PTR [rbp-0x8d0],r10
  448290:	mov    r10,QWORD PTR [rbp-0x3ef0]
  448297:	shr    r10,0x28
  44829b:	mov    QWORD PTR [rbp-0x8d8],r10
  4482a2:	and    r10,0x7fffff
  4482a9:	mov    QWORD PTR [rbp-0x8d8],r10
  4482b0:	movabs r10,0x2
  4482ba:	or     r10,0x10000
  4482c1:	mov    QWORD PTR [rbp-0x8e0],r10
  4482c8:	mov    r10,QWORD PTR [rbp-0x8d8]
  4482cf:	mov    r11,QWORD PTR [rbp-0x8e0]
  4482d6:	cmp    r10,r11
  4482d9:	sete   r10b
  4482dd:	movzx  r10d,r10b
  4482e1:	mov    QWORD PTR [rbp-0x8e8],r10
  4482e8:	mov    r11,r10
  4482eb:	mov    r13,QWORD PTR [rbp-0x8d0]
  4482f2:	or     r13d,r11d
  4482f5:	xor    r13d,0x1
  4482fc:	mov    r10,r13
  4482ff:	test   r10d,r10d
  448302:	je     4486f6 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x6d70>
  448308:	mov    rdi,QWORD PTR [rbp-0x3ed8]
  44830f:	lea    r10,[rbp-0x830]
  448316:	mov    r11,rdi
  448319:	mov    QWORD PTR [r10],r11
  44831c:	lea    r10,[rbp-0x830]
  448323:	mov    r11,QWORD PTR [rbp-0x3ee0]
  44832a:	mov    QWORD PTR [r10+0x8],r11
  44832e:	mov    r10,r12
  448331:	mov    r10,QWORD PTR [r10+0x8]
  448335:	mov    QWORD PTR [rbp-0x3f00],r10
  44833c:	mov    r10,QWORD PTR [r10+0x8]
  448340:	mov    QWORD PTR [rbp-0x3f08],r10
  448347:	cmp    r10,0x0
  44834e:	je     4483ef <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x6a69>
  448354:	mov    rdi,QWORD PTR [r12]
  448358:	mov    rsi,QWORD PTR [rbp-0x3f08]
  44835f:	shl    rsi,0x3
  448363:	mov    rdx,rdi
  448366:	add    rdx,rsi
  448369:	mov    rdi,QWORD PTR [rdx]
  44836c:	mov    r10,QWORD PTR [rbp-0x3f00]
  448373:	mov    rsi,QWORD PTR [r10+0x108]
  44837a:	lea    r10,[rbp-0x830]
  448381:	mov    r8,QWORD PTR [r10]
  448384:	lea    r10,[rbp-0x830]
  44838b:	mov    r9,QWORD PTR [r10+0x8]
  44838f:	mov    r10,QWORD PTR [rbp-0x3f00]
  448396:	mov    r11,rdi
  448399:	mov    QWORD PTR [r10+0x8],r11
  44839d:	mov    rdi,rsi
  4483a0:	sub    rdi,0x2
  4483a7:	mov    r10,QWORD PTR [rbp-0x3f00]
  4483ae:	mov    r11,rdi
  4483b1:	mov    QWORD PTR [r10+0x108],r11
  4483b8:	mov    QWORD PTR [rdx],r8
  4483bb:	mov    QWORD PTR [rdx+0x8],r9
  4483bf:	movabs rdi,0x2c
  4483c9:	shl    rdi,0x28
  4483cd:	movabs r11,0x200000000000000
  4483d7:	mov    rsi,rdi
  4483da:	or     rsi,r11
  4483dd:	mov    r11,QWORD PTR [rbp-0x3f08]
  4483e4:	mov    rbx,rsi
  4483e7:	or     rbx,r11
  4483ea:	jmp    44841b <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x6a95>
  4483ef:	mov    rdi,r12
  4483f2:	movabs rsi,0x2c
  4483fc:	mov    esi,esi
  4483fe:	lea    rdx,[rbp-0x830]
  448405:	movabs rcx,0x2
  44840f:	mov    ecx,ecx
  448411:	xor    eax,eax
  448413:	call   461a80 <p111_rt_ctor>
  448418:	mov    rbx,rax
  44841b:	mov    rdi,rbx
  44841e:	lea    r10,[rbp-0x830]
  448425:	mov    r11,QWORD PTR [rbp-0x8a8]
  44842c:	mov    QWORD PTR [r10],r11
  44842f:	lea    r10,[rbp-0x830]
  448436:	mov    r11,rdi
  448439:	mov    QWORD PTR [r10+0x8],r11
  44843d:	mov    rdi,QWORD PTR [r12+0x10]
  448442:	mov    rsi,QWORD PTR [rbp-0x8a8]
  448449:	mov    QWORD PTR [rdi],rsi
  44844c:	lea    r10,[rbp-0x830]
  448453:	mov    rsi,QWORD PTR [r10+0x8]
  448457:	mov    QWORD PTR [rdi+0x8],rsi
  44845b:	mov    r10,rdi
  44845e:	movabs r11,0x16a
  448468:	mov    QWORD PTR [r10+0x10],r11
  44846c:	mov    rsi,rdi
  44846f:	add    rsi,0x18
  448476:	mov    QWORD PTR [r12+0x10],rsi
  44847b:	mov    rdi,r12
  44847e:	mov    rsi,QWORD PTR [rbp-0x33a8]
  448485:	xor    eax,eax
  448487:	call   461980 <p111_rt_keep>
  44848c:	mov    QWORD PTR [rbp-0x33a8],rax
  448493:	mov    rdi,rax
  448496:	lea    r10,[rbp-0x830]
  44849d:	mov    r11,rdi
  4484a0:	mov    QWORD PTR [r10],r11
  4484a3:	lea    r10,[rbp-0x830]
  4484aa:	mov    r11,QWORD PTR [rbp-0x33b0]
  4484b1:	mov    QWORD PTR [r10+0x8],r11
  4484b5:	lea    r10,[rbp-0x830]
  4484bc:	mov    r11,QWORD PTR [rbp-0x33b8]
  4484c3:	mov    QWORD PTR [r10+0x10],r11
  4484c7:	mov    r10,r12
  4484ca:	mov    r10,QWORD PTR [r10+0x8]
  4484ce:	mov    QWORD PTR [rbp-0x3f90],r10
  4484d5:	mov    r10,QWORD PTR [r10+0x10]
  4484d9:	mov    QWORD PTR [rbp-0x3f98],r10
  4484e0:	cmp    r10,0x0
  4484e7:	je     4485a8 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x6c22>
  4484ed:	mov    rdi,QWORD PTR [r12]
  4484f1:	mov    rsi,QWORD PTR [rbp-0x3f98]
  4484f8:	shl    rsi,0x3
  4484fc:	mov    rdx,rdi
  4484ff:	add    rdx,rsi
  448502:	mov    rdi,QWORD PTR [rdx]
  448505:	mov    r10,QWORD PTR [rbp-0x3f90]
  44850c:	mov    rsi,QWORD PTR [r10+0x110]
  448513:	lea    r10,[rbp-0x830]
  44851a:	mov    r8,QWORD PTR [r10]
  44851d:	lea    r10,[rbp-0x830]
  448524:	mov    r9,QWORD PTR [r10+0x8]
  448528:	lea    r10,[rbp-0x830]
  44852f:	mov    r10,QWORD PTR [r10+0x10]
  448533:	mov    QWORD PTR [rbp-0x3fe0],r10
  44853a:	mov    r10,QWORD PTR [rbp-0x3f90]
  448541:	mov    r11,rdi
  448544:	mov    QWORD PTR [r10+0x10],r11
  448548:	mov    rdi,rsi
  44854b:	sub    rdi,0x4
  448552:	mov    r10,QWORD PTR [rbp-0x3f90]
  448559:	mov    r11,rdi
  44855c:	mov    QWORD PTR [r10+0x110],r11
  448563:	mov    QWORD PTR [rdx],r8
  448566:	mov    QWORD PTR [rdx+0x8],r9
  44856a:	mov    r10,rdx
  44856d:	mov    r11,QWORD PTR [rbp-0x3fe0]
  448574:	mov    QWORD PTR [r10+0x10],r11
  448578:	movabs rdi,0x2d
  448582:	shl    rdi,0x28
  448586:	movabs r11,0x200000000000000
  448590:	mov    rsi,rdi
  448593:	or     rsi,r11
  448596:	mov    r11,QWORD PTR [rbp-0x3f98]
  44859d:	mov    rbx,rsi
  4485a0:	or     rbx,r11
  4485a3:	jmp    4485d4 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x6c4e>
  4485a8:	mov    rdi,r12
  4485ab:	movabs rsi,0x2d
  4485b5:	mov    esi,esi
  4485b7:	lea    rdx,[rbp-0x830]
  4485be:	movabs rcx,0x3
  4485c8:	mov    ecx,ecx
  4485ca:	xor    eax,eax
  4485cc:	call   461a80 <p111_rt_ctor>
  4485d1:	mov    rbx,rax
  4485d4:	mov    r10,rbx
  4485d7:	mov    QWORD PTR [rbp-0x4000],r10
  4485de:	mov    r10,QWORD PTR [rbp-0x33a8]
  4485e5:	mov    QWORD PTR [rbp-0x4008],r10
  4485ec:	mov    rdi,r12
  4485ef:	mov    rsi,QWORD PTR [rbp-0x3ee8]
  4485f6:	mov    rdx,QWORD PTR [rbp-0x4008]
  4485fd:	xor    eax,eax
  4485ff:	call   40eddf <p112w_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_>
  448604:	mov    QWORD PTR [rbp-0x4010],rax
  44860b:	lea    r10,[rbp-0x4810]
  448612:	mov    r11,QWORD PTR [rbp-0x4000]
  448619:	mov    QWORD PTR [r10],r11
  44861c:	lea    r10,[rbp-0x4810]
  448623:	mov    r11,QWORD PTR [rbp-0x4010]
  44862a:	mov    QWORD PTR [r10+0x8],r11
  44862e:	lea    r10,[rip+0x285ab]        # 470be0 <p111_program>
  448635:	movabs rdi,0x4
  44863f:	and    rdi,QWORD PTR [r10+0x58]
  448643:	mov    r10,rdi
  448646:	test   r10d,r10d
  448649:	je     4486a6 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x6d20>
  44864f:	lea    r10,[rbp-0x4810]
  448656:	mov    rdi,QWORD PTR [r10]
  448659:	lea    r10,[rbp-0x4810]
  448660:	mov    rsi,QWORD PTR [r10+0x8]
  448664:	mov    QWORD PTR [r12+0x28],rdi
  448669:	mov    QWORD PTR [r12+0x30],rsi
  44866e:	mov    r10,r12
  448671:	movabs r11,0x0
  44867b:	mov    DWORD PTR [r10+0x1c],r11d
  44867f:	mov    r10,r12
  448682:	movabs r11,0x151
  44868c:	mov    DWORD PTR [r10+0x20],r11d
  448690:	movabs r10,0x0
  44869a:	mov    QWORD PTR [rbp-0x4838],r10
  4486a1:	jmp    4486d6 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x6d50>
  4486a6:	mov    rdi,r12
  4486a9:	movabs rsi,0x151
  4486b3:	mov    esi,esi
  4486b5:	lea    rdx,[rbp-0x4810]
  4486bc:	movabs rcx,0x2
  4486c6:	mov    ecx,ecx
  4486c8:	xor    eax,eax
  4486ca:	call   461fd0 <p111_rt_jump>
  4486cf:	mov    QWORD PTR [rbp-0x4838],rax
  4486d6:	mov    rax,QWORD PTR [rbp-0x4838]
  4486dd:	mov    r12,QWORD PTR [rbp-0x10]
  4486e1:	mov    rbx,QWORD PTR [rbp-0x8]
  4486e5:	mov    r13,QWORD PTR [rbp-0x18]
  4486e9:	mov    r14,QWORD PTR [rbp-0x20]
  4486ed:	mov    r15,QWORD PTR [rbp-0x28]
  4486f1:	mov    rsp,rbp
  4486f4:	pop    rbp
  4486f5:	ret    
  4486f6:	mov    r10,QWORD PTR [rbp-0x3ef0]
  4486fd:	cmp    r10,0x1
  448704:	sete   r10b
  448708:	movzx  r10d,r10b
  44870c:	mov    QWORD PTR [rbp-0x8d0],r10
  448713:	mov    r10,QWORD PTR [rbp-0x3ef0]
  44871a:	shr    r10,0x28
  44871e:	mov    QWORD PTR [rbp-0x8d8],r10
  448725:	and    r10,0x7fffff
  44872c:	mov    QWORD PTR [rbp-0x8d8],r10
  448733:	movabs r10,0x2
  44873d:	or     r10,0x10000
  448744:	mov    QWORD PTR [rbp-0x8e0],r10
  44874b:	mov    r10,QWORD PTR [rbp-0x8d8]
  448752:	mov    r11,QWORD PTR [rbp-0x8e0]
  448759:	cmp    r10,r11
  44875c:	sete   r10b
  448760:	movzx  r10d,r10b
  448764:	mov    QWORD PTR [rbp-0x8e8],r10
  44876b:	mov    r11,r10
  44876e:	mov    r13,QWORD PTR [rbp-0x8d0]
  448775:	or     r13d,r11d
  448778:	mov    r10,r13
  44877b:	test   r10d,r10d
  44877e:	je     448f1d <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x7597>
  448784:	mov    rdi,QWORD PTR [rbp-0x33a8]
  44878b:	lea    r10,[rbp-0x830]
  448792:	mov    r11,rdi
  448795:	mov    QWORD PTR [r10],r11
  448798:	lea    r10,[rbp-0x830]
  44879f:	mov    r11,QWORD PTR [rbp-0x33b0]
  4487a6:	mov    QWORD PTR [r10+0x8],r11
  4487aa:	lea    r10,[rbp-0x830]
  4487b1:	mov    r11,QWORD PTR [rbp-0x33b8]
  4487b8:	mov    QWORD PTR [r10+0x10],r11
  4487bc:	mov    r10,r12
  4487bf:	mov    r10,QWORD PTR [r10+0x8]
  4487c3:	mov    QWORD PTR [rbp-0x4848],r10
  4487ca:	mov    r10,QWORD PTR [r10+0x10]
  4487ce:	mov    QWORD PTR [rbp-0x4850],r10
  4487d5:	cmp    r10,0x0
  4487dc:	je     44889d <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x6f17>
  4487e2:	mov    rdi,QWORD PTR [r12]
  4487e6:	mov    rsi,QWORD PTR [rbp-0x4850]
  4487ed:	shl    rsi,0x3
  4487f1:	mov    rdx,rdi
  4487f4:	add    rdx,rsi
  4487f7:	mov    rdi,QWORD PTR [rdx]
  4487fa:	mov    r10,QWORD PTR [rbp-0x4848]
  448801:	mov    rsi,QWORD PTR [r10+0x110]
  448808:	lea    r10,[rbp-0x830]
  44880f:	mov    r8,QWORD PTR [r10]
  448812:	lea    r10,[rbp-0x830]
  448819:	mov    r9,QWORD PTR [r10+0x8]
  44881d:	lea    r10,[rbp-0x830]
  448824:	mov    r10,QWORD PTR [r10+0x10]
  448828:	mov    QWORD PTR [rbp-0x4898],r10
  44882f:	mov    r10,QWORD PTR [rbp-0x4848]
  448836:	mov    r11,rdi
  448839:	mov    QWORD PTR [r10+0x10],r11
  44883d:	mov    rdi,rsi
  448840:	sub    rdi,0x4
  448847:	mov    r10,QWORD PTR [rbp-0x4848]
  44884e:	mov    r11,rdi
  448851:	mov    QWORD PTR [r10+0x110],r11
  448858:	mov    QWORD PTR [rdx],r8
  44885b:	mov    QWORD PTR [rdx+0x8],r9
  44885f:	mov    r10,rdx
  448862:	mov    r11,QWORD PTR [rbp-0x4898]
  448869:	mov    QWORD PTR [r10+0x10],r11
  44886d:	movabs rdi,0x2d
  448877:	shl    rdi,0x28
  44887b:	movabs r11,0x200000000000000
  448885:	mov    rsi,rdi
  448888:	or     rsi,r11
  44888b:	mov    r11,QWORD PTR [rbp-0x4850]
  448892:	mov    rbx,rsi
  448895:	or     rbx,r11
  448898:	jmp    4488c9 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x6f43>
  44889d:	mov    rdi,r12
  4488a0:	movabs rsi,0x2d
  4488aa:	mov    esi,esi
  4488ac:	lea    rdx,[rbp-0x830]
  4488b3:	movabs rcx,0x3
  4488bd:	mov    ecx,ecx
  4488bf:	xor    eax,eax
  4488c1:	call   461a80 <p111_rt_ctor>
  4488c6:	mov    rbx,rax
  4488c9:	mov    r10,rbx
  4488cc:	mov    QWORD PTR [rbp-0x48b8],r10
  4488d3:	mov    rdi,r12
  4488d6:	mov    rsi,QWORD PTR [rbp-0x3ed8]
  4488dd:	xor    eax,eax
  4488df:	call   461980 <p111_rt_keep>
  4488e4:	mov    QWORD PTR [rbp-0x3ed8],rax
  4488eb:	mov    rdi,rax
  4488ee:	lea    r10,[rbp-0x830]
  4488f5:	mov    r11,rdi
  4488f8:	mov    QWORD PTR [r10],r11
  4488fb:	lea    r10,[rbp-0x830]
  448902:	mov    r11,QWORD PTR [rbp-0x3ee0]
  448909:	mov    QWORD PTR [r10+0x8],r11
  44890d:	mov    r10,r12
  448910:	mov    r10,QWORD PTR [r10+0x8]
  448914:	mov    QWORD PTR [rbp-0x48c8],r10
  44891b:	mov    r10,QWORD PTR [r10+0x8]
  44891f:	mov    QWORD PTR [rbp-0x48d0],r10
  448926:	cmp    r10,0x0
  44892d:	je     4489ce <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x7048>
  448933:	mov    rdi,QWORD PTR [r12]
  448937:	mov    rsi,QWORD PTR [rbp-0x48d0]
  44893e:	shl    rsi,0x3
  448942:	mov    rdx,rdi
  448945:	add    rdx,rsi
  448948:	mov    rdi,QWORD PTR [rdx]
  44894b:	mov    r10,QWORD PTR [rbp-0x48c8]
  448952:	mov    rsi,QWORD PTR [r10+0x108]
  448959:	lea    r10,[rbp-0x830]
  448960:	mov    r8,QWORD PTR [r10]
  448963:	lea    r10,[rbp-0x830]
  44896a:	mov    r9,QWORD PTR [r10+0x8]
  44896e:	mov    r10,QWORD PTR [rbp-0x48c8]
  448975:	mov    r11,rdi
  448978:	mov    QWORD PTR [r10+0x8],r11
  44897c:	mov    rdi,rsi
  44897f:	sub    rdi,0x2
  448986:	mov    r10,QWORD PTR [rbp-0x48c8]
  44898d:	mov    r11,rdi
  448990:	mov    QWORD PTR [r10+0x108],r11
  448997:	mov    QWORD PTR [rdx],r8
  44899a:	mov    QWORD PTR [rdx+0x8],r9
  44899e:	movabs rdi,0x2c
  4489a8:	shl    rdi,0x28
  4489ac:	movabs r11,0x200000000000000
  4489b6:	mov    rsi,rdi
  4489b9:	or     rsi,r11
  4489bc:	mov    r11,QWORD PTR [rbp-0x48d0]
  4489c3:	mov    rbx,rsi
  4489c6:	or     rbx,r11
  4489c9:	jmp    4489fa <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x7074>
  4489ce:	mov    rdi,r12
  4489d1:	movabs rsi,0x2c
  4489db:	mov    esi,esi
  4489dd:	lea    rdx,[rbp-0x830]
  4489e4:	movabs rcx,0x2
  4489ee:	mov    ecx,ecx
  4489f0:	xor    eax,eax
  4489f2:	call   461a80 <p111_rt_ctor>
  4489f7:	mov    rbx,rax
  4489fa:	mov    rdi,rbx
  4489fd:	lea    r10,[rbp-0x830]
  448a04:	mov    r11,QWORD PTR [rbp-0x8a8]
  448a0b:	mov    QWORD PTR [r10],r11
  448a0e:	lea    r10,[rbp-0x830]
  448a15:	mov    r11,QWORD PTR [rbp-0x48b8]
  448a1c:	mov    QWORD PTR [r10+0x8],r11
  448a20:	lea    r10,[rbp-0x830]
  448a27:	mov    r11,rdi
  448a2a:	mov    QWORD PTR [r10+0x10],r11
  448a2e:	mov    r10,r12
  448a31:	mov    r10,QWORD PTR [r10+0x8]
  448a35:	mov    QWORD PTR [rbp-0x4938],r10
  448a3c:	mov    r10,QWORD PTR [r10+0x10]
  448a40:	mov    QWORD PTR [rbp-0x4940],r10
  448a47:	cmp    r10,0x0
  448a4e:	je     448b0f <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x7189>
  448a54:	mov    rdi,QWORD PTR [r12]
  448a58:	mov    rsi,QWORD PTR [rbp-0x4940]
  448a5f:	shl    rsi,0x3
  448a63:	mov    rdx,rdi
  448a66:	add    rdx,rsi
  448a69:	mov    rdi,QWORD PTR [rdx]
  448a6c:	mov    r10,QWORD PTR [rbp-0x4938]
  448a73:	mov    rsi,QWORD PTR [r10+0x110]
  448a7a:	lea    r10,[rbp-0x830]
  448a81:	mov    r8,QWORD PTR [r10]
  448a84:	lea    r10,[rbp-0x830]
  448a8b:	mov    r9,QWORD PTR [r10+0x8]
  448a8f:	lea    r10,[rbp-0x830]
  448a96:	mov    r10,QWORD PTR [r10+0x10]
  448a9a:	mov    QWORD PTR [rbp-0x4988],r10
  448aa1:	mov    r10,QWORD PTR [rbp-0x4938]
  448aa8:	mov    r11,rdi
  448aab:	mov    QWORD PTR [r10+0x10],r11
  448aaf:	mov    rdi,rsi
  448ab2:	sub    rdi,0x4
  448ab9:	mov    r10,QWORD PTR [rbp-0x4938]
  448ac0:	mov    r11,rdi
  448ac3:	mov    QWORD PTR [r10+0x110],r11
  448aca:	mov    QWORD PTR [rdx],r8
  448acd:	mov    QWORD PTR [rdx+0x8],r9
  448ad1:	mov    r10,rdx
  448ad4:	mov    r11,QWORD PTR [rbp-0x4988]
  448adb:	mov    QWORD PTR [r10+0x10],r11
  448adf:	movabs rdi,0x2d
  448ae9:	shl    rdi,0x28
  448aed:	movabs r11,0x200000000000000
  448af7:	mov    rsi,rdi
  448afa:	or     rsi,r11
  448afd:	mov    r11,QWORD PTR [rbp-0x4940]
  448b04:	mov    rbx,rsi
  448b07:	or     rbx,r11
  448b0a:	jmp    448b3b <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x71b5>
  448b0f:	mov    rdi,r12
  448b12:	movabs rsi,0x2d
  448b1c:	mov    esi,esi
  448b1e:	lea    rdx,[rbp-0x830]
  448b25:	movabs rcx,0x3
  448b2f:	mov    ecx,ecx
  448b31:	xor    eax,eax
  448b33:	call   461a80 <p111_rt_ctor>
  448b38:	mov    rbx,rax
  448b3b:	mov    r10,rbx
  448b3e:	mov    QWORD PTR [rbp-0x49a8],r10
  448b45:	mov    rdi,QWORD PTR [rbp-0x3ed8]
  448b4c:	lea    r10,[rbp-0x830]
  448b53:	mov    r11,rdi
  448b56:	mov    QWORD PTR [r10],r11
  448b59:	mov    r10,r12
  448b5c:	mov    r10,QWORD PTR [r10+0x8]
  448b60:	mov    QWORD PTR [rbp-0x49b8],r10
  448b67:	mov    r10,QWORD PTR [r10]
  448b6a:	mov    QWORD PTR [rbp-0x49c0],r10
  448b71:	cmp    r10,0x0
  448b78:	je     448c09 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x7283>
  448b7e:	mov    rdi,QWORD PTR [r12]
  448b82:	mov    rsi,QWORD PTR [rbp-0x49c0]
  448b89:	shl    rsi,0x3
  448b8d:	mov    rdx,rdi
  448b90:	add    rdx,rsi
  448b93:	mov    rdi,QWORD PTR [rdx]
  448b96:	mov    r10,QWORD PTR [rbp-0x49b8]
  448b9d:	mov    rsi,QWORD PTR [r10+0x100]
  448ba4:	lea    r10,[rbp-0x830]
  448bab:	mov    r8,QWORD PTR [r10]
  448bae:	mov    r10,QWORD PTR [rbp-0x49b8]
  448bb5:	mov    r11,rdi
  448bb8:	mov    QWORD PTR [r10],r11
  448bbb:	mov    rdi,rsi
  448bbe:	sub    rdi,0x1
  448bc5:	mov    r10,QWORD PTR [rbp-0x49b8]
  448bcc:	mov    r11,rdi
  448bcf:	mov    QWORD PTR [r10+0x100],r11
  448bd6:	mov    QWORD PTR [rdx],r8
  448bd9:	movabs rdi,0xc
  448be3:	shl    rdi,0x28
  448be7:	movabs r11,0x200000000000000
  448bf1:	mov    rsi,rdi
  448bf4:	or     rsi,r11
  448bf7:	mov    r11,QWORD PTR [rbp-0x49c0]
  448bfe:	mov    rbx,rsi
  448c01:	or     rbx,r11
  448c04:	jmp    448c35 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x72af>
  448c09:	mov    rdi,r12
  448c0c:	movabs rsi,0xc
  448c16:	mov    esi,esi
  448c18:	lea    rdx,[rbp-0x830]
  448c1f:	movabs rcx,0x1
  448c29:	mov    ecx,ecx
  448c2b:	xor    eax,eax
  448c2d:	call   461a80 <p111_rt_ctor>
  448c32:	mov    rbx,rax
  448c35:	mov    rdi,rbx
  448c38:	lea    r10,[rbp-0x830]
  448c3f:	mov    r11,QWORD PTR [rbp-0x3ee8]
  448c46:	mov    QWORD PTR [r10],r11
  448c49:	lea    r10,[rbp-0x830]
  448c50:	mov    r11,rdi
  448c53:	mov    QWORD PTR [r10+0x8],r11
  448c57:	mov    r10,r12
  448c5a:	mov    r10,QWORD PTR [r10+0x8]
  448c5e:	mov    QWORD PTR [rbp-0x4a20],r10
  448c65:	mov    r10,QWORD PTR [r10+0x8]
  448c69:	mov    QWORD PTR [rbp-0x4a28],r10
  448c70:	cmp    r10,0x0
  448c77:	je     448d18 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x7392>
  448c7d:	mov    rdi,QWORD PTR [r12]
  448c81:	mov    rsi,QWORD PTR [rbp-0x4a28]
  448c88:	shl    rsi,0x3
  448c8c:	mov    rdx,rdi
  448c8f:	add    rdx,rsi
  448c92:	mov    rdi,QWORD PTR [rdx]
  448c95:	mov    r10,QWORD PTR [rbp-0x4a20]
  448c9c:	mov    rsi,QWORD PTR [r10+0x108]
  448ca3:	lea    r10,[rbp-0x830]
  448caa:	mov    r8,QWORD PTR [r10]
  448cad:	lea    r10,[rbp-0x830]
  448cb4:	mov    r9,QWORD PTR [r10+0x8]
  448cb8:	mov    r10,QWORD PTR [rbp-0x4a20]
  448cbf:	mov    r11,rdi
  448cc2:	mov    QWORD PTR [r10+0x8],r11
  448cc6:	mov    rdi,rsi
  448cc9:	sub    rdi,0x2
  448cd0:	mov    r10,QWORD PTR [rbp-0x4a20]
  448cd7:	mov    r11,rdi
  448cda:	mov    QWORD PTR [r10+0x108],r11
  448ce1:	mov    QWORD PTR [rdx],r8
  448ce4:	mov    QWORD PTR [rdx+0x8],r9
  448ce8:	movabs rdi,0x8
  448cf2:	shl    rdi,0x28
  448cf6:	movabs r11,0x200000000000000
  448d00:	mov    rsi,rdi
  448d03:	or     rsi,r11
  448d06:	mov    r11,QWORD PTR [rbp-0x4a28]
  448d0d:	mov    rbx,rsi
  448d10:	or     rbx,r11
  448d13:	jmp    448d44 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x73be>
  448d18:	mov    rdi,r12
  448d1b:	movabs rsi,0x8
  448d25:	mov    esi,esi
  448d27:	lea    rdx,[rbp-0x830]
  448d2e:	movabs rcx,0x2
  448d38:	mov    ecx,ecx
  448d3a:	xor    eax,eax
  448d3c:	call   461a80 <p111_rt_ctor>
  448d41:	mov    rbx,rax
  448d44:	mov    rdi,rbx
  448d47:	lea    r10,[rbp-0x830]
  448d4e:	mov    r11,QWORD PTR [rbp-0x49a8]
  448d55:	mov    QWORD PTR [r10],r11
  448d58:	lea    r10,[rbp-0x830]
  448d5f:	mov    r11,rdi
  448d62:	mov    QWORD PTR [r10+0x8],r11
  448d66:	mov    r10,r12
  448d69:	mov    r10,QWORD PTR [r10+0x8]
  448d6d:	mov    QWORD PTR [rbp-0x4a90],r10
  448d74:	mov    r10,QWORD PTR [r10+0x8]
  448d78:	mov    QWORD PTR [rbp-0x4a98],r10
  448d7f:	cmp    r10,0x0
  448d86:	je     448e27 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x74a1>
  448d8c:	mov    rdi,QWORD PTR [r12]
  448d90:	mov    rsi,QWORD PTR [rbp-0x4a98]
  448d97:	shl    rsi,0x3
  448d9b:	mov    rdx,rdi
  448d9e:	add    rdx,rsi
  448da1:	mov    rdi,QWORD PTR [rdx]
  448da4:	mov    r10,QWORD PTR [rbp-0x4a90]
  448dab:	mov    rsi,QWORD PTR [r10+0x108]
  448db2:	lea    r10,[rbp-0x830]
  448db9:	mov    r8,QWORD PTR [r10]
  448dbc:	lea    r10,[rbp-0x830]
  448dc3:	mov    r9,QWORD PTR [r10+0x8]
  448dc7:	mov    r10,QWORD PTR [rbp-0x4a90]
  448dce:	mov    r11,rdi
  448dd1:	mov    QWORD PTR [r10+0x8],r11
  448dd5:	mov    rdi,rsi
  448dd8:	sub    rdi,0x2
  448ddf:	mov    r10,QWORD PTR [rbp-0x4a90]
  448de6:	mov    r11,rdi
  448de9:	mov    QWORD PTR [r10+0x108],r11
  448df0:	mov    QWORD PTR [rdx],r8
  448df3:	mov    QWORD PTR [rdx+0x8],r9
  448df7:	movabs rdi,0x8
  448e01:	shl    rdi,0x28
  448e05:	movabs r11,0x200000000000000
  448e0f:	mov    rsi,rdi
  448e12:	or     rsi,r11
  448e15:	mov    r11,QWORD PTR [rbp-0x4a98]
  448e1c:	mov    rbx,rsi
  448e1f:	or     rbx,r11
  448e22:	jmp    448e53 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x74cd>
  448e27:	mov    rdi,r12
  448e2a:	movabs rsi,0x8
  448e34:	mov    esi,esi
  448e36:	lea    rdx,[rbp-0x830]
  448e3d:	movabs rcx,0x2
  448e47:	mov    ecx,ecx
  448e49:	xor    eax,eax
  448e4b:	call   461a80 <p111_rt_ctor>
  448e50:	mov    rbx,rax
  448e53:	lea    r10,[rbp-0x830]
  448e5a:	mov    r11,rbx
  448e5d:	mov    QWORD PTR [r10],r11
  448e60:	lea    r10,[rip+0x27d79]        # 470be0 <p111_program>
  448e67:	movabs rdi,0x4
  448e71:	and    rdi,QWORD PTR [r10+0x58]
  448e75:	mov    r10,rdi
  448e78:	test   r10d,r10d
  448e7b:	je     448ed9 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x7553>
  448e81:	lea    r10,[rbp-0x830]
  448e88:	mov    rdi,QWORD PTR [r10]
  448e8b:	mov    QWORD PTR [r12+0x28],rdi
  448e90:	mov    r10,r12
  448e93:	movabs r11,0x1
  448e9d:	mov    DWORD PTR [r10+0x1c],r11d
  448ea1:	mov    rdi,QWORD PTR [r12+0x10]
  448ea6:	movabs r11,0xfffffffffffffff8
  448eb0:	mov    rsi,rdi
  448eb3:	add    rsi,r11
  448eb6:	mov    QWORD PTR [r12+0x10],rsi
  448ebb:	mov    rdi,QWORD PTR [rsi]
  448ebe:	mov    DWORD PTR [r12+0x20],edi
  448ec3:	movabs r10,0x0
  448ecd:	mov    QWORD PTR [rbp-0xa90],r10
  448ed4:	jmp    448efd <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x7577>
  448ed9:	mov    rdi,r12
  448edc:	lea    rsi,[rbp-0x830]
  448ee3:	movabs rdx,0x1
  448eed:	mov    edx,edx
  448eef:	xor    eax,eax
  448ef1:	call   462030 <p111_rt_return>
  448ef6:	mov    QWORD PTR [rbp-0xa90],rax
  448efd:	mov    rax,QWORD PTR [rbp-0xa90]
  448f04:	mov    r12,QWORD PTR [rbp-0x10]
  448f08:	mov    rbx,QWORD PTR [rbp-0x8]
  448f0c:	mov    r13,QWORD PTR [rbp-0x18]
  448f10:	mov    r14,QWORD PTR [rbp-0x20]
  448f14:	mov    r15,QWORD PTR [rbp-0x28]
  448f18:	mov    rsp,rbp
  448f1b:	pop    rbp
  448f1c:	ret    
  448f1d:	mov    rdi,r12
  448f20:	mov    rsi,QWORD PTR [rbp-0x8a8]
  448f27:	xor    eax,eax
  448f29:	call   461a10 <p111_rt_sink>
  448f2e:	mov    QWORD PTR [rbp-0x8a0],rax
  448f35:	mov    rdi,r12
  448f38:	mov    rsi,QWORD PTR [rbp-0x33a8]
  448f3f:	xor    eax,eax
  448f41:	call   461a10 <p111_rt_sink>
  448f46:	mov    QWORD PTR [rbp-0x8a0],rax
  448f4d:	mov    rdi,r12
  448f50:	mov    rsi,QWORD PTR [rbp-0x33b0]
  448f57:	xor    eax,eax
  448f59:	call   461a10 <p111_rt_sink>
  448f5e:	mov    QWORD PTR [rbp-0x8a0],rax
  448f65:	mov    rdi,r12
  448f68:	mov    rsi,QWORD PTR [rbp-0x33b8]
  448f6f:	xor    eax,eax
  448f71:	call   461a10 <p111_rt_sink>
  448f76:	mov    QWORD PTR [rbp-0x8a0],rax
  448f7d:	mov    rdi,r12
  448f80:	mov    rsi,QWORD PTR [rbp-0x3ed8]
  448f87:	xor    eax,eax
  448f89:	call   461a10 <p111_rt_sink>
  448f8e:	mov    QWORD PTR [rbp-0x8a0],rax
  448f95:	mov    rdi,r12
  448f98:	mov    rsi,QWORD PTR [rbp-0x3ee0]
  448f9f:	xor    eax,eax
  448fa1:	call   461a10 <p111_rt_sink>
  448fa6:	mov    QWORD PTR [rbp-0x8a0],rax
  448fad:	mov    rdi,r12
  448fb0:	mov    rsi,QWORD PTR [rbp-0x3ee8]
  448fb7:	xor    eax,eax
  448fb9:	call   461a10 <p111_rt_sink>
  448fbe:	mov    QWORD PTR [rbp-0x8a0],rax
  448fc5:	lea    r10,[rbp-0x830]
  448fcc:	mov    r11,QWORD PTR [rbp-0x3ef0]
  448fd3:	mov    QWORD PTR [r10],r11
  448fd6:	mov    rdi,QWORD PTR [r12+0x10]
  448fdb:	mov    r10,rdi
  448fde:	mov    r11,QWORD PTR [rbp-0x3ef0]
  448fe5:	mov    QWORD PTR [r10],r11
  448fe8:	mov    r10,rdi
  448feb:	movabs r11,0x16c
  448ff5:	mov    QWORD PTR [r10+0x8],r11
  448ff9:	mov    rsi,rdi
  448ffc:	add    rsi,0x10
  449003:	mov    QWORD PTR [r12+0x10],rsi
  449008:	mov    rdi,r12
  44900b:	movabs rsi,0x4
  449015:	mov    esi,esi
  449017:	xor    eax,eax
  449019:	call   4621a0 <p111_rt_fail>
  44901e:	mov    QWORD PTR [rbp-0xa90],rax
  449025:	mov    r12,QWORD PTR [rbp-0x10]
  449029:	mov    rbx,QWORD PTR [rbp-0x8]
  44902d:	mov    r13,QWORD PTR [rbp-0x18]
  449031:	mov    r14,QWORD PTR [rbp-0x20]
  449035:	mov    r15,QWORD PTR [rbp-0x28]
  449039:	mov    rsp,rbp
  44903c:	pop    rbp
  44903d:	ret    
  44903e:	mov    rdi,r12
  449041:	mov    rsi,QWORD PTR [rbp-0x8a8]
  449048:	xor    eax,eax
  44904a:	call   461a10 <p111_rt_sink>
  44904f:	mov    QWORD PTR [rbp-0x8a0],rax
  449056:	mov    rdi,r12
  449059:	mov    rsi,QWORD PTR [rbp-0x33a8]
  449060:	xor    eax,eax
  449062:	call   461a10 <p111_rt_sink>
  449067:	mov    QWORD PTR [rbp-0x8a0],rax
  44906e:	mov    rdi,r12
  449071:	mov    rsi,QWORD PTR [rbp-0x33b0]
  449078:	xor    eax,eax
  44907a:	call   461a10 <p111_rt_sink>
  44907f:	mov    QWORD PTR [rbp-0x8a0],rax
  449086:	mov    rdi,r12
  449089:	mov    rsi,QWORD PTR [rbp-0x33b8]
  449090:	xor    eax,eax
  449092:	call   461a10 <p111_rt_sink>
  449097:	mov    QWORD PTR [rbp-0x8a0],rax
  44909e:	mov    rdi,r12
  4490a1:	mov    rsi,QWORD PTR [rbp-0x3ed8]
  4490a8:	xor    eax,eax
  4490aa:	call   461a10 <p111_rt_sink>
  4490af:	mov    QWORD PTR [rbp-0x8a0],rax
  4490b6:	mov    rdi,r12
  4490b9:	mov    rsi,QWORD PTR [rbp-0x3ee0]
  4490c0:	xor    eax,eax
  4490c2:	call   461a10 <p111_rt_sink>
  4490c7:	mov    QWORD PTR [rbp-0x8a0],rax
  4490ce:	lea    r10,[rbp-0x830]
  4490d5:	mov    r11,r14
  4490d8:	mov    QWORD PTR [r10],r11
  4490db:	mov    rdi,QWORD PTR [r12+0x10]
  4490e0:	mov    QWORD PTR [rdi],r14
  4490e3:	mov    r10,rdi
  4490e6:	movabs r11,0x16d
  4490f0:	mov    QWORD PTR [r10+0x8],r11
  4490f4:	mov    rsi,rdi
  4490f7:	add    rsi,0x10
  4490fe:	mov    QWORD PTR [r12+0x10],rsi
  449103:	mov    rdi,r12
  449106:	movabs rsi,0x4
  449110:	mov    esi,esi
  449112:	xor    eax,eax
  449114:	call   4621a0 <p111_rt_fail>
  449119:	mov    QWORD PTR [rbp-0xa90],rax
  449120:	mov    r12,QWORD PTR [rbp-0x10]
  449124:	mov    rbx,QWORD PTR [rbp-0x8]
  449128:	mov    r13,QWORD PTR [rbp-0x18]
  44912c:	mov    r14,QWORD PTR [rbp-0x20]
  449130:	mov    r15,QWORD PTR [rbp-0x28]
  449134:	mov    rsp,rbp
  449137:	pop    rbp
  449138:	ret    
  449139:	mov    r15,QWORD PTR [rbp-0x8b8]
  449140:	shr    r15,0x28
  449144:	and    r15,0xffff
  44914b:	movabs r11,0x2d
  449155:	mov    r13,r15
  449158:	cmp    r13,r11
  44915b:	sete   r13b
  44915f:	movzx  r13d,r13b
  449163:	mov    r10,r13
  449166:	test   r10d,r10d
  449169:	je     449ddb <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x8455>
  44916f:	mov    rdi,r12
  449172:	mov    rsi,QWORD PTR [rbp-0x8b8]
  449179:	lea    rdx,[rbp-0x830]
  449180:	xor    eax,eax
  449182:	call   467a10 <p125_rt_take3>
  449187:	mov    QWORD PTR [rbp-0x8a0],rax
  44918e:	lea    r10,[rbp-0x830]
  449195:	mov    r10,QWORD PTR [r10]
  449198:	mov    QWORD PTR [rbp-0x4b48],r10
  44919f:	lea    r10,[rbp-0x830]
  4491a6:	mov    r10,QWORD PTR [r10+0x8]
  4491aa:	mov    QWORD PTR [rbp-0x4b50],r10
  4491b1:	lea    r10,[rbp-0x830]
  4491b8:	mov    r10,QWORD PTR [r10+0x10]
  4491bc:	mov    QWORD PTR [rbp-0x4b58],r10
  4491c3:	mov    r15,r14
  4491c6:	shr    r15,0x28
  4491ca:	and    r15,0xffff
  4491d1:	movabs r11,0x8
  4491db:	mov    r13,r15
  4491de:	cmp    r13,r11
  4491e1:	sete   r13b
  4491e5:	movzx  r13d,r13b
  4491e9:	mov    r10,r13
  4491ec:	test   r10d,r10d
  4491ef:	je     449cc8 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x8342>
  4491f5:	mov    rdi,r12
  4491f8:	mov    rsi,r14
  4491fb:	lea    rdx,[rbp-0x830]
  449202:	xor    eax,eax
  449204:	call   4677b0 <p125_rt_take2>
  449209:	mov    QWORD PTR [rbp-0x8a0],rax
  449210:	lea    r10,[rbp-0x830]
  449217:	mov    r10,QWORD PTR [r10]
  44921a:	mov    QWORD PTR [rbp-0x4b60],r10
  449221:	lea    r10,[rbp-0x830]
  449228:	mov    r10,QWORD PTR [r10+0x8]
  44922c:	mov    QWORD PTR [rbp-0x4b68],r10
  449233:	cmp    r10,0x1
  44923a:	sete   r10b
  44923e:	movzx  r10d,r10b
  449242:	mov    QWORD PTR [rbp-0x8d0],r10
  449249:	mov    r10,QWORD PTR [rbp-0x4b68]
  449250:	shr    r10,0x28
  449254:	mov    QWORD PTR [rbp-0x8d8],r10
  44925b:	and    r10,0x7fffff
  449262:	mov    QWORD PTR [rbp-0x8d8],r10
  449269:	movabs r10,0x2
  449273:	or     r10,0x10000
  44927a:	mov    QWORD PTR [rbp-0x8e0],r10
  449281:	mov    r10,QWORD PTR [rbp-0x8d8]
  449288:	mov    r11,QWORD PTR [rbp-0x8e0]
  44928f:	cmp    r10,r11
  449292:	sete   r10b
  449296:	movzx  r10d,r10b
  44929a:	mov    QWORD PTR [rbp-0x8e8],r10
  4492a1:	mov    r11,r10
  4492a4:	mov    r13,QWORD PTR [rbp-0x8d0]
  4492ab:	or     r13d,r11d
  4492ae:	xor    r13d,0x1
  4492b5:	mov    r10,r13
  4492b8:	test   r10d,r10d
  4492bb:	je     4496e1 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x7d5b>
  4492c1:	mov    rdi,QWORD PTR [rbp-0x4b48]
  4492c8:	lea    r10,[rbp-0x830]
  4492cf:	mov    r11,rdi
  4492d2:	mov    QWORD PTR [r10],r11
  4492d5:	lea    r10,[rbp-0x830]
  4492dc:	mov    r11,QWORD PTR [rbp-0x4b50]
  4492e3:	mov    QWORD PTR [r10+0x8],r11
  4492e7:	lea    r10,[rbp-0x830]
  4492ee:	mov    r11,QWORD PTR [rbp-0x4b58]
  4492f5:	mov    QWORD PTR [r10+0x10],r11
  4492f9:	mov    r10,r12
  4492fc:	mov    r10,QWORD PTR [r10+0x8]
  449300:	mov    QWORD PTR [rbp-0x4b78],r10
  449307:	mov    r10,QWORD PTR [r10+0x10]
  44930b:	mov    QWORD PTR [rbp-0x4b80],r10
  449312:	cmp    r10,0x0
  449319:	je     4493da <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x7a54>
  44931f:	mov    rdi,QWORD PTR [r12]
  449323:	mov    rsi,QWORD PTR [rbp-0x4b80]
  44932a:	shl    rsi,0x3
  44932e:	mov    rdx,rdi
  449331:	add    rdx,rsi
  449334:	mov    rdi,QWORD PTR [rdx]
  449337:	mov    r10,QWORD PTR [rbp-0x4b78]
  44933e:	mov    rsi,QWORD PTR [r10+0x110]
  449345:	lea    r10,[rbp-0x830]
  44934c:	mov    r8,QWORD PTR [r10]
  44934f:	lea    r10,[rbp-0x830]
  449356:	mov    r9,QWORD PTR [r10+0x8]
  44935a:	lea    r10,[rbp-0x830]
  449361:	mov    r10,QWORD PTR [r10+0x10]
  449365:	mov    QWORD PTR [rbp-0x4bc8],r10
  44936c:	mov    r10,QWORD PTR [rbp-0x4b78]
  449373:	mov    r11,rdi
  449376:	mov    QWORD PTR [r10+0x10],r11
  44937a:	mov    rdi,rsi
  44937d:	sub    rdi,0x4
  449384:	mov    r10,QWORD PTR [rbp-0x4b78]
  44938b:	mov    r11,rdi
  44938e:	mov    QWORD PTR [r10+0x110],r11
  449395:	mov    QWORD PTR [rdx],r8
  449398:	mov    QWORD PTR [rdx+0x8],r9
  44939c:	mov    r10,rdx
  44939f:	mov    r11,QWORD PTR [rbp-0x4bc8]
  4493a6:	mov    QWORD PTR [r10+0x10],r11
  4493aa:	movabs rdi,0x2d
  4493b4:	shl    rdi,0x28
  4493b8:	movabs r11,0x200000000000000
  4493c2:	mov    rsi,rdi
  4493c5:	or     rsi,r11
  4493c8:	mov    r11,QWORD PTR [rbp-0x4b80]
  4493cf:	mov    rbx,rsi
  4493d2:	or     rbx,r11
  4493d5:	jmp    449406 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x7a80>
  4493da:	mov    rdi,r12
  4493dd:	movabs rsi,0x2d
  4493e7:	mov    esi,esi
  4493e9:	lea    rdx,[rbp-0x830]
  4493f0:	movabs rcx,0x3
  4493fa:	mov    ecx,ecx
  4493fc:	xor    eax,eax
  4493fe:	call   461a80 <p111_rt_ctor>
  449403:	mov    rbx,rax
  449406:	mov    rdi,rbx
  449409:	lea    r10,[rbp-0x830]
  449410:	mov    r11,QWORD PTR [rbp-0x8a8]
  449417:	mov    QWORD PTR [r10],r11
  44941a:	lea    r10,[rbp-0x830]
  449421:	mov    r11,rdi
  449424:	mov    QWORD PTR [r10+0x8],r11
  449428:	mov    rdi,QWORD PTR [r12+0x10]
  44942d:	mov    rsi,QWORD PTR [rbp-0x8a8]
  449434:	mov    QWORD PTR [rdi],rsi
  449437:	lea    r10,[rbp-0x830]
  44943e:	mov    rsi,QWORD PTR [r10+0x8]
  449442:	mov    QWORD PTR [rdi+0x8],rsi
  449446:	mov    r10,rdi
  449449:	movabs r11,0x16e
  449453:	mov    QWORD PTR [r10+0x10],r11
  449457:	mov    rsi,rdi
  44945a:	add    rsi,0x18
  449461:	mov    QWORD PTR [r12+0x10],rsi
  449466:	mov    rdi,r12
  449469:	mov    rsi,QWORD PTR [rbp-0x33a8]
  449470:	xor    eax,eax
  449472:	call   461980 <p111_rt_keep>
  449477:	mov    QWORD PTR [rbp-0x33a8],rax
  44947e:	mov    rdi,rax
  449481:	lea    r10,[rbp-0x830]
  449488:	mov    r11,rdi
  44948b:	mov    QWORD PTR [r10],r11
  44948e:	lea    r10,[rbp-0x830]
  449495:	mov    r11,QWORD PTR [rbp-0x33b0]
  44949c:	mov    QWORD PTR [r10+0x8],r11
  4494a0:	lea    r10,[rbp-0x830]
  4494a7:	mov    r11,QWORD PTR [rbp-0x33b8]
  4494ae:	mov    QWORD PTR [r10+0x10],r11
  4494b2:	mov    r10,r12
  4494b5:	mov    r10,QWORD PTR [r10+0x8]
  4494b9:	mov    QWORD PTR [rbp-0x4c10],r10
  4494c0:	mov    r10,QWORD PTR [r10+0x10]
  4494c4:	mov    QWORD PTR [rbp-0x4c18],r10
  4494cb:	cmp    r10,0x0
  4494d2:	je     449593 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x7c0d>
  4494d8:	mov    rdi,QWORD PTR [r12]
  4494dc:	mov    rsi,QWORD PTR [rbp-0x4c18]
  4494e3:	shl    rsi,0x3
  4494e7:	mov    rdx,rdi
  4494ea:	add    rdx,rsi
  4494ed:	mov    rdi,QWORD PTR [rdx]
  4494f0:	mov    r10,QWORD PTR [rbp-0x4c10]
  4494f7:	mov    rsi,QWORD PTR [r10+0x110]
  4494fe:	lea    r10,[rbp-0x830]
  449505:	mov    r8,QWORD PTR [r10]
  449508:	lea    r10,[rbp-0x830]
  44950f:	mov    r9,QWORD PTR [r10+0x8]
  449513:	lea    r10,[rbp-0x830]
  44951a:	mov    r10,QWORD PTR [r10+0x10]
  44951e:	mov    QWORD PTR [rbp-0x4c60],r10
  449525:	mov    r10,QWORD PTR [rbp-0x4c10]
  44952c:	mov    r11,rdi
  44952f:	mov    QWORD PTR [r10+0x10],r11
  449533:	mov    rdi,rsi
  449536:	sub    rdi,0x4
  44953d:	mov    r10,QWORD PTR [rbp-0x4c10]
  449544:	mov    r11,rdi
  449547:	mov    QWORD PTR [r10+0x110],r11
  44954e:	mov    QWORD PTR [rdx],r8
  449551:	mov    QWORD PTR [rdx+0x8],r9
  449555:	mov    r10,rdx
  449558:	mov    r11,QWORD PTR [rbp-0x4c60]
  44955f:	mov    QWORD PTR [r10+0x10],r11
  449563:	movabs rdi,0x2d
  44956d:	shl    rdi,0x28
  449571:	movabs r11,0x200000000000000
  44957b:	mov    rsi,rdi
  44957e:	or     rsi,r11
  449581:	mov    r11,QWORD PTR [rbp-0x4c18]
  449588:	mov    rbx,rsi
  44958b:	or     rbx,r11
  44958e:	jmp    4495bf <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x7c39>
  449593:	mov    rdi,r12
  449596:	movabs rsi,0x2d
  4495a0:	mov    esi,esi
  4495a2:	lea    rdx,[rbp-0x830]
  4495a9:	movabs rcx,0x3
  4495b3:	mov    ecx,ecx
  4495b5:	xor    eax,eax
  4495b7:	call   461a80 <p111_rt_ctor>
  4495bc:	mov    rbx,rax
  4495bf:	mov    r10,rbx
  4495c2:	mov    QWORD PTR [rbp-0x4c80],r10
  4495c9:	mov    r10,QWORD PTR [rbp-0x33a8]
  4495d0:	mov    QWORD PTR [rbp-0x4c88],r10
  4495d7:	mov    rdi,r12
  4495da:	mov    rsi,QWORD PTR [rbp-0x4b60]
  4495e1:	mov    rdx,QWORD PTR [rbp-0x4c88]
  4495e8:	xor    eax,eax
  4495ea:	call   40eddf <p112w_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_>
  4495ef:	mov    QWORD PTR [rbp-0x4c90],rax
  4495f6:	lea    r10,[rbp-0x5490]
  4495fd:	mov    r11,QWORD PTR [rbp-0x4c80]
  449604:	mov    QWORD PTR [r10],r11
  449607:	lea    r10,[rbp-0x5490]
  44960e:	mov    r11,QWORD PTR [rbp-0x4c90]
  449615:	mov    QWORD PTR [r10+0x8],r11
  449619:	lea    r10,[rip+0x275c0]        # 470be0 <p111_program>
  449620:	movabs rdi,0x4
  44962a:	and    rdi,QWORD PTR [r10+0x58]
  44962e:	mov    r10,rdi
  449631:	test   r10d,r10d
  449634:	je     449691 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x7d0b>
  44963a:	lea    r10,[rbp-0x5490]
  449641:	mov    rdi,QWORD PTR [r10]
  449644:	lea    r10,[rbp-0x5490]
  44964b:	mov    rsi,QWORD PTR [r10+0x8]
  44964f:	mov    QWORD PTR [r12+0x28],rdi
  449654:	mov    QWORD PTR [r12+0x30],rsi
  449659:	mov    r10,r12
  44965c:	movabs r11,0x0
  449666:	mov    DWORD PTR [r10+0x1c],r11d
  44966a:	mov    r10,r12
  44966d:	movabs r11,0x151
  449677:	mov    DWORD PTR [r10+0x20],r11d
  44967b:	movabs r10,0x0
  449685:	mov    QWORD PTR [rbp-0x54b8],r10
  44968c:	jmp    4496c1 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x7d3b>
  449691:	mov    rdi,r12
  449694:	movabs rsi,0x151
  44969e:	mov    esi,esi
  4496a0:	lea    rdx,[rbp-0x5490]
  4496a7:	movabs rcx,0x2
  4496b1:	mov    ecx,ecx
  4496b3:	xor    eax,eax
  4496b5:	call   461fd0 <p111_rt_jump>
  4496ba:	mov    QWORD PTR [rbp-0x54b8],rax
  4496c1:	mov    rax,QWORD PTR [rbp-0x54b8]
  4496c8:	mov    r12,QWORD PTR [rbp-0x10]
  4496cc:	mov    rbx,QWORD PTR [rbp-0x8]
  4496d0:	mov    r13,QWORD PTR [rbp-0x18]
  4496d4:	mov    r14,QWORD PTR [rbp-0x20]
  4496d8:	mov    r15,QWORD PTR [rbp-0x28]
  4496dc:	mov    rsp,rbp
  4496df:	pop    rbp
  4496e0:	ret    
  4496e1:	mov    r10,QWORD PTR [rbp-0x4b68]
  4496e8:	cmp    r10,0x1
  4496ef:	sete   r10b
  4496f3:	movzx  r10d,r10b
  4496f7:	mov    QWORD PTR [rbp-0x8d0],r10
  4496fe:	mov    r10,QWORD PTR [rbp-0x4b68]
  449705:	shr    r10,0x28
  449709:	mov    QWORD PTR [rbp-0x8d8],r10
  449710:	and    r10,0x7fffff
  449717:	mov    QWORD PTR [rbp-0x8d8],r10
  44971e:	movabs r10,0x2
  449728:	or     r10,0x10000
  44972f:	mov    QWORD PTR [rbp-0x8e0],r10
  449736:	mov    r10,QWORD PTR [rbp-0x8d8]
  44973d:	mov    r11,QWORD PTR [rbp-0x8e0]
  449744:	cmp    r10,r11
  449747:	sete   r10b
  44974b:	movzx  r10d,r10b
  44974f:	mov    QWORD PTR [rbp-0x8e8],r10
  449756:	mov    r11,r10
  449759:	mov    r13,QWORD PTR [rbp-0x8d0]
  449760:	or     r13d,r11d
  449763:	mov    r10,r13
  449766:	test   r10d,r10d
  449769:	je     449b8f <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x8209>
  44976f:	mov    rdi,QWORD PTR [rbp-0x33a8]
  449776:	lea    r10,[rbp-0x830]
  44977d:	mov    r11,rdi
  449780:	mov    QWORD PTR [r10],r11
  449783:	lea    r10,[rbp-0x830]
  44978a:	mov    r11,QWORD PTR [rbp-0x33b0]
  449791:	mov    QWORD PTR [r10+0x8],r11
  449795:	lea    r10,[rbp-0x830]
  44979c:	mov    r11,QWORD PTR [rbp-0x33b8]
  4497a3:	mov    QWORD PTR [r10+0x10],r11
  4497a7:	mov    r10,r12
  4497aa:	mov    r10,QWORD PTR [r10+0x8]
  4497ae:	mov    QWORD PTR [rbp-0x54c8],r10
  4497b5:	mov    r10,QWORD PTR [r10+0x10]
  4497b9:	mov    QWORD PTR [rbp-0x54d0],r10
  4497c0:	cmp    r10,0x0
  4497c7:	je     449888 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x7f02>
  4497cd:	mov    rdi,QWORD PTR [r12]
  4497d1:	mov    rsi,QWORD PTR [rbp-0x54d0]
  4497d8:	shl    rsi,0x3
  4497dc:	mov    rdx,rdi
  4497df:	add    rdx,rsi
  4497e2:	mov    rdi,QWORD PTR [rdx]
  4497e5:	mov    r10,QWORD PTR [rbp-0x54c8]
  4497ec:	mov    rsi,QWORD PTR [r10+0x110]
  4497f3:	lea    r10,[rbp-0x830]
  4497fa:	mov    r8,QWORD PTR [r10]
  4497fd:	lea    r10,[rbp-0x830]
  449804:	mov    r9,QWORD PTR [r10+0x8]
  449808:	lea    r10,[rbp-0x830]
  44980f:	mov    r10,QWORD PTR [r10+0x10]
  449813:	mov    QWORD PTR [rbp-0x5518],r10
  44981a:	mov    r10,QWORD PTR [rbp-0x54c8]
  449821:	mov    r11,rdi
  449824:	mov    QWORD PTR [r10+0x10],r11
  449828:	mov    rdi,rsi
  44982b:	sub    rdi,0x4
  449832:	mov    r10,QWORD PTR [rbp-0x54c8]
  449839:	mov    r11,rdi
  44983c:	mov    QWORD PTR [r10+0x110],r11
  449843:	mov    QWORD PTR [rdx],r8
  449846:	mov    QWORD PTR [rdx+0x8],r9
  44984a:	mov    r10,rdx
  44984d:	mov    r11,QWORD PTR [rbp-0x5518]
  449854:	mov    QWORD PTR [r10+0x10],r11
  449858:	movabs rdi,0x2d
  449862:	shl    rdi,0x28
  449866:	movabs r11,0x200000000000000
  449870:	mov    rsi,rdi
  449873:	or     rsi,r11
  449876:	mov    r11,QWORD PTR [rbp-0x54d0]
  44987d:	mov    rbx,rsi
  449880:	or     rbx,r11
  449883:	jmp    4498b4 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x7f2e>
  449888:	mov    rdi,r12
  44988b:	movabs rsi,0x2d
  449895:	mov    esi,esi
  449897:	lea    rdx,[rbp-0x830]
  44989e:	movabs rcx,0x3
  4498a8:	mov    ecx,ecx
  4498aa:	xor    eax,eax
  4498ac:	call   461a80 <p111_rt_ctor>
  4498b1:	mov    rbx,rax
  4498b4:	mov    rdi,rbx
  4498b7:	lea    r10,[rbp-0x830]
  4498be:	mov    r11,QWORD PTR [rbp-0x8a8]
  4498c5:	mov    QWORD PTR [r10],r11
  4498c8:	lea    r10,[rbp-0x830]
  4498cf:	mov    r11,rdi
  4498d2:	mov    QWORD PTR [r10+0x8],r11
  4498d6:	mov    rdi,QWORD PTR [r12+0x10]
  4498db:	mov    rsi,QWORD PTR [rbp-0x8a8]
  4498e2:	mov    QWORD PTR [rdi],rsi
  4498e5:	lea    r10,[rbp-0x830]
  4498ec:	mov    rsi,QWORD PTR [r10+0x8]
  4498f0:	mov    QWORD PTR [rdi+0x8],rsi
  4498f4:	mov    r10,rdi
  4498f7:	movabs r11,0x170
  449901:	mov    QWORD PTR [r10+0x10],r11
  449905:	mov    rsi,rdi
  449908:	add    rsi,0x18
  44990f:	mov    QWORD PTR [r12+0x10],rsi
  449914:	mov    rdi,r12
  449917:	mov    rsi,QWORD PTR [rbp-0x4b48]
  44991e:	xor    eax,eax
  449920:	call   461980 <p111_rt_keep>
  449925:	mov    QWORD PTR [rbp-0x4b48],rax
  44992c:	mov    rdi,rax
  44992f:	lea    r10,[rbp-0x830]
  449936:	mov    r11,rdi
  449939:	mov    QWORD PTR [r10],r11
  44993c:	lea    r10,[rbp-0x830]
  449943:	mov    r11,QWORD PTR [rbp-0x4b50]
  44994a:	mov    QWORD PTR [r10+0x8],r11
  44994e:	lea    r10,[rbp-0x830]
  449955:	mov    r11,QWORD PTR [rbp-0x4b58]
  44995c:	mov    QWORD PTR [r10+0x10],r11
  449960:	mov    r10,r12
  449963:	mov    r10,QWORD PTR [r10+0x8]
  449967:	mov    QWORD PTR [rbp-0x5560],r10
  44996e:	mov    r10,QWORD PTR [r10+0x10]
  449972:	mov    QWORD PTR [rbp-0x5568],r10
  449979:	cmp    r10,0x0
  449980:	je     449a41 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x80bb>
  449986:	mov    rdi,QWORD PTR [r12]
  44998a:	mov    rsi,QWORD PTR [rbp-0x5568]
  449991:	shl    rsi,0x3
  449995:	mov    rdx,rdi
  449998:	add    rdx,rsi
  44999b:	mov    rdi,QWORD PTR [rdx]
  44999e:	mov    r10,QWORD PTR [rbp-0x5560]
  4499a5:	mov    rsi,QWORD PTR [r10+0x110]
  4499ac:	lea    r10,[rbp-0x830]
  4499b3:	mov    r8,QWORD PTR [r10]
  4499b6:	lea    r10,[rbp-0x830]
  4499bd:	mov    r9,QWORD PTR [r10+0x8]
  4499c1:	lea    r10,[rbp-0x830]
  4499c8:	mov    r10,QWORD PTR [r10+0x10]
  4499cc:	mov    QWORD PTR [rbp-0x55b0],r10
  4499d3:	mov    r10,QWORD PTR [rbp-0x5560]
  4499da:	mov    r11,rdi
  4499dd:	mov    QWORD PTR [r10+0x10],r11
  4499e1:	mov    rdi,rsi
  4499e4:	sub    rdi,0x4
  4499eb:	mov    r10,QWORD PTR [rbp-0x5560]
  4499f2:	mov    r11,rdi
  4499f5:	mov    QWORD PTR [r10+0x110],r11
  4499fc:	mov    QWORD PTR [rdx],r8
  4499ff:	mov    QWORD PTR [rdx+0x8],r9
  449a03:	mov    r10,rdx
  449a06:	mov    r11,QWORD PTR [rbp-0x55b0]
  449a0d:	mov    QWORD PTR [r10+0x10],r11
  449a11:	movabs rdi,0x2d
  449a1b:	shl    rdi,0x28
  449a1f:	movabs r11,0x200000000000000
  449a29:	mov    rsi,rdi
  449a2c:	or     rsi,r11
  449a2f:	mov    r11,QWORD PTR [rbp-0x5568]
  449a36:	mov    rbx,rsi
  449a39:	or     rbx,r11
  449a3c:	jmp    449a6d <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x80e7>
  449a41:	mov    rdi,r12
  449a44:	movabs rsi,0x2d
  449a4e:	mov    esi,esi
  449a50:	lea    rdx,[rbp-0x830]
  449a57:	movabs rcx,0x3
  449a61:	mov    ecx,ecx
  449a63:	xor    eax,eax
  449a65:	call   461a80 <p111_rt_ctor>
  449a6a:	mov    rbx,rax
  449a6d:	mov    r10,rbx
  449a70:	mov    QWORD PTR [rbp-0x55d0],r10
  449a77:	mov    r10,QWORD PTR [rbp-0x4b48]
  449a7e:	mov    QWORD PTR [rbp-0x55d8],r10
  449a85:	mov    rdi,r12
  449a88:	mov    rsi,QWORD PTR [rbp-0x4b60]
  449a8f:	mov    rdx,QWORD PTR [rbp-0x55d8]
  449a96:	xor    eax,eax
  449a98:	call   40eddf <p112w_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_>
  449a9d:	mov    QWORD PTR [rbp-0x55e0],rax
  449aa4:	lea    r10,[rbp-0x5de0]
  449aab:	mov    r11,QWORD PTR [rbp-0x55d0]
  449ab2:	mov    QWORD PTR [r10],r11
  449ab5:	lea    r10,[rbp-0x5de0]
  449abc:	mov    r11,QWORD PTR [rbp-0x55e0]
  449ac3:	mov    QWORD PTR [r10+0x8],r11
  449ac7:	lea    r10,[rip+0x27112]        # 470be0 <p111_program>
  449ace:	movabs rdi,0x4
  449ad8:	and    rdi,QWORD PTR [r10+0x58]
  449adc:	mov    r10,rdi
  449adf:	test   r10d,r10d
  449ae2:	je     449b3f <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x81b9>
  449ae8:	lea    r10,[rbp-0x5de0]
  449aef:	mov    rdi,QWORD PTR [r10]
  449af2:	lea    r10,[rbp-0x5de0]
  449af9:	mov    rsi,QWORD PTR [r10+0x8]
  449afd:	mov    QWORD PTR [r12+0x28],rdi
  449b02:	mov    QWORD PTR [r12+0x30],rsi
  449b07:	mov    r10,r12
  449b0a:	movabs r11,0x0
  449b14:	mov    DWORD PTR [r10+0x1c],r11d
  449b18:	mov    r10,r12
  449b1b:	movabs r11,0x151
  449b25:	mov    DWORD PTR [r10+0x20],r11d
  449b29:	movabs r10,0x0
  449b33:	mov    QWORD PTR [rbp-0x5e08],r10
  449b3a:	jmp    449b6f <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x81e9>
  449b3f:	mov    rdi,r12
  449b42:	movabs rsi,0x151
  449b4c:	mov    esi,esi
  449b4e:	lea    rdx,[rbp-0x5de0]
  449b55:	movabs rcx,0x2
  449b5f:	mov    ecx,ecx
  449b61:	xor    eax,eax
  449b63:	call   461fd0 <p111_rt_jump>
  449b68:	mov    QWORD PTR [rbp-0x5e08],rax
  449b6f:	mov    rax,QWORD PTR [rbp-0x5e08]
  449b76:	mov    r12,QWORD PTR [rbp-0x10]
  449b7a:	mov    rbx,QWORD PTR [rbp-0x8]
  449b7e:	mov    r13,QWORD PTR [rbp-0x18]
  449b82:	mov    r14,QWORD PTR [rbp-0x20]
  449b86:	mov    r15,QWORD PTR [rbp-0x28]
  449b8a:	mov    rsp,rbp
  449b8d:	pop    rbp
  449b8e:	ret    
  449b8f:	mov    rdi,r12
  449b92:	mov    rsi,QWORD PTR [rbp-0x8a8]
  449b99:	xor    eax,eax
  449b9b:	call   461a10 <p111_rt_sink>
  449ba0:	mov    QWORD PTR [rbp-0x8a0],rax
  449ba7:	mov    rdi,r12
  449baa:	mov    rsi,QWORD PTR [rbp-0x33a8]
  449bb1:	xor    eax,eax
  449bb3:	call   461a10 <p111_rt_sink>
  449bb8:	mov    QWORD PTR [rbp-0x8a0],rax
  449bbf:	mov    rdi,r12
  449bc2:	mov    rsi,QWORD PTR [rbp-0x33b0]
  449bc9:	xor    eax,eax
  449bcb:	call   461a10 <p111_rt_sink>
  449bd0:	mov    QWORD PTR [rbp-0x8a0],rax
  449bd7:	mov    rdi,r12
  449bda:	mov    rsi,QWORD PTR [rbp-0x33b8]
  449be1:	xor    eax,eax
  449be3:	call   461a10 <p111_rt_sink>
  449be8:	mov    QWORD PTR [rbp-0x8a0],rax
  449bef:	mov    rdi,r12
  449bf2:	mov    rsi,QWORD PTR [rbp-0x4b48]
  449bf9:	xor    eax,eax
  449bfb:	call   461a10 <p111_rt_sink>
  449c00:	mov    QWORD PTR [rbp-0x8a0],rax
  449c07:	mov    rdi,r12
  449c0a:	mov    rsi,QWORD PTR [rbp-0x4b50]
  449c11:	xor    eax,eax
  449c13:	call   461a10 <p111_rt_sink>
  449c18:	mov    QWORD PTR [rbp-0x8a0],rax
  449c1f:	mov    rdi,r12
  449c22:	mov    rsi,QWORD PTR [rbp-0x4b58]
  449c29:	xor    eax,eax
  449c2b:	call   461a10 <p111_rt_sink>
  449c30:	mov    QWORD PTR [rbp-0x8a0],rax
  449c37:	mov    rdi,r12
  449c3a:	mov    rsi,QWORD PTR [rbp-0x4b60]
  449c41:	xor    eax,eax
  449c43:	call   461a10 <p111_rt_sink>
  449c48:	mov    QWORD PTR [rbp-0x8a0],rax
  449c4f:	lea    r10,[rbp-0x830]
  449c56:	mov    r11,QWORD PTR [rbp-0x4b68]
  449c5d:	mov    QWORD PTR [r10],r11
  449c60:	mov    rdi,QWORD PTR [r12+0x10]
  449c65:	mov    r10,rdi
  449c68:	mov    r11,QWORD PTR [rbp-0x4b68]
  449c6f:	mov    QWORD PTR [r10],r11
  449c72:	mov    r10,rdi
  449c75:	movabs r11,0x172
  449c7f:	mov    QWORD PTR [r10+0x8],r11
  449c83:	mov    rsi,rdi
  449c86:	add    rsi,0x10
  449c8d:	mov    QWORD PTR [r12+0x10],rsi
  449c92:	mov    rdi,r12
  449c95:	movabs rsi,0x4
  449c9f:	mov    esi,esi
  449ca1:	xor    eax,eax
  449ca3:	call   4621a0 <p111_rt_fail>
  449ca8:	mov    QWORD PTR [rbp-0xa90],rax
  449caf:	mov    r12,QWORD PTR [rbp-0x10]
  449cb3:	mov    rbx,QWORD PTR [rbp-0x8]
  449cb7:	mov    r13,QWORD PTR [rbp-0x18]
  449cbb:	mov    r14,QWORD PTR [rbp-0x20]
  449cbf:	mov    r15,QWORD PTR [rbp-0x28]
  449cc3:	mov    rsp,rbp
  449cc6:	pop    rbp
  449cc7:	ret    
  449cc8:	mov    rdi,r12
  449ccb:	mov    rsi,QWORD PTR [rbp-0x8a8]
  449cd2:	xor    eax,eax
  449cd4:	call   461a10 <p111_rt_sink>
  449cd9:	mov    QWORD PTR [rbp-0x8a0],rax
  449ce0:	mov    rdi,r12
  449ce3:	mov    rsi,QWORD PTR [rbp-0x33a8]
  449cea:	xor    eax,eax
  449cec:	call   461a10 <p111_rt_sink>
  449cf1:	mov    QWORD PTR [rbp-0x8a0],rax
  449cf8:	mov    rdi,r12
  449cfb:	mov    rsi,QWORD PTR [rbp-0x33b0]
  449d02:	xor    eax,eax
  449d04:	call   461a10 <p111_rt_sink>
  449d09:	mov    QWORD PTR [rbp-0x8a0],rax
  449d10:	mov    rdi,r12
  449d13:	mov    rsi,QWORD PTR [rbp-0x33b8]
  449d1a:	xor    eax,eax
  449d1c:	call   461a10 <p111_rt_sink>
  449d21:	mov    QWORD PTR [rbp-0x8a0],rax
  449d28:	mov    rdi,r12
  449d2b:	mov    rsi,QWORD PTR [rbp-0x4b48]
  449d32:	xor    eax,eax
  449d34:	call   461a10 <p111_rt_sink>
  449d39:	mov    QWORD PTR [rbp-0x8a0],rax
  449d40:	mov    rdi,r12
  449d43:	mov    rsi,QWORD PTR [rbp-0x4b50]
  449d4a:	xor    eax,eax
  449d4c:	call   461a10 <p111_rt_sink>
  449d51:	mov    QWORD PTR [rbp-0x8a0],rax
  449d58:	mov    rdi,r12
  449d5b:	mov    rsi,QWORD PTR [rbp-0x4b58]
  449d62:	xor    eax,eax
  449d64:	call   461a10 <p111_rt_sink>
  449d69:	mov    QWORD PTR [rbp-0x8a0],rax
  449d70:	lea    r10,[rbp-0x830]
  449d77:	mov    r11,r14
  449d7a:	mov    QWORD PTR [r10],r11
  449d7d:	mov    rdi,QWORD PTR [r12+0x10]
  449d82:	mov    QWORD PTR [rdi],r14
  449d85:	mov    r10,rdi
  449d88:	movabs r11,0x173
  449d92:	mov    QWORD PTR [r10+0x8],r11
  449d96:	mov    rsi,rdi
  449d99:	add    rsi,0x10
  449da0:	mov    QWORD PTR [r12+0x10],rsi
  449da5:	mov    rdi,r12
  449da8:	movabs rsi,0x4
  449db2:	mov    esi,esi
  449db4:	xor    eax,eax
  449db6:	call   4621a0 <p111_rt_fail>
  449dbb:	mov    QWORD PTR [rbp-0xa90],rax
  449dc2:	mov    r12,QWORD PTR [rbp-0x10]
  449dc6:	mov    rbx,QWORD PTR [rbp-0x8]
  449dca:	mov    r13,QWORD PTR [rbp-0x18]
  449dce:	mov    r14,QWORD PTR [rbp-0x20]
  449dd2:	mov    r15,QWORD PTR [rbp-0x28]
  449dd6:	mov    rsp,rbp
  449dd9:	pop    rbp
  449dda:	ret    
  449ddb:	mov    rdi,r12
  449dde:	mov    rsi,QWORD PTR [rbp-0x8a8]
  449de5:	xor    eax,eax
  449de7:	call   461a10 <p111_rt_sink>
  449dec:	mov    QWORD PTR [rbp-0x8a0],rax
  449df3:	mov    rdi,r12
  449df6:	mov    rsi,QWORD PTR [rbp-0x33a8]
  449dfd:	xor    eax,eax
  449dff:	call   461a10 <p111_rt_sink>
  449e04:	mov    QWORD PTR [rbp-0x8a0],rax
  449e0b:	mov    rdi,r12
  449e0e:	mov    rsi,QWORD PTR [rbp-0x33b0]
  449e15:	xor    eax,eax
  449e17:	call   461a10 <p111_rt_sink>
  449e1c:	mov    QWORD PTR [rbp-0x8a0],rax
  449e23:	mov    rdi,r12
  449e26:	mov    rsi,QWORD PTR [rbp-0x33b8]
  449e2d:	xor    eax,eax
  449e2f:	call   461a10 <p111_rt_sink>
  449e34:	mov    QWORD PTR [rbp-0x8a0],rax
  449e3b:	lea    r10,[rbp-0x830]
  449e42:	mov    r11,r14
  449e45:	mov    QWORD PTR [r10],r11
  449e48:	mov    rdi,QWORD PTR [r12+0x10]
  449e4d:	mov    QWORD PTR [rdi],r14
  449e50:	mov    r10,rdi
  449e53:	movabs r11,0x174
  449e5d:	mov    QWORD PTR [r10+0x8],r11
  449e61:	mov    rsi,rdi
  449e64:	add    rsi,0x10
  449e6b:	mov    QWORD PTR [r12+0x10],rsi
  449e70:	lea    r10,[rbp-0x830]
  449e77:	mov    r11,QWORD PTR [rbp-0x8b8]
  449e7e:	mov    QWORD PTR [r10],r11
  449e81:	mov    rdi,QWORD PTR [r12+0x10]
  449e86:	mov    r10,rdi
  449e89:	mov    r11,QWORD PTR [rbp-0x8b8]
  449e90:	mov    QWORD PTR [r10],r11
  449e93:	mov    r10,rdi
  449e96:	movabs r11,0x175
  449ea0:	mov    QWORD PTR [r10+0x8],r11
  449ea4:	mov    rsi,rdi
  449ea7:	add    rsi,0x10
  449eae:	mov    QWORD PTR [r12+0x10],rsi
  449eb3:	mov    rdi,r12
  449eb6:	movabs rsi,0x4
  449ec0:	mov    esi,esi
  449ec2:	xor    eax,eax
  449ec4:	call   4621a0 <p111_rt_fail>
  449ec9:	mov    QWORD PTR [rbp-0xa90],rax
  449ed0:	mov    r12,QWORD PTR [rbp-0x10]
  449ed4:	mov    rbx,QWORD PTR [rbp-0x8]
  449ed8:	mov    r13,QWORD PTR [rbp-0x18]
  449edc:	mov    r14,QWORD PTR [rbp-0x20]
  449ee0:	mov    r15,QWORD PTR [rbp-0x28]
  449ee4:	mov    rsp,rbp
  449ee7:	pop    rbp
  449ee8:	ret    
  449ee9:	mov    rdi,r12
  449eec:	mov    rsi,QWORD PTR [rbp-0x8a8]
  449ef3:	xor    eax,eax
  449ef5:	call   461a10 <p111_rt_sink>
  449efa:	mov    QWORD PTR [rbp-0x8a0],rax
  449f01:	lea    r10,[rbp-0x830]
  449f08:	mov    r11,r14
  449f0b:	mov    QWORD PTR [r10],r11
  449f0e:	mov    rdi,QWORD PTR [r12+0x10]
  449f13:	mov    QWORD PTR [rdi],r14
  449f16:	mov    r10,rdi
  449f19:	movabs r11,0x176
  449f23:	mov    QWORD PTR [r10+0x8],r11
  449f27:	mov    rsi,rdi
  449f2a:	add    rsi,0x10
  449f31:	mov    QWORD PTR [r12+0x10],rsi
  449f36:	lea    r10,[rbp-0x830]
  449f3d:	mov    r11,QWORD PTR [rbp-0x8b8]
  449f44:	mov    QWORD PTR [r10],r11
  449f47:	mov    rdi,QWORD PTR [r12+0x10]
  449f4c:	mov    r10,rdi
  449f4f:	mov    r11,QWORD PTR [rbp-0x8b8]
  449f56:	mov    QWORD PTR [r10],r11
  449f59:	mov    r10,rdi
  449f5c:	movabs r11,0x177
  449f66:	mov    QWORD PTR [r10+0x8],r11
  449f6a:	mov    rsi,rdi
  449f6d:	add    rsi,0x10
  449f74:	mov    QWORD PTR [r12+0x10],rsi
  449f79:	lea    r10,[rbp-0x830]
  449f80:	mov    r11,QWORD PTR [rbp-0x8b0]
  449f87:	mov    QWORD PTR [r10],r11
  449f8a:	mov    rdi,QWORD PTR [r12+0x10]
  449f8f:	mov    r10,rdi
  449f92:	mov    r11,QWORD PTR [rbp-0x8b0]
  449f99:	mov    QWORD PTR [r10],r11
  449f9c:	mov    r10,rdi
  449f9f:	movabs r11,0x178
  449fa9:	mov    QWORD PTR [r10+0x8],r11
  449fad:	mov    rsi,rdi
  449fb0:	add    rsi,0x10
  449fb7:	mov    QWORD PTR [r12+0x10],rsi
  449fbc:	mov    rdi,r12
  449fbf:	movabs rsi,0x4
  449fc9:	mov    esi,esi
  449fcb:	xor    eax,eax
  449fcd:	call   4621a0 <p111_rt_fail>
  449fd2:	mov    QWORD PTR [rbp-0xa90],rax
  449fd9:	mov    r12,QWORD PTR [rbp-0x10]
  449fdd:	mov    rbx,QWORD PTR [rbp-0x8]
  449fe1:	mov    r13,QWORD PTR [rbp-0x18]
  449fe5:	mov    r14,QWORD PTR [rbp-0x20]
  449fe9:	mov    r15,QWORD PTR [rbp-0x28]
  449fed:	mov    rsp,rbp
  449ff0:	pop    rbp
  449ff1:	ret    
  449ff2:	mov    r15,r14
  449ff5:	shr    r15,0x28
  449ff9:	and    r15,0xffff
  44a000:	movabs r11,0x8
  44a00a:	mov    r13,r15
  44a00d:	cmp    r13,r11
  44a010:	sete   r13b
  44a014:	movzx  r13d,r13b
  44a018:	mov    r10,r13
  44a01b:	test   r10d,r10d
  44a01e:	je     44a369 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x89e3>
  44a024:	mov    rdi,r12
  44a027:	mov    rsi,r14
  44a02a:	lea    rdx,[rbp-0x830]
  44a031:	xor    eax,eax
  44a033:	call   4677b0 <p125_rt_take2>
  44a038:	mov    QWORD PTR [rbp-0x8a0],rax
  44a03f:	lea    r10,[rbp-0x830]
  44a046:	mov    r10,QWORD PTR [r10]
  44a049:	mov    QWORD PTR [rbp-0x5e80],r10
  44a050:	lea    r10,[rbp-0x830]
  44a057:	mov    r10,QWORD PTR [r10+0x8]
  44a05b:	mov    QWORD PTR [rbp-0x5e88],r10
  44a062:	mov    rdi,r12
  44a065:	mov    rsi,QWORD PTR [rbp-0x5e88]
  44a06c:	xor    eax,eax
  44a06e:	call   461a10 <p111_rt_sink>
  44a073:	mov    QWORD PTR [rbp-0x8a0],rax
  44a07a:	movabs rdi,0x1000b0000000000
  44a084:	lea    r10,[rbp-0x830]
  44a08b:	mov    r11,QWORD PTR [rbp-0x5e80]
  44a092:	mov    QWORD PTR [r10],r11
  44a095:	lea    r10,[rbp-0x830]
  44a09c:	mov    r11,rdi
  44a09f:	mov    QWORD PTR [r10+0x8],r11
  44a0a3:	mov    r10,r12
  44a0a6:	mov    r10,QWORD PTR [r10+0x8]
  44a0aa:	mov    QWORD PTR [rbp-0x5e98],r10
  44a0b1:	mov    r10,QWORD PTR [r10+0x8]
  44a0b5:	mov    QWORD PTR [rbp-0x5ea0],r10
  44a0bc:	cmp    r10,0x0
  44a0c3:	je     44a164 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x87de>
  44a0c9:	mov    rdi,QWORD PTR [r12]
  44a0cd:	mov    rsi,QWORD PTR [rbp-0x5ea0]
  44a0d4:	shl    rsi,0x3
  44a0d8:	mov    rdx,rdi
  44a0db:	add    rdx,rsi
  44a0de:	mov    rdi,QWORD PTR [rdx]
  44a0e1:	mov    r10,QWORD PTR [rbp-0x5e98]
  44a0e8:	mov    rsi,QWORD PTR [r10+0x108]
  44a0ef:	lea    r10,[rbp-0x830]
  44a0f6:	mov    r8,QWORD PTR [r10]
  44a0f9:	lea    r10,[rbp-0x830]
  44a100:	mov    r9,QWORD PTR [r10+0x8]
  44a104:	mov    r10,QWORD PTR [rbp-0x5e98]
  44a10b:	mov    r11,rdi
  44a10e:	mov    QWORD PTR [r10+0x8],r11
  44a112:	mov    rdi,rsi
  44a115:	sub    rdi,0x2
  44a11c:	mov    r10,QWORD PTR [rbp-0x5e98]
  44a123:	mov    r11,rdi
  44a126:	mov    QWORD PTR [r10+0x108],r11
  44a12d:	mov    QWORD PTR [rdx],r8
  44a130:	mov    QWORD PTR [rdx+0x8],r9
  44a134:	movabs rdi,0x8
  44a13e:	shl    rdi,0x28
  44a142:	movabs r11,0x200000000000000
  44a14c:	mov    rsi,rdi
  44a14f:	or     rsi,r11
  44a152:	mov    r11,QWORD PTR [rbp-0x5ea0]
  44a159:	mov    rbx,rsi
  44a15c:	or     rbx,r11
  44a15f:	jmp    44a190 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x880a>
  44a164:	mov    rdi,r12
  44a167:	movabs rsi,0x8
  44a171:	mov    esi,esi
  44a173:	lea    rdx,[rbp-0x830]
  44a17a:	movabs rcx,0x2
  44a184:	mov    ecx,ecx
  44a186:	xor    eax,eax
  44a188:	call   461a80 <p111_rt_ctor>
  44a18d:	mov    rbx,rax
  44a190:	mov    rdi,rbx
  44a193:	lea    r10,[rbp-0x830]
  44a19a:	mov    r11,QWORD PTR [rbp-0x880]
  44a1a1:	mov    QWORD PTR [r10],r11
  44a1a4:	lea    r10,[rbp-0x830]
  44a1ab:	mov    r11,rdi
  44a1ae:	mov    QWORD PTR [r10+0x8],r11
  44a1b2:	mov    r10,r12
  44a1b5:	mov    r10,QWORD PTR [r10+0x8]
  44a1b9:	mov    QWORD PTR [rbp-0x5f08],r10
  44a1c0:	mov    r10,QWORD PTR [r10+0x8]
  44a1c4:	mov    QWORD PTR [rbp-0x5f10],r10
  44a1cb:	cmp    r10,0x0
  44a1d2:	je     44a273 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x88ed>
  44a1d8:	mov    rdi,QWORD PTR [r12]
  44a1dc:	mov    rsi,QWORD PTR [rbp-0x5f10]
  44a1e3:	shl    rsi,0x3
  44a1e7:	mov    rdx,rdi
  44a1ea:	add    rdx,rsi
  44a1ed:	mov    rdi,QWORD PTR [rdx]
  44a1f0:	mov    r10,QWORD PTR [rbp-0x5f08]
  44a1f7:	mov    rsi,QWORD PTR [r10+0x108]
  44a1fe:	lea    r10,[rbp-0x830]
  44a205:	mov    r8,QWORD PTR [r10]
  44a208:	lea    r10,[rbp-0x830]
  44a20f:	mov    r9,QWORD PTR [r10+0x8]
  44a213:	mov    r10,QWORD PTR [rbp-0x5f08]
  44a21a:	mov    r11,rdi
  44a21d:	mov    QWORD PTR [r10+0x8],r11
  44a221:	mov    rdi,rsi
  44a224:	sub    rdi,0x2
  44a22b:	mov    r10,QWORD PTR [rbp-0x5f08]
  44a232:	mov    r11,rdi
  44a235:	mov    QWORD PTR [r10+0x108],r11
  44a23c:	mov    QWORD PTR [rdx],r8
  44a23f:	mov    QWORD PTR [rdx+0x8],r9
  44a243:	movabs rdi,0x8
  44a24d:	shl    rdi,0x28
  44a251:	movabs r11,0x200000000000000
  44a25b:	mov    rsi,rdi
  44a25e:	or     rsi,r11
  44a261:	mov    r11,QWORD PTR [rbp-0x5f10]
  44a268:	mov    rbx,rsi
  44a26b:	or     rbx,r11
  44a26e:	jmp    44a29f <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x8919>
  44a273:	mov    rdi,r12
  44a276:	movabs rsi,0x8
  44a280:	mov    esi,esi
  44a282:	lea    rdx,[rbp-0x830]
  44a289:	movabs rcx,0x2
  44a293:	mov    ecx,ecx
  44a295:	xor    eax,eax
  44a297:	call   461a80 <p111_rt_ctor>
  44a29c:	mov    rbx,rax
  44a29f:	lea    r10,[rbp-0x830]
  44a2a6:	mov    r11,rbx
  44a2a9:	mov    QWORD PTR [r10],r11
  44a2ac:	lea    r10,[rip+0x2692d]        # 470be0 <p111_program>
  44a2b3:	movabs rdi,0x4
  44a2bd:	and    rdi,QWORD PTR [r10+0x58]
  44a2c1:	mov    r10,rdi
  44a2c4:	test   r10d,r10d
  44a2c7:	je     44a325 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x899f>
  44a2cd:	lea    r10,[rbp-0x830]
  44a2d4:	mov    rdi,QWORD PTR [r10]
  44a2d7:	mov    QWORD PTR [r12+0x28],rdi
  44a2dc:	mov    r10,r12
  44a2df:	movabs r11,0x1
  44a2e9:	mov    DWORD PTR [r10+0x1c],r11d
  44a2ed:	mov    rdi,QWORD PTR [r12+0x10]
  44a2f2:	movabs r11,0xfffffffffffffff8
  44a2fc:	mov    rsi,rdi
  44a2ff:	add    rsi,r11
  44a302:	mov    QWORD PTR [r12+0x10],rsi
  44a307:	mov    rdi,QWORD PTR [rsi]
  44a30a:	mov    DWORD PTR [r12+0x20],edi
  44a30f:	movabs r10,0x0
  44a319:	mov    QWORD PTR [rbp-0xa90],r10
  44a320:	jmp    44a349 <p111_FID_36_100_105_114_101_99_116_46_77_97_112_46_115_101_101_107_46_103_111_+0x89c3>
  44a325:	mov    rdi,r12
  44a328:	lea    rsi,[rbp-0x830]
  44a32f:	movabs rdx,0x1
  44a339:	mov    edx,edx
  44a33b:	xor    eax,eax
  44a33d:	call   462030 <p111_rt_return>
  44a342:	mov    QWORD PTR [rbp-0xa90],rax
  44a349:	mov    rax,QWORD PTR [rbp-0xa90]
  44a350:	mov    r12,QWORD PTR [rbp-0x10]
  44a354:	mov    rbx,QWORD PTR [rbp-0x8]
  44a358:	mov    r13,QWORD PTR [rbp-0x18]
  44a35c:	mov    r14,QWORD PTR [rbp-0x20]
  44a360:	mov    r15,QWORD PTR [rbp-0x28]
  44a364:	mov    rsp,rbp
  44a367:	pop    rbp
  44a368:	ret    
  44a369:	mov    rdi,r12
  44a36c:	mov    rsi,QWORD PTR [rbp-0x880]
  44a373:	xor    eax,eax
  44a375:	call   461a10 <p111_rt_sink>
  44a37a:	mov    QWORD PTR [rbp-0x8a0],rax
  44a381:	lea    r10,[rbp-0x830]
  44a388:	mov    r11,r14
  44a38b:	mov    QWORD PTR [r10],r11
  44a38e:	mov    rdi,QWORD PTR [r12+0x10]
  44a393:	mov    QWORD PTR [rdi],r14
  44a396:	mov    r10,rdi
  44a399:	movabs r11,0x179
  44a3a3:	mov    QWORD PTR [r10+0x8],r11
  44a3a7:	mov    rsi,rdi
  44a3aa:	add    rsi,0x10
  44a3b1:	mov    QWORD PTR [r12+0x10],rsi
  44a3b6:	mov    rdi,r12
  44a3b9:	movabs rsi,0x4
  44a3c3:	mov    esi,esi
  44a3c5:	xor    eax,eax
  44a3c7:	call   4621a0 <p111_rt_fail>
  44a3cc:	mov    QWORD PTR [rbp-0xa90],rax
  44a3d3:	mov    r12,QWORD PTR [rbp-0x10]
  44a3d7:	mov    rbx,QWORD PTR [rbp-0x8]
  44a3db:	mov    r13,QWORD PTR [rbp-0x18]
  44a3df:	mov    r14,QWORD PTR [rbp-0x20]
  44a3e3:	mov    r15,QWORD PTR [rbp-0x28]
  44a3e7:	mov    rsp,rbp
  44a3ea:	pop    rbp
  44a3eb:	ret    

