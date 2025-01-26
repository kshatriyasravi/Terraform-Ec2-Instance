# Here we are defining the variables for the provider
# were if will ask for the region name while running the code and it will validate the region name as per the condition.
variable "region" {
  description = "The region in which the AWS provider should operate. So please enter the region name in which you want to create the instance."
  # default = "us-west-2" # Here we are using the default region, because it will ask for the region name while running the code
  sensitive = true
  nullable  = false
  type      = string
  validation {
    condition     = contains(["us-west-2", "us-east-1", "us-west-1", "us-east-2", "ap-south-1", "ap-northeast-1", "ap-southeast-1"], var.region)
    error_message = "Please enter the valid region name."
  }

}