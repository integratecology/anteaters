#!/bin/bash
#SBATCH --job-name=anteaters       # name of the job
#SBATCH --partition=defq           # partition to be used (defq, gpu or intel)
#SBATCH --time=96:00:00            # walltime (up to 96 hours)
#SBATCH --nodes=1                  # number of nodes
#SBATCH --ntasks-per-node=1        # number of tasks (i.e. parallel processes) to be started
#SBATCH --cpus-per-task=1          # number of cpus required to run the script
#SBATCH --mem-per-cpu=32G	   # memory required for process
#SBATCH --array=0-36%37 	   # set number of total simulations and number that can run simultaneously	  


module load gcc

export LD_LIBRARY_PATH="/home/alston92/software/lib64:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="/home/alston92/software/gdal-3.3.0/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="/home/alston92/software/proj-8.0.1/lib:$LD_LIBRARY_PATH"

module load R

cd /home/alston92/proj/anteaters   # where executable and data is located

list=(/home/alston92/proj/anteaters/data/*_r.csv)

date
echo "Initiating script"


if [ -f results/anteater_speeds.csv ]; then
	echo "anteater_speeds.csv already exists! continuing..."
else
	echo "creating results file anteater_speeds.csv"
	echo "uid,species,individual.local.identifier,timestamp,location.lat,location.long,HDOP,data.owner,temp_c,speed,speed_lcl,speed_ucl" > results/anteater_speeds.csv
fi

Rscript anteater_speeds.R ${list[SLURM_ARRAY_TASK_ID]}     # name of script
echo "Script complete"
date
