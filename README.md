Surveys on smoking habits are not used effectively
--------------------------------------------------

The smoking habits of Danish youth is frequently discussed these days, with retailers and politicians competing to announce new measures and proposals for curbing youth smoking.

Reliably measuring youth smoking frequencies is harder than you might expect though - see <http://altandetlige.dk/blog/6644/kommet-unge-dagligrygere-712> (only available in Danish).

The official data on the smoking habits of the Danish population is collected by every year by Danish Department of Health. A nationally representative sample of 5,000 people are surveyed, and the National smoking frequency is measured by the sample smoking frequency. That's it. No mension of uncertainty, no analysis.

But the data can be used much more efficiently. Just consider the 2016 survey. The Danish Cancer Society collect data on smoking rates. Their survey samples youth (aged 16-25) specifically, and 2,000 youth are surveyed. Youth are not equivalently grouped in the official data (but in the ages 15-19 and 20-29). However, similar inferences could have been obtained from the official data, had you more efficiently exploited the information in the data.

This is where multilevel modelling comes in.

What the smoking rates look like
--------------------------------

This is an R Markdown document. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>.

When you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document. You can embed an R code chunk like this:

``` r
summary(cars)
```

    ##      speed           dist       
    ##  Min.   : 4.0   Min.   :  2.00  
    ##  1st Qu.:12.0   1st Qu.: 26.00  
    ##  Median :15.0   Median : 36.00  
    ##  Mean   :15.4   Mean   : 42.98  
    ##  3rd Qu.:19.0   3rd Qu.: 56.00  
    ##  Max.   :25.0   Max.   :120.00

Including Plots
---------------

You can also embed plots, for example:

![](README_files/figure-markdown_github/pressure-1.png)

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
