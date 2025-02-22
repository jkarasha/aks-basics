What is `WebAssembly(Wasm)`? It is a binary instruction set architecture(ISA), like ARM, x86, MIPS, and RISC-V. This means programming languages can compile source code into `Wasm` binaries that will run on any sytem with a `Wasm runtime`.

`Wasm` apps execute inside a deny-by-default sandbox that distrusts the application, meaning access to everything is denied by default and must be explicitly granted. This is the opposite of containers, that start with everything open.

`WASI`, the WebAssembly System Interface, allows sandboxed Wasm apps to securely access external services as key-value stores, networks, host environment, etc.

Wasm is secure and portable. Build once run anywhere.

K8s delegates running containers to containerd. For container implementations, it uses a `shim + runc` combination to run and maintain containers. For `WebAssembly`, it uses a `shim + wasmtime` combination to run and maintain `WebAssembly` apps.

For Wasm applications, the containerd shim actually combines the shim code and the wasm runtime as a single application. The code that interfaces with containerd is [runwasi](https://github.com/containerd/runwasi), but each each can embed a specific Wasm runtime.

For example the `Spin` shim embeds the `runwasi` Rust library and the `Spin` runtime code. The `Slight` shim embeds `runwasi` and the `Slight` runtime. In each shim, the embedded Wasm runtime creates the Wasm host and executes the Wasm app, while `runwasi` keeps containerd in the loop.

containerd mandates that all shim binaries be named using the `containerd-shim-prefix` convention. The prefix specifies the name of the runtime and the version. For example, `containerd-shim-spin-v1`

[Hands-on Lab]
TODO: Complete the hands-on lab


