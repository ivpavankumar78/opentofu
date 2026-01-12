
package spacelift

# ============================================================================
# CONFIGURATION - Approved Values
# ============================================================================

# Approved instance types by environment
approved_instance_types := {
  "dev": ["t3.micro", "t3.small", "t2.micro", "t2.small"],
  "staging": ["t3.micro", "t3.small", "t3.medium"],
  "prod": ["t3.small", "t3.medium", "t3.large", "t3.xlarge"],
}

# Required tags for all EC2 instances
required_tags := ["Environment", "Owner", "Name"]

# Maximum root volume size in GB
max_root_volume_gb := 100

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Check if a resource is an EC2 instance being created or updated
is_ec2_instance(resource) if {
  resource.type == "aws_instance"
  resource.change.actions[_] != "delete"
}

# Check if a resource is a security group rule being created or updated
is_security_group_rule(resource) if {
  resource.type == "aws_security_group_rule"
  resource.change.actions[_] != "delete"
}

# Check if a resource is a security group being created or updated
is_security_group(resource) if {
  resource.type == "aws_security_group"
  resource.change.actions[_] != "delete"
}

# Get the planned values (after) for a resource
planned_values(resource) := resource.change.after

# Get environment from tags; prefer tags (or tags_all if you want to honor provider defaults)
# Fallback to "unknown" when not set.
get_environment(resource) := env if {
  values := planned_values(resource)
  values.tags != null
  env := values.tags.Environment
  env != null
  env != ""
}
get_environment(resource) := "unknown" if {
  # Fallback when Environment tag is missing/empty
  values := planned_values(resource)
  values.tags == null
} else if {
  values := planned_values(resource)
  values.tags.Environment == null
} else if {
  values := planned_values(resource)
  values.tags.Environment == ""
}

# Helper: membership check for approved instance types in the given environment
approved_type(env, it) if {
  approved := approved_instance_types[env]
  approved[_] == it
}

# ============================================================================
# DENY RULES - Block Non-Compliant Changes
# ============================================================================

# RULE 1: Enforce approved instance types
deny[reason] if {
  rc := input.terraform.plan.resource_changes[_]
  is_ec2_instance(rc)

  values := planned_values(rc)
  instance_type := values.instance_type
  env := get_environment(rc)

  # Only evaluate if we have an env key in our map; unknown envs will fail membership
  approved_instance_types[env]  # ensure env exists
  not approved_type(env, instance_type)

  reason := sprintf(
    "EC2 instance %q: Instance type %q is not approved for %s environment. Approved types: %v",
    [rc.address, instance_type, env, approved_instance_types[env]],
  )
}

# RULE 2: Enforce required tags
deny[reason] if {
  rc := input.terraform.plan.resource_changes[_]
  is_ec2_instance(rc)

  values := planned_values(rc)
  required_tag := required_tags[_]

  # Tag is missing or empty
  not values.tags[required_tag]

  reason := sprintf(
    "EC2 instance %q: Required tag %q is missing. All instances must have: %v",
    [rc.address, required_tag, required_tags],
  )
}

# RULE 3: Block public IPs in production
deny[reason] if {
  rc := input.terraform.plan.resource_changes[_]
  is_ec2_instance(rc)

  values := planned_values(rc)
  env := get_environment(rc)

  env == "prod"
  values.associate_public_ip_address == true

  reason := sprintf(
    "EC2 instance %q: Public IP addresses are not allowed in production. Use a load balancer or bastion host instead.",
    [rc.address],
  )
}

# RULE 4: Require encrypted root volumes
deny[reason] if {
  rc := input.terraform.plan.resource_changes[_]
  is_ec2_instance(rc)

  values := planned_values(rc)
  root_block := values.root_block_device[_]

  root_block.encrypted != true

  reason := sprintf(
    "EC2 instance %q: Root volume must be encrypted. Set encrypted = true in root_block_device.",
    [rc.address],
  )
}

# RULE 5: Limit root volume size
deny[reason] if {
  rc := input.terraform.plan.resource_changes[_]
  is_ec2_instance(rc)

  values := planned_values(rc)
  root_block := values.root_block_device[_]

  root_block.volume_size > max_root_volume_gb

  reason := sprintf(
    "EC2 instance %q: Root volume size %d GB exceeds maximum allowed %d GB.",
    [rc.address, root_block.volume_size, max_root_volume_gb],
  )
}

# RULE 6: Block 0.0.0.0/0 SSH access
deny[reason] if {
  rc := input.terraform.plan.resource_changes[_]
  is_security_group_rule(rc)

  values := planned_values(rc)

  values.type == "ingress"
  values.from_port <= 22
  values.to_port >= 22

  cidr := values.cidr_blocks[_]
  cidr == "0.0.0.0/0"

  reason := sprintf(
    "Security group rule %q: SSH (port 22) access from 0.0.0.0/0 is not allowed. Use specific CIDR ranges.",
    [rc.address],
  )
}

# ============================================================================
# WARN RULES - Advisory Messages (Don't Block)
# ============================================================================

# WARN: Recommend IMDSv2
warn[reason] if {
  rc := input.terraform.plan.resource_changes[_]
  is_ec2_instance(rc)

  values := planned_values(rc)
  metadata := values.metadata_options

  metadata != null
  metadata.http_tokens != "required"

  reason := sprintf(
    "EC2 instance %q: Consider enabling IMDSv2 by setting http_tokens = 'required' in metadata_options.",
    [rc.address],
  )
}

# WARN: Large instance types in dev
warn[reason] if {
  rc := input.terraform.plan.resource_changes[_]
  is_ec2_instance(rc)

  values := planned_values(rc)
  env := get_environment(rc)

  env == "dev"
  contains(values.instance_type, "large")

  reason := sprintf(
    "EC2 instance %q: Using %q in dev environment. Consider a smaller instance to reduce costs.",
    [rc.address, values.instance_type],
  )
}

# WARN: Missing detailed monitoring in prod
warn[reason] if {
  rc := input.terraform.plan.resource_changes[_]
  is_ec2_instance(rc)

  values := planned_values(rc)
  env := get_environment(rc)

  env == "prod"
  values.monitoring != true

  reason := sprintf(
    "EC2 instance %q: Detailed CloudWatch monitoring is recommended for production instances.",
    [rc.address],
  )
}
