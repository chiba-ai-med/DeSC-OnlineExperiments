from snakemake.utils import min_version

#################################
# Setting
#################################
# Minimum Version of Snakemake
min_version("8.11.1")

ROWS = ['1000', '10000', '100000', '1000000']

rule all:
    input:
        'plot/simulation/exact_ooc_pca_sparse_mm/time.png',
        'plot/simulation/exact_ooc_pca_sparse_mm/memory.png',
        'plot/simulation/exact_ooc_pca_sparse_bincoo/time.png',
        'plot/simulation/exact_ooc_pca_sparse_bincoo/memory.png',
        'plot/simulation/sparse_dnmf/time.png',
        'plot/simulation/sparse_dnmf/memory.png',
        'plot/simulation/bincoo_dnmf/time.png',
        'plot/simulation/bincoo_dnmf/memory.png',
        'plot/simulation/scalability_time.png'

rule plot_onlinepca_exact_ooc_pca_sparse_mm:
    input:
        expand('output/simulation/{row}/exact_ooc_pca_sparse_mm/Scores.csv',
            row=ROWS)
    output:
        'plot/simulation/exact_ooc_pca_sparse_mm/time.png',
        'plot/simulation/exact_ooc_pca_sparse_mm/memory.png'
    container:
        'docker://koki/desc_investigation:20240508'
    resources:
        mem_mb=1000000
    benchmark:
        'benchmarks/plot_onlinepca_exact_ooc_pca_sparse_mm.txt'
    log:
        'logs/plot_onlinepca_exact_ooc_pca_sparse_mm.log'
    shell:
        'src/plot_time_memory.sh {output} >& {log}'

rule plot_onlinepca_exact_ooc_pca_sparse_bincoo:
    input:
        expand('output/simulation/{row}/exact_ooc_pca_sparse_bincoo/Scores.csv',
            row=ROWS)
    output:
        'plot/simulation/exact_ooc_pca_sparse_bincoo/time.png',
        'plot/simulation/exact_ooc_pca_sparse_bincoo/memory.png'
    container:
        'docker://koki/desc_investigation:20240508'
    resources:
        mem_mb=1000000
    benchmark:
        'benchmarks/plot_onlinepca_exact_ooc_pca_sparse_bincoo.txt'
    log:
        'logs/plot_onlinepca_exact_ooc_pca_sparse_bincoo.log'
    shell:
        'src/plot_time_memory.sh {output} >& {log}'

rule plot_onlinenmf_sparse_dnmf:
    input:
        expand('output/simulation/{row}/sparse_dnmf/U.csv',
            row=ROWS)
    output:
        'plot/simulation/sparse_dnmf/time.png',
        'plot/simulation/sparse_dnmf/memory.png'
    container:
        'docker://koki/desc_investigation:20240508'
    resources:
        mem_mb=1000000
    benchmark:
        'benchmarks/plot_onlinenmf_sparse_dnmf.txt'
    log:
        'logs/plot_onlinenmf_sparse_dnmf.log'
    shell:
        'src/plot_time_memory.sh {output} >& {log}'

rule plot_onlinenmf_bincoo_dnmf:
    input:
        expand('output/simulation/{row}/bincoo_dnmf/U.csv',
            row=ROWS)
    output:
        'plot/simulation/bincoo_dnmf/time.png',
        'plot/simulation/bincoo_dnmf/memory.png'
    container:
        'docker://koki/desc_investigation:20240508'
    resources:
        mem_mb=1000000
    benchmark:
        'benchmarks/plot_onlinenmf_bincoo_dnmf.txt'
    log:
        'logs/plot_onlinenmf_bincoo_dnmf.log'
    shell:
        'src/plot_time_memory.sh {output} >& {log}'

rule plot_scalability:
    input:
        expand('output/simulation/{row}/exact_ooc_pca_sparse_mm/Scores.csv', row=ROWS),
        expand('output/simulation/{row}/exact_ooc_pca_sparse_bincoo/Scores.csv', row=ROWS),
        expand('output/simulation/{row}/sparse_dnmf/U.csv',
            row=ROWS),
        expand('output/simulation/{row}/bincoo_dnmf/U.csv',
            row=ROWS)
    output:
        'plot/simulation/scalability_time.png'
    container:
        'docker://koki/desc_investigation:20240508'
    resources:
        mem_mb=1000000
    benchmark:
        'benchmarks/plot_scalability.txt'
    log:
        'logs/plot_scalability.log'
    shell:
        'src/plot_scalability.sh {output} >& {log}'
