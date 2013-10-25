FROM ubuntu

MAINTAINER Allan Costa allaninocencio@yahoo.com.br

# Install dependencies
RUN \
    echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list;\
    apt-get update;\
    apt-get install -y git-core;\
    apt-get install -y build-essential;\
    apt-get install -y wget;\
    apt-get install -y python2.7;\
    apt-get install -y python-dev;\
    apt-get install -y libtool;\
    apt-get install -y automake;\
    apt-get install -y python-numpy;\
#RUN

# Install setuptools (required by pip) and pip (required by NuPIC builder)
RUN \
    wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -O - | python;\
    wget https://raw.github.com/pypa/pip/master/contrib/get-pip.py -O - | python;\
#RUN

# Clone NuPIC repository (takes some time)
RUN git clone https://github.com/numenta/nupic.git /usr/local/src/nupic

# Set enviroment variables needed by NuPIC builder
ENV NTA /usr/bin/nta/eng
ENV NUPIC /usr/local/src/nupic
ENV BUILDDIR /tmp/ntabuild
ENV MK_JOBS 3

# More enviroment variables (setted originally by $NUPIC/env.sh)
ENV PY_VERSION 2.7
ENV PATH $NTA/bin:$PATH
ENV PYTHONPATH $NTA/lib/python$PY_VERSION/site-packages:$PYTHONPATH
ENV NTA_ROOTDIR $NTA
ENV NTA_DATA_PATH $NTA/share/prediction/data:$NTA_DATA_PATH
ENV LDIR $NTA/lib
ENV LD_LIBRARY_PATH $LDIR

# Install NuPIC
RUN $NUPIC/build.sh

# Create a symbolic link named libpython2.6.so.1.0 targeting libpython2.7.so.1.0
# Needed because NuPIC seems to still have hardcoded Python 2.6 portions
RUN ln -s /usr/lib/libpython2.7.so.1.0 /usr/lib/libpython2.6.so.1.0

# Fix the "no --boxed argument" problem by replacing line 150 of $NTA/bin/run_tests.py:
# - args = ["--boxed", "--verbose"]
# + args = ["--verbose"]
RUN sed '150s/.*/\ \ args = ["--verbose"]/' $NUPIC/bin/run_tests.py > $NUPIC/run_tests.py & mv $NUPIC/run_tests.py $NUPIC/bin/run_tests.py

# Cleanup
RUN rm setuptools*

# OPF needs this (It's a workaround. We can create a user, but I wanted to keep this image clean to use as base to my projects)
ENV USER docker

# Default directory
WORKDIR /home/docker