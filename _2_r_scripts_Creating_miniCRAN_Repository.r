# install the packages necessary to create a local miniCRAN repository
if (!require("miniCRAN"))
    install.packages("miniCRAN")
if (!require("igraph"))
    install.packages("igraph")
library(miniCRAN)
library(igraph)

# define a mirror source for the packages to get
myMirror <- c(CRAN = "https://cloud.r-project.org/")

# be sure to create a folder for the packages and define the location here
dir.create(pth <- file.path("C:\\demos\\miniCRAN-repos"))
myRepos <- "C:\\demos\\miniCRAN-repos"



# define a vector to hold packages to get 
pkgs_to_get <- c("ggplot2", "reshape2", "unbalanced")

# review the package dependencies (uses igraph package)
plot(makeDepGraph(pkgs_to_get))

# Get dependencies
pkgs <- pkgDep(pkgs_to_get, repos = myMirror)


# create the local repository 
makeRepo(pkgs,
         path = myRepos,
         repos = myMirror,
         type = "win.binary")

