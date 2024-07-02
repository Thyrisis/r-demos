options(repos ='https://cran.r-project.org/'
, unzip = 'internal'
, download.file.method ='libcurl'
, Ncpus = parallel::detectCores())
install.packages('requiRements')
requiRements::install(c('tidyverse', 'data.table', 'gt', 'keyring', 'odbc', 'paws', 'reticulate', 'sf', 'slider', 'webshot2'
, 'tidyquant', 'geomtextpath', 'bbc/bbplot@master', 'janitor', 'Hmisc'))
