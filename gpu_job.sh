#!/bin/bash

#PBS -P vp91
#PBS -q gpuvolta
#PBS -l ncpus=48
#PBS -l ngpus=4
#PBS -l mem=380GB
#PBS -l walltime=00:05:00
#PBS -l storage=scratch/vp91
#PBS -e ./gpu-errlog
#PBS -o ./gpu-outlog
#PBS -l wd


module load openmpi/5.0.8
module load nvidia-hpc-sdk/25.7
module load cuda/12.6.2

mpirun -np 12 build/gpu/mpi_pi_gpu
