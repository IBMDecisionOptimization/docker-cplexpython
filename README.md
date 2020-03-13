# docker-cplexpython

Docker container definition for CPLEX using only the CPLEX Python API.

The Dockerfile first installs a full CPLEX and then removes everything that
is not required to run the CPLEX Python API.

By default the files install into /ilog/CPLEX directory in the container. This
can be changed by modifying `install.properties` and `Dockerfile`.

By default the files install Python 3.7. This can be changed by modifying
`CPX_PYVERSION` in `Dockerfile`.