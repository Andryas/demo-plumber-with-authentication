FROM r-base:4.3.1 as base

RUN apt-get -y update && apt-get install -y  gdal-bin imagemagick \
    libcurl4-openssl-dev libgdal-dev libgeos-dev libgeos++-dev \
    libicu-dev libpng-dev libproj-dev libsasl2-dev libssl-dev \
    libxml2-dev make zlib1g-dev libudunits2-dev libgdal-dev libgeos-dev \
    libproj-dev libprotobuf-dev libmagick++-6.q16-dev protobuf-compiler \
    libjq-dev libsodium-dev libv8-dev libharfbuzz-dev libfribidi-dev && \
    rm -rf /var/lib/apt/lists/*

COPY .Renviron_github_pat root/.Renviron

RUN echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl', Ncpus = 4)" >> /usr/lib/R/etc/Rprofile.site

RUN R -e 'install.packages("pak")'

RUN Rscript -e "pak::pak('httr@1.4.7')"
RUN Rscript -e "pak::pak('stringr@1.5.1')"
RUN Rscript -e "pak::pak('base64enc@0.1.3')"
RUN Rscript -e "pak::pak('RSQLite@2.3.6')"
RUN Rscript -e "pak::pak('DBI@1.2.2')"
RUN Rscript -e "pak::pak('plumber@1.2.2')"
RUN Rscript -e "pak::pak('dplyr@1.1.4')"
RUN Rscript -e "pak::pak('attachment@0.4.1')"
RUN Rscript -e "pak::pak('purrr@1.0.2')"
RUN Rscript -e "pak::pak('pak@0.7.2')"
RUN Rscript -e "pak::pak('tibble@3.2.1')"

COPY . root/api
COPY .Renviron root/.Renviron

WORKDIR /root/api

CMD  ["Rscript", "/root/api/start.R"]