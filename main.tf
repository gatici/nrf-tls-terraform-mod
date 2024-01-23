resource "juju_application" "nrf" {
  name = "nrf"
  model = var.model_name

  charm {
    name = "sdcore-nrf-k8s"
    channel = var.channel
  }

  units = 1
  trust = true
}

module "mongodb-k8s" {
  source     = "gatici/mongodb-k8s/juju"
  model_name = var.model_name
}


module "self-signed-certificates" {
  source     = "gatici/self-signed-certificates/juju"
  model_name = var.model_name
}

resource "juju_integration" "nrf-db" {
  model = var.model_name

  application {
    name     = juju_application.nrf.name
    endpoint = "database"
  }

  application {
    name     = module.mongodb-k8s.db_application_name
    endpoint = "database"
  }
}

resource "juju_integration" "nrf-certs" {
  model = var.model_name

  application {
    name     = juju_application.nrf.name
    endpoint = "certificates"
  }

  application {
    name     = module.self-signed-certificates.certs_application_name
    endpoint = "certificates"
  }
}

