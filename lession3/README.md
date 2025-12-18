
ssh-keygen -t rsa

add the key into the keypair import and create key - give that key name when you are trying to apply plan
 
tofu init, tofu validate, tofu plan
 
tofu plan -var="aws_region=us-east-1" -var="environment=dev" -var="create_key_pair=true".......
 
 
tofu apply -var="key_pair_name=jp_rsa_key"

tofu graph | dot -Tpng > graph.png

 sudo apt install graphviz
 
 tofu show

 tofu apply -auto-approve