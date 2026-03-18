# WEIRD - Layer_01 👁️‍🗨️

**Ghost Lab – Stealth Web Audit Tool**

---

## 📌 Repository Description

Stealth web reconnaissance tool using Tor and Proxychains for low-noise surface analysis.

---

## 🎓 Learning Purpose

This project was developed as part of my personal learning process in Bash scripting with a focus on cybersecurity.

Although there are far more advanced and specialized tools available, this script aims to provide a practical approach to understanding web reconnaissance, stealth techniques, and basic vulnerability discovery.

It is primarily intended for educational purposes and is not meant to replace professional tools.

---

## 🧠 Overview

WEIRD Layer_01 is a stealth-oriented web reconnaissance script designed to gather useful information about a target website while minimizing detection.

It operates through **Tor + Proxychains**, ensuring anonymized traffic and reduced footprint during analysis.

This tool is intended for:

* Cybersecurity learning
* Ethical reconnaissance
* Passive security assessment

---

## ⚙️ Features

* 🔒 **Tor-based anonymity** (SOCKS5)
* 🧅 **Automatic Tor IP rotation**
* 🌐 HTTP/HTTPS analysis (status codes, headers)
* 🖥️ Server fingerprinting (Server header)
* 🌍 DNS resolution via proxychains (multi-DNS fallback)
* 🧠 Basic **XSS detection** (reflected payload test)
* 📊 HTML analysis:

  * JavaScript count
  * Forms detection
  * Cookie presence
* 🗂️ Sensitive path discovery:

  * `/robots.txt`, `/admin`, `/login`, `.git`, `.env`, etc.
* 🔍 Optional IP intelligence via **ipinfo.io API**
* 📝 Logging system with timestamped output

---

## 🚀 Usage

```bash
bash Weird_Layer01.sh example.com
```

Or with your bootstrap (recommended):

```bash
bash ghost_bootstrap.sh example.com
```

---

## 🔑 API Configuration (Optional)

To enable IP intelligence enrichment, insert your API key:

```bash
IPINFO_API_TOKEN="YOUR_API_KEY_HERE"
```

Get a free token here:
👉 [https://ipinfo.io/](https://ipinfo.io/)

If no key is provided, this step is skipped automatically.

---

## 📂 Output

Logs are stored in:

```
$HOME/Weird/Weird_Log/
```

---

Each scan generates a timestamped log file.

---

## ⚠️ Disclaimer

This tool is provided for **educational and ethical purposes only**.

You are responsible for how you use it.

Do not scan systems without proper authorization.

---

## 🧩 Roadmap

- Layer_02: Advanced vulnerability detection
- Framework detection (React, Vue, Next.js)
- Security headers scoring
- Modular plugin system

---

## 👁️ Ghost Philosophy

> "Move quietly. Observe everything. Leave nothing behind."

---

## 🛠️ Requirements

- `tor`
- `proxychains4`
- `curl`
- `dig`
- `nc`
- `grep`, `awk`, `sed`

---

## 📜 License

MIT License

---

💀 Built for the Wired.

```

