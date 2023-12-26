# tf-playground

1. `terraform plan -o temp`
2. `terraform show -json temp | gcpconv`

Supported resources are listed [here](https://github.com/GoogleCloudPlatform/terraform-google-conversion/blob/main/tfplan2cai/converters/google/resources/resource_converters.go).
