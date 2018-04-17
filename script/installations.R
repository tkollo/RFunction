options(repos = "https://mran.microsoft.com")

# Installing packages ------------------------------------------------------------------

if (!require('httr')) install.packages('httr')
if (!require('jsonlite')) install.packages('jsonlite')
if (!require('ggplot2')) install.packages('ggplot2')
if (!require('twitteR')) install.packages("twitteR")
if (!require('rsvg')) install.packages("rsvg")
if (!require('rjson')) install.packages("rjson")
library('rjson')
library('rsvg')
library('twitteR')
library('httr')
library('jsonlite')
library('ggplot2')