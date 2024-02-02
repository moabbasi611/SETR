## Install SETR or other packages from moabbasi611 github repos
devtools::install_github("moabbasi611/SETR",
                         ref="master",
                         auth_token = "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", force =T)


## Rscript for deploying shiny app.
library(rsconnect)


## set repos to use bioconductorr based on https://community.rstudio.com/t/failing-to-deploy-shinyapp-depending-on-bioconductor-packages/6970/2
r <- getOption("repos")
r["BioCsoft"] <- "https://bioconductor.org/packages/3.16/bioc"
r["BioCann"] <- "https://bioconductor.org/packages/3.16/data/annotation"
r["BioCexp"] <- "https://bioconductor.org/packages/3.16/data/experiment"
r["BioCextra"] <- "https://bioconductor.org/packages/3.16/bioc"
r["CRAN"] <- "https://cloud.r-project.org/"
r["CRANextra"] <- "https://www.stats.ox.ac.uk/pub/RWin"

options(repos = r)
rm(r)
