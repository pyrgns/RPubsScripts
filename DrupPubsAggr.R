# 
# This script collapses and merges database tables from Drupal publications
# into a aggregate human readable .csv file that can be queryied with SAS or 
# R or other statistical computing software
# 


#
# CONFIGURATION
#

# your working directory path
working_directory = "/Users/pdy/code/R/Publications/RPubsScripts"

# setting the working directory
setwd(file.path(working_directory))

# setting the path to the csv of the main biblio table
biblio_path = "data/biblio.csv"

# biblio_types table path ie journal article, book, dissertation
types_path = "data/biblio_types.csv"

# biblio_contributor table path  
contributor_path = "data/biblio_contributor.csv"

# biblio_contributor_data table path
contributor_data_path = "data/biblio_contributor_data.csv"

# biblio_keyword table path
keyword_path = "data/biblio_keyword.csv"

# biblio_keyword_data table path
keyword_data_path = "data/biblio_keyword_data.csv"

# biblio_pubmed table path
pubmed_path = "data/biblio_pubmed.csv"

#
# READING THE CSV TABLES INTO DATA FRAMES
#

# biblio table 
biblio<-read.csv(biblio_path, head=TRUE, sep=",")

# biblio_types table, a lookup table for types such as journal, book, thesis 
# There is a a one biblio : one type relationship 
types<-read.csv(types_path, head=TRUE, sep=",")

# biblio_contributor table, a join or juntion table between the biblio and biblio_contributor_data tables
# Generally, there is a one one biblio : many contributors relatioinshipo 
contributor<-read.csv(contributor_path, head=TRUE, sep=",")

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

# Merging publication types into the biblio table - ONE TO ONE RELATIONSHIPS 

biblio<-merge(biblio,types, by.x = "biblio_type", by.y = "tid", all=TRUE)

# Merging pubmed PMC id's into biblio table
biblio<-merge(biblio,pubmed, by.x= "nid", by.y = "nid", all=TRUE)

# MERGING AND COLLAPSING KEYWORDS AND CONTRIBUTORS THEN MERGING INTO BIBLIO - MOST LIKELY TO TO BE ONE TO MANY RELATIONSHIPS

# contributor

contributor_merged<-merge(contributor,contributor_data, by = "cid", all=TRUE)

contributor_merged$cid <- NULL

contributor_aggregate<-aggregate(name~nid,paste,collapse=" ",data=contributor_merged)

biblio<-merge(biblio,contributor_aggregate, by.x= "nid", by.y = "nid", all=TRUE)

# keywords

keyword_merged<-merge(keyword,keyword_data, by = "kid", all=TRUE)

keyword_merged$kid <- NULL

keyword_aggregate<-aggregate(word~nid,paste,collapse=", ",data=keyword_merged)

biblio<-merge(biblio,keyword_aggregate, by.x= "nid", by.y = "nid", all=TRUE)

# Merging the two columns that could contain the journal name
biblio<-transform(biblio,journal=interaction(biblio_secondary_title,biblio_tertiary_title,sep=' '))


#
# CLEAN UP
#


# Renaming the columns
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

# Reordering the columns
biblio<-biblio[c("id","Title","Year","Date","Journal","Publisher","Type","Authors","Keywords","Pubmed ID", "PMCID")]


#
# EXPORT
#

write.csv(biblio, "DrupalBiblioAggregate.csv")
