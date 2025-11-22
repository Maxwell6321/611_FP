library(ggplot2)
library(dplyr)
library(tidyr)
library(caret)
library(readr)
library(xgboost)
library(stringr)
library(randomForest)
library(glmnet)
library(reshape2)
library(cluster)
library(elasticnet)
dat <- read_csv("used_cars.csv")

## Data Cleaning
dat$model_year <- as.integer(dat$model_year)
dat$milage <- as.integer(gsub("[^0-9]", "", dat$milage))
dat <- dat %>%
  filter(!fuel_type %in% c("–", "not supported")) %>%
  mutate(
    fuel_type = ifelse(fuel_type %in% c("Hybrid", "Plug-In Hybrid"),
                       "Hybrid", fuel_type),
    fuel_type = factor(fuel_type)
  )
table(dat$fuel_type)

dat$HP <- as.numeric(str_extract(dat$engine, "(?i)[0-9]+\\.?[0-9]*\\s*(?=HP)"))

dat <- dat %>%
  filter(!fuel_type %in% c("–", "not supported")) %>%
  mutate(
    fuel_type = case_when(
      fuel_type %in% c("Gasoline", "E85 Flex Fuel") ~ "Gasoline",
      fuel_type %in% c("Hybrid", "Plug-In Hybrid") ~ "Hybrid",
      fuel_type == "Diesel" ~ "Diesel",
      TRUE ~ NA_character_
    ),
    fuel_type = factor(fuel_type)
  )

dat <- dat %>%
  mutate(
    tr_low = tolower(transmission),
    transmission = case_when(
      tr_low %in% c("–", "") ~ NA_character_,
      grepl("cvt", tr_low) |
        grepl("variable", tr_low) ~ "CVT",
      grepl("manual", tr_low) |
        grepl("m/t", tr_low) ~ "Manual",
      grepl("automatic", tr_low) |
        grepl("a/t", tr_low) ~ "Automatic",
      TRUE   ~ "Automatic" 
    ),
    transmission = factor(transmission)
  )

dat <- dat %>%
  mutate(
    ext_low = tolower(ext_col),
    ext_color = case_when(
      ext_low %in% c("–", "") ~ NA_character_,
      grepl("black", ext_low) ~ "Black",
      grepl("white", ext_low) ~ "White",
      grepl("silver|grey|gray|graphite|platinum|stone", ext_low) ~ "Silver/Gray",
      grepl("blue", ext_low) ~ "Blue",
      grepl("red|maroon|crimson|ruby", ext_low) ~ "Red",
      grepl("green", ext_low)  ~ "Green",
      grepl("brown|bronze|copper", ext_low) ~ "Brown",
      grepl("beige|sand|ivory|cream|tan", ext_low)  ~ "Beige/Tan",
      grepl("yellow|gold", ext_low) ~ "Yellow/Gold",
      grepl("orange", ext_low) ~ "Orange",
      grepl("purple", ext_low) ~ "Purple",
      TRUE  ~ "Other"
    ),
    ext_color = factor(ext_color)
  )

min_count <- 50
color_count <- table(dat$ext_color)
small_colors <- names(color_count[color_count < min_count])

dat <- dat %>%
  mutate(
    ext_color = ifelse(ext_color %in% small_colors, "Other", as.character(ext_color)),
    ext_color = factor(ext_color)
  )

dat <- dat %>%
  mutate(
    int_low = tolower(int_col),
    int_color = case_when(
      int_low %in% c("–", "") ~ NA_character_,
      grepl("black|ebony|noir", int_low) ~ "Black",
      grepl("gray|grey|granite|graphite|slate|stone",int_low) ~ "Gray",
      grepl("beige|sand|ivory|cream|parchment|tan|camel|macchiato", int_low) ~ "Beige/Tan",
      grepl("brown|brandy|chestnut|saddle|mocha|walnut|nougat", int_low) ~ "Brown",
      grepl("red|crimson|pimento|burgundy", int_low) ~ "Red",
      grepl("white", int_low) ~ "White",
      TRUE ~ "Other"
    ),
    int_color = factor(int_color)
  )

dat <- dat %>%
  mutate(
    accident = ifelse(
      accident == "At least 1 accident or damage reported",
      "Accident", "NoAccident"
    ),
    accident = factor(accident, levels = c("NoAccident", "Accident"))
  )

dat$price <- as.numeric(gsub("[$,]", "", dat$price))
dat$log_price <- log(dat$price)


brand_price <- dat %>%
  group_by(brand) %>%
  summarize(brand_med_price = median(price))

dat <- dat %>%
  left_join(brand_price, by = "brand")

dat$brand_tier <- cut(
  dat$brand_med_price,
  breaks = quantile(dat$brand_med_price, probs = c(0, 0.25, 0.5, 0.75, 1)),
  labels = c("Economy", "MidRange", "Premium", "UltraLuxury"),
  include.lowest = TRUE
)

dat <- dat %>%
  select(
    brand_tier,
    model_year,    
    milage,        
    fuel_type,
    HP,             
    transmission,   
    ext_color,      
    int_color,    
    accident, 
    log_price    
  ) %>%
  drop_na()

write.csv(dat,"cleaned_used_cars.csv")

## Predictions 
## Linear Regression Model
set.seed(123)
ctrl <- trainControl(method = "cv", number = 10)
fit_lm <- train(log_price ~ ., data = as.data.frame(dat), method = "lm", trControl = ctrl)
fit_lasso <- train(log_price ~ ., data = as.data.frame(dat), method = "lasso", trControl = ctrl, tuneLength = 5)
fit_rf <- train(log_price ~ ., data = as.data.frame(dat), method = "rf", trControl = ctrl, tuneLength = 5)

resamps <- resamples(list(
  LM = fit_lm,
  Lasso = fit_lasso,
  RF = fit_rf
))

summary(resamps)    
bwplot(resamps, metric="MAE")  
bwplot(resamps, metric="RMSE")  
bwplot(resamps, metric="Rsquared")

## Correlation Analysis and Clustering
cont_vars <- c("milage", "model_year", "HP", "log_price")
cat_vars  <- c("fuel_type", "transmission", "ext_color", "int_color", "accident", "brand_tier")

cor_mat <- cor(dat[, cont_vars], use = "complete.obs")
cor_long <- melt(cor_mat)

ggplot(cor_long, aes(x = Var1, y = Var2, fill = value)) +
  geom_tile() +
  scale_fill_gradient2(
    low = "blue", high = "red", mid = "white",
    midpoint = 0, limit = c(-1, 1)
  ) +
  theme_minimal() +
  labs(
    title = "Correlation Heatmap (Continuous Variables)",
    x = "", y = "", fill = "corr"
  )

gower_dist <- daisy(dat, metric = "gower")

sil_width <- numeric(9)
for (k in 2:10) {
  pam_fit <- pam(gower_dist, k = k)
  sil_width[k - 2] <- pam_fit$silinfo$avg.width
}
print(sil_width)

set.seed(123)
pam_fit <- pam(gower_dist, k = 5)
dat$cluster <- factor(pam_fit$clustering)
table(dat$cluster)

ggplot(dat, aes(x = milage, y = log_price, color = cluster)) +
  geom_point(alpha = 0.6) +
  labs(
    title = "Gower + PAM Clusters (k = 5)",
    x = "Milage",
    y = "log(Price)"
  ) +
  theme_minimal()

ggplot(dat, aes(x = HP, y = log_price, color = cluster)) +
  geom_point(alpha = 0.6) +
  theme_minimal() +
  labs(
    title = "Gower + PAM Clusters (k = 5)",
    x = "HP",
    y = "log(Price)"
  )

ggplot(dat, aes(x = model_year, y = log_price, color = cluster)) +
  geom_point(alpha = 0.6) +
  theme_minimal() +
  labs(
    title = "Gower + PAM Clusters (k = 5)",
    x = "Model_year",
    y = "log(Price)"
  )