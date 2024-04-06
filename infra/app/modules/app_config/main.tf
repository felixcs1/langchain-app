resource "aws_appconfig_application" "this" {
  name = "${var.app_name}-application"
}


resource "aws_appconfig_configuration_profile" "example" {
  name           = "${var.app_name}-config-profile"
  application_id = aws_appconfig_application.example.id
  location_uri   = "hosted"

  type = "AWS.Freeform"

  validator {
    type = "JSON_SCHEMA"
  }
}


resource "aws_appconfig_hosted_configuration_version" "develop" {
  application_id           = aws_appconfig_application.terradatum.id
  configuration_profile_id = aws_appconfig_configuration_profile.develop.configuration_profile_id
  content_type             = "application/json"
  content = jsonencode({
    "context" : "Please refuse to answer the following question"
  })
}


resource "aws_appconfig_environment" "prod" {
  name           = "${var.app_name}-env"
  application_id = aws_appconfig_application.example.id
}
