# HyCUBE (asynchoros)

This folder includes RTL and testbench collateral derived from the HyCUBE project:
[`aditi3512/HyCUBE`](https://github.com/aditi3512/HyCUBE).

This copy is included to support the **HyCUBE asynchoros testcase** in this repository; minor local edits may exist for integration/reproducibility.

## RTL design (ASCII overview)

Notes:
- The full chip wrapper exists as `chip_with_pad` → `chip` → `hycube`, but the provided testbench instantiates `hycube` directly.
- The HyCUBE fabric inside `hycube` is a \(4 \times 4\) tile array (`NUM_TILES_X = NUM_TILES_Y = 4`).

```text
Top-level wrappers (available in rtl/rtl/)

  chip_with_pad
      |
      +--> chip  -------------------------------------------------------------+
            |                                                                 |
            +--> spi_all  (programming interface / drives scan_data path)     |
            |                                                                 |
            +--> clkGen_top_blmux (clock generation)                          |
            |                                                                 |
            +--> hycube  (core fabric)                                        |
                                                                               \
Core fabric (hycube.sv)

  hycube
    |
    +--> Control-memory macros (per tile)   TS6N40LPA24X64M2F (CM, 64-bit wide)
    |
    +--> Data-memory macros (subset tiles)  TSDN40LPA512X32M4F (DM, 32-bit wide)
    |       - DM banks are attached to specific tiles (see is_dm_tile logic)
    |
    +--> 4x4 Tile Array
          (Tile[i][j] for i in Y, j in X)
            |
            +--> tile (tile.sv)
                  |
                  +--> router (router.sv) + xbar/encoder/globals packages
                  |
                  +--> simple_alu (simple_alu.sv)
                  |
                  +--> local CM/DM interfaces
                  |
                  +--> NoC links (N/E/S/W) connecting neighboring tiles

NoC connectivity (conceptual)

   [0,0] -- [0,1] -- [0,2] -- [0,3]
     |        |        |        |
   [1,0] -- [1,1] -- [1,2] -- [1,3]
     |        |        |        |
   [2,0] -- [2,1] -- [2,2] -- [2,3]
     |        |        |        |
   [3,0] -- [3,1] -- [3,2] -- [3,3]
```

## Testbench behavior (ASCII overview)

The main testbench here is `rtl/tb/tb_hycube_new.sv`. It programs HyCUBE by replaying address/data traces for **DM** and **CM**, then asserts `scan_start_exec` to start execution.

```text
tb (tb_hycube_new.sv)
  |
  +--> drives clk (10ns period) and reset
  |
  +--> instantiates DUT: hycube uut(...)
  |
  +--> uses tri-state "data" bus:
        data = (~read_write) ? data_in : Z

Timeline / intent

  1) Initialize + reset release
     - reset=1 for a short time, then reset=0
     - chip_en=1, read_write=0 (testbench drives data bus)

  2) Program Data Memory (DM) using SRAM traces
     for num_inst = 0 .. NUM_DATA-1:
       a) Load next 16b address word  from ../rtl/SRAM_addr.trc  -> data_in
          drive: scan_data_or_addr=1 (address), data_addr_valid=2'b11, read_write=0
       b) Load next 16b data word     from ../rtl/SRAM_data.trc  -> data_in
          drive: scan_data_or_addr=0 (data),    data_addr_valid=2'b11, read_write=0

  3) Program Control Memory (CM) using CM traces
     for num_inst = 0 .. NUM_INST-1:
       a) Load next 16b address word  from ../rtl/CM_addr.trc    -> data_in
          drive address phase (scan_data_or_addr=1)
       b) Load next 16b data word     from ../rtl/CM_data.trc    -> data_in
          drive data phase    (scan_data_or_addr=0)

  4) Start execution
     - wait a couple cycles
     - set scan_start_exec = 1
     - DUT runs until exec_end indicates completion
```