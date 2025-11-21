# 611 Final Project – Used Car Price Analysis

This project analyzes a used car dataset (`used_cars.csv`) containing information such as model year, mileage, horsepower, fuel type, transmission, color, accident history, and brand. The data includes 4009 rows (sample size) and 12 variables.
The goals of this analysis are to:

- Clean and recode raw used car data  
- Build predictive models for log(price) using:
  - Linear Regression  
  - Lasso Regression  
  - Random Forest 
- Perform correlation analysis for continuous variables  
- Conduct mixed-type clustering (Gower + PAM)
- Visualize model performance and cluster structure
- Ensure full reproducibility through Makefile + Docker

All work is implemented in **`Analysis.R`**.

# 🐳 Running the project in Docker

To build the Docker container for this project, run the following command from the root of the `611_FP` repository:
```bash
docker build -t 611-fp
```
Then, to start an RStudio server inside the container, run:
```bash
docker run -p 8787:8787 -e PASSWORD=rstudio 611-fp
```
Open your browser and go to
```bash
docker run -p 8787:8787 -e PASSWORD=rstudio 611-fp
```

To rerun the full analysis (data cleaning, modeling, clustering, and figure generation), first run:
```bash
make clean
make all
```






