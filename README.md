# OpenAI API Usage
<img width="282" alt="image" src="https://github.com/webcpu/OpenAIAPIUsage/assets/4646838/9d8ad726-95da-4714-bf85-abee5a51c772">

Welcome to OpenAI API Usage, a sleek and convenient macOS menu bar application designed to keep you informed about your API usage costs every minute. With this app, you no longer need to log into multiple dashboards or wait for billing statements to understand your API consumption. API Usage Tracker does the heavy lifting by displaying your current API usage amount in USD directly in your menu bar, ensuring you have immediate access to your spending without interrupting your workflow.


# Steps
1. Click "Get Bearer Token".
- <img width="214" alt="image" src="https://github.com/webcpu/OpenAIAPIUsage/assets/4646838/b1bcfd01-1dbc-458b-839c-40149dbdd8d9">

2. Copy OpenAI Dashboard API Bearer Token in Safari
  <img width="1126" alt="screenshot-dashboard" src="https://github.com/webcpu/OpenAIAPIUsage/assets/4646838/05877530-ad21-49d2-a1a9-a722ba2ff1bd">
3. Click "Paste Bearer Token".

- <img width="214" alt="image" src="https://github.com/webcpu/OpenAIAPIUsage/assets/4646838/6b9b68ca-d4e5-4539-88e5-9b0bb3bc2dd3">


# Obtaining a OpenAI Dashboard API Bearer Token in Safari

## Prerequisites

- Safari browser installed on your Mac.
- Log in to access https://platform.openai.com/usage

## Steps to Retrieve a Bearer Token

### 1. Open Developer Tools

To start, log in to access https://platform.openai.com/usage. Then, open Safari's Developer Tools. If the Developer menu is not already visible in Safari, enable it by following these steps:

- Go to Safari > Preferences > Advanced.
- Check the box at the bottom that says "Show Develop menu in menu bar."

Now you can access the Developer Tools by:

- Clicking on the "Develop" menu in the menu bar and selecting "Show Web Inspector."
- Using the keyboard shortcut `Option+Cmd+I`.

### 2. Access the Network Tab

Within the Web Inspector, click on the "Network" tab. This tab records all the network requests made by the browser. If the list is empty, refresh the page to start capturing the network activity while the Web Inspector is open.

### 3. Trigger a Network Request

Bearer tokens are usually included in specific requests, such as those made during login or when accessing secured content. Execute an action that would trigger such a request to ensure the bearer token is sent.

### 4. Identify the Request Containing the Bearer Token

Look through the network requests listed in the "Network" tab to find one that includes an Authorization header with a Bearer token. This is typically found in requests to API endpoints or other backend services.

You might find it helpful to use the filter functionality to narrow down the requests by typing keywords related to your application's API endpoints.

### 5. Extract the Bearer Token

After locating the request with the bearer token, click on it to open the request details. Navigate to the "Headers" section and look for the "Authorization" header under the "Request Headers" subsection.

The Bearer token usually follows the "Bearer" scheme in this header, formatted as follows:



```Authorization: Bearer sess-31uNn4ckFvo36Mg6CdSycFdeOm...```


The string after "Bearer" is your token. You can select and copy this token for your use.

## Using the Bearer Token

With the bearer token copied, you can use it in authenticated requests to the server. When testing with API tools like Postman or crafting requests with cURL, include this token in the Authorization header, following the same format observed in the Web Inspector.

## Important Considerations

- **Security**: Treat bearer tokens as sensitive information, as they grant access to the application on behalf of the authenticated user. Never expose them in client-side code or share them unnecessarily.
- **Expiration**: Bearer tokens often expire after a certain period. If your token becomes invalid, you'll need to repeat these steps to obtain a new one.
- **Environment Variability**: The exact steps and the layout of the Web Inspector may vary slightly between different versions of Safari and depending on the specific web application you are working with.
