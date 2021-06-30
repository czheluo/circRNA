#MENG
args<-commandArgs(T)
library(ggplot2)
library(stringr)
library(grid)
library(gridExtra)
library(RColorBrewer)
color <- grDevices::colors()[grep("gr(a|e)y", grDevices::colors(), invert = T)]
rcolor <- color[sample(1:length(color), length(color))]
# real dataset

express <- read.table(args[1], header = T)

gro<-read.table(args[2],sep=",",header=F,stringsAsFactors=F)

pca <- prcomp(as.matrix(t(express[, -1])), scale = T)
pca.out <- as.data.frame(pca$x)

pca.out$sample <- gro[, 1]
pca.out$group <- gro[, 2]
nsample=length(pca.out$group)
# SET THEM
theme <- theme(
  axis.text = element_text(size = 16),
  axis.title = element_text(size = 16, face = "bold"),
  legend.title = element_text(size = 16),
  legend.text = element_text(size = 16),
  panel.background = element_blank(),
  panel.border = element_rect(fill = NA),
  panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(),
  strip.background = element_blank(),
  axis.text.x = element_text(colour = "black"),
  axis.text.y = element_text(colour = "black"),
  axis.ticks = element_line(colour = "black"),
  plot.margin = unit(c(1, 1, 1, 1), "line")
)

# explation

percentage <- round(pca$sdev / sum(pca$sdev) * 100, 2)
percentage <- paste(
  colnames(pca.out),
  "(", paste(as.character(percentage), "%", ")", sep = "")
)

pdf("pca.pdf",width=15,height=10)
p <- ggplot(pca.out, aes(x = PC1, y = PC2, color = sample,shape=group,label = row.names(pca.out)))
p <- p + geom_point(size = 6) +geom_text(size = 7,nudge_x = 0,nudge_y = 10)+
  xlab(percentage[1]) + ylab(percentage[2]) +
  scale_color_manual(values = rcolor[sample(1:100)[c(1:nsample)]]) + theme
p
dev.off()
