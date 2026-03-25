import { motion } from 'framer-motion';
import { TrendingUp, Send, ExternalLink } from 'lucide-react';

const footerLinks = {
  navigation: [
    { name: 'Программа', href: '#program' },
    { name: 'Сделки в Telegram', href: '#telegram' },
    { name: 'Результаты', href: '#results' },
    { name: 'Тарифы', href: '#pricing' },
    { name: 'Отзывы', href: '#testimonials' },
    { name: 'FAQ', href: '#faq' },
  ],
  legal: [
    { name: 'Оферта', href: '/oferta' },
    { name: 'Политика конфиденциальности', href: '/politika' },
    { name: 'Уведомление о рисках', href: '/risks' },
  ],
  social: [
    { name: 'Telegram-каналы', href: 'https://t.me/addlist/xCzKIuCnQbtiNDBi', icon: Send },
    { name: 'Отзывы выпускников', href: 'https://t.me/reviews_STtraining', icon: Send },
  ],
};

export default function Footer() {
  const scrollToSection = (href: string) => {
    if (href.startsWith('#')) {
      const element = document.querySelector(href);
      if (element) {
        element.scrollIntoView({ behavior: 'smooth' });
      }
    }
  };

  return (
    <footer className="relative py-16 lg:py-20 overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 bg-dark-900">
        <div className="absolute inset-0 bg-gradient-to-t from-dark-800/50 to-transparent" />
      </div>

      <div className="relative z-10 section-padding max-w-7xl mx-auto">
        <div className="grid lg:grid-cols-4 gap-12 lg:gap-8 mb-12">
          {/* Brand */}
          <div className="lg:col-span-2">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5 }}
              className="flex items-center gap-2 mb-4"
            >
              <div className="relative">
                <div className="absolute inset-0 bg-gold-500/20 blur-xl rounded-full" />
                <TrendingUp className="w-8 h-8 text-gold-400 relative z-10" />
              </div>
              <span className="font-bold text-xl text-white">Trader's University</span>
            </motion.div>
            <motion.p
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: 0.1 }}
              className="text-muted-foreground max-w-md mb-6"
            >
              Обучение объёмному анализу, которое превращает трейдинг в понятную систему. 
              14 лет практики · Объёмы + фундамент.
            </motion.p>
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: 0.2 }}
              className="flex items-center gap-4"
            >
              {footerLinks.social.map((link) => (
                <a
                  key={link.name}
                  href={link.href}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center gap-2 px-4 py-2 bg-white/5 rounded-lg text-sm text-muted-foreground hover:text-white hover:bg-white/10 transition-colors"
                >
                  <Send className="w-4 h-4" />
                  {link.name}
                </a>
              ))}
            </motion.div>
          </div>

          {/* Navigation */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5, delay: 0.3 }}
          >
            <h4 className="font-semibold text-white mb-4">Навигация</h4>
            <ul className="space-y-3">
              {footerLinks.navigation.map((link) => (
                <li key={link.name}>
                  <button
                    onClick={() => scrollToSection(link.href)}
                    className="text-sm text-muted-foreground hover:text-white transition-colors"
                  >
                    {link.name}
                  </button>
                </li>
              ))}
            </ul>
          </motion.div>

          {/* Legal */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5, delay: 0.4 }}
          >
            <h4 className="font-semibold text-white mb-4">Правовая информация</h4>
            <ul className="space-y-3">
              {footerLinks.legal.map((link) => (
                <li key={link.name}>
                  <a
                    href={link.href}
                    className="text-sm text-muted-foreground hover:text-white transition-colors inline-flex items-center gap-1"
                  >
                    {link.name}
                    <ExternalLink className="w-3 h-3" />
                  </a>
                </li>
              ))}
            </ul>
          </motion.div>
        </div>

        {/* Bottom Bar */}
        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5, delay: 0.5 }}
          className="pt-8 border-t border-white/5"
        >
          <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
            <p className="text-sm text-muted-foreground">
              © 2026 Trader's University. Все права защищены.
            </p>
            <p className="text-sm text-muted-foreground flex items-center gap-2">
              <span className="w-2 h-2 rounded-full bg-gold-400 animate-pulse" />
              14 лет экспертизы в трейдинге
            </p>
          </div>
        </motion.div>

        {/* Risk Disclaimer */}
        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5, delay: 0.6 }}
          className="mt-8 p-4 bg-white/5 rounded-lg"
        >
          <p className="text-xs text-muted-foreground/60 text-center">
            <span className="text-gold-400/80">Важно:</span> Трейдинг связан с высокими рисками. 
            Прошлые результаты не гарантируют будущих доходов. Инвестируйте только те средства, 
            которые можете позволить себе потерять. Перед началом торговли рекомендуется 
            проконсультироваться с финансовым советником.
          </p>
        </motion.div>
      </div>
    </footer>
  );
}
