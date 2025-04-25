source("src/Functions.R")

# Argument
args <- commandArgs(trailingOnly = TRUE)
outfile <- args[1]

# Loading
infiles1 <- paste0("benchmarks/onlinepca_exact_ooc_pca_sparse_mm_", rows, ".txt")
infiles2 <- paste0("benchmarks/onlinepca_exact_ooc_pca_sparse_bincoo_", rows, ".txt")
infiles3 <- paste0("benchmarks/onlinenmf_sparse_dnmf_", rows, ".txt")
infiles4 <- paste0("benchmarks/onlinenmf_bincoo_dnmf_", rows, ".txt")

infile <- c(infiles1, infiles2, infiles3, infiles4)
tabledata <- do.call(rbind, lapply(infile, function(x) {
    read.table(x, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
}))
method_name <- c(rep("OnlinePCA (exact_ooc_pca <MM>)", length(rows)),
    rep("OnlinePCA (exact_ooc_pca <BinCOO>)", length(rows)),
    rep("OnlineNMF (sparse_dnmf <MM>)", length(rows)),
    rep("OnlineNMF (bincoo_dnmf <BinCOO>)", length(rows)))
method_name <- factor(method_name,
    levels = c("OnlinePCA (exact_ooc_pca <MM>)",
        "OnlinePCA (exact_ooc_pca <BinCOO>)",
        "OnlineNMF (sparse_dnmf <MM>)",
        "OnlineNMF (bincoo_dnmf <BinCOO>)"))
tabledata <- data.frame(tabledata,
    method = method_name)

# Time
gdata_time <- data.frame(time=log10(tabledata$s/60/60), rows=log10(as.numeric(rows)), method = tabledata$method)

g_time <- ggplot(gdata_time, aes(x = rows, y = time, color = method)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "", x = "log10(Rows)", y = "log10(Time [Hour])") +
  theme_minimal()

# LM
models <- gdata_time %>%
  group_by(method) %>%
  do(model = lm(time ~ rows, data = .))
print(models)
print(models[1,2][[1]])
print(models[2,2][[1]])
print(models[3,2][[1]])
print(models[4,2][[1]])

# Plot
ggsave(filename = outfile, g_time, width=12, height=8, dpi = 300)
