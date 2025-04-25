# HTML
mkdir -p report
snakemake -s workflow/preprocess.smk --report report/preprocess.html
snakemake -s workflow/onlinexxx.smk --report report/onlinexxx.html
snakemake -s workflow/plot.smk --report report/plot.html
