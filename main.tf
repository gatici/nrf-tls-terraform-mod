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
  model_name = juju_application.nrf.model
}


module "self-signed-certificates" {
  source     = "gatici/self-signed-certificates/juju"
  model_name = juju_application.nrf.model
}

resource "juju_integration" "nrf-db" {
  model = juju_application.nrf.model

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
  model = juju_application.nrf.model

  application {
    name     = juju_application.nrf.name
    endpoint = "certificates"
  }

  application {
    name     = var.certs_application_name
    endpoint = "certificates"
  }
}

