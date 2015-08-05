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

# biblio_types table path - a lookup table for types such as journal, book, thesis 
types_path = "data/biblio_types.csv"

# biblio_contributor table path - a join or juntion table between the biblio and biblio_contributor_data tables
contributor_path = "data/biblio_contributor.csv"

# biblio_contributor_data table path - a lookup table for contributor names 
contributor_data_path = "data/biblio_contributor_data.csv"

# biblio_keyword table path - a join or juntion table between the biblio and biblio_keywords_data tables
keyword_path = "data/biblio_keyword.csv"

# biblio_keyword_data table path - a lookup table for keyword names
keyword_data_path = "data/biblio_keyword_data.csv"

# biblio_pubmed table path - a lookup table for pubmed and pubmed central ids
pubmed_path = "data/biblio_pubmed.csv"


#
# READING THE CSV TABLES INTO DATA FRAMES
#

# biblio table 
biblio<-read.csv(biblio_path, head=TRUE, sep=",")

# biblio_types table
types<-read.csv(types_path, head=TRUE, sep=",")

# biblio_contributor table  
contributor<-read.csv(contributor_path, head=TRUE, sep=",")

# biblio_contributor_data 
contributor_data<-read.csv(contributor_data_path, head=TRUE, sep=",")

# biblio_keywords table
# generally, 1 biblio: many keywords 
keyword<-read.csv(keyword_path, head=TRUE, sep=",")

# biblio_keywords
keyword_data<-read.csv(keyword_data_path, head=TRUE, sep=",")

# biblio_pubmed table 
pubmed<-read.csv(pubmed_path, head=TRUE, sep=",")


#
# ADDING LOOKUP DATA INTO THE BIBLIO TABLE
#

# publication types into biblio table - one-to-one relationship; one biblio to one type   
biblio<-merge(biblio,types, by.x = "biblio_type", by.y = "tid", all=TRUE)
biblio$biblio_type <- NULL

# pubmed PMC ids into biblio table - one-to-one relationship; one biblio to one pubmed AND/OR pmc id.  
biblio<-merge(biblio,pubmed, by.x= "nid", by.y = "nid", all=TRUE)

# contributors into biblio table - one-to-many relatioinship; one biblio to many contributors. 
contributor_merged<-merge(contributor,contributor_data, by = "cid", all=TRUE)

contributor_merged$cid <- NULL

contributor_aggregate<-aggregate(name~nid,paste,collapse=" ",data=contributor_merged)

biblio<-merge(biblio,contributor_aggregate, by.x= "nid", by.y = "nid", all=TRUE)

# keywords into biblio table - one-to-many relatioinship; one biblio to many keywords. It is
keyword_merged<-merge(keyword,keyword_data, by = "kid", all=TRUE)

keyword_merged$kid <- NULL

keyword_aggregate<-aggregate(word~nid,paste,collapse=", ",data=keyword_merged)

biblio<-merge(biblio,keyword_aggregate, by.x= "nid", by.y = "nid", all=TRUE)


#
# FIXING JOURNAL NAMES
#

# the journal name could appear in the field biblio_secondary_title or biblio_tertiary_title so they must be combined into a new column
biblio<-transform(biblio,journal=interaction(biblio_secondary_title,biblio_tertiary_title,sep=' '))

# deleting the old columns
biblio$biblio_secondary_title <- NULL
biblio$biblio_tertiary_title <- NULL


#
# CLEAN UP
#

# Renaming the columns
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
