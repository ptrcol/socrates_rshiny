#___________________________________________________________________________
# This file is part of the SOcial Contact RATES (SOCRATES) modelling project
# 
# => PLOT TILE
#
#  Copyright 2020, SIMID, UNIVERSITY OF ANTWERP & HASSELT UNIVERSITY
#___________________________________________________________________________


#mij <- contact_matrix(polymod, countries = "United Kingdom", age.limits = c(0, 1, 5, 15))$matrix
#mij <- matrix_out$matrix
plot_tile <- function(mij,plot_title="",plot_xlab="",plot_ylab="",scale_max=NA){
  if(all(is.na(mij))){
    return(NA)
  }
  if(!exists('format_num_digits')){
    format_num_digits <- 2
  }
  redc <- rev(heat.colors(100))
  par(mar=c(5, 6, 2, 2),mgp=c(3,0.5,0))
  p <- simage(s = mij, 
              xlab=plot_xlab,
              ylab=plot_ylab, 
              legend.width=1,
              slim=c(min(0,mij,na.rm=T), ifelse(is.na(scale_max),max(mij,na.rm=T),max(1,scale_max))), 
              cex.lab=1.2,
              cex.main=1.2, 
              las=0.1,
              col=redc, 
              main=plot_title, 
              xaxt="n", 
              yaxt="n")
  # set axis 
  plt_ticks <- seq(0,1,length=nrow(mij))
  axis(2, at=plt_ticks, labels = c(colnames(mij)),cex.axis=0.9,tick = FALSE,las=1)
  axis(1, at=plt_ticks, labels = c(colnames(mij)),cex.axis=0.9,tick = FALSE)
  
  # format results (rounding/scientific)
  if(any(max(mij,na.rm=T)>1)){
    mij <- round(mij,digits=format_num_digits)
  } else{
    mij <- format(mij,digits = format_num_digits)
  }
  # get grid centers and add value
  e_grid <- expand.grid(plt_ticks,plt_ticks)
  text(e_grid, labels = mij)
}

# test
#mij <- contact_matrix(polymod, countries = "United Kingdom", age.limits = c(0, 1, 5, 15))$matrix
#plot_tile(mij,"NGM","Infected","Infective")
