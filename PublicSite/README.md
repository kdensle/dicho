# Public Site

These static files are ready to host as the public App Store URLs:

- `https://dicho.app/support`
- `https://dicho.app/privacy`
- `https://dicho.app/terms`

You can host them with Cloudflare Pages, Netlify, Vercel, GitHub Pages, or any static web host.

Before App Store submission:

- Replace `support@dicho.app` if you use a different monitored support address.
- Confirm the legal copy matches the in-app text in `Dicho/Models/LegalCopy.swift`.
- Have counsel review the final Privacy Policy and Terms of Use.
- Configure the host so `/support`, `/privacy`, and `/terms` resolve to these pages, or update App Store Connect to use the `.html` URLs.
