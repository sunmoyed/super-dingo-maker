import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";
import * as awsx from "@pulumi/awsx";
import Stripe from 'stripe'




const config = new pulumi.Config();
const stripeSecret = config.getSecret("stripe_secret_key")
const stripePublic = config.get("stripe_public_key") || ""

const lambdaEnv = stripeSecret?.apply(stripeSecret => ({
  variables: {
    "STRIPE_SECRET_KEY": stripeSecret,
    "STRIPE_PUBLIC_KEY": stripePublic,
    "DINGO_PRINT_ID": "price_1I1ifoHnmSSGyUB7NVJpyZSM",
    "DOMAIN": "https://example.com",
    "PAYMENT_METHODS": "card",
  }
}))


// Define a new GET endpoint that just returns a 200 and "hello" in the body.
const api = new awsx.apigateway.API("super-dingo-maker", {
  routes: [{
    path: "/",
    method: "GET",
    eventHandler: new aws.lambda.CallbackFunction("get-handler", {
      environment: lambdaEnv,
      callback: async (event) => {
        // This code runs in an AWS Lambda anytime `/` is hit.
        return {
          statusCode: 200,
          body: "Hello, API Gateway!",
        };
      },
    })
  },
  {
    path: "/config",
    method: "GET",
    eventHandler: new aws.lambda.CallbackFunction("getConfig", {
      environment: lambdaEnv,
      callback: async (event: awsx.apigateway.Request): Promise<awsx.apigateway.Response> => {
        console.log("secret is", process.env["STRIPE_SECRET_KEY"])
        const stripe = new Stripe(process.env["STRIPE_SECRET_KEY"] || "", { apiVersion: "2020-08-27" })
        const price = await stripe.prices.retrieve(process.env.DINGO_PRINT_ID || "");
        return {
          statusCode: 200,
          body: JSON.stringify(
            {
              publicKey: process.env.STRIPE_PUBLISHABLE_KEY,
              unitAmount: price.unit_amount,
              currency: price.currency,
            })
        };
      },
    })
  },
  {
    path: "/checkout-session",
    method: "GET",
    eventHandler: new aws.lambda.CallbackFunction("checkoutSession", {
      environment: lambdaEnv,
      callback: async (event: awsx.apigateway.Request): Promise<awsx.apigateway.Response> => {
        // const { sessionId } = req.query;
        const sessionId = event.queryStringParameters?.sessionId || ""
        const stripe = new Stripe(process.env["STRIPE_SECRET_KEY"] || "", { apiVersion: "2020-08-27" })
        const session = await stripe.checkout.sessions.retrieve(sessionId);
        return {
          statusCode: 200,
          headers: session.headers,
          body: JSON.stringify(session)
        };
      },
    })
  },
  {
    path: "/create-checkout-session",
    method: "POST",
    eventHandler: new aws.lambda.CallbackFunction("createCheckoutSession", {
      environment: lambdaEnv,
      callback: async (event: awsx.apigateway.Request): Promise<awsx.apigateway.Response> => {
        const stripe = new Stripe(process.env["STRIPE_SECRET_KEY"] || "", { apiVersion: "2020-08-27" })
        const body = Buffer.from(event.body || "", 'base64').toString('utf-8')
        const { quantity, locale } = JSON.parse(body)
        const domainURL = process.env.DOMAIN
        // Create new Checkout Session for the order
        // Other optional params include:
        // [billing_address_collection] - to display billing address details on the page
        // [customer] - if you have an existing Stripe Customer ID
        // [customer_email] - lets you prefill the email input in the Checkout page
        // For full details see https://stripe.com/docs/api/checkout/sessions/create
        const session = await stripe.checkout.sessions.create({
          payment_method_types: process.env.PAYMENT_METHODS?.split(', ') as any,
          mode: 'payment',
          locale: locale,
          line_items: [
            {
              price: process.env.DINGO_PRINT_ID,
              quantity: quantity
            },
          ],
          // ?session_id={CHECKOUT_SESSION_ID} means the redirect will have the session ID set as a query param
          success_url: `${domainURL}/success.html?session_id={CHECKOUT_SESSION_ID}`,
          cancel_url: `${domainURL}/canceled.html`,
        });

        return {
          statusCode: 200,
          headers: session.headers,
          body: JSON.stringify({
            sessionId: session.id,
          })
        };
      },
    })
  }
  ],
})

// Export the auto-generated API Gateway base URL.
export const url = api.url;