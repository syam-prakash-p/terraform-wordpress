
variable "basic"{

type = map
default = {
"key" = "< put your public key file here >"

"ubuntu_ami" = "ami-08962a4068733a2b6"
"amazon_linux_ami" = "ami-09246ddb00c7c4fef"
"type" = "t2.micro"
}
}



variable "db"{
	
	type = map
	default = {

	db_user = "wpuser"
	db_name = "wordpress"
	db_pass = "wpuser2020"
	db_port = 3306

	}
}
