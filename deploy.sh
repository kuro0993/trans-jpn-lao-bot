#/bin/bash

gcloud functions deploy trans-jpn-lao \
--gen2 \
--region=asia-northeast2 \
--runtime=ruby33 \
--source=./app/ \
--env-vars-file=.env.yaml \
--entry-point=translate \
--trigger-http