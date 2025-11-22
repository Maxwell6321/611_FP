# 611 Final Project – Used Car Price Analysis

This project analyzes a used car dataset (`used_cars.csv`) containing information such as model year, mileage, horsepower, fuel type, transmission, color, accident history, and brand. The data includes 4009 observations and 12 variables.
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
docker build -t 611-fp .
```
Then, to start an RStudio server inside the container, run:
```bash
docker run -p 8787:8787 -e PASSWORD=Shuai611 611-fp
```
Open your browser and go to:
```text
http://localhost:8787
```

## 🖥 Running locally without Docker

If you already have R and the required packages installed, you can run the analysis directly from the terminal.

From the root of the `611_FP` repository:

```bash
make clean
make all
```

## 🖥 Running on MacOS

If you are using M1/M2 chips, run: 
```bash
docker build --platform linux/amd64 -t 611-fp .
docker run --rm --platform linux/amd64 -v "$(pwd)":/home/rstudio/611_FP 611-fp make clean
docker run --rm --platform linux/amd64 -v "$(pwd)":/home/rstudio/611_FP 611-fp make all
```





