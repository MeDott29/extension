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
