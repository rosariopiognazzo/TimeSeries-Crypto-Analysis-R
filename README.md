# Crypto Currencies Analysis
The following historical series analysis project aims to examine the performance of the three cryptocurrencies with the highest current market capitalization on the digital currency market, comparing them with traditional indices such as the S&P 500 and the price of gold. The S&P 500, which includes the 500 largest companies listed on the US stock exchanges, and gold, considered a safe haven, will allow me to contextualize the behavior of the cryptocurrency series within the economic and financial landscape. The goal is to identify any relationships, recurring patterns and possible trends emerging from financial data over time.

[![View Report](https://img.shields.io/badge/View%20Report-HTML-blue)](https://htmlpreview.github.io/?https://github.com/YOUR_USERNAME/Crypto-TSAnalysis/blob/main/StatisticalAnalysis.html)

---

## Overview

The project is divided into two main phases:

**1. Descriptive & Explanatory Analysis**
- OHLC interactive charts for each asset
- Standardized comparison across all five series
- Dependency analysis: 3D scatterplots, correlation matrices (raw and first-differenced)
- ACF correlograms and monthly seasonal plots for each series

**2. Forecasting & Regression**
- Stationarity achieved via daily log-returns: $r_t = \ln(P_t) - \ln(P_{t-1})$
- White noise verification (Box-Pierce & Ljung-Box tests)
- **Model 1** — Multivariate regression: BNB returns ~ BTC + ETH + Gold + S&P500 returns
- **Model 2** — Univariate regression: BNB price ~ 7-day moving average trend
- Model comparison via LOO cross-validation (RMSE, MAE, CV, AIC, BIC)

---

## Data

| Asset | Ticker | Source |
|---|---|---|
| Bitcoin | `BTC-USD` | Yahoo Finance via `quantmod` |
| Ethereum | `ETH-USD` | Yahoo Finance via `quantmod` |
| Binance Coin | `BNB-USD` | Yahoo Finance via `quantmod` |
| Gold Futures | `GC=F` | Yahoo Finance via `quantmod` |
| S&P 500 | `^GSPC` | Yahoo Finance via `quantmod` |

Period: **November 2017 – January 2024** (daily frequency).

---

## Files

```
Crypto-TSAnalysis/
├── StatisticalAnalysis.Rmd   # Full report with analysis and commentary
├── StatisticalAnalysis.html  # Rendered output (open in browser)
└── analysis.R                # Pure R code, organized by section
```

---

## Requirements

R packages:

```r
install.packages(c(
  "ggplot2", "fpp", "fpp2", "quantmod", "dygraphs",
  "seasonal", "gridExtra", "corrplot", "gplots",
  "scatterplot3d", "reshape2", "imputeTS",
  "glmnet", "caret", "GGally"
))
```

---

## How to Run

**Full report:**
```r
rmarkdown::render("StatisticalAnalysis.Rmd")
```

**Code only:**
```r
source("analysis.R")
```

---

## Viewing the Report on GitHub

Since GitHub does not render HTML files directly, use the link below to preview the report in your browser:

**[https://htmlpreview.github.io/?https://github.com/YOUR_USERNAME/Crypto-TSAnalysis/blob/main/StatisticalAnalysis.html](https://htmlpreview.github.io/?https://github.com/YOUR_USERNAME/Crypto-TSAnalysis/blob/main/StatisticalAnalysis.html)**
