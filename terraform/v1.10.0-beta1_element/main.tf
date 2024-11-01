output "current" {
  # https://developer.hashicorp.com/terraform/language/functions/element
  value = element(["a", "b", "c"], length(["a", "b", "c"]) - 1)
}

# test for element() function accepts negative indices
locals {
  test = ["A", "B", "C"]
}

check "test" {
  assert {
    condition     = element(local.test, 0) == "A"
    error_message = "not A."
  }
  assert {
    condition     = element(local.test, 1) == "B"
    error_message = "not B."
  }
  assert {
    condition     = element(local.test, 2) == "C"
    error_message = "not C."
  }
  assert {
    condition     = element(local.test, length(local.test) - 1) == "C"
    error_message = "last element is not C."
  }

  assert {
    condition     = element(local.test, -1) == "C"
    error_message = "last element is not C."
  }

}
