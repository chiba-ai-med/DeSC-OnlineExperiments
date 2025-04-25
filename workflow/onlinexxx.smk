from snakemake.utils import min_version

#################################
# Setting
#################################
# Minimum Version of Snakemake
min_version("8.11.1")

ROWS = ['1000', '10000', '100000', '1000000']

rule all:
    input:
        expand('output/simulation/{row}/exact_ooc_pca_sparse_mm/Scores.csv',  
            row=ROWS),
        expand('output/simulation/{row}/exact_ooc_pca_sparse_bincoo/Scores.csv',  
            row=ROWS),
        expand('output/simulation/{row}/sparse_dnmf/U.csv',
            row=ROWS),
        expand('output/simulation/{row}/bincoo_dnmf/U.csv',
            row=ROWS)

rule onlinepca_exact_ooc_pca_sparse_mm:
    input:
        'data/simulation/{row}/Data.mtx.zst'
    output:
        'output/simulation/{row}/exact_ooc_pca_sparse_mm/Scores.csv'
    container:
        'docker://ghcr.io/rikenbit/onlinepcajl:f3532d4'
    resources:
        mem_mb=1000000
    benchmark:
        'benchmarks/onlinepca_exact_ooc_pca_sparse_mm_{row}.txt'
    log:
        'logs/onlinepca_exact_ooc_pca_sparse_mm_{row}.log'
    shell:
        'src/onlinepca_exact_ooc_pca_sparse_mm.sh {input} {output} >& {log}'

rule onlinepca_exact_ooc_pca_sparse_bincoo:
    input:
        'data/simulation/{row}/Data.bincoo.zst'
    output:
        'output/simulation/{row}/exact_ooc_pca_sparse_bincoo/Scores.csv'
    container:
        'docker://ghcr.io/rikenbit/onlinepcajl:f3532d4'
    resources:
        mem_mb=1000000
    benchmark:
        'benchmarks/onlinepca_exact_ooc_pca_sparse_bincoo_{row}.txt'
    log:
        'logs/onlinepca_exact_ooc_pca_sparse_bincoo_{row}.log'
    shell:
        'src/onlinepca_exact_ooc_pca_sparse_bincoo.sh {input} {output} >& {log}'

rule onlinenmf_sparse_dnmf:
    input:
        'data/simulation/{row}/Data.mtx.zst'
    output:
        'output/simulation/{row}/sparse_dnmf/U.csv'
    container:
        'docker://ghcr.io/rikenbit/onlinenmfjl:e7a5cc3'
    resources:
        mem_mb=1000000
    benchmark:
        'benchmarks/onlinenmf_sparse_dnmf_{row}.txt'
    log:
        'logs/onlinenmf_sparse_dnmf_{row}.log'
    shell:
        'src/onlinenmf_sparse_dnmf.sh {input} {output} >& {log}'

rule onlinenmf_bincoo_dnmf:
    input:
        'data/simulation/{row}/Data.bincoo.zst'
    output:
        'output/simulation/{row}/bincoo_dnmf/U.csv'
    container:
        'docker://ghcr.io/rikenbit/onlinenmfjl:e7a5cc3'
    resources:
        mem_mb=1000000
    benchmark:
        'benchmarks/onlinenmf_bincoo_dnmf_{row}.txt'
    log:
        'logs/onlinenmf_bincoo_dnmf_{row}.log'
    shell:
        'src/onlinenmf_bincoo_dnmf.sh {input} {output} >& {log}'
