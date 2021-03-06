<!-- README.md is generated from README.Rmd. Please edit that file -->
vip: Variable Importance Plots <img src="tools/vip-logo.png" align="right" />
=============================================================================

Complex nonparametric models (like neural networks, random forests, and support vector machines) are more common than ever in predictive analytics, especially when dealing with large observational databases that don't adhere to the strict assumptions imposed by traditional statistical techniques (e.g., multiple linear regression which assumes linearity, homoscedasticity, and normality). Unfortunately, it can be challenging to understand the results of such models and explain them to management. Variable importance plots and partial dependence plots (PDPs) offer a simple solution. PDPs are low-dimensional graphical renderings of the prediction function so that the relationship between the outcome and predictors of interest can be more easily understood. These plots are especially useful in explaining the output from black box models. The [`pdp`](https://github.com/bgreenwell/pdp) package offers a general framework for constructing PDPs for various types of fitted models in R.

While PDPs can be constructed for any predictor in a fitted model, variable importance scores are more difficult to define. Some methods (like random forests and other tree-based methods) have a natural way of defining variable importance. Unfortunately, this is not the case for other popular supervised learning algorithms like support vector machines. The `vip` package offers a solution by providing a partial dependence-based variable importance metric that can be used with any supervised learning algorithm.

Installation
------------

The `vip` package is currently only available from GitHub, but can easily be installed using the [devtools](https://CRAN.R-project.org/package=devtools) package:

``` r
if (!requireNamespace("devtools")) install.packages("devtools")
devtools::install_github("koalaverse/vip")
```

Example usage
-------------

For illustration, we use one of the regression problems described in Friedman (1991) and Breiman (1996). These data are available in the [mlbench](https://CRAN.R-project.org/package=mlbench) package. The inputs consist of 10 independent variables uniformly distributed on the interval \[0,1\]; however, only 5 out of these 10 are actually used in the true model. Outputs are created according to the formula described in `?mlbench::mlbench.friedman1`. The code chunk below simulates 500 observations from the model default standard deviation.

``` r
# Simulate training data
set.seed(101)  # for reproducibility
trn <- as.data.frame(mlbench::mlbench.friedman1(500))  # ?mlbench.friedman1
```

Next, we fit a random forest to the simulated data and construct variable importance plots using the two methods provided by the random forest algorithm (left and middle plots) and the (**experimental**) partial dependence-based approach (right plot). In this case, all three methods do a fantastic job at highlighting the five variables used in the true model.

``` r
# Load required packages
library(randomForest)  
library(vip)

# Fit a random forest
set.seed(102)
rf <- randomForest(y ~ ., data = trn, importance = TRUE)

# Use `vi()` to return a tibble of variable importance scores
vi(rf, type = 1)
#> # A tibble: 10 x 2
#>    Variable Importance
#>    <chr>         <dbl>
#>  1 x.4          81.1  
#>  2 x.2          62.3  
#>  3 x.1          58.0  
#>  4 x.5          37.7  
#>  5 x.3          23.8  
#>  6 x.8           2.02 
#>  7 x.9           0.159
#>  8 x.6           0.150
#>  9 x.7          -0.374
#> 10 x.10         -1.92

# Use `vip()` to construct ggplot2-based variable importance plots
p1 <- vip(rf, type = 1)
p2 <- vip(rf, type = 2)
p3 <- vip(rf, partial = TRUE)
#> Warning: Setting `partial = TRUE` is experimental, use at your own risk!
grid.arrange(p1, p2, p3, ncol = 3)
```

<img src="tools/README-example-rf-1.png" style="display: block; margin: auto;" />
