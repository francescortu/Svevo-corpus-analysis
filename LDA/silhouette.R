library(textmineR)
library(cluster)
library(factoextra)

compute_silhouette_score <- function(model, display_plot){ 

  x<-as.data.frame(model$theta)
  
  # Hard clustering of documents assign to each document the most likely topic
  cluster <- NULL
  for(i in c(1:nrow(x))){
    cluster[i] <- which.max(x[i,])
  }

  #Compute siluette
  sil<-silhouette(cluster,CalcHellingerDist(model$theta))
  
  #plot
  if(display_plot == TRUE){
    print(fviz_silhouette(sil))
  }
  
  return(sil) 
}



#import LDA model
#lda_ita<-readRDS("LDA_model_ita.rds")
#compute_silhouette_score(lda_ita, FALSE)

