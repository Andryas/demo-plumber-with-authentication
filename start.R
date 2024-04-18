source("aux.R")

pr <- plumber::pr("api.R")
pr$run(host = '0.0.0.0', port = 8080, swagger = FALSE)