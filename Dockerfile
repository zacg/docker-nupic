FROM ubuntu

MAINTAINER Allan Costa <allaninocencio@yahoo.com.br>

# Make sure the package repository is up to date
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list

# Update repository
RUN apt-get update

# Install make and gcc (needed by NuPIC builder) 
# Install wget (need for installing pip) 
# Update Python 2.7 
# Install Python devoleper libs (needed by pip)
# Install numpy (needed by NuPIC)
# Install git (necessary to clone NuPIC repository)
# Install libtool (needed by NuPIC builder)
# Install automake (needed by NuPIC builder)
RUN apt-get install -y build-essential wget python2.7 python-dev python-numpy git-core libtool automake

# Install setuptools (needed by pip)
RUN wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -O - | python

# Install pip (needed by NuPIC builder)
RUN wget https://raw.github.com/pypa/pip/master/contrib/get-pip.py -O - | python

#Clone NuPIC repository
RUN git clone https://github.com/numenta/nupic.git /home/nupic

# Set enviroment variables
ENV NTA /usr/bin/nta/eng
ENV NUPIC /home/nupic
ENV BUILDDIR /tmp/ntabuild
ENV MK_JOBS 3

# Enviroment variables setted by $NUPIC/env.sh
ENV PY_VERSION 2.7
ENV PATH $NTA/bin:$PATH
ENV PYTHONPATH $NTA/lib/python$PY_VERSION/site-packages:$PYTHONPATH
ENV NTA_ROOTDIR $NTA
ENV NTA_DATA_PATH $NTA/share/prediction/data:$NTA_DATA_PATH
ENV LDIR $NTA/lib
ENV LD_LIBRARY_PATH $LDIR

# OPF uses this (It's a workaround)
ENV USER nupic

#Install NuPIC
RUN $NUPIC/build.sh

# Create a symbolic link named libpython2.6.so.1.0 targeting libpython2.7.so.1.0
# Needed because NuPIC seems to still have hardcoded Python 2.6 portions 
RUN ln -s /usr/lib/libpython2.7.so.1.0 /usr/lib/libpython2.6.so.1.0

# Fix the "no --boxed argument" problem by replacing line 150 of $NTA/bin/run_tests.py:
# -  args = ["--boxed", "--verbose"]
# +  args = ["--verbose"]
RUN sed '150s/.*/\ \ args = ["--verbose"]/' $NUPIC/bin/run_tests.py > $NUPIC/run_tests.py & mv $NUPIC/run_tests.py $NUPIC/bin/run_tests.py

# Cleanup
RUN rm setuptools*