# Create a WAF web acl
resource "aws_wafv2_web_acl" "waf_nginx_acl" {
  name        = "waf-web-acl"
  description = "The acl rule for nginx server"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # Rate limit
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
            country_codes = ["AU"]  # Only allow traffic from countries
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rate-limit-rule-metric"
      sampled_requests_enabled   = true
    }
  }

  # SQL Injection Attack
  rule {
    name     = "sql-injection-rule"
    priority = 2

    action {
      block {}
    }

    statement {
      or_statement {
        statement {
          # Check the header
          regex_pattern_set_reference_statement {
            arn = aws_wafv2_regex_pattern_set.sql_injection_set.arn
            field_to_match {
              single_header {
                name = "user-agent"
              }
            }
            text_transformation {
              priority = 1
              type     = "NONE"
            }
          }
        }

        statement {
          # SQL Injection transformation inspection for body
          # https://docs.aws.amazon.com/waf/latest/developerguide/classic-web-acl-sql-conditions.html
          sqli_match_statement {
            field_to_match {
              body {}
            }
            text_transformation {
              priority = 1
              type     = "CMD_LINE"
            }
            text_transformation {
              priority = 2
              type     = "LOWERCASE"
            }
            text_transformation {
              priority = 3
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 4
              type     = "HTML_ENTITY_DECODE"
            }
            text_transformation {
              priority = 5
              type     = "COMPRESS_WHITE_SPACE"
            }
          }
        }

        statement {
          # Check the query string with sql regrex
          regex_pattern_set_reference_statement {
            arn = aws_wafv2_regex_pattern_set.sql_injection_set.arn
            field_to_match {
              query_string{}
            }

            text_transformation {
              priority = 2
              type     = "NONE"
            }
          }
        }
        statement {
          # Check body with sql regrex
          regex_pattern_set_reference_statement {
            arn = aws_wafv2_regex_pattern_set.sql_injection_set.arn
            field_to_match {
              body {}
            }

            text_transformation {
              priority = 1
              type     = "NONE"
            }
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "sql-injection-rule-metric"
      sampled_requests_enabled   = true
    }
  }

    rule {
    name     = "xss-rule"
    priority = 3

    action {
      block {}
    }

    statement {
      or_statement{
        statement{
          # Header check for Xss
          regex_pattern_set_reference_statement {
            arn = aws_wafv2_regex_pattern_set.xss_set.arn
            field_to_match {
              single_header {
                name = "user-agent"
              }
            }
            text_transformation {
              priority = 1
              type     = "NONE"
            }
          }
        }

        statement{
          # HTTP method transformation check for Xss
          # https://docs.aws.amazon.com/waf/latest/developerguide/classic-web-acl-xss-conditions.html
          xss_match_statement {
            field_to_match {
              method {}
            }

            text_transformation {
              priority = 1
              type     = "CMD_LINE"
            }
            text_transformation {
              priority = 2
              type     = "LOWERCASE"
            }
            text_transformation {
              priority = 3
              type     = "URL_DECODE"
            }

            text_transformation {
              priority = 4
              type     = "HTML_ENTITY_DECODE"
            }

            text_transformation {
              priority = 5
              type     = "COMPRESS_WHITE_SPACE"
            }
          }
        }

        statement{
          # Body check for Xss
          regex_pattern_set_reference_statement {
            arn = aws_wafv2_regex_pattern_set.xss_set.arn
            field_to_match {
              body {}
            }
            text_transformation {
              priority = 1
              type     = "NONE"
            }
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "xss-rule-metric"
      sampled_requests_enabled   = true
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "nginx-acl-metric"
    sampled_requests_enabled   = true
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

# Create the regrex pattern set for SQL Injection
resource "aws_wafv2_regex_pattern_set" "sql_injection_set" {
  name        = "sql-injection-set"
  description = "The regex pattern set for detecting sql injection attack"
  scope       = "REGIONAL"

  regular_expression {
    regex_string = "('(''|[^'])*')|(;)|(\\b(ALTER|CREATE|DELETE|DROP|EXEC(UTE){0,1}|INSERT( +INTO){0,1}|MERGE|SELECT|UPDATE|UNION( +ALL){0,1})\\b)"
  }

  tags = {
    Name = "sql-injection-set"
  }
}

# Create the regrex pattern set for XSS
resource "aws_wafv2_regex_pattern_set" "xss_set" {
  name        = "xss-set"
  description = "The regex pattern set for detecting xss attack"
  scope       = "REGIONAL"

  regular_expression {
    regex_string = "<script.*>"
  }

  regular_expression {
    regex_string = "<iframe.*>"
  }

  regular_expression {
    regex_string = "<object.*>"
  }

  tags = {
    Name = "xss-set"
  }
}