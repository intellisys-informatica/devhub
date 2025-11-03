/**
 * Main Application Module
 * Orchestrates the entire application
 */

import { MarkdownRenderer } from './markdown-renderer.js';
import { Navigation } from './navigation.js';

class App {
    constructor() {
        this.renderer = new MarkdownRenderer();
        this.navigation = new Navigation();
        this.elements = {
            content: document.getElementById('content'),
            searchBtn: document.getElementById('searchBtn'),
            searchContainer: document.getElementById('searchContainer'),
            searchInput: document.getElementById('searchInput'),
            searchResults: document.getElementById('searchResults'),
            themeToggle: document.getElementById('themeToggle')
        };

        this.init();
    }

    /**
     * Initialize application
     */
    async init() {
        try {
            // Load manifest and render menu
            await this.navigation.loadManifest();
            this.navigation.renderMenu();

            // Setup event listeners
            this.setupEventListeners();
            this.setupTheme();
            this.setupSearch();

            // Setup hash navigation
            this.navigation.setupHashNavigation();

            console.log('✅ DevHub initialized successfully');
        } catch (error) {
            console.error('Failed to initialize app:', error);
            this.showError('Falha ao inicializar a aplicação. Por favor, recarregue a página.');
        }
    }

    /**
     * Setup event listeners
     */
    setupEventListeners() {
        // Listen for navigation events
        window.addEventListener('navigate', async (e) => {
            const { doc } = e.detail;
            await this.loadDocument(doc);
        });

        // Listen for navigate home event
        window.addEventListener('navigate-home', () => {
            this.showWelcome();
        });

        // Setup copy buttons after content loads
        this.elements.content.addEventListener('click', (e) => {
            if (e.target.classList.contains('copy-btn')) {
                this.handleCopyCode(e.target);
            }
            
            // Handle internal markdown links
            if (e.target.tagName === 'A' && e.target.href) {
                const href = e.target.getAttribute('href');
                if (href && href.endsWith('.md')) {
                    e.preventDefault();
                    this.handleMarkdownLink(href);
                }
            }
        });
    }

    /**
     * Load and display a document
     * @param {Object} doc - Document object
     */
    async loadDocument(doc) {
        try {
            // Show loading state
            this.showLoading();

            // Load markdown file
            const filePath = `docs/${doc.file}`;
            const html = await this.renderer.loadAndRender(filePath);

            // Display content
            this.elements.content.innerHTML = html;

            // Extract and render TOC
            const toc = this.renderer.extractTOC(html);
            this.navigation.renderTOC(toc);

            // Add edit link
            this.addEditLink(doc.file);

            // Scroll to top
            window.scrollTo({ top: 0, behavior: 'smooth' });

        } catch (error) {
            console.error('Error loading document:', error);
            this.showError(`Falha ao carregar o documento: ${doc.title}`);
        }
    }

    /**
     * Show welcome page
     */
    showWelcome() {
        this.elements.content.innerHTML = `
            <div class="welcome">
                <h1>🤖 Bem-vindo ao Intellisys DevHub</h1>
                <p class="subtitle">Guia completo para desenvolvimento colaborativo com IA e Git</p>

                <div class="features">
                    <div class="feature-card">
                        <span class="feature-icon">🛠️</span>
                        <h3>Ambiente de Desenvolvimento</h3>
                        <p>Setup completo do ambiente, ferramentas e configurações</p>
                    </div>
                    <div class="feature-card">
                        <span class="feature-icon">📝</span>
                        <h3>Padrões de Código</h3>
                        <p>Convenções, boas práticas e guias de estilo</p>
                    </div>
                    <div class="feature-card">
                        <span class="feature-icon">🔀</span>
                        <h3>Git & Commits</h3>
                        <p>Regras de commits, branches e changelogs</p>
                    </div>
                    <div class="feature-card">
                        <span class="feature-icon">⚙️</span>
                        <h3>Configurações</h3>
                        <p>Templates de configuração para VSCode e mais</p>
                    </div>
                </div>

                <div class="cta">
                    <p>👈 Selecione um tópico no menu lateral para começar</p>
                </div>
            </div>
        `;
    }

    /**
     * Show loading state
     */
    showLoading() {
        this.elements.content.innerHTML = '<div class="loading"></div>';
    }

    /**
     * Show error message
     * @param {string} message - Error message
     */
    showError(message) {
        this.elements.content.innerHTML = `
            <div class="error">
                <h2>❌ Erro</h2>
                <p>${message}</p>
            </div>
        `;
    }

    /**
     * Add edit link to document
     * @param {string} filePath - Document file path
     */
    addEditLink(filePath) {
        const githubUrl = `https://github.com/intellisys-informatica/devhub/edit/main/docs/${filePath}`;
        const editLink = document.createElement('a');
        editLink.href = githubUrl;
        editLink.target = '_blank';
        editLink.className = 'edit-link';
        editLink.innerHTML = '✏️ Editar esta página no GitHub';

        this.elements.content.appendChild(editLink);
    }

    /**
     * Handle internal markdown links
     * @param {string} href - Link href attribute
     */
    handleMarkdownLink(href) {
        // Get current document path to resolve relative links
        const currentHash = window.location.hash.slice(1);
        let basePath = '';
        
        if (currentHash) {
            const currentDoc = this.navigation.getAllDocs().find(d => d.id === currentHash);
            if (currentDoc && currentDoc.file) {
                // Get the directory of the current file
                const lastSlash = currentDoc.file.lastIndexOf('/');
                if (lastSlash > -1) {
                    basePath = currentDoc.file.substring(0, lastSlash + 1);
                }
            }
        }
        
        // Resolve the full path
        const fullPath = basePath + href;
        
        // Find the document in manifest by file path
        const targetDoc = this.navigation.getAllDocs().find(d => {
            return d.file === fullPath || d.file.endsWith(href);
        });
        
        if (targetDoc) {
            this.navigation.navigateToDoc(targetDoc.id);
        } else {
            console.warn('Document not found for link:', href, 'Full path:', fullPath);
            // Fallback: try to load the file directly
            this.loadDocumentByPath(fullPath);
        }
    }

    /**
     * Load document by file path (fallback for links not in manifest)
     * @param {string} filePath - Document file path
     */
    async loadDocumentByPath(filePath) {
        try {
            this.showLoading();
            
            const html = await this.renderer.loadAndRender(`docs/${filePath}`);
            this.elements.content.innerHTML = html;
            
            const toc = this.renderer.extractTOC(html);
            this.navigation.renderTOC(toc);
            
            this.addEditLink(filePath);
            window.scrollTo({ top: 0, behavior: 'smooth' });
            
        } catch (error) {
            console.error('Error loading document by path:', error);
            this.showError(`Falha ao carregar o documento: ${filePath}`);
        }
    }

    /**
     * Handle code copy button click
     * @param {HTMLElement} button - Copy button element
     */
    async handleCopyCode(button) {
        const code = button.dataset.code;

        try {
            await navigator.clipboard.writeText(code);

            // Update button state
            const originalText = button.textContent;
            button.textContent = '✓ Copiado!';
            button.classList.add('copied');

            setTimeout(() => {
                button.textContent = originalText;
                button.classList.remove('copied');
            }, 2000);

        } catch (error) {
            console.error('Failed to copy code:', error);
            button.textContent = '✗ Erro';

            setTimeout(() => {
                button.textContent = 'Copiar';
            }, 2000);
        }
    }

    /**
     * Setup theme toggle
     */
    setupTheme() {
        // Check if user has a saved preference
        const savedTheme = localStorage.getItem('theme');

        let theme;
        if (savedTheme) {
            // User has explicitly chosen a theme
            theme = savedTheme;
        } else {
            // Detect system preference
            const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
            theme = prefersDark ? 'dark' : 'light';
        }

        document.documentElement.setAttribute('data-theme', theme);
        this.updateThemeIcon(theme);

        // Listen for system theme changes (only if user hasn't set a preference)
        window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
            if (!localStorage.getItem('theme')) {
                const newTheme = e.matches ? 'dark' : 'light';
                document.documentElement.setAttribute('data-theme', newTheme);
                this.updateThemeIcon(newTheme);
            }
        });

        // Setup toggle button
        this.elements.themeToggle.addEventListener('click', () => {
            const currentTheme = document.documentElement.getAttribute('data-theme');
            const newTheme = currentTheme === 'dark' ? 'light' : 'dark';

            document.documentElement.setAttribute('data-theme', newTheme);
            localStorage.setItem('theme', newTheme);
            this.updateThemeIcon(newTheme);
        });
    }

    /**
     * Update theme toggle icon
     * @param {string} theme - Current theme
     */
    updateThemeIcon(theme) {
        this.elements.themeToggle.textContent = theme === 'dark' ? '☀️' : '🌙';
    }

    /**
     * Setup search functionality
     */
    setupSearch() {
        // Toggle search container
        this.elements.searchBtn.addEventListener('click', () => {
            this.elements.searchContainer.classList.toggle('active');
            if (this.elements.searchContainer.classList.contains('active')) {
                this.elements.searchInput.focus();
            } else {
                this.elements.searchInput.value = '';
                this.elements.searchResults.innerHTML = '';
            }
        });

        // Search input
        let searchTimeout;
        this.elements.searchInput.addEventListener('input', (e) => {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(() => {
                this.performSearch(e.target.value);
            }, 300);
        });

        // Close search on escape
        this.elements.searchInput.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                this.elements.searchContainer.classList.remove('active');
                this.elements.searchInput.value = '';
                this.elements.searchResults.innerHTML = '';
            }
        });
    }

    /**
     * Perform search
     * @param {string} query - Search query
     */
    async performSearch(query) {
        if (!query || query.length < 2) {
            this.elements.searchResults.innerHTML = '';
            return;
        }

        const allDocs = this.navigation.getAllDocs();
        const results = [];

        // Search in document titles and content
        for (const doc of allDocs) {
            const titleMatch = doc.title.toLowerCase().includes(query.toLowerCase());
            const descMatch = doc.description?.toLowerCase().includes(query.toLowerCase());

            if (titleMatch || descMatch) {
                results.push({
                    doc,
                    score: titleMatch ? 10 : 5,
                    highlight: titleMatch ? 'title' : 'description'
                });
            }
        }

        // Sort by score
        results.sort((a, b) => b.score - a.score);

        // Display results
        this.displaySearchResults(results, query);
    }

    /**
     * Display search results
     * @param {Array} results - Search results
     * @param {string} query - Search query
     */
    displaySearchResults(results, query) {
        if (results.length === 0) {
            this.elements.searchResults.innerHTML = '<p style="padding: 1rem; color: var(--text-secondary);">Nenhum resultado encontrado</p>';
            return;
        }

        const resultsHTML = results.map(result => {
            const { doc } = result;
            return `
                <div class="search-result-item" data-doc-id="${doc.id}">
                    <div style="font-weight: 600; color: var(--text-primary);">
                        ${doc.category.icon} ${doc.title}
                    </div>
                    <div style="font-size: 0.875rem; color: var(--text-secondary); margin-top: 0.25rem;">
                        ${doc.category.title}
                    </div>
                </div>
            `;
        }).join('');

        this.elements.searchResults.innerHTML = resultsHTML;

        // Setup click handlers
        this.elements.searchResults.querySelectorAll('.search-result-item').forEach(item => {
            item.addEventListener('click', () => {
                const docId = item.dataset.docId;
                this.navigation.navigateToDoc(docId);
                this.elements.searchContainer.classList.remove('active');
                this.elements.searchInput.value = '';
                this.elements.searchResults.innerHTML = '';
            });
        });
    }
}

// Initialize app when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => new App());
} else {
    new App();
}

export default App;
