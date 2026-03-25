import { motion } from 'framer-motion';
import { useInView } from 'framer-motion';
import { useRef } from 'react';
import { HelpCircle, MessageCircle } from 'lucide-react';
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from '@/components/ui/accordion';

const faqs = [
  {
    question: 'Как устроена поддержка во время и после обучения?',
    answer: 'Во время обучения вы получаете доступ к закрытому чату учеников, где можно задавать вопросы и получать обратную связь. Преподаватели и выпускники помогают разбирать сделки и ситуации. После окончания курса доступ к материалам остаётся у вас навсегда, а в зависимости от тарифа поддержка продолжается от 3 до 12 месяцев.',
  },
  {
    question: 'Сколько времени нужно уделять обучению?',
    answer: 'Рекомендуется уделять минимум 5-10 часов в неделю: просмотр уроков, выполнение домашних заданий и практика на демо-счёте. Чем больше времени вы посвящаете практике, тем быстрее осваиваете материал. Гибкий формат позволяет учиться в удобном темпе.',
  },
  {
    question: 'Где посмотреть сделки и статистику команды?',
    answer: 'Все сделки публикуются в наших открытых Telegram-каналах. Вы можете подписаться и наблюдать за торговлей в реальном времени, проверить статистику и убедиться в результативности подхода. Ссылки на каналы доступны на сайте.',
  },
  {
    question: 'Чем этот курс отличается от других?',
    answer: 'Мы — команда практиков, которая торгует в реальном времени и показывает результат открыто. Не даём «сигналов» и не обещаем лёгких денег. Учим понимать рынок через объёмный анализ, чтобы вы могли принимать самостоятельные решения. 14 лет практики и 500+ выпускников — наша репутация.',
  },
  {
    question: 'Подходит ли курс для начинающих?',
    answer: 'Да, курс подходит для всех уровней. Мы начинаем с основ и постепенно переходим к продвинутым темам. Главное — готовность учиться и посвящать время практике. Начинающие получают прочный фундамент, опытные трейдеры — новые инструменты для анализа.',
  },
  {
    question: 'Какое оборудование и ПО нужно?',
    answer: 'Вам понадобится компьютер с доступом в интернет. Мы используем профессиональные платформы для анализа объёмов (ATAS, Bookmap, ClusterDelta) — настраиваем всё вместе на занятиях. Большинство платформ имеют бесплатные пробные периоды или демо-версии.',
  },
  {
    question: 'Можно ли оформить рассрочку?',
    answer: 'Да, для тарифов Премиум и PRO доступна рассрочка через партнёрские банки. Уточните детали при консультации — мы поможем подобрать оптимальный вариант оплаты.',
  },
  {
    question: 'Что если я пропущу занятие?',
    answer: 'Все занятия записываются и доступны в личном кабинете. Вы можете смотреть записи в удобное время и задавать вопросы по пропущенным темам в чате поддержки.',
  },
];

export default function FAQ() {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: '-100px' });

  return (
    <section id="faq" className="relative py-24 lg:py-32 overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 bg-dark-900">
        <div className="absolute top-1/2 right-0 w-[500px] h-[500px] bg-gold-500/5 rounded-full blur-[150px] -translate-y-1/2" />
      </div>

      <div className="relative z-10 section-padding max-w-4xl mx-auto">
        {/* Section Header */}
        <div ref={ref} className="text-center mb-12">
          <motion.span
            initial={{ opacity: 0, y: 20 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5 }}
            className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-gold-500/10 border border-gold-500/20 mb-6"
          >
            <HelpCircle className="w-4 h-4 text-gold-400" />
            <span className="text-sm text-gold-400 font-medium">Частые вопросы</span>
          </motion.span>
          
          <motion.h2
            initial={{ opacity: 0, y: 30 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.6, delay: 0.1 }}
            className="heading-lg mb-4"
          >
            <span className="text-white">Есть</span>
            <span className="text-gradient"> вопросы?</span>
          </motion.h2>
          
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="body-lg"
          >
            Ответы на самые популярные вопросы о курсе и обучении
          </motion.p>
        </div>

        {/* FAQ Accordion */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.3 }}
        >
          <Accordion type="single" collapsible className="space-y-4">
            {faqs.map((faq, index) => (
              <AccordionItem
                key={index}
                value={`item-${index}`}
                className="glass-card rounded-xl border-0 px-6 data-[state=open]:border-gold-500/30 transition-colors"
              >
                <AccordionTrigger className="text-left text-white hover:text-gold-400 py-5 text-base font-medium [&[data-state=open]>svg]:rotate-180">
                  {faq.question}
                </AccordionTrigger>
                <AccordionContent className="text-muted-foreground pb-5 leading-relaxed">
                  {faq.answer}
                </AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>
        </motion.div>

        {/* Contact CTA */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.5, delay: 0.6 }}
          className="mt-12 text-center"
        >
          <p className="text-muted-foreground mb-4">
            Не нашли ответ на свой вопрос?
          </p>
          <a
            href="#contact"
            onClick={(e) => {
              e.preventDefault();
              document.querySelector('#contact')?.scrollIntoView({ behavior: 'smooth' });
            }}
            className="inline-flex items-center gap-2 text-gold-400 hover:text-gold-300 transition-colors"
          >
            <MessageCircle className="w-4 h-4" />
            <span className="font-medium">Задайте его нам напрямую</span>
          </a>
        </motion.div>
      </div>
    </section>
  );
}
