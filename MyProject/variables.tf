variable "cidr_block" {
    type = list(string)
    
}
variable "ports" {
    type = list(number)
   
}
variable "ami" {
    type =  string 
  
}
variable "instance_type" {
    type = string
}

variable "instance_type_nexus" {
    type = string
}
