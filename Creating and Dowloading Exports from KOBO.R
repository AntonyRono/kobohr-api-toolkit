#Title:Creating and Dowloading Exports from KOBO
#Author: Antony Rono
#Date: 31-May-2021

library(httr)
library(jsonlite)
library(readr) # to read CSV data
library(openxlsx) # to write to excel file
library(tidyverse)
library(R.utils)
library(readxl)
library(lubridate)
library(tidyverse)


####################### Helper Functions ##################### -------------------------------------------------------


# Function to trigger exports  --------------------------------------------

kobohr_create_export <- function(){
  
  api_url_export<-paste0(kobo_server_url,"exports/")
  
  api_url_asset<-paste0(kobo_server_url,"assets/",asset_uid,"/")
  
  api_url_export_asset<-paste0(kobo_server_url,"exports/",asset_uid,"/")

  d<-list(source=api_url_asset,
          type=type,
          lang=lang,
          fields_from_all_versions=fields_from_all_versions,
          hierarchy_in_labels=hierarchy_in_labels,
          multiple_select = multiple_select,
          group_sep=group_sep)
  
  result<-httr::POST (url=api_url_export,
                      body=d,
                      authenticate(u,pw),
                      progress()
  )
  
  
  
  if(result$status_code == 200 | result$status_code == 201){
    
    print(paste0("Success! ","status code:",result$status_code))
    
  }else{
    
    print("*** Report generation failed ***")
  }
  
  
  d_content <- rawToChar(result$content)
  
  d_content <- fromJSON(d_content)
  
  report_key <<- d_content$uid
  
  return(report_key)
}



# Function to list all the previous exports for a form --------------------


kobohr_list_exports <- function(){
  
  api_url_export<-paste0(kobo_server_url,"exports/")
  
  api_url_asset<-paste0(kobo_server_url,"assets/",asset_uid,"/")
  
  api_url_export_asset<-paste0(kobo_server_url,"exports/",asset_uid,"/")
  
  payload<-list(q=paste0('source:',asset_uid))

  result<-httr::GET (url=api_url_export,
                     query=payload,
                     authenticate(u,pw),
                     progress()
  )
  
  warn_for_status(result)
  
  stop_for_status(result)
  
  d_content <- rawToChar(result$content)
  
  Encoding(d_content) <- "UTF-8"
  
  d_content <- fromJSON(d_content)

  d_content_result<-data.frame(d_content$results$result,d_content$results$date_created,d_content$results$last_submission_time)
  
  names(d_content_result)<-str_remove(names(d_content_result),"d_content.results.")
  
  d_content_data<-data.frame(d_content$results$data)
  
  d_content_all<-bind_cols(d_content_result,d_content_data)
  
  d_content_list<-d_content_all %>% 
    
  filter(str_detect(source,asset_uid))
  
  all_exports <<- d_content_list
}


# Function to download file 

download_report <- function(filename, path){
  
  MAX_POLL_ATTEMPTS =1000    # <---------- Increase the poll if the file takes too long to download
  
  if (!exists("report_key")) {
    
    print("Error:Missing report key!")
    
  }else{
    
    repeat{
      
      d_list_export_urls<-kobohr_list_exports()
      
      d_list_url<-d_list_export_urls[nrow(d_list_export_urls),]
      
      latest_url<<-d_list_url$result
      
      attempts = 0
      
      if(attempts > MAX_POLL_ATTEMPTS){
        
        print("Error:Timed out trying to fetch report, try setting a higher MAX_PULL_ATTEMPTS!")
        
        break
      
      }else if(is.na(latest_url)){
        
        attempts = attempts + 1 
        
        print(paste("attempting to download ",filename," to ",path, ",attempt", attempts))
        
        
        
      }else{
        
        downloadFile(url = latest_url, filename = filename,  path = path,skip = FALSE, overwrite = TRUE, username= u, password = pw)
        
        print(paste0("Successfully downloaded ", filename, " to ", path, " at ", now()))
        
        break
      }
      
    }
    
    
  }
  
}



######################## INPUTS ##############################------------------------------------------------------

#### Fixed Values: URLS, Authentication 

kobo_server_url<-"https://kobo.humanitarianresponse.info/"
kc_server_url<-"https://kc.humanitarianresponse.info/"

u = "username"        # <---------- input your username
pw<-"password"  # <---------- input your password


#### Export Settings

# Go to https://kobo.humanitarianresponse.info/exports/  to see all possible values

type <- "xls"
lang <- "_default"
fields_from_all_versions <- "true"
multiple_select <- "both" 
hierarchy_in_labels <- "FALSE"
group_sep = "/"

#### Directory to save the files

save_dir <- getwd()  # <---------- Or input the directory you'd like to save your files

#### Form Ids

forms <-  list("aMvrg5325RTNYxAYeuBm29",   # <---------- Input the form id(s). This can be found on the url of the form
               "aLFxADZ2gV9YhxHyb99mqr",  
               
)


#### Output Names of the files

output_files <- list("Survey1.xlsx",   # <---------- Input the name(s) you'd like to save the file(s) as. Note the extension has to match the type that you specified under export settings
                     "Survey2.xlsx"
                     
                     )




##################### Pulling and Downloading Reports ################## -----------------------------------------


for (i in seq_along(forms)){
  
  asset_uid <- forms[[i]]
  
  filename = output_files[[i]]
  
  kobohr_create_export()
  
  download_report(filename, save_dir)
  
  
}
