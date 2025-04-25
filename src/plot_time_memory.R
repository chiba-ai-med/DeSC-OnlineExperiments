source("src/Functions.R")

# Argument
args <- commandArgs(trailingOnly = TRUE)
outfile1 <- args[1]
outfile2 <- args[2]

# Loading
if(length(grep("exact_ooc_pca_sparse_mm", outfile1)) != 0) {
    infiles <- paste0("benchmarks/onlinepca_exact_ooc_pca_sparse_mm_", rows, ".txt")
}
if(length(grep("exact_ooc_pca_sparse_bincoo", outfile1)) != 0) {
    infiles <- paste0("benchmarks/onlinepca_exact_ooc_pca_sparse_bincoo_", rows, ".txt")
}
if(length(grep("sparse_dnmf", outfile1)) != 0) {
    infiles <- paste0("benchmarks/onlinenmf_sparse_dnmf_", rows, ".txt")
}
if(length(grep("bincoo_dnmf", outfile1)) != 0) {
    infiles <- paste0("benchmarks/onlinenmf_bincoo_dnmf_", rows, ".txt")
}
tabledata <- do.call(rbind, lapply(infiles, function(x) {
    read.table(x, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
}))

# Time
gdata_time <- data.frame(time=log10(tabledata$s/60/60), rows=as.factor(rows))
g_time <- ggplot(gdata_time, aes(x=rows, y=time)) + geom_bar(stat = "identity") + xlab("# Rows") + ylab("Time (log Hour)")

# Memory
gdata_memory <- data.frame(memory=tabledata$max_rss, rows=as.factor(rows))
g_memory <- ggplot(gdata_memory, aes(x=rows, y=memory/10^3)) + geom_bar(stat = "identity") + xlab("# Rows") + ylab("Memory usage (GB)")

# Plot
ggsave(filename = outfile1, g_time, width=12, height=8, dpi = 300)
ggsave(filename = outfile2, g_memory, width=12, height=8, dpi = 300)
