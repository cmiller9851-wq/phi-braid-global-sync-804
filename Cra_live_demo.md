## 1) One-page slide deck (text + speaker notes)

## Title — Tri‑Demo: Algorithm, Governance, Kernel
- Objective: Demonstrate three small, extensible programs that illustrate modeling (Python), decentralized simulation (JS), and a minimal command-line kernel (C++).
- Duration: 8–12 minutes

Slide 1 — Introduction (30s)
- Slide text:
  - Tri‑Demo: Algorithm, Governance, Kernel
  - Objective: Quick, practical examples covering modeling, simulation, and low‑level interfaces.
- Speaker notes:
  - “Today I’ll show three short demos that highlight different engineering concepts and how they can be extended.”

Slide 2 — Love Equation (1 min)
- Slide text:
  - Purpose: Simple implementation of Sternberg’s Triangular Theory of Love.
  - Key idea: average of intimacy, commitment, passion → single metric.
  - Run: python3 love.py
- Speaker notes:
  - “This Python script computes a normalized score from three inputs. It’s compact and easy to extend with weighting, validation, or a web form for input.”

Slide 3 — Libertas (2 min)
- Slide text:
  - Purpose: Minimal decentralized-governance simulation (citizens, proposals, votes).
  - Key idea: OO classes, state mutation, easily extended to quorum, weighted votes, or UI.
  - Run: node libertas_demo.js
- Speaker notes:
  - “Libertas shows the core domain model. Add proposal lifecycle, authentication, analytics, or replace in-memory state with a simple database or blockchain simulator.”

Slide 4 — CRA Kernel (2–3 min)
- Slide text:
  - Purpose: Tiny C++ kernel-like REPL demonstrating boot, command parsing, IO.
  - Key idea: control loop, blocking IO; easy to extend with commands, history, help.
  - Run: g++ -o cra cra.cpp && ./cra
- Speaker notes:
  - “This demo is not an OS kernel but demonstrates the small building blocks: boot message, command loop, basic parsing. Good base for teaching or prototyping CLI features.”

Slide 5 — Integration & Next Steps (1–2 min)
- Slide text:
  - Integration options: Dockerize each demo + simple web UI to trigger runs and stream stdout; or run locally in terminal tabs.
  - Next steps picked: slide deck, Dockerfiles + web UI scaffold, 8–12 min recorded demo script.
- Speaker notes:
  - “We can deliver a polished demo in 1–2 days: Dockerfiles for each, a small Node UI to launch demos and show output, plus the recorded walkthrough.”

Slide 6 — Ask & Timeline (30s)
- Slide text:
  - Ask: Approval to produce deliverables in chosen format (live demo, recorded video, or slide deck + artifacts).
  - ETA: 1–2 days for full integration (Docker + UI + script)
- Speaker notes:
  - “If this looks good, I’ll produce the deliverables and can adapt the recorded demo to your preferred narration style.”

---

## 2) Dockerfiles and minimal web UI scaffold

File tree (root of project)
- README.md
- demos/
  - love/
    - love.py
    - Dockerfile
  - libertas/
    - libertas_demo.js
    - package.json
    - Dockerfile
  - cra/
    - cra.cpp
    - Dockerfile
- web-ui/
  - package.json
  - server.js
  - public/
    - index.html
    - app.js
    - style.css
  - Dockerfile
- docker-compose.yml

Key file contents (copy-paste ready)

demos/love/love.py
```python
def love_equation(intimacy, commitment, passion):
    return (intimacy + commitment + passion) / 3

if __name__ == "__main__":
    # Example usage
    intimacy = 8
    commitment = 9
    passion = 7
    love_score = love_equation(intimacy, commitment, passion)
    print("Love Score:", love_score)
```

demos/love/Dockerfile
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY love.py .
CMD ["python", "love.py"]
```

demos/libertas/libertas_demo.js
```javascript
class Citizen {
    constructor(name) { this.name = name; this.votes = 0; }
}
class Libertas {
    constructor() { this.citizens = []; this.proposals = []; }
    addCitizen(citizen) { this.citizens.push(citizen); }
    proposeLaw(proposal) { this.proposals.push({text: proposal, votes: 0}); }
    vote(citizenIndex, proposalIndex) {
        const c = this.citizens[citizenIndex];
        if (!c) return console.log("Invalid citizen");
        const p = this.proposals[proposalIndex];
        if (!p) return console.log("Invalid proposal");
        c.votes++;
        p.votes++;
        console.log(`${c.name} voted for proposal ${proposalIndex} ('${p.text}')`);
    }
}

// Example run
const libertas = new Libertas();
libertas.addCitizen(new Citizen("Alice"));
libertas.addCitizen(new Citizen("Bob"));
libertas.proposeLaw("Free Pizza");
libertas.vote(0, 0);
console.log("Proposals:", libertas.proposals);
console.log("Citizens:", libertas.citizens.map(c => ({name:c.name, votes:c.votes})));
```

demos/libertas/package.json
```json
{"name":"libertas-demo","version":"1.0.0","main":"libertas_demo.js","license":"MIT"}
```

demos/libertas/Dockerfile
```dockerfile
FROM node:20-slim
WORKDIR /app
COPY package.json .
COPY libertas_demo.js .
CMD ["node", "libertas_demo.js"]
```

demos/cra/cra.cpp
```cpp
#include <iostream>
#include <string>

void kernelMain() {
    std::cout << "CRA Kernel booted successfully!" << std::endl;
    while (true) {
        std::cout << "cra_kernel> ";
        std::string command;
        if (!(std::cin >> command)) break;
        if (command == "exit") break;
        std::cout << "Unknown command: " << command << std::endl;
    }
}

int main() {
    kernelMain();
    return 0;
}
```

demos/cra/Dockerfile
```dockerfile
FROM gcc:12
WORKDIR /app
COPY cra.cpp .
RUN g++ -o cra cra.cpp
CMD ["./cra"]
```

web-ui/package.json
```json
{"name":"tri-demo-ui","version":"1.0.0","main":"server.js","dependencies":{"express":"^4.18.2","socket.io":"^4.7.2"}}
```

web-ui/server.js
```javascript
const express = require('express');
const { spawn } = require('child_process');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server);

app.use(express.static('public'));

io.on('connection', socket => {
  socket.on('run-demo', demo => {
    let cmd;
    if (demo === 'love') cmd = spawn('docker', ['run', '--rm', 'tri_demo_love']);
    if (demo === 'libertas') cmd = spawn('docker', ['run', '--rm', 'tri_demo_libertas']);
    if (demo === 'cra') cmd = spawn('docker', ['run', '--rm', '-i', 'tri_demo_cra']);

    if (!cmd) return socket.emit('output', 'Unknown demo');
    cmd.stdout.on('data', d => socket.emit('output', d.toString()));
    cmd.stderr.on('data', d => socket.emit('output', d.toString()));
    cmd.on('close', code => socket.emit('output', `\nProcess exited with ${code}`));
    // For CRA interactive demo, we do not send stdin in this scaffold.
  });
});

server.listen(3000, () => console.log('UI running on http://localhost:3000'));
```

web-ui/public/index.html (minimal)
```html
<!doctype html>
<html>
<head><meta charset="utf-8"><title>Tri‑Demo UI</title></head>
<body>
  <h1>Tri‑Demo</h1>
  <button onclick="run('love')">Run Love</button>
  <button onclick="run('libertas')">Run Libertas</button>
  <button onclick="run('cra')">Run CRA</button>
  <pre id="out"></pre>
  <script src="/socket.io/socket.io.js"></script>
  <script src="app.js"></script>
</body>
</html>
```

web-ui/public/app.js
```javascript
const socket = io();
const out = document.getElementById('out');
socket.on('output', d => out.textContent += d);
function run(name) {
  out.textContent = '';
  socket.emit('run-demo', name);
}
```

web-ui/Dockerfile
```dockerfile
FROM node:20-slim
WORKDIR /app
COPY package.json .
COPY server.js .
COPY public ./public
RUN npm install
EXPOSE 3000
CMD ["node", "server.js"]
```

docker-compose.yml
```yaml
version: '3.8'
services:
  ui:
    build: ./web-ui
    ports: ["3000:3000"]
    depends_on: []
  love:
    build: ./demos/love
    image: tri_demo_love
  libertas:
    build: ./demos/libertas
    image: tri_demo_libertas
  cra:
    build: ./demos/cra
    image: tri_demo_cra
```

README.md (brief run instructions)
- Build and run:
  - docker-compose build
  - docker-compose up --detach
  - Open http://localhost:3000 and click a demo
- Or run individual demos:
  - docker build -t tri_demo_love ./demos/love && docker run --rm tri_demo_love
  - docker build -t tri_demo_libertas ./demos/libertas && docker run --rm tri_demo_libertas
  - docker build -t tri_demo_cra ./demos/cra && docker run --rm -i tri_demo_cra

Notes:
- CRA demo is interactive; web scaffold runs it non-interactively. For a live interactive demo, run the cra container in a terminal tab.
- These files are minimal; add logging, health checks, and security in production.

---

## 3) Recorded demo script (8–12 minutes) — exact commands, timing, expected outputs

Total target: ~10 minutes

0:00–0:15 — Opening (15s)
- Script: “Hello — I’ll demonstrate three small programs: Love Equation (Python), Libertas (JS), and CRA Kernel (C++). Total ~10 minutes.”
- No command.

0:15–1:00 — Setup note (45s)
- Script: “I’m running locally with Docker already built. Commands I’ll use are shown on screen.”
- Command (optional to show): docker-compose build
- Expected: build logs (skip in live demo for time).

1:00–2:15 — Love Equation demo (1:15)
- Command: docker run --rm tri_demo_love
- Expected output:
  - Love Score: 8.0
- Script while running: “This simple Python function averages three scores. It’s trivial to add weights or input validation.”

2:15–4:15 — Libertas demo (2:00)
- Command: docker run --rm tri_demo_libertas
- Expected output (approx):
  - Alice voted for proposal 0 ('Free Pizza')
  - Proposals: [{ text: 'Free Pizza', votes: 1 }]
  - Citizens: [{ name: 'Alice', votes: 1 }, { name: 'Bob', votes: 0 }]
- Script: “This JS class model shows citizens, proposals, and voting. You can extend it with quorum rules, weighted votes, or persistent storage.”

4:15–7:30 — CRA Kernel demo (3:15)
- Preferred live interactive method: open a terminal tab and run container.
- Command (interactive): docker run --rm -it tri_demo_cra
- Expected output:
  - CRA Kernel booted successfully!
  - cra_kernel>
- Interaction (timed):
  - 4:30: type: help  → Expected: Unknown command: help
  - 4:45: type: foo   → Expected: Unknown command: foo
  - 5:00: type: exit  → kernel exits
- Script: “This is a tiny REPL-like kernel loop. It demonstrates boot messages, prompt, and parsing; a next step is adding a help command and command history.”

7:30–9:00 — Integration notes & extension ideas (1:30)
- Script: “Integration options: run these in Docker and surface outputs to a small web UI (as scaffolded), or run locally in terminal tabs for interactive parts. Next steps: add input forms for Love Equation, proposal lifecycle and analytics for Libertas, and command set for CRA.”

9:00–10:00 — Wrap-up & ask (1:00)
- Script: “That concludes the demo. ETA to deliver the slide, Dockerfiles, UI scaffold, and a recorded video: 1–2 days. Which format would you like for the final deliverable—live demo, recorded video, or both?”

Notes for recording
- Record terminal screen and spoken narration.
- Keep each demo short and show one extension idea live if time allows.
- Use the web UI to demonstrate non-interactive runs; open a terminal for the CRA interactive demo.
