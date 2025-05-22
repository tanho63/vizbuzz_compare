FROM rocker/r-ver:4.4.1

# install linux system libraries
RUN apt-get update && apt-get install -y \
      apt-utils \
      curl \
      libcurl4-openssl-dev \
   # install latest version of pak
   && install2.r -e -r https://r-lib.github.io/p/pak/stable/source/linux-gnu/x86_64 pak \
   && apt-get clean \
   && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/downloaded_packages

WORKDIR /root/app
COPY DESCRIPTION /root/app
RUN Rscript -e "pak::local_install_deps('/root/app')"

COPY . /root/app
EXPOSE 3838
ENTRYPOINT ["Rscript"]
CMD ["-e", "shiny::runApp('/root/app',host='0.0.0.0',port=3838)"]
