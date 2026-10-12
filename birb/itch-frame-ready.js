(() => {
    'use strict';

    const PROTOCOL_VERSION = 1;
    const ITCH_WRAPPER_ORIGIN = 'https://html-classic.itch.zone';
    if (
        window.parent === window ||
        new URLSearchParams(window.location.search).get('source') !== 'itch'
    ) return;

    let referrerOrigin = null;
    if (document.referrer) {
        try {
            referrerOrigin = new URL(document.referrer).origin;
        } catch {
            referrerOrigin = null;
        }
    }

    const isOpaqueItchApp = !referrerOrigin || referrerOrigin === 'null';
    const isLocalWrapper = Boolean(
        referrerOrigin?.match(/^http:\/\/(?:localhost|127\.0\.0\.1|\[::1\]):\d+$/),
    );
    if (!isOpaqueItchApp && referrerOrigin !== ITCH_WRAPPER_ORIGIN && !isLocalWrapper) return;

    window.parent.postMessage({
        type: 'birb:frame-ready',
        version: PROTOCOL_VERSION,
    }, isOpaqueItchApp ? '*' : referrerOrigin);
})();
