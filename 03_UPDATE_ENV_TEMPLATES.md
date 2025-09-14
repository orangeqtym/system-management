# Migration Step 2.3: Update Environment Templates

**Objective:** Document the environment variables needed by the `email-service` in the central templates.

**Action:** First, read the `.env.template` from the `email-service` repo. Then, append its contents to the `.env.template` files in this repository.

**Agent Tasks:**
1.  Read the application's template file:
    ```
    read_file(absolute_path='/home/qtym/email-service/.env.template')
    ```
2.  Use the content from the above step to append to the `dev` and `prod` templates here. For example:
    ```
    # Let's say the content was "EMAIL_PROVIDER_API_KEY=..."
    replace(
        file_path='/home/qtym/system-management/dev/.env.template',
        old_string='# EMAIL_SERVICE_URL=http://email-service:3000',
        new_string='''# EMAIL_SERVICE_URL=http://email-service:3000

# Variables for email-service
EMAIL_PROVIDER_API_KEY='''
    )
    replace(
        file_path='/home/qtym/system-management/prod/.env.template',
        old_string='# EMAIL_SERVICE_URL=http://email-service:3000',
        new_string='''# EMAIL_SERVICE_URL=http://email-service:3000

# Variables for email-service
EMAIL_PROVIDER_API_KEY='''
    )
    ```
