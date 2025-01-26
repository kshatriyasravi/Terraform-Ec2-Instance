
# This is a resource variable file, were we deifne the variables for the resource.

variable "name" {
  description = "Please enter the name for the EC2 instance."
  type        = string
  nullable    = false
  sensitive   = false
}
variable "environment" {
  description = "Please enter the environment for the EC2 instance."
  type        = string
  nullable    = false
  sensitive   = false
}
variable "owner" {
  description = "Please enter the owner for the EC2 instance."
  type        = string
  nullable    = false
  sensitive   = false
}

# were if will ask for the AMI ID, instance type, key pair, security group, subnet ID, tags while running the code and it will validate the AMI ID, instance type, key pair, security group, subnet ID, tags as per the condition.
# we will use the variable file to pass the values to the resource file.
variable "aws_ami_id" {
  description = "The AMI ID (Amazon Machine Image) for the EC2 instance. So please enter the AMI ID for the EC2 instance."
  # default = "ami-0c55b159cbfafe1f0" # Here we are using the default AMI ID, or if required we can use our own AMI ID
  sensitive = true
  nullable  = false
  type      = string
  # This is a condition were it will validate the AMI ID as per the condition.
  # Like length should be greater than 0. ex: if ami id is not provided then it will throw an error message. 
  # And it will ask for the AMI ID while running the code.
  #And for example if we provided the ami id as (ami-0c55b159cbfafe1f0) then it will take the ami id. 
  #And validate the ami id as per the condition.
  # 1. This is the first condition were it will check the length of the ami id should be 17 characters long.
  validation {
    condition     = length(var.aws_ami_id) == 17
    error_message = "Please enter the valid AMI ID. It should be 17 characters long."
  }
  validation {
    condition     = can(regex("ami-[0-9a-f]{17}", var.aws_ami_id))
    error_message = "Please enter the valid AMI ID. It should be in the format of ami-xxxxxxxxxxxxxxxxx."
  }

}
variable "aws_instance_type" {
  description = "The instance type for the EC2 instance. So please enter the instance type for the EC2 instance."
  # default = "t2.micro" # Here we are using the default instance type, or if required we can use our own instance type
  sensitive = true
  nullable  = false
  type      = string
  # This is a condition were it will validate the instance type as per the condition.
  # Like length should be greater than 0. ex: if instance type is not provided then it will throw an error message.
  # And it will ask for the instance type while running the code.
  # And for example if we provided the instance type as (t2.micro) then it will take the instance type.
  # And validate the instance type as per the condition.
  validation {
    condition     = contains(["t2.micro", "t2.large", "t2.xlarge", "t2.2xlarge", "t2.3xlarge", "t2.4xlarge", "t2.5xlarge", "t2.6xlarge", "t2.7xlarge", "t2.8xlarge"], var.aws_instance_type)
    error_message = "Please enter the valid instance type."
  }
}



