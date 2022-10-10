# Security Group
#D SG for LB accepts only HTTP and HTTPS connections
#D And ignore all other in/egresses
resource "aws_security_group" "sg_alb" {
  name = "elon-kiosk-lb-sg"
  description = "Load Balancer Security Group"
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "elon-kiosk-lb-sg"
  }
}

## SG Rules
### Ingress
resource "aws_security_group_rule" "sg_alb_rule_ing_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_alb.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "sg_alb_rule_ing_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_alb.id

  lifecycle {
    create_before_destroy = true
  }
}

### Egress
resource "aws_security_group_rule" "sg_alb_rule_eg_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_alb.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "sg_alb_rule_eg_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_alb.id

  lifecycle {
    create_before_destroy = true
  }
}
