# Aalto GIS education Docker environment

[CSC Instructions](
https://github.com/csc-training/geocomputing/blob/master/rahti/autogis-course-part1/creating_csc_notebooks_image.md)

Other useful docs:
- [How to get Docker to play nicely with your Python Data Science package](https://medium.com/better-programming/how-to-get-docker-to-play-nicely-with-your-python-data-science-packages-81d16f1080d2)

# Steps

1. Install Docker and OpenShift
2. Update the [Python environment](environment.yml) with required packages
3. Run build.sh that will create the Docker container 
4. Make a dedicated project for the course if it does not exist yet at https://registry-console.rahti.csc.fi/ 
  
   - Access policy should be `Allow anonymous users to pull images`

5. Push to docker image to Rahti
  
   1. Declare environment variables:
      
      - `export OSO_PROJECT=sds-sustainability`  (<-- this should match with the course project name that you created in step 4)
      - `export OSO_REGISTRY=docker-registry.rahti.csc.fi`
      
   2. Login to the Rahti docker image registry from docker and oc (get the tokens from Rahti registry web pages)
   
      - `docker login -p <DOCKER-LOGIN-TOKEN-HERE> -u unused docker-registry.rahti.csc.fi`
      - `oc login --token <OpenShift-LOGIN-TOKEN-HERE> rahti.csc.fi:8443`   
      - Switch to correct project (if needed) by: `oc project sds-sustainability`
      
   3. Tag the image you want to send to the registry
     
      - `docker tag csc/sds-sustainability docker-registry.rahti.csc.fi/sds-sustainability/sds-sustainability:latest`   
 
   4. Push the image to Rahti image registry
   
      - `docker push docker-registry.rahti.csc.fi/sds-sustainability/sds-sustainability:latest`
      
6. Deploy the pushed image to Rahti

  1. Go to https://rahti.csc.fi -> Web user interface -> Choose your project
  2. "Add to project" (top right) -> Deploy image -> Choose your image -> Deploy

7. Add route for the object (make the application publicly available/visible)

  - Applications (left) -> Routes -> Create Route (top right) -> Fill only "Name" and "Service"

8. Add persistent storage 

  1. Create persistent storage:

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
   2. Login to 