chrome.runtime.onInstalled.addListener(() => {
  console.log('Voice Assistant Extension installed');
});

chrome.action.onClicked.addListener((tab) => {
  if (tab.id) {
    chrome.sidePanel.open({ windowId: tab.windowId });
  }
});

export {};
