import Link from 'next/link'
import Image from 'next/image'

export const metadata = {
  title: 'Copyright - Factor',
}

export default function Copyright() {
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
          <h1>Copyright Notice</h1>
          <p className="updated">Last updated: January 2026</p>

          <h2>Copyright</h2>
          <p>
            © 2026 Factor. All rights reserved.
          </p>

          <h2>Ownership</h2>
          <p>
            The Factor application, including but not limited to its design, code, graphics,
            logos, and user interface, is the intellectual property of Factor and its contributors.
          </p>

          <h2>Permitted Use</h2>
          <p>
            Under the MIT License, you are permitted to:
          </p>
          <ul>
            <li>Use the software for personal or commercial purposes</li>
            <li>Modify the source code</li>
            <li>Distribute copies of the software</li>
            <li>Sublicense the software</li>
          </ul>

          <h2>Attribution</h2>
          <p>
            When using or redistributing Factor or its source code, please include
            the original copyright notice and license information.
          </p>

          <h2>Trademarks</h2>
          <p>
            The Factor name and logo are trademarks. Use of these trademarks without
            prior written permission is prohibited, except as permitted by applicable law.
          </p>

          <h2>Third-Party Content</h2>
          <p>
            Factor may include or reference third-party content, libraries, or services.
            Such content remains the property of their respective owners and is subject
            to their own copyright and licensing terms.
          </p>

          <h2>Contact</h2>
          <p>
            For copyright inquiries or permission requests, please contact us through
            our GitHub repository.
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
