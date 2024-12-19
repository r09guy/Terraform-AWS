#Making an Application Load Balancer
# Create ALB
resource "aws_lb" "LoadBalancer" {
    name               = "Terraform-Webserver-ALB"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.Terraform-SG.id]
    subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}

# ALB Target Group
resource "aws_lb_target_group" "LoadBalancerTargetGroup" {
    name     = "webserver-target-group"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.Terraform-VPC-test.id

    health_check {
        path                = "/"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 3
        unhealthy_threshold = 3
    }
}

# ALB Listener
resource "aws_lb_listener" "LoadBalancerListener" {
    load_balancer_arn = aws_lb.LoadBalancer.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.LoadBalancerTargetGroup.arn
    }
}

# Register EC2 Instances with the Target Group
resource "aws_lb_target_group_attachment" "LoadBalancerGroupAttachment" {
    count             = 2
    target_group_arn  = aws_lb_target_group.LoadBalancerTargetGroup.arn
    target_id         = aws_instance.Terraform-Apache[count.index].id
    port              = 80
}

#output the ip of the loadbalancer
output "LoadBalancer_IP" {
    value = aws_lb.LoadBalancer.dns_name
}

#Mustafa Karabayir