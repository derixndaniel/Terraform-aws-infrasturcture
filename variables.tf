variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "aws_region" {
  default = "us-east-1"

}

variable "environment" {
  default = "Dev"

}

variable "public_subnet_ranges" {
  type = map(object({
    cidr = string
    AZ   = string
  }))
  default = {
    "public1" = {
      cidr = "10.0.0.0/24"
      AZ   = "us-east-1a"
    }

    "public2" = {
      cidr = "10.0.11.0/24"
      AZ   = "us-east-1b"
    }
  }
}

variable "private_subnet_ranges" {

  type = map(object({
    cidr = string
    AZ   = string
  }))
  default = {
    "private1" = {
      cidr = "10.0.2.0/24"
      AZ   = "us-east-1a"
    }

    "private2" = {
      cidr = "10.0.3.0/24"
      AZ   = "us-east-1b"
    }
  }
}

variable "instance_type" {
  default = "t3.micro"
}


