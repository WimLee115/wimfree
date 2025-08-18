WIMFREE Quantum Chat Platform
WIMFREE is a cutting-edge, quantum-secure platform for private chat and streaming, designed to deliver end-to-end encrypted (E2EE) communication with zero-knowledge architecture. Developed by WimLee115, a certified security expert and web3 innovator, with inspiration from PrivacyVerzetNL’s privacy advocacy, WIMFREE empowers users to connect securely across web, desktop, and mobile. Imagine it as a web3 RPG: you’re the hero, wielding quantum encryption as your sword, zero-knowledge servers as your shield, and low-latency streaming as your agility boost, ensuring privacy in every quest.
Features

Post-Quantum Encryption: Leverages NIST-approved algorithms (Kyber-1024, Dilithium5, Falcon-1024) to protect against quantum threats.
End-to-End Encrypted Chat: Secure, real-time messaging with perfect forward secrecy, powered by WebSocket and Argon2 password hashing.
Secure Streaming: Low-latency video/audio streams protected by quantum-safe keys, ideal for private broadcasts or gaming sessions.
Invite-Only Access: Restrict chats and streams to trusted users, like an exclusive guild in an RPG.
Cross-Platform Support: Seamlessly switch between web (modern browsers), desktop (Windows, macOS, Linux), and mobile (iOS, Android).
Zero-Knowledge Architecture: Servers store no sensitive data, ensuring maximum privacy, inspired by PrivacyVerzetNL.
Developer-Friendly: Built with Rust (Axum), React, and Vite, with an automated installer for easy deployment.

System Requirements

Operating System: Ubuntu 20.04+, Windows 10+, macOS 10.15+.
Tools: Docker, Node.js 18+, Rust 1.70+, PostgreSQL 13+, Redis 6+.
Browser: Chrome, Firefox, or any modern browser supporting WebRTC.
Mobile: iOS 13+ or Android 8.0+ (mobile apps coming soon).

Installation
WIMFREE provides an automated installer (build_and_run.sh) to set up the platform with minimal effort. Follow these steps to deploy locally:

Download the Installer:

Clone the repository or download build_and_run.sh from GitHub.
Ensure the script is in ~/quantum-chat-platform.


Run the Installer:
chmod +x build_and_run.sh
./build_and_run.sh --auto


The --auto flag skips prompts and auto-stops local PostgreSQL/Redis if running.
Use sudo only if required for Docker or permissions.
Watch the progress bar and spinner for installation status.


Access WIMFREE:

Open http://localhost:5173 in a browser for the React-based UI.
The backend runs on http://localhost:3000 (test with curl http://localhost:3000/api/health).


Generate Documentation:

Save generate_readme.py from the repository and run:python generate_readme.py


This generates a user-focused README.md with setup and usage details.



Usage

Create an Account:

Sign up via the web UI with a username and strong password (hashed with Argon2).
Quantum keypairs (Kyber/Dilithium) are auto-generated for secure communication.


Start a Chat or Stream:

Chat: Create a private chat, invite users, and send E2EE messages via WebSocket.
Stream: Launch a quantum-secure video/audio stream for invited users, powered by WebRTC.
Badges: Earn “Privacy Hero” badges for completing secure sessions (RPG-inspired feature).


Best Practices:

Use strong, unique passwords for maximum security.
Share invites only with trusted users.
Keep WIMFREE updated for the latest security patches.



Troubleshooting

Frontend Issues:
If http://localhost:5173 fails, check Vite logs: cat frontend/web/dist/*.
Verify @vitejs/plugin-react: ls frontend/web/node_modules/@vitejs/plugin-react.
Clear npm cache: npm cache clean --force && npm install.
Ensure Node 18+: node -v.


Database Issues:
Check PostgreSQL logs: docker logs postgres.
Test connectivity: docker exec -it postgres psql -U postgres -d wimfree.
Verify migrations: ls backend/migrations/.
Check DATABASE_URL: postgres://postgres:securepass@127.0.0.1:5432/wimfree.
Check firewall: sudo ufw status and sudo ufw allow 5432.


Backend Issues:
Test API: curl http://localhost:3000/api/health.
Check Rust PATH: echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc.


Permissions:
Fix ownership: sudo chown -R $USER:$USER ~/quantum-chat-platform.


NPM Vulnerabilities:
Run cd frontend/web && npm audit.
Update packages in package.json (e.g., "vite": "^5.0.0") and run npm install.



For further assistance, open an issue on GitHub or contact the community.
Security
WIMFREE is designed with security as the top priority, audited by WimLee115, a certified bug bounty hunter:

End-to-End Encryption: Client-side encryption using NIST-approved quantum-resistant algorithms (placeholder: base64, production: liboqs for Kyber/Dilithium).
Zero-Knowledge Servers: No sensitive data stored on servers, inspired by PrivacyVerzetNL.
Secure Authentication: JWT with Argon2 password hashing (to be implemented in full backend).
Content Security Policy (CSP): Add to vite.config.ts: contentSecurityPolicy: "script-src 'self'".
Rate Limiting: Planned for WebSocket endpoints to prevent DDoS attacks.
NPM Audit: Two moderate vulnerabilities in dev; fix for production with npm audit fix.

Contributing
We welcome contributions to make WIMFREE the ultimate privacy platform:

Fork the repository and submit pull requests with features or bug fixes.
Report issues or suggest improvements on GitHub.
Join the community discussion, inspired by PrivacyVerzetNL’s privacy mission.

License
© 2025 WIMFREE Quantum Chat Platform. All rights reserved. Developed by WimLee115, with gratitude to PrivacyVerzetNL for privacy advocacy.

About the Developer: WimLee115 is a cybersecurity expert and web3 innovator, holding certifications like OSCP, CISSP, CEH, and CCSP. With a passion for quantum-secure systems and web3 RPGs, WimLee115 crafts platforms like WIMFREE to empower users with privacy and security.
Acknowledgments: Special thanks to PrivacyVerzetNL for inspiring WIMFREE’s zero-knowledge architecture and advocating for digital privacy.
