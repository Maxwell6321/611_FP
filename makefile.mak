.PHONY: all clean analysis

# Default target: run the full analysis
all: analysis

# Main analysis: run Analysis.R, which should
# - read used_cars.csv
# - clean data
# - fit models
# - write cleaned_used_cars.csv
# - save any plots under Figures/
analysis: cleaned_used_cars.csv

cleaned_used_cars.csv: used_cars.csv Analysis.R
	mkdir -p Figures
	Rscript Analysis.R

# Clean generated files (but keep source code)
clean:
	rm -rf Figures
	rm -f cleaned_used_cars.csv
