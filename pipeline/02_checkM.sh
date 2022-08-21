#!/bin/bash -l
#
#SBATCH -n 48 #number cores
#SBATCH -p batch -a 1
#SBATCH -o logs/checkm.%a.log
#SBATCH -e logs/checkm.%a.elog
#SBATCH --mem 192G #memory in Gb

module load checkm

MIN=2500
INBIN=bins
OUTPUT=bins_checkM

CPU=2
if [ ! -z $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi

N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
  N=$1
fi
if [ -z $N ]; then
  echo "cannot run without a number provided either cmdline or --array in sbatch"
  exit
fi
IFS=,
tail -n +2 $SAMPFILE | sed -n ${N}p | while read STRAIN FILEBASE
do
    BINFOLDER=$INPUT/$STRAIN/$INBIN
    OUT=$OUTPUT/$STRAIN/$OUTPUT
    mkdir -p $OUT
    checkm lineage_wf -t $CPU -x fa $BINFOLDER $OUT

    checkm tree $BINFOLDER -x .fa -t $CPU $OUT/tree

    checkm tree_qa $OUT/tree -f $OUT/checkm.txt
done

