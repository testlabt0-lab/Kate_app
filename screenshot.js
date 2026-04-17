const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({
    viewport: { width: 414, height: 896 } // iPhone XR/11 size for mobile view
  });

  // Navigate to the local flutter web app
  await page.goto('http://127.0.0.1:3000', { waitUntil: 'networkidle' });

  // Wait a bit for flutter to fully render its canvas
  await page.waitForTimeout(10000); // 10 seconds to make sure it renders

  await page.screenshot({ path: 'app_screenshot.png' });
  await browser.close();
})();
