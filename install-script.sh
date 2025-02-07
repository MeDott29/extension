#!/bin/bash

# Exit on any error
set -e

# Print commands before executing
set -x

echo "🚀 Starting Chrome Extension Setup..."

# Create directory structure
echo "📁 Creating extension directory structure..."
mkdir -p extension/{src,dist,public}
cd extension

# Initialize npm and create package.json
echo "📦 Initializing npm project..."
npm init -y

# Update package.json with better defaults
node -e '
const fs = require("fs");
const package = JSON.parse(fs.readFileSync("package.json"));
package.name = "voice-assistant-extension";
package.description = "Voice-based Chrome extension using transformers.js";
package.scripts = {
  "build": "webpack --config webpack.config.js",
  "watch": "webpack --config webpack.config.js --watch",
  "dev": "webpack --config webpack.config.js --mode=development --watch",
  "prod": "webpack --config webpack.config.js --mode=production"
};
fs.writeFileSync("package.json", JSON.stringify(package, null, 2));
'

# Install dependencies
echo "📥 Installing project dependencies..."
npm install --save-dev \
  @types/chrome \
  typescript \
  webpack \
  webpack-cli \
  ts-loader \
  copy-webpack-plugin

# Install transformers
echo "🤖 Installing Transformers.js..."
npm install @xenova/transformers

# Create webpack.config.js
echo "🔧 Creating webpack configuration..."
cat > webpack.config.js << 'EOF'
const path = require('path');
const CopyPlugin = require('copy-webpack-plugin');

module.exports = {
  mode: 'development',
  devtool: 'source-map',
  entry: {
    background: './src/background.ts',
    popup: './src/popup.ts',
    content: './src/content.ts'
  },
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: '[name].js',
    clean: true
  },
  module: {
    rules: [
      {
        test: /\.ts$/,
        use: 'ts-loader',
        exclude: /node_modules/,
      },
    ],
  },
  resolve: {
    extensions: ['.ts', '.js'],
  },
  plugins: [
    new CopyPlugin({
      patterns: [
        { from: 'public' }
      ],
    }),
  ],
  optimization: {
    minimize: false
  }
};
EOF

# Create tsconfig.json
echo "📝 Creating TypeScript configuration..."
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "es2020",
    "module": "es2020",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "moduleResolution": "node",
    "typeRoots": ["./node_modules/@types"],
    "lib": ["es2020", "dom"],
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules"]
}
EOF

# Create manifest.json in public directory
echo "📄 Creating extension manifest..."
mkdir -p public
cat > public/manifest.json << 'EOF'
{
  "manifest_version": 3,
  "name": "Voice Assistant Extension",
  "version": "1.0.0",
  "description": "Voice-based Chrome extension using transformers.js",
  "permissions": [
    "sidePanel",
    "storage",
    "tabs",
    "activeTab"
  ],
  "background": {
    "service_worker": "background.js",
    "type": "module"
  },
  "action": {
    "default_popup": "popup.html"
  },
  "side_panel": {
    "default_path": "sidepanel.html"
  }
}
EOF

# Create popup.html
echo "🖥️ Creating popup HTML..."
cat > public/popup.html << 'EOF'
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>Voice Assistant</title>
    <style>
      body {
        width: 300px;
        padding: 16px;
        font-family: system-ui, -apple-system, sans-serif;
      }
      button {
        width: 100%;
        padding: 8px 16px;
        background: #4CAF50;
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-size: 14px;
      }
      button:hover {
        background: #45a049;
      }
      h2 {
        margin-top: 0;
        color: #333;
      }
    </style>
  </head>
  <body>
    <div id="app">
      <h2>Voice Assistant</h2>
      <button id="toggleSidePanel">Open Side Panel</button>
    </div>
    <script src="popup.js" type="module"></script>
  </body>
</html>
EOF

# Create sidepanel.html
echo "📋 Creating sidepanel HTML..."
cat > public/sidepanel.html << 'EOF'
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>Voice Assistant Panel</title>
    <style>
      body {
        padding: 20px;
        font-family: system-ui, -apple-system, sans-serif;
        color: #333;
      }
      button {
        padding: 8px 16px;
        background: #4CAF50;
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-size: 14px;
      }
      button:hover {
        background: #45a049;
      }
      #transcript, #response {
        margin-top: 20px;
        padding: 10px;
        background: #f5f5f5;
        border-radius: 4px;
        min-height: 50px;
      }
      .listening {
        background: #ff4444 !important;
      }
      .listening:hover {
        background: #cc0000 !important;
      }
    </style>
  </head>
  <body>
    <div id="app">
      <h2>Voice Assistant</h2>
      <button id="startVoice">Start Voice Input</button>
      <div id="transcript"></div>
      <div id="response"></div>
    </div>
    <script src="content.js" type="module"></script>
  </body>
</html>
EOF

# Create TypeScript source files
echo "📝 Creating TypeScript source files..."
mkdir -p src

# Create background.ts
cat > src/background.ts << 'EOF'
chrome.runtime.onInstalled.addListener(() => {
  console.log('Voice Assistant Extension installed');
});

chrome.action.onClicked.addListener((tab) => {
  if (tab.id) {
    chrome.sidePanel.open({ windowId: tab.windowId });
  }
});

export {};
EOF

# Create popup.ts (Fixed version)
cat > src/popup.ts << 'EOF'
document.getElementById('toggleSidePanel')?.addEventListener('click', async () => {
  // Get the current window first
  const currentWindow = await chrome.windows.getCurrent();
  if (currentWindow.id) {
    chrome.sidePanel.open({ windowId: currentWindow.id });
  }
});

export {};
EOF

# Create content.ts
cat > src/content.ts << 'EOF'
import { pipeline } from '@xenova/transformers';

class VoiceAssistant {
  private isListening: boolean = false;
  private mediaRecorder: MediaRecorder | null = null;
  private audioChunks: Blob[] = [];
  private startButton: HTMLButtonElement | null;

  constructor() {
    this.startButton = document.getElementById('startVoice') as HTMLButtonElement;
    this.initializeListeners();
  }

  private initializeListeners() {
    if (this.startButton) {
      this.startButton.addEventListener('click', () => this.toggleVoiceInput());
    }
  }

  private async toggleVoiceInput() {
    if (!this.isListening) {
      await this.startListening();
    } else {
      this.stopListening();
    }
  }

  private async startListening() {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      this.mediaRecorder = new MediaRecorder(stream);
      this.audioChunks = [];

      this.mediaRecorder.ondataavailable = (event) => {
        this.audioChunks.push(event.data);
      };

      this.mediaRecorder.onstop = async () => {
        await this.processAudio();
      };

      this.mediaRecorder.start();
      this.isListening = true;
      
      if (this.startButton) {
        this.startButton.textContent = 'Stop Listening';
        this.startButton.classList.add('listening');
      }

      this.updateTranscript('Listening...');
    } catch (error) {
      console.error('Error accessing microphone:', error);
      this.updateTranscript('Error: Could not access microphone');
    }
  }

  private stopListening() {
    if (this.mediaRecorder && this.isListening) {
      this.mediaRecorder.stop();
      this.isListening = false;
      
      if (this.startButton) {
        this.startButton.textContent = 'Start Voice Input';
        this.startButton.classList.remove('listening');
      }
    }
  }

  private async processAudio() {
    this.updateTranscript('Processing audio...');
    // TODO: Implement ASR using transformers.js
    // For now, just showing a placeholder response
    this.updateResponse('Audio processing not yet implemented');
  }

  private updateTranscript(text: string) {
    const transcript = document.getElementById('transcript');
    if (transcript) {
      transcript.textContent = text;
    }
  }

  private updateResponse(text: string) {
    const response = document.getElementById('response');
    if (response) {
      response.textContent = text;
    }
  }
}

// Initialize the voice assistant when the page loads
window.addEventListener('load', () => {
  new VoiceAssistant();
});

export {};
EOF

# Initial build
echo "🔨 Building extension..."
npm run build

echo "✅ Installation complete!"
echo "To load the extension:"
echo "1. Open Chrome and go to chrome://extensions/"
echo "2. Enable 'Developer mode'"
echo "3. Click 'Load unpacked' and select the 'dist' directory"

# Print status of required tools
echo -e "\n🔍 System Status:"
echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"
echo "TypeScript version: $(npx tsc --version)"
echo "Webpack version: $(npx webpack --version)"
