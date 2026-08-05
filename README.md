# 🛡️ PasarGuard Subscription Dashboard

یک صفحه‌ی اشتراک شیک، تیره، شیشه‌ای (Glassmorphism) و کاملاً تک‌فایل برای پنل **PasarGuard** — بدون نیاز به Build، بدون نیاز به دیتابیس یا سرور جدا. کافیه یک فایل `index.html` رو توی پنل خودتون جا بدید.

---

## این پروژه چطور کار می‌کند؟

PasarGuard از یک مکانیزم رسمی برای «تمپلیت سفارشی صفحه‌ی اشتراک» پشتیبانی می‌کند: یک فایل HTML تکی می‌دید به پنل، پنل همون فایل رو مستقیماً برای هرکسی که لینک ساب رو توی مرورگر باز کنه سرو می‌کنه — یعنی **هیچ مشکل CORS‌ای در کار نیست**، چون همه‌چیز از دامنه‌ی خودتون سرو می‌شه.

این صفحه برای گرفتن اطلاعات واقعی (حجم مصرفی، تاریخ انقضا، لیست کانفیگ‌ها) دقیقاً از همون قرارداد استانداردی استفاده می‌کنه که تمام اپ‌های v2rayNG / Hiddify / Clash و غیره همین الان بهش وابسته‌ن (هدر `Subscription-Userinfo` + لیست کانفیگ‌های base64). طبق مستندات خود PasarGuard، تشخیص «مرورگر یا اپ» با هدر `Accept` انجام می‌شه — پس این صفحه با یک درخواست هم‌مبدأ (same-origin، بدون CORS) به آدرس خودش، همون داده‌ی خامی رو می‌گیره که اپ‌ها می‌گیرن. همین باعث می‌شه این روش، در برابر تغییرات نسخه‌های بعدی پنل هم پایدار بمونه، چون به یک ساختار داخلی و مستندنشده وابسته نیست.

اگر پنل شما یک ساختار اضافه‌ی `window.__INITIAL_DATA__` هم به این فایل تزریق کنه، صفحه از اون برای غنی‌تر کردن نمایش (مثل عنوان پروفایل) استفاده می‌کنه — ولی به آن **وابسته نیست**، پس با نسخه‌های مختلف پنل هم کار می‌کنه.

---

## نصب سریع (پیشنهادی)

روی سرور پنلتون، داخل پوشه‌ی این پروژه:

```bash
sudo bash install.sh
```

اسکریپت این کارها رو انجام می‌ده:
1. فایل `index.html` رو توی `/var/lib/pasarguard/templates/subscription/index.html` کپی می‌کنه (هر فایل قبلی رو قبلش بکاپ می‌گیره).
2. اگه دو خط لازم توی `.env` پنل نبود، با اجازه‌ی شما اضافه‌شون می‌کنه (هیچ‌وقت مقدار موجود رو خودش عوض نمی‌کنه — اگه فرق داشته باشه فقط بهتون نشون می‌ده).
3. با تأیید شما پنل رو ری‌استارت می‌کنه.

با `sudo bash install.sh --help` گزینه‌های بیشتر (مسیر سفارشی و غیره) رو ببینید.

## نصب دستی

```bash
sudo mkdir -p /var/lib/pasarguard/templates/subscription
sudo cp index.html /var/lib/pasarguard/templates/subscription/index.html
```

توی `/opt/pasarguard/.env` (یا مسیر env پنل شما) این دو خط رو اضافه کنید:

```
CUSTOM_TEMPLATES_DIRECTORY="/var/lib/pasarguard/templates/"
SUBSCRIPTION_PAGE_TEMPLATE="subscription/index.html"
```

و در نهایت:

```bash
pasarguard restart
```

حالا هر لینک اشتراکی که کاربرهاتون توی مرورگر باز کنن، همین صفحه رو می‌بینن.

## حذف / برگرداندن به حالت قبل

```bash
sudo bash install.sh --uninstall
```

این دستور، دقیقاً برعکس نصب رو انجام می‌ده:
- اگه قبل از نصب این تمپلیت، یک تمپلیت دیگه (یا نسخه‌ی قبلی همین) اونجا بوده، از روی بکاپی که خودِ نصب گرفته بود برش می‌گردونه؛ اگه چیزی قبلش نبوده، فقط فایل رو حذف می‌کنه تا پنل به صفحه‌ی پیش‌فرض خودش برگردد.
- اگه دو خطی که موقع نصب به `.env` اضافه کرده بود هنوز دقیقاً همون مقدارن (یعنی خودتون دستی عوضش نکرده باشید)، با تأیید شما حذفشون می‌کنه.
- در آخر با تأیید شما پنل رو ری‌استارت می‌کنه.

هیچ‌کدوم از این‌ها بدون سؤال از شما انجام نمی‌شه. اگه فقط می‌خواید خودتون دستی انجامش بدید:
```bash
# فایل تمپلیت رو حذف کنید (یا نسخه‌ی قبلی‌ش که بکاپ گرفته شده بود رو برگردونید،
# دنبال یک فایل .bak.تاریخ کنار همون index.html بگردید)
sudo rm /var/lib/pasarguard/templates/subscription/index.html

# و این دو خط رو از .env پنل حذف کنید:
#   CUSTOM_TEMPLATES_DIRECTORY="..."
#   SUBSCRIPTION_PAGE_TEMPLATE="subscription/index.html"

sudo pasarguard restart
```

## پیش‌نمایش محلی (قبل از نصب)

فقط `index.html` رو مستقیم توی مرورگر باز کنید — چون به هیچ سروری وصل نیست، خودکار داده‌ی نمونه (همون‌طور که در اسکرین‌شات دیدید) نشون داده می‌شه. یا:

```bash
python3 -m http.server 8080
```

و به `http://localhost:8080` برید.

---

## شخصی‌سازی

همه‌چیز بالای فایل `index.html`، داخل بلوک `CONFIG` هست (دنبال `1) CONFIG` بگردید) — یک فایل ساده‌ی جاوااسکریپت، بدون نیاز به کامپایل:

```js
const CONFIG = {
  brand: { name: 'اسم برند شما', logoEmoji: '🛡️', logoUrl: '' },
  links: { renew: '', support: '', channel: '' }, // یوزرنیم تلگرام یا لینک کامل
  announcement: { enabled: false, text: { fa: '', en: '' }, url: '' },
  theme: { default: 'dark' },
  language: { default: 'fa' },
  apps: [ /* دکمه‌های افزودن سریع به اپ‌ها */ ],
  // ...
};
```

رنگ اصلی، شعاع گوشه‌ها و بقیه‌ی توکن‌های ظاهری هم بالای فایل `<style>` با نام‌های `--clr-signal`, `--radius-lg` و غیره قابل تغییرن.

### چیزهایی که عمداً ساده نگه داشته شدن

طبق درخواست خودتون برای یک پروژه‌ی تمیز و کم‌دردسر، این موارد از ایده‌های اولیه عمداً کنار گذاشته شدن یا ساده‌سازی شدن:

- **پینگ/سرعت زنده‌ی هر سرور:** از داخل مرورگر قابل‌اندازه‌گیری دقیق نیست (نه ICMP در دسترسه، نه اکثر نودها وب‌سرور دارن) و نتیجه‌ش گمراه‌کننده می‌شه؛ به‌جاش هر کانفیگی که پنل توی ساب برگردونه به‌عنوان «فعال» نشون داده می‌شه.
- **نمودار مصرف تاریخی (ساعتی/روزانه):** به یک endpoint داخلی و مستندنشده وابسته‌ست که بین نسخه‌های پنل ممکنه فرق کنه؛ به‌جاش همون مصرف لحظه‌ای (که کاملاً استاندارده) با حلقه‌ی گرافیکی نشون داده می‌شه.
- **برندینگ جداگانه به‌ازای هر ادمین:** یک ویژگی پیشرفته برای فروشنده‌های چندسطحیه؛ اگه لازمش داشتید، تمپلیت رسمی یا پروژه‌ی P4r34m این قابلیت رو دارن.
- **Service Worker / کش آفلاین کامل:** دقیقاً همون چیزیه که باعث «آپدیت جدید رو نمی‌بینم» می‌شه؛ به‌جاش فقط یک PWA manifest ساده برای Add to Home Screen گذاشته شده، بدون کش کردن فایل.

### لینک‌های Deep Link اپ‌ها

دکمه‌های «افزودن سریع» از URL Schemeهایی مثل `v2rayng://install-config?url=...` استفاده می‌کنن. این‌ها رو خود سازنده‌ی هر اپ تعریف می‌کنه و گاهی با آپدیت اپ عوض می‌شن. اگه یک دکمه کار نکرد، معمولاً فقط باید همون یک خط `importUrl` مربوط به همون اپ رو توی `CONFIG.apps` آپدیت کنید — بقیه‌ی صفحه بهش وابسته نیست.

---

## عیب‌یابی

**اطلاعات واقعی نشون داده نمی‌شه (همیشه داده‌ی نمونه می‌بینم):**
با curl تست کنید که پنل واقعاً هدرهای لازم رو برمی‌گردونه:
```bash
curl -I "https://your-sub-domain/sub/TOKEN"
```
باید هدر `Subscription-Userinfo` رو توی خروجی ببینید. اگه ندیدید، مشکل از تنظیمات Subscription پنلتونه نه این تمپلیت.

**QR باز نمی‌شه:** این تمپلیت برای رسم QR از یک کتابخونه‌ی سبک روی CDN استفاده می‌کنه (تنها وابستگی بیرونی این پروژه). اگه بار نشد، دکمه‌ی کپی لینک همچنان کار می‌کنه. برای حذف کامل وابستگی، فایل کتابخونه رو دانلود کنید و آدرس `cdnjs.cloudflare.com` توی `script.js`ی داخل فایل رو به مسیر لوکالتون عوض کنید.

**فونت وزیرمتن لود نمی‌شه:** تنها درخواست شبکه‌ای که این صفحه خودش می‌زنه همینه (از Google Fonts)؛ اگه بلاک بشه، فونت‌های سیستمی (Tahoma/Segoe UI) جایگزین می‌شن و صفحه همچنان درست دیده می‌شه.

---

## English (short version)

A single-file, no-build, dark/glass subscription dashboard for the **PasarGuard** panel. Drop `index.html` into PasarGuard's custom subscription-template directory and it just works — no CORS proxy, no database, no build step.

It reads live data through the exact same standard subscription contract every VPN client already relies on (`Subscription-Userinfo` header + base64 config list), fetched same-origin per PasarGuard's own documented `Accept`-header content negotiation — not through an undocumented internal data shape, so it stays working across panel versions.

**Install:** `sudo bash install.sh` (or see the manual steps above — same `.env` keys as the official template: `CUSTOM_TEMPLATES_DIRECTORY`, `SUBSCRIPTION_PAGE_TEMPLATE`). **Remove:** `sudo bash install.sh --uninstall` — restores whatever was there before, and only touches `.env` lines that match exactly what the installer added.
**Customize:** edit the `CONFIG` block at the top of `index.html`.
**Preview locally:** just open `index.html` in a browser — it shows sample data when there's nothing to fetch.

Inspired by [PasarGuard/subscription-template](https://github.com/PasarGuard/subscription-template) and [P4r34m/PasarGuard-Subscription-Template](https://github.com/P4r34m/PasarGuard-Subscription-Template).

---

## License

MIT — همین‌طوری که هست استفاده کنید، تغییرش بدید، توزیعش کنید.
