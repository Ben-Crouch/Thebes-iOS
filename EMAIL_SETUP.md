# Setting Up Email Forwarding for support@thebes.app

To set up email forwarding from `support@thebes.app` to `bencrouch94@gmail.com`.

## ✅ Your Setup
- **Domain:** thebes.app (registered via GoDaddy)
- **Forward from:** support@thebes.app
- **Forward to:** bencrouch94@gmail.com

## Option 1: GoDaddy Email Forwarding (RECOMMENDED - Easiest)

Since you're using GoDaddy, this is the simplest option:

### Steps:
1. **Log into GoDaddy:**
   - Go to https://www.godaddy.com
   - Sign in to your account

2. **Navigate to Email Forwarding:**
   - Go to "My Products" → Click on your domain "thebes.app"
   - Look for "Email" section or "Email Forwarding"
   - If you don't see it, go to "DNS" settings first

3. **Set Up Forwarding:**
   - Click "Add" or "Create Email Forwarding"
   - Enter email address: `support`
   - Forward to: `bencrouch94@gmail.com`
   - Save

4. **Verify Setup:**
   - Send a test email to `support@thebes.app`
   - Check your Gmail inbox

### Cost: Usually free with domain registration (or ~$2-5/year)

---

## Option 2: Google Workspace (If GoDaddy forwarding isn't available)

1. **Register/Set up Google Workspace:**
   - Go to https://workspace.google.com
   - Set up your domain (thebes.app)
   - Add the email alias `support@thebes.app`
   - Configure forwarding to `bencrouch94@gmail.com`

2. **Cost:** ~$6/month per user (or you can use a free trial)

## Option 2: Cloudflare Email Routing (Free & Easy)

If you're using Cloudflare for DNS (which is free), you can use their Email Routing feature:

1. **Set up Cloudflare Email Routing:**
   - Go to Cloudflare Dashboard > Email > Email Routing
   - Enable Email Routing for `thebes.app`
   - Add address: `support@thebes.app`
   - Forward to: `bencrouch94@gmail.com`

2. **Update DNS Records:**
   - Cloudflare will provide MX records to add to your domain
   - Add these MX records in your domain registrar

3. **Cost:** Free!

## Alternative: Using GoDaddy DNS with Cloudflare Email Routing

If GoDaddy's email forwarding isn't available or you want more control:

1. **Transfer DNS to Cloudflare (free):**
   - Sign up for Cloudflare (free)
   - Add your domain `thebes.app`
   - Cloudflare will give you nameservers
   - Update nameservers in GoDaddy

2. **Set up Email Routing in Cloudflare:**
   - Go to Cloudflare Dashboard > Email > Email Routing
   - Enable Email Routing
   - Add address: `support@thebes.app` → `bencrouch94@gmail.com`

3. **Cost:** Free

**Note:** This gives you better DNS management and free email routing, but requires changing nameservers.

## Option 4: Zoho Mail (Free)

Zoho offers free email hosting for one domain:

1. **Sign up for Zoho Mail:**
   - Go to https://www.zoho.com/mail/
   - Add your domain `thebes.app`
   - Create `support@thebes.app`
   - Set up forwarding to `bencrouch94@gmail.com`

2. **Cost:** Free for 5 users

## Recommended Approach for Your Setup

**Since you have thebes.app via GoDaddy:**
1. **Try Option 1 first** (GoDaddy Email Forwarding) - easiest and usually free
2. If that's not available, use **Option 2** (Cloudflare Email Routing) with DNS transfer
3. For full email hosting, consider **Option 4** (Google Workspace) if you need to reply as support@thebes.app

## Testing

After setting up forwarding, test by:
1. Sending an email to `support@thebes.app`
2. Check that it arrives at `bencrouch94@gmail.com`

## Important Notes

- The email `support@thebes.app` will forward ALL emails to `bencrouch94@gmail.com`
- You'll receive emails in your Gmail inbox, but you can reply from `bencrouch94@gmail.com`
- To reply AS `support@thebes.app`, you'll need a full email hosting service (Google Workspace, Zoho)

