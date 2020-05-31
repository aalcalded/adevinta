
import getopt
import sys
import os
import subprocess

CRED = '\033[91m'
CEND = '\033[0m'
CBLUE = '\033[34m'

def deploy_terraform(command,target,extra,deploy_ami):

  tf_path = "./terraform/adevinta/" 
  tf_init = "terraform init -backend-config=bucket=$TF_VAR_tf_bucket -backend-config=region=$TF_VAR_region"
  tf_workspace="terraform workspace select pro || terraform workspace new pro"
  tf_cmd=""

  try:
    os.chdir(tf_path)
    if deploy_ami:
       deploy_green =" -var=enable_green_webserver=true -var=webserver_green_ami="+deploy_ami
    else:
      deploy_green =""  

    if target=="":
       tf_cmd="terraform "+command+" -var-file=./vars/adevinta.tfvars "+extra+" "+deploy_green
    else:
       tf_cmd="terraform "+command+" -target="+target+" -var-file=./vars/adevinta.tfvars "+extra+" "+deploy_green

    print(CBLUE +"INFO Initializing Terraform"+ CEND)
    os.system (tf_init)
    print(CBLUE +"INFO Selecting Terraform workspace pro"+ CEND)
    os.system (tf_workspace)
    print(CBLUE +"INFO Executing >>> "+tf_cmd+ CEND)
    os.system (tf_cmd)    

  except Exception as e:
    print(CRED + "ERROR Error while executing" +tf_cmd + CEND)
    print e
    raise
   

def deploy_packer(command,target,extra):

    packer_path = "./packer/"

    try:
      os.chdir (packer_path)
      packer_cmd="packer build -machine-readable app.json | tee build.log"
      print(CBLUE +"INFO Executing "+packer_cmd+ CEND)
      os.system (packer_cmd)
      ami_cmd = subprocess.check_output("grep 'artifact,0,id' build.log | cut -d, -f6 | cut -d: -f2", shell=True);
      return ami_cmd

    except Exception as e:
      print(CRED + "ERROR Error while executing " +packer_cmd+ CEND)
      print e
      raise

def deploy(action,command,target,extra):

  try:  
    if action == "green_deploy": 
      (green_ami) = deploy_packer(command,target,extra)
      print (CBLUE + "INFO Green AMI ID: "+green_ami+ CEND)
      os.chdir("../")
      deploy_terraform(command,target,extra,green_ami)

    elif action == "terraform":
      deploy_terraform(command,target,extra,"")

    elif action == "packer":
      (ami) = deploy_packer(command,target,extra)
      print (CBLUE + "INFO New AMI ID: "+ami+ CEND)
 
  except Exception as e:
    print(CRED + "ERROR Error while executing" +action+ CEND)
    print e
    raise

def main(argv):

    action=""
    command=""
    target=""
    extra=""

    try:
       opts, args = getopt.getopt(argv,"ha:c:t:e:",["action=", "command=", "target=", "extra-args="])
    except getopt.GetoptError:
       print (CRED + "adevinta-deploy.py  -a action -c command -t target -e args" + CEND)
       sys.exit(2)

    for opt, arg in opts:
       if opt == "-h":
          print (CBLUE + "adevinta-deploy.py  -a action -c command -t target" + CEND)
          sys.exit()

       elif opt in ("-a", "--action"):
         if arg in ("terraform", "packer", "green_deploy"):
          action= arg  
         else: 
           print (CRED + "The action isn't allowed. Please use -a terraform or -a packer" + CEND)
           sys.exit(2)    

       elif opt in ("-c", "--command"): 
          if arg in ("plan", "apply", "destroy"):
            command = arg  
          else: 
            print (CRED + "This command isn't allowed for terraform" + CEND)
            sys.exit(2)  

       elif opt in ("-t", "--target"):
           target = arg
       elif opt in ("-e", "--extra-args"):
           extra = arg
    deploy (action,command,target,extra)
                  
     

if __name__ == "__main__":
   main(sys.argv[1:])



