resource "juju_model" "sdcore" {
  name = var.model_name
}

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
  version    = "1.0.2"
  model_name = var.model_name
}


module "self-signed-certificates" {
  source     = "gatici/self-signed-certificates/juju"
  version    = "1.0.3"
  model_name = var.model_name
}

resource "juju_integration" "nrf-db" {
  model = var.model_name

  application {
    name     = juju_application.nrf.name
    endpoint = "database"
  }

  application {
    name     = var.db_application_name
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
    name     = var.certs_application_name
    endpoint = "certificates"
  }
}

