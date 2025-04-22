#!/bin/bash
#SBATCH -t 00:10:00
#SBATCH -J "Synch_p2p"
#SBATCH -p normal
#SBATCH --exclusive

source env.sh

ranks=$SLURM_NTASKS

max_threads_per_rank=128

if (( ranks < max_threads_per_rank )); then
    ranks_omp=1
    threads_per_rank=$ranks
else
    ranks_omp=$(( ranks / max_threads_per_rank ))
    threads_per_rank=$max_threads_per_rank
fi

iterations=1
m=65536
n=65536

echo "running MPI1"
srun -o mpi1_${ranks}-%j.out -e mpi1_${ranks}-%j.out -n $ranks ./PRK/MPI1/Synch_p2p/p2p $iterations $m $n

echo "running MPIRMA"
srun -o mpirma_${ranks}-%j.out -e mpirma_${ranks}-%j.out -n $ranks ./PRK/MPIRMA/Synch_p2p/p2p $iterations $m $n

echo "running MPISHM"
srun -o mpishm_${ranks}-%j.out -e mpishm_${ranks}-%j.out -n $ranks ./PRK/MPISHM/Synch_p2p/p2p $iterations $m $n

echo "running MPIOMP"
srun --spread-job --cpus-per-task=${threads_per_rank} -o mpiomp_${ranks}-%j.out -e mpiomp_${ranks}-%j.out -n $ranks_omp ./PRK/MPIOPENMP/Synch_p2p/p2p $threads_per_rank $iterations $m $n

echo "done"
