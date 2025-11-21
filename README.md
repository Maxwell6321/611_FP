# 611 Final Project – Used Car Price Analysis

This project analyzes a used car dataset (`used_cars.csv`) containing information such as model year, mileage, horsepower, fuel type, transmission, color, accident history, and brand.  
The goals of this analysis are to:

- Clean and recode raw used car data  
- Build predictive models for log(price) using:
  - Linear Regression  
  - Lasso Regression  
  - Random Forest (10-fold CV via `caret`)
- Perform correlation analysis for continuous variables  
- Conduct mixed-type clustering (Gower + PAM)
- Visualize model performance and cluster structure
- Ensure full reproducibility through Makefile + Docker

All work is implemented in **`Analysis.R`**.

---

## 📁 Project Structure
.
├── Analysis.R # Main script: cleaning, modeling, clustering, plots
├── used_cars.csv # Raw dataset
├── cleaned_used_cars.csv # Generated dataset (auto-created)
├── Figures/ # Auto-created directory for plots
├── Makefile # Reproducible build
├── Dockerfile # Docker environment
└── README.md # Documentation





