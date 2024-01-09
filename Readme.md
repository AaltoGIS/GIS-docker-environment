# Aalto GIS education Docker environment

[CSC Instructions](
https://github.com/csc-training/geocomputing/blob/master/rahti/autogis-course-part1/creating_csc_notebooks_image.md)

Other useful docs:
- [How to get Docker to play nicely with your Python Data Science package](https://medium.com/better-programming/how-to-get-docker-to-play-nicely-with-your-python-data-science-packages-81d16f1080d2)

## Steps

1. Install [Docker](https://docs.docker.com/engine/install/ubuntu/), [configure Docker to work without sudo](https://docs.docker.com/engine/install/linux-postinstall/) and [install OpenShift](https://www.howtoforge.com/how-to-install-and-configure-openshift-origin-paas-server-on-ubuntu-2004/)
   1. For Docker, [enable experimental features](https://stackoverflow.com/a/44346323)
2. Update the [Python environment](environment.yml) with required packages
3. Run build.sh (within the course folder) that will create the Docker container 
   1. If the image is large, try to make it smaller (5 GB limit) with [these tricks](https://docs.csc.fi/cloud/rahti/images/keeping_docker_images_small/). Take a look at [spatial-analytics.dockerfile](spatial-analytics/spatial-analytics.dockerfile) for inspiration.
   2. Test running the docker locally by executing (an example for `csc/spatial-analytics` -image): `docker run --rm -ti -p 8888:8888 -v ${PWD}:/home/jovyan/work csc/spatial-analytics`
4. Make a dedicated project for the course if it does not exist yet at https://registry-console.rahti.csc.fi/ 
  
   - Access policy should be `Anonymous: Allow all unauthenticated users to pull images`

5. Push to docker image to Rahti (replace `<image-name>` and `<project-name>` below to correspond your settings):
  
   1. Declare environment variables:
      
      - `export OSO_PROJECT=<project-name>`  (<-- this should match with the course project name that you created in step 4)
      - `export OSO_REGISTRY=docker-registry.rahti.csc.fi`
      
   2. Login to the Rahti docker image registry from docker and oc (get the tokens from Rahti registry web pages)
   
      - `sudo docker login -p <DOCKER-LOGIN-TOKEN-HERE> -u unused docker-registry.rahti.csc.fi`
      - `oc login --token <OpenShift-LOGIN-TOKEN-HERE> rahti.csc.fi:8443`   
      - Switch to correct project (if needed) by: `oc project <project name>`
      
   3. Tag the image you want to send to the registry
     
      - `docker tag csc/<image-name> docker-registry.rahti.csc.fi/<project-name>/<image-name>:latest`   
        - Sustainability course: `docker tag csc/sds-sustainability docker-registry.rahti.csc.fi/sds-sustainability/sds-sustainability:latest`
        - Spatial Analytics course: `docker tag csc/spatial-analytics docker-registry.rahti.csc.fi/spatial-analytics-course/spatial-analytics:latest`
 
   4. Push the image to Rahti image registry
   
      - `docker push docker-registry.rahti.csc.fi/<project-name>/<image-name>:latest`
        - Sustainability course: `sudo docker push docker-registry.rahti.csc.fi/sds-sustainability/sds-sustainability:latest`
        - Spatial analytics course: `sudo docker push docker-registry.rahti.csc.fi/spatial-analytics-course/spatial-analytics:latest`
      
**Deploy the pushed image to Rahti**

  1. Go to https://rahti.csc.fi -> Web user interface -> Choose your project
  2. "Add to project" (top right) -> Deploy image -> Choose your image -> Deploy

  3. Add route for the object (make the application publicly available/visible)

  - Applications (left) -> Routes -> Create Route (top right) -> Fill only "Name" and "Service"

8. Add persistent storage 

  1. Create persistent storage (this is the storage allocated for the **whole project**):

      - Storage (left) -> Create Storage (top right) -> Storage Class: glusterfs, Name: unique name, Access Mode: RWO, Size: 5GB

  2. Attach it to the deployment: 
     
      - Applications -> deployment -> click the name of the deployment -> Configuration -> Under "Volumes" Add Storage 
        
        - Choose the storage you created and add the mounting point (path) where this storage is to be added. In the CSC notebooks it should be `/home/jovyan/work`  
  
9. Make the notebook container loads faster for the students by preloading the image to Rahti pods

   - In Rahti web console: 
    
     - Applications -> Deployments -> The version number of your current deployment (e.g #28) (you might need to wait for the image building to stop before continuing) 
     - Replicas -> Edit (pen symbol) -> increase to the number of students 
     - After the pods have started succesfully, bring them down again to 1
     
10. Running the container in notebooks.csc.fi

   1. If you don't have group owner rights at CSC Notebooks, apply for those by sending email to servicedesk@csc.fi
   2. Login to https://notebooks.csc.fi 
   3. Create a new Group for the course (under the "Groups" -tab) which will be used to invite students to the course CSC Notebook
   4. Create a new Blueprint in Notebooks (under Blueprints tab) by using a template that uses Rahti, e.g. `Rahti Jupyter Minimal`
        
        1. Fill the name and description as you see best.
        2. Specify the source for the Blueprint from Rahti registry:
          
           - `docker-registry.rahti.csc.fi/<project-name>/<image-name>:latest`
           
        3. Specify the memory limit as `8000M` (remember to ask permission from CSC guys for larger instances, e.g. for 16GB)
        
   5. Activate the Blueprint under the `Deactive Blueprints` section. After this, the blueprint will be available under the "Dashboard" tab.
   
## How to update Docker image?

If you need to update the docker image in Rahti, make a new image and push it to Rahti Docker registry (steps 2-5 above).
After you have pushed a new image to the registry, the environment will be updated to Notebooks after repeating step 9 above 
(i.e. increase the number of pods and bring them down).  
   
## Configure the Blueprint environment using a dedicated GitHub notebook repo

After a "clean" Docker/JupyterLab environment has been created for your course, you want to configure which materials will be used
as source in your course Notebook environment. As a starting point, [please check this CSC Pebbles guide](http://cscfi.github.io/pebbles/group_owners_guide.html).

To specify which repository should always be cloned for your programming environment (i.e when the students use CSC Notebooks), you need to:

1. Create a dedicated repository for your course notebooks **OR** add a new branch to [AaltoGIS/notebooks](https://github.com/AaltoGIS/notebooks) repository with your materials.

 - In this repository you should add all the notebooks that you want the students to be able to see and run during the lessons. 
 Typically you want to update this repo for each week (so that the students don't see all materials at once). 
 
2. Create a configuration file for your course into [AaltoGIS/CSC-notebooks-env-config](https://github.com/AaltoGIS/CSC-notebooks-env-config) following the instructions in that repo. 

   

        
