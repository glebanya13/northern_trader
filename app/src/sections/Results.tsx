import { motion } from 'framer-motion';
import { useInView } from 'framer-motion';
import { useRef } from 'react';
import { TrendingUp, TrendingDown, Award, BarChart3, Target, Shield } from 'lucide-react';

const caseStudies = [
  {
    result: '+502.47%',
    before: 'Сделки без системы и контроля риска',
    after: 'Сценарии, точки отмены и дисциплина',
    color: 'from-green-500/20 to-emerald-500/20',
    borderColor: 'border-green-500/30',
    textColor: 'text-green-400',
  },
  {
    result: '+42.38%',
    before: 'Импульсивные входы и «догадки»',
    after: 'Вход по подтверждению и риск-план',
    color: 'from-blue-500/20 to-cyan-500/20',
    borderColor: 'border-blue-500/30',
    textColor: 'text-blue-400',
  },
  {
    result: '+8.9%',
    before: '«Скачки» результата от сделки к сделке',
    after: 'Стабильность на дистанции и контроль риска',
    color: 'from-gold-500/20 to-yellow-500/20',
    borderColor: 'border-gold-500/30',
    textColor: 'text-gold-400',
  },
];

const stats = [
  { icon: Target, value: '90%', label: 'Точность сделок', description: 'Отрабатывают с высокой точностью' },
  { icon: BarChart3, value: '500+', label: 'Выпускников', description: 'Успешно прошли обучение' },
  { icon: TrendingUp, value: '14', label: 'Лет практики', description: 'Команда торгует на рынках' },
  { icon: Shield, value: '24/7', label: 'Поддержка', description: 'В закрытом чате учеников' },
];

export default function Results() {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: '-100px' });

  return (
    <section id="results" className="relative py-24 lg:py-32 overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 bg-dark-900">
        {/* Background Volume Image */}
        <div 
          className="absolute inset-0 bg-cover bg-center bg-no-repeat opacity-15"
          style={{ backgroundImage: 'url(/landing/volume-bg.jpg)' }}
        />
        
        {/* Dark Overlay */}
        <div className="absolute inset-0 bg-gradient-to-b from-dark-900 via-dark-900/90 to-dark-900" />
        
        <div className="absolute top-0 right-1/4 w-[600px] h-[600px] bg-gold-500/5 rounded-full blur-[150px]" />
        <div className="absolute bottom-0 left-1/4 w-[400px] h-[400px] bg-green-500/5 rounded-full blur-[120px]" />
      </div>

      <div className="relative z-10 section-padding max-w-7xl mx-auto">
        {/* Section Header */}
        <div ref={ref} className="text-center mb-16">
          <motion.span
            initial={{ opacity: 0, y: 20 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5 }}
            className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-green-500/10 border border-green-500/20 mb-6"
          >
            <Award className="w-4 h-4 text-green-400" />
            <span className="text-sm text-green-400 font-medium">Кейсы выпускников</span>
          </motion.span>
          
          <motion.h2
            initial={{ opacity: 0, y: 30 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.6, delay: 0.1 }}
            className="heading-lg mb-6"
          >
            <span className="text-white">Результаты</span>
            <span className="text-gradient"> учеников</span>
          </motion.h2>
          
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="body-lg max-w-2xl mx-auto"
          >
            Скриншоты, конкретные цифры, до и после. От хаотичных решений — к торговле по сценарию и риск‑плану.
          </motion.p>
        </div>

        {/* Stats Grid */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.3 }}
          className="grid grid-cols-2 lg:grid-cols-4 gap-4 lg:gap-6 mb-16"
        >
          {stats.map((stat, index) => (
            <motion.div
              key={stat.label}
              initial={{ opacity: 0, scale: 0.9 }}
              animate={isInView ? { opacity: 1, scale: 1 } : {}}
              transition={{ duration: 0.5, delay: 0.4 + index * 0.1 }}
              className="glass-card rounded-xl p-6 text-center group hover:border-gold-500/20 transition-colors"
            >
              <div className="w-12 h-12 rounded-lg bg-gold-500/10 flex items-center justify-center mx-auto mb-4 group-hover:bg-gold-500/20 transition-colors">
                <stat.icon className="w-6 h-6 text-gold-400" />
              </div>
              <div className="text-3xl lg:text-4xl font-bold text-gradient mb-1">{stat.value}</div>
              <div className="text-sm font-medium text-white mb-1">{stat.label}</div>
              <div className="text-xs text-muted-foreground">{stat.description}</div>
            </motion.div>
          ))}
        </motion.div>

        {/* Case Studies */}
        <div className="grid md:grid-cols-3 gap-6 mb-12">
          {caseStudies.map((study, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 30 }}
              animate={isInView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.5, delay: 0.5 + index * 0.1 }}
              className={`glass-card rounded-xl p-6 border ${study.borderColor} relative overflow-hidden group`}
            >
              {/* Gradient Background */}
              <div className={`absolute inset-0 bg-gradient-to-br ${study.color} opacity-50`} />
              
              <div className="relative z-10">
                <div className={`text-4xl lg:text-5xl font-bold ${study.textColor} mb-6`}>
                  {study.result}
                </div>
                
                <div className="space-y-4">
                  <div>
                    <div className="flex items-center gap-2 mb-2">
                      <TrendingDown className="w-4 h-4 text-red-400" />
                      <span className="text-xs text-muted-foreground uppercase tracking-wider">До</span>
                    </div>
                    <p className="text-sm text-white/70">{study.before}</p>
                  </div>
                  
                  <div className="h-px bg-white/10" />
                  
                  <div>
                    <div className="flex items-center gap-2 mb-2">
                      <TrendingUp className="w-4 h-4 text-green-400" />
                      <span className="text-xs text-gold-400 uppercase tracking-wider">После</span>
                    </div>
                    <p className="text-sm text-white">{study.after}</p>
                  </div>
                </div>
              </div>
            </motion.div>
          ))}
        </div>

        {/* Disclaimer */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={isInView ? { opacity: 1 } : {}}
          transition={{ duration: 0.5, delay: 0.8 }}
          className="text-center"
        >
          <p className="text-xs text-muted-foreground/60 max-w-xl mx-auto">
            <span className="text-gold-400/80">*</span> Прошлые результаты не гарантируют будущих. 
            Ключ — навык и соблюдение риск‑менеджмента. Каждый результат индивидуален и зависит от 
            множества факторов, включая дисциплину и посвящённое время.
          </p>
        </motion.div>
      </div>
    </section>
  );
}
