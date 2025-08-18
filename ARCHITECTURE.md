
# System Architecture – SpeakUpP

SpeakUpP is a mobile-first speech therapy application designed to support children with speech disorders. Below is the technical architecture of the system.

## 🧱 Tech Stack

- **Frontend**: Flutter (mobile application)
- **Backend**: Supabase (authentication, data storage, hosting)
- **AI Integration**: OpenAI Whisper API (speech recognition)
- **Bot Interface**: Telegram Bot API (accessible interaction layer)

## ⚙️ Architecture Diagram (Text)

```
[User] → [Mobile App (Flutter)]
        → [Speechy Bot] → [Telegram Bot API]
        → [Speech Recognition] → [OpenAI Whisper]
        → [Database & Auth] → [Supabase]
```

## 🔐 Security

- Authentication via Supabase
- Secure cloud storage of progress and audio templates
- Parental controls and access limitations

## 🌐 Scalability

The app is designed to scale to support additional languages, therapy content, and real-time therapist communication modules.
