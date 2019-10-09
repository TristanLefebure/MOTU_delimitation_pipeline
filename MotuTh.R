#! /usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

if (length(args)!=1){
	stop("Usage : MotuTh.R <COI tree file>", call.=FALSE)}


library (ape)
library (seqinr)
library (cluster)
tree <- read.tree(args[1])


###Matrice de distance
matdist <- cophenetic.phylo(tree)
j<-0.16
bindist <- matdist

#Mettre des 0 et des 1 à la place des valeurs
bindist[which(matdist <= j)] <- 0
bindist[which(matdist > j)] <- 1
bindist <- as.dist(bindist)
sp.tr <- cutree(as.hclust(diana(bindist)), h=0)



sp.tr.l <- list()
for (k in unique(sp.tr)) {
	sp.tr.l[[k]] <- names(which(sp.tr == k))
}
colo <- rep(1,dim(tree$edge)[1])
col <- rep_len(2:5, length(sp.tr.l))
ed <- (1:length(sp.tr.l))
for (i in ed) { 
	w <- which.edge(tree,as.vector(sp.tr.l[[i]]))
# 	colo[w] <- rainbow(length(ed))[i]
	colo[w] <- col[i]
}
plot(tree, cex=0.05, edge.color=colo, no.margin=T, edge.width=0.2)

temp <- gsub("'", "", names(sp.tr))
motu<- data.frame(seq=temp, motu=sp.tr)

haplo <- read.table("COI_seq_haplo.tab",h=T)

haplo$motu <- motu$motu[match(haplo$ChosenHaplotype, motu$seq)]

ntab<-haplo[,c("motu","ChosenHaplotype")]
ntab<-unique(ntab)

##export for chimera assembler
# haplo[c("Sequence","motu")]
write.table(ntab, file=paste(args[1],"THmotu",sep="_"), sep="\t", col.names=F, row.names=F, quote=F)



