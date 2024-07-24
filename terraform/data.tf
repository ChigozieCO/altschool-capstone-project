# Filter out local zones, which are not currently supported 
# with managed node groups
data "aws_availability_zones" "azs" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}