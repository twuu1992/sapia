# Create a WAF web acl
resource "aws_wafv2_web_acl" "waf_nginx_acl" {
  name        = "waf-web-acl"
  description = "The acl rule for nginx server"
  scope       = "REGIONAL"

  default_action {
    block {}
  }

  rule {
    name     = "rate-based-rule"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 100 # limit per 5 mins, 100 minimum
        aggregate_key_type = "IP"

        scope_down_statement {
          geo_match_statement {
            country_codes = ["AU"]
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "nginx-rule-metric"
      sampled_requests_enabled   = true
    }
  }

  tags = {
    Name = "waf-web-acl"
  }
}

# Associate WAF with ALB
resource "aws_wafv2_web_acl_association" "waf_alb_association" {
  resource_arn = aws_lb.alb_nginx.arn
  web_acl_arn  = aws_wafv2_web_acl.waf_nginx_acl.arn
}