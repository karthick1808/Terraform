terraform {
  required_version = "~= 1.25"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~>3.0"
    }
    http = {
        source = "hashicorp/http"
        version = "~>2.1.0"
    }
  }
}