import { motion } from 'framer-motion';
import { useInView } from 'framer-motion';
import { useRef } from 'react';
import { Check, Sparkles, Zap, Crown, ArrowRight, Calendar } from 'lucide-react';

const plans = [
  {
    name: 'Стандарт',
    price: '88 500',
    period: '₽',
    description: 'Полная программа курса для самостоятельного обучения',
    badge: null,
    features: [
      'Полная программа курса (8 модулей)',
      'Практические вебинары и разборы ситуаций',
      'Индивидуальные разборы сделок',
      'Закрытый чат учеников и выпускников',
      'Доступ к материалам остаётся у вас',
      'Поддержка в течение 3 месяцев',
    ],
    notIncluded: [
      'Углублённый курс по макроэкономике',
      'Профессиональный курс по опционам',
      'Обучение арбитражу',
      'Личный ментор',
    ],
    cta: 'Выбрать тариф',
    color: 'border-white/10',
    badgeColor: '',
    buttonClass: 'btn-secondary w-full',
  },
  {
    name: 'Премиум',
    price: '194 000',
    period: '₽',
    description: 'Расширенная программа с приоритетной поддержкой',
    badge: 'Популярный',
    features: [
      'Всё из тарифа «Стандарт»',
      'Углублённый курс по макроэкономике',
      'Профессиональный курс по опционам',
      'Приоритетная поддержка и ответы',
      'Дополнительные разборы сделок',
      'Поддержка в течение 6 месяцев',
    ],
    notIncluded: [
      'Обучение арбитражу',
      'Личный ментор',
    ],
    cta: 'Выбрать тариф',
    color: 'border-gold-500/30',
    badgeColor: 'bg-gold-500 text-dark-900',
    buttonClass: 'btn-primary w-full',
  },
  {
    name: 'PRO',
    price: '440 000',
    period: '₽',
    description: 'Максимальный результат с личным менторством',
    badge: 'Максимум',
    features: [
      'Всё из тарифов «Стандарт» и «Премиум»',
      'Обучение арбитражу',
      'Личный ментор',
      'Еженедельные созвоны 1-на-1',
      'Разработка стратегии под вас',
      'Поддержка в течение 12 месяцев',
      'Доступ к закрытым материалам',
    ],
    notIncluded: [],
    cta: 'Выбрать тариф',
    color: 'border-purple-500/30',
    badgeColor: 'bg-purple-500 text-white',
    buttonClass: 'bg-gradient-to-r from-purple-500 to-purple-600 text-white font-semibold px-6 py-3 rounded-lg w-full transition-all duration-300 hover:shadow-lg hover:shadow-purple-500/25 hover:scale-[1.02]',
  },
];

export default function Pricing() {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: '-100px' });

  const scrollToContact = () => {
    const element = document.querySelector('#contact');
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' });
    }
  };

  return (
    <section id="pricing" className="relative py-24 lg:py-32 overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 bg-dark-900">
        {/* Background Money Image */}
        <div 
          className="absolute inset-0 bg-cover bg-center bg-no-repeat opacity-12"
          style={{ backgroundImage: 'url(/landing/bg-money.jpg)' }}
        />
        
        {/* Dark Overlay */}
        <div className="absolute inset-0 bg-gradient-to-b from-dark-900 via-dark-900/92 to-dark-900" />
        
        <div className="absolute bottom-0 left-1/4 w-[600px] h-[600px] bg-gold-500/5 rounded-full blur-[150px]" />
        <div className="absolute top-1/4 right-1/4 w-[400px] h-[400px] bg-purple-500/5 rounded-full blur-[120px]" />
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
            <Sparkles className="w-4 h-4 text-gold-400" />
            <span className="text-sm text-gold-400 font-medium">Инвестиция в навык</span>
          </motion.span>
          
          <motion.h2
            initial={{ opacity: 0, y: 30 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.6, delay: 0.1 }}
            className="heading-lg mb-6"
          >
            <span className="text-white">Выберите свой</span>
            <span className="text-gradient"> тариф</span>
          </motion.h2>
          
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="body-lg max-w-2xl mx-auto mb-4"
          >
            Старт потока — 15.04.2026. Тарифы отличаются уровнем поддержки и дополнительными модулями.
          </motion.p>
          
          <motion.div
            initial={{ opacity: 0 }}
            animate={isInView ? { opacity: 1 } : {}}
            transition={{ duration: 0.5, delay: 0.3 }}
            className="inline-flex items-center gap-2 text-sm text-muted-foreground"
          >
            <Calendar className="w-4 h-4 text-gold-400" />
            <span>Следующий поток начинается через ограниченное время</span>
          </motion.div>
        </div>

        {/* Pricing Cards */}
        <div className="grid lg:grid-cols-3 gap-6 lg:gap-8 mb-12">
          {plans.map((plan, index) => (
            <motion.div
              key={plan.name}
              initial={{ opacity: 0, y: 30 }}
              animate={isInView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.5, delay: 0.4 + index * 0.1 }}
              className={`relative glass-card rounded-2xl p-6 lg:p-8 border ${plan.color} ${
                plan.badge === 'Популярный' ? 'lg:scale-105 lg:-my-4' : ''
              }`}
            >
              {/* Badge */}
              {plan.badge && (
                <div className={`absolute -top-3 left-1/2 -translate-x-1/2 px-4 py-1 rounded-full text-xs font-semibold ${plan.badgeColor}`}>
                  {plan.badge}
                </div>
              )}
              
              {/* Plan Header */}
              <div className="text-center mb-6">
                <div className="flex items-center justify-center gap-2 mb-2">
                  {plan.name === 'Стандарт' && <Zap className="w-5 h-5 text-gold-400" />}
                  {plan.name === 'Премиум' && <Sparkles className="w-5 h-5 text-gold-400" />}
                  {plan.name === 'PRO' && <Crown className="w-5 h-5 text-purple-400" />}
                  <h3 className="text-xl font-bold text-white">{plan.name}</h3>
                </div>
                <div className="flex items-baseline justify-center gap-1 mb-2">
                  <span className="text-4xl font-bold text-gradient">{plan.price}</span>
                  <span className="text-xl text-muted-foreground">{plan.period}</span>
                </div>
                <p className="text-sm text-muted-foreground">{plan.description}</p>
              </div>
              
              {/* Features */}
              <div className="space-y-3 mb-6">
                {plan.features.map((feature, i) => (
                  <div key={i} className="flex items-start gap-3">
                    <Check className="w-5 h-5 text-green-400 shrink-0 mt-0.5" />
                    <span className="text-sm text-white/80">{feature}</span>
                  </div>
                ))}
                {plan.notIncluded.map((feature, i) => (
                  <div key={`not-${i}`} className="flex items-start gap-3 opacity-40">
                    <div className="w-5 h-5 rounded-full border border-white/20 shrink-0 mt-0.5" />
                    <span className="text-sm text-white/60 line-through">{feature}</span>
                  </div>
                ))}
              </div>
              
              {/* CTA Button */}
              <button onClick={scrollToContact} className={plan.buttonClass}>
                {plan.cta}
                <ArrowRight className="w-4 h-4 inline ml-2" />
              </button>
            </motion.div>
          ))}
        </div>

        {/* Bottom CTA */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.5, delay: 0.8 }}
          className="text-center"
        >
          <button
            onClick={scrollToContact}
            className="inline-flex items-center gap-2 text-gold-400 hover:text-gold-300 transition-colors"
          >
            <span className="text-sm font-medium">Нужна помощь в выборе тарифа?</span>
            <ArrowRight className="w-4 h-4" />
          </button>
        </motion.div>
      </div>
    </section>
  );
}
