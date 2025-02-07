document.getElementById('toggleSidePanel')?.addEventListener('click', async () => {
  // Get the current window first
  const currentWindow = await chrome.windows.getCurrent();
  if (currentWindow.id) {
    chrome.sidePanel.open({ windowId: currentWindow.id });
  }
});

export {};
