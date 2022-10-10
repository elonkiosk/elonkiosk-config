# Security Group
#D SG for LB accepts only HTTP and HTTPS connections
#D And ignore all other in/egresses
resource "aws_security_group" "sg_alb" {
  name        = "elon-kiosk-lb-sg"
  description = "Load Balancer Security Group"
  vpc_id      = aws_vpc.vpc_main.id

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
  from_port         = var.apiserver_port
  to_port           = var.apiserver_port
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

# ALB
resource "aws_alb" "alb_main" {
  name               = "elon-kiosk-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_alb.id]
  subnets            = [aws_subnet.pub_subnet_az1.id, aws_subnet.pub_subnet_az2.id]
}

## Target Group
resource "aws_alb_target_group" "alb_main_tg_api" {
  name     = "elon-kiosk-alb-tg"
  port     = var.apiserver_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_main.id
}

resource "aws_alb_target_group_attachment" "alb_main_tg_api_attach_az1" {
  target_group_arn = aws_alb_target_group.alb_main_tg_api.arn
  target_id        = aws_instance.apiserver_az1.id
  port             = var.apiserver_port
}

resource "aws_alb_target_group_attachment" "alb_main_tg_api_attach_az2" {
  target_group_arn = aws_alb_target_group.alb_main_tg_api.arn
  target_id        = aws_instance.apiserver_az2.id
  port             = var.apiserver_port
}

## Listeners
resource "aws_alb_listener" "alb_main_listener_http" {
  load_balancer_arn = aws_alb.alb_main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "alb_main_listener_https" {
  load_balancer_arn = aws_alb.alb_main.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate_validation.hz_main_cert_validate.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_main_tg_api.arn
  }
}
