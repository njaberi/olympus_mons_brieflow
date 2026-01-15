#!/bin/bash
#SBATCH --job-name=brieflow_test       # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=1               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=nj6532@princeton.edu
#SBATCH --time=24:00:00          # total run time limit (HH:MM:SS)
#SBATCH --output=/scratch/gpfs/BRANGWYNNE/users/Shared/Nikhil - Nima/Olympus_mons_brieflow/analysis/brieflow_outputs/log/brieflow_OM_preprocessing.log

#NJ added 20260104
conda activate brieflow_OPS_pilot 
echo "activated environment"

# Log all output to a log file (stdout and stderr)
mkdir -p /scratch/gpfs/BRANGWYNNE/users/Shared/Nikhil - Nima/Olympus_mons_brieflow/analysis/brieflow_outputs/slurm/slurm_output/main
start_time_formatted=$(date +%Y%m%d_%H%M%S)
log_file="/scratch/gpfs/BRANGWYNNE/users/Shared/Nikhil - Nima/Olympus_mons_brieflow/analysis/brieflow_outputs/slurm/slurm_output/main/preprocessing-${start_time_formatted}.log"
exec > >(tee -a "$log_file") 2>&1

# Start timing
start_time=$(date +%s)

# TODO: Set number of plates to process
NUM_PLATES=2

echo "===== STARTING SEQUENTIAL PROCESSING OF $NUM_PLATES PLATES ====="

# Process each plate in sequence
for PLATE in $(seq 1 $NUM_PLATES); do
    echo ""
    echo "==================== PROCESSING PLATE $PLATE ===================="
    echo "Started at: $(date)"
    
    # Start timing for this plate
    plate_start_time=$(date +%s)
    
    # Run Snakemake with plate filter for this plate
    #NJ added
        #changed latency 60-->300
        # --jobs, --resources
    snakemake --executor slurm --use-conda \
        --workflow-profile "slurm/" \
        --snakefile "../brieflow/workflow/Snakefile" \
        --configfile "/scratch/gpfs/BRANGWYNNE/users/Shared/Nikhil - Nima/Olympus_mons_brieflow/analysis/config/config.yml" \
        --latency-wait 300 \
        --rerun-triggers mtime \
        --keep-going \
        --until all_preprocess \
        --config plate_filter=$PLATE \
        --jobs 600 \
        --resources mem_mb=250000
    
    # Check if Snakemake was successful
    if [ $? -ne 0 ]; then
        echo "ERROR: Processing of plate $PLATE failed. Stopping sequential run."
    fi
    
    # End timing and calculate duration for this plate
    plate_end_time=$(date +%s)
    plate_duration=$((plate_end_time - plate_start_time))
    
    echo "==================== PLATE $PLATE COMPLETED ===================="
    echo "Finished at: $(date)"
    echo "Runtime for plate $PLATE: $((plate_duration / 3600))h $(((plate_duration % 3600) / 60))m $((plate_duration % 60))s"
    echo ""
    
    # Optional: Add a short pause between plates
    sleep 10
done

echo "===== ALL $NUM_PLATES PLATES PROCESSED SUCCESSFULLY ====="
