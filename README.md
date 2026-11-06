# AHB-to-APB Bridge Verification (UVM)

UVM testbench for an AMBA AHB-to-APB bridge. The bridge is an AHB slave on one
side and an APB master on the other: every AHB transfer is turned into an APB
transfer (setup phase, then access phase with `PENABLE`), and `HREADYOUT` is held
low while the APB side finishes.

## Design under test (`Bridge_rtl/`)

| Block | Job |
|---|---|
| `ahb_slave.v` | AHB interface: pipelines address and control, decodes the slave select, checks errors |
| `apb_controller.v` | bridge FSM (IDLE, READ, RENABLE, WWAIT, WRITE, WRITEP, WENABLE, WENABLEP), byte-lane selection |
| `apb_interface.v` | APB outputs |
| `ahb_apb_top.v` | top level (`rtl_top`) |

Four APB slaves, 1 KB each, at `8000_0000`, `8400_0000`, `8800_0000` and `8C00_0000`.

## Testbench

```
test ── env ─┬─ AHB master agent: sequencer → driver → AHB pins, monitor → ahb2sco
             ├─ APB slave agent: driver returns random PRDATA, monitor → apb2sco
             ├─ virtual sequencer
             └─ scoreboard: analysis FIFOs from both monitors
```

**Sequences** (`AHB_master/ahb_master_seqs.sv`): single transfers, defined-length INCR4/8/16 bursts, undefined-length INCR bursts and WRAP4/8/16 bursts, with random BUSY cycles inside bursts. Constraints keep addresses aligned to `HSIZE` and inside the slave ranges.

**Scoreboard** (`tb/bridge_scoreboard.sv`): each AHB data beat (NONSEQ or SEQ) must produce exactly one APB transfer, in order. For every pair it checks

- `PADDR == HADDR` and `PWRITE == HWRITE`
- `PSELx` is the slave that owns `HADDR`
- writes: `PWDATA` equals the active byte lane(s) of `HWDATA`; reads: `HRDATA` equals the active lane(s) of `PRDATA` (the bridge moves the active lane down to bit 0, see the `Endianess` tasks in `apb_controller.v`)

It counts passes and failures, reports AHB transfers that never reached the APB side in `check_phase`, and samples a covergroup on read/write × size (byte, halfword, word) × slave.

## Tests (`test/bridge_vtest_lib.sv`)

| Test | Stimulus |
|---|---|
| `bridge_base_test` | one defined-length INCR burst (writes) |
| `bridge_single_test` | ten single transfers, random read/write, size and slave |
| `bridge_incr_test` | defined- and undefined-length INCR bursts |
| `bridge_wrap_test` | WRAP4/8/16 bursts |

Each test waits until the scoreboard has matched every AHB transfer before ending.

## Running

```
cd sim
make run_test      # bridge_base_test   (VCS by default; set SIMULATOR = Questa for Questa)
make run_test1     # bridge_single_test
make run_test2     # bridge_incr_test
make run_test3     # bridge_wrap_test
make regress       # all tests + merged coverage
```

Tools: SystemVerilog, UVM, Synopsys VCS / Siemens QuestaSim.
