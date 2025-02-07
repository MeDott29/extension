# Voice Assistant Chrome Extension

This project is a Chrome extension that uses voice input to interact with users, leveraging transformers.js for AI functionality. The extension is built using TypeScript, Webpack, and other modern tools.

## Setup Instructions

1. Ensure you have Node.js (>=14) and npm installed on your system.

2. Clone the repository and navigate into it:
   ```bash
   git clone <repository_url>
   cd <repository_directory>
   ```

3. Run the install script to set up the project:
   ```bash
   ./install-script.sh
   ```

4. The install script will:
   - Create the necessary directory structure under the `extension/` directory.
   - Initialize an npm project and update package.json with required defaults.
   - Install all necessary dependencies (including TypeScript, Webpack, and transformers.js).
   - Create configuration files like `webpack.config.js` and `tsconfig.json`.
   - Build the extension by running `npm run build`.

5. During development:
   - For a one-time build, run:
     ```bash
     npm run build
     ```
   - For continuous development with auto-reload on changes, run:
     ```bash
     npm run watch
     ```

6. Load the extension in Chrome:
   - Open Chrome and navigate to `chrome://extensions/`.
   - Enable "Developer mode".
   - Click on "Load unpacked" and select the `extension/dist` directory.

## File Structure

- README.md: This file.
- install-script.sh: Bash script to set up and initialize the extension.
- extension/: Contains the Chrome extension source, configuration, and build files.
  - src/: TypeScript source files.
  - dist/: Build output.
  - public/: Static assets including HTML files for the popup and side panel.
  - .gitignore: Git ignore rules for the extension.

## License

Specify your project's license here.
