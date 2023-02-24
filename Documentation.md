ABOUT DEPLOYMENT:

- Application can be accessed using the value of ec2_public_ip
- Application can only be accessed publicly by 3.121.56.176
- EC2 instance can only be accessed from my <myip_address>
- Application runs as a container

STACK:

In the course of this assignment, I decided to host the html application using the following underlying platform:

- Nginx (Web Server)
- Docker (Container Engine)
- Ubuntu (Base OS)

STACK JUSTIFICATION:

I had the option of deploying using AWS Elastic Container Service (ECS) but I chose the to use EC2 because of the following reasons:

- It affords me control over the underlying application infrastructure
- EC2 appears to be the cheaper option when compared to ECS
- Running docker on EC2 affords me more flexibility and control
- I could also use the EC2 for multiple applications (including microservices), should there be need for such
- Migration will most defintiely be easier with the EC2
- Easier to perform security hardenening of the app's platform on the Ubuntu OS since I have full control

INSTRUCTUIONS:

To to run this script within from your PC after cloning the repository, there is need to make some adjustments in order to account for some environment changes. These changes will include:

- Change the value of directory based variables such as; public_key, private_key, script, Dockerfile, & app in the terraform.tfvars file
- Change the value of <myip_address> to your public IP in terraform.tfvars file to allow you SSH access to the EC2 for platform admin purposes
- To adjust the way the container is run, modify script.sh to suite your need
