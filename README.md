## About The Project

This project is designing and building a terraform module, and the components include:
* ECS cluster module, ECS task definition, NGINX image, ECS service, ECS capacity provider based on Fargate and Farget Spot
* VPC, Security Group, Subnets
* IAM role and role policy
* Application Load Balancer, Target Groups, Listeners
* WAF access control list, regrex pattern set, rule statements
* Auto Scaling Group, Launch Template
* Terraform configuration files for two regions: ap-southeast-2, eu-west-1

### Project Structure

- ap-southeast-2
  - terraform.tf
  - main.tf
  - variables.tf
- eu-west-1
  - terraform.tf
  - main.tf
  - variables.tf
- modules
  - nginx
    - vpc
    - ecs
    - iam-role
    - load_balancer
    - waf
    - auto_scaling_group

### Prerequisites

To deploy this module into two regions, you can use the bash script in the root folder
1. Grant execution permit:
```sh
chmod +x ./plan-cmd.sh
```
2. Configure your aws profile by running awscli, now the profile defined in Terraform is "default"
```sh
aws configure
```
3. Run the script
```sh
./plan-cmd.sh
```

### Functionalities

Here are couple of functionalities achieved in this module:
1. WAF set a rate limit rule, which will block the traffic if beyond 100 hits per 5 minutes
2. WAF will block the traffic outside the Australia
3. A rule will check the SQL Injection by inspecting header, body, querystring with transformation and regrex check
4. A rule will check the xss attack with specific regrex check
5. ASG will launch the ec2 instance for Fargate capacity provider, and spot instances for Fargate Spot if the usage reaches 80%
6. IAM role and polices are created for ECS and it can grant permissions to provision resources in AWS

## Roadmap

- [x] Create basic components including ECS, ALB, VPC
- [x] Add WAF service with rate limiter
- [x] Add IAM role and role policy for ECS
- [x] Add capacity providers for Fargate and Fargate Spot, add them into cluster
- [x] Add Auto Scaling Group and link it will capacity providers
- [x] Add WAF rules for SQL Inejction, Xss attack, geo matching
- [x] Configure terraform to be able to deploy in multiple regions
- [ ] Use Terragrunt to manage deployment instead of script
- [ ] Mock attack behavior
