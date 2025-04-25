using OnlinePCA

# Command line arguments
infile = ARGS[1]
outdir = dirname(ARGS[2])

# Exact Out-of-Core PCA
out = exact_ooc_pca(
	input=infile,
	scale="raw", dim=10, chunksize=50000, mode="sparse_mm")

# Output
OnlinePCA.output(outdir, out, 0.1f0)