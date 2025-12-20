for ws in dev staging prod; do
  echo "=== Workspace: $ws ==="
  tofu workspace select $ws
  tofu state list | grep aws_instance.web
  tofu output vpc_id
done
