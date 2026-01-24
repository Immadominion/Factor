import Link from 'next/link'
import Image from 'next/image'

export const metadata = {
  title: 'License - Factor',
}

export default function License() {
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
          <h1>License</h1>
          <p className="updated">Last updated: January 2026</p>

          <h2>MIT License</h2>
          <p>Copyright (c) 2026 Factor</p>

          <p>
            Permission is hereby granted, free of charge, to any person obtaining a copy
            of this software and associated documentation files (the "Software"), to deal
            in the Software without restriction, including without limitation the rights
            to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
            copies of the Software, and to permit persons to whom the Software is
            furnished to do so, subject to the following conditions:
          </p>

          <p>
            The above copyright notice and this permission notice shall be included in all
            copies or substantial portions of the Software.
          </p>

          <p>
            THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
            IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
            FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
            AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
            LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
            OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
            SOFTWARE.
          </p>

          <h2>Third-Party Services</h2>
          <p>
            Factor uses the following third-party services, each subject to their own terms:
          </p>
          <ul>
            <li><strong>Jupiter Aggregator:</strong> For real-time token prices on Solana</li>
            <li><strong>CoinGecko API:</strong> For additional cryptocurrency data</li>
          </ul>

          <h2>Open Source</h2>
          <p>
            Factor is open source software. You can view, modify, and contribute to the
            source code on our GitHub repository.
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
