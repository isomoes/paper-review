# Field Analysis and Reviewer Configuration

## Manuscript

**Title:** SHARANG: A Heterogeneous CPU–GPU Accelerated, Security-Hardened ML-KEM-768 Implementation for ARM–CUDA Platforms  
**Review round:** 1  
**Target venue:** The Journal of Supercomputing

## Classification

- **Primary field:** Applied cryptography and post-quantum cryptographic engineering.
- **Secondary fields:** Heterogeneous and embedded computing; ARM SIMD and CUDA acceleration; side-channel and fault countermeasures.
- **Research paradigm:** Design-science and systems-building research supported by benchmarking, functional validation, and arithmetic-bound arguments.
- **Methodology:** Artifact-centered implementation study combining scalar, NEON, and CUDA backends on NVIDIA Jetson Orin.
- **Maturity:** Advanced prototype manuscript, but not submission-ready because several central operation-equivalence, arithmetic, security, and evaluation claims require reconstruction.
- **Venue context:** The topic is provisionally relevant to The Journal of Supercomputing. No formal target-criteria binding manifest was supplied (`criteria_binding_unavailable`), so venue alignment is provisional.

## Reviewer configuration

1. **Journal-Fit Reviewer:** Secure-systems and computer-architecture editor assessing venue relevance, contribution positioning, novelty, and submission maturity.
2. **Methodology Reviewer:** Experimental systems researcher specializing in ARM/CUDA benchmarking, statistical reporting, controlled baselines, and reproducibility.
3. **Domain Reviewer:** ML-KEM/Kyber implementation-security specialist assessing FIPS 203 fidelity, NTT arithmetic, side channels, fault resistance, and constant-time behavior.
4. **Perspective Reviewer:** Heterogeneous embedded/HPC deployment specialist assessing CPU–GPU partitioning, unified-memory behavior, resource accounting, workload realism, energy, and operational impact.
5. **Devil's Advocate:** Fixed adversarial seat challenging the central security, novelty, and performance claims.

The five seats were role-separated and blind to peer outputs during report generation. This separation is not a claim of statistically independent errors.
