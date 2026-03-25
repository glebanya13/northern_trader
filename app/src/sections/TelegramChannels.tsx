import { motion } from 'framer-motion';
import { useInView } from 'framer-motion';
import { useRef } from 'react';
import { Send, ArrowRight, ExternalLink } from 'lucide-react';

const channels = [
  {
    name: 'Валютный рынок',
    handle: '@tradingplusforex',
    description: 'Реальные сделки и сценарии по FX: точки входа, риск и сопровождение — без «постфактума».',
    color: 'from-blue-500/20 to-cyan-500/20',
    link: 'https://t.me/tradingplusforex',
    logoUrl: 'https://my-blog-1766143027.web.app/landing/ch-tradingplusforex.png',
  },
  {
    name: 'Срочный рынок',
    handle: '@Exper_Trading',
    description: 'Фьючерсы и индексы: объёмы, уровни ликвидности и план сделки. Статистика и результаты — открыто.',
    color: 'from-purple-500/20 to-pink-500/20',
    link: 'https://t.me/Exper_Trading',
    logoUrl: 'https://my-blog-1766143027.web.app/landing/ch-expert.png',
  },
  {
    name: 'Крипторынок',
    handle: '@QuantumTradingPRO',
    description: 'Сделки по криптовалютам с понятным риском: вход, сопровождение, выход. Всё в реальном времени.',
    color: 'from-orange-500/20 to-yellow-500/20',
    link: 'https://t.me/QuantumTradingPRO',
    logoUrl: 'https://my-blog-1766143027.web.app/landing/ch-quantum.png',
  },
  {
    name: 'MOEX (акции)',
    handle: '@IntradingMoex',
    description: 'Идеи и сделки по рынку Мосбиржи: уровни, риск‑план и сопровождение — без «воды».',
    color: 'from-green-500/20 to-emerald-500/20',
    link: 'https://t.me/IntradingMoex',
    logoUrl: 'https://my-blog-1766143027.web.app/landing/ch-intradingmoex.png',
  },
  {
    name: 'Американский рынок',
    handle: '@nyseTsU',
    description: 'Акции и деривативы США: объёмная логика и сценарии сделок с пояснениями и открытой статистикой.',
    color: 'from-red-500/20 to-rose-500/20',
    link: 'https://t.me/nyseTsU',
    logoUrl: 'https://my-blog-1766143027.web.app/landing/ch-nysetsu.png',
  },
];

export default function TelegramChannels() {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: '-100px' });

  return (
    <section id="telegram" className="relative py-24 lg:py-32 overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 bg-dark-900">
        {/* Background Waves Image */}
        <div 
          className="absolute inset-0 bg-cover bg-center bg-no-repeat opacity-15"
          style={{ backgroundImage: 'url(/landing/bg-waves.jpg)' }}
        />
        
        {/* Dark Overlay */}
        <div className="absolute inset-0 bg-gradient-to-b from-dark-900 via-dark-900/90 to-dark-900" />
        
        <div className="absolute bottom-0 right-0 w-[600px] h-[600px] bg-gold-500/5 rounded-full blur-[150px]" />
      </div>

      <div className="relative z-10 section-padding max-w-7xl mx-auto">
        {/* Section Header */}
        <div ref={ref} className="text-center mb-16">
          <motion.span
            initial={{ opacity: 0, y: 20 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5 }}
            className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-blue-500/10 border border-blue-500/20 mb-6"
          >
            <Send className="w-4 h-4 text-blue-400" />
            <span className="text-sm text-blue-400 font-medium">Наши Telegram-каналы</span>
          </motion.span>
          
          <motion.h2
            initial={{ opacity: 0, y: 30 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.6, delay: 0.1 }}
            className="heading-lg mb-6"
          >
            <span className="text-white">Хочешь посмотреть, как мы</span>
            <br />
            <span className="text-gradient">торгуем на практике?</span>
          </motion.h2>
          
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="body-lg max-w-2xl mx-auto"
          >
            Подпишитесь на наши Telegram-каналы и понаблюдайте за торговлей в режиме онлайн. 
            Ежедневно — реальные сделки, логика входа и открытая статистика.
          </motion.p>
        </div>

        {/* CTA Button */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.5, delay: 0.3 }}
          className="flex justify-center mb-12"
        >
          <a
            href="https://t.me/addlist/xCzKIuCnQbtiNDBi"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-2 px-6 py-3 bg-blue-500 hover:bg-blue-600 text-white font-semibold rounded-lg transition-all duration-300 hover:shadow-lg hover:shadow-blue-500/25"
          >
            <Send className="w-5 h-5" />
            Получить ссылки на каналы
            <ArrowRight className="w-4 h-4" />
          </a>
        </motion.div>

        {/* Channels Grid */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {channels.map((channel, index) => (
            <motion.a
              key={channel.name}
              href={channel.link}
              target="_blank"
              rel="noopener noreferrer"
              initial={{ opacity: 0, y: 30 }}
              animate={isInView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.5, delay: 0.4 + index * 0.1 }}
              className="group relative glass-card rounded-xl p-6 overflow-hidden hover:border-blue-500/30 transition-all duration-300"
            >
              {/* Gradient Background */}
              <div className={`absolute inset-0 bg-gradient-to-br ${channel.color} opacity-0 group-hover:opacity-100 transition-opacity duration-300`} />
              
              <div className="relative z-10">
                <div className="flex items-start justify-between mb-4">
                  <div className="w-14 h-14 rounded-lg bg-white p-1.5 flex items-center justify-center border border-white/20">
                    <img
                      src={channel.logoUrl}
                      alt={channel.name}
                      className="w-full h-full object-contain"
                      loading="lazy"
                    />
                  </div>
                  <ExternalLink className="w-5 h-5 text-muted-foreground opacity-0 group-hover:opacity-100 transition-opacity" />
                </div>
                
                <h3 className="text-lg font-semibold text-white mb-1 group-hover:text-blue-400 transition-colors">
                  {channel.name}
                </h3>
                <p className="text-sm text-blue-400/80 mb-3">{channel.handle}</p>
                <p className="text-sm text-muted-foreground">{channel.description}</p>
              </div>
            </motion.a>
          ))}
        </div>

        {/* Trust Note */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.5, delay: 0.9 }}
          className="mt-12 text-center"
        >
          <p className="text-sm text-muted-foreground">
            <span className="text-gold-400 font-medium">Максимальная прозрачность:</span> сделки и статистика публикуются открыто — всё можно проверить самому.
          </p>
        </motion.div>
      </div>
    </section>
  );
}
