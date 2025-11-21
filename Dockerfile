FROM rocker/verse

# Install make
RUN apt-get update && \
    apt-get install -y make && \
    rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c( \
  'ggplot2', 'dplyr', 'tidyr', 'caret', 'readr', \
  'xgboost', 'stringr', 'randomForest', 'glmnet', \
  'reshape2', 'cluster' \
  ), dependencies = TRUE)"

# WORKING DIRECTORY
WORKDIR /home/rstudio/611_FP

# Copy file into docker
COPY Analysis.R Makefile used_cars.csv README.md ./
