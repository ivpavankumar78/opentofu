#!/bin/bash
# ~/.spacelift-jwt-config
#cp the script into your home dir as . file
# source ~/.spacelift-jwt-config

# JWT Token (get new token from Postman when expired)
export SPACELIFT_TOKEN="eyJhbGciOiJLTVMiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOlsiaHR0cHM6Ly9wYXZhbjc4LmFwcC5zcGFjZWxpZnQuaW8iXSwiZXhwIjoxNzY3OTkwNzc1LjAwNDY2OSwianRpIjoiMDFLRUg1MVlZVzAyOFNLS01CNkJINUo3QVoiLCJpYXQiOjE3Njc5NTQ3NzUuMDA0NjY5LCJpc3MiOiJhcGkta2V5IiwibmJmIjoxNzY3OTU0Nzc1LjAwNDY2OSwic3ViIjoiYXBpOjowMUtFSDJXWDZNQVI2TUtEMlJNOFZKWlE1MCIsImF2dCI6Imh0dHBzOi8vd3d3LmdyYXZhdGFyLmNvbS9hdmF0YXIvZTQwYTMwOTYyNTIwOGFlMzdhZTAzZGMzZjJlNjgwZDE3YjcyMjNmNjA5MmE4NDcxYzNkNTRiMjI0ZDVmYzlkNi5qcGc_ZD1yb2JvaGFzaFx1MDAyNnNpemU9ODAiLCJjaXAiOiI1NC44Ni41MC4xMzkiLCJwc2EiOiIwMUtFSDUxWjA4M1BIMVZFRzFKUVFCQk5QRCIsIklzTWFjaGluZVVzZXIiOmZhbHNlLCJJc0ludGVncmF0aW9uIjpmYWxzZSwic3ViZG9tYWluIjoicGF2YW43OCIsIm1lbWJlciI6dHJ1ZSwiZnVsbF9uYW1lIjoiY29ubmVjdGZyb21ncmFwaHFsIn0.OM3SfxHLfjB7PXbrgDnP6gnMSJrE3z8w2Zz6U0jbaBly6v4OVg1Z4LnjTxQ7Hi/LPHDuyIBv5BgM+YM5hQ1qxWW9S+CCuoO5rwUW4ogYpACMpuaFLBSm9T5DMclljGI/OGk0773DL7ChsHsKSGqcVlofXPRhUUuWNzA053+NQ1PeXl3csBVBWNvEiTmYSyRmvnzFlrmULUmNBjDI7fMGw7OdKvS51ArMyPRBZI85JX01deh+RvxbO1H0yW+uNi6prVzHV/+7MjXMrsiDnIJpEgFhr1zJJnfvAzlRDim+927BDo416xkEuVcYrSQ+GORpEeXSrRdgrAv6wU5o6pSxHs+tKg4k8z6e8cXYxHWqAVpI6nIt95F3ehk44tdURQUB/m3gQayRB2AF3xRijqYVzEVKEbpoFN1DVQpkJd67fkyMCGOFYTaFvjhmFQR6fQcHamrpNA5zaCH9eMda33Pi/OhdI2HknnoUi814RZtmswZvZP8RH8o0Pxu9Jaa4YNdRTUr6GQkNijrQRw3P2kRQkMsMixfwNHErUzAvoluxGXXcDvLoQQ/u6S7YJMD4ZKFWGim77kvqUqk7aaWeNJufDyXG0fekPs0TZtZahpgHXPr4rH6siN2zRWUZh3lD1nmsWHfXChhUAgEpgRDNw0pFiDJC/swzy0FoeZgr3lyRB74="

export SPACELIFT_ENDPOINT="https://pavan78.app.spacelift.io/graphql"

# Helper aliases
alias spacelift-test='curl -s -X POST "$SPACELIFT_ENDPOINT" -H "Authorization: Bearer $SPACELIFT_TOKEN" -H "Content-Type: application/json" -d "{\"query\":\"query{stacks{id name state}}\"}" | jq .'
alias spacelift-runs='curl -s -X POST "$SPACELIFT_ENDPOINT" -H "Authorization: Bearer $SPACELIFT_TOKEN" -H "Content-Type: application/json" -d "{\"query\":\"query{stack(id:\\\"ec2-demo-stack\\\"){runs{id state type}}}\"}" | jq .'~                                                                
