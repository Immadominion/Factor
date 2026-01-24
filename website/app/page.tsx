import Link from 'next/link'
import Image from 'next/image'

export default function Home() {
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

      <main>
        <section className="hero">
          <div className="container">
            <span className="hero-badge">Crypto Calculator</span>
            <h1>Real-time <span>Exchange Rates</span></h1>
            <p>Simple, elegant crypto-to-fiat conversion with live prices powered by Jupiter.</p>
            <div className="cta-buttons">
              <a href="https://play.google.com/store/apps/details?id=com.factor.app" className="btn btn-primary">
                Download App
              </a>
              <a href="https://github.com/AffanShaiworking/factor" className="btn btn-secondary">
                View Source
              </a>
            </div>
          </div>
        </section>

        <section className="features">
          <div className="container">
            <div className="features-grid">
              <div className="feature-card">
                <div className="feature-icon">⚡</div>
                <h3>Live Prices</h3>
                <p>Real-time exchange rates from Jupiter aggregator for accurate conversions.</p>
              </div>
              <div className="feature-card">
                <div className="feature-icon">🌍</div>
                <h3>50+ Currencies</h3>
                <p>Convert to USD, EUR, GBP, and many more fiat currencies.</p>
              </div>
              <div className="feature-card">
                <div className="feature-icon">🎨</div>
                <h3>Beautiful UI</h3>
                <p>Clean, dark-themed interface designed for quick calculations.</p>
              </div>
            </div>
          </div>
        </section>
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
