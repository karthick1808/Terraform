provider "aws" {
  region = "ap-south-1"
}
resource "aws_instance" "ubuntu" {
  ami           = "ami-08df646e18b182346"
  instance_type = "t2.micro"

}