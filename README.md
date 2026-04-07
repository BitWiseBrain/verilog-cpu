# Single-Cycle MIPS CPU — Verilog Implementation

A single-cycle MIPS processor implemented in Verilog, supporting a subset of the MIPS ISA: R-type arithmetic/logic instructions, `lw`, `sw`, and `beq`. The design follows the classic textbook separation of **control** and **datapath**, wired together in a top-level CPU module.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Module Breakdown](#module-breakdown)
- [Supported Instructions](#supported-instructions)
- [File Structure](#file-structure)
- [Running the Simulation](#running-the-simulation)
- [Testbench & Example Program](#testbench--example-program)
- [Waveform Viewer](#waveform-viewer)
- [Known Limitations](#known-limitations)

---

## Architecture Overview

```
                   ┌─────────────────────────────────────┐
                   │              ct (CPU top)            │
                   │                                      │
                   │  ┌──────────┐      ┌─────────────┐  │
     clk, rst ────►│  │ control  │◄────►│     dp      │  │
                   │  │  (ctrl)  │      │ (datapath)  │  │
                   │  └──────────┘      └─────────────┘  │
                   │                         │            │
                   │               ┌─────────┴──────────┐ │
                   │               │  imem  rf  dmem    │ │
                   │               │  ac    the_alu     │ │
                   │               └────────────────────┘ │
                   └─────────────────────────────────────┘
```

The CPU is **single-cycle**: every instruction completes in one clock cycle. The datapath (`dp`) contains all state-bearing elements (PC, register file, data memory) and the control unit (`control`) drives all mux selects and enable signals based solely on the 6-bit opcode.

---

## Module Breakdown

### `ct.v` — Top-level CPU
Instantiates `control` and `dp`, wiring the control signals between them. The only external inputs are `clk` and `rst`.

### `control.v` — Main Control Unit
Decodes the 6-bit opcode and asserts control signals:

| Signal      | Width | Purpose                                      |
|-------------|-------|----------------------------------------------|
| `reg_dst`   | 1     | Selects write register: `rd` (1) or `rt` (0) |
| `alu_src`   | 1     | ALU B input: sign-extended imm (1) or `$rs2` (0) |
| `mem_to_reg`| 1     | Register write-back: memory (1) or ALU (0)   |
| `reg_write` | 1     | Enable register file write                   |
| `mem_read`  | 1     | Enable data memory read                      |
| `mem_write` | 1     | Enable data memory write                     |
| `branch`    | 1     | Enable branch (ANDed with ALU zero flag)     |
| `alu_op`    | 2     | Passed to ALU control for operation decode   |

### `control_alu.v` — ALU Control
Takes `alu_op[1:0]` from the main control and the instruction's `funct[5:0]` field (for R-types), and outputs the 3-bit `alu_control` signal to the ALU.

| `alu_op` | Meaning          | `alu_control` source |
|----------|------------------|----------------------|
| `00`     | lw / sw (add)    | Hardcoded `010`      |
| `01`     | beq (subtract)   | Hardcoded `110`      |
| `10`     | R-type           | Decoded from `funct` |

### `dp.v` — Datapath
Contains and connects:
- **PC register** with synchronous reset and next-PC logic (PC+4 or branch target)
- **Sign extension** of the 16-bit immediate
- **Branch target** calculation: `PC+4 + (sign_ext << 2)`
- Instantiates `imem`, `rf`, `ac` (ALU control), `the_alu`, and `dmem`

### `alu.v` — ALU
32-bit arithmetic/logic unit. Operations selected by `alu_control[2:0]`:

| `alu_control` | Operation |
|---------------|-----------|
| `010`         | ADD       |
| `110`         | SUB       |
| `000`         | AND       |
| `001`         | OR        |
| `111`         | SLT       |

Outputs a `zero` flag (used for branch decisions).

### `regfile.v` — Register File
32 × 32-bit registers. Key properties:
- **Asynchronous reads** — `read_data1`/`read_data2` update combinatorially
- **Synchronous writes** — on rising clock edge when `we` is asserted
- **$zero hardwired** — register 0 always reads as 0, writes to it are ignored

### `memory.v` — Data Memory
64 × 32-bit word-addressed memory.
- **Asynchronous read** (when `mem_read` asserted)
- **Synchronous write** on rising clock edge (when `mem_write` asserted)

### `imem.v` — Instruction Memory
64 × 32-bit read-only memory loaded from `imem.hex` at simulation start via `$readmemh`. Uses the upper 6 bits of PC (`pc[7:2]`) as a word address.

---

## Supported Instructions

| Instruction | Opcode   | Operation                        |
|-------------|----------|----------------------------------|
| R-type      | `000000` | ADD, SUB, AND, OR, SLT (via funct) |
| `lw`        | `100011` | Load word from memory            |
| `sw`        | `101011` | Store word to memory             |
| `beq`       | `000100` | Branch if equal                  |

> **Not supported:** `addi` and other I-type arithmetic, `j`/`jal`, multiply/divide, and most other MIPS instructions.

---

## File Structure

```
.
├── ct.v            # Top-level CPU (control + datapath wired together)
├── control.v       # Main control unit
├── control_alu.v   # ALU control decoder
├── dp.v            # Datapath
├── alu.v           # 32-bit ALU
├── regfile.v       # 32×32 register file
├── memory.v        # Data memory (64×32)
├── imem.v          # Instruction memory (loaded from hex)
├── imem.hex        # Machine code program
├── testbench.v     # Simulation testbench
├── cpu_waves.vcd   # GTKWave output (generated on simulation run)
└── cpu_sim         # Compiled simulation binary (generated by iverilog)
```

---

## Running the Simulation

### Prerequisites

- [Icarus Verilog](http://iverilog.icarus.com/) (`iverilog`)
- [GTKWave](http://gtkwave.sourceforge.net/) (for waveform viewing)

### Compile

```bash
iverilog -o cpu_sim testbench.v ct.v control.v control_alu.v dp.v alu.v regfile.v memory.v imem.v
```

### Run

```bash
vvp cpu_sim
```

Expected output:
```
Simulation finished.
$1 = 5
$2 = 10
$3 = 15
$4 = 15
```

The `imem.hex` file must be present in the **working directory** when you run the simulation (not necessarily where the source files are).

### View Waveforms

```bash
gtkwave cpu_waves.vcd
```

---

## Testbench & Example Program

The testbench (`testbench.v`) drives a 10ns clock (`#5` half-period), holds reset high for the first 10ns, then runs for 200ns before printing register values and finishing.

Because `addi` is not implemented, registers `$1` and `$2` are initialized directly via hierarchical access before reset is released:

```verilog
cpu.dp.rf.registers[1] = 32'd5;
cpu.dp.rf.registers[2] = 32'd10;
```

### `imem.hex` — Test Program

```
00221820  // add  $3, $1, $2      → $3 = 15
ac030004  // sw   $3, 4($0)       → mem[4] = 15
8c040004  // lw   $4, 4($0)       → $4 = 15
10640001  // beq  $3, $4, +1      → branch taken (skips next instruction)
00002820  // add  $5, $0, $0      → (SKIPPED)
00642822  // sub  $5, $3, $4      → $5 = 0  (branch lands here)
```

This program exercises ADD, SW, LW, and BEQ in sequence, and verifies that the branch correctly skips over an instruction.

---

## Waveform Viewer

The screenshot below shows the GTKWave output after simulation. Key signals to observe:

- `address[5:0]` — PC word address stepping through instructions
- `opcode[5:0]` — matches each instruction in the hex file
- `reg_write`, `mem_read`, `mem_write` — control signals asserting correctly per instruction
- `read_data1/2`, `write_data` — register file traffic
- `we` — register write enable in the register file hierarchy

<img width="1456" height="819" alt="image" src="https://github.com/user-attachments/assets/906d1fb3-fa8c-47d4-af75-dce5b29b0272" />


---

## Known Limitations

- **No `addi`** — immediate arithmetic not supported; initial register values must be set in the testbench directly.
- **No jump instructions** — `j` and `jal` are not implemented.
- **Fixed memory sizes** — instruction memory and data memory are each 64 words (256 bytes). Programs longer than 64 instructions will not work.
- **No hazard handling** — this is a single-cycle design; no pipelining, no forwarding, no stall logic.
- **No overflow detection** — ALU arithmetic silently wraps on overflow.
