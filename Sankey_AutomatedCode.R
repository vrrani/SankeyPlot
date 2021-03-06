library(plotly)
library(rjson)

####################################### Provide Path and Files Name ###############
FilePath <- "" # Provide Working Directory
LableFile <- "InputFiles/Test_400_Lables(7to10).csv"
LinksFile <- "InputFiles/Test_400_Links(7to10).csv"
###json File Template ################################
json_data <- fromJSON(file = paste(FilePath,"Template-Json/jsonTemplateForSankey.json", sep =""))
###################################################################################


labels <- (read.csv(paste(FilePath, LableFile, sep =""), sep=",", header = TRUE))
links <- (read.csv(paste(FilePath, LinksFile, sep =""), sep=",", header = TRUE))

# Check if the labels and thier links are of same length
if(ncol(labels)/2 == ncol(links)) {
  ##########################################################
  # Collect Labels For Sankey json File
  names <- NULL
  colors <- NULL
  for( i in 1:ncol(labels) ) { 
   if((i %% 2) == 0) {
    colors <- c(colors, (labels[,i]))  
   }
   else{
    names <- c(names, (labels[,i]))  
   }
  } 
  newNames <- names[names != ""]
  newColor <- colors[colors != ""]
  ########################################################
  # Rearrange the nodegrouping number in the order for sankey
  newLinks <- NULL
  for( n in 1:ncol(links) ) { 
       if( n == 1) {
        links <- links[order(as.numeric(links[,n])),]
        newLinks <- cbind(newLinks, links[,n]-1)
       }
       else{
        modules <- links[,n]
        modules <- modules + max(newLinks[,n-1])
        newLinks <- cbind(newLinks, modules)
       }
    }
   
  ######################################################    
  # Collect Links For Sankey json File
  source <- NULL
  target <- NULL
  value <- NULL
  
  for( j in 1:(n-1) ) { 
     if( j == 1) {
     col <- (newLinks[,j])     
     source <- rbind(source, col)
     target <- rbind(target, newLinks[,j+1])
     value <- rbind(value, rep(1, times = length(col)))
    }
    else {
      modules <- sort(unique(newLinks[,j]))
      for( k in 1:length(modules)) {
       modulesNew <- newLinks[which(newLinks[,j] == modules[k]),]
      
      if(!is.null(dim(modulesNew))) 
       {  
          tab <- table(modulesNew[,j+1])
          names <- names(tab)
          
          for (l in 1:length(tab)) {
           source <- cbind( source, modules[k])
           target <- cbind(target, names[l])
           value <- cbind(value, tab[[l]]) 
          }
          
        }  else { 
	   source <- cbind( source, modulesNew[j])  
           target <- cbind(target, modulesNew[j+1])
           value <- cbind(value, 1)
        }
      } 
    }   
  } 
} else {print("The Sankey Plot Columns and Names Mismatch")}


######## Creating a Json File ##################
json_data$data[[1]]$node$label <- newNames
json_data$data[[1]]$node$color <- newColor
json_data$data[[1]]$link$source <- c(source)
json_data$data[[1]]$link$target <- c(as.double(target))
json_data$data[[1]]$link$value <- c(value)
#print(json_data)

############ Sankey Plot Code ########################################

if( length(json_data$data[[1]]$link$source) == length(json_data$data[[1]]$link$target) && 
       length(json_data$data[[1]]$link$target) == length(json_data$data[[1]]$link$value))
{
 if(length(json_data$data[[1]]$node$label) == length(json_data$data[[1]]$node$color))
 {
  ################ Sankey Plot Code Here ############################
  sankey <- plot_ly(
      type = "sankey",
      domain = list(
        x =  c(0,1),
        y =  c(0,1)
      ),
      orientation = "h",
      valueformat = ".0f",
      valuesuffix = " Links",
  
      node = list(
      
        label = json_data$data[[1]]$node$label,
        color = json_data$data[[1]]$node$color,
        pad = 1,
        thickness = 10,
        line = list(
          color = "black",
          width = 1
        )
      ),
  
      link = list(
        source = json_data$data[[1]]$link$source,
        target = json_data$data[[1]]$link$target,
        value =  json_data$data[[1]]$link$value,
        label =  json_data$data[[1]]$link$label
      )
      
    ) %>% 
    layout(
      title = "",
      font = list(
        size = 8
      )
  )
  sankey
  ##########################################################
 }else { print ("Mismatching labels and colors") }
 
}else {print ("Mismatching links length")}


  
