# Use Python 3.10 (should match with Python interpreter in environment.yml)
FROM jupyter/minimal-notebook:python-3.10.11

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
&& conda install --override-channels -c conda-forge mamba 'python_abi=*=*cp*' \
&& mamba env update -n base -f environment.yml \
&& pip install -r requirements.txt

#USER root
# Do not show announcements
RUN jupyter labextension disable "@jupyterlab/apputils-extension:announcements" \
&& conda clean --all --yes --force-pkgs-dirs \
&& jupyter lab clean -y \
&& npm cache clean --force # \
&& find /opt/conda/ -follow -type f -name '*.a' -delete \
&& find /opt/conda/ -follow -type f -name '*.pyc' -delete \
&& find /opt/conda/ -follow -type f -name '*.js.map' -delete \
&& find /opt/conda/lib/python*/site-packages/bokeh/server/static \
    -follow -type f -name '*.js' ! -name '*.min.js' -delete

USER $NB_USER
WORKDIR /home/$NB_USER
CMD ["/usr/local/bin/instance_start_script.sh"]

