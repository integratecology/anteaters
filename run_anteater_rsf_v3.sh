#!/bin/bash
#SBATCH --job-name=ant_rsfs        # name of the job
#SBATCH --partition=defq           # partition to be used (defq, gpu or intel)
#SBATCH --time=96:00:00            # walltime (up to 96 hours)
#SBATCH --nodes=1                  # number of nodes
#SBATCH --ntasks-per-node=1        # number of tasks (i.e. parallel processes) to be started
#SBATCH --cpus-per-task=1          # number of cpus required to run the script
#SBATCH --mem-per-cpu=128G	   # memory required for process
#SBATCH --array=0-36%37    	   # set number of total simulations and number that can run simultaneously	  


module load gcc

export LD_LIBRARY_PATH="/home/alston92/software/lib64:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="/home/alston92/software/gdal-3.3.0/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="/home/alston92/software/proj-8.0.1/lib:$LD_LIBRARY_PATH"

ldd /home/alston92/R/x86_64-pc-linux-gnu-library/3.6/terra/libs/terra.so
ldd /home/alston92/R/x86_64-pc-linux-gnu-library/3.6/rgdal/libs/rgdal.so

module load R

cd /home/alston92/proj/anteaters   # where executable and data is located

list=(/home/alston92/proj/anteaters/data/*_r.csv)

date
echo "Initiating script"


if [ -f results/anteater_rsf_results_3.csv ]; then
	echo "Results file already exists! continuing..."
else
	echo "creating results file anteater_rsf_results_3.csv"
	echo "aid,pasture_est,pasture_lcl,pasture_ucl,nf_est,nf_lcl,nf_ucl,pf_est,pf_lcl,pf_ucl,stream_est,stream_lcl,stream_ucl,area,area_lcl,area_ucl,pasture_temp_est,pasture_temp_lcl,pasture_temp_ucl,nf_temp_est,nf_temp_lcl,nf_temp_ucl,pf_temp_est,pf_temp_lcl,pf_temp_ucl,stream_temp_est,stream_temp_lcl,stream_temp_ucl,runtime" > results/anteater_rsf_results_3.csv
fi

Rscript anteater_rsfs_3.R ${list[SLURM_ARRAY_TASK_ID]}     # name of script
echo "Script complete"
date
