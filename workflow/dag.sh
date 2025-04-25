# DAG graph
mkdir -p plot
snakemake -s workflow/preprocess.smk --rulegraph | dot -Tpng > plot/preprocess.png
snakemake -s workflow/onlinexxx.smk --rulegraph | dot -Tpng > plot/onlinexxx.png
snakemake -s workflow/plot.smk --rulegraph | dot -Tpng > plot/plot.png
