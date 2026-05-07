from snakemake.utils import min_version

#################################
# Setting
#################################
# Minimum Version of Snakemake
min_version("8.11.1")

ROWS = ['1000', '10000', '100000', '1000000']

rule all:
    input:
        expand('data/simulation/{row}/Data.mtx.zst', row=ROWS),
        expand('data/simulation/{row}/Data.bincoo.zst', row=ROWS)

rule simulation_mm:
    output:
        'data/simulation/{row}/Data.mtx'
    container:
        'docker://koki/desc_investigation_julia:20240701'
    resources:
        mem_mb=1000000
    benchmark:
        'benchmarks/simulation_mm_{row}.txt'
    log:
        'logs/simulation_mm_{row}.log'
    shell:
        'src/simulation_mm.sh {output} {wildcards.row} >& {log}'

rule simulation_bincoo:
    output:
        'data/simulation/{row}/Data.bincoo'
    container:
        'docker://koki/desc_investigation_julia:20240701'
    resources:
        mem_mb=1000000
    benchmark:
        'benchmarks/simulation_bincoo_{row}.txt'
    log:
        'logs/simulation_bincoo_{row}.log'
    shell:
        'src/simulation_bincoo.sh {output} {wildcards.row} >& {log}'

rule simulation_mm2bin:
    input:
        'data/simulation/{row}/Data.mtx'
    output:
        'data/simulation/{row}/Data.mtx.zst'
    container:
        'docker://ghcr.io/rikenbit/onlinepcajl:f3532d4'
    resources:
        mem_mb=1000000
    benchmark:
        'benchmarks/simulation_mm2bin_{row}.txt'
    log:
        'logs/simulation_mm2bin_{row}.log'
    shell:
        'src/simulation_mm2bin.sh {input} {output} >& {log}'

rule simulation_bincoo2bin:
    input:
        'data/simulation/{row}/Data.bincoo'
    output:
        'data/simulation/{row}/Data.bincoo.zst'
    container:
        'docker://ghcr.io/rikenbit/onlinepcajl:f3532d4'
    resources:
        mem_mb=1000000
    benchmark:
        'benchmarks/simulation_bincoo2bin_{row}.txt'
    log:
        'logs/simulation_bincoo2bin_{row}.log'
    shell:
        'src/simulation_bincoo2bin.sh {input} {output} >& {log}'