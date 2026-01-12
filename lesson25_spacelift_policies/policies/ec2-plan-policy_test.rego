
package spacelift_test

# Import the policy under test
import data.spacelift

# ============================================================================
# TEST: Instance Type Rules
# ============================================================================

# Test: Approved instance type should pass
test_approved_instance_type_dev if {
    result := spacelift.deny with input as {
        "terraform": {
            "plan": {
                "resource_changes": [{
                    "address": "aws_instance.test",
                    "type": "aws_instance",
                    "change": {
                        "actions": ["create"],
                        "after": {
                            "instance_type": "t3.micro",
                            "tags": {
                                "Environment": "dev",
                                "Owner": "team@example.com",
                                "Name": "test-instance"
                            },
                            "associate_public_ip_address": false,
                            "root_block_device": [{"encrypted": true, "volume_size": 20}],
                            "metadata_options": {"http_tokens": "required"},
                            "monitoring": true
                        }
                    }
                }]
            }
        }
    }
    count(result) == 0
}

# Test: Unapproved instance type should be denied
test_unapproved_instance_type if {
    result := spacelift.deny with input as {
        "terraform": {
            "plan": {
                "resource_changes": [{
                    "address": "aws_instance.test",
                    "type": "aws_instance",
                    "change": {
                        "actions": ["create"],
                        "after": {
                            "instance_type": "m5.xlarge",
                            "tags": {
                                "Environment": "dev",
                                "Owner": "team@example.com",
                                "Name": "test-instance"
                            },
                            "associate_public_ip_address": false,
                            "root_block_device": [{"encrypted": true, "volume_size": 20}],
                            "metadata_options": {"http_tokens": "required"},
                            "monitoring": true
                        }
                    }
                }]
            }
        }
    }
    count(result) > 0
}

# ============================================================================
# TEST: Required Tags
# ============================================================================

# Test: Missing Owner tag should be denied
test_missing_owner_tag if {
    result := spacelift.deny with input as {
        "terraform": {
            "plan": {
                "resource_changes": [{
                    "address": "aws_instance.test",
                    "type": "aws_instance",
                    "change": {
                        "actions": ["create"],
                        "after": {
                            "instance_type": "t3.micro",
                            "tags": {
                                "Environment": "dev",
                                "Name": "test-instance"
                            },
                            "associate_public_ip_address": false,
                            "root_block_device": [{"encrypted": true, "volume_size": 20}],
                            "metadata_options": {"http_tokens": "required"},
                            "monitoring": true
                        }
                    }
                }]
            }
        }
    }
    count(result) > 0
}

# ============================================================================
# TEST: Public IP Rules
# ============================================================================

# Test: Public IP in prod should be denied
test_public_ip_in_prod_denied if {
    result := spacelift.deny with input as {
        "terraform": {
            "plan": {
                "resource_changes": [{
                    "address": "aws_instance.test",
                    "type": "aws_instance",
                    "change": {
                        "actions": ["create"],
                        "after": {
                            "instance_type": "t3.small",
                            "tags": {
                                "Environment": "prod",
                                "Owner": "team@example.com",
                                "Name": "test-instance"
                            },
                            "associate_public_ip_address": true,
                            "root_block_device": [{"encrypted": true, "volume_size": 20}],
                            "metadata_options": {"http_tokens": "required"},
                            "monitoring": true
                        }
                    }
                }]
            }
        }
    }
    count(result) > 0
}

# Test: Public IP in dev should be allowed
test_public_ip_in_dev_allowed if {
    result := spacelift.deny with input as {
        "terraform": {
            "plan": {
                "resource_changes": [{
                    "address": "aws_instance.test",
                    "type": "aws_instance",
                    "change": {
                        "actions": ["create"],
                        "after": {
                            "instance_type": "t3.micro",
                            "tags": {
                                "Environment": "dev",
                                "Owner": "team@example.com",
                                "Name": "test-instance"
                            },
                            "associate_public_ip_address": true,
                            "root_block_device": [{"encrypted": true, "volume_size": 20}],
                            "metadata_options": {"http_tokens": "required"},
                            "monitoring": true
                        }
                    }
                }]
            }
        }
    }
    not contains_public_ip_denial(result)
}

contains_public_ip_denial(results) if {
    some r in results
    contains(r, "Public IP")
}

# ============================================================================
# TEST: Encryption Rules
# ============================================================================

# Test: Unencrypted volume should be denied
test_unencrypted_volume_denied if {
    result := spacelift.deny with input as {
        "terraform": {
            "plan": {
                "resource_changes": [{
                    "address": "aws_instance.test",
                    "type": "aws_instance",
                    "change": {
                        "actions": ["create"],
                        "after": {
                            "instance_type": "t3.micro",
                            "tags": {
                                "Environment": "dev",
                                "Owner": "team@example.com",
                                "Name": "test-instance"
                            },
                            "associate_public_ip_address": false,
                            "root_block_device": [{"encrypted": false, "volume_size": 20}],
                            "metadata_options": {"http_tokens": "required"},
                            "monitoring": true
                        }
                    }
                }]
            }
        }
    }
    count(result) > 0
}
