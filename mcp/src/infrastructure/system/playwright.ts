/**
 * @layer Infrastructure
 * @role Playwright browser automation wrapper with security restrictions
 * @deps playwright
 * @exports executePlaywrightTask
 * @invariants
 *   - Browser instance properly cleaned up after execution
 *   - Screenshots saved to specified path
 *   - URL access restricted to whitelist domains
 * @notes Provides browser automation capabilities using Playwright
 */

import { chromium, Browser, Page } from "playwright";

/**
 * Default allowed domains for browser navigation
 * @note Override via PLAYWRIGHT_ALLOWED_DOMAINS env var (comma-separated)
 */
const DEFAULT_ALLOWED_DOMAINS = [
  "github.com",
  "www.github.com",
  "docs.github.com",
  "stackoverflow.com",
  "www.stackoverflow.com",
  "developer.mozilla.org",
  "www.npmjs.com",
  "npmjs.com"
];

/**
 * Get allowed domains from environment or use defaults
 */
function getAllowedDomains(): string[] {
  const envDomains = process.env.PLAYWRIGHT_ALLOWED_DOMAINS;
  if (envDomains) {
    return envDomains.split(",").map(d => d.trim()).filter(Boolean);
  }
  return DEFAULT_ALLOWED_DOMAINS;
}

/**
 * Validate if URL is allowed based on domain whitelist
 * @throws Error if domain is not in whitelist
 */
function validateUrl(url: string, allowedDomains: string[]): void {
  try {
    const parsedUrl = new URL(url);
    const hostname = parsedUrl.hostname.toLowerCase();

    const isAllowed = allowedDomains.some(domain => {
      const normalizedDomain = domain.toLowerCase();
      return hostname === normalizedDomain || hostname.endsWith(`.${normalizedDomain}`);
    });

    if (!isAllowed) {
      throw new Error(
        `Security Error: Domain "${hostname}" is not in the allowed list. ` +
        `Allowed domains: ${allowedDomains.join(", ")}`
      );
    }
  } catch (error) {
    if (error instanceof Error && error.message.startsWith("Security Error:")) {
      throw error;
    }
    throw new Error(`Invalid URL format: ${url}`);
  }
}

/**
 * @type PlaywrightTaskResult
 * @role Result of Playwright task execution
 */
export interface PlaywrightTaskResult {
  success: boolean;
  message: string;
  screenshotPath?: string;
  pageContent?: string;
  error?: string;
}

/**
 * executePlaywrightTask
 * @role Execute browser automation task using natural language instructions
 * @input task: natural language instruction
 * @input url: optional starting URL
 * @input headless: whether to run browser in headless mode
 * @input screenshot: whether to take screenshot after task
 * @input screenshotPath: path to save screenshot
 * @output PlaywrightTaskResult with execution details
 * @cleanup Always closes browser instance
 */
export async function executePlaywrightTask(
  task: string,
  url?: string,
  headless: boolean = true,
  screenshot: boolean = false,
  screenshotPath: string = "./screenshot.png"
): Promise<PlaywrightTaskResult> {
  let browser: Browser | null = null;
  let page: Page | null = null;

  try {
    const allowedDomains = getAllowedDomains();

    // Guard: validate URL if provided
    if (url) {
      validateUrl(url, allowedDomains);
    }

    browser = await chromium.launch({
      headless,
      args: ['--disable-blink-features=AutomationControlled']
    });
    page = await browser.newPage({
      userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      viewport: { width: 1920, height: 1080 }
    });

    // Remove automation indicators
    await page.addInitScript(() => {
      Object.defineProperty(navigator, 'webdriver', {
        get: () => false
      });
    });

    // Guard: navigate to URL if provided (already validated above)
    if (url) {
      await page.goto(url, { waitUntil: "load", timeout: 60000 });
    }

    // Execute task based on natural language instructions
    const result = await executeTaskInstructions(page, task);

    // Take screenshot if requested
    let capturedScreenshotPath: string | undefined;
    if (screenshot) {
      await page.screenshot({ path: screenshotPath, fullPage: true });
      capturedScreenshotPath = screenshotPath;
    }

    // Get page content for context
    const pageContent = await page.content();

    return {
      success: true,
      message: result,
      screenshotPath: capturedScreenshotPath,
      pageContent: pageContent.substring(0, 5000) // Limit content size
    };
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error);
    return {
      success: false,
      message: "Task execution failed",
      error: errorMessage
    };
  } finally {
    // Cleanup: always close browser
    if (page) await page.close();
    if (browser) await browser.close();
  }
}

/**
 * executeTaskInstructions
 * @role Parse and execute task instructions on page
 * @input page: Playwright Page instance
 * @input task: natural language task description
 * @output execution result message
 * @note Validates URLs before navigation for security
 */
async function executeTaskInstructions(
  page: Page,
  task: string
): Promise<string> {
  const taskLower = task.toLowerCase();
  const actions: string[] = [];
  const allowedDomains = getAllowedDomains();

  // Pattern matching for common tasks
  if (taskLower.includes("screenshot") || taskLower.includes("撮影")) {
    actions.push("Screenshot will be taken");
  }

  if (taskLower.includes("click") || taskLower.includes("クリック")) {
    // Extract selector or text to click
    const clickMatch = task.match(/click\s+(?:on\s+)?["']?([^"']+)["']?/i);
    if (clickMatch) {
      const selector = clickMatch[1];
      await page.click(selector);
      actions.push(`Clicked on: ${selector}`);
    }
  }

  if (taskLower.includes("type") || taskLower.includes("入力")) {
    // Extract selector and text to type
    const typeMatch = task.match(/type\s+["']([^"']+)["']\s+(?:in|into)\s+["']?([^"']+)["']?/i);
    if (typeMatch) {
      const text = typeMatch[1];
      const selector = typeMatch[2];
      await page.fill(selector, text);
      actions.push(`Typed "${text}" into: ${selector}`);
    }
  }

  if (taskLower.includes("navigate") || taskLower.includes("go to") || taskLower.includes("移動")) {
    const urlMatch = task.match(/(?:navigate|go)\s+(?:to\s+)?(?:https?:\/\/)?([^\s]+)/i);
    if (urlMatch) {
      const targetUrl = urlMatch[1].startsWith("http") ? urlMatch[1] : `https://${urlMatch[1]}`;

      // Security: validate URL before navigation
      validateUrl(targetUrl, allowedDomains);

      await page.goto(targetUrl, { waitUntil: "load", timeout: 60000 });
      actions.push(`Navigated to: ${targetUrl}`);
    }
  }

  if (taskLower.includes("wait") || taskLower.includes("待機")) {
    const waitMatch = task.match(/wait\s+(?:for\s+)?(\d+)\s*(?:ms|seconds?)?/i);
    if (waitMatch) {
      const duration = parseInt(waitMatch[1], 10);
      await page.waitForTimeout(duration);
      actions.push(`Waited for ${duration}ms`);
    }
  }

  // Default: just wait for page to be ready
  if (actions.length === 0) {
    await page.waitForLoadState("load");
    actions.push("Page loaded and ready");
  }

  return actions.join(", ");
}
