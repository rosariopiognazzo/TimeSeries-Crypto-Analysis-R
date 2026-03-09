# =============================================================================
# Cryptocurrency Time Series Analysis
# =============================================================================

# --- Libraries ----------------------------------------------------------------
library(ggplot2)
library(fpp)
library(quantmod)
library(dygraphs)
library(seasonal)
library(gridExtra)
library(corrplot)
library(gplots)
library(scatterplot3d)
library(reshape2)
library(imputeTS)
library(fpp2)
library(glmnet)
library(caret)

# =============================================================================
# SECTION 1: DATA LOADING
# =============================================================================

BTC_USD <- getSymbols("BTC-USD", auto.assign = FALSE)
BTC_USD <- window(BTC_USD, end = as.Date("2024-01-01"))
btc_data <- BTC_USD[, c("BTC-USD.Adjusted")]

ETH_USD <- getSymbols("ETH-USD", auto.assign = FALSE)
ETH_USD <- window(ETH_USD, end = as.Date("2024-01-01"))
eth_data <- ETH_USD[, c("ETH-USD.Adjusted")]

BNB_USD <- getSymbols("BNB-USD", auto.assign = FALSE)
BNB_USD <- window(BNB_USD, end = as.Date("2024-01-01"))
bnb_data <- BNB_USD[, c("BNB-USD.Adjusted")]

GOLD <- getSymbols("GC=F", auto.assign = FALSE)
GOLD <- window(GOLD, start = as.Date("2017-11-09"), end = as.Date("2024-01-02"))
gold_data <- GOLD[, c("GC=F.Adjusted")]

SP500 <- getSymbols("^GSPC", auto.assign = FALSE)
SP500 <- window(SP500, start = as.Date("2017-11-09"), end = as.Date("2024-01-02"))
sp500_data <- SP500[, c("GSPC.Adjusted")]

# =============================================================================
# SECTION 2: OHLC TIME SERIES PLOTS
# =============================================================================

dygraph(BTC_USD[, c("BTC-USD.Open", "BTC-USD.High", "BTC-USD.Low", "BTC-USD.Adjusted")],
        main = "BTC-USD Time Series & Daily log-returns") %>%
  dyCandlestick() %>%
  dyLegend(width = 200) %>%
  dyEvent("2016-07-09", "II Halving", labelLoc = "bottom") %>%
  dyEvent("2020-05-11", "III Halving", labelLoc = "bottom") %>%
  dyEvent("2024-04-20", "IV Halving", labelLoc = "bottom") %>%
  dyRangeSelector(height = 20)

dygraph(ETH_USD[, c("ETH-USD.Open", "ETH-USD.High", "ETH-USD.Low", "ETH-USD.Adjusted")],
        main = "ETH-USD Time Series & Daily log-returns") %>%
  dyCandlestick() %>%
  dyLegend(width = 200) %>%
  dyRangeSelector(height = 20)

dygraph(BNB_USD[, c("BNB-USD.Open", "BNB-USD.High", "BNB-USD.Low", "BNB-USD.Adjusted")],
        main = "BNB-USD Time Series & Daily log-returns") %>%
  dyCandlestick() %>%
  dyLegend(width = 200) %>%
  dyRangeSelector(height = 20)

dygraph(GOLD[, c("GC=F.Open", "GC=F.High", "GC=F.Low", "GC=F.Adjusted")],
        main = "GOLD Time Series") %>%
  dyCandlestick() %>%
  dyRangeSelector(height = 20)

dygraph(SP500[, c("GSPC.Open", "GSPC.High", "GSPC.Low", "GSPC.Adjusted")],
        main = "S&P500 Time Series") %>%
  dyCandlestick() %>%
  dyRangeSelector(height = 20)

# =============================================================================
# SECTION 3: DATA MERGING & MISSING VALUE IMPUTATION
# =============================================================================

btc_data <- subset(btc_data, index(btc_data) >= "2017-11-09")

data <- cbind(btc_data, eth_data, bnb_data, gold_data, sp500_data)

gold_r <- na_interpolation(data$GC.F.Adjusted)
sp500_r <- na_interpolation(data$GSPC.Adjusted)

data$GC.F.Adjusted  <- gold_r
data$GSPC.Adjusted  <- sp500_r

data <- subset(data, index(data) <= "2024-01-01")
colnames(data) <- c("BTC.USD.Adjusted", "ETH.USD.Adjusted", "BNB.USD.Adjusted",
                    "GOLD.USD.Adjusted", "SP500.USD.Adjusted")

# =============================================================================
# SECTION 4: STANDARDIZED COMPARISON PLOT
# =============================================================================

standardized_bnb   <- scale(data$BTC.USD.Adjusted)
standardized_eth   <- scale(data$ETH.USD.Adjusted)
standardized_btc   <- scale(data$BNB.USD.Adjusted)
standardized_gold  <- scale(data$GOLD.USD.Adjusted)
standardized_sp500 <- scale(data$SP500.USD.Adjusted)

cryptoScale <- cbind(standardized_btc, standardized_eth, standardized_bnb,
                     standardized_gold, standardized_sp500)

dygraph(cryptoScale, main = "Time Series Comparison (Rescaled)") %>%
  dySeries("BTC.USD.Adjusted", label = "BTC-USD",  color = "red")   %>%
  dySeries("ETH.USD.Adjusted", label = "ETH-USD",  color = "blue")  %>%
  dySeries("BNB.USD.Adjusted", label = "BNB-USD",  color = "green") %>%
  dySeries("GOLD.USD.Adjusted",  label = "GOLD-USD",  color = "gold")  %>%
  dySeries("SP500.USD.Adjusted", label = "SP500-USD", color = "brown")

# =============================================================================
# SECTION 5: DEPENDENCY ANALYSIS
# =============================================================================

crypto <- cbind(data$BTC.USD.Adjusted, data$ETH.USD.Adjusted, data$BNB.USD.Adjusted)
colnames(crypto) <- c("BTC", "ETH", "BNB")

scatterplot3d(crypto$BTC, crypto$BNB, crypto$ETH,
              xlab = "BTC", ylab = "BNB", zlab = "ETH",
              color = "black", cex.symbols = 0.5, main = "Scatterplot 3D")

cor(crypto, use = "complete.obs")

cryptodiff <- cbind(diff(crypto$BTC)[-1], diff(crypto$ETH)[-1], diff(crypto$BNB)[-1])
colnames(cryptodiff) <- c("BTC", "ETH", "BNB")

p7 <- ggplot(as.data.frame(cryptodiff), aes(BTC, ETH)) +
  geom_point() + ggtitle("Scatterplot BTC - ETH") + theme_bw()
p8 <- ggplot(as.data.frame(cryptodiff), aes(BTC, BNB)) +
  geom_point() + ggtitle("Scatterplot BTC - BNB") + theme_bw()
p9 <- ggplot(as.data.frame(cryptodiff), aes(ETH, BNB)) +
  geom_point() + ggtitle("Scatterplot ETH - BNB") + theme_bw()

corr_matrix <- cor(cryptodiff, use = "complete.obs")
corr_df <- melt(corr_matrix)

p10 <- ggplot(data = corr_df, aes(Var1, Var2)) +
  geom_tile(aes(fill = value), color = "white") +
  geom_text(aes(label = round(value, 2)), color = "black") +
  scale_fill_gradient2(low = "red", mid = "white", high = "blue",
                       midpoint = 0.2, limits = c(-1, 1)) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Correlation Matrix", x = NULL, y = NULL) +
  coord_fixed()

grid.arrange(p7, p8, p9, p10, ncol = 2, nrow = 2)

GGally::ggpairs(as.data.frame(data)) + theme_bw()

datadiff <- cbind(diff(data$BTC.USD.Adjusted)[-1], diff(data$ETH.USD.Adjusted)[-1],
                  diff(data$BNB.USD.Adjusted)[-1], diff(data$GOLD.USD.Adjusted)[-1],
                  diff(data$SP500.USD.Adjusted)[-1])
colnames(datadiff) <- c("BTC", "ETH", "BNB", "GOLD", "S&P500")
GGally::ggpairs(as.data.frame(datadiff)) + theme_bw()

# =============================================================================
# SECTION 6: ACF & SEASONAL PLOTS
# =============================================================================

plot_acf <- function(data, titolo) {
  cryptoAcf <- ggAcf(data, lag.max = 365, plot = FALSE)
  ci <- 1.96 / sqrt(length(data))

  df <- data.frame(lag = cryptoAcf$lag[2:length(cryptoAcf$lag)],
                   acf = cryptoAcf$acf[2:length(cryptoAcf$acf)])

  df$multipli <- ifelse(
    df$lag %% 7 == 0 & df$lag %% 30 == 0, "Multiples of 7 and 30",
    ifelse(df$lag %% 7 == 0, "Multiples of 7",
           ifelse(df$lag %% 30 == 0, "Multiples of 30", "None")))

  ggplot(df, aes(lag, acf, fill = multipli)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.5) +
    geom_hline(yintercept = c(-ci, ci), linetype = "dashed", color = "#00008B") +
    xlab("lag") + ylab("ACF") +
    ggtitle(titolo) + theme_bw() +
    scale_fill_manual(values = c("blue", "green", "red", "#D3D3D3"),
                      labels = c("Multiples of 7 and 30", "Multiples of 7",
                                 "Multiples of 30", "None"),
                      name = NULL) +
    theme(legend.position = "bottom", legend.key.size = unit(0.5, "lines"))
}

btcMonth <- apply.monthly(btc_data, FUN = median)
p1 <- ggseasonplot(ts(btcMonth, frequency = 12), polar = TRUE) +
  ggtitle("BTC-USD\nMonthly polar seasonal plot") + theme_bw()
p2 <- ggsubseriesplot(ts(btcMonth, frequency = 12)) +
  ggtitle("BTC-USD\nMonthly seasonal subseries plot") + ylab("") + theme_bw()
plot_acf(btc_data, "Bitcoin - ACF plot")
grid.arrange(p1, p2, ncol = 2)

ethMonth <- apply.monthly(eth_data, FUN = median)
p3 <- ggseasonplot(ts(ethMonth, frequency = 12), polar = TRUE) +
  ggtitle("ETH-USD\nMonthly polar seasonal plot") + theme_bw()
p4 <- ggsubseriesplot(ts(ethMonth, frequency = 12)) +
  ggtitle("ETH-USD\nMonthly seasonal subseries plot") + ylab("") + theme_bw()
plot_acf(eth_data, "Ethereum - ACF plot")
grid.arrange(p3, p4, ncol = 2)

bnbMonth <- apply.monthly(bnb_data, FUN = median)
p5 <- ggseasonplot(ts(bnbMonth, frequency = 12), polar = TRUE) +
  ggtitle("BNB-USD\nMonthly polar seasonal plot") + theme_bw()
p6 <- ggsubseriesplot(ts(bnbMonth, frequency = 12)) +
  ggtitle("BNB-USD\nMonthly seasonal subseries plot") + ylab("") + theme_bw()
plot_acf(bnb_data, "Binance Coin - ACF plot")
grid.arrange(p5, p6, ncol = 2)

goldMonth <- apply.monthly(gold_data, FUN = median)
p11 <- ggseasonplot(ts(goldMonth, frequency = 12), polar = TRUE) +
  ggtitle("GOLD-USD\nMonthly polar seasonal plot") + theme_bw()
p12 <- ggsubseriesplot(ts(goldMonth, frequency = 12)) +
  ggtitle("GOLD-USD\nMonthly seasonal subseries plot") + ylab("") + theme_bw()
plot_acf(gold_data, "GOLD - ACF plot")
grid.arrange(p11, p12, ncol = 2)

sp500Month <- apply.monthly(sp500_data, FUN = median)
p13 <- ggseasonplot(ts(sp500Month, frequency = 12), polar = TRUE) +
  ggtitle("S&P 500\nMonthly polar seasonal plot") + theme_bw()
p14 <- ggsubseriesplot(ts(sp500Month, frequency = 12)) +
  ggtitle("S&P 500\nMonthly seasonal subseries plot") + ylab("") + theme_bw()
plot_acf(sp500_data, "S&P 500 - ACF plot")
grid.arrange(p13, p14, ncol = 2)

# =============================================================================
# SECTION 7: DAILY LOG-RETURNS DECOMPOSITION
# =============================================================================

returnsBTC  <- diff(log(data$BTC.USD.Adjusted))[-1]
returnsETH  <- diff(log(data$ETH.USD.Adjusted))[-1]
returnsBNB  <- diff(log(data$BNB.USD.Adjusted))[-1]
returnsGOLD <- diff(log(data$GOLD.USD.Adjusted))[-1]
returnsSP500 <- diff(log(data$SP500.USD.Adjusted))[-1]

returns <- cbind(returnsBTC, returnsETH, returnsBNB, returnsGOLD, returnsSP500)
colnames(returns) <- c("returnsBTC", "returnsETH", "returnsBNB", "returnsGOLD", "returnsSP500")

dygraph(data$BTC.USD.Adjusted, main = "BTC") %>% dyOptions(colors = "#00008B")
dygraph(log(data$BTC.USD.Adjusted), main = "Log - BTC") %>% dyOptions(colors = "#00008B")
dygraph(returns$returnsBTC, main = "Daily log-returns BTC") %>% dyOptions(colors = "#00008B")

hist_btc <- gghistogram(returns$returnsBTC, add.normal = TRUE) +
  xlab("daily log-returns") + ylab("frequency") +
  ggtitle("BTC daily log-returns histogram") + theme_bw()
acf_btc <- plot_acf(returns$returnsBTC, "ACF - Bitcoin returns")
grid.arrange(hist_btc, acf_btc, ncol = 2)

Box.test(returns$returnsBTC, fitdf = 0)
Box.test(returns$returnsBTC, fitdf = 0, type = "Ljung")

# =============================================================================
# SECTION 8: FIRST MODEL — MULTIVARIATE REGRESSION ON LOG-RETURNS
# =============================================================================

corr <- cor(returns, use = "complete.obs")
cor_df <- melt(corr)

ggplot(data = cor_df, aes(Var1, Var2)) +
  geom_tile(aes(fill = value), color = "white") +
  geom_text(aes(label = round(value, 2)), color = "black") +
  scale_fill_gradient2(low = "red", mid = "white", high = "blue",
                       midpoint = 0.2, limits = c(-1, 1)) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Correlation Matrix", x = NULL, y = NULL) +
  coord_fixed()

bnb_r   <- as.ts(returns$returnsBNB)
btc_r   <- as.ts(returns$returnsBTC)
eth_r   <- as.ts(returns$returnsETH)
gold_r  <- as.ts(returns$returnsGOLD)
sp500_r <- as.ts(returns$returnsSP500)

fit1 <- tslm(bnb_r ~ btc_r + eth_r + gold_r + sp500_r)
summary(fit1)

bnb_r_train   <- head(bnb_r,   1795)
btc_r_train   <- head(btc_r,   1795)
eth_r_train   <- head(eth_r,   1795)
gold_r_train  <- head(gold_r,  1795)
sp500_r_train <- head(sp500_r, 1795)

trainset <- data.frame(btc = btc_r_train, eth = eth_r_train,
                       gold = gold_r_train, sp500 = sp500_r_train)

bnb_r_test   <- tail(bnb_r,   449)
btc_r_test   <- tail(btc_r,   449)
eth_r_test   <- tail(eth_r,   449)
gold_r_test  <- tail(gold_r,  449)
sp500_r_test <- tail(sp500_r, 449)

testset <- data.frame(btc = btc_r_test, eth = eth_r_test,
                      gold = gold_r_test, sp500 = sp500_r_test)

mod1  <- tslm(bnb_r_train ~ btc + eth + gold + sp500, data = trainset)
prev1 <- predict(mod1, newdata = testset)

risultati <- cbind(bnb_r_test,
                   ts(prev1, start = 1796, end = 2244, frequency = 1))
colnames(risultati) <- c("bnbTEST", "bnbPrev")

dygraph(risultati, main = "Return Forecasts on Test Series") %>%
  dySeries("bnbTEST", label = "Test Series", color = "blue") %>%
  dySeries("bnbPrev", label = "Forecasts",   color = "red")

accuracy(fit1, test = seq(1795, 2244))

# =============================================================================
# SECTION 9: SECOND MODEL — REGRESSION ON MOVING AVERAGE TREND
# =============================================================================

bnbTS <- as.ts(data$BNB.USD.Adjusted)
fit2 <- tslm(bnbTS ~ ma(bnbTS, 7))
summary(fit2)

bnb.train <- as.data.frame(head(bnbTS, 1796))
bnb.test  <- as.data.frame(tail(bnbTS, 449))

mod2  <- tslm(x ~ ma(x, 7), data = bnb.train)
prev2 <- predict(mod2, newdata = bnb.test)

bnbTest <- bnb.test$x

testing <- cbind(ts(bnbTest, start = 1797, end = 2245, frequency = 1),
                 ts(prev2,   start = 1797, end = 2245, frequency = 1))
colnames(testing) <- c("bnbTEST", "bnbPrev")

dygraph(testing, main = "BNB Forecasts on Test Series") %>%
  dySeries("bnbTEST", label = "Test Series", color = "blue") %>%
  dySeries("bnbPrev", label = "Forecasts",   color = "red")

accuracy(fit2, test = seq(1797, 2245))

# =============================================================================
# SECTION 10: MODEL COMPARISON — LOO-CV
# =============================================================================

CV(fit1)
CV(fit2)
