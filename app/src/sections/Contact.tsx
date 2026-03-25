import { motion } from 'framer-motion';
import { useInView } from 'framer-motion';
import { useRef, useState } from 'react';
import { Send, User, Mail, MessageSquare, Calendar, CheckCircle, AlertCircle } from 'lucide-react';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Label } from '@/components/ui/label';
import { sendLeadToTelegram } from '@/services/telegram';

export default function Contact() {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: '-100px' });
  const [isSubmitted, setIsSubmitted] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState('');
  const [formData, setFormData] = useState({
    name: '',
    telegram: '',
    email: '',
    message: '',
  });
  const [errors, setErrors] = useState<Record<string, string>>({});

  const validateForm = () => {
    const newErrors: Record<string, string> = {};
    if (!formData.name.trim()) {
      newErrors.name = 'Укажите имя';
    }
    if (!formData.telegram.trim() && !formData.email.trim()) {
      newErrors.contact = 'Укажите хотя бы Telegram или Email';
    }
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validateForm()) return;

    setSubmitError('');
    setIsSubmitting(true);
    
    // Отправляем заявку в Telegram
    const success = await sendLeadToTelegram({
      name: formData.name,
      telegram: formData.telegram,
      email: formData.email,
      message: formData.message,
    });
    
    setIsSubmitting(false);
    
    if (success) {
      setIsSubmitted(true);
    } else {
      setSubmitError('Ошибка отправки. Проверьте TG_BOT_TOKEN или сеть и попробуйте снова.');
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }
  };

  return (
    <section id="contact" className="relative py-24 lg:py-32 overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 bg-dark-900">
        {/* Background Chart Image */}
        <div 
          className="absolute inset-0 bg-cover bg-center bg-no-repeat opacity-10"
          style={{ backgroundImage: 'url(/landing/chart-bg-1.jpg)' }}
        />
        
        {/* Dark Overlay */}
        <div className="absolute inset-0 bg-gradient-to-b from-dark-900 via-dark-900/95 to-dark-900" />
        
        <div className="absolute inset-0 bg-gradient-to-b from-transparent via-gold-500/5 to-transparent" />
        <div className="absolute bottom-0 left-1/2 -translate-x-1/2 w-[800px] h-[400px] bg-gold-500/10 rounded-full blur-[150px]" />
      </div>

      <div className="relative z-10 section-padding max-w-4xl mx-auto">
        {/* Section Header */}
        <div ref={ref} className="text-center mb-12">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5 }}
            className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-gold-500/10 border border-gold-500/20 mb-6"
          >
            <Calendar className="w-4 h-4 text-gold-400" />
            <span className="text-sm text-gold-400 font-medium">Старт потока 15.04.2026</span>
          </motion.div>
          
          <motion.h2
            initial={{ opacity: 0, y: 30 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.6, delay: 0.1 }}
            className="heading-lg mb-6"
          >
            <span className="text-white">Записаться</span>
            <span className="text-gradient"> на курс</span>
          </motion.h2>
          
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="body-lg"
          >
            Оставьте заявку — поможем подобрать тариф, ответим на вопросы и при необходимости отправим ссылки на наши Telegram-каналы с реальными сделками.
          </motion.p>
        </div>

        {/* Form */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.3 }}
          className="glass-card rounded-2xl p-8 lg:p-10"
        >
          {isSubmitted ? (
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              className="text-center py-12"
            >
              <div className="w-20 h-20 rounded-full bg-green-500/10 flex items-center justify-center mx-auto mb-6">
                <CheckCircle className="w-10 h-10 text-green-400" />
              </div>
              <h3 className="text-2xl font-bold text-white mb-4">Заявка отправлена!</h3>
              <p className="text-muted-foreground mb-6">
                Спасибо за интерес к курсу. Мы свяжемся с вами в ближайшее время для консультации.
              </p>
              <button
                onClick={() => {
                  setIsSubmitted(false);
                  setFormData({ name: '', telegram: '', email: '', message: '' });
                }}
                className="text-gold-400 hover:text-gold-300 transition-colors"
              >
                Отправить ещё одну заявку
              </button>
            </motion.div>
          ) : (
            <form onSubmit={handleSubmit} className="space-y-6">
              <div className="grid sm:grid-cols-2 gap-6">
                {/* Name */}
                <div className="space-y-2">
                  <Label htmlFor="name" className="text-white flex items-center gap-2">
                    <User className="w-4 h-4 text-gold-400" />
                    Имя
                  </Label>
                  <Input
                    id="name"
                    name="name"
                    value={formData.name}
                    onChange={handleChange}
                    placeholder="Ваше имя"
                    className="bg-dark-700/50 border-white/10 text-white placeholder:text-muted-foreground focus:border-gold-500/50"
                  />
                  {errors.name && (
                    <p className="text-sm text-red-400 flex items-center gap-1">
                      <AlertCircle className="w-3 h-3" />
                      {errors.name}
                    </p>
                  )}
                </div>

                {/* Telegram */}
                <div className="space-y-2">
                  <Label htmlFor="telegram" className="text-white flex items-center gap-2">
                    <Send className="w-4 h-4 text-blue-400" />
                    Telegram
                  </Label>
                  <Input
                    id="telegram"
                    name="telegram"
                    value={formData.telegram}
                    onChange={handleChange}
                    placeholder="@username"
                    className="bg-dark-700/50 border-white/10 text-white placeholder:text-muted-foreground focus:border-gold-500/50"
                  />
                </div>
              </div>

              {/* Email */}
              <div className="space-y-2">
                <Label htmlFor="email" className="text-white flex items-center gap-2">
                  <Mail className="w-4 h-4 text-gold-400" />
                  Email
                </Label>
                <Input
                  id="email"
                  name="email"
                  type="email"
                  value={formData.email}
                  onChange={handleChange}
                  placeholder="your@email.com"
                  className="bg-dark-700/50 border-white/10 text-white placeholder:text-muted-foreground focus:border-gold-500/50"
                />
                {errors.contact && (
                  <p className="text-sm text-red-400 flex items-center gap-1">
                    <AlertCircle className="w-3 h-3" />
                    {errors.contact}
                  </p>
                )}
              </div>

              {/* Message */}
              <div className="space-y-2">
                <Label htmlFor="message" className="text-white flex items-center gap-2">
                  <MessageSquare className="w-4 h-4 text-gold-400" />
                  Сообщение (необязательно)
                </Label>
                <Textarea
                  id="message"
                  name="message"
                  value={formData.message}
                  onChange={handleChange}
                  placeholder="Расскажите о своём опыте в трейдинге или задайте вопрос..."
                  rows={4}
                  className="bg-dark-700/50 border-white/10 text-white placeholder:text-muted-foreground focus:border-gold-500/50 resize-none"
                />
              </div>

              {/* Submit Button */}
              <button
                type="submit"
                disabled={isSubmitting}
                className="btn-primary w-full flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {isSubmitting ? (
                  <>
                    <div className="w-5 h-5 border-2 border-dark-900/30 border-t-dark-900 rounded-full animate-spin" />
                    Отправка...
                  </>
                ) : (
                  <>
                    <Send className="w-4 h-4" />
                    Записаться на курс
                  </>
                )}
              </button>

              {submitError && (
                <p className="text-sm text-red-400 text-center">{submitError}</p>
              )}

              <p className="text-xs text-muted-foreground text-center">
                Нажимая кнопку, вы соглашаетесь с{' '}
                <a href="/politika" className="text-gold-400 hover:underline">политикой конфиденциальности</a>
              </p>
            </form>
          )}
        </motion.div>
      </div>
    </section>
  );
}
