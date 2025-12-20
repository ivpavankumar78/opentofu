for ws in dev staging prod; do
  echo "Destroying $ws environment..."
  tofu workspace select $ws
  tofu destroy -auto-approve
done
