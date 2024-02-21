library(data.table)


# Get list of Data names --------------------------------------------------
path <- "/Users//mohammadabassi/Documents/SET/Data"
files <- list.files(path = path,recursive = TRUE,full.names = TRUE)
dt <- data.table(
  rbindlist(
    lapply(files,function(filename){
      temp <- data.table::fread(filename,skip = 7)

      # Parse header to get the information regarding the data table
      header <- read.csv(filename,nrows = 4,header = FALSE)[,1]
      Demographic <- limma::strsplit2(header[3],"[,]")[1]
      Sex <- gsub(" ","",limma::strsplit2(header[3],"[,]")[2])
      Age <- gsub("^ ","",limma::strsplit2(header[3],"[,]")[3])
      Cancer <- limma::strsplit2(header[2],"[ ]")[1]
      Years <- gsub("^ ","",limma::strsplit2(header[2],"[,]")[2])


      temp[,Years := Years]
      temp[,Demographic := Demographic]
      temp[,Sex := Sex]
      temp[,Age := Age]
      temp[,Cancer := Cancer]
      temp

})))
dt <- dt[`Age-Adjusted Incidence Rate([rate note]) - cases per 100,000`!= "*"]
dt <- dt[`Age-Adjusted Incidence Rate([rate note]) - cases per 100,000`!= "data not available"]
dt <- dt[`Age-Adjusted Incidence Rate([rate note]) - cases per 100,000`!= "[S3 note]"]
dt <- dt[`Age-Adjusted Incidence Rate([rate note]) - cases per 100,000`!= "[P3 note]"]


setnames(dt,
         old = "Age-Adjusted Incidence Rate([rate note]) - cases per 100,000",
         new = "Age-Adjusted Incidence Rate - cases per 100,000")

dt[,State := limma::strsplit2(dt$County,"[,]")[,2]]
dt[,State := gsub("[(6)]","",State)]
dt[,State := gsub("[(7)]","",State)]
dt[,State := gsub("^ ","",State)]
dt <- dt[State != ""]

dt[,`Age-Adjusted Incidence Rate - cases per 100,000` := as.numeric(`Age-Adjusted Incidence Rate - cases per 100,000`)]
dt[,`Average Annual Count` := as.numeric(`Average Annual Count`)]


# updated cancer names
dt[Cancer == "Lung", Cancer := "Lung & Bronchus"]
dt[Cancer == "Colon", Cancer := "Colon & Rectal"]
dt[Cancer == "Breast", Cancer := "Breast (Female)"]



path <- "/Users//mohammadabassi/Documents/SET"
fwrite(dt,file.path(path,"Cancer_rate_Dem_sex_age_county_data_012924.csv"))

Cancer_rates_dt <- dt
usethis::use_data(Cancer_rates_dt, overwrite = T)
# WHich county has the highest rate of Breast cancer in African American
# County
# 1:      Ada County, Idaho(7)
# 2:     Adair County, Iowa(7)
# 3: Adair County, Kentucky(7)
# 4: Adair County, Missouri(6)
# 5: Adair County, Oklahoma(6)
# 6:    Adams County, Idaho(7)
# 7: Adams County, Illinois(7)
# 8:     Adams County, Iowa(7)
# 9: Adams County, Nebraska(6)
# 10:     Adams County, Ohio(6)








