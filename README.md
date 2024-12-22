# Terraform-AWS  
Welcome! I am Mustafa Karabayir, the creator of this project. This project demonstrates how to set up a scalable and functional infrastructure on AWS (Amazon Web Services) using Terraform. The infrastructure includes components such as a VPC, subnets, instances, load balancers, and more, tailored to support a web-based application, with added provisioning for an Ansible server and two Ansible clients.

## Project Overview  
This project sets up an AWS infrastructure containing:

- **VPC (Virtual Private Cloud)** with 2 subnets:  
    - One with an internet gateway  
    - One without an internet gateway  

- **8 EC2 Instances:**  
    - Two web servers running Apache, mounted on an EFS (Elastic File System) to serve shared content  
    - One API server running a Lambda function to process file uploads  
    - One MySQL server to store metadata about uploaded files  
    - One secondary mount client for redundancy  
    - **One Ansible server** for configuration management and automation  
    - **Two Ansible clients** to be managed by the Ansible server  

- **Elastic File System (EFS):** Shared storage across web servers  
- **S3 Bucket:** To store uploaded files  
- **Application Load Balancer (ALB):** To distribute traffic to web servers  
- **Lambda Function:** To handle file uploads via an API Gateway  
- **Security Groups:** To define inbound and outbound rules  

## How It Works  
### Infrastructure Setup  
#### Terraform Configuration:  
The repository contains Terraform configuration files to define and manage cloud infrastructure.  

#### Jenkins Pipeline:  
A Jenkins pipeline is integrated with the repository to automate the deployment process:  
- Whenever changes are pushed to the GitLab repository, a webhook triggers the Jenkins pipeline.  
- Jenkins pulls the latest code, authenticates with AWS using credentials, and applies the Terraform configuration to ensure the infrastructure remains up to date.  

#### GitLab Integration:  
The integration between GitLab and Jenkins ensures that any changes to the infrastructure code are automatically reflected in the AWS environment.  

### Components:  
#### Networking  
- **VPC with CIDR block** `10.0.0.0/16`  
- **Subnets:** Two subnets for public and private access  
- **Internet Gateway:** For internet connectivity  
- **Route Tables:** Configured for internet access  

#### Compute and Storage  
- **EC2 Instances:** Web servers, API server, MySQL server, Ansible server, and Ansible clients  
- **EFS:** Shared storage across web servers  
- **S3 Bucket:** Secure storage for uploaded files  

#### Security  
- **Security Groups:** Configured for HTTP, SSH, MySQL, and ICMP traffic  
- **IAM Roles and Policies:** For Lambda and S3 access  

#### Application Layer  
- **API Gateway:** HTTP-based API for Lambda function  
- **Lambda Function:** Handles file uploads and stores them in S3  
- **Application Load Balancer:** Distributes traffic among web servers  

#### Ansible Integration  
- **Ansible Server:** Provisioned to manage configurations and automate tasks  
- **Ansible Clients:** Two instances configured to connect to the Ansible server for centralized management  

## Deployment Steps  
### Prerequisites  
- Install Terraform.  
- Configure your AWS credentials.  
- Ensure your public SSH key is available.  
- Ensure Jenkins and GitLab are properly configured.  

### Deploy Infrastructure Using Terraform  
1. Clone the repository:  
    ```bash  
    git clone https://gitlab.com/<your-repo-name>.git  
    cd <project-folder>  
    git init  
    git add .  
    git commit -m "some message"  
    git push  
    ```  

2. Initialize Terraform:  
    ```bash  
    terraform init  
    ```  

3. Review the execution plan:  
    ```bash  
    terraform plan  
    ```  

4. Apply the configuration:  
    ```bash  
    terraform apply  
    ```  

## Usage  
### File Upload API  
To upload a file, use the following command:  
```bash  
curl -X POST -H "filename: <File Name .extension>" -d "<Your Message>" <API URL from Terraform output>  
```  
Example:  
```bash  
curl -X POST -H "filename: example.txt" -d "Hello from Mustafa!" https://<api-url>/production/upload  
```  
The uploaded file will appear in the S3 bucket and can be accessed through the web application.  

### Example Commands  
#### Upload File Using API:  
```bash  
curl -X POST -H "filename: example.txt" -d "Sample message" https://<api-url>/production/upload  
```  
#### Query MySQL:  
```bash  
sudo mysql -h 10.0.1.31 -u remote -premote -e 'SELECT * FROM files.file'  
```  

### Manage Ansible Clients  
- SSH into the Ansible server:  
    ```bash  
    ssh -i <keyfile> ubuntu@<ansible-server-ip>  
    ```  
- Configure Ansible playbooks and inventory to manage clients.  

## Acknowledgements  
Thank you for exploring this project. Feel free to modify and expand upon it to suit your needs!
