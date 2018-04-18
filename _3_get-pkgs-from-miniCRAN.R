# Copy folder containing miniCRAN repository to target server
# Get path for instance library
lib <- .libPaths()[1]

# Define the location of the miniCRAN repository
server_Repos <- "C:\\demos\\miniCRAN-repos"

# Define the packages to install as a comma-separated list in a vector
pkgs_to_install <- c("ggplot2")

# Install the packages from the local miniCRAN
install.packages(pkgs_to_install,
                 repos = file.path("file://",
                            normalizePath(server_Repos, winslash = "/")
                            ),
                 lib = lib,
                 type = "win.binary",
                 dependencies = TRUE)

# Confirm installation
rownames(installed.packages())