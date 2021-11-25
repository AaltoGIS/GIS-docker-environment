FROM jupyter/minimal-notebook

MAINTAINER Henrikki Tenkanen <henrikki.tenkanen@aalto.fi>

WORKDIR /opt/app
USER 1000

COPY environment.yml .
COPY requirements.txt .
COPY ./instance_start_script.sh /usr/local/bin/instance_start_script.sh
ENV HOME /home/jovyan

### Installing the GIS libraries
RUN echo "Upgrading conda" \
&& conda update --yes -n base conda \
&& conda install mamba -n base -c conda-forge \
# Install pkgs from environment.yml
&& mamba env update -n base -f environment.yml \
# Install with pip from requirements.txt
&& pip install -r requirements.txt \
&& jupyter lab build  \
# Clean as much as possible
&& conda clean --all --yes --force-pkgs-dirs \
&& jupyter lab clean -y \
&& npm cache clean --force \
&& find /opt/conda/ -follow -type f -name '*.a' -delete \
&& find /opt/conda/ -follow -type f -name '*.pyc' -delete \
&& find /opt/conda/ -follow -type f -name '*.js.map' -delete \
&& find /opt/conda/lib/python*/site-packages/bokeh/server/static \
    -follow -type f -name '*.js' ! -name '*.min.js' -delete

USER root
# OpenShift allocates the UID for the process, but GID is 0
# Based on an example by Graham Dumpleton
RUN chgrp -R root /home/jovyan \
    && find /home/jovyan -type d -exec chmod g+rwx,o+rx {} \; \
    && find /home/jovyan -type f -exec chmod g+rw {} \; \
    && chgrp -R root /opt/conda \
    && find /opt/conda -type d -exec chmod g+rwx,o+rx {} \; \
    && find /opt/conda -type f -exec chmod g+rw {} \; \
    && chmod a+x /usr/local/bin/instance_start_script.sh

USER 1000
WORKDIR /home/jovyan/work
CMD ["/usr/local/bin/instance_start_script.sh"]

