#!/bin/bash
#SBATCH --job-name=brieflow_test       # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=1               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=nj6532@princeton.edu
#SBATCH --time=2:00:00          # total run time limit (HH:MM:SS)
#SBATCH --output=./log/6_run_merge_slurm.log

# Log all output to a log file (stdout and stderr)
mkdir -p slurm/slurm_output/main
start_time_formatted=$(date +%Y%m%d_%H%M%S)
log_file="slurm/slurm_output/main/merge-${start_time_formatted}.log"
exec > >(tee -a "$log_file") 2>&1

# Start timing
start_time=$(date +%s)

# Run the merge rules
snakemake --executor slurm --use-conda \
    --workflow-profile "slurm/" \
    --snakefile "../brieflow/workflow/Snakefile" \
    --configfile "config/config_B3_tiling.yml" \
    --latency-wait 60 \
    --rerun-triggers mtime \
    --keep-going \
    --until all_merge

# End timing and calculate duration
end_time=$(date +%s)
duration=$((end_time - start_time))
echo "Total runtime: $((duration / 3600))h $(((duration % 3600) / 60))m $((duration % 60))s"
