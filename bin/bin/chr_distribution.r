library(ggplot2)

files<-list.files()
chr<-files[grep("*chr.list$",files)]
for (i in 1:length(chr))
{
data<-read.table(chr[i],header=T,sep="\t")
pp<-ggplot(data=data,mapping=aes(x=chromosome,y=circRNA_number,fill=chromosome,group=factor(1)))+theme(axis.text.x=element_text(angle=45,size=8)) + geom_bar(stat="identity")
name<-gsub("list","pdf",chr[i])
ggsave(pp, file = name)
}
