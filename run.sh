#!/bin/bash
#SBATCH -t 00:60:00
#SBATCH -J "Synch_p2p"
#SBATCH -p normal
#SBATCH --exclusive

if [ -z "$1" ]; then
    echo "pass iterations as first argument"
    exit
fi

if [ -z "$2" ]; then
    echo "pass m as second argument"
    exit
fi

if [ -z "$3" ]; then
    echo "pass n as third argument"
    exit
fi

source env.sh

ranks=$SLURM_NTASKS

max_threads_per_rank=(1 2 4 8 16 32 64 128)

iterations=$1
m=$2
n=$3

echo "Setup: ${2}x${3}, ${1} iterations"

echo "running MPI1"
srun -o mpi1_${ranks}_${2}_${3}-%j.out -e mpi1_${ranks}_${2}_${3}-%j.out -n $ranks ./PRK/MPI1/Synch_p2p/p2p $iterations $m $n

echo "running MPIRMA"
srun -o mpirma_${ranks}_${2}_${3}-%j.out -e mpirma_${ranks}_${2}_${3}-%j.out -n $ranks ./PRK/MPIRMA/Synch_p2p/p2p $iterations $m $n

echo "running MPISHM"
srun -o mpishm_${ranks}_${2}_${3}-%j.out -e mpishm_${ranks}_${2}_${3}-%j.out -n $ranks ./PRK/MPISHM/Synch_p2p/p2p $iterations $m $n

echo "running MPIOMP"
for (( num_threads = 1; num_threads <= 128; num_threads = num_threads * 2 )); do
    if (( ranks <= num_threads )); then
        ranks_omp=1
        threads_per_rank=$ranks
    else
        ranks_omp=$(( ranks / num_threads ))
        threads_per_rank=$num_threads
    fi

    srun --spread-job --cpus-per-task=${threads_per_rank} -o mpiomp_${threads_per_rank}_${ranks}_${2}_${3}-%j.out -e mpiomp_${threads_per_rank}_${ranks}_${2}_${3}-%j.out -n $ranks_omp ./PRK/MPIOPENMP/Synch_p2p/p2p $threads_per_rank $iterations $m $n
done

echo "done"
