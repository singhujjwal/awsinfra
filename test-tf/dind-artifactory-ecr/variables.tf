variable "common_tags" {
  type = map(string)
  default = {

    "Application" : "ceks-cluster",
    "BusinessUnit" : "test",
    "Origin" : "terraform",

  }

}