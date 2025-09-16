# AI MCP Host App

This module contains a **skeleton privileged application** for Android Automotive OS that acts as an MCP host service.  The app is packaged as `AiMcpHost` and built from source when included in the platform build.  It is signed with the platform certificate and marked as `privileged`, which allows it to access internal AAOS APIs.

## Components

* **AndroidManifest.xml** – Declares the package `com.example.ai.mcp` and a single service `McpHostService`.  The service runs in the foreground and is not exported externally; you can modify this to expose a Binder interface if desired.
* **Android.bp** – A Soong build descriptor that declares `AiMcpHost` as an `android_app`.  It sets `sdk_version` to `system_current`, enables `platform_apis`, and marks the app as `privileged`.
* **src/com/example/ai/mcp/McpHostService.java** – A stub `Service` implementation.  It logs lifecycle events but does not yet implement any tool dispatch logic.  Extend this class to register tool providers, open sockets or binders, and communicate with your on‑device language model.

## Extending the host

To build a functional agent you should:

1. Implement a **tool registry** that maps tool names to handler objects.  Each handler should expose a JSON‑serialisable schema for inputs and outputs and execute the appropriate Automotive API calls.
2. Expose a **local IPC interface** (e.g. via Binder or a Unix domain socket) so that your AI orchestrator can call tools.  Binder is recommended for performance and security on Android.
3. Integrate an **on‑device LLM** (for example, Gemini Nano via AICore) to parse user queries, plan a sequence of tool invocations, and execute them.  Ensure you respect driver distraction rules and other AAOS UX restrictions when deciding whether to proceed automatically or request confirmation from the driver.
4. Update the product configuration (`PRODUCT_PACKAGES += AiMcpHost`) or use the `android_app_import` rule if you wish to include a prebuilt APK instead of building from source【769513936751118†L566-L579】.

This stub is deliberately minimal to simplify integration into the platform build.  Feel free to restructure it according to your own architectural preferences.
