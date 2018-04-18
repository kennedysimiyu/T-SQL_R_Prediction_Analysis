# Be sure to create r_demos database and grant user permissions firs
# Set the working directory for the demo data
wd <- "C:\\demos"

# Define variables
##  connection to SQL Server and table to load - UPDATE YOUR SERVER NAME
#sqlConnString <- "Driver=SQL Server;Server=<server>;Database=r_demos;Trusted_Connection={Yes}"
sqlConnString <- "Driver=SQL Server;Server=disql01;Database=r_demos;Trusted_Connection={Yes}"
cdrTable <- "cdr"

# Set data source object for source file
cdrCSV <- RxTextData(file.path(wd, "edw_cdr.csv"))

# Define the column list to get data types and factors set correctly for the SQL Server data source object (created in the next step)
cdrColInfo <- list(age = list(type = "integer"),
                   annualincome = list(type = "integer"),
                   calldroprate = list(type = "numeric"),
                   callfailurerate = list(type = "numeric"),
                   callingnum = list(type = "numeric"),
                   customerid = list(type = "integer"),
                   customersuspended = list(type = "factor", levels = c("No", "Yes")),
                   education = list(type = "factor", levels = c("Bachelor or equivalent", "High School or below", "Master or equivalent", "PhD or equivalent")),
                   gender = list(type = "factor", levels = c("Female", "Male")),
                   homeowner = list(type = "factor", levels = c("No", "Yes")),
                   maritalstatus = list(type = "factor", levels = c("Married", "Single")),
                   monthlybilledamount = list(type = "integer"),
                   noadditionallines = list(type = "factor", levels = c("\\N")),
                   numberofcomplaints = list(type = "factor", levels = as.character(0:3)),
                   numberofmonthunpaid = list(type = "factor", levels = as.character(0:7)),
                   numdayscontractequipmentplanexpiring = list(type = "integer"),
                   occupation = list(type = "factor", levels = c("Non-technology Related Job", "Others", "Technology Related Job")),
                   penaltytoswitch = list(type = "integer"),
                   state = list(type = "factor", levels = c("AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "IA", "ID",
                                                            "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV",
                                                            "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY")),
                   totalminsusedinlastmonth = list(type = "integer"),
                   unpaidbalance = list(type = "integer"),
                   usesinternetservice = list(type = "factor", levels = c("No", "Yes")),
                   usesvoiceservice = list(type = "factor", levels = c("No", "Yes")),
                   percentagecalloutsidenetwork = list(type = "numeric"),
                   totalcallduration = list(type = "integer"),
                   avgcallduration = list(type = "integer"),
                   churn = list(type = "integer"),
                   year = list(type = "factor", levels = as.character(2015)),
                   month = list(type = "factor", levels = as.character(1:3)))

# Set data source object for SQL Server table (not created yet)
cdrSQL <- RxSqlServerData(connectionString = sqlConnString,
                          table = cdrTable,
                          colInfo = cdrColInfo)

# Load CSV data into SQL Server table
rxDataStep(inData = cdrCSV, outFile = cdrSQL, overwrite = TRUE)

# Review metadata
rxGetInfo(data = cdrSQL, getVarInfo = TRUE)
rxGetVarInfo(data = cdrSQL)

# Output metadata to a variable
cdrDataDictionary <- rxGetVarInfo(data = cdrSQL)
cdrDataDictionary$gender
cdrDataDictionary$state


# Review summary statistics
rxSummary(~., data = cdrSQL)
rxSummary(~annualincome:education, data = cdrSQL)
rxSummary(~annualincome:F(age), data = cdrSQL)
rxSummary(~annualincome:F(age, low = 25, high = 44), data = cdrSQL,
          rowSelection = age >= 25 & age < 45)
rxSummary(~annualincome:F(age, low = 25, high = 44), data = cdrSQL)

# Output summary data to a variable (list object) and then review elements of the list
cdrSummary <- rxSummary(~., data = cdrSQL)
cdrSummaryDF <- cdrSummary$sDataFrame
cdrSummary$categorical
cdrSummary$params

# Output specified summary data to XDF file
rxSummary(~annualincome:F(age), data = cdrSQL,
          byGroupOutFile = "incomeByAge.xdf",
          overwrite = TRUE)

# Read data from XDF file
rxGetInfo("incomeByAge.xdf", numRows = 5)

# Plot data from XDF file
rxLinePlot(annualincome_Mean ~ F_age, data = "incomeByAge.xdf")

# Copy data from SQL Server to local data frame
cdrDF <- rxImport(cdrSQL)

# Even with compute context set to SQL Server, calls to non-RevoScaleR functions require 
# local package installation - you'll see prompt for personal library first time
# confirm library paths with .libPaths()
if (!("ggplot2" %in% rownames(installed.packages()))) {
  install.packages("ggplot2")
}

library(ggplot2)

# Plot data using local data frame
ggplot(cdrDF, aes(x = factor(1),
                  fill = factor(churn))) +
  geom_bar(width = 1) +
  #coord_polar(theta="y") +
  theme_minimal()

# Set variables for compute context
sqlWait <- TRUE
sqlConsoleOutput <- FALSE
sqlShareDir <- paste("c:\\demos\\", Sys.getenv("USERNAME"), sep = "")
sqlCompute <- RxInSqlServer(
  connectionString = sqlConnString,
  wait = sqlWait,
  consoleOutput = sqlConsoleOutput)

# Check the compute context
rxGetComputeContext()

# Change the compute context to SQL Server
rxSetComputeContext(sqlCompute)

# Check the compute context
rxGetComputeContext()

# Generate histogram using SQL Server resources
rxHistogram(~age, data = cdrSQL)
rxHistogram(~annualincome, data = cdrSQL)
rxHistogram(~calldroprate, data = cdrSQL)

# Exploring the data through histograms by each table column manually is tedious 
# Create a function to loop through the columns 
histograms <-
  lapply(names(cdrSQL),
         function(index)
           eval(parse(text = paste("rxHistogram(~",
                                   index,
                                   ", data=cdrSQL)",
                                   sep = "")
           ))
  )

# Create a query to pre-summarize the data for local analysis - churn by month and education
sqlQueryText <- "SELECT [month], [education], SUM([churn]) as churncount
FROM [cdr]
GROUP BY [month], [education];"

# Set up a data source object based on the new query
cdrMonthChurnEdDS <- RxSqlServerData(
  sqlQuery = sqlQueryText,
  connectionString = sqlConnString
)

# Import the data from SQL Server to a local data frame
cdrMonthChurnEdDF <- rxImport(cdrMonthChurnEdDS)

# Now plot the data frame
ggplot(cdrMonthChurnEdDF,
       aes(x = month, y = churncount,
           group = education, fill = education)) +
  geom_bar(stat = "identity",
           position = position_dodge()) +
  labs(x = "month", y = "churn count") +
  theme_minimal()

# Create a new  query to pre-summarize the data for local analysis - churn by month and call failure rate
sqlQueryText <- "SELECT [month], [callfailurerate], SUM([churn]) as churncount
FROM [cdr]
GROUP BY [month], [callfailurerate];"

# Set up a data source object based on the new query
cdrMonthChurnCFRDS <- RxSqlServerData(
  sqlQuery = sqlQueryText,
  connectionString = sqlConnString
)

# Import the data from SQL Server to a local data frame
cdrMonthChurnCFRDF <- rxImport(cdrMonthChurnCFRDS)

# Plot the data frame
ggplot(cdrMonthChurnCFRDF,
       aes(x = month, y = churncount,
           group = factor(callfailurerate), fill = factor(callfailurerate))) +
  geom_bar(stat = "identity",
           position = position_dodge()) +
  labs(x = "month", y = "churn count") +
  theme_minimal()

# Find the numeric columns and create a data frame 
numeric_cols <- sapply(cdrDF, is.numeric)
if (!("reshape2" %in% rownames(installed.packages()))) {
  install.packages("reshape2")
}
library("reshape2")
cdrpivot <- melt(cdrDF[, numeric_cols], id.vars = c("churn"))

ggplot(aes(x = value,
           group = churn,
           color = factor(churn)),
       data = cdrpivot) +
  geom_density() +
  facet_wrap(~variable, scales = "free")
