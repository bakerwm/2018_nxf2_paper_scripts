
# Author: Ming Wang
# Email: wangming@ibp.ac.cn
# Date: 2018-10-16
# License: MIT License

# The following codes were designed to generate high quality plots for
# publication.

## scatter plot
setwd("dNxf2_project")

# list DESeq2 output files
f1 <- "results/RNAseq_attp2_vs_dNxf2_KD/transposon_analysis/de_analysis/RNAseq_attp2_vs_dNxf2_KD/transcripts_deseq2.csv"
f2 <- "results/RNAseq_W1118_vs_dNxf2_mut/transposon_analysis/de_analysis/RNAseq_W1118_vs_dNxf2_mut/transcripts_deseq2.csv"
f3 <- "results/RNAseq_Panx_het_vs_Panx_mut/transposon_analysis/de_analysis/RNAseq_Panx_het_vs_Panx_mut/transcripts_deseq2.csv"

stopifnot(file.exists(f1) & file.exists(f2) & file.exists(f3))

# load required packages
source("src/rnaseq_plot_functions.R")
library(goldclipReport)
# extra R package,
# available on Github: https://github.com/bakerwm/goldclipReport.git
library(ggplot2)
library(ggrepel)

# dNxf2 WT vs dNxf2 KD
pdf1 <- "RNAseq_attp2_vs_dNxf2_KD.te.pdf"
x.label <- "dNxf2 WT"
y.label <- "dNxf2 KD"
annotation.labels <- c("HeT-A", "blood", "mdg1")
p1 <- make_deseq2_scatter_plot2(f1, organism = "dm3",
                              x.label = x.label, y.label = y.label,
                              show.sig.labels = FALSE,
                              annotation.labels = annotation.labels,
                              pvalue_cutoff = 0.05, save2pdf = NULL)
pdf(pdf1, width = 2.5, height = 2.5, paper = "a4")
print(p1)
dev.off()

# dNxf2 wt vs dNxf2 mut
pdf2 <- "RNAseq_dNxf2_wt_vs_dNxf2_mut.te.pdf"
x.label <- "dNxf2 wt"
y.label <- "dNxf2 mut"
annotation.labels <- c("HeT-A", "blood", "mdg1")
p2 <- make_deseq2_scatter_plot2(f2, organism = "dm3",
                               x.label = x.label, y.label = y.label,
                               show.sig.labels = TRUE,
                               annotation.labels = annotation.labels,
                               pvalue_cutoff = 0.05, save2pdf = NULL)

x.title <- expression(paste(italic("W1118 "), "[", log["10"], " rpm]"))
y.title <- expression(paste(italic("dNxf2 mut "), "[", log["10"], " rpm]"))
p <- p + xlab(x.title) + ylab(y.title)

pdf(pdf2, width = 3, height = 3, paper = "a4")
print(p2)
dev.off()

## significant TE in nxf2_wt_vs_nxf2_mut
df_nxf2_mut <- DESeq2_csv2df(x)
figF_sig_TE <- dplyr::filter(df_nxf2_mut, padj < 0.05)

# Panx_mut vs dNxf2_mut
pdf3 <- "RNAseq_CG9754_mut_vs_dNxf2_mut.te.pdf"
x.label <- "Panx mut"
y.label <- "dNxf2 mut"
df1 <- DESeq2_csv2df(f2)
df2 <- DESeq2_csv2df(f3)
df_norm <- merge(dplyr::select(df1, 1:3), dplyr::select(df2, 1:3), by = "id") %>%
  dplyr::mutate(RNAseq_Panx_mut_norm = RNAseq_CG9754_mut * RNAseq_W1118 / RNAseq_CG9754_het) %>%
  dplyr::select(id, RNAseq_Panx_mut_norm, RNAseq_dNxf2_mut)
names(df_norm) <- c("id", "x", "y")
df_norm$id <- as.character(df_norm$id)

# fix NA and missing values
df_norm$x[is.infinite(df_norm$x)] = 0
df_norm$y[is.infinite(df_norm$y)] = 0

# convert to log10
# replace zero values by 0.001 (rpm)
df_norm$x[df_norm$x == 0] <- 0.001
df_norm$y[df_norm$y == 0] <- 0.001
df_norm <- dplyr::mutate(df_norm, x = log10(x), y = log10(y))

annotation.labels = figF_sig_TE$id

p3 <- publish_plot_de_scatter(df_norm, x.label, y.label, point.size = 1.2,
                              point.color = "grey50", sig.labels = NULL,
                              sig.size = 1.2, sig.color = "red",
                              annotation.labels = annotation.labels,
                              annotation.point.size = 1.2,
                              annotation.point.color = "red",
                              show.labels.text = FALSE,
                              save2pdf = FALSE)

x.title <- expression(paste(italic("CG9754 mut "), "[", log["10"], " rpm]"))
y.title <- expression(paste(italic("dNxf2 mut "), "[", log["10"], " rpm]"))
p3 <- p3 + xlab(x.title) + ylab(y.title)

pdf(pdf3, width = 3, height = 3, paper = "a4")
print(p3)
dev.off()

# EOF
