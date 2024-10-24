# Aalto GIS education Docker environment

UPDATED INSTRUCTIONS at CSC (2024):
 - [How to create a OpenShift Project at Rahti2](https://docs.csc.fi/cloud/rahti2/usage/projects_and_quota/)
 - [How to login to Rahti 2 registry and push a docker image](https://docs.csc.fi/cloud/rahti2/images/Using_Rahti_2_integrated_registry/)
 - [Guide for Noppe system for teachers](https://docs.csc.fi/cloud/noppe/guide_for_teachers/)

Other useful docs:
- [How to get Docker to play nicely with your Python Data Science package](https://medium.com/better-programming/how-to-get-docker-to-play-nicely-with-your-python-data-science-packages-81d16f1080d2)

## Steps

1. Install [Docker](https://docs.docker.com/engine/install/ubuntu/), [configure Docker to work without sudo](https://docs.docker.com/engine/install/linux-postinstall/) and install OpenShift for [Linux](https://www.howtoforge.com/how-to-install-and-configure-openshift-origin-paas-server-on-ubuntu-2004/)/[MacOS](https://formulae.brew.sh/formula/openshift-cli) 
   1. For Docker, [enable experimental features](https://stackoverflow.com/a/44346323)
2. Update the [Python environment](environment.yml) with required packages
3. Run build.sh (within the course folder) that will create the Docker container 
   1. If the image is large, try to make it smaller (5 GB limit) with [these tricks](https://docs.csc.fi/cloud/rahti/images/keeping_docker_images_small/). Take a look at [spatial-analytics.dockerfile](spatial-analytics/spatial-analytics.dockerfile) for inspiration.
   2. Test running the docker locally by executing (an example for `csc/spatial-analytics` -image): `docker run --rm -ti -p 8888:8888 -v ${PWD}:/home/jovyan/work csc/spatial-analytics`
4. Make a dedicated project for the course if it does not exist yet at https://rahti.csc.fi/

5. Push to docker image to Rahti (replace `<image-name>` and `<project-name>` below to correspond your settings):
   
   1. Login to the Rahti docker image registry from docker and oc (get the tokens from Rahti registry web pages)
   
      - `sudo docker login -p <DOCKER-LOGIN-TOKEN-HERE> -u unused docker-registry.rahti.csc.fi`
      - `oc login --token <OpenShift-LOGIN-TOKEN-HERE> rahti.csc.fi:8443`   
      - Switch to correct project (if needed) by: `oc project <project name>`
      
   2. Tag the image you want to send to the registry (Rahti 2)
     
      - `docker tag csc/<image-name> image-registry.apps.2.rahti.csc.fi/<project-name>/<image-name>:latest`   
        - IntroSDA course: `docker tag csc/intro-sda image-registry.apps.2.rahti.csc.fi/intro-sda-course/intro-sda:latest`
        - Sustainability course: `docker tag csc/sds-sustainability image-registry.apps.2.rahti.csc.fi/sds-sustainability/sds-sustainability:latest`
        - Spatial Analytics course: `docker tag csc/spatial-analytics image-registry.apps.2.rahti.csc.fi/spatial-analytics-course/spatial-analytics:latest`
 
   3. Push the image to Rahti2 image registry
   
      - `docker push image-registry.apps.2.rahti.csc.fi/<project-name>/<image-name>:latest`
        - IntroSDA course: `docker push image-registry.apps.2.rahti.csc.fi/intro-sda-course/intro-sda:latest`
        - Sustainability course: `docker push image-registry.apps.2.rahti.csc.fi/sds-sustainability/sds-sustainability:latest`
        - Spatial analytics course: `docker push image-registry.apps.2.rahti.csc.fi/spatial-analytics-course/spatial-analytics:latest`

   
## How to update Docker image?

If you need to update the docker image in Rahti, make a new image and push it to Rahti Docker registry (steps 2-5 above).
After you have pushed a new image to the registry, the environment will be updated to Notebooks after repeating step 9 above 
(i.e. increase the number of pods and bring them down).  
   
## Configure the Noppe environment using a dedicated GitHub notebook repo

After a "clean" Docker/JupyterLab environment has been created for your course, you want to configure which materials will be used
as source in your course Notebook environment. As a starting point, [please check this CSC Pebbles guide](http://cscfi.github.io/pebbles/group_owners_guide.html).

To specify which repository should always be cloned for your programming environment (i.e when the students use CSC Notebooks), you need to:

1. Create a dedicated repository for your course notebooks **OR** add a new branch to [AaltoGIS/notebooks](https://github.com/AaltoGIS/notebooks) repository with your materials.

 - In this repository you should add all the notebooks that you want the students to be able to see and run during the lessons. 
 Typically you want to update this repo for each week (so that the students don't see all materials at once). 
 
2. Create a configuration file for your course into [AaltoGIS/CSC-notebooks-env-config](https://github.com/AaltoGIS/CSC-notebooks-env-config) following the instructions in that repo. 

   

        
