# confirm one path for package library
.libPaths()

# review installed packages
rownames(installed.packages())

# install a group of packages from CRAN
packages <- c("ggplot2", "reshape2", "unbalanced")

for (p in packages) {
	if (!(p %in% rownames(installed.packages()))){
		install.packages(p)
		}
	}
	
#use this instead for a local copy of packages (in C:\PackageDownload)
#install.packages ("C:\\PackageDownload\\mypackage.zip", repos=NULL)