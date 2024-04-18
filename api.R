#* @filter checkAuth
function(req, res){
  encoded_string <- req$HTTP_AUTHORIZATION
  
  encoded_string <- gsub("Basic ", "",encoded_string)
  decoded_string <- rawToChar(base64enc::base64decode(what = encoded_string))
  
  username <- strsplit(decoded_string, ":")[[1]][1]
  password <- strsplit(decoded_string, ":")[[1]][2]

  conn <- RSQLite::dbConnect(RSQLite::SQLite(), "./data/sampledb.sqlite")
  query <- paste0(
    "
    SELECT * 
    FROM users
    WHERE username=? and password=?
    "
  )
  checkUser <- DBI::dbGetQuery(conn, query, params = list(username, password))
  checkUser <- nrow(checkUser)==0 # Unauthorized

  if (checkUser){
    res$status <- 401 # Unauthorized
    return(list(error="Authentication required"))
  } else {
    plumber::forward()
  }
}

#* @get /hello
#* @serializer html
function(){
  "<html><h1>hello world</h1></html>"
}

#* Echo the parameter that was sent in
#* @param msg The message to echo back.
#* @get /echo
function(msg=""){
  list(msg = paste0("The message is: '", msg, "'"))
}

#* @param price_min Minimum price (optional). If provided, only records with price greater than or equal to this value will be returned.
#* @param price_max Maximum price (optional). If provided, only records with price less than or equal to this value will be returned.
#* @param lat Latitude for geographical filtering (optional). If provided along with lon and radius, only records within the specified radius of this point will be returned.
#* @param lon Longitude for geographical filtering (optional). If provided along with lat and radius, only records within the specified radius of this point will be returned.
#* @param radius Radius for geographical filtering (optional). If provided along with lat and lon, only records within this distance (in KM units corresponding to lat/lon) of the specified point will be returned.
#* @get /centris
function(price_min, price_max, lat, lon, radius=1){
  conn <- RSQLite::dbConnect(RSQLite::SQLite(), "./data/sampledb.sqlite")

  if (!missing(price_min) & !missing(price_max)) {
    query <- paste0(
      "
      SELECT *
      FROM centris_ca
      WHERE price BETWEEN {price_min} AND {price_max}
      "
    )
  } else if (!missing(price_min)) {
    query <- paste0(
      "
      SELECT *
      FROM centris_ca
      WHERE price >= {price_min}
      "
    )
  } else if (!missing(price_max)) {
    query <- paste0(
      "
      SELECT *
      FROM centris_ca
      WHERE price <= {price_max}
      "
    )
  } else {
    query <- paste0(
      "
      SELECT *
      FROM centris_ca
      "
    )
  }

  data <- DBI::dbGetQuery(conn, stringr::str_glue(query))
  DBI::dbDisconnect(conn)

  if (!missing(lat) & !missing(lon)) {
    lat <- as.numeric(lat)
    lon <- as.numeric(lon)
    radius <- as.numeric(radius)

    data <- data |> 
      dplyr::mutate(dist = geo_distance(lat, lon, !!lat, !!lon)) |> 
      dplyr::filter(dist <= !!radius)
  }


  return(data)
}

#* @post /new_user
function(req, name, dob, gender, is_gamer) {
  conn <- RSQLite::dbConnect(RSQLite::SQLite(), "./data/sampledb.sqlite")

  if (missing(name)) name <- NA_character_
  if (missing(dob)) dob <- NA_character_
  if (missing(gender)) gender <- NA_character_
  if (missing(is_gamer)) is_gamer <- NA_character_

  query <- stringr::str_glue("INSERT INTO clients (name, dob, gender, is_gamer) VALUES ('{name}', '{dob}', '{gender}', '{is_gamer}')")

  DBI::dbExecute(conn, query)
  DBI::dbDisconnect(conn)

  return(
    list(
      message = "User added successfully!"
    )
  )
}

#* @post /client/new
function(req, name, dob, gender, is_gamer) {
  conn <- RSQLite::dbConnect(RSQLite::SQLite(), "./data/sampledb.sqlite")

  if (missing(name)) name <- NA_character_
  if (missing(dob)) dob <- NA_character_
  if (missing(gender)) gender <- NA_character_
  if (missing(is_gamer)) is_gamer <- NA_character_

  query <- paste0(
    "INSERT INTO clients (name, dob, gender, is_gamer) VALUES (?, ?, ?, ?)"
  )

  DBI::dbExecute(conn, query, params = list(name, dob, gender, is_gamer))
  DBI::dbDisconnect(conn)

  return(
    list(
      message = "User added successfully!"
    )
  )
}

#* @get /client/read
function(req) {
  conn <- RSQLite::dbConnect(RSQLite::SQLite(), "./data/sampledb.sqlite")
  data <- DBI::dbReadTable(conn, "clients")
  DBI::dbDisconnect(conn)

  return(data)
}


#* @put /client/update/<id>
function(id, name, dob, gender, is_gamer, res) {
  conn <- RSQLite::dbConnect(RSQLite::SQLite(), "./data/sampledb.sqlite")
  
  if (missing(name)) name <- NA_character_
  if (missing(dob)) dob <- NA_character_
  if (missing(gender)) gender <- NA_character_
  if (missing(is_gamer)) is_gamer <- NA_character_

  query <- paste0(
    "UPDATE clients 
    SET name = ?, dob = ?, gender = ?, is_gamer = ?
    WHERE id = ?"
  )

  result <- DBI::dbExecute(conn, query, params = list(name, dob, gender, is_gamer, as.integer(id)))

  DBI::dbDisconnect(conn)

  if (result > 0) {
    res$status <- 200
    return(list(message = "Client updated successfully"))
  } else {
    res$status <- 404
    return(list(error = "Client not found"))
  }

}

#* @delete /client/delete/<id>
function(id, res) {
  conn <- RSQLite::dbConnect(RSQLite::SQLite(), "./data/sampledb.sqlite")
  result <- dbExecute(con, "DELETE FROM clients WHERE id = ?", params = list(as.integer(id)))
  DBI::dbDisconnect(con)
  if (result > 0) {
    res$status <- 200
    return(list(message = "Client deleted successfully"))
  } else {
    res$status <- 404
    return(list(error = "Client not found"))
  }
}