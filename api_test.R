httr::content(httr::GET("http://localhost:8080/echo"))

msg <- URLencode("testando som")
httr::content(httr::GET(stringr::str_glue("http://localhost:8080/echo?msg={msg}")))


p <- httr::content(httr::GET("http://localhost:8080/plot"))

