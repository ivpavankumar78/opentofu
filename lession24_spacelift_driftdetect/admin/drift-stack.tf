# admin/drift-stack.tf
# Manage drift detection lab stack via OpenTofu

resource "spacelift_stack" "drift_lab" {
  name        = "drift-detection-lab"
  description = "Lab environment for drift detection training"
  
  repository   = "drift-detection-lab"
  branch       = "main"
  project_root = "stacks/drift-lab"
  
  # Use OpenTofu
  terraform_workflow_tool = "OPEN_TOFU"
  
  # Enable state management
  manage_state = true
  
  # Labels for organization
  labels = ["training", "drift-detection", "lab"]
}

# Configure Drift Detection
resource "spacelift_drift_detection" "drift_lab" {
  stack_id = spacelift_stack.drift_lab.id
  
  # Run drift detection every 4 hours
  schedule = ["0 */4 * * *"]
  
  # Reconcile drift automatically (use with caution!)
  reconcile = false
  
  # Ignore specific runs from triggering alerts
  ignore_state = false
  
  # Timezone for schedule
  timezone = "UTC"
}