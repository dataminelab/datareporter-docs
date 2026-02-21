---
title: How to Create a Google Developers Project
section: open-source
category: admin-guide
---

1. Sign into the [API manager in the Google Cloud console](https://console.cloud.google.com/apis/credentials).
2. Likely you will need to create a new project in Google Cloud, so click `Create`.
   ![Create new project](/docs/images/google_oauth_1.png)
3. Give your project a name, like "DataReporter" and click create.
   ![Give project name](/docs/images/google_oauth2.png)
4. Click `Create Credentials` and select OAuth Client ID.
   ![Create credentials](/docs/images/google_oauth3.png)
5. If you see it, click on the button that says `Configure Consent Screen`.
   ![Configure consent](/docs/images/google_oauth4.png)
6. Fill out the Product Name field and click Save. (This will be displayed to users during the sign in flow).
   ![Fill out product name](/docs/images/google_oauth5.png)
7. Select the Application Type `Web Application`. Give your application a name and in Authorized Javascript Origins, put the address of your DataReporter instance (something like: `https://redash.acme.com`).
8. In the Authorized redirect URIs section, put the address of your DataReporter instance suffixed by `/oauth/google_callback` (i.e. `https://redash.acme.com/oauth/google_callback`). Click create.
   ![Set callbacks](/docs/images/google_oauth6.png)
9. Copy your client ID and secret and paste them in the fields on the left to finish connecting Google.
   ![Copy Client ID and Secret](/docs/images/google_oauth7.png)
