#! /usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

if (length(args)!=2){
	stop("Usage : RootedTree.R <Tree file> <outgroup list file>", call.=FALSE)}


require(ape)

tree<-read.tree(args[1])
outgroup<-read.table(args[2])

tr<-root(tree,as.vector(outgroup$V1),resolve.root=TRUE)

write.tree(tr,file=paste(args[1],"rooted",sep="_"))


