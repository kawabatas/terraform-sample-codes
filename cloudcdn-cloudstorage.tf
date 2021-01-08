# @see
# https://cloud.google.com/blog/ja/products/serverless/serverless-load-balancing-terraform-hard-way
# https://medium.com/cognite/configuring-google-cloud-cdn-with-terraform-ab65bb0456a9

provider "google" {
  project = local.project_id
}

provider "google-beta" {
  project = local.project_id
}

# Variables

locals {
  project_id  = ""
  name        = ""
  region      = ""
  bucket_name = ""
  domain      = ""
}

# Load Balancing resources

resource "google_compute_global_address" "default" {
  name = "${local.name}-address"
}

resource "google_compute_global_forwarding_rule" "default" {
  name = "${local.name}-fwdrule"

  target     = google_compute_target_https_proxy.default.id
  port_range = "443"
  ip_address = google_compute_global_address.default.address
}

resource "google_compute_managed_ssl_certificate" "default" {
  provider = google-beta

  name = "${local.name}-cert"
  managed {
    domains = [local.domain]
  }
}

# TODO: need creating a DNS “A” record set.

resource "google_compute_backend_bucket" "default" {
  provider = google-beta

  name        = "${local.bucket_name}-backend"
  description = "Backend bucket for serving static content through CDN"
  bucket_name = local.bucket_name
  enable_cdn  = true
  cdn_policy {
    cache_mode = "CACHE_ALL_STATIC"
  }
}

resource "google_compute_url_map" "default" {
  name = "${local.name}-urlmap"

  default_service = google_compute_backend_bucket.default.id
}

resource "google_compute_target_https_proxy" "default" {
  name = "${local.name}-https-proxy"

  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

# Outputs

output "load_balancer_ip" {
  value = google_compute_global_address.default.address
}
