/**
 * PWA FullCover — SillyTavern 扩展
 *
 * 作用:主屏幕 App(PWA / standalone 模式)下,聊天页与角色卡选择页全屏铺满,
 * 输入栏贴底。所有规则只挂在 body.PWA 下(该类由酒馆 script.js 原生添加,
 * 仅 standalone 显示模式存在),PC 浏览器与手机 Safari 标签页完全不受影响。
 * 不动背景系统;关闭开关后移除全部样式,酒馆回到原样。
 */
import { extension_settings } from '../../../extensions.js';

function saveSettings() {
    const ctx = globalThis.SillyTavern?.getContext?.();
    if (typeof ctx?.saveSettingsDebounced === 'function') {
        ctx.saveSettingsDebounced();
    }
}

(function () {
    const MODULE = 'pwa-fullcover';
    const STYLE_ID = 'pwa-fullcover-style';
    const DEBUG_ID = 'pwa-fullcover-debug';

    const CSS = `
/* ===== PWA FullCover ===== */
/* 1) 主栏宽度变量:所有 width:var(--sheldWidth) 的消费者(chat_width 设置)一律满宽 */
body.PWA { --sheldWidth: 100vw !important; --sheldWidth: 100dvw !important; }

/* 2) 顶栏满宽 */
body.PWA #top-bar,
body.PWA #top-settings-holder {
    width: 100vw !important;
    width: 100dvw !important;
    max-width: 100vw !important;
}

/* 3) 主列(聊天页)满宽 + 贴到屏幕底:
      压过 style.css 的 width:var(--sheldWidth)/left:calc 居中定位,
      以及 mobile-styles.css iOS 块的 height:calc(100dvh - 36px) 高度公式。 */
body.PWA #sheld {
    left: 0 !important;
    right: 0 !important;
    width: 100vw !important;
    width: 100dvw !important;
    min-width: 100vw !important;
    max-width: 100vw !important;
    top: var(--topBarBlockSize) !important;
    bottom: 0 !important;
    height: auto !important;
}

/* 4) 主列内各层满宽 */
body.PWA #main,
body.PWA #chat,
body.PWA #form_sheld,
body.PWA #send_form {
    width: 100% !important;
    max-width: 100vw !important;
    min-width: 0 !important;
}

/* 5) 输入栏贴底:mobile-styles.css 给 body.PWA #sheld 塞了
      padding-bottom: max(env(safe-area-inset-bottom), 15px),这里清零。 */
body.PWA #sheld { padding-bottom: 0 !important; }

/* 6) 角色卡/聊天卡片选择页(左右抽屉)满宽 */
body.PWA #right-nav-panel,
body.PWA #left-nav-panel {
    left: 0 !important;
    right: 0 !important;
    margin: 0 !important;
    width: 100vw !important;
    width: 100dvw !important;
    min-width: 100vw !important;
    max-width: 100vw !important;
}
body.PWA #rm_print_characters_block {
    width: 100% !important;
    max-width: 100% !important;
}

/* 7) 弹层兜底:不超屏宽 */
body.PWA #character_popup,
body.PWA #select_chat_popup,
body.PWA .drawer-content {
    max-width: 100vw !important;
    max-width: 100dvw !important;
}
`;

    function isEnabled() {
        const s = extension_settings[MODULE];
        return !s || s.enabled !== false; // 安装后默认开启
    }

    function apply() {
        let el = document.getElementById(STYLE_ID);
        if (isEnabled()) {
            if (!el) {
                el = document.createElement('style');
                el.id = STYLE_ID;
                el.textContent = CSS;
                document.head.appendChild(el);
            }
        } else if (el) {
            el.remove();
        }
    }

    /* 调试条:默认不显示,扩展面板里点按钮才出现;点红条本体关闭 */
    let debugTimer = null;

    function debugProbe() {
        const el = document.getElementById(DEBUG_ID);
        if (!el) return;
        const rect = (id) => {
            const e = document.getElementById(id);
            return e ? e.getBoundingClientRect() : null;
        };
        const w = (id) => {
            const r = rect(id);
            return r ? Math.round(r.width) : '-';
        };
        const fb = rect('form_sheld');
        const gap = fb ? Math.round(window.innerHeight - fb.bottom) : '-';
        const varVal = getComputedStyle(document.body).getPropertyValue('--sheldWidth').trim();
        el.textContent =
            `FullCover ${isEnabled() ? 'ON' : 'OFF'} ` +
            `W:${window.innerWidth} H:${window.innerHeight} ` +
            `top:${w('top-bar')} sheld:${w('sheld')} chat:${w('chat')} ` +
            `卡片页:${w('right-nav-panel')} 输入栏底距:${gap} ` +
            `var:${varVal} PWA类:${document.body.classList.contains('PWA')}`;
    }

    function toggleDebug() {
        const el = document.getElementById(DEBUG_ID);
        if (el) {
            el.remove();
            clearInterval(debugTimer);
            debugTimer = null;
            return;
        }
        const bar = document.createElement('div');
        bar.id = DEBUG_ID;
        bar.style.cssText = 'position:fixed;top:50px;left:4px;right:4px;background:#c00;color:#fff;'
            + 'font-size:13px;z-index:9999999;padding:5px 8px;border-radius:6px;'
            + 'font-family:monospace;word-break:break-all;cursor:pointer;';
        bar.title = '点击关闭';
        bar.addEventListener('click', () => {
            bar.remove();
            clearInterval(debugTimer);
            debugTimer = null;
        });
        document.body.appendChild(bar);
        debugProbe();
        debugTimer = setInterval(debugProbe, 2000);
    }

    jQuery(async () => {
        if (extension_settings[MODULE] === undefined) {
            extension_settings[MODULE] = { enabled: true };
            saveSettings();
        }
        apply();

        const html = `
        <div class="pwa-fullcover-settings">
            <label class="checkbox_label">
                <input id="pwa_fullcover_enabled" type="checkbox">
                <span>PWA FullCover:主屏幕App模式全屏铺满(仅手机PWA生效,PC不受影响)</span>
            </label>
            <div class="flex-container" style="margin-top:5px;gap:5px;">
                <div id="pwa_fullcover_debug_btn" class="menu_button" title="手机上若仍有边缝,打开后把红条数字报给开发者">显示调试信息</div>
            </div>
        </div>`;
        $('#extensions_settings').append(html);
        $('#pwa_fullcover_enabled')
            .prop('checked', isEnabled())
            .on('change', function () {
                extension_settings[MODULE].enabled = $(this).prop('checked');
                saveSettings();
                apply();
            });
        $('#pwa_fullcover_debug_btn').on('click', toggleDebug);
    });
})();
