#!/bin/bash
# Spacelift GraphQL Query Script (Fixed Escaping)

STACK_ID="testingone"
SPACELIFT_ENDPOINT="https://pavan78.app.spacelift.io/graphql"
SPACELIFT_TOKEN="eyJhbGciOiJLTVMiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOlsiaHR0cHM6Ly9wYXZhbjc4LmFwcC5zcGFjZWxpZnQuaW8iXSwiZXhwIjoxNzY4MDU2NjQxLjQ3MTgyNCwianRpIjoiMDFLRUszVzFOWlQ0SlpNSDMyOFBXOVFZMzUiLCJpYXQiOjE3NjgwMjA2NDEuNDcxODI0LCJpc3MiOiJhcGkta2V5IiwibmJmIjoxNzY4MDIwNjQxLjQ3MTgyNCwic3ViIjoiYXBpOjowMUtFSDJXWDZNQVI2TUtEMlJNOFZKWlE1MCIsImFkbSI6dHJ1ZSwiYXZ0IjoiaHR0cHM6Ly93d3cuZ3JhdmF0YXIuY29tL2F2YXRhci9lNDBhMzA5NjI1MjA4YWUzN2FlMDNkYzNmMmU2ODBkMTdiNzIyM2Y2MDkyYTg0NzFjM2Q1NGIyMjRkNWZjOWQ2LmpwZz9kPXJvYm9oYXNoXHUwMDI2c2l6ZT04MCIsImNpcCI6IjM0LjkzLjkxLjIwMSIsInBzYSI6IjAxS0VLM1cxUFRQRDVWVFhaVkROUUE3RDJBIiwiSXNNYWNoaW5lVXNlciI6ZmFsc2UsIklzSW50ZWdyYXRpb24iOmZhbHNlLCJzdWJkb21haW4iOiJwYXZhbjc4IiwibWVtYmVyIjp0cnVlLCJmdWxsX25hbWUiOiJjb25uZWN0ZnJvbWdyYXBocWwifQ.V6dJo908kRZCVCNTHf/WaPMa6lEmbaXWzz2lpkZNKqbRIPFmhi7XIqnvel40aE1bBjpz0z7jS4cZB3yyJZkC1f6Cg+Gr5+3lZzClbQYiYKsB0xyRT3f30mZZWFbdZ4psC8pizvb11Fllp6LsSVlymGi/DpxtOjr1SBS4UWvJJZQkc5ELJGeWtXmTy3MvPZbFN/vCow0eqex7gMFvxVcZXnb4DHKNpm5DLYOdDaR/IXOREzusSAcZqT/XMmucMFCJVfN6BkE0lOh69FBzNuu7hX+tajWnVThwdM5T5P/W6/XFx0Ss4z0tIgA1jfEG1sd/57uYzlqtxUxCHnFkUDhbF3vzdlUXDr3UKg356qpXVHHlFtFkqAE0OrGLFFoVPpFtjSwyZNL2dr2WNtmqqI3yJet/308w6KK0hokrJnGU99Ge8pgOivsmHj7M4eA/PBm3tj1+3W6T40NRNkQaZkVBjcHwU4d13eayhU2I8dhWI8njntN5I19F9Gl0BnCiowLEDfS04wIXW+s52ftbUYEk4wPw/wWvxRmTXVDVAbn6NqMDqdlJUqf9ptRq7u6JidJh7pkglFRIJaCT3OjVmpv4z3wbnf3sOBobB2iCEgRlPlyCqhcIeJA/R9UVdICrEx7+biVMe+32K3Fa552kD3sPYqFV82mctOJh4RfZTGSd9KE="

query() {
    curl -s -X POST "$SPACELIFT_ENDPOINT" \
        -H "Authorization: Bearer $SPACELIFT_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$1"
}

echo "=== Stacks ==="
query '{"query":"query{stacks{id name state}}"}' | jq '.data.stacks'


#    id
#    name
#    space            # the space the stack belongs to
#    branch
#    repository
#    namespace
#    state            # overall stack/run state
#    description
#    labels


echo -e "\n=== Stack Details ==="
query "{\"query\":\"query{stack(id:\\\"$STACK_ID\\\"){id name state space repository autodeploy}}\"}" | jq '.data.stack'

echo -e "\n=== Outputs ==="
query "{\"query\":\"query{stack(id:\\\"$STACK_ID\\\"){outputs{id value}}}\"}" | jq '.data.stack.outputs'

echo -e "\n=== Recent Runs ==="
query "{\"query\":\"query{stack(id:\\\"$STACK_ID\\\"){runs{id state type createdAt}}}\"}" | jq '.data.stack.runs[:5]'
