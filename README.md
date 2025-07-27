# A perlite own webserver hosting with GCP for self hosting with zero-scalling feature
Original perlite web : https://github.com/secure-77/Perlite.git

# Introduction 
# why this project 
# what need for this project 
# explaining each file in the project 
# how to implement obsidian git gcloud bucket automaet 
# how to deploy with git action and wrokfiles. 

# How to implement 
# how to deploy gcloud run
# add auth to the webserver for robest user control or restrict all user and user a proxy using cloud run proxy 
## 1. **Test with the Cloud Run Proxy (Recommended for Browsers)**

Google provides a simple way to proxy your private Cloud Run service to your local machine, automatically handling authentication:

1. **Open your terminal and run:**
    
    text
    
    `gcloud run services proxy SERVICE_NAME --project=YOUR_PROJECT_ID`
    
    Replace `SERVICE_NAME` and `YOUR_PROJECT_ID` appropriately.
    
2. This command will expose the service at `http://localhost:8080` on your machine, **including the proper authentication token automatically**.
    
3. Now, you can open `http://localhost:8080` in your browser and interact with your service exactly as an authenticated user[2](https://cloud.google.com/run/docs/triggering/https-request)[3](https://docs.gitlab.com/tutorials/create_and_deploy_web_service_with_google_cloud_run_component/).
    


- Deploying An perlite forked webserver for a self hosting website for personal Use

- Create a Gcloud bucket in your gcloud for putting your obsidian files 

- push your obsidian files to a github repo 

- automate your application to push the new updates in the gcloud bucket automatically when a new push i happen . same wise you can install git plugin in obsidian and connect your auto-rollout-to-gcloud repo in the obsidian plugin for easywork. 
obsidian plugin : https://github.com/Vinzent03/obsidian-git.git






- deploy the perlite web app in google run (for low cost for personnal use and free so cost): now it supports volumes attachment with gcloud bucket. if that possible (i dint tryed that) attach the conainer directly and replace the entrypoint.sh to work with your conatiner or remove it as your wise

- our gcloud app will automaticly fetech the new updates on the bucket 

- note only the gcloud run is service based and opted for personal use(based of request type instance will scale to 0 when not used ) : your personal web app for obsidian notes.

- after deploying the service you will know able to access the website with 





