/**
 * Создаёт пользователя-владельца (админа) в Firebase Auth и документ в Firestore с isOwner: true.
 *
 * Запуск:
 *   1. Скачайте ключ сервисного аккаунта: Firebase Console → Project settings → Service accounts → Generate new private key.
 *   2. Сохраните как scripts/serviceAccountKey.json (или укажите путь в GOOGLE_APPLICATION_CREDENTIALS).
 *   3. cd scripts && npm install && node create-admin.js
 *
 * Или с параметрами:
 *   node create-admin.js --email admin@mail.ru --password Admin1234 --name "Admin"
 */

import admin from 'firebase-admin';
import { readFileSync, existsSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __dirname = dirname(fileURLToPath(import.meta.url));

function parseArgs() {
  const args = process.argv.slice(2);
  const out = { email: 'admin@mail.ru', password: 'Admin1234', name: 'Admin', projectId: 'my-blog-1766143027' };
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--email' && args[i + 1]) out.email = args[++i];
    else if (args[i] === '--password' && args[i + 1]) out.password = args[++i];
    else if (args[i] === '--name' && args[i + 1]) out.name = args[++i];
    else if (args[i] === '--project' && args[i + 1]) out.projectId = args[++i];
  }
  return out;
}

async function main() {
  const { email, password, name, projectId } = parseArgs();

  const keyPath = process.env.GOOGLE_APPLICATION_CREDENTIALS || join(__dirname, 'serviceAccountKey.json');
  if (!existsSync(keyPath)) {
    console.error('Не найден ключ сервисного аккаунта.');
    console.error('Положите JSON-ключ в scripts/serviceAccountKey.json или задайте GOOGLE_APPLICATION_CREDENTIALS.');
    console.error('Скачать: Firebase Console → Project settings → Service accounts → Generate new private key.');
    process.exit(1);
  }

  const key = JSON.parse(readFileSync(keyPath, 'utf8'));
  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.cert(key),
      projectId: key.project_id || projectId,
    });
  }

  const auth = admin.auth();
  const firestore = admin.firestore();

  let uid;
  try {
    const userRecord = await auth.createUser({
      email,
      password,
      displayName: name,
      emailVerified: true,
    });
    uid = userRecord.uid;
    console.log('Пользователь создан в Auth:', uid, userRecord.email);
  } catch (e) {
    if (e.code === 'auth/email-already-exists') {
      const user = await auth.getUserByEmail(email);
      uid = user.uid;
      await auth.updateUser(uid, { password, displayName: name });
      console.log('Пользователь уже существует, обновлён пароль и имя. UID:', uid);
    } else {
      throw e;
    }
  }

  const userDoc = {
    name,
    uid,
    profilePic: '',
    isOnline: false,
    phoneNumber: email,
    isOwner: true,
  };

  await firestore.collection('users').doc(uid).set(userDoc);
  console.log('Документ users/%s создан с isOwner: true', uid);
  console.log('Вход: email =', email, ', пароль = (тот что указали)');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
