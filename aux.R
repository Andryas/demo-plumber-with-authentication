deg2rad <- function(deg) {
    deg * (pi / 180)
}

geo_distance <- function(lat1, lng1, lat2, lng2) {
    R <- 6371 # Radius of the earth in km
    dLat <- deg2rad(lat2 - lat1) # deg2rad below
    dLon <- deg2rad(lng2 - lng1)
    a <- sin(dLat / 2) * sin(dLat / 2) + cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2)
    c <- 2 * atan2(sqrt(a), sqrt(1 - a))
    d <- R * c # Distance in km
    return(d)
}

# dependencies for dockerfile
get_dependencies <- function() {
    pkgs <- attachment::att_from_rscripts(".")
    pkgs_version <- unlist(purrr::map(pkgs, function(x) as.character(packageVersion(x))))

    purrr::map2(pkgs, pkgs_version, function(x, y) {
        p <- paste0(x, "@", y)
        paste0("RUN Rscript -e \"pak::pak('",p,"')\"")
    }) |> 
    unlist() |> 
    paste0(collapse = "\n") |> 
    cat()
}
