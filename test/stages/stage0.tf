# terraform {
# }
# module "setup_clis" {
#   source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
#   clis   = ["yq", "jq"]
#   # clis   = [“helm”, “rosa”]
# }
# resource "null_resource" "setup_clis" {
#   depends_on = [
#     "module.setup_clis"
#   ]
#   provisioner "local-exec" {
#     #command = “echo -n ‘${module.clis.bin_dir}’ > .bin_dir”
#     command = "echo -n '${module.setup_clis.bin_dir}' > .bin_dir"
#   }
# }

terraform {
  required_providers {
    gitops = {
     source = "cloud-native-toolkit/gitops"
     }
  }
}


module setup_test_clis {
    source = "github.com/cloud-native-toolkit/terraform-util-clis.git"

    bin_dir = "${path.cwd}/test_bin_dir"
    clis = ["kubectl", "oc"]
}


resource local_file bin_dir {
    filename = "${path.cwd}/.bin_dir"


    content = module.setup_test_clis.bin_dir
}