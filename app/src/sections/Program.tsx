import { motion } from 'framer-motion';
import { useInView } from 'framer-motion';
import { useRef, useState } from 'react';
import { BookOpen, ChevronDown, Check, Lock, Play, FileText, Users, MessageSquare } from 'lucide-react';

const modules = [
  {
    number: '01',
    title: 'Логика объёмов: где «деньги»',
    description: 'Как объёмы и ликвидность двигают цену. Учимся видеть след капитала и понимать, почему рынок пошёл именно туда.',
    topics: ['Объёмы vs ликвидность', 'Чтение ленты принтов', 'Зоны накопления и распределения', 'Идентификация крупных игроков'],
    duration: '2 недели',
    lessons: 8,
  },
  {
    number: '02',
    title: 'Инструменты и аналитический софт',
    description: 'Настройка рабочего пространства и чтение рынка: объёмные метрики, подтверждения, точки интереса и отмены сценария.',
    topics: ['ATAS, Bookmap, ClusterDelta', 'Настройка тепловых карт', 'Дельта и объёмные профили', 'Алерты и автоматизация'],
    duration: '1 неделя',
    lessons: 5,
  },
  {
    number: '03',
    title: 'Точный вход: сценарий и подтверждение',
    description: 'Вход «до пункта» — это не магия. Это сочетание контекста, объёма и точек, где риск контролируем.',
    topics: ['Поиск точек интереса', 'Подтверждение через объёмы', 'Время входа и паттерны', 'Ложные пробои и ловушки'],
    duration: '2 недели',
    lessons: 10,
  },
  {
    number: '04',
    title: 'Риск-менеджмент и дисциплина',
    description: 'Размер позиции, лимиты, стоп‑логика и правила «когда не торговать». Стабильность строится на риске.',
    topics: ['Расчёт размера позиции', 'Стоп-лосс и тейк-профит', 'Управление капиталом', 'Психология трейдинга'],
    duration: '1 неделя',
    lessons: 6,
  },
  {
    number: '05',
    title: 'Сопровождение и выход из сделки',
    description: 'Как вести позицию: цели, частичные фиксации, перенос стопа и выход по сценарию — без хаоса и эмоций.',
    topics: ['Трейлинг-стопы', 'Частичная фиксация прибыли', 'Управление открытой позицией', 'Выход по объёмам'],
    duration: '1 неделя',
    lessons: 5,
  },
  {
    number: '06',
    title: 'Рынки: FX · FORTS · Crypto · MOEX · US',
    description: 'Переносим один метод на разные рынки: что меняется в ликвидности, волатильности и правилах исполнения.',
    topics: ['Особенности каждого рынка', 'Выбор рынка под себя', 'Время торговли', 'Комиссии и проскальзывание'],
    duration: '2 недели',
    lessons: 8,
  },
  {
    number: '07',
    title: 'Практика на реальных сделках',
    description: 'Разборы ситуаций, домашние задания, обратная связь. Учимся делать выводы и улучшать качество решений.',
    topics: ['Разбор сделок учеников', 'Групповые сессии', 'Индивидуальная обратная связь', 'Формирование торгового плана'],
    duration: '2 недели',
    lessons: 12,
  },
  {
    number: '08',
    title: 'Создание собственной системы',
    description: 'Интеграция всех знаний в единую торговую систему, адаптированную под ваш стиль и темперамент.',
    topics: ['Выбор стиля торговли', 'Создание чек-листа', 'Ведение торгового дневника', 'Постоянное совершенствование'],
    duration: '1 неделя',
    lessons: 4,
  },
];

const premiumFeatures = [
  'Углублённый курс по макроэкономике: контекст, новости, циклы',
  'Профессиональный курс по опционам: механика, риски, стратегии',
  'Приоритетная поддержка и ответы на вопросы',
];

export default function Program() {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: '-100px' });
  const [expandedModule, setExpandedModule] = useState<string | null>('01');

  const scrollToSection = (href: string) => {
    const element = document.querySelector(href);
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' });
    }
  };

  return (
    <section id="program" className="relative py-24 lg:py-32 overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 bg-dark-900">
        {/* Background Grid Image */}
        <div 
          className="absolute inset-0 bg-cover bg-center bg-no-repeat opacity-12"
          style={{ backgroundImage: 'url(/landing/bg-grid.jpg)' }}
        />
        
        {/* Dark Overlay */}
        <div className="absolute inset-0 bg-gradient-to-b from-dark-900 via-dark-900/92 to-dark-900" />
        
        <div className="absolute top-1/2 left-0 w-[500px] h-[500px] bg-gold-500/5 rounded-full blur-[150px] -translate-y-1/2" />
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
            <BookOpen className="w-4 h-4 text-gold-400" />
            <span className="text-sm text-gold-400 font-medium">Программа курса</span>
          </motion.span>
          
          <motion.h2
            initial={{ opacity: 0, y: 30 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.6, delay: 0.1 }}
            className="heading-lg mb-6"
          >
            <span className="text-white">Только то, что реально</span>
            <br />
            <span className="text-gradient">используется в торговле</span>
          </motion.h2>
          
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="body-lg max-w-2xl mx-auto"
          >
            Никаких абстрактных теорий — только практика, сценарии и риск‑план. 
            8 модулей, которые превратят вас в профессионального трейдера.
          </motion.p>
        </div>

        {/* Modules Accordion */}
        <div className="space-y-4 mb-12">
          {modules.map((module, index) => (
            <motion.div
              key={module.number}
              initial={{ opacity: 0, y: 20 }}
              animate={isInView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.5, delay: 0.3 + index * 0.05 }}
              className={`glass-card rounded-xl overflow-hidden transition-all duration-300 ${
                expandedModule === module.number ? 'border-gold-500/30' : ''
              }`}
            >
              <button
                onClick={() => setExpandedModule(expandedModule === module.number ? null : module.number)}
                className="w-full px-6 py-5 flex items-center gap-4 text-left"
              >
                <span className="number-badge shrink-0">{module.number}</span>
                <div className="flex-1 min-w-0">
                  <h3 className="text-lg font-semibold text-white truncate">{module.title}</h3>
                </div>
                <div className="hidden sm:flex items-center gap-4 text-sm text-muted-foreground shrink-0">
                  <span className="flex items-center gap-1">
                    <Play className="w-4 h-4" />
                    {module.lessons} уроков
                  </span>
                  <span className="flex items-center gap-1">
                    <ClockIcon className="w-4 h-4" />
                    {module.duration}
                  </span>
                </div>
                <ChevronDown 
                  className={`w-5 h-5 text-muted-foreground shrink-0 transition-transform duration-300 ${
                    expandedModule === module.number ? 'rotate-180' : ''
                  }`} 
                />
              </button>
              
              <motion.div
                initial={false}
                animate={{ 
                  height: expandedModule === module.number ? 'auto' : 0,
                  opacity: expandedModule === module.number ? 1 : 0
                }}
                transition={{ duration: 0.3 }}
                className="overflow-hidden"
              >
                <div className="px-6 pb-6 pt-2">
                  <p className="text-muted-foreground mb-4">{module.description}</p>
                  <div className="grid sm:grid-cols-2 gap-2">
                    {module.topics.map((topic, i) => (
                      <div key={i} className="flex items-center gap-2 text-sm text-white/80">
                        <Check className="w-4 h-4 text-gold-400 shrink-0" />
                        <span>{topic}</span>
                      </div>
                    ))}
                  </div>
                  <div className="flex sm:hidden items-center gap-4 mt-4 text-sm text-muted-foreground">
                    <span className="flex items-center gap-1">
                      <Play className="w-4 h-4" />
                      {module.lessons} уроков
                    </span>
                    <span className="flex items-center gap-1">
                      <ClockIcon className="w-4 h-4" />
                      {module.duration}
                    </span>
                  </div>
                </div>
              </motion.div>
            </motion.div>
          ))}
        </div>

        {/* Premium Features */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.7 }}
          className="glass-card rounded-xl p-6 lg:p-8 border-gold-500/20"
        >
          <div className="flex items-center gap-3 mb-6">
            <div className="w-10 h-10 rounded-lg bg-gold-500/10 flex items-center justify-center">
              <Lock className="w-5 h-5 text-gold-400" />
            </div>
            <div>
              <h3 className="text-lg font-semibold text-white">Дополнительно в тарифах Премиум и PRO</h3>
              <p className="text-sm text-muted-foreground">Расширенная программа для максимальных результатов</p>
            </div>
          </div>
          <div className="grid md:grid-cols-3 gap-4">
            {premiumFeatures.map((feature, index) => (
              <div key={index} className="flex items-start gap-3 p-4 bg-white/5 rounded-lg">
                <Check className="w-5 h-5 text-gold-400 shrink-0 mt-0.5" />
                <span className="text-sm text-white/80">{feature}</span>
              </div>
            ))}
          </div>
        </motion.div>

        {/* CTA */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.5, delay: 0.8 }}
          className="flex flex-col sm:flex-row items-center justify-center gap-4 mt-12"
        >
          <button
            onClick={() => scrollToSection('#program')}
            className="btn-primary flex items-center gap-2"
          >
            <FileText className="w-4 h-4" />
            Смотреть программу
          </button>
          <button
            onClick={() => scrollToSection('#pricing')}
            className="btn-secondary flex items-center gap-2"
          >
            <Users className="w-4 h-4" />
            Выбрать тариф
          </button>
        </motion.div>

        {/* Note */}
        <motion.p
          initial={{ opacity: 0 }}
          animate={isInView ? { opacity: 1 } : {}}
          transition={{ duration: 0.5, delay: 0.9 }}
          className="text-center text-sm text-muted-foreground mt-6"
        >
          <MessageSquare className="w-4 h-4 inline mr-1" />
          Дополнительно во время обучения ты попадаешь в закрытый чат учеников, где находятся как участники текущего потока, так и выпускники прошлых.
        </motion.p>
      </div>
    </section>
  );
}

function ClockIcon({ className }: { className?: string }) {
  return (
    <svg className={className} fill="none" viewBox="0 0 24 24" stroke="currentColor">
      <circle cx="12" cy="12" r="10" strokeWidth="2" />
      <path strokeWidth="2" strokeLinecap="round" d="M12 6v6l4 2" />
    </svg>
  );
}
