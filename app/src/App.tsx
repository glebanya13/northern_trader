import Navigation from './components/custom/Navigation';
import Hero from './sections/Hero';
import About from './sections/About';
import TelegramChannels from './sections/TelegramChannels';
import Program from './sections/Program';
import Results from './sections/Results';
import Testimonials from './sections/Testimonials';
import Pricing from './sections/Pricing';
import FAQ from './sections/FAQ';
import Contact from './sections/Contact';
import Footer from './sections/Footer';
import { OfertaPage, PolitikaPage, RisksPage } from './pages/LegalPages';

function App() {
  const rawPath = window.location.pathname.replace(/\/+$/, '') || '/';
  const path = rawPath.startsWith('/landing')
    ? rawPath.replace('/landing', '') || '/'
    : rawPath;

  if (path === '/oferta') return <OfertaPage />;
  if (path === '/politika') return <PolitikaPage />;
  if (path === '/risks') return <RisksPage />;

  return (
    <div className="min-h-screen bg-dark-900 text-white overflow-x-hidden">
      <Navigation />
      <main>
        <Hero />
        <About />
        <TelegramChannels />
        <Program />
        <Results />
        <Testimonials />
        <Pricing />
        <FAQ />
        <Contact />
      </main>
      <Footer />
    </div>
  );
}

export default App;
