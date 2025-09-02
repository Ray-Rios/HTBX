// Rich Editor Hook for WordPress-style content editing
export const RichEditor = {
  mounted() {
    this.initializeEditor();
  },

  updated() {
    // Re-initialize if needed
  },

  initializeEditor() {
    const textarea = this.el;
    
    // Create toolbar
    const toolbar = this.createToolbar();
    textarea.parentNode.insertBefore(toolbar, textarea);
    
    // Add editor styling
    textarea.classList.add('rich-editor-textarea');
    
    // Add event listeners
    this.addEventListeners(textarea, toolbar);
  },

  createToolbar() {
    const toolbar = document.createElement('div');
    toolbar.className = 'rich-editor-toolbar';
    toolbar.innerHTML = `
      <div class="toolbar-group">
        <button type="button" data-command="bold" title="Bold">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M6 4h8a4 4 0 0 1 4 4 4 4 0 0 1-4 4H6z"></path>
            <path d="M6 12h9a4 4 0 0 1 4 4 4 4 0 0 1-4 4H6z"></path>
          </svg>
        </button>
        <button type="button" data-command="italic" title="Italic">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <line x1="19" y1="4" x2="10" y2="4"></line>
            <line x1="14" y1="20" x2="5" y2="20"></line>
            <line x1="15" y1="4" x2="9" y2="20"></line>
          </svg>
        </button>
        <button type="button" data-command="underline" title="Underline">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M6 3v7a6 6 0 0 0 6 6 6 6 0 0 0 6-6V3"></path>
            <line x1="4" y1="21" x2="20" y2="21"></line>
          </svg>
        </button>
      </div>
      
      <div class="toolbar-group">
        <button type="button" data-command="h1" title="Heading 1">H1</button>
        <button type="button" data-command="h2" title="Heading 2">H2</button>
        <button type="button" data-command="h3" title="Heading 3">H3</button>
      </div>
      
      <div class="toolbar-group">
        <button type="button" data-command="ul" title="Bullet List">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <line x1="8" y1="6" x2="21" y2="6"></line>
            <line x1="8" y1="12" x2="21" y2="12"></line>
            <line x1="8" y1="18" x2="21" y2="18"></line>
            <line x1="3" y1="6" x2="3.01" y2="6"></line>
            <line x1="3" y1="12" x2="3.01" y2="12"></line>
            <line x1="3" y1="18" x2="3.01" y2="18"></line>
          </svg>
        </button>
        <button type="button" data-command="ol" title="Numbered List">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <line x1="10" y1="6" x2="21" y2="6"></line>
            <line x1="10" y1="12" x2="21" y2="12"></line>
            <line x1="10" y1="18" x2="21" y2="18"></line>
            <path d="M4 6h1v4"></path>
            <path d="M4 10h2"></path>
            <path d="M6 18H4c0-1 2-2 2-3s-1-1.5-2-1"></path>
          </svg>
        </button>
        <button type="button" data-command="link" title="Insert Link">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"></path>
            <path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"></path>
          </svg>
        </button>
      </div>
      
      <div class="toolbar-group">
        <button type="button" data-command="image" title="Insert Image">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
            <circle cx="8.5" cy="8.5" r="1.5"></circle>
            <polyline points="21,15 16,10 5,21"></polyline>
          </svg>
        </button>
        <button type="button" data-command="code" title="Code Block">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <polyline points="16,18 22,12 16,6"></polyline>
            <polyline points="8,6 2,12 8,18"></polyline>
          </svg>
        </button>
      </div>
    `;
    
    return toolbar;
  },

  addEventListeners(textarea, toolbar) {
    // Toolbar button clicks
    toolbar.addEventListener('click', (e) => {
      if (e.target.closest('button')) {
        e.preventDefault();
        const button = e.target.closest('button');
        const command = button.dataset.command;
        this.executeCommand(command, textarea);
      }
    });

    // Keyboard shortcuts
    textarea.addEventListener('keydown', (e) => {
      if (e.ctrlKey || e.metaKey) {
        switch (e.key) {
          case 'b':
            e.preventDefault();
            this.executeCommand('bold', textarea);
            break;
          case 'i':
            e.preventDefault();
            this.executeCommand('italic', textarea);
            break;
          case 'u':
            e.preventDefault();
            this.executeCommand('underline', textarea);
            break;
          case 'k':
            e.preventDefault();
            this.executeCommand('link', textarea);
            break;
        }
      }
    });

    // Auto-resize textarea
    textarea.addEventListener('input', () => {
      this.autoResize(textarea);
    });

    // Initial resize
    this.autoResize(textarea);
  },

  executeCommand(command, textarea) {
    const start = textarea.selectionStart;
    const end = textarea.selectionEnd;
    const selectedText = textarea.value.substring(start, end);
    const beforeText = textarea.value.substring(0, start);
    const afterText = textarea.value.substring(end);

    let replacement = '';
    let cursorOffset = 0;

    switch (command) {
      case 'bold':
        replacement = `**${selectedText || 'bold text'}**`;
        cursorOffset = selectedText ? 0 : -2;
        break;
      
      case 'italic':
        replacement = `*${selectedText || 'italic text'}*`;
        cursorOffset = selectedText ? 0 : -1;
        break;
      
      case 'underline':
        replacement = `<u>${selectedText || 'underlined text'}</u>`;
        cursorOffset = selectedText ? 0 : -4;
        break;
      
      case 'h1':
        replacement = `# ${selectedText || 'Heading 1'}`;
        cursorOffset = selectedText ? 0 : 0;
        break;
      
      case 'h2':
        replacement = `## ${selectedText || 'Heading 2'}`;
        cursorOffset = selectedText ? 0 : 0;
        break;
      
      case 'h3':
        replacement = `### ${selectedText || 'Heading 3'}`;
        cursorOffset = selectedText ? 0 : 0;
        break;
      
      case 'ul':
        replacement = `- ${selectedText || 'List item'}`;
        cursorOffset = selectedText ? 0 : 0;
        break;
      
      case 'ol':
        replacement = `1. ${selectedText || 'List item'}`;
        cursorOffset = selectedText ? 0 : 0;
        break;
      
      case 'link':
        const url = prompt('Enter URL:');
        if (url) {
          replacement = `[${selectedText || 'link text'}](${url})`;
          cursorOffset = selectedText ? 0 : -3 - url.length;
        } else {
          return;
        }
        break;
      
      case 'image':
        const imageUrl = prompt('Enter image URL:');
        if (imageUrl) {
          const altText = selectedText || 'image';
          replacement = `![${altText}](${imageUrl})`;
          cursorOffset = 0;
        } else {
          return;
        }
        break;
      
      case 'code':
        if (selectedText.includes('\n')) {
          replacement = `\`\`\`\n${selectedText || 'code block'}\n\`\`\``;
        } else {
          replacement = `\`${selectedText || 'code'}\``;
        }
        cursorOffset = selectedText ? 0 : (selectedText.includes('\n') ? -4 : -1);
        break;
      
      default:
        return;
    }

    // Update textarea value
    textarea.value = beforeText + replacement + afterText;
    
    // Set cursor position
    const newCursorPos = start + replacement.length + cursorOffset;
    textarea.setSelectionRange(newCursorPos, newCursorPos);
    
    // Focus textarea
    textarea.focus();
    
    // Trigger input event for LiveView
    textarea.dispatchEvent(new Event('input', { bubbles: true }));
    
    // Auto-resize
    this.autoResize(textarea);
  },

  autoResize(textarea) {
    textarea.style.height = 'auto';
    textarea.style.height = Math.max(200, textarea.scrollHeight) + 'px';
  }
};

// Add CSS styles
const style = document.createElement('style');
style.textContent = `
  .rich-editor-toolbar {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    padding: 12px;
    background: #f8f9fa;
    border: 1px solid #d1d5db;
    border-bottom: none;
    border-radius: 6px 6px 0 0;
  }

  .toolbar-group {
    display: flex;
    gap: 4px;
  }

  .rich-editor-toolbar button {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    padding: 6px;
    background: white;
    border: 1px solid #d1d5db;
    border-radius: 4px;
    cursor: pointer;
    transition: all 0.2s;
    font-size: 12px;
    font-weight: 600;
    color: #374151;
  }

  .rich-editor-toolbar button:hover {
    background: #f3f4f6;
    border-color: #9ca3af;
  }

  .rich-editor-toolbar button:active {
    background: #e5e7eb;
    transform: translateY(1px);
  }

  .rich-editor-textarea {
    border-radius: 0 0 6px 6px !important;
    border-top: none !important;
    min-height: 200px;
    resize: vertical;
    font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
    font-size: 14px;
    line-height: 1.5;
  }

  .rich-editor-textarea:focus {
    outline: none;
    border-color: #3b82f6 !important;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1) !important;
  }
`;
document.head.appendChild(style);