
########## vpc variable  #############

variable "vpc"{

	type = map
	default = {

	"cidr" = "172.20.0.0/16"
	"name" = "blog"
	}
}

########## public subnet variables  #############

variable "public"{
	
	type = map
	default = {

	"cidr1" = "172.20.0.0/20"
	"az1" = "us-east-2a"
	"cidr2" = "172.20.16.0/20"
	"az2" = "us-east-2b"
	"cidr3" = "172.20.32.0/20"
	"az3" = "us-east-2a"

	}
}


########## private subnet variables  #############

variable "private"{
	
	type = map
	default = {

	"cidr1" = "172.20.48.0/20"
	"az1" = "us-east-2a"
	"cidr2" = "172.20.64.0/20"
	"az2" = "us-east-2b"
	"cidr3" = "172.20.80.0/20"
	"az3" = "us-east-2a"

	}
}

###################################################

