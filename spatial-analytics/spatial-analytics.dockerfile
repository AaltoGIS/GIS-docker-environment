FROM jupyter/minimal-notebook

MAINTAINER Henrikki Tenkanen <henrikki.tenkanen@aalto.fi>

# Install openjdk
USER root
RUN apt-get update \
    && apt-get clean

    # OpenJDK 11 not needed anymore for r5py
    # && apt-get install -y openjdk-11-jdk \

# the user set here will be the user that students will use
USER $NB_USER
ENV HOME /home/$NB_USER
ENV NODE_OPTIONS=--max-old-space-size=4096

COPY environment.yml .
COPY requirements.txt .
COPY ./instance_start_script.sh /usr/local/bin/instance_start_script.sh

### Installing the GIS libraries
RUN echo "Upgrading conda" \
&& conda update --yes -n base conda \
&& conda install mamba -n base -c conda-forge \
# Install pkgs from environment.yml
&& mamba env update -n base -f environment.yml \
# Install with pip from requirements.txt
&& pip install -r requirements.txt \
# Install keplergl extension
&& jupyter labextension install @jupyter-widgets/jupyterlab-manager keplergl-jupyter \
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

USER $NB_USER
WORKDIR /home/$NB_USER
CMD ["/usr/local/bin/instance_start_script.sh"]

