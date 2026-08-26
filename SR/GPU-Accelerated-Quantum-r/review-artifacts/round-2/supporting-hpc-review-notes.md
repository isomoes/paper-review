# HPC/CUDA Methodology Re-review Notes

## Scope

Read-only review of `revision 30.txt` against the author-response document `Review.txt`. This note focuses on GPU benchmark design, CPU/GPU comparability, timing scope and PCIe exclusion, throughput/speedup consistency, occupancy evidence, energy and memory measurement, statistical replication, datasets and scalability, state-of-the-art comparisons, reproducibility, and whether author responses match manuscript evidence. No manuscript was modified.

## Recommendation

**Major Revision; not acceptable as currently evidenced.** If the authors cannot rerun the experiments with matched workloads and documented measurement procedures, **reject and resubmit** is warranted.

---

## Exact Anchored Findings

### 1. CPU and GPU workloads may process different byte counts

**Severity: Critical**

- CPU payload: `L = W × H × C` — `revision 30.txt:412-415`.
- GPU payload: `data_len = width × height` — `revision 30.txt:542-545`, `643-649`.

For RGB input, the GPU pseudocode omits the channel factor and may process only one-third of the decoded bytes. This invalidates CPU/GPU comparability, RGB validation, throughput, and correctness unless the actual code is shown to differ from the manuscript.

### 2. Cipher variants are mismatched

**Severity: Critical**

- CPU section is Salsa20-128: `revision 30.txt:359-360`, `409-410`, `446-462`.
- GPU section is Salsa20-128: `revision 30.txt:514-515`, `639-650`.
- Headline results concern Salsa20-256: `revision 30.txt:20-29`, `802-814`, `840-852`.

The unsupported statement that Salsa20-128 and Salsa20-256 have the same computation time appears at `revision 30.txt:784-785`. A documented 128-bit CPU result cannot serve as a 256-bit GPU baseline without an equivalent implementation and validation.

### 3. Speedup arithmetic is correct, but methodological comparability is not

**Severity: Critical**

Input values:

- CPU: 91.337 ms and 232.03 ms — `revision 30.txt:762-768`.
- GPU: 0.344 ms and 0.168 ms — `revision 30.txt:802-807`, `840-845`.

Arithmetic:

- Tesla T4 system: `91.337 / 0.344 = 265.51×`.
- RTX A4000 system: `232.03 / 0.168 = 1381.13×`.

Thus, the advertised 265×/1381× values at `revision 30.txt:1184-1192` are arithmetically reproducible, but they are not valid comparative speedups because cipher variant, processed bytes, timing implementation, and CPU optimization are not shown to be equivalent.

Table 11's AES `26.86×` and ASCON `71.31×` cannot be verified because no corresponding CPU AES or ASCON timings are reported: `revision 30.txt:1086-1094`.

### 4. Kernel-only timing is presented too broadly

**Severity: Critical**

- CUDA events measure kernel execution: `revision 30.txt:605-608`, `786-789`.
- H2D/D2H transfers occur outside the timed kernel: `revision 30.txt:559-561`, `655-666`, `669-674`.
- PCIe exclusion is disclosed only with the headline speedup in the conclusion: `revision 30.txt:1184-1192`.
- Nsight timelines identify stages but provide no numerical transfer costs: `revision 30.txt:883-905`.

Kernel-only results are legitimate microbenchmarks, but they must not be presented as full implementation or application acceleration. Both kernel-only and end-to-end measurements are required.

The pseudocode also does not document `cudaEventSynchronize`, warm-up launches, repeated measurements, or synchronization before reading elapsed time: `revision 30.txt:661-672`.

### 5. CPU baseline is insufficiently controlled

**Severity: Critical**

The i9-14900K is reported approximately 2.5× slower than an unspecified 2 GHz Xeon:

- Xeon encryption: 91.337 ms.
- i9 encryption: 232.03 ms.
- Anchor: `revision 30.txt:762-768`.

No exact Xeon SKU, compiler, optimization flags, ISA target, CPU affinity, turbo state, thread count, or SIMD use is reported. The baseline is serial C rather than an optimized AVX2/AVX-512 or established cryptographic-library implementation. The result therefore measures speedup over an uncharacterized program, not over a competitive CPU implementation.

### 6. Occupancy explanation is unsupported and architecturally questionable

**Severity: Critical**

The manuscript claims that `8192 blocks × 8 threads` maximizes occupancy without register spilling:

- `revision 30.txt:992-1000`.
- Repeated mechanistic explanation: `revision 30.txt:1197-1204`.

No supporting values are supplied for:

- achieved or theoretical occupancy,
- registers per thread,
- local-memory spill load/store transactions,
- active/resident warps or blocks,
- eligible warps per cycle,
- warp execution efficiency,
- memory-latency stalls,
- L1/L2 cache hit rates.

Eight threads consume a partially populated 32-lane warp, leaving 24 lanes inactive. Resident-block limits can prevent such a configuration from maximizing active warps. A latency minimum cannot be relabelled an occupancy maximum without Nsight Compute evidence.

Figures 13–15 are timelines, not occupancy analyses: `revision 30.txt:883-905`.

### 7. Throughput and energy efficiency use inconsistent payload sizes

**Severity: Critical numerical inconsistency**

Table 11 is at `revision 30.txt:1086-1094`.

The throughput values use approximately **1.34 MB**:

- Salsa20: `1.34 / 0.000168 = 7,976 MB/s`, consistent with the reported 7,980 MB/s.
- AES: `1.34 / 0.001340 = 1,000 MB/s`.
- ASCON: `1.34 / 0.000144 = 9,306 MB/s`, consistent with 9,310 MB/s.

The energy-efficiency values use approximately **4.19 MB**:

- Salsa20: `780.38 MB/J × 0.00537 J = 4.1906 MB`.
- AES: `176 MB/J × 0.02383 J = 4.1941 MB`.
- ASCON: `841.02 MB/J × 0.00498 J = 4.1883 MB`.

If the payload is 1.34 MB, energy efficiencies should be approximately:

| Cipher | Reported | Recomputed from 1.34 MB |
|---|---:|---:|
| Salsa20 | 780.38 MB/J | 249.5 MB/J |
| AES-256-CTR | 176 MB/J | 56.2 MB/J |
| ASCON-128a | 841.02 MB/J | 269.1 MB/J |

Conversely, using 4.19 MB would make the throughput values approximately 3.13× higher.

The fixed Salsa launch covers exactly 4 MiB:

- 65,536 threads stated at `revision 30.txt:790-794`.
- 64 bytes per thread stated at `revision 30.txt:563-566`.
- `65,536 × 64 = 4,194,304 bytes`.

The manuscript likely confuses compressed file size, megapixels, and decoded RGB bytes. Every table must state the precise decoded byte count processed.

### 8. Energy and power measurements are not reproducible

**Severity: Critical**

Energy and efficiency appear only as final values: `revision 30.txt:1086-1093`.

No measurement tool, telemetry sampling rate, batching procedure, integration interval, idle-power subtraction, transfer inclusion, GPU clock state, or uncertainty is provided. Board-power telemetry generally cannot resolve a single 0.168 ms kernel reliably without repeated batching and integration.

The author response claims that power consumption was reported at `Review.txt:175-198`, but Table 11 reports energy and energy efficiency, not directly measured power.

### 9. Memory evidence is undefined

**Severity: Major**

Identical `6.29 MB` memory usage is reported for all three ciphers: `revision 30.txt:1091-1094`.

No definition distinguishes allocated, peak, incremental, host, device, or profiler-observed memory. The documented Salsa allocations consist of one image buffer plus small key and nonce allocations: `revision 30.txt:549-561`, `652-655`.

The response also claims memory throughput is reported at `Review.txt:215-227`, but the manuscript reports application encryption/decryption throughput and memory capacity, not GPU DRAM throughput.

### 10. Statistical replication is absent

**Severity: Critical**

Tables 2–7 present single values: `revision 30.txt:802-873`, `917-946`.

Missing information includes:

- number of trials,
- number of warm-up runs,
- mean and median,
- standard deviation or confidence interval,
- min/max or percentiles,
- outlier policy,
- CPU/GPU clock controls,
- background-load controls.

Consequently, small differences between launch configurations cannot establish a statistically supported optimum.

### 11. Dataset scalability is not demonstrated

**Severity: Major**

- Main benchmark: one 1.34 "Mb" airport image — `revision 30.txt:762-768`.
- Lenna: only a figure and 512 KB statement — `revision 30.txt:911-915`.
- No Lenna-specific timing, throughput, or scaling result is identified.
- Tables 6–7 are AES and ASCON configuration tables, not labelled Lenna scaling results: `revision 30.txt:917-946`.

The response's claim of multi-resolution/RGB evaluation at `Review.txt:367-385` overstates the evidence, especially because the GPU `data_len` omits the channel factor.

A valid scalability evaluation should sweep decoded payload size, resolution, channel count, and aspect ratio, reporting both kernel-only and end-to-end throughput.

### 12. State-of-the-art comparison remains inadequate

**Severity: Major**

The original request required recent comparable GPU/lightweight/stream-cipher methods: `Review.txt:3-16`.

Only in-house AES-CTR and ASCON implementations were added. No measured ChaCha20 GPU, optimized CPU Salsa20, OpenMP/OpenCL, recent GPU image-encryption implementation, or established CUDA cryptographic-library baseline is provided.

The claim of superiority to Khalid et al. at `revision 30.txt:1102-1109` conflicts with:

- Khalid et al.: 43.44 GB/s — `revision 30.txt:194-197`.
- Current work: 7.98 GB/s — `revision 30.txt:1088-1090`.

The present reported throughput is approximately 5.4× lower. Cross-generation hardware differences further preclude an unqualified efficiency claim.

### 13. Additional consistency problems

**Severity: Major**

- The manuscript says AES-256-CTR and ASCON-128a also meet a 128-bit post-quantum requirement: `revision 30.txt:1099-1100`. A 128-bit ASCON key provides only approximately 64-bit generic key-search security under Grover's algorithm.
- One response describes all three algorithms as lightweight: `Review.txt:3-12`, while another calls AES the conventional non-lightweight reference: `Review.txt:175-180`.
- Tables 8–10 report plaintext NPCR/UACI as zero and key-sensitivity NPCR/UACI near 99.61%/33.5%: `revision 30.txt:1004-1042`, `1062-1081`. These are distinct experiments and require explicit labels. The response note at `Review.txt:397-400` does not resolve the tabular ambiguity.
- The `O(N/P)` complexity statement at `revision 30.txt:758-760` ignores finite SM resources, launch overhead, occupancy, memory traffic, and hardware saturation. It is not a defensible measured scalability model.

### 14. Reproducibility remains insufficient

**Severity: Major**

Partial hardware description appears at `revision 30.txt:1184-1188`.

Missing information includes:

- exact Xeon model and CPU core use,
- operating system,
- CUDA toolkit, driver, and Nsight versions,
- GPU compute capability,
- CPU and CUDA compiler versions and complete flags,
- CPU affinity, turbo, and SIMD settings,
- GPU clocks, persistence mode, and power settings,
- exact image dimensions, sources, hashes, and decoded byte counts,
- key, nonce, and correctness test vectors,
- benchmark commands,
- raw repetition data,
- scripts used to produce each table,
- immutable repository commit or release tag.

A mutable GitHub URL alone is insufficient: `revision 30.txt:1227-1229`.

---

## Per-comment Verification

### Reviewer 1

| Comment | Verification status | Severity | Anchored finding |
|---|---|---:|---|
| R1.1 State-of-the-art comparison, `Review.txt:3-16` | **Not addressed** | Major | Only self-implemented AES/ASCON baselines were added. Khalid superiority is contradicted by `revision 30.txt:194-197`, `1088-1090`, `1102-1109`. |
| R1.2 Security metrics, `Review.txt:17-35` | **Partially addressed** | Major | Metrics appear at `revision 30.txt:1004-1047`, `1062-1081`, but NIST/CPA/KPA are absent and NPCR labels are ambiguous. |
| R1.3 Performance evaluation, `Review.txt:36-47` | **Partially addressed; not validated** | Critical | Times and throughput are present, but byte counts, energy, memory, speedup comparability, and scalability are inconsistent or undocumented. |
| R1.4 Figures, `Review.txt:48-58` | **Not verifiable from text export** | Minor | Response only asserts 400 dpi and reference checking; it does not substantiate consistent styling, enlarged labels, or redesigned charts. |
| R1.5 Datasets and replication, `Review.txt:59-67` | **Not addressed** | Critical | One qualitative additional image is shown; there are no repeated experiments or statistical summaries. |
| R1.6 Discussion, `Review.txt:68-78` | **Partially addressed** | Major | Deployment discussion exists at `revision 30.txt:1115-1182`, but the CUDA mechanism remains unsupported by profiler evidence. |

### Reviewer 2

| Comment | Verification status | Severity | Anchored finding |
|---|---|---:|---|
| R2.1 Quantum-resistance claim, `Review.txt:80-93` | **Partially addressed** | Major | Grover discussion was added at `revision 30.txt:221-228`; the ASCON claim at `revision 30.txt:1099-1100` is inconsistent with its 128-bit key. |
| R2.2 Novel optimization, `Review.txt:94-109` | **Not verified** | Critical | No occupancy or register evidence is reported; the prior-throughput comparison is adverse. |
| R2.3 Expanded security evaluation, `Review.txt:110-120` | **Partially addressed** | Major | Tables were added, but the abstract at `revision 30.txt:20-32` does not reflect the breadth claimed in the response. |
| R2.4 Throughput, kernel scope, PCIe, `Review.txt:121-129` | **Partially addressed** | Critical | Kernel scope is disclosed, but there is no end-to-end result or numerical PCIe measurement. |
| R2.5 Threat/deployment/compression, `Review.txt:130-174` | **Partially verified** | Major | Sections exist at `revision 30.txt:1115-1182`; the JPEG-quality-75 claim at `1129-1135` lacks a protocol or quantitative result. |
| R2.6 Lightweight classification, `Review.txt:175-199` | **Not adequately verified** | Critical | Energy and memory lack methods, direct power is absent, and rounds per byte alone is insufficient. |
| R2.7 ChaCha20/AES-GCM/ASCON, `Review.txt:200-201` | **Partially addressed** | Major | AES-CTR and ASCON are present; ChaCha20 and AES-GCM are not measured. |
| Minor CUDA strategy and 8192×8, `Review.txt:203-210` | **Not verified** | Critical | An explanation is asserted without occupancy, register, cache, or latency counters. |
| Minor throughput, `Review.txt:210-211` | **Present but inconsistent** | Critical | Table 11 exists, but its throughput payload conflicts with its energy-efficiency payload. |

### Reviewer 3

| Comment | Verification status | Severity | Anchored finding |
|---|---|---:|---|
| R3.1 Novelty versus prior CUDA Salsa20, `Review.txt:215-248` | **Not verified** | Major | The claim depends on unsupported occupancy evidence and a contradicted Khalid comparison. |
| R3.2 Quantum discussion, `Review.txt:249-280` | **Partially addressed** | Major | Theory was added, but the claim requires qualification and consistent key-security treatment. |
| R3.3 Image-security metrics, `Review.txt:281-301` | **Partially addressed** | Major | Several metrics were added; NIST randomness and CPA/KPA remain future work. |
| R3.4 OpenMP/OpenCL/ChaCha/AES comparisons, `Review.txt:302-326` | **Mostly not addressed** | Major | Only AES-CUDA was measured; expected similarity is not experimental evidence. |
| R3.5 Architecture evidence, `Review.txt:327-338` | **Not addressed evidentially** | Critical | No occupancy, latency, spilling, register, or cache measurements are supplied. |
| R3.6 Requested references, `Review.txt:339-366` | **Verified** | Minor | Requested literature appears at `revision 30.txt:202-216`, `1340-1346`. |
| R3.7 Resolutions/RGB/datasets, `Review.txt:367-385` | **Contradicted** | Critical | No quantitative scaling is shown; GPU length omits channels at `revision 30.txt:542-545`, `643-649`. |
| R3.8 Figure size, `Review.txt:386-388` | **Not addressed/not verifiable from text** | Minor | The response justifies retaining the figures rather than implementing the request. |
| R3.9 Language, `Review.txt:389-391` | **Not satisfied** | Minor | Numerous grammatical and terminology errors remain, although this is outside the primary HPC assessment. |
| R3.10 Variable consistency, `Review.txt:392-394` | **Contradicted** | Critical | `W×H×C` versus `W×H`, Salsa20-128 versus Salsa20-256, and MB/Mb/decoded-byte ambiguity remain. |

---

## Minimum Evidence Required for a Defensible Revision

1. Verify bit-for-bit identical CPU/GPU ciphertext using official Salsa20 test vectors.
2. Process the exact same decoded byte count on CPU and GPU, including all channels.
3. Benchmark Salsa20-256 on both platforms and label any Salsa20-128 results separately.
4. Add optimized CPU baselines with full compiler flags and at least one established SIMD/library implementation.
5. Report kernel-only and end-to-end latency, including separate H2D and D2H measurements.
6. Use warm-ups and sufficient repetitions; report mean, median, standard deviation, confidence intervals, and run counts.
7. Lock or record CPU/GPU clocks and document CUDA event placement and synchronization.
8. Report Nsight Compute occupancy, registers, spills, active warps, warp efficiency, memory stalls, and cache metrics for each launch configuration.
9. Batch kernels for energy measurement and document sampling, integration, idle-baseline subtraction, and uncertainty.
10. Reconcile compressed file size, pixel count, decoded bytes, and launch coverage in every throughput and energy calculation.
11. Evaluate multiple decoded sizes and both grayscale and RGB inputs, including scaling beyond one fixed total-thread count.
12. Add contemporary GPU ChaCha20/Salsa20 and optimized CPU comparisons, or narrow the state-of-the-art claims.
13. Release a tagged code revision, benchmark scripts, raw measurements, image hashes, and commands.

## Final Disposition

Until these requirements are satisfied, the reported **265×/1381× speedups, occupancy optimum, energy efficiency, scalability, and superior-efficiency claims should not be treated as validated findings**.
