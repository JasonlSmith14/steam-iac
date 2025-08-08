include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
    source = "../../../modules/aws/s3_bucket"
}

inputs = {
    s3_bucket_name = "${include.root.locals.base_component_name}-raw-data"
}