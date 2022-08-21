#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 128 --mem 200gb  --out logs/gtdbtk.wf_classify.%a.log -a 1

module load gtdbtk
module load workspace/scratch
CPU=2
if [ $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi

SAMPFILE=samples.csv

INPUT=results
OUTPUT=results

CPU=2
if [ $SLURM_CPUS_ON_NODE ]; then
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
  PREFIX=$STRAIN
  gtdbtk classify_wf --genome_dir $INPUT/$STRAIN/bins --out_dir $OUTPUT/$STRAIN/bins_classify_gtdbtk \
	 -x .fa --cpus $CPU --scratch_dir $SCRATCH --tmpdir $SCRATCH
done

