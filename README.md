
# bastionProject 

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white) 
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Visual Studio Code](https://img.shields.io/badge/Visual%20Studio%20Code-0078d7.svg?style=for-the-badge&logo=visual-studio-code&logoColor=white)
![Git](https://img.shields.io/badge/git-%23F05033.svg?style=for-the-badge&logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)

## What is this? 
In this project I built a secure AWS environment, where one host only (known as a Bastion Host) has access to another host in AWS. I created everything in Terraform, so you can download it too and run it on your local machine.

### Architecture

![Screenshot](/architecture-diagrams/bastion_architecture.png)

- 1 VPC
- 1 Public subnet
- 1 private subnet
- 1 internet gateway
- 2 Route Tables
- 2 EC2 instances

### Prerequisites before installation 

1) You will need your AWS Credentials to hand. 
2) You will need an SSH keypair

### Installation

To install this code on your machine follow these steps: 
1) Download code onto your machine using .zip file or through git cli
2) Open it up in a code editor 
3) If you don't have an SSH keypair, create a keypair from your Terminal
4) Run these commands in your terminal to set up environment variables: 
- `export AWS_ACCESS_KEY_ID="your-access-key-id"` (this will set your access key in the terminal session)
- `export AWS_SECRET_ACCESS_KEY="your-secret"` (this will set your secret access key in the terminal session)
5) Ensure your current IP is set as the IP from which traffic can enter the set up. Type this into your Bash shell: 
- `export TF_VAR_my_ip_address="$(curl -s https://checkip.amazonaws.com)/32"` (This will check your current IP and set that value to the my_ip_address variable) 
6) Then run the Terraform commands: 
- `terraform init`
- `terraform plan`
- `terraform apply` + (select yes) 

### Usage
Follow these steps to check its working: 
1) Log into your AWS console. Locate the public EC2 instance. Check the IP. Insert it directly into your browser and see if you can connect to it using http (**not** https). You should see a html message appear on your screen with the hostname ip and server ip.
2) SSH into the bastion host using the keypair you created.
3) Once inside, create another key file with the same name. Copy and paste the same data from your original key. Then ssh into the private EC2 host


### Licensing 
MIT license