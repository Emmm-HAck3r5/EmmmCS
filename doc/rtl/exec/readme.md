# 临时 exec 模块

## RV32I Base IS, v2.0

- [ ] Integer Computational Instructions
    - [ ] Integer Register-Immediate Instructions

        |Name|Type||
        |:-|:-|:-|
        |⭕`ADDI`  |I     |`X[rd] <- X[rs1] +         imm(sign extended 12 bit)`|
        |⭕`SLTI` |I      |`X[rd] <- X[rs1] <(signed) imm(sign extended 12 bit) ? 1 : 0`|
        |⭕`SLTIU`|I      |`X[rd] <- X[rs1] <(unsigned) imm(sign extended 12 bit) ? 1 : 0`|
        |⭕`ANDI` |I      |`X[rd] <- X[rs1] bit-AND   imm(sign extended 12 bit)`|
        |⭕`ORI`  |I      |`X[rd] <- X[rs1] bit-OR    imm(sign extended 12 bit)`|
        |⭕`XORI` |I      |`X[rd] <- X[rs1] bit-XOR   imm(sign extended 12 bit)`|
        |⭕`SLLI` |I-spec |`X[rd] <- X[rs1] <<   imm[4:0]`|
        |⭕`SRLI` |I-spec |`X[rd] <- X[rs1] L->> imm[4:0]`|
        |⭕`SRAI` |I-spec |`X[rd] <- X[rs1] A->> imm[4:0]`|
        |⭕`LUI`  |U      |`X[rd] <- {imm[31:12]      << 12}`|
        |⭕`AUIPC`|U      |`pc    <- pc + {imm[31:12] << 12}; X[rd] <- pc`|

    - [ ] Integer Register-Register Operations
- [ ] Control Transfer Instructions
    - [ ] Unconditional Jumps
    - [ ] Conditional Branches
- [ ] Load and Store Instructions
- [ ] Control and Status Register Instructions
    - [ ] CSR Instructions
    - [ ] Timers and Counters
- [ ] Environment Call and Breakpoints

## "M" Ext for Int Mul & Div, v2.0

## "N" Ext for Intr, v1.1