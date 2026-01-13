# Simple 8-bit Microprocessor (VHDL)

Educational CPU implemented in VHDL.  
Features a custom 8-bit instruction set, 4 general-purpose registers, unified memory, and a multi-cycle FSM control unit.

---

## Architecture Overview

- **Word size:** 8 bits  
- **Registers:** 4 general-purpose registers (R0–R3)  
- **Memory:** Unified program + data RAM  
  - 8 locations × 8 bits (`MEM_DEPTH = 8`, `MEM_ADDR_W = 3`)  
- **Instruction format (8 bits):**
  - `IR(7..5)` – opcode (3 bits)  
  - `IR(4..3)` – register index (2 bits)  
  - `IR(2..0)` – small address / extra field (3 bits)  

**Basic instructions:**

| Instruction | Opcode | Description |
|------------|--------|------------|
| LOAD Rr, [addr3] | 000 | Load memory into register |
| STORE Rr, [addr3] | 001 | Store register to memory |
| ADD Rd, Rs | 010 | Add two registers |
| HALT | 111 | Stop CPU |

**Execution model:**

- Von Neumann architecture (single unified memory)  
- Multi-cycle FSM: FETCH → DECODE → EXECUTE → WRITEBACK  
- No pipeline, no cache, no interrupts  

---

## Modules

### `cpu_types_pkg.vhd`
Global type and constant definitions:

- Word size, register count, memory depth  
- Opcode constants: `OP_LOAD`, `OP_STORE`, `OP_ADD`, `OP_HALT`  
- ALU operations: `type alu_op_t is (ALU_ADD, ALU_PASS_A)`  
- FSM states: `state_types`  
- Microinstruction record: `microinstr_t`  

### `regfile.vhd`
4 × 8-bit general-purpose registers (R0–R3).

- Synchronous write, combinational read  
- Ports:
  - `clk`, `write_enable`, `write_address`, `write_data`  
  - `readA_address`, `readB_address` → outputs: `readA_data`, `readB_data`  

### `alu.vhd`
8-bit combinational ALU.

- Ports:
  - `A`, `B` (inputs)  
  - `ALU_op`  
  - `Result` (output)  
- Operations:
  - `ALU_ADD` → `Result = A + B`  
  - `ALU_PASS_A` → `Result = A`  

### `memory.vhd`
Unified 8×8-bit memory.

- Synchronous write, combinational read gated by `read_en`  
- Ports: `clk`, `addr`, `data_in`, `write_en`, `read_en`, `data_out`  

### `microcode_rom.vhd`
Defines microinstructions for each FSM state.

- Inputs: `current_state`, `IR`  
- Output: `microinstr_out`  
- Handles control signal generation and FSM transitions  

### `control_unit.vhd`
FSM controller using microcode ROM.

- Inputs: `clk`, `rst`, `IR`  
- Outputs: control signals (`mem_read_en`, `mem_write_en`, `alu_op`, `reg_write_en`, `reg_src_sel`, `next_state`)  

### `cpu_core.vhd`
Top-level CPU integrating:

- Main registers: `PC`, `IR`, `AR`, `DR`  
- Register file, ALU, memory  
- Control unit (multi-cycle FSM)  

**Current limitation:** No dedicated output ports yet for testbench monitoring (e.g., `PC_out`, `IR_out`, `DR_out`).  

---

## Example Program (Current Memory Contents)

The microprocessor currently contains the following program in memory:

| Address | Instruction | Operation |
|---------|------------|-----------|
| 0 | `LOAD R0, [5]` | Load R0 with value from memory address 5 (value: 31) |
| 1 | `LOAD R2, [6]` | Load R2 with value from memory address 6 (value: 10) |
| 2 | `ADD R0, R0` | Add R0 = R0 + R0 (result: 62 stored in R0) |
| 3 | `STORE R2, [7]` | Store R2 to memory address 7 |
| 4 | `HALT` | Halt execution |
| 5 | `00011111` | Data: 31 (decimal) |
| 6 | `00001010` | Data: 10 (decimal) |
| 7 | (empty) | Memory location for storing result |

**Program Execution:**
1. Load the constant value 31 from memory into R0
2. Load the constant value 10 from memory into R2
3. Add R0 to itself: R0 = 31 + 31 = 62
4. Store the value from R2 (10) to memory address 7
5. Stop execution

---

## Instruction Behaviour

| Instruction | Behaviour |
|------------|-----------|
| **LOAD Rr, [addr3]** | `AR <- addr3`, `MEM -> DR`, `DR -> Rr` |
| **STORE Rr, [addr3]** | `AR <- addr3`, `Rr -> MEM` |
| **ADD Rd, Rs** | `Rd <- Rd + Rs` (ALU) |
| **HALT** | Enter `S_HALT`, stop CPU, disable writes |

---

## TODO

- Complete the FSM for all instructions  
- Implement the microprogrammed control unit fully  
- Add output ports for debugging (`PC_out`, `IR_out`, `DR_out`)  
- Create a testbench 

