#!/bin/bash
#SBATCH -t 00:30:00
#SBATCH -J "Synch_p2p"
#SBATCH -p normal

source env.sh

ranks=$SLURM_NTASKS

threads_per_rank=32
ranks_omp=$(($ranks / $threads_per_rank))

iterations=1000
m=1280
n=12800

echo "running MPI1"
srun -o mpi1_$ranks-%j.out -e mpi1_$ranks.out -n $ranks ./PRK/MPI1/Synch_p2p/p2p $iterations $m $n

echo "running MPIRMA"
srun -o mpirma_$ranks-%j.out -e mpirma_$ranks.out -n $ranks ./PRK/MPIRMA/Synch_p2p/p2p $iterations $m $n

echo "running MPISHM"
srun -o mpishm_$ranks-%j.out -e mpishm_$ranks.out -n $ranks ./PRK/MPISHM/Synch_p2p/p2p $iterations $m $n

echo "running MPIOMP"
srun -o mpiomp_$ranks-%j.out -e mpiomp_$ranks.out -n $ranks_omp ./PRK/MPIOPENMP/Synch_p2p/p2p $threads_per_rank $iterations $m $n
