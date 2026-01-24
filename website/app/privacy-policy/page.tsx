import Link from 'next/link'
import Image from 'next/image'

export const metadata = {
  title: 'Privacy Policy - Factor',
}

export default function PrivacyPolicy() {
  return (
    <>
      <header className="header">
        <div className="container header-content">
          <Link href="/" className="logo">
            <Image src="/icon.png" alt="Factor" width={40} height={40} className="logo-icon" />
            <span className="logo-text">Factor</span>
          </Link>
          <nav className="nav">
            <Link href="/license">License</Link>
            <Link href="/copyright">Copyright</Link>
            <Link href="/privacy-policy">Privacy</Link>
          </nav>
        </div>
      </header>

      <main className="legal-page">
        <div className="container">
          <h1>Privacy Policy</h1>
          <p className="updated">Last updated: January 2026</p>

          <h2>Overview</h2>
          <p>
            Factor ("we", "our", or "the app") is committed to protecting your privacy.
            This Privacy Policy explains how we handle information when you use our
            cryptocurrency exchange rate calculator application.
          </p>

          <h2>Information We Collect</h2>
          <p>
            <strong>Factor does not collect, store, or transmit any personal information.</strong>
          </p>
          <p>
            The app operates entirely on your device. We do not:
          </p>
          <ul>
            <li>Collect personal identification information</li>
            <li>Track your location</li>
            <li>Access your contacts, photos, or files</li>
            <li>Store your calculation history on external servers</li>
            <li>Use analytics or tracking services</li>
          </ul>

          <h2>Network Requests</h2>
          <p>
            Factor makes network requests solely to fetch real-time cryptocurrency prices from:
          </p>
          <ul>
            <li><strong>Jupiter Aggregator API:</strong> To retrieve current token prices on Solana</li>
            <li><strong>CoinGecko API:</strong> To retrieve fiat currency exchange rates</li>
          </ul>
          <p>
            These requests contain no personal information and are used only to display
            current exchange rates within the app.
          </p>

          <h2>Local Storage</h2>
          <p>
            Any preferences or settings you configure in the app (such as preferred
            currency or recent tokens) are stored locally on your device and are never
            transmitted to external servers.
          </p>

          <h2>Third-Party Services</h2>
          <p>
            While we use third-party APIs for price data, we do not share any user
            information with these services. Please refer to their respective privacy
            policies for information about how they handle data:
          </p>
          <ul>
            <li><a href="https://jup.ag/privacy-policy" target="_blank" rel="noopener noreferrer">Jupiter Privacy Policy</a></li>
            <li><a href="https://www.coingecko.com/en/privacy" target="_blank" rel="noopener noreferrer">CoinGecko Privacy Policy</a></li>
          </ul>

          <h2>Children's Privacy</h2>
          <p>
            Factor does not knowingly collect any information from children under 13.
            The app does not collect information from any users.
          </p>

          <h2>Changes to This Policy</h2>
          <p>
            We may update this Privacy Policy from time to time. Any changes will be
            reflected on this page with an updated revision date.
          </p>

          <h2>Contact</h2>
          <p>
            If you have any questions about this Privacy Policy, please contact us
            through our GitHub repository.
          </p>
        </div>
      </main>

      <footer className="footer">
        <div className="container footer-content">
          <div className="footer-links">
            <Link href="/license">License</Link>
            <Link href="/copyright">Copyright</Link>
            <Link href="/privacy-policy">Privacy Policy</Link>
          </div>
          <p className="copyright">© {new Date().getFullYear()} Factor. All rights reserved.</p>
        </div>
      </footer>
    </>
  )
}
