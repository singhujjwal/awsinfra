resource "aws_iam_user" "the-accounts" {
  for_each = toset(["Todd", "James", "Alice", "Dottie"])
  name     = each.key
}

locals {
  myname      = "ujjwal"
  ext_name    = join("/", [local.myname, "singh"])
  format_name = format("%s/%s", local.myname, "Kumar")

}

output "myname" {
  value = local.ext_name
}
output "nyname" {
  value = local.format_name
}

