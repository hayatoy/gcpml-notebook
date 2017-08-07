# Copyright (c) Hayato Yoshikawa
FROM google/cloud-sdk:slim

MAINTAINER Hayato Yoshikawa

RUN apt-get install -yq --no-install-recommends wget build-essential gfortran libatlas-base-dev

RUN pip install --upgrade jupyter
RUN pip install --upgrade scipy
RUN pip install --upgrade matplotlib
RUN pip install --upgrade seaborn
RUN pip install --upgrade Pillow
RUN pip install --upgrade pandas
RUN pip install --upgrade pandas-gbq
RUN pip install --upgrade scikit-learn
RUN pip install --upgrade tensorflow
RUN pip install --upgrade google-cloud-vision
RUN pip install --upgrade google-cloud-translate
RUN pip install --upgrade google-cloud-language

USER root

# Install Tini
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.10.0/tini && \
    echo "1361527f39190a7338a0b434bd8c88ff7233ce7b9a4876f3315c22fce7eca1b0 *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini

ENV SHELL /bin/bash
ENV NB_USER gcpuser
ENV NB_UID 1000
ENV HOME /home/$NB_USER

# Create jovyan user with UID=1000 and in the 'users' group
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER

EXPOSE 8888
WORKDIR $HOME

# Configure container startup
ENTRYPOINT ["tini", "--"]
CMD ["start-notebook.sh"]

# Add local files as late as possible to avoid cache busting
COPY start.sh /usr/local/bin/
COPY start-notebook.sh /usr/local/bin/
COPY start-singleuser.sh /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/
RUN chown -R $NB_USER:users /etc/jupyter/

ENV CLOUDSDK_CONFIG $HOME/notebook/.config

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_USER
