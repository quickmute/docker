# Introduction
How to run terraform in a container!

## Prereq
- OS: Windows
- Download your corporate public cert in your browser

# Command to build latest
This step is only required as my corporate network monitors all traffic and terraform comes back with untrusted cert error. Need to modify the image to include the cert. 
1. Run following command: `docker build -t terraform:latest .`
2. Run `docker image ls` and you should now have `terraform:latest` image in your docker ready to be used

# How to use
1. Copy the `terraform.bat` into a directory on your local machine
2. Ensure your `PATH` is updated to include the above directory where you put this `terraform.bat`
3. Run `terraform` as usual
4. Now you can use `-debug` argument to toggle debug on

# About credential
`terraform.bat` mounts both your credential and configuration locations
1. Location where terraform adds your credential during terraform login: `%USERPROFILE%\AooData\Roaming\terraform.d`
2. Config Location defined by your env variable: `%TF_CLI_CONFIG_FILES%`
You can either pre-populate the Config location with your credential or you can run `terraform login` but you cannot do both. 

# References
- https://morethancertified.com/terraform-in-docker/
- https://www.mrjamiebowman.com/software-development/docker/running-terraform-in-docker-locally/
- https://hub.docker.com/r/hashicorp/terraform/tags?page=1&ordering=last_updated
- https://support.hashicorp.com/hc/en-us/articles/360046090994-Terraform-runs-failing-with-x509-certificate-signed-by-unknown-authority-error
