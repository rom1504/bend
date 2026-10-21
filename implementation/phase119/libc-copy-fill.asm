
/usr/lib/x86_64-linux-gnu/libc-2.31.so:     file format elf64-x86-64


Disassembly of section .text:

00000000000a3930 <memcpy@GLIBC_2.2.5+0xc0>:
   a3930:	48 89 f8             	mov    rax,rdi
   a3933:	48 83 fa 10          	cmp    rdx,0x10
   a3937:	72 3e                	jb     a3977 <memcpy@GLIBC_2.2.5+0x107>
   a3939:	48 83 fa 20          	cmp    rdx,0x20
   a393d:	77 7e                	ja     a39bd <memcpy@GLIBC_2.2.5+0x14d>
   a393f:	0f 10 06             	movups xmm0,XMMWORD PTR [rsi]
   a3942:	0f 10 4c 16 f0       	movups xmm1,XMMWORD PTR [rsi+rdx*1-0x10]
   a3947:	0f 11 07             	movups XMMWORD PTR [rdi],xmm0
   a394a:	0f 11 4c 17 f0       	movups XMMWORD PTR [rdi+rdx*1-0x10],xmm1
   a394f:	c3                   	ret    
   a3950:	48 3b 15 29 da 12 00 	cmp    rdx,QWORD PTR [rip+0x12da29]        # 1d1380 <_obstack@GLIBC_2.2.5+0x118>
   a3957:	0f 83 e2 00 00 00    	jae    a3a3f <memcpy@GLIBC_2.2.5+0x1cf>
   a395d:	48 39 f7             	cmp    rdi,rsi
   a3960:	72 0f                	jb     a3971 <memcpy@GLIBC_2.2.5+0x101>
   a3962:	74 12                	je     a3976 <memcpy@GLIBC_2.2.5+0x106>
   a3964:	4c 8d 0c 16          	lea    r9,[rsi+rdx*1]
   a3968:	4c 39 cf             	cmp    rdi,r9
   a396b:	0f 82 63 01 00 00    	jb     a3ad4 <memcpy@GLIBC_2.2.5+0x264>
   a3971:	48 89 d1             	mov    rcx,rdx
   a3974:	f3 a4                	rep movs BYTE PTR es:[rdi],BYTE PTR ds:[rsi]
   a3976:	c3                   	ret    
   a3977:	80 fa 08             	cmp    dl,0x8
   a397a:	73 12                	jae    a398e <memcpy@GLIBC_2.2.5+0x11e>
   a397c:	80 fa 04             	cmp    dl,0x4
   a397f:	73 1e                	jae    a399f <memcpy@GLIBC_2.2.5+0x12f>
   a3981:	80 fa 01             	cmp    dl,0x1
   a3984:	77 26                	ja     a39ac <memcpy@GLIBC_2.2.5+0x13c>
   a3986:	72 05                	jb     a398d <memcpy@GLIBC_2.2.5+0x11d>
   a3988:	0f b6 0e             	movzx  ecx,BYTE PTR [rsi]
   a398b:	88 0f                	mov    BYTE PTR [rdi],cl
   a398d:	c3                   	ret    
   a398e:	48 8b 4c 16 f8       	mov    rcx,QWORD PTR [rsi+rdx*1-0x8]
   a3993:	48 8b 36             	mov    rsi,QWORD PTR [rsi]
   a3996:	48 89 4c 17 f8       	mov    QWORD PTR [rdi+rdx*1-0x8],rcx
   a399b:	48 89 37             	mov    QWORD PTR [rdi],rsi
   a399e:	c3                   	ret    
   a399f:	8b 4c 16 fc          	mov    ecx,DWORD PTR [rsi+rdx*1-0x4]
   a39a3:	8b 36                	mov    esi,DWORD PTR [rsi]
   a39a5:	89 4c 17 fc          	mov    DWORD PTR [rdi+rdx*1-0x4],ecx
   a39a9:	89 37                	mov    DWORD PTR [rdi],esi
   a39ab:	c3                   	ret    
   a39ac:	0f b7 4c 16 fe       	movzx  ecx,WORD PTR [rsi+rdx*1-0x2]
   a39b1:	0f b7 36             	movzx  esi,WORD PTR [rsi]
   a39b4:	66 89 4c 17 fe       	mov    WORD PTR [rdi+rdx*1-0x2],cx
   a39b9:	66 89 37             	mov    WORD PTR [rdi],si
   a39bc:	c3                   	ret    
   a39bd:	48 81 fa 00 08 00 00 	cmp    rdx,0x800
   a39c4:	77 8a                	ja     a3950 <memcpy@GLIBC_2.2.5+0xe0>
   a39c6:	48 81 fa 80 00 00 00 	cmp    rdx,0x80
   a39cd:	77 70                	ja     a3a3f <memcpy@GLIBC_2.2.5+0x1cf>
   a39cf:	48 83 fa 40          	cmp    rdx,0x40
   a39d3:	72 47                	jb     a3a1c <memcpy@GLIBC_2.2.5+0x1ac>
   a39d5:	0f 10 06             	movups xmm0,XMMWORD PTR [rsi]
   a39d8:	0f 10 4e 10          	movups xmm1,XMMWORD PTR [rsi+0x10]
   a39dc:	0f 10 56 20          	movups xmm2,XMMWORD PTR [rsi+0x20]
   a39e0:	0f 10 5e 30          	movups xmm3,XMMWORD PTR [rsi+0x30]
   a39e4:	0f 10 64 16 f0       	movups xmm4,XMMWORD PTR [rsi+rdx*1-0x10]
   a39e9:	0f 10 6c 16 e0       	movups xmm5,XMMWORD PTR [rsi+rdx*1-0x20]
   a39ee:	0f 10 74 16 d0       	movups xmm6,XMMWORD PTR [rsi+rdx*1-0x30]
   a39f3:	0f 10 7c 16 c0       	movups xmm7,XMMWORD PTR [rsi+rdx*1-0x40]
   a39f8:	0f 11 07             	movups XMMWORD PTR [rdi],xmm0
   a39fb:	0f 11 4f 10          	movups XMMWORD PTR [rdi+0x10],xmm1
   a39ff:	0f 11 57 20          	movups XMMWORD PTR [rdi+0x20],xmm2
   a3a03:	0f 11 5f 30          	movups XMMWORD PTR [rdi+0x30],xmm3
   a3a07:	0f 11 64 17 f0       	movups XMMWORD PTR [rdi+rdx*1-0x10],xmm4
   a3a0c:	0f 11 6c 17 e0       	movups XMMWORD PTR [rdi+rdx*1-0x20],xmm5
   a3a11:	0f 11 74 17 d0       	movups XMMWORD PTR [rdi+rdx*1-0x30],xmm6
   a3a16:	0f 11 7c 17 c0       	movups XMMWORD PTR [rdi+rdx*1-0x40],xmm7
   a3a1b:	c3                   	ret    
   a3a1c:	0f 10 06             	movups xmm0,XMMWORD PTR [rsi]
   a3a1f:	0f 10 4e 10          	movups xmm1,XMMWORD PTR [rsi+0x10]
   a3a23:	0f 10 54 16 f0       	movups xmm2,XMMWORD PTR [rsi+rdx*1-0x10]
   a3a28:	0f 10 5c 16 e0       	movups xmm3,XMMWORD PTR [rsi+rdx*1-0x20]
   a3a2d:	0f 11 07             	movups XMMWORD PTR [rdi],xmm0
   a3a30:	0f 11 4f 10          	movups XMMWORD PTR [rdi+0x10],xmm1
   a3a34:	0f 11 54 17 f0       	movups XMMWORD PTR [rdi+rdx*1-0x10],xmm2
   a3a39:	0f 11 5c 17 e0       	movups XMMWORD PTR [rdi+rdx*1-0x20],xmm3
   a3a3e:	c3                   	ret    
   a3a3f:	48 39 f7             	cmp    rdi,rsi
   a3a42:	0f 87 8c 00 00 00    	ja     a3ad4 <memcpy@GLIBC_2.2.5+0x264>
   a3a48:	0f 84 28 ff ff ff    	je     a3976 <memcpy@GLIBC_2.2.5+0x106>
   a3a4e:	0f 10 26             	movups xmm4,XMMWORD PTR [rsi]
   a3a51:	0f 10 6c 16 f0       	movups xmm5,XMMWORD PTR [rsi+rdx*1-0x10]
   a3a56:	0f 10 74 16 e0       	movups xmm6,XMMWORD PTR [rsi+rdx*1-0x20]
   a3a5b:	0f 10 7c 16 d0       	movups xmm7,XMMWORD PTR [rsi+rdx*1-0x30]
   a3a60:	44 0f 10 44 16 c0    	movups xmm8,XMMWORD PTR [rsi+rdx*1-0x40]
   a3a66:	49 89 fb             	mov    r11,rdi
   a3a69:	48 8d 4c 17 f0       	lea    rcx,[rdi+rdx*1-0x10]
   a3a6e:	49 89 f8             	mov    r8,rdi
   a3a71:	49 83 e0 0f          	and    r8,0xf
   a3a75:	49 83 e8 10          	sub    r8,0x10
   a3a79:	4c 29 c6             	sub    rsi,r8
   a3a7c:	4c 29 c7             	sub    rdi,r8
   a3a7f:	4c 01 c2             	add    rdx,r8
   a3a82:	48 3b 15 f7 d8 12 00 	cmp    rdx,QWORD PTR [rip+0x12d8f7]        # 1d1380 <_obstack@GLIBC_2.2.5+0x118>
   a3a89:	0f 87 cc 00 00 00    	ja     a3b5b <memcpy@GLIBC_2.2.5+0x2eb>
   a3a8f:	0f 10 06             	movups xmm0,XMMWORD PTR [rsi]
   a3a92:	0f 10 4e 10          	movups xmm1,XMMWORD PTR [rsi+0x10]
   a3a96:	0f 10 56 20          	movups xmm2,XMMWORD PTR [rsi+0x20]
   a3a9a:	0f 10 5e 30          	movups xmm3,XMMWORD PTR [rsi+0x30]
   a3a9e:	48 83 c6 40          	add    rsi,0x40
   a3aa2:	48 83 ea 40          	sub    rdx,0x40
   a3aa6:	0f 29 07             	movaps XMMWORD PTR [rdi],xmm0
   a3aa9:	0f 29 4f 10          	movaps XMMWORD PTR [rdi+0x10],xmm1
   a3aad:	0f 29 57 20          	movaps XMMWORD PTR [rdi+0x20],xmm2
   a3ab1:	0f 29 5f 30          	movaps XMMWORD PTR [rdi+0x30],xmm3
   a3ab5:	48 83 c7 40          	add    rdi,0x40
   a3ab9:	48 83 fa 40          	cmp    rdx,0x40
   a3abd:	77 d0                	ja     a3a8f <memcpy@GLIBC_2.2.5+0x21f>
   a3abf:	0f 11 29             	movups XMMWORD PTR [rcx],xmm5
   a3ac2:	0f 11 71 f0          	movups XMMWORD PTR [rcx-0x10],xmm6
   a3ac6:	0f 11 79 e0          	movups XMMWORD PTR [rcx-0x20],xmm7
   a3aca:	44 0f 11 41 d0       	movups XMMWORD PTR [rcx-0x30],xmm8
   a3acf:	41 0f 11 23          	movups XMMWORD PTR [r11],xmm4
   a3ad3:	c3                   	ret    
   a3ad4:	0f 10 26             	movups xmm4,XMMWORD PTR [rsi]
   a3ad7:	0f 10 6e 10          	movups xmm5,XMMWORD PTR [rsi+0x10]
   a3adb:	0f 10 76 20          	movups xmm6,XMMWORD PTR [rsi+0x20]
   a3adf:	0f 10 7e 30          	movups xmm7,XMMWORD PTR [rsi+0x30]
   a3ae3:	44 0f 10 44 16 f0    	movups xmm8,XMMWORD PTR [rsi+rdx*1-0x10]
   a3ae9:	4c 8d 5c 17 f0       	lea    r11,[rdi+rdx*1-0x10]
   a3aee:	48 8d 4c 16 f0       	lea    rcx,[rsi+rdx*1-0x10]
   a3af3:	4d 89 d9             	mov    r9,r11
   a3af6:	4d 89 d8             	mov    r8,r11
   a3af9:	49 83 e0 0f          	and    r8,0xf
   a3afd:	4c 29 c1             	sub    rcx,r8
   a3b00:	4d 29 c1             	sub    r9,r8
   a3b03:	4c 29 c2             	sub    rdx,r8
   a3b06:	48 3b 15 73 d8 12 00 	cmp    rdx,QWORD PTR [rip+0x12d873]        # 1d1380 <_obstack@GLIBC_2.2.5+0x118>
   a3b0d:	0f 87 af 00 00 00    	ja     a3bc2 <memcpy@GLIBC_2.2.5+0x352>
   a3b13:	0f 10 01             	movups xmm0,XMMWORD PTR [rcx]
   a3b16:	0f 10 49 f0          	movups xmm1,XMMWORD PTR [rcx-0x10]
   a3b1a:	0f 10 51 e0          	movups xmm2,XMMWORD PTR [rcx-0x20]
   a3b1e:	0f 10 59 d0          	movups xmm3,XMMWORD PTR [rcx-0x30]
   a3b22:	48 83 e9 40          	sub    rcx,0x40
   a3b26:	48 83 ea 40          	sub    rdx,0x40
   a3b2a:	41 0f 29 01          	movaps XMMWORD PTR [r9],xmm0
   a3b2e:	41 0f 29 49 f0       	movaps XMMWORD PTR [r9-0x10],xmm1
   a3b33:	41 0f 29 51 e0       	movaps XMMWORD PTR [r9-0x20],xmm2
   a3b38:	41 0f 29 59 d0       	movaps XMMWORD PTR [r9-0x30],xmm3
   a3b3d:	49 83 e9 40          	sub    r9,0x40
   a3b41:	48 83 fa 40          	cmp    rdx,0x40
   a3b45:	77 cc                	ja     a3b13 <memcpy@GLIBC_2.2.5+0x2a3>
   a3b47:	0f 11 27             	movups XMMWORD PTR [rdi],xmm4
   a3b4a:	0f 11 6f 10          	movups XMMWORD PTR [rdi+0x10],xmm5
   a3b4e:	0f 11 77 20          	movups XMMWORD PTR [rdi+0x20],xmm6
   a3b52:	0f 11 7f 30          	movups XMMWORD PTR [rdi+0x30],xmm7
   a3b56:	45 0f 11 03          	movups XMMWORD PTR [r11],xmm8
   a3b5a:	c3                   	ret    
   a3b5b:	4c 8d 14 17          	lea    r10,[rdi+rdx*1]
   a3b5f:	4c 39 d6             	cmp    rsi,r10
   a3b62:	0f 82 27 ff ff ff    	jb     a3a8f <memcpy@GLIBC_2.2.5+0x21f>
   a3b68:	0f 18 8e 80 00 00 00 	prefetcht0 BYTE PTR [rsi+0x80]
   a3b6f:	0f 18 8e c0 00 00 00 	prefetcht0 BYTE PTR [rsi+0xc0]
   a3b76:	0f 10 06             	movups xmm0,XMMWORD PTR [rsi]
   a3b79:	0f 10 4e 10          	movups xmm1,XMMWORD PTR [rsi+0x10]
   a3b7d:	0f 10 56 20          	movups xmm2,XMMWORD PTR [rsi+0x20]
   a3b81:	0f 10 5e 30          	movups xmm3,XMMWORD PTR [rsi+0x30]
   a3b85:	48 83 c6 40          	add    rsi,0x40
   a3b89:	48 83 ea 40          	sub    rdx,0x40
   a3b8d:	66 0f e7 07          	movntdq XMMWORD PTR [rdi],xmm0
   a3b91:	66 0f e7 4f 10       	movntdq XMMWORD PTR [rdi+0x10],xmm1
   a3b96:	66 0f e7 57 20       	movntdq XMMWORD PTR [rdi+0x20],xmm2
   a3b9b:	66 0f e7 5f 30       	movntdq XMMWORD PTR [rdi+0x30],xmm3
   a3ba0:	48 83 c7 40          	add    rdi,0x40
   a3ba4:	48 83 fa 40          	cmp    rdx,0x40
   a3ba8:	77 be                	ja     a3b68 <memcpy@GLIBC_2.2.5+0x2f8>
   a3baa:	0f ae f8             	sfence 
   a3bad:	0f 11 29             	movups XMMWORD PTR [rcx],xmm5
   a3bb0:	0f 11 71 f0          	movups XMMWORD PTR [rcx-0x10],xmm6
   a3bb4:	0f 11 79 e0          	movups XMMWORD PTR [rcx-0x20],xmm7
   a3bb8:	44 0f 11 41 d0       	movups XMMWORD PTR [rcx-0x30],xmm8
   a3bbd:	41 0f 11 23          	movups XMMWORD PTR [r11],xmm4
   a3bc1:	c3                   	ret    
   a3bc2:	4c 8d 14 11          	lea    r10,[rcx+rdx*1]
   a3bc6:	4d 39 d1             	cmp    r9,r10
   a3bc9:	0f 82 44 ff ff ff    	jb     a3b13 <memcpy@GLIBC_2.2.5+0x2a3>
   a3bcf:	0f 18 49 80          	prefetcht0 BYTE PTR [rcx-0x80]
   a3bd3:	0f 18 89 40 ff ff ff 	prefetcht0 BYTE PTR [rcx-0xc0]
   a3bda:	0f 10 01             	movups xmm0,XMMWORD PTR [rcx]
   a3bdd:	0f 10 49 f0          	movups xmm1,XMMWORD PTR [rcx-0x10]
   a3be1:	0f 10 51 e0          	movups xmm2,XMMWORD PTR [rcx-0x20]
   a3be5:	0f 10 59 d0          	movups xmm3,XMMWORD PTR [rcx-0x30]
   a3be9:	48 83 e9 40          	sub    rcx,0x40
   a3bed:	48 83 ea 40          	sub    rdx,0x40
   a3bf1:	66 41 0f e7 01       	movntdq XMMWORD PTR [r9],xmm0
   a3bf6:	66 41 0f e7 49 f0    	movntdq XMMWORD PTR [r9-0x10],xmm1
   a3bfc:	66 41 0f e7 51 e0    	movntdq XMMWORD PTR [r9-0x20],xmm2
   a3c02:	66 41 0f e7 59 d0    	movntdq XMMWORD PTR [r9-0x30],xmm3
   a3c08:	49 83 e9 40          	sub    r9,0x40
   a3c0c:	48 83 fa 40          	cmp    rdx,0x40
   a3c10:	77 bd                	ja     a3bcf <memcpy@GLIBC_2.2.5+0x35f>
   a3c12:	0f ae f8             	sfence 
   a3c15:	0f 11 27             	movups XMMWORD PTR [rdi],xmm4
   a3c18:	0f 11 6f 10          	movups XMMWORD PTR [rdi+0x10],xmm5
   a3c1c:	0f 11 77 20          	movups XMMWORD PTR [rdi+0x20],xmm6
   a3c20:	0f 11 7f 30          	movups XMMWORD PTR [rdi+0x30],xmm7
   a3c24:	45 0f 11 03          	movups XMMWORD PTR [r11],xmm8
   a3c28:	c3                   	ret    
   a3c29:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

00000000000a3c30 <__bzero@@GLIBC_2.2.5>:
   a3c30:	48 89 f8             	mov    rax,rdi
   a3c33:	48 89 f2             	mov    rdx,rsi
   a3c36:	66 0f ef c0          	pxor   xmm0,xmm0
   a3c3a:	eb 58                	jmp    a3c94 <__bzero@@GLIBC_2.2.5+0x64>
   a3c3c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
   a3c40:	48 39 d1             	cmp    rcx,rdx
   a3c43:	0f 82 87 63 06 00    	jb     109fd0 <__chk_fail@@GLIBC_2.3.4>
   a3c49:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
   a3c50:	48 c1 e2 02          	shl    rdx,0x2
   a3c54:	66 0f 6e c6          	movd   xmm0,esi
   a3c58:	48 89 f8             	mov    rax,rdi
   a3c5b:	66 0f 70 c0 00       	pshufd xmm0,xmm0,0x0
   a3c60:	eb 32                	jmp    a3c94 <__bzero@@GLIBC_2.2.5+0x64>
   a3c62:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
   a3c69:	00 00 00 00 
   a3c6d:	0f 1f 00             	nop    DWORD PTR [rax]
   a3c70:	48 39 d1             	cmp    rcx,rdx
   a3c73:	0f 82 57 63 06 00    	jb     109fd0 <__chk_fail@@GLIBC_2.3.4>
   a3c79:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
   a3c80:	66 0f 6e c6          	movd   xmm0,esi
   a3c84:	48 89 f8             	mov    rax,rdi
   a3c87:	66 0f 60 c0          	punpcklbw xmm0,xmm0
   a3c8b:	66 0f 61 c0          	punpcklwd xmm0,xmm0
   a3c8f:	66 0f 70 c0 00       	pshufd xmm0,xmm0,0x0
   a3c94:	48 83 fa 10          	cmp    rdx,0x10
   a3c98:	0f 82 13 01 00 00    	jb     a3db1 <__bzero@@GLIBC_2.2.5+0x181>
   a3c9e:	48 83 fa 20          	cmp    rdx,0x20
   a3ca2:	0f 87 90 00 00 00    	ja     a3d38 <__bzero@@GLIBC_2.2.5+0x108>
   a3ca8:	f3 0f 7f 44 17 f0    	movdqu XMMWORD PTR [rdi+rdx*1-0x10],xmm0
   a3cae:	f3 0f 7f 07          	movdqu XMMWORD PTR [rdi],xmm0
   a3cb2:	c3                   	ret    
   a3cb3:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
   a3cba:	00 00 00 00 
   a3cbe:	66 90                	xchg   ax,ax
   a3cc0:	48 39 d1             	cmp    rcx,rdx
   a3cc3:	0f 82 07 63 06 00    	jb     109fd0 <__chk_fail@@GLIBC_2.3.4>
   a3cc9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
   a3cd0:	48 85 d2             	test   rdx,rdx
   a3cd3:	75 04                	jne    a3cd9 <__bzero@@GLIBC_2.2.5+0xa9>
   a3cd5:	48 89 f8             	mov    rax,rdi
   a3cd8:	c3                   	ret    
   a3cd9:	48 89 d1             	mov    rcx,rdx
   a3cdc:	40 0f b6 c6          	movzx  eax,sil
   a3ce0:	48 89 fa             	mov    rdx,rdi
   a3ce3:	f3 aa                	rep stos BYTE PTR es:[rdi],al
   a3ce5:	48 89 d0             	mov    rax,rdx
   a3ce8:	c3                   	ret    
   a3ce9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
   a3cf0:	48 39 d1             	cmp    rcx,rdx
   a3cf3:	0f 82 d7 62 06 00    	jb     109fd0 <__chk_fail@@GLIBC_2.3.4>
   a3cf9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
   a3d00:	66 0f 6e c6          	movd   xmm0,esi
   a3d04:	48 89 f8             	mov    rax,rdi
   a3d07:	66 0f 60 c0          	punpcklbw xmm0,xmm0
   a3d0b:	66 0f 61 c0          	punpcklwd xmm0,xmm0
   a3d0f:	66 0f 70 c0 00       	pshufd xmm0,xmm0,0x0
   a3d14:	48 83 fa 10          	cmp    rdx,0x10
   a3d18:	0f 82 93 00 00 00    	jb     a3db1 <__bzero@@GLIBC_2.2.5+0x181>
   a3d1e:	48 83 fa 20          	cmp    rdx,0x20
   a3d22:	77 0b                	ja     a3d2f <__bzero@@GLIBC_2.2.5+0xff>
   a3d24:	f3 0f 7f 44 17 f0    	movdqu XMMWORD PTR [rdi+rdx*1-0x10],xmm0
   a3d2a:	f3 0f 7f 07          	movdqu XMMWORD PTR [rdi],xmm0
   a3d2e:	c3                   	ret    
   a3d2f:	48 81 fa 00 08 00 00 	cmp    rdx,0x800
   a3d36:	77 a1                	ja     a3cd9 <__bzero@@GLIBC_2.2.5+0xa9>
   a3d38:	48 83 fa 40          	cmp    rdx,0x40
   a3d3c:	77 16                	ja     a3d54 <__bzero@@GLIBC_2.2.5+0x124>
   a3d3e:	f3 0f 7f 07          	movdqu XMMWORD PTR [rdi],xmm0
   a3d42:	f3 0f 7f 47 10       	movdqu XMMWORD PTR [rdi+0x10],xmm0
   a3d47:	f3 0f 7f 44 17 f0    	movdqu XMMWORD PTR [rdi+rdx*1-0x10],xmm0
   a3d4d:	f3 0f 7f 44 17 e0    	movdqu XMMWORD PTR [rdi+rdx*1-0x20],xmm0
   a3d53:	c3                   	ret    
   a3d54:	48 8d 4f 40          	lea    rcx,[rdi+0x40]
   a3d58:	f3 0f 7f 07          	movdqu XMMWORD PTR [rdi],xmm0
   a3d5c:	48 83 e1 c0          	and    rcx,0xffffffffffffffc0
   a3d60:	f3 0f 7f 44 17 f0    	movdqu XMMWORD PTR [rdi+rdx*1-0x10],xmm0
   a3d66:	f3 0f 7f 47 10       	movdqu XMMWORD PTR [rdi+0x10],xmm0
   a3d6b:	f3 0f 7f 44 17 e0    	movdqu XMMWORD PTR [rdi+rdx*1-0x20],xmm0
   a3d71:	f3 0f 7f 47 20       	movdqu XMMWORD PTR [rdi+0x20],xmm0
   a3d76:	f3 0f 7f 44 17 d0    	movdqu XMMWORD PTR [rdi+rdx*1-0x30],xmm0
   a3d7c:	f3 0f 7f 47 30       	movdqu XMMWORD PTR [rdi+0x30],xmm0
   a3d81:	f3 0f 7f 44 17 c0    	movdqu XMMWORD PTR [rdi+rdx*1-0x40],xmm0
   a3d87:	48 01 fa             	add    rdx,rdi
   a3d8a:	48 83 e2 c0          	and    rdx,0xffffffffffffffc0
   a3d8e:	48 39 d1             	cmp    rcx,rdx
   a3d91:	74 c0                	je     a3d53 <__bzero@@GLIBC_2.2.5+0x123>
   a3d93:	66 0f 7f 01          	movdqa XMMWORD PTR [rcx],xmm0
   a3d97:	66 0f 7f 41 10       	movdqa XMMWORD PTR [rcx+0x10],xmm0
   a3d9c:	66 0f 7f 41 20       	movdqa XMMWORD PTR [rcx+0x20],xmm0
   a3da1:	66 0f 7f 41 30       	movdqa XMMWORD PTR [rcx+0x30],xmm0
   a3da6:	48 83 c1 40          	add    rcx,0x40
   a3daa:	48 39 ca             	cmp    rdx,rcx
   a3dad:	75 e4                	jne    a3d93 <__bzero@@GLIBC_2.2.5+0x163>
   a3daf:	f3 c3                	repz ret 
   a3db1:	66 48 0f 7e c1       	movq   rcx,xmm0
   a3db6:	80 fa 08             	cmp    dl,0x8
   a3db9:	73 0f                	jae    a3dca <__bzero@@GLIBC_2.2.5+0x19a>
   a3dbb:	80 fa 04             	cmp    dl,0x4
   a3dbe:	73 13                	jae    a3dd3 <__bzero@@GLIBC_2.2.5+0x1a3>
   a3dc0:	80 fa 01             	cmp    dl,0x1
   a3dc3:	77 15                	ja     a3dda <__bzero@@GLIBC_2.2.5+0x1aa>
   a3dc5:	72 02                	jb     a3dc9 <__bzero@@GLIBC_2.2.5+0x199>
   a3dc7:	88 0f                	mov    BYTE PTR [rdi],cl
   a3dc9:	c3                   	ret    
   a3dca:	48 89 4c 17 f8       	mov    QWORD PTR [rdi+rdx*1-0x8],rcx
   a3dcf:	48 89 0f             	mov    QWORD PTR [rdi],rcx
   a3dd2:	c3                   	ret    
   a3dd3:	89 4c 17 fc          	mov    DWORD PTR [rdi+rdx*1-0x4],ecx
   a3dd7:	89 0f                	mov    DWORD PTR [rdi],ecx
   a3dd9:	c3                   	ret    
   a3dda:	66 89 4c 17 fe       	mov    WORD PTR [rdi+rdx*1-0x2],cx
   a3ddf:	66 89 0f             	mov    WORD PTR [rdi],cx
   a3de2:	c3                   	ret    
