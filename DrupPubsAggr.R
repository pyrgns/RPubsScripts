# 
# This script collapses and merges database tables from Drupal publications
# into a aggregate human readable .csv file that can be queryied with SAS or 
# R or other statistical computing software
# 

#
# CONFIGURATION
#

working_directory = "/Users/pdy/code/R/Publications/RPubsScripts"

#setting the working directory
setwd(file.path(working_directory))

# setting the path to the csv of the main biblio table
biblio_path = "data/biblio.csv"

# biblio_types table path ie journal article, book, dissertation
types_path = "data/biblio_types.csv"

# biblio_contributor table path  
contributor_path = "data/biblio_contributor.csv"

# biblio_contributor_data table path
contributor_data_path = "data/biblio_contributor.csv"

# biblio_keyword table path
keyword_path = "data/biblio_keyword.csv"

# biblio_keyword_data table path
keyword_data_path = "data/biblio_keyword_data.csv"

# biblio_pubmed table path
pubmed_path = "data/biblio_pubmed.csv"

## READING THE CSV TABLES INTO DATA FRAMES

# biblio table 
biblio<-read.csv(biblio_path, head=TRUE, sep=",")

# biblio_types table, a lookup table for types such as journal, book, thesis 
# There is a a one biblio : one type relationship 
types<-read.csv(types_path, head=TRUE, sep=",")

# biblio_contributor table, a join or juntion table between the biblio and biblio_contributor_data tables
# Generally, there is a one one biblio : many contributors relatioinshipo 
contributor<-read.csv(contributor__path, head=TRUE, sep=",")

# biblio_contributor_data, a lookup table for contributor names 
contributor_data<-read.csv(contributor_data_path, head=TRUE, sep=",")

# biblio_keywords table, a join or juntion table between the biblio and biblio_keywords_data tables
# generally, 1 biblio: many keywords 
keyword<-read.csv(keyword_path, head=TRUE, sep=",")


# biblio_keywords, a lookup table for keyword names
keyword_data<-read.csv(keyword_data_path, head=TRUE, sep=",")



# biblio_pubmed table, a lookup table for pubmed and pubmed central ids
# one biblio: one pubmed AND/OR pmc id(s)  
pubmed<-read.csv(pubmed_path, head=TRUE, sep=",")

# MERGING PUBMED AND TYPES INTO BIBLIO - ONE TO ONE RELATIONSHIPS 

#types
biblio<-merge(biblio,types, by.x = "biblio_type", by.y = "tid", all=TRUE)

#changing the column name from "name" to "type"
# colnames(biblio)[7] <- "type"

biblio$biblio_type <- NULL

#pubmed
biblio<-merge(biblio,pubmed, by.x= "nid", by.y = "nid", all=TRUE)

# MERGING AND COLLAPSING KEYWORDS AND CONTRIBUTORS THEN MERGING INTO BIBLIO - MOST LIKELY TO TO BE ONE TO MANY RELATIONSHIPS


# I'm using this for aggregate
# http://stackoverflow.com/questions/16596515/aggregating-by-unique-identifier-and-concatenating-related-values-into-a-string


# contributor

c_merged<-merge(contributor,contributor_data, by = "cid", all=TRUE)

c_merged$cid <- NULL

c_agg<-aggregate(name~nid,paste,collapse=" ",data=c_merged)

biblio<-merge(biblio,c_agg, by.x= "nid", by.y = "nid", all=TRUE)


# keywords

k_merged<-merge(keyword,k_data, by = "kid", all=TRUE)

k_merged$kid <- NULL

k_agg<-aggregate(word~nid,paste,collapse=", ",data=k_merged)

biblio<-merge(biblio,k_agg, by.x= "nid", by.y = "nid", all=TRUE)

# fixing the column names and merging the journals

# biblio[is.null(biblio)] <- NA

biblio<-transform(biblio,journal=interaction(biblio_secondary_title,biblio_tertiary_title,sep=' '))

biblio$biblio_secondary_title <- NULL
biblio$biblio_tertiary_title <- NULL
colnames(biblio)[1] <- "id"
colnames(biblio)[2] <- "Title"
colnames(biblio)[3] <- "Date"
colnames(biblio)[4] <- "Publisher"
colnames(biblio)[5] <- "Year"
colnames(biblio)[6] <- "Type"
colnames(biblio)[7] <- "Pubmed ID"
colnames(biblio)[8] <- "PMCID"
colnames(biblio)[9] <- "Authors"
colnames(biblio)[10] <- "Keywords"
colnames(biblio)[11] <- "Journal"

biblio<-biblio[c("id","Title","Year","Date","Journal","Publisher","Type","Authors","Keywords","Pubmed ID", "PMCID")]

write.csv(biblio, "BiblioAgg.csv")
