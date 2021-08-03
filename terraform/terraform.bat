@echo off
::run this first: docker pull hashicorp/terraform
:dockerizedTerraform
setlocal enabledelayedexpansion
:: Initiall set this to 0, remember /A means this is number type
set /A debug = 0
::Set all the incoming argument into another variable, didn't know how to work with %*
set "args=%*"
::echo "start"
::echo Old arguments: %args%
::loop through the arguments, when something we want to is found, flag it
:: if there are more special flags we need to catch then just them here
:: be sure to put quote around both side of comparison
for %%x in (%*) do (
  if "%%x" == "-debug" set /A debug = 1
)
:: If debug flag was set to 1 then remove -debug from the args
if %debug%==1 (
  set "newarg=%args:-debug= %"
  set "debugVar=DEBUG"
) else (
  set "newarg=%args%"
  set "debugVar= "
)
::echo New arguments: %newarg%
:: use -e for passing in environment variables to Docker container
::Need to pass in environment variable for the token file
:: but we need to mount the volume and pass in the remote-end equivalent 
FOR %%i IN ("%TF_CLI_CONFIG_FILE%") DO (
  :: get the folder path
  set "tf_config=%%~di%%~pi"
  :: get the file name and extension
  set "tf_config_file=%%~ni%%~xi"
)
::This will be the mount point for the terraform configuration file
set "TF_CONFIG_PATH=terraform"
::THis will be the new config file location in the remote-end
set "TF_CLI_CONFIG_FILE_NEW=/%TF_CONFIG_PATH%/%tf_config_file%"

::THIS is the default location where terraform will store credential if you do terraform login
:: ON THE HOST end
set "TF_DEFAULT_CREDENTIAL_PATH_HOST=%USERPROFILE%\AppData\Roaming\terraform.d"
:: ON THE CONTAINER end
set "TF_DEFAULT_CREDENTIAL_PATH_REMOTE=/root/.terraform.d"
:: If you drop your credential in your TF_CLI_CONFIG_FILE then you can't run terraform login. Pick one and go with it. 

docker run --rm -it -e TF_LOG=%debugVar% -e TF_CLI_CONFIG_FILE=%TF_CLI_CONFIG_FILE_NEW%  -v %cd%:/data -v %tf_config%:/%TF_CONFIG_PATH% -v %TF_DEFAULT_CREDENTIAL_PATH_HOST%:%TF_DEFAULT_CREDENTIAL_PATH_REMOTE% -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker -w /data terraform:latest %newarg%
::========================================================================
::Below 2 docker commands is how you force this container to keep running... 
:: because entrypoint is set to terraform by default it shutsdown afterward
:: Logging into it is a good way to debug your mounts
::: docker run -d -it --name terraform --entrypoint "/usr/bin/tail" -e TF_LOG=%debugVar% -e TF_CLI_CONFIG_FILE=%TF_CLI_CONFIG_FILE_NEW% -v %cd%:/data -v %tf_config%:/%TF_CONFIG_PATH% -v %TF_DEFAULT_CREDENTIAL_PATH_HOST%:%TF_DEFAULT_CREDENTIAL_PATH_REMOTE% -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker -w /data terraform:latest sh tail -f /dev/null
::: docker exec -it terraform sh
::echo "finish" 
:: 
