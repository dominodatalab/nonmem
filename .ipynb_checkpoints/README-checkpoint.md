## Setup

This code will not work until a nonmem.lic file is purchases and placed within the /license folder in this project.

Use with the `NONMEM Regular Environment` for regular workloads. For MPI, use the 
`NONMEM MPI Compute Environment` and `NONMEM MPI Cluster Environment`.

## NONMEM Testing Overview

The following are test commands for running a NONMEM models on the workspace node and across nodes. The perl-speaks 
library is used to execute these programs. Note, the parafile is what runs NONMEM
in a parallel/distributed manner, and will start the mpirun command but it isn't successful. 
The example files are from 
[https://kb.metworx.com/Users/Tutorials/Nonmem/Nonmem-via-PsN/](https://kb.metworx.com/Users/Tutorials/Nonmem/Nonmem-via-PsN/).

The NONMEM documentation is saved in the project as nm741.pdf and has details about 
how to install MPI that might be helpful here, as well as the parafile information. 

#### Nonmem execution for run649:
`execute /mnt/code/insulin/run649.mod -dir=/mnt/code/run649`

#### Nonmem execution for run105:
`execute /mnt/code/run105.mod -dir=/mnt/code/run105`
 
#### Parallelization for run650:
This is the same as run649 but with parallelization options, from the original example:
 
`execute /mnt/insulin/run650.mod -dir=/mnt/run650 -parafile=/mnt/insulin/16.pnm`

This is my modified version, was not successful on MPI either:

`execute /mnt/run650/run650.mod -always_datafile_in_nmrun  -verbose -clean=4 -parafile=/mnt/mpi.pnm`

