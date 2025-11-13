// 从JSON配置文件加载菜单项
async function loadMenuItems() {
    try {
        const response = await fetch('homeMenuItems.json');
        const data = await response.json();
        renderCategories(data.categories);
    } catch (error) {
        console.error('加载菜单项失败:', error);
        showEmptyState();
    }
}

// 渲染分类和链接
function renderCategories(categories) {
    const menuGrid = document.getElementById('menuGrid');

    if (!categories || categories.length === 0) {
        showEmptyState();
        return;
    }

    menuGrid.innerHTML = categories.map(category => `
        <div class="category">
            <div class="category-title">${escapeHtml(category.title)}</div>
            <div class="links">
                ${category.links.map(link => `
                    <a href="${escapeHtml(link.url)}" class="link-item">
                        <span class="link-icon">${link.icon}</span>
                        <span class="link-name">${escapeHtml(link.name)}</span>
                        <span class="link-desc">${escapeHtml(link.desc)}</span>
                    </a>
                `).join('')}
            </div>
        </div>
    `).join('');
}

// 显示空状态
function showEmptyState() {
    const menuGrid = document.getElementById('menuGrid');
    menuGrid.innerHTML = `
        <div class="empty-state">
            <h2>暂无工具项</h2>
            <p>右键点击菜单栏图标，选择"设置"来添加工具</p>
        </div>
    `;
}

// HTML转义
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// 搜索功能
function handleSearch(event) {
    if (event.key === 'Enter') {
        performSearch();
    }
}

function performSearch() {
    const input = document.getElementById('searchInput').value.trim();
    if (!input) return;

    // 判断是否是URL
    if (input.match(/^https?:\/\//i) || input.includes('.')) {
        const url = input.match(/^https?:\/\//i) ? input : 'https://' + input;
        window.location.href = url;
    } else {
        // 默认使用必应搜索
        window.location.href = 'https://www.bing.com/search?q=' + encodeURIComponent(input);
    }
}

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', function() {
    loadMenuItems();
});
