FROM ubuntu

MAINTAINER Allan Costa allaninocencio@yahoo.com.br

# Update repositories
RUN apt-get update

# Install apt-utils
RUN apt-get install -y apt-utils

# Install make and gcc 
RUN apt-get install -y build-essential

# Install wget (need for installing pip) 
RUN apt-get install -y wget 

# Update Python 2.7 
RUN apt-get install -y python2.7 

# Install Python devoleper libs (needed by pip)
RUN apt-get install -y python-dev

# Install git (necessary to clone NuPIC repository)
RUN apt-get install -y git-core

# Install libtool (needed by NuPIC builder)
RUN apt-get install -y libtool

# Install automake (needed by NuPIC builder)
RUN apt-get install -y automake

# Install setuptools (needed by pip)
RUN wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -O - | python

# Install pip
RUN wget https://raw.github.com/pypa/pip/master/contrib/get-pip.py -O - | python

# Install numpy (needed by NuPIC)
RUN pip install numpy

#Clone NuPIC repository
RUN git clone https://github.com/numenta/nupic.git /home

# Set enviroment variables
RUN echo export NTA=/usr/bin/nta/eng >> ~/.bashrc
RUN echo export NUPIC=/nupic >> ~/.bashrc
RUN echo export BUILDDIR=/tmp/ntabuild >> ~/.bashrc
RUN echo export MK_JOBS=3 >> ~/.bashrc
RUN echo source '$NUPIC'/env.sh >> ~/.bashrc

# Reload bash
RUN exec bash

#Install NuPIC
RUN $NUPIC/build.sh

# Create a symbolic link named libpython2.6.so.1.0 targeting libpython2.7.so.1.0
# Needed because NuPIC seems to still have hardcoded Python 2.6 portions 
RUN ln -s /usr/lib/libpython2.7.so.1.0 /usr/lib/libpython2.6.so.1.0

# Install dateutil (needed by hotgym.py)
RUN pip install python-dateutil

# Install validictory (needed by hotgym.py)
RUN pip install validictory

# Install if will run the python unit tests for NuPIC 
RUN pip install pytest

# Install if will run the python unit tests for NuPIC
RUN pip install unittest2

# Fix the "no --boxed argument" problem by replacing line 150 of $NTA/bin/run_tests.py:
# -  args = ["--boxed", "--verbose"]
# +  args = ["--verbose"]
sed '150s/.*/\ \ args = ["--verbose"]/' bin/run_tests.py > run_tests.py & mv run_tests.py bin/run_tests.py


# args = ["--verbose"]
# Install curl (only for my project)
# RUN apt-get install -y curl

# ======>Disable host key checking for Github
# ======> echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> /etc/ssh/ssh_config 
