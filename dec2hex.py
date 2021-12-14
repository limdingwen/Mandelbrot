dec = []
for char in input("Dec? 0."):
    dec.append(int(char))

print("0x0.", end="")
max_hex_digits = 48
curr_binary = []
for _ in range(0, max_hex_digits * 4):
    carry = 0
    for i in range(len(dec) - 1, -1, -1):
        dec[i] *= 2
        dec[i] += carry
        carry = 0
        if dec[i] > 9:
            dec[i] -= 10
            carry = 1
    curr_binary.append(str(carry))
    if len(curr_binary) == 4:
        print(hex(int("".join(curr_binary), 2))[2:].upper(), end="")
        curr_binary = []
print("")