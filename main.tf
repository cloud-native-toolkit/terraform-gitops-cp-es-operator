locals {
  name               = "ibm-eventstreams-operator"
  bin_dir            = module.setup_clis.bin_dir
  yaml_dir           = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  layer              = "services"
  type               = "operators"
  application_branch = "main"
  layer_config       = var.gitops_config[local.layer]
  values_content = {
    "ibm-eventstreams-operator" = {
      subscriptions = {
        ibmeventstreams = {
          name = "ibm-eventstreams"
          subscription = {
            channel             = var.channel
            installPlanApproval = "Automatic"
            name                = "ibm-eventstreams"
            source              = var.catalog
            sourceNamespace     = var.catalog_namespace
          }
        }
      }
    }
  }
  values_file = "values-${var.server_name}.yaml"
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

resource null_resource create_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
    }
  }
}

resource gitops_module module {
  depends_on = [null_resource.create_yaml]


  name = local.name
  namespace = var.namespace
  content_dir = local.yaml_dir
  server_name = var.server_name
  layer = local.layer
  type = local.type
  branch = local.application_branch
  config = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}


