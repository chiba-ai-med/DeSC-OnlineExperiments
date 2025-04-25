using OnlinePCA

# 引数の取得
infile = ARGS[1]
outdir = "data/simulation/" * ARGS[2] * "/"

# Output
sumr(binfile=infile, outdir=outdir, sparse_mode=true)