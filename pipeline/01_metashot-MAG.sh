#!/usr/bin/bash -l
#SBATCH -p batch -N 1 -n 48 --mem 192gb --out logs/mag.%a.%A.log --time 7-0:00:00 -a 1

module load singularity
module load workspace/scratch
INPUT=input
SAMPFILE=samples.csv
OUTPUT=results
mkdir -p $OUTPUT
export NXF_SINGULARITY_CACHEDIR=/bigdata/stajichlab/shared/singularity_cache/
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
  O=""
  for BASEPATTERN in $(echo $FILEBASE | perl -p -e 's/\;/,/g');
  do
      if [ ! -z $O ]; 
      then
	  O="$O $INPUT/$BASEPATTERN"
      else
	  O="$INPUT/$BASEPATTERN"
      fi
  done
  
  ./nextflow run metashot/mag-illumina -resume \
	     --reads "$O" \
	     --outdir results/$STRAIN --max_cpus $CPU \
	     --scratch $SCRATCH -c metashot-MAG.cfg 

done

