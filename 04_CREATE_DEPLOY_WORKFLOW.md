# Migration Step 2.4: Create Deployment Workflow

**Objective:** Create the workflow that receives deployment requests and executes the `deploy.sh` script.

**Action:** Create the file `.github/workflows/deploy.yml`.

**Agent Task:**
```
write_file(file_path='/home/qtym/system-management/.github/workflows/deploy.yml', content='''
name: Deploy Application

on:
  repository_dispatch:
    types: [deploy-app]

jobs:
  deploy:
    runs-on: self-hosted # This must run on your local machine
    steps:
      - name: Checkout system-management repository
        uses: actions/checkout@v3

      - name: Parse Dispatch Payload
        id: payload
        run: |
          echo "service=${{ github.event.client_payload.service }}" >> $GITHUB_OUTPUT
          echo "tag=${{ github.event.client_payload.tag }}" >> $GITHUB_OUTPUT
          echo "environment=${{ github.event.client_payload.environment }}" >> $GITHUB_OUTPUT

      - name: Execute Deployment Script
        run: |
          bash scripts/deploy.sh ${{ steps.payload.outputs.environment }} ${{ steps.payload.outputs.service }} ${{ steps.payload.outputs.tag }}
''')
```
