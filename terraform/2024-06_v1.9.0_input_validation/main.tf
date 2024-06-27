# see https://zenn.dev/raki/articles/2024-06-24_terraform_v1.9.0_input_validation

locals {
  # ami の image_id に次のいずれかの番号を使用することにしたい
  include_image_id = [
    "ami-11111",
    "ami-22222",
    "ami-33333"
  ]
}

variable "image_id" {
  type        = string
  description = "The id of the machine image (AMI) to use for the server."

  default = "ami-11111"

  validation {
    # サンプルの validation
    condition     = length(var.image_id) > 4 && substr(var.image_id, 0, 4) == "ami-"
    error_message = "The image_id value must be a valid AMI id, starting with \"ami-\"."
  }

  validation {
    # v1.8.x までならこう書くしかなかった
    condition     = contains(["ami-11111", "ami-22222", "ami-33333"], var.image_id)
    error_message = "The image_id value must be a valid AMI id and must also be one of the following [ami-11111,ami-22222,ami-33333]."
  }

  validation {
    # v1.9.0 からはこう書けるようになった。見やすい！
    condition     = contains(local.include_image_id, var.image_id)
    error_message = format("The image_id value must be a valid AMI id and must also be one of the following %v.", local.include_image_id)
  }
}

output "image_id" {
  value = var.image_id
}
