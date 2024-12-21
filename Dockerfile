FROM --platform=linux/amd64 continuumio/miniconda3 AS build
LABEL maintainer="mpmaneta@gmail.com"
LABEL company="eki environment and water, inc"


RUN useradd -ms /bin/bash -G sudo eki 

ENV HOME="/home/eki"
WORKDIR ${HOME}

RUN apt-get update -y -qq
RUN apt install -y build-essential gfortran unzip vim

USER eki

WORKDIR ${HOME}/pest
RUN wget https://s3.amazonaws.com/docs.pesthomepage.org/source_code/pest17.tar.zip
RUN tar xvzf pest17.tar.zip && rm pest17.tar.zip

WORKDIR ${HOME}/pest/pest_source

RUN sed -i'' -e '2 i GFVERSION =  $(shell gfortran -dumpversion)' -e '8 i ifeq "$(GFVERSION)" "12"\n\tFFLAGS += -fallow-argument-mismatch\nendif' pestutl5.mak
RUN sed -i'' -e '2 i GFVERSION =  $(shell gfortran -dumpversion)' -e '8 i ifeq "$(GFVERSION)" "12"\n\tFFLAGS += -fallow-argument-mismatch\nendif' pestutl6.mak
RUN sed -i'' -e '2 i GFVERSION =  $(shell gfortran -dumpversion)' -e '8 i ifeq "$(GFVERSION)" "12"\n\tFFLAGS += -fallow-argument-mismatch\nendif' beopest.mak

#RUN mv ip.C ip.c

COPY Makefile_pest .
RUN mkdir -p ${HOME}/bin
RUN make -f Makefile_pest pest

# PEST HP

WORKDIR ${HOME}/pest
RUN wget https://s3.amazonaws.com/docs.pesthomepage.org/source_code/unixpest_hp.zip
RUN unzip unixpest_hp.zip && rm unixpest_hp.zip


RUN sed -i'' -e '14 i GFVERSION =  $(shell gfortran -dumpversion)' -e '25 i ifeq "$(GFVERSION)" "12"\n\tFFLAGS += -fallow-argument-mismatch\nendif' pest_hp.mak
RUN sed -i'' -e '10 i GFVERSION =  $(shell gfortran -dumpversion)' -e '22 i ifeq "$(GFVERSION)" "12"\n\tFFLAGS += -fallow-argument-mismatch\nendif' cmaes_hp.mak
RUN sed -i'' -e '10 i GFVERSION =  $(shell gfortran -dumpversion)' -e '22 i ifeq "$(GFVERSION)" "12"\n\tFFLAGS += -fallow-argument-mismatch\nendif' jactest_hp.mak
RUN sed -i'' -e '10 i GFVERSION =  $(shell gfortran -dumpversion)' -e '22 i ifeq "$(GFVERSION)" "12"\n\tFFLAGS += -fallow-argument-mismatch\nendif' rsi_hp.mak
RUN sed -i'' -e '9 i GFVERSION =  $(shell gfortran -dumpversion)' -e '19 i ifeq "$(GFVERSION)" "12"\n\tFFLAGS += -fallow-argument-mismatch\nendif' agent_hp.mak

RUN mv postensiunc.f postensiunc.F

COPY Makefile_pest .
RUN make -f Makefile_pest pest_hp
RUN find . -executable -exec cp {} ${HOME}/bin/ \;

FROM --platform=linux/amd64 continuumio/miniconda3
LABEL maintainer="mpmaneta@gmail.com"
LABEL company="eki environment and water, inc"

RUN useradd -ms /bin/bash -G sudo eki 


ENV HOME="/home/eki"
WORKDIR ${HOME}

COPY --from=build ${HOME}/bin ${HOME}/bin


COPY conda_reqs.txt .
RUN conda install -y -c conda-forge --file conda_reqs.txt && conda clean -ayq
RUN get-modflow :python

USER eki

ENV PATH=$PATH:${HOME}/bin

WORKDIR ${HOME}
