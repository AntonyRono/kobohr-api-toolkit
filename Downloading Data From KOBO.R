#Title: Downloading Data from KOBO
#Author: Antony Rono
#Date: 31-May-2021

# Inputs ------------------------------------------------------------------

u = "username"        # <---------- input your username
pw<-"password"  # <---------- input your password
api = "kobohr"    # <---------- input the Url at which Kobo can be accessed: Either "kobo" or "kobohr"
form_id<-123456   # <---------- input the form id


######## Using KoboLoader Package #############------------------------------------------------


# Loading Library ---------------------------------------------------------

library(koboloadeR)

# Finding Form ID ---------------------------------------------------------

all_data_sets <- kobo_datasets(user = paste0(u,":",pw), api = api)

# Loading Data ------------------------------------------------------------

data <-  koboloadeR::kobo_data_downloader(form_id, paste0(u,":",pw), api = api)

data <- data.frame(data)

# Changing n/a to NA ------------------------------------------------------

data <- data.frame(lapply(data, function(x) {
  
  gsub("n/a", NA, x)
}))



######## Without Using KoboLoader ############ ------------------------------------------------------

library(httr)
library(jsonlite)
library(readr) # to read CSV data
library(openxlsx) # to write to excel file
library(tidyverse)

kobo_server_url<-"https://kobo.humanitarianresponse.info/"

kc_server_url<-"https://kc.humanitarianresponse.info/"


pull_data <- function(url, form_id, username, password){
  
  url<-paste0(url,"api/v1/data/",form_id,".csv")
  
  rawdata<-GET(url,authenticate(username,password),progress())
  
  if(rawdata$status_code == 200 || rawdata$status_code == 201){
    
    print(paste0("Sucess!!", "Status Code:",rawdata$status_code))
    
    d_content <- content(rawdata,"text",encoding="UTF-8")
    
    d_content_csv <- read_csv(d_content, col_types = cols(.default = "c"))
    
    d_content_csv <- as_tibble(d_content_csv)
    
  }else{
    
    paste0("Error! Unable to pull data;","Status Code:",rawdata$status_code)
    
  }

  
}


data <- pull_data(kc_server_url, form_id, u, pw)




### You can then save the data or analyze in R. Good luck!!!
