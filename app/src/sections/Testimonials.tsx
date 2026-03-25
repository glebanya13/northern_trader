import { motion } from 'framer-motion';
import { useInView } from 'framer-motion';
import { useRef } from 'react';
import { MessageSquare, Send } from 'lucide-react';

export default function Testimonials() {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: '-100px' });

  return (
    <section id="testimonials" className="relative py-24 lg:py-32 overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 bg-dark-900">
        {/* Background Candles Image */}
        <div 
          className="absolute inset-0 bg-cover bg-center bg-no-repeat opacity-10"
          style={{ backgroundImage: 'url(/landing/bg-candles.jpg)' }}
        />
        
        {/* Dark Overlay */}
        <div className="absolute inset-0 bg-gradient-to-b from-dark-900 via-dark-900/95 to-dark-900" />
        
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[400px] bg-gold-500/5 rounded-full blur-[150px]" />
      </div>

      <div className="relative z-10 section-padding max-w-7xl mx-auto">
        {/* Section Header */}
        <div ref={ref} className="text-center mb-16">
          <motion.span
            initial={{ opacity: 0, y: 20 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5 }}
            className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-gold-500/10 border border-gold-500/20 mb-6"
          >
            <MessageSquare className="w-4 h-4 text-gold-400" />
            <span className="text-sm text-gold-400 font-medium">Живые отзывы</span>
          </motion.span>
          
          <motion.h2
            initial={{ opacity: 0, y: 30 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.6, delay: 0.1 }}
            className="heading-lg mb-6"
          >
            <span className="text-white">Отзывы</span>
            <span className="text-gradient"> выпускников</span>
          </motion.h2>
          
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="body-lg max-w-2xl mx-auto"
          >
            Скриншоты, фото и реальный опыт. Больше отзывов — в нашем Telegram-канале.
          </motion.p>
        </div>

        {/* Telegram Link */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.5, delay: 0.3 }}
          className="flex justify-center mb-12"
        >
          <a
            href="https://t.me/reviews_STtraining"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-2 px-5 py-2.5 bg-blue-500/10 border border-blue-500/20 rounded-lg text-blue-400 hover:bg-blue-500/20 transition-colors"
          >
            <Send className="w-4 h-4" />
            <span className="text-sm font-medium">t.me/reviews_STtraining</span>
          </a>
        </motion.div>

        {/* Testimonials Grid (как в site: реальные скриншоты отзывов) */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 sm:gap-6 lg:gap-8">
          {[
            'https://my-blog-1766143027.web.app/landing/feedback1.jpg',
            'https://my-blog-1766143027.web.app/landing/feedback2.jpg',
            'https://my-blog-1766143027.web.app/landing/feedback3.jpg',
          ].map((src, index) => (
            <motion.div
              key={src}
              initial={{ opacity: 0, y: 30 }}
              animate={isInView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.5, delay: 0.4 + index * 0.1 }}
              className="relative bg-black/15 border border-white/10 rounded-xl p-3 sm:p-5 overflow-hidden shadow-lg shadow-black/30 max-w-[380px] w-full mx-auto"
            >
              <div className="relative aspect-[3/4] sm:aspect-[2/3] w-full min-h-[220px] sm:min-h-[320px] overflow-hidden rounded-lg bg-black flex items-center justify-center">
                <img
                  src={src}
                  alt={`Отзыв выпускника №${index + 1}`}
                  className="w-full h-full object-cover sm:object-contain"
                  loading="lazy"
                />
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
