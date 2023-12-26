provider "google" {
  project = "example-project"
  region  = "us-central1"
}

resource "google_storage_bucket" "static-site" {
  name          = "yolocs-image-store.com"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
  cors {
    origin          = ["http://yolo-image-store.com"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

resource "google_pubsub_topic" "example" {
  name = "example-topic"

  labels = {
    foo = "bar"
  }

  message_retention_duration = "86600s"
}

resource "google_org_policy_custom_constraint" "constraint" {

  name   = "custom.disableGkeAutoUpgrade"
  parent = "projects/220951778751"

  action_type    = "ALLOW"
  condition      = "resource.management.autoUpgrade == false"
  method_types   = ["CREATE", "UPDATE"]
  resource_types = ["container.googleapis.com/NodePool"]
}

resource "google_iam_deny_policy" "example" {
  parent       = urlencode("cloudresourcemanager.googleapis.com/projects/example-project")
  name         = "my-deny-policy"
  display_name = "A deny rule"
  rules {
    description = "First rule"
    deny_rule {
      denied_principals = ["principalSet://goog/public:all"]
      denial_condition {
        title      = "Some expr"
        expression = "!resource.matchTag('12345678/env', 'test')"
      }
      denied_permissions = ["cloudresourcemanager.googleapis.com/projects.update"]
    }
  }
}

resource "google_project_iam_member" "project" {
  project = "example-project"
  role    = "roles/editor"
  member  = "user:cshou@google.com"
}

resource "google_project_organization_policy" "serial_port_policy" {
  project    = "example-project"
  constraint = "compute.disableSerialPortAccess"

  boolean_policy {
    enforced = true
  }
}
