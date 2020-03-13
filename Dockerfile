# Dockerfile to install CPLEX into a container.
# Based on Python containers so that CPLEX Python connectors can be used.

# NOTE: Starting with docker 17.05 (https://github.com/moby/moby/pull/31352)
# we could specify the version as ${CPX_PYVERSION}. For now we hardcode so
# that things work with older versions of Docker as well.
FROM python:3.7
MAINTAINER daniel.junglas@de.ibm.com

# Where to install (this is also specified in install.properties)
ARG COSDIR=/opt/CPLEX

# Default Python version is 3.7
ARG CPX_PYVERSION=3.7

# Copy installer and installer arguments from local disk
COPY cos_installer-*.bin /tmp/installer
COPY install.properties /tmp/install.properties
RUN chmod u+x /tmp/installer

# Install Java runtime. This is required by the installer
RUN apt-get update && apt-get install -y default-jre

# Install COS
RUN /tmp/installer -f /tmp/install.properties

# Remove installer, temporary files, and the JRE we installed
RUN rm -f /tmp/installer /tmp/install.properties
RUN apt-get remove -y --purge default-jre && apt-get -y --purge autoremove

# For the CPLEX Python API we only need ${COSDIR}/cplex/python/${CPX_PYVERSION}.
# Remove everything else (keep license and swidtag)
RUN rm -rf \
   ${COSDIR}/concert \
   ${COSDIR}/cpoptimizer \
   ${COSDIR}/doc \
   ${COSDIR}/opl \
   ${COSDIR}/python \
   ${COSDIR}/Uninstall \
   ${COSDIR}/cplex/bin \
   ${COSDIR}/cplex/examples \
   ${COSDIR}/cplex/include \
   ${COSDIR}/cplex/lib \
   ${COSDIR}/cplex/matlab \
   ${COSDIR}/cplex/readmeUNIX.html

RUN ls -d ${COSDIR}/cplex/python/* | grep -v ${CPX_PYVERSION} | xargs rm -rf

# Setup Python
# In practice, setting PYTHONPATH is sufficient to get CPLEX Python API going.
# However, we go the official way and call the installation script to install
# the CPLEX packages into the root system
# ENV PYTHONPATH ${PYTHONPATH}:${COSDIR}/cplex/python/${CPX_PYVERSION}/x86-64_linux
RUN cd ${COSDIR}/cplex/python/${CPX_PYVERSION}/x86-64_linux && \
	python${CPX_PYVERSION} setup.py install

ENV CPX_PYVERSION ${CPX_PYVERSION}

# Default user is cplex
RUN adduser --disabled-password --gecos "" cplex 
USER cplex
WORKDIR /home/cplex


CMD /bin/bash
