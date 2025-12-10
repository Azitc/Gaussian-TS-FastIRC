# Gaussian-TS-FastIRC
Optimize transition state structure down imaginary frequency in the style of IRC but without the total reaction coordinate, this will only run opt on the structure moving along the imaginary frequency
## Manual Installation
1. To install manually, type
   ```
   cp firc_script.sh firc_script
   ```
   then
   ```
   chmod +x firc_script
   ```
2. `cd /home/user` open .bashrc `vi .bashrc` then under "# User specific aliases and functions", type in
   ```
   alias firc='/path/to/firc_script'
   ```
   make sure to select the chmodded file. This alias can be customized such as `alias fastirc='/path/to/firc_script'`
<br /><br />
## Input File Specification (Opt Job)
Within `firc_optinp.txt` will be input file specification on how your input file would look like. The format is the same as normal Gaussian input file. Additional job such as `freq` may be added, extra parameters like solvation or EmpiricalDispersion could be added as desired, output format could be modified. <br />
DO NOT MODIFY THE NUMBER OF LINES, the script reads from line 2 to 10 of that file
### Example firc_optinp.txt
this is an example of nproc=4 and 12GB of memory with PBEPBE/def2SVP level of theory
```
### Begin inp file specification ###
%chk file will automatically be named firc_forward/firc_reverse.chk
%NProc=4
%mem=12GB

#p PBEPBE/def2SVP opt gfinput pop=full

	Title

0 1

### End inp file specification DO NOT MODIFY LINE NUMBERING ###
```
