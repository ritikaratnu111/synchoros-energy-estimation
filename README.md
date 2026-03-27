# synchoros-energy-estimation

Artifacts (paper + code + testcases) for **Synchoros** energy characterization/estimation of CGRA fabrics, with state-of-the-art (SOTA) comparisons.

## Repository layout

- **`src/`**  : Python code for running characterization/estimation flows.


- **`tests/`**: Testcases for the following CGRAs 
  - `ADRES/`: [B. Mei, et al, “ADRES: An architecture with tightly coupled VLIW processor and coarse-grained reconfigurable matrix,” FPL 2003](https://link.springer.com/chapter/10.1007/978-3-540-45234-8_7)
  - `DRRA/` : 
  - `HyCUBE/` : https://www.comp.nus.edu.sg/~tulika/DAC17.pdf 


- **`sota/`**: Comparion with two state-of-the-art estimation methodologies:
  - `accelergy/` : https://accelergy.mit.edu/paper.pdf
  - `cgra_eam/`  : https://research.tue.nl/en/publications/cgra-eam-rapid-energy-and-area-estimation-for-coarse-grained-reco/

- **`paper/`**: LaTeX sources for the paper.


## Quickstart
```bash
cd tests/HyCUBE/synchoros
python3 ../../../src/PowerCharacterizer.py
```
This will read Input files and emit reports under:
- `./Output/power_reports/`

