include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  databricks_credentials = jsondecode(read_tfvars_file("terraform.tfvars"))
}

dependency "data" {
  config_path = "../data/"

  mock_outputs = {
    data_bucket = "mock-data-bucket"
  }
}

terraform {
    source = "../../../modules/aws/iam_role"
}

inputs = {
   role_name = "${include.root.locals.base_component_name}-databricks-s3-role" 
   role_description = "The role Databricks will use to load/retrieve data to/from s3"
assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${local.databricks_credentials["databricks_catalog_arn"]}", "arn:aws:iam::${include.root.locals.aws_account_id}:role/${include.root.locals.base_component_name}-databricks-s3-role"
        ]
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "${local.databricks_credentials["databricks_external_id"]}"
        }
      }
    }
  ]
}
EOF

   policy_name = "${include.root.locals.base_component_name}-databricks-s3-policy"
   policy_description = ""
   policy_content = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${dependency.data.outputs.s3_bucket_name}",
        "arn:aws:s3:::${dependency.data.outputs.s3_bucket_name}/*"
      ]
    }
  ]
}

EOF
}
