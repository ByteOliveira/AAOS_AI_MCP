# AAOS AI MCP OS

This repository provides a starter blueprint for building a custom **Android Automotive OS (AAOS)** image that includes an on‑device AI agent powered by an **MCP (Model‑Controller Protocol) host**.  The goal is to enable voice‑driven or natural‑language commands (for example, *“Navigate to the latest address sent by Maria while playing Joe’s playlist”*) without relying on an external phone or PC.

The project consists of two major parts:

1. **`build_aaos_ai.sh`** – a bash script that downloads the Android source tree for AAOS, applies a local manifest, integrates the AI host app into the build, and compiles images for a supported target device.  The script follows the official Android build process, using the [`repo` tool to initialize and sync the manifest【886674710982981†L90-L116】]; it then sources the build environment (`build/envsetup.sh`), selects a target (`lunch`), and invokes the `make` command to produce the `boot.img`, `system.img` and `vendor.img` files【886674710982981†L90-L116】.
2. **`ai_mcp_host/`** – a skeleton privileged app that acts as an MCP host service.  When built into the system image, it exposes MCP tools over a local interface.  The app is deliberately minimal; you can extend it with real tool providers and orchestrator logic.

## Prerequisites

To build AAOS you need a Linux machine (Ubuntu 20.04 or later) with at least 16 GB of RAM and a fast CPU.  You must also install the standard AOSP build dependencies (`git`, `curl`, `flex`, `bison`, `zip`, etc.).  The [KINTO tech blog’s beginner‑friendly guide](https://blog.kinto-technologies.com/posts/2024-12-05-android-automotive-en/) has a good checklist of these requirements【886674710982981†L90-L116】.

## Building a custom AAOS image

The `build_aaos_ai.sh` script automates the following steps:

1. **Install and initialise the `repo` tool** – The script fetches the `repo` launcher and initialises a shallow clone of the AAOS manifest (`android-13.0.0_r35` by default).  The manifest defines all Git projects that make up the OS【886674710982981†L90-L116】.
2. **Apply a local manifest** – A local manifest can add or override projects in the main manifest.  This project uses a local manifest to pull in the AI host app and any other custom modules.  See `.repo/local_manifests/local_manifest.xml` for details.
3. **Sync the source tree** – `repo sync` downloads all repositories referenced by the manifest.
4. **Copy the AI host app** – The script places the `ai_mcp_host` directory into `packages/apps/` in the source tree, making it part of the build.
5. **Configure Soong** – A Soong build descriptor (`Android.bp`) declares the app as an `android_app` with `privileged: true` and `platform_apis: true` so it can access system APIs.  If you choose to distribute a prebuilt APK instead of source code, you can use the `android_app_import` rule to include the APK in the system image【769513936751118†L566-L579】.
6. **Build the images** – The script sources `build/envsetup.sh`, selects a lunch target (for example `aosp_car_x86_64-userdebug`), and runs `make bootimage systemimage vendorimage -j$(nproc)`【886674710982981†L90-L116】.

After the build finishes, the generated images are in the `out/target/product/<target>/` directory.  You can flash them to your AAOS hardware (e.g. Raspberry Pi or an x86 emulator) following the standard fastboot or SD‑card instructions.

## Extending the AI host

The `ai_mcp_host` module contains a stub `McpHostService`.  To build a functional AI agent you should:

* Implement tool providers that wrap Android Automotive APIs (navigation, media playback, climate control, vehicle properties, etc.).  See `tools.kt` for an example provider skeleton.
* Register each tool with your MCP host and expose them over a local IPC (e.g. a Unix domain socket or Binder interface).
* Integrate an on‑device LLM orchestrator (for example, Gemini Nano via AICore) to interpret user intents and call your tools.  The orchestrator should observe car UX restrictions and request permission when reading sensitive data.

This repository is a starting point; you are free to modify the manifest, build script and app to suit your own hardware target and AI architecture.
