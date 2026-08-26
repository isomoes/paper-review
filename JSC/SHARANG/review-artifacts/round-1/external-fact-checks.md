# Supplemental External Fact Checks

These checks supplement the role-separated manuscript review. They are not a substitute for a systematic literature review.

## 1. Target-journal scope

*The Journal of Supercomputing* describes itself as “An International Journal of High-Performance Computer Design, Analysis, and Use.” Its published scope encompasses supercomputing technology, architectures and systems, algorithms and programs, performance measures and methods, and applications. SHARANG is therefore topically plausible for the journal, especially if framed and evaluated as a heterogeneous-computing systems contribution. Because no formal target-criteria binding manifest was supplied, this remains a provisional fit assessment.

Source: [The Journal of Supercomputing — Springer Nature](https://link.springer.com/journal/11227/articles?page=90)

## 2. Incorrect TLS standardization statement

The Introduction states that “the IETF has standardized ML-KEM for TLS 1.3 via RFC9794” (extracted manuscript lines 55–59). RFC 9794 is *Terminology for Post-Quantum Traditional Hybrid Schemes*; it does not itself standardize ML-KEM TLS 1.3 groups. The later RFC 10024 defines hybrid TLS 1.3 groups including X25519MLKEM768.

Minimum correction: replace the RFC 9794 statement with an accurate description and citation to the applicable TLS specification, while retaining RFC 9794 only for terminology where relevant.

Sources: [RFC 9794](https://www.rfc-editor.org/info/rfc9794/); [RFC 10024](https://www.rfc-editor.org/info/rfc10024/)

## 3. GPU ML-KEM prior art must be updated

The manuscript’s GPU-prior-art paragraph cites Reference [13], but that reference is an FPGA NewHope paper, not a GPU ML-KEM study (lines 127–137 and 678–679). In addition, NVIDIA currently documents cuPQC-PK as providing GPU-accelerated, batched FIPS-203 ML-KEM. This does not by itself disprove a narrowly framed integrated-SoC or implementation-date priority claim, but it makes the unqualified “first” claim and the current related-work survey untenable without a dated, systematic comparison.

Source: [NVIDIA cuPQC-PK overview](https://docs.nvidia.com/cuda/cupqc/overview/feature_cupqc_pk.html)

## 4. SP 800-90B terminology and placement

NIST SP 800-90B explains that health tests are primarily applied to noise-source outputs before conditioning; tests may additionally be applied to conditioned outputs, but that is not the same as demonstrating an SP 800-90B-conforming entropy-source design. Applying byte-level RCT/APT checks to Linux `getrandom()` output, without the underlying noise-source model, assessed min-entropy, cutoff derivation, persistent state, startup behavior, and failure policy, does not support the manuscript’s present compliance implication.

Source: [NIST SP 800-90B](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-90B.pdf)
