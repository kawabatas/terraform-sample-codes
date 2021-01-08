provider "google" {
  project = string
}

resource "google_sql_database_instance" "master" {
  name                = string
  database_version    = "MYSQL_5_7"
  region              = "asia-northeast1"
  deletion_protection = false

  settings {
    tier              = "db-n1-standard-1"
    availability_type = "ZONAL"
    disk_size         = 10
    disk_type         = "PD_SSD"
    disk_autoresize   = false
    backup_configuration {
      enabled = false
    }

    database_flags {
      name  = "character_set_server"
      value = "utf8mb4"
    }
    database_flags {
      name  = "slow_query_log"
      value = "on"
    }
    database_flags {
      name  = "log_output"
      value = "FILE"
    }
    database_flags {
      name  = "long_query_time"
      value = 0.5
    }
    database_flags {
      name  = "innodb_lock_wait_timeout"
      value = 5
    }
    database_flags {
      name  = "max_connections"
      value = 10000
    }

    ip_configuration {
      authorized_networks {
        name  = string
        value = string
      }
    }
  }
}

resource "google_sql_user" "users" {
  name     = string
  instance = google_sql_database_instance.master.name
  host     = "%"
  password = string
}

resource "google_sql_database" "database" {
  name     = string
  instance = google_sql_database_instance.master.name
  charset  = "utf8mb4"
}
