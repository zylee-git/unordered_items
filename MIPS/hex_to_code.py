with open("1.txt", "r") as f:
    hex = f.readlines()
with open("code.txt", "w") as f:
    for i in range(len(hex)):
        if hex[i][0:3]=="081":
            f.write(f"8\'d{i}: Instruction = 32'h080{hex[i][3:-1]}; // j\n")
        else:
            f.write(f"8\'d{i}: Instruction = 32'h{hex[i][:-1]};\n")