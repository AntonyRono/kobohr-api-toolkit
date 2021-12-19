#Title:Updating Records via API in KOBO
#Author: Antony Rono
#Date: 19-Dec-2021


library(httr)
library(jsonlite)
library(tidyverse)
library(readxl)


########## Pre-requisites ########

# Ensure that the column names of the file containing the data you'd like to push  MATCHES the field names of the form in KOBO

# You can find the field names by downloading the form structure from KOBO, either as XML or XLS

# Please see the two excel files in the same directory as an example: "columns" is the form structure downloaded from KOBO, and "Edit data" is the data we'd like to Update with


# INPUTS --------------------------------------------------

u <-  "username"        # <---------- input your username
pw <-"password"  # <---------- input your password


kc_server_url<-"https://kc.humanitarianresponse.info/"    # <---------- The base url. Can be either of the two: kc_server or kobo server
kobo_server_url<-"https://kobo.humanitarianresponse.info/"

asset_uid = "awrt9VTU5pvS4MdBYuqCFo"                       # <---------- Input the form id(s). This can be found on the url of the form

url<-paste0(kc_server_url,"api/v1/submissions")            # <---------- Creating the API: Base Url + Endpoint


# Function to push data ---------------------------------------------------------

push_data <- function(file, url, asset_uid, username, password){
  
  for (i in 1:nrow(file)){
    
    file$meta[[i]]$instanceID <- paste0(file$meta[[i]]$instanceID,i)   # Making submission ids unique (By Adding Row Number)
    
    file_json <- toJSON(list(id =asset_uid,  submission = file[i,]), pretty = TRUE, flatten= FALSE, auto_unbox = TRUE, na = "null")  ##Changing file to Json
    
    file_json <- gsub(pattern = '\\[', replacement = "", x = file_json)    ##Replacing square brackets to round in the JSON file
    
    file_json <- gsub(pattern = '\\]', replacement = "", x = file_json)
    
    res <<- POST(url,authenticate(username,password), body =file_json, id =asset_uid, content_type_json())  ## Pushing data
    
    if(is.null(content(res)$error)){
      
      print(paste(content(res)$message, "for row", i, "instance id", content(res)$instanceID))  ## Result
      
    }else{
      
      print(paste("Error!", content(res)$error, "for row", i, "instance id", paste0(file$meta[[i]],i)))
      
    }
    
    
    
  }
  
  
}


# Importing Data  ----------------------------------

kobo_survey <- read_excel("Import files/Edit data")


# Adding InstanceID to Data  ----------------------------------------

# You need to specify the original UUID as well as a newly-generated UUID to identify the edited version

data_to_post <- kobo_survey %>% 
  
  mutate(meta = list(
    
    tibble(instanceID = paste0("uuid:",paste(random::randomStrings(n=1, len=8, digits=TRUE, upperalpha=TRUE,
                                                                   loweralpha=TRUE, unique=TRUE, check=TRUE)[1,],
                                             
                                             random::randomStrings(n=1, len=4, digits=TRUE, upperalpha=TRUE,
                                                                   loweralpha=TRUE, unique=TRUE, check=TRUE)[1,],
                                             
                                             random::randomStrings(n=1, len=4, digits=TRUE, upperalpha=TRUE,
                                                                   loweralpha=TRUE, unique=TRUE, check=TRUE)[1,],
                                             
                                             random::randomStrings(n=1, len=4, digits=TRUE, upperalpha=TRUE,
                                                                   loweralpha=TRUE, unique=TRUE, check=TRUE)[1,],
                                             
                                             format(lubridate::now(),"%Y%m%d%H%M"),
                                             
                                             sep = "-")),
           
           deprecatedID = paste0("uuid:",`_uuid`)
           
           
    ) 
    
  )
  
  )    

# Pushing data to the form in KOBO ------------------------------------------------

push_data(data_to_post,url, asset_uid, u, pw)