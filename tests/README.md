
  The tests are split into:
  - `asynchoros/` : RTL design and testbench for the complete CGRA fabric. 
  - `synchoros/`  : RTL design and testbench for minimal “valid-neighbour” configurations. 

## Synchoros Input testcase format

Each testcase contains:

- **`SiLagoBlocks/`**: Block description with path for resource and valid neighbour configuration.
- **`Operations/`**: Operation description and their resource bindings.
- **`Resources/`**: Resource description.
- **`ValidNeighbourDesigns/`**: Minimal abutted designs for each valid neighbour configuration.

See `tests/HyCUBE/synchoros/Input/README.md` for the short format description.