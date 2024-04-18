library(RSQLite)

conn <- dbConnect(SQLite(), "./data/sampledb.sqlite")

query <- "
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY,
        username TEXT UNIQUE,
        password TEXT
)"
dbExecute(conn, query)

query <- stringr::str_glue("INSERT INTO users (username, password) VALUES ('admin', '12345')")
dbExecute(conn, query)

query <- "
    CREATE TABLE IF NOT EXISTS clients (
        id INTEGER PRIMARY KEY,
        name TEXT,
        dob DATE,
        gender TEXT,
        is_gamer BOOLEAN
)"
dbExecute(conn, query)

query <- "
    CREATE TABLE IF NOT EXISTS clients (
        id INTEGER PRIMARY KEY,
        name TEXT,
        dob DATE,
        gender TEXT,
        is_gamer BOOLEAN
)"
dbExecute(conn, query)

centris_ca_sample <- tibble::as_tibble(readRDS("./data/centris_ca_sample.rds"))
dbWriteTable(conn, "centris_ca", centris_ca_sample)

dbListTables(conn)
