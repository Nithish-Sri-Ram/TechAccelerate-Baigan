# 🚨 AI-Powered Emergency Tracker Mobile App

## Overview

The **AI-Powered Emergency Tracker** is a life-saving mobile application built with **Flutter** and **Dart**, designed to detect emergencies such as accidents in real-time and instantly alert emergency contacts and nearby hospitals. Powered by a trained **LSTM (Long Short-Term Memory)** model and utilizing **Firebase** for secure authentication, the app ensures both reliability and responsiveness.

Aimed at users who are at higher risk of accidents or medical emergencies, this app delivers proactive, AI-driven safety monitoring through movement pattern recognition and real-time communication.

---

## 🔑 Key Features

### 🚨 SOS Button
- Instantly triggers emergency protocols.
- Activates the microphone to record and transcribe audio.
- Sends both the **audio** and **transcript** to emergency contacts and local medical facilities.

### 🤖 AI-Powered Emergency Detection
- Uses a custom-trained **LSTM model** to monitor and analyze user movement.
- Detects abnormal patterns indicative of falls or accidents.

### 🏥 Automatic Nearby Hospital Identification
- Uses **Google Maps Places API** to fetch and display:
  - Hospital name
  - Open/closed status
  - Ratings
  - Contact details
  - Real-time navigation support

### 🛑 False Alarm Prevention Timer
- Introduces a **60-second buffer** after detecting an anomaly.
- Continuously analyzes movement to confirm emergency status before alerting responders.

### ⚡ Real-Time Alerts via WebSockets
- Enables **instant communication** between user, emergency contacts, and hospitals.
- Ensures low-latency data exchange using **WebSocket** integration.

---

## 🛠 Technology Stack

| Component         | Technology                    |
|------------------|-------------------------------|
| Frontend         | Flutter, Dart                 |
| Backend          | FastAPI                       |
| Authentication   | Firebase                      |
| AI Model         | LSTM (TensorFlow/Keras)       |
| Real-Time Comm.  | WebSocket                     |
| Mapping & Places | Google Maps Places API        |

---

## 🙌 Why Choose This App?

- **Instant Emergency Response**: Alerts sent within seconds.
- **AI-Driven Accuracy**: Reduces false alarms using pattern-based detection.
- **User-Friendly Interface**: Designed for ease of use in high-stress moments.
- **Real-Time Communication**: Ensures rapid and dependable information delivery.

---

## 👤 Ideal For

- Elderly individuals living alone
- People with chronic health conditions
- Outdoor adventurers and athletes
- Anyone seeking a personal safety net

---

## 🚀 Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Nithish-Sri-Ram/TechAccelerate-Baigan
   cd TechAccelerate-Baigan
   ```

2. **Install dependencies:**
   - For Flutter app
   - For FastAPI backend
   - For Firebase integration

3. **Set up Firebase Authentication:**
   - Configure Firebase project
   - Add `google-services.json` or `GoogleService-Info.plist` as required

4. **Set up Google Maps API Keys:**
   - Enable Places API in Google Cloud Console
   - Insert your API key in relevant files

5. **Deploy the backend:**
   - Run FastAPI server
   - Load the trained LSTM model

6. **Run the Flutter app:**
   - Use `flutter run` on a physical/emulated device

---

## 📸 Screenshots

![WhatsApp Image 2025-05-01 at 01 28 08_60b64482](https://github.com/user-attachments/assets/3ce7e2cb-c615-48ea-ad1e-825688aa7cbc)
![WhatsApp Image 2025-05-01 at 01 28 07_6ed5bdce](https://github.com/user-attachments/assets/68ce82ff-5c3d-48cf-bd60-f4d4d8345e38)
![Screenshot_1742731869](https://github.com/user-attachments/assets/f48e10ba-53d7-45d8-bdc7-0a1fb1e7fa56)
![Screenshot_1742730656](https://github.com/user-attachments/assets/668902ff-2718-4b67-8bf8-764c1a47a3ad)
![WhatsApp Image 2025-05-01 at 01 28 11_fa84a08e](https://github.com/user-attachments/assets/4757058a-81e9-4f05-b485-fd6740b6caf9)
![WhatsApp Image 2025-05-01 at 01 28 09_7c6c83c9](https://github.com/user-attachments/assets/3a293fe4-2a10-409e-bd9e-a809c90e6bed)
![WhatsApp Image 2025-05-01 at 01 28 16_a9407afe](https://github.com/user-attachments/assets/50820eb5-39cd-480e-9ca3-da87f6d66edd)
![WhatsApp Image 2025-05-01 at 01 28 15_c3bf78c0](https://github.com/user-attachments/assets/b64bfe3d-84af-49dd-95cc-0e08d3185ddd)


---

## 🧭 App Flow Diagram

![WhatsApp Image 2025-05-01 at 01 28 14_9ddfc4fa](https://github.com/user-attachments/assets/d058594e-a5e7-428c-b85a-389ed047828a)

---

## 📬 Contributing & Feedback

Contributions, suggestions, and feedback are welcome! Please open an issue or submit a pull request to improve the app.

---

## 📄 License

MIT License © [Nithish Sri Ram](https://github.com/Nithish-Sri-Ram)
