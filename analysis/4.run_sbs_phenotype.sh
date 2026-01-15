#!/bin/bash

# Run the SBS/phenotype rules
snakemake --use-conda --cores all \
    --snakefile "../brieflow/workflow/Snakefile" \
    --configfile "config/config_B3_tiling.yml" \
    --rerun-triggers mtime \
    --until all_sbs all_phenotype
