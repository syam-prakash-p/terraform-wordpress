
#################################################
# create vpc
#################################################

resource "aws_vpc" "blog_vpc" {

  cidr_block         = var.vpc.cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc.name
  }
}

################ create 3 public subnets ####################

resource "aws_subnet" "public1" {

  vpc_id     = aws_vpc.blog_vpc.id
  cidr_block =  var.public.cidr1
  availability_zone = var.public.az1
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc.name}-public1"
  }
}


resource "aws_subnet" "public2" {

  vpc_id     = aws_vpc.blog_vpc.id
  cidr_block =  var.public.cidr2
  availability_zone = var.public.az2
   map_public_ip_on_launch = true

  
  tags = {
    Name = "${var.vpc.name}-public2"
  }
}


resource "aws_subnet" "public3" {

  vpc_id     = aws_vpc.blog_vpc.id
  cidr_block =  var.public.cidr3
  availability_zone = var.public.az3
  map_public_ip_on_launch = true

  
  tags = {
    Name = "${var.vpc.name}-public2"
  }
}

################ create private subnet ####################


resource "aws_subnet" "private1" {

  vpc_id     = aws_vpc.blog_vpc.id
  cidr_block =  var.private.cidr1
  availability_zone = var.private.az1
  map_public_ip_on_launch = false


  tags = {
    Name = "${var.vpc.name}-private1"
  }
}


resource "aws_subnet" "private2" {

  vpc_id     = aws_vpc.blog_vpc.id
  cidr_block =  var.private.cidr2
  availability_zone = var.private.az2
   map_public_ip_on_launch = false

  
  tags = {
    Name = "${var.vpc.name}-private2"
  }
}


resource "aws_subnet" "private3" {

  vpc_id     = aws_vpc.blog_vpc.id
  cidr_block =  var.private.cidr3
  availability_zone = var.private.az3
   map_public_ip_on_launch = false

  
  tags = {
    Name = "${var.vpc.name}-private3"
  }
}

############## internet gateway ###############################

resource "aws_internet_gateway" "blog_gw" {

  vpc_id = aws_vpc.blog_vpc.id

  tags = {
    Name = "${var.vpc.name}-igw"
  }
}


############## elastic ip  ###############################

resource "aws_eip" "eip" {
  vpc      = true
}


############## nat gateway ###############################


resource "aws_nat_gateway" "blog_ngw" {

  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "${var.vpc.name}-nat"
  }
}

############## route table for public ##############

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.blog_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.blog_gw.id
  }

  tags = {
    Name = "${var.vpc.name}-route-public"
  }
}


############## route table for private ##############

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.blog_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.blog_ngw.id
  }

  tags = {
    Name = "${var.vpc.name}-route-public"
  }
}


################# public subnet to public route ########

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.public.id
}

################# private subnet to private route ########

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private.id
}

############### bastion security group #######################

resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Allow ssh traffic"
  vpc_id      = aws_vpc.blog_vpc.id

  ingress {
    description = "allow ssh connection from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc.name}-bastion"
  }
}

############### webserver security group #######################

resource "aws_security_group" "webserver" {
  name        = "webserver"
  description = "allow traffic from bastion server,web traffic"
  vpc_id      = aws_vpc.blog_vpc.id

  ingress {
    description = "allow 443 from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "allow 80 from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow ssh connection from bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }  

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc.name}-webserver"
  }
}

############### database security group #######################

resource "aws_security_group" "database" {
  name        = "database"
  description = "Allow 3306 from webserver and 22 from bastion"
  vpc_id      = aws_vpc.blog_vpc.id


    ingress {
    description = "allow 3306 from webserver"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.webserver.id]
  }

  ingress {
    description = "allow ssh connection from bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }  

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc.name}-database"
  }
}

##################  uploading key ########################

resource "aws_key_pair" "key" {
  key_name   = "server-key"
  public_key = var.basic.key
  }


#################### creating bastion instance ##############

resource "aws_instance" "bastion" {

  ami           = var.basic.amazon_linux_ami
  instance_type = var.basic.type
  subnet_id = aws_subnet.public2.id
  vpc_security_group_ids= [aws_security_group.bastion.id ]
  key_name = aws_key_pair.key.key_name

  tags = {
    Name = "${var.vpc.name}-bastion"
  }
}



 #################### creating database instance ##############

resource "aws_instance" "database" {

  ami           = var.basic.amazon_linux_ami
  instance_type = var.basic.type
  subnet_id = aws_subnet.private3.id
  vpc_security_group_ids= [aws_security_group.database.id ]
  key_name = aws_key_pair.key.key_name
  user_data = file("scripts/db_setup.sh")
  tags = {
    Name = "${var.vpc.name}-database"
  }
}




#################### script modify ####################

data "template_file" "wordpress" {
  template = file("scripts/wordpress_setup.sh")
  vars = {
    db_private_ip = aws_instance.database.private_ip
  }
}

 #################### creating webserver instance ##############

resource "aws_instance" "webserver" {

  ami           = var.basic.ubuntu_ami
  instance_type = var.basic.type
  subnet_id = aws_subnet.public1.id
  vpc_security_group_ids= [aws_security_group.webserver.id ]
  key_name = aws_key_pair.key.key_name
  user_data = data.template_file.wordpress.rendered

  tags = {
    Name = "${var.vpc.name}-webserver"
  }
}

###################################################
