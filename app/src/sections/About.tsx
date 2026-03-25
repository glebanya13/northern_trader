import { motion } from 'framer-motion';
import { useInView } from 'framer-motion';
import { useRef } from 'react';
import { Target, TrendingUp, Shield, Users, BarChart3, Lightbulb } from 'lucide-react';

const features = [
  {
    icon: Target,
    title: 'Точность входов',
    description: 'Заходим в сделки с ювелирной точностью, иногда буквально до пункта',
  },
  {
    icon: BarChart3,
    title: 'Объёмный анализ',
    description: 'Читаем след капитала через интерпретацию объёмов и ликвидности',
  },
  {
    icon: Shield,
    title: 'Риск-менеджмент',
    description: 'Контролируем риск на каждой сделке, строим стабильность на дистанции',
  },
  {
    icon: TrendingUp,
    title: 'Реальная практика',
    description: 'Торгуем в реальном времени и показываем результат открыто',
  },
  {
    icon: Users,
    title: 'Закрытое сообщество',
    description: 'Чат учеников и выпускников для обмена опытом и развития',
  },
  {
    icon: Lightbulb,
    title: 'Индивидуальный подход',
    description: 'Каждый трейдер уникален — выстраиваем систему под вас',
  },
];

export default function About() {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: '-100px' });

  return (
    <section id="about" className="relative py-24 lg:py-32 overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 bg-dark-900">
        {/* Background Chart Image */}
        <div 
          className="absolute inset-0 bg-cover bg-center bg-no-repeat opacity-20"
          style={{ backgroundImage: 'url(/landing/chart-bg-2.jpg)' }}
        />
        
        {/* Dark Overlay */}
        <div className="absolute inset-0 bg-gradient-to-b from-dark-900 via-dark-900/95 to-dark-900" />
        
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[800px] h-[400px] bg-gold-500/5 rounded-full blur-[150px]" />
      </div>

      <div className="relative z-10 section-padding max-w-7xl mx-auto">
        {/* Section Header */}
        <div ref={ref} className="text-center mb-16 lg:mb-20">
          <motion.span
            initial={{ opacity: 0, y: 20 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5 }}
            className="inline-block text-sm text-gold-400 font-medium mb-4"
          >
            О нас и нашем подходе
          </motion.span>
          <motion.h2
            initial={{ opacity: 0, y: 30 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.6, delay: 0.1 }}
            className="heading-lg mb-6"
          >
            <span className="text-white">Стабильность — это и есть</span>
            <br />
            <span className="text-gradient">основа успешного трейдинга</span>
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="body-lg max-w-3xl mx-auto"
          >
            Каждый день команда публикует сделки в Telegram-каналах. Как правило, 90% сделок 
            отрабатывают с высокой точностью. Если внимательно посмотреть каналы, можно увидеть 
            всю статистику и понять главное: мы стабильно зарабатываем на дистанции.
          </motion.p>
        </div>

        {/* Secret Section */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, delay: 0.3 }}
          className="glass-card rounded-2xl p-8 lg:p-12 mb-16 lg:mb-20"
        >
          <div className="grid lg:grid-cols-2 gap-8 lg:gap-12 items-center">
            <div>
              <h3 className="text-2xl lg:text-3xl font-bold text-white mb-4">
                В чём <span className="text-gradient">секрет?</span>
              </h3>
              <p className="text-lg text-muted-foreground mb-4">
                Всё строится на правильной интерпретации объёмов.
              </p>
              <p className="text-white font-semibold text-lg mb-4">
                Объёмы = деньги.
              </p>
              <p className="text-muted-foreground">
                А деньги — это единственное, что действительно двигает рынок. За 14 лет практики 
                команда выработала навык, который позволяет заходить в сделки с ювелирной точностью.
              </p>
            </div>
            <div className="relative">
              <div className="absolute inset-0 bg-gold-500/10 blur-3xl rounded-full" />
              <div className="relative glass-card rounded-xl p-6 space-y-4">
                <div className="flex items-center gap-3">
                  <div className="w-3 h-3 rounded-full bg-green-500 animate-pulse" />
                  <span className="text-sm text-muted-foreground">Покупка объёмом</span>
                  <span className="ml-auto text-green-400 font-mono">+2.4M</span>
                </div>
                <div className="h-px bg-white/10" />
                <div className="flex items-center gap-3">
                  <div className="w-3 h-3 rounded-full bg-red-500 animate-pulse animation-delay-200" />
                  <span className="text-sm text-muted-foreground">Продажа объёмом</span>
                  <span className="ml-auto text-red-400 font-mono">-1.8M</span>
                </div>
                <div className="h-px bg-white/10" />
                <div className="flex items-center gap-3">
                  <div className="w-3 h-3 rounded-full bg-gold-400 animate-pulse animation-delay-400" />
                  <span className="text-sm text-muted-foreground">Накопление</span>
                  <span className="ml-auto text-gold-400 font-mono">+650K</span>
                </div>
                <div className="mt-4 p-3 bg-gold-500/10 rounded-lg border border-gold-500/20">
                  <p className="text-sm text-gold-400 text-center">
                    "Деньги не лгут — они всегда оставляют след"
                  </p>
                </div>
              </div>
            </div>
          </div>
        </motion.div>

        {/* Features Grid */}
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {features.map((feature, index) => (
            <motion.div
              key={feature.title}
              initial={{ opacity: 0, y: 30 }}
              animate={isInView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.5, delay: 0.4 + index * 0.1 }}
              className="glass-card-hover rounded-xl p-6 group"
            >
              <div className="w-12 h-12 rounded-lg bg-gold-500/10 flex items-center justify-center mb-4 group-hover:bg-gold-500/20 transition-colors">
                <feature.icon className="w-6 h-6 text-gold-400 icon-glow" />
              </div>
              <h4 className="text-lg font-semibold text-white mb-2">{feature.title}</h4>
              <p className="text-sm text-muted-foreground">{feature.description}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
