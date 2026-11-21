0000000000003cea <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_>:
    3cea:	55                   	push   rbp
    3ceb:	48 89 e5             	mov    rbp,rsp
    3cee:	48 81 ec d0 09 00 00 	sub    rsp,0x9d0
    3cf5:	4c 89 65 f0          	mov    QWORD PTR [rbp-0x10],r12
    3cf9:	48 89 5d f8          	mov    QWORD PTR [rbp-0x8],rbx
    3cfd:	4c 89 6d e8          	mov    QWORD PTR [rbp-0x18],r13
    3d01:	4c 89 75 e0          	mov    QWORD PTR [rbp-0x20],r14
    3d05:	4c 89 7d d8          	mov    QWORD PTR [rbp-0x28],r15
    3d09:	48 89 f8             	mov    rax,rdi
    3d0c:	49 89 c4             	mov    r12,rax
    3d0f:	48 89 f0             	mov    rax,rsi
    3d12:	48 89 45 d0          	mov    QWORD PTR [rbp-0x30],rax
    3d16:	48 89 d0             	mov    rax,rdx
    3d19:	48 89 c7             	mov    rdi,rax
    3d1c:	48 89 c8             	mov    rax,rcx
    3d1f:	49 89 c5             	mov    r13,rax
    3d22:	4c 89 c0             	mov    rax,r8
    3d25:	48 89 c3             	mov    rbx,rax
    3d28:	4c 89 c8             	mov    rax,r9
    3d2b:	48 89 c6             	mov    rsi,rax
    3d2e:	4d 8b 3c 24          	mov    r15,QWORD PTR [r12]
    3d32:	48 89 da             	mov    rdx,rbx
    3d35:	49 89 d0             	mov    r8,rdx
    3d38:	49 c1 e8 38          	shr    r8,0x38
    3d3c:	4d 89 c1             	mov    r9,r8
    3d3f:	49 81 f9 04 00 00 00 	cmp    r9,0x4
    3d46:	41 0f 94 c1          	sete   r9b
    3d4a:	45 0f b6 c9          	movzx  r9d,r9b
    3d4e:	49 bb ff ff ff ff ff 	movabs r11,0xffffffffff
    3d55:	00 00 00 
    3d58:	49 89 d0             	mov    r8,rdx
    3d5b:	4d 21 d8             	and    r8,r11
    3d5e:	4d 89 c6             	mov    r14,r8
    3d61:	49 81 fe 80 82 10 03 	cmp    r14,0x3108280
    3d68:	41 0f 93 c6          	setae  r14b
    3d6c:	45 0f b6 f6          	movzx  r14d,r14b
    3d70:	45 21 ce             	and    r14d,r9d
    3d73:	48 c1 ea 28          	shr    rdx,0x28
    3d77:	48 81 e2 1f 00 00 00 	and    rdx,0x1f
    3d7e:	49 89 d3             	mov    r11,rdx
    3d81:	48 ba 01 00 00 00 00 	movabs rdx,0x1
    3d88:	00 00 00 
    3d8b:	44 89 d9             	mov    ecx,r11d
    3d8e:	48 d3 e2             	shl    rdx,cl
    3d91:	4c 8d 4a ff          	lea    r9,[rdx-0x1]
    3d95:	4c 89 c2             	mov    rdx,r8
    3d98:	48 c1 e2 03          	shl    rdx,0x3
    3d9c:	4d 89 f8             	mov    r8,r15
    3d9f:	49 01 d0             	add    r8,rdx
    3da2:	ba 01 00 00 00       	mov    edx,0x1
    3da7:	44 21 f2             	and    edx,r14d
    3daa:	49 89 d2             	mov    r10,rdx
    3dad:	45 85 d2             	test   r10d,r10d
    3db0:	0f 84 05 00 00 00    	je     3dbb <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0xd1>
    3db6:	e9 76 00 00 00       	jmp    3e31 <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0x147>
    3dbb:	4d 89 e2             	mov    r10,r12
    3dbe:	4c 89 54 24 30       	mov    QWORD PTR [rsp+0x30],r10
    3dc3:	4c 8b 55 d0          	mov    r10,QWORD PTR [rbp-0x30]
    3dc7:	4c 89 54 24 38       	mov    QWORD PTR [rsp+0x38],r10
    3dcc:	49 89 fa             	mov    r10,rdi
    3dcf:	4c 89 54 24 40       	mov    QWORD PTR [rsp+0x40],r10
    3dd4:	4d 89 ea             	mov    r10,r13
    3dd7:	4c 89 54 24 48       	mov    QWORD PTR [rsp+0x48],r10
    3ddc:	49 89 da             	mov    r10,rbx
    3ddf:	4c 89 54 24 50       	mov    QWORD PTR [rsp+0x50],r10
    3de4:	49 89 f2             	mov    r10,rsi
    3de7:	4c 89 54 24 58       	mov    QWORD PTR [rsp+0x58],r10
    3dec:	48 8b 7c 24 30       	mov    rdi,QWORD PTR [rsp+0x30]
    3df1:	48 8b 74 24 38       	mov    rsi,QWORD PTR [rsp+0x38]
    3df6:	48 8b 54 24 40       	mov    rdx,QWORD PTR [rsp+0x40]
    3dfb:	48 8b 4c 24 48       	mov    rcx,QWORD PTR [rsp+0x48]
    3e00:	4c 8b 44 24 50       	mov    r8,QWORD PTR [rsp+0x50]
    3e05:	4c 8b 4c 24 58       	mov    r9,QWORD PTR [rsp+0x58]
    3e0a:	31 c0                	xor    eax,eax
    3e0c:	e8 00 00 00 00       	call   3e11 <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0x127>
			3e0d: R_X86_64_PLT32	p117v_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_-0x4
    3e11:	48 89 85 d0 f6 ff ff 	mov    QWORD PTR [rbp-0x930],rax
    3e18:	4c 8b 65 f0          	mov    r12,QWORD PTR [rbp-0x10]
    3e1c:	48 8b 5d f8          	mov    rbx,QWORD PTR [rbp-0x8]
    3e20:	4c 8b 6d e8          	mov    r13,QWORD PTR [rbp-0x18]
    3e24:	4c 8b 75 e0          	mov    r14,QWORD PTR [rbp-0x20]
    3e28:	4c 8b 7d d8          	mov    r15,QWORD PTR [rbp-0x28]
    3e2c:	48 89 ec             	mov    rsp,rbp
    3e2f:	5d                   	pop    rbp
    3e30:	c3                   	ret    
    3e31:	48 81 ff 00 00 00 00 	cmp    rdi,0x0
    3e38:	0f 85 30 00 00 00    	jne    3e6e <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0x184>
    3e3e:	49 89 da             	mov    r10,rbx
    3e41:	4c 8b 5d d0          	mov    r11,QWORD PTR [rbp-0x30]
    3e45:	4d 89 13             	mov    QWORD PTR [r11],r10
    3e48:	49 89 f2             	mov    r10,rsi
    3e4b:	4c 8b 5d d0          	mov    r11,QWORD PTR [rbp-0x30]
    3e4f:	4d 89 53 08          	mov    QWORD PTR [r11+0x8],r10
    3e53:	31 c0                	xor    eax,eax
    3e55:	4c 8b 65 f0          	mov    r12,QWORD PTR [rbp-0x10]
    3e59:	48 8b 5d f8          	mov    rbx,QWORD PTR [rbp-0x8]
    3e5d:	4c 8b 6d e8          	mov    r13,QWORD PTR [rbp-0x18]
    3e61:	4c 8b 75 e0          	mov    r14,QWORD PTR [rbp-0x20]
    3e65:	4c 8b 7d d8          	mov    r15,QWORD PTR [rbp-0x28]
    3e69:	48 89 ec             	mov    rsp,rbp
    3e6c:	5d                   	pop    rbp
    3e6d:	c3                   	ret    
    3e6e:	4d 89 c2             	mov    r10,r8
    3e71:	4c 89 54 24 28       	mov    QWORD PTR [rsp+0x28],r10
    3e76:	4d 89 ca             	mov    r10,r9
    3e79:	4c 89 54 24 30       	mov    QWORD PTR [rsp+0x30],r10
    3e7e:	49 89 fa             	mov    r10,rdi
    3e81:	4c 89 54 24 38       	mov    QWORD PTR [rsp+0x38],r10
    3e86:	4d 89 ea             	mov    r10,r13
    3e89:	4c 89 54 24 40       	mov    QWORD PTR [rsp+0x40],r10
    3e8e:	49 89 f2             	mov    r10,rsi
    3e91:	4c 89 54 24 48       	mov    QWORD PTR [rsp+0x48],r10
    3e96:	48 8b 7c 24 28       	mov    rdi,QWORD PTR [rsp+0x28]
    3e9b:	48 8b 74 24 30       	mov    rsi,QWORD PTR [rsp+0x30]
    3ea0:	48 8b 54 24 38       	mov    rdx,QWORD PTR [rsp+0x38]
    3ea5:	48 8b 4c 24 40       	mov    rcx,QWORD PTR [rsp+0x40]
    3eaa:	4c 8b 44 24 48       	mov    r8,QWORD PTR [rsp+0x48]
    3eaf:	31 c0                	xor    eax,eax
    3eb1:	e8 00 00 00 00       	call   3eb6 <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0x1cc>
			3eb2: R_X86_64_PLT32	p199_rt_u32_scan4-0x4
    3eb6:	48 89 c6             	mov    rsi,rax
    3eb9:	49 89 da             	mov    r10,rbx
    3ebc:	4c 8b 5d d0          	mov    r11,QWORD PTR [rbp-0x30]
    3ec0:	4d 89 13             	mov    QWORD PTR [r11],r10
    3ec3:	49 89 f2             	mov    r10,rsi
    3ec6:	4c 8b 5d d0          	mov    r11,QWORD PTR [rbp-0x30]
    3eca:	4d 89 53 08          	mov    QWORD PTR [r11+0x8],r10
    3ece:	31 c0                	xor    eax,eax
    3ed0:	4c 8b 65 f0          	mov    r12,QWORD PTR [rbp-0x10]
    3ed4:	48 8b 5d f8          	mov    rbx,QWORD PTR [rbp-0x8]
    3ed8:	4c 8b 6d e8          	mov    r13,QWORD PTR [rbp-0x18]
    3edc:	4c 8b 75 e0          	mov    r14,QWORD PTR [rbp-0x20]
    3ee0:	4c 8b 7d d8          	mov    r15,QWORD PTR [rbp-0x28]
    3ee4:	48 89 ec             	mov    rsp,rbp
    3ee7:	5d                   	pop    rbp
    3ee8:	c3                   	ret    

