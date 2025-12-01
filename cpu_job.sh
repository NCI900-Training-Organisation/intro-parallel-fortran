#!/bin/bash

#PBS -P vp91
#PBS -q normal
#PBS -l ncpus=12
#PBS -l mem=45GB
#PBS -l walltime=00:05:00
#PBS -l storage=scratch/vp91
#PBS -e ./cpu-errlog
#PBS -o ./cpu-outlog
#PBS -l wd


module load openmpi/5.0.8

mpirun -np 12 build/cpu/mpi_pi_cpu
