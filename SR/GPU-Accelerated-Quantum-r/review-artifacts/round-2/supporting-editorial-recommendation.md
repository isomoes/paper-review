# Editorial Re-Review Recommendation

**Manuscript:** *GPU-Accelerated Quantum-resistant Image Encryption for Social Media using Lightweight Cryptographic Stream Cipher*  
**Decision:** **Major Revision — acceptance not supportable in the present form**  
**Editorial contingency:** If the journal does not permit another complete implementation and experimental round, reject and invite a substantially rebuilt resubmission.

Dear Authors,

The revision addresses several reviewer topics by adding AES-256-CTR and ASCON-128a tables, security metrics, a threat-model discussion, deployment limitations, and a code link. These additions improve the manuscript's coverage. Nevertheless, verification identifies acceptance-blocking problems in the implementation specification and experimental evidence.

Most importantly, the manuscript claims Salsa20-256 while the detailed CPU and CUDA methods repeatedly specify Salsa20-128. The CUDA pseudocode reverses the standard nonce and counter state positions, specifies no operational nonce-uniqueness protocol, and computes the GPU image length as `width × height` despite claiming RGB validation. Successful encryption/decryption round trips cannot establish Salsa20 conformance because the same erroneous transformation can invert itself. Official known-answer tests and CPU/GPU byte-for-byte validation are required.

The advertised social-media construction is also unauthenticated and therefore cannot detect tampering, substitution, truncation, or replay under the manuscript's own untrusted-intermediary threat model. Acknowledging this as a limitation does not support claims of a secure deployable system. Either the work must be narrowed to a confidentiality-only kernel study, or a standardized authenticated construction must be implemented and benchmarked.

The central performance claims require a full rerun. The CPU results are explicitly for Salsa20-128 while the main GPU/security claims concern Salsa20-256; PCIe and application overheads are excluded; repeated-trial statistics are absent; occupancy, register-spilling, energy, and memory claims lack underlying measurements; and throughput and energy efficiency appear to use inconsistent payload denominators. The manuscript's own tables report lower ASCON-128a latency and higher throughput than Salsa20, contradicting the stated Salsa20 advantage.

The requested state-of-the-art, multi-dataset, statistical, architectural, and cryptographic evaluations therefore remain only partially addressed. Deferring NIST, chosen-/known-plaintext, ChaCha20, OpenCL/OpenMP, and broader dataset work does not satisfy comments that requested those evaluations in the present revision.

Before reconsideration, the authors should:

1. Correct and fully specify a conforming Salsa20-256 implementation, including state layout, RGB byte length, nonce lifecycle, and official test-vector validation.
2. Implement authenticated encryption or restrict all claims to confidentiality-only benchmarking.
3. Revalidate AES/ASCON baselines with equivalent functionality, including ASCON tag generation and verification.
4. Rerun CPU/GPU benchmarks with identical variants and payloads, reporting kernel-only and end-to-end measurements, repeated trials, uncertainty, and profiler evidence.
5. Reconcile every throughput, energy, memory, occupancy, and speedup calculation from released raw data.
6. Correct the quantum-security framing, comparative conclusions, threat model, algorithm description, English, figures, and point-by-point response.

The work may contain a useful implementation-study direction, but the current evidence does not establish the correctness, security, or comparative performance of the claimed system. A further major revision must involve cryptographic reimplementation and experimental reconstruction rather than prose changes alone.

Sincerely,  
**Editorial Re-Reviewer**
