# 8bits-ALU-design
# 8-Bit Modular ALU — Intel Quartus Prime (DE10-Lite / MAX 10)

An 8-bit Arithmetic Logic Unit implemented in Verilog HDL and deployed on the
Terasic DE10-Lite (Intel MAX 10 FPGA). Two 8-bit operands and a 4-bit opcode
are entered through onboard switches using a time-multiplexed input scheme,
and the result and status flags are displayed live on the board's LEDs.

## Overview

The ALU integrates four functional sub-units behind a 4-to-1 output mux:

- **Adder/Subtractor** — 8-bit two's-complement add/subtract with carry-out
  and overflow detection
- **Logic Unit** — bitwise AND, OR, XOR, NOT
- **Barrel-style Shifter** — 1-bit left/right shift with carry-out
- **Bypass** — passes operand A straight through

A 4-bit opcode selects both *which unit's result* is routed to the output
(top 2 bits) and *which operation within that unit* is performed (bottom
2 bits), so the same 4-bit code fully determines the ALU's behavior for a
given operation.

## Architecture

```
                ┌────────────────────┐
   SW[7:0] ───▶ │  Operand Register   │
   SW[9:8] ───▶ │  (A, B, opcode)     │◀─── KEY[0] (debounced load pulse)
                │  2-phase entry FSM  │◀─── KEY[1] (async reset)
                └─────────┬───────────┘
                          │ A, B, opcode[3:0]
        ┌─────────────────┼──────────────────┬───────────────┐
        ▼                 ▼                  ▼               ▼
 ┌─────────────┐   ┌─────────────┐   ┌───────────────┐   ┌─────────┐
 │Adder/Subtr. │   │ Logic Block │   │Shifter w/Carry│   │ Bypass  │
 │  (A ± B)    │   │ AND/OR/XOR/ │   │ shift L/R,    │   │  (A)    │
 │             │   │  NOT        │   │  Cin=0        │   │         │
 └──────┬──────┘   └──────┬──────┘   └───────┬───────┘   └────┬────┘
        │                 │                  │                │
        └─────────────────┴────────┬─────────┴────────────────┘
                                    ▼
                          ┌───────────────────┐
                          │   4-to-1 Mux       │
                          │  sel = opcode[3:2] │
                          └─────────┬──────────┘
                                    ▼
                    LEDR[7:0] = result
                    LEDR[8]   = Zero flag
                    LEDR[9]   = Carry-out (adder) / Shifter carry-out
```

## Opcode Encoding

The 4-bit opcode is entered as `{op_upper, op_lower}`, where `op_upper` is
`SW[9:8]` during the A-entry phase and `op_lower` is `SW[9:8]` during the
B-entry phase.

| opcode[3:2] (unit select) | Unit             | opcode[1:0] (operation)                  |
|----------------------------|------------------|-------------------------------------------|
| `00`                       | Adder/Subtractor | `0` = A + B&nbsp;&nbsp;&nbsp; `1` = A − B (two's complement) |
| `01`                       | Logic Block      | `00` = A & B&nbsp;&nbsp; `01` = A \| B&nbsp;&nbsp; `10` = A ^ B&nbsp;&nbsp; `11` = ~A |
| `10`                       | Shifter          | `0` = shift left (Cin → LSB)&nbsp;&nbsp; `1` = shift right (Cin → MSB) |
| `11`                       | Bypass           | — (outputs A unchanged)                    |

## Input Sequence (DE10-Lite)

Operands and opcode are loaded in two phases through a single debounced
push-button, since the board doesn't expose enough raw switches for A, B,
and a 4-bit opcode simultaneously:

1. Set `SW[7:0] = A` and `SW[9:8] = opcode[3:2]` (unit select), press **KEY0**.
2. Set `SW[7:0] = B` and `SW[9:8] = opcode[1:0]` (operation select), press **KEY0** again.
3. Result and flags appear immediately on `LEDR[9:0]`.
4. **KEY1** asynchronously resets A, B, opcode, and the phase register.

## Status Flags

- **Zero (`LEDR[8]`)** — set when the final result is `8'b00000000`
- **Carry/Overflow (`LEDR[9]`)** — carry-out from the adder for arithmetic
  operations, or the shifted-out bit for shift operations (selected based
  on `opcode[3:2]`)

## Repository Structure

| File                          | Description                                             |
|--------------------------------|-----------------------------------------------------------|
| `alu.v`                        | Top-level module — operand entry FSM, submodule instantiation, output mux, flags |
| `adder_subtractor.v`           | 8-bit two's-complement adder/subtractor with overflow detection |
| `logic_block.v`                | Combinational AND/OR/XOR/NOT unit                        |
| `shifter_with_carry.v`         | 1-bit left/right shifter with carry-out                  |
| `mux_4to1.v`                   | 4-to-1 output multiplexer                                 |
| `debounce_key0.v` / `debounce_key0_simple.bsf` | Push-button debounce logic for the KEY0 load pulse |
| `flag_register.v`              | Registered flag storage (available for a pipelined/registered-output variant) |
| `alu.qpf` / `alu.qsf`          | Quartus Prime project and settings files                 |

## Tools & Target

- **Language:** Verilog HDL
- **Toolchain:** Intel Quartus Prime
- **Target board:** Terasic DE10-Lite (Intel MAX 10, 10M50DAF484C7G)
- **Design entry:** Verilog + schematic symbol files (`.bsf`) for block-level integration

## Synthesis Results

<!-- Fill in from Quartus Compilation Report → Fitter Summary / TimeQuest Timing Analyzer -->
- Logic elements used: **TODO** (see Fitter Summary → Flow Summary)
- Registers used: **TODO**
- Fmax achieved: **TODO** (see TimeQuest Timing Analyzer → Slow 1200mV 0C Model)

## Possible Extensions

- Route flags through `flag_register.v` for a registered, glitch-free status output
- Add a testbench with self-checking assertions for each opcode
- Replace the 2-phase switch entry with a UART or PS/2 input for faster operand loading
