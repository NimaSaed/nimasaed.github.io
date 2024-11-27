This talk was presented at the Xebia Knowledge Exchange for Xebia's consultants on November 26, 2024.

 [https://xke.xebia.com/events/Yhc5k2atadyRw1q5WG1C/6eMXPFUnyxFccbMQdIJm/modernizing-access-control-authorization-engines](https://xke.xebia.com/events/Yhc5k2atadyRw1q5WG1C/6eMXPFUnyxFccbMQdIJm/modernizing-access-control-authorization-engines)


# From Pet to Cattle: Modernizing Access Control with Open Source Authorization Engines


## Introduction

In today's dynamic systems, managing authorization poses a complex challenge. This presentation will explore the CIE triangle and the DIE model to enhance our understanding of modern data management. We will discuss why data often behaves like a "pet" instead of "cattle," highlighting the implications for effective access control.

The session will introduce the concept of an authorization engine, highlighting its role in securing systems at scale, as well as reviewing some of the leading open-source solutions available today. We will also focus on OpenFGA, showcasing its potential to transform authorization workflows and align access control with modern development practices. Whether you are an engineer, architect, or security enthusiast, this talk will provide you with valuable insights and tools to modernize your authorization strategies

[Excalidraw file](../images/authorization_engine.excalidraw)

[Excalidraw read-only link](https://excalidraw.com/#json=SlfIJDAnZ5gFQK2-MAkV2,-DsDvIQoAUAyzgt7UzOswA)

## OpenFGA demo

### Simple small app


app.sh

```bash
#!/usr/bin/env bash
set -o nounset # Treat unset variables as an error

store_id=$(jq -r .store_id ./output.json)
model_id=$(jq -r .model_id ./output.json)

function fga_check() {

  fga query check --store-id $store_id \
                  --model-id $model_id \
                  user:$1 viewer document:$2 \
                  | jq -r '.allowed'

}

# get user name

read -p "Enter user name: " user_name

# get document id

while true; do

  PS3="Select a document: [none = 0] "

  all_documents=$(ls ./document*)
  select doc in ${all_documents[@]}
  do
      selected=${doc}
      break;
  done

  if [ -z $selected ]; then
    exit;

  else
    docuemt_id=$(echo $selected | grep -oE [1-9])

    if [ "$(fga_check $user_name $docuemt_id)" = "true" ]; then
      echo
      cat $selected
      echo
    else
      echo
      echo "Not Allowed"
      echo
    fi
  fi

done
```

fga-setup.sh

```bash
#!/usr/bin/env bash
set -o nounset # Treat unset variables as an error


store_name="demo_fga"


store_id=$( \
  fga store create --name $store_name | jq -r '.store.id' \
)

model_id=$( \
  fga model write --store-id $store_id \
                  --file ./model.yaml \
                  | jq -r '.authorization_model_id' \
)

fga tuple write --store-id $store_id \
                --model-id $model_id \
                --file ./tuples.yaml


json=$( jq -n \
              --arg store_id "$store_id" --arg model_id "$model_id" \
              '{ "store_id": $store_id, "model_id": $model_id }'
          )
echo $json > output.json
```

model.yaml

```yaml
model
  schema 1.1

type user

type document
   relations
     define viewer : [user]
```

tuples.yaml

```yaml
- user: user:anne
  relation: viewer
  object: document:1

- user: user:peter
  relation: viewer
  object: document:2
```

### OpenFGA test demo

```yaml
name: Model Tests

model: |
  model
    schema 1.1

  type user

  type org
    relations
      define member : [user]
      define document_viewer : [user]

  type document
     relations
       define owner : [org]
       define viewer : document_viewer from owner

tuples:

  - user: user:anne
    relation: document_viewer
    object: org:1

  - user: org:1
    relation: owner
    object: document:1

  - user: user:peter
    relation: document_viewer
    object: org:2

  - user: org:2
    relation: owner
    object: document:2

tests:
  - name: Test Anne
    check:
      - user: user:anne
        object: document:1
        assertions:
          viewer: true

      - user: user:anne
        object: document:2
        assertions:
          viewer: false

      - user: user:anne
        object: document:3
        assertions:
          viewer: false

  - name: Test Peter
    check:
      - user: user:peter
        object: document:1
        assertions:
          viewer: false

      - user: user:peter
        object: document:2
        assertions:
          viewer: true
```
