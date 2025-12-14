# Simple 8-bit Microprocessor (VHDL)

Small educational CPU implemented in VHDL.  
Features a custom 8-bit instruction set, 4 general-purpose registers, and a multi-cycle FSM control unit.


---

## Architecture Overview

- **Word size:** 8 bits
- **Registers:** 4 general-purpose registers (R0–R3)
- **Memory:**
  - Unified program + data RAM
  - 8 locations × 8 bits (`MEM_DEPTH = 8`, `MEM_ADDR_W = 3`)
- **Instruction format (8 bits):**
  - `IR(7..5)` – opcode (3 bits)
  - `IR(4..3)` – register index (2 bits)
  - `IR(2..0)` – small address / extra field (3 bits)
- **Basic instructions:**
  - `LOAD Rr, [addr3]` – `OP_LOAD = "000"`
  - `STORE Rr, [addr3]` – `OP_STORE = "001"`
  - `ADD Rd, Rs`       – `OP_ADD  = "010"`
  - `HALT`             – `OP_HALT = "111"`

Execution model:

- **Von Neumann architecture** (single unified memory)
- **Multi-cycle FSM**: FETCH → DECODE → EXEC
- No pipeline, no cache, no interrupts

---

## Modules

### `cpu_types_pkg.vhd`
Global type and constant definitions:

- `DATA_WIDTH`, `REG_COUNT`, `REG_INDEX_W`, `MEM_ADDR_W`, `MEM_DEPTH`
- Opcode constants: `OP_LOAD`, `OP_STORE`, `OP_ADD`, `OP_HALT`
- `type alu_op_t is (ALU_ADD, ALU_PASS_A);`
- `type cpu_state_t` – FSM states (fetch, decode, exec, halt)

### `regfile.vhd`
4 × 8-bit general-purpose register file (R0–R3).

- Ports:
  - `clk`
  - `write_enable`
  - `write_address` (2 bits)
  - `write_data` (8 bits)
  - `readA_address`, `readB_address` (2 bits)
  - `readA_data`, `readB_data` (8 bits)
- Synchronous write, combinational read.

### `alu.vhd`
Simple combinational ALU.

- Ports:
  - `A`, `B` (8-bit inputs)
  - `ALU_op : alu_op_t`
  - `Result` (8-bit)
- Operations:
  - `ALU_ADD` → `Result = A + B`
  - `ALU_PASS_A` → `Result = A`

### `memory.vhd`
Unified program + data memory (8×8).

- Ports:
  - `clk`
  - `addr` (3 bits, from AR)
  - `data_in` (8 bits, from regB)
  - `write_en`, `read_en`
  - `data_out` (8 bits)
- Synchronous write, combinational read gated by `read_en`.

### `cpu_core.vhd`
Top-level CPU core.

- Ports:
  - `clk`, `rst`
- Main registers:
  - `PC` – Program Counter (3 bits)
  - `IR` – Instruction Register (8 bits)
  - `AR` – Address Register (3 bits, to memory)
  - `DR` – Data Register (8 bits, from memory)
- Connected units:
  - Register file (`regA`, `regB`, `regW_addr`, `reg_write_en`, `reg_source_select`)
  - ALU (`alu_result`, `alu_op`)
  - Memory (`memory_read_en`, `memory_write_en`, `memory_data_out`)
- Control:
  - Multi-cycle FSM with states for:
    - Fetch: `S_FETCH_0`, `S_FETCH_1`, `S_FETCH_2`
    - Decode: `S_DECODE`
    - Execute: `S_EXEC_LOAD_*`, `S_EXEC_STORE_*`, `S_EXEC_ADD_0`
    - `S_HALT`

---

## Instruction Behaviour (Summary)

- **LOAD Rr, [addr3]**
  - `Rr <- MEM[addr3]`
  - Uses AR → memory → DR → regfile write-back

- **STORE Rr, [addr3]**
  - `MEM[addr3] <- Rr`
  - Reads Rr via regfile, writes through memory

- **ADD Rd, Rs**
  - `Rd <- Rd + Rs`
  - Register-to-register add using ALU (no memory access)

- **HALT**
  - Enters `S_HALT`, disables writes and stops fetching new instructions.

---


## TODO

- Finish the FSM for the operations
- Implement the microprogrammed control unit
- Create a testbench for debugging
  

