docker-nupic
============

A Dockerfile for building a [NuPIC][1] image. 


Any improvements are welcome.

Examples
--------

I pushed the built image to docker index. To pull it:
```
sudo docker pull allanino/nupic
```

To build the image:
```
sudo docker build -t="allanino/nupic" .
```

Run the Python unit tests:

    sudo docker run allanino/nupic /bin/bash -c "cd /usr/bin/nta/eng/;./bin/run_tests.sh"

Run the C++ tests:

    sudo docker run allanino/nupic /bin/bash -c "/usr/bin/nta/eng/bin/htmtest"
    sudo docker run allanino/nupic /bin/bash -c "/usr/bin/nta/eng/bin/testeverything"

Run hotgym example:

    sudo docker run allanino/nupic /bin/bash -c "python /usr/local/src/nupic/examples/opf/clients/hotgym/hotgym.py"

    sudo docker run allanino/nupic /bin/bash -c "python /usr/local/src/nupic/examples/opf/bin/OpfRunExperiment.py /usr/local/src/nupic/examples/opf/experiments/multistep/hotgym/"


[1]:https://github.com/numenta/nupic