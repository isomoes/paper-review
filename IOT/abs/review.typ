#import "@preview/basic-document-props:0.1.0": simple-page

// Chinese font configuration
// #set text(
//   font: (
//     "Noto Sans CJK SC", // Primary Chinese font
//     "Noto Serif CJK SC", // Alternative Chinese serif font
//     "Noto Sans", // Latin fallback
//   ),
//   lang: "zh",
//   region: "cn",
// )

// Document configuration
#let document-author = "isomo"

// Document setup
#set document(
  title: "A Novel Artificial Bits Superposition BasedSecurity Method for IoT Systems",
  author: document-author,
  date: datetime.today(),
)

// Page setup
#set page(
  numbering: "1",
  number-align: center,
)

// Heading styles with numbering
#set heading(numbering: "1.1.1.")
#show heading.where(level: 1): set text(size: 16pt, weight: "bold")
#show heading.where(level: 2): set text(size: 14pt, weight: "bold")
#show heading.where(level: 3): set text(size: 12pt, weight: "bold")

// Citation styling - make citations blue and clickable-looking
#show cite: set text(fill: blue)

// Table caption positioning - put captions above tables
#show figure.where(kind: table): it => [
  #it.caption
  #it.body
]

// Color shorthand functions
#let redt(content) = text(fill: red, content)
#let bluet(content) = text(fill: blue, content)
#let greent(content) = text(fill: green, content)
#let yellowt(content) = text(fill: yellow, content)
#let oranget(content) = text(fill: orange, content)
#let purplet(content) = text(fill: purple, content)
#let greyt(content) = text(fill: gray, content)
#let grayt(content) = text(fill: gray, content)

// Review scoring function
#let score-box(title, score, max-score: 10) = rect(width: 100%, stroke: 1pt, inset: 8pt, fill: luma(250), [
  #text(weight: "bold")[#title: ] #text(fill: blue, weight: "bold")[#score/#max-score]
])

// Comment box function
#let comment-box(title, content) = rect(width: 100%, stroke: 1pt, inset: 10pt, [
  #text(weight: "bold", size: 11pt)[#title]
  #v(0.5em)
  #content
])

// Title page
#align(center)[
  #text(size: 18pt, weight: "bold")[
    Academic Paper Review Report
  ]
  #v(0.5em)
  #text(size: 12pt)[
    Reviewer: #document-author
    Review Date: #datetime.today().display("[year]-[month]-[day]")
  ]
]

#v(1em)

// Paper information section
#rect(width: 100%, stroke: 1pt, inset: 10pt, fill: luma(245), [
  #text(weight: "bold", size: 14pt)[Paper Information]

  #grid(
    columns: (auto, 1fr),
    gutter: 1em,
    [*Paper Title:*], [A Novel Artificial Bits Superposition BasedSecurity Method for IoT Systems],

    [*Manuscript ID:*], [IoT-62377-2026],
    [*Journal/Conference:*], [IEEE Internet of Things Letter],
  )
])

#v(1em)

// This section is for the author response.
= Review Summary

This manuscript proposes Artificial Bits Superposition (ABS), a cryptographic framework that claims to achieve physical-layer-like security at the application layer for IoT systems using XOR-based operations in $F_2^n$. The claimed contributions include information-theoretic security for key exchange, quantum attack resistance, side-channel resistance, and superior performance over existing post-quantum alternatives.
However, the paper suffers from fundamental technical flaws that undermine its core claims. The "artificial superposition" concept is a misleading repackaging of well-known linear algebra over $F_2$ (invertible matrix transformations and basis changes). The security proofs contain critical errors and unjustified leaps. The experimental results appear unreproducible and the performance claims are implausible. #redt[*Recommendation: Reject.*]

*Key issues:*

+ *Misleading core concept:* The "artificial superposition" is simply a change of basis in $F_2^n$ using invertible matrices---a standard linear algebra operation. Calling it "superposition" and drawing analogies to quantum mechanics is fundamentally misleading. Classical bits XORed with basis vectors do not exhibit quantum properties (no entanglement, no measurement collapse, no no-cloning). The non-commutativity of matrix multiplication (Theorem 1) is a trivial property of $"GL"(n, F_2)$, not a novel insight.

+ *Flawed security proofs:* Theorem 2 (key exchange security) provides only a proof sketch with an inequality that is not properly derived. The claim of "information-theoretic security" is unsupported: Alice sends $M_A^((0))$ in the clear (Algorithm 2, line 4), so an eavesdropper observes the basis matrix directly. The mutual information bound $I(K; E) <= 1/(2^(n-2k)) sum H(M_A^((j)) | M_B^((j)))$ lacks rigorous derivation and the convergence argument is hand-waved. Theorem 4 (perfect secrecy) only holds for one-time use with truly random basis---this is essentially a one-time pad restated with extra notation, not a new result.

+ *Unjustified IND-CCA2 claim:* Theorem 3 claims IND-CCA2 security "under the XOR-Decision Linear assumption in the random oracle model" but provides no proof whatsoever. The "XOR-Decision Linear assumption" is not a recognized hardness assumption in the literature. A one-line theorem statement without proof for such a strong security notion is unacceptable.

+ *Dubious quantum resistance claims:* Theorem 5 claims $Omega(2^(n\/2))$ quantum queries are needed, but the proof is superficial. The "structured ambiguity" argument is vague. Since the entire scheme is linear over $F_2$, Gaussian elimination (a classical attack) can recover the basis and plaintext in $O(n^3)$ time---no quantum computer needed. The linearity of the scheme is its fundamental weakness, and the paper does not address this at all.

+ *Critical vulnerability---linearity:* The ABS encryption $|c chevron.r = M times.o ("Pad"(m) xor "PRG"(K_2)) xor "PRG"(K_3)$ is entirely linear/affine over $F_2$. Given sufficient known plaintext-ciphertext pairs, an attacker can recover $M$ and the PRG outputs through straightforward linear algebra. This is a well-known attack vector against linear cryptosystems that the paper completely ignores.

+ *Implausible performance claims:* Table II shows ABS-256 at 1,200,000 ops/s vs RSA-2048 at 500,000 ops/s. RSA-2048 signature verification is typically ~10,000-50,000 ops/s, and key generation far slower. The numbers appear fabricated or measured incorrectly. The claim of "2.4x faster than RSA-2048" compares fundamentally different operations (symmetric-like XOR vs. modular exponentiation) without proper normalization.

+ *Unreproducible experiments:* No source code, implementation details, or experimental setup (hardware, OS, compiler flags) is provided. The NIST/Dieharder/TestU01 results (Table III) claim perfect scores but provide no raw data, seeds, or methodology. These test suites evaluate randomness of output, not cryptographic security---passing them does not validate the security claims.

+ *Scope mismatch with venue:* The paper is submitted to IEEE Internet of Things Journal/Letters but contains almost no IoT-specific content. There is no discussion of resource-constrained devices, communication protocols, deployment scenarios, or how ABS integrates with existing IoT architectures.

+ *Writing quality issues:* The title contains a typo ("BasedSecurity" should be "Based Security"). Quantum notation ($|psi chevron.r$, $|c chevron.r$) is used for classical binary vectors, which is misleading. Figure 2 reference in Section VII is broken ("shown in 2" instead of "shown in Fig. 2"). The paper uses hyperbolic language throughout ("revolutionary," "unprecedented," "paradigm shift") that is inappropriate for a technical paper.

+ *Insufficient related work:* The paper does not compare with NIST post-quantum standards (CRYSTALS-Kyber for KEM, CRYSTALS-Dilithium for signatures) beyond a superficial table entry. No discussion of lattice-based, code-based, or hash-based cryptography is provided. The related work on physical layer security is superficial and does not establish how ABS relates to the rich PLS literature.


// This section is for the editor and supports the review above.
= Detailed Review

== Innovation Assessment

The paper claims novelty in creating "artificial superposition" for classical bits using XOR operations and basis transformations over $F_2^n$. However, upon careful examination, the core technique is a standard change of basis using invertible matrices in $"GL"(n, F_2)$---a well-studied algebraic structure. Representing a binary vector in different bases using matrix multiplication is a fundamental operation in linear algebra, not a novel cryptographic primitive.

The analogy to quantum superposition is superficial and misleading. In quantum mechanics, superposition involves complex probability amplitudes, measurement collapse, and the no-cloning theorem. None of these properties exist in the proposed classical system. A binary vector $s$ expressed as $s = M dot v$ for different invertible matrices $M$ does not create any "superposition"---it is simply a linear transformation. The non-commutativity highlighted in Theorem 1 is an elementary property of matrix multiplication, known since the 19th century.

The claim of creating "genuine superposition states through algebraic structures rather than simulation" (Section II-C) is unfounded. There is no genuine superposition in classical bits, regardless of the algebraic operations applied.

== Technical Quality Assessment

The technical quality of this paper is critically deficient in several aspects:

*Security proof issues:*
- Theorem 2 (key exchange security): The proof sketch provides an information-theoretic bound but does not properly account for the fact that $M_A^((0))$ is transmitted in the clear. An eavesdropper who observes all public transmissions can potentially reconstruct the shared state through linear algebraic methods.
- Theorem 3 (IND-CCA2 security): This is stated without any proof. The referenced "XOR-Decision Linear assumption" does not appear in standard cryptographic literature. Claiming IND-CCA2 security---one of the strongest security notions---without proof is a serious deficiency.
- Theorem 4 (perfect secrecy): While mathematically correct in isolation, this is essentially a restatement of the one-time pad's perfect secrecy, adding only the notational overhead of basis transformations. This is not a new result.
- Theorem 5 (Grover resistance): The proof assumes the search space is unstructured, but the linearity of ABS means the search space is highly structured, potentially allowing polynomial-time classical attacks that make quantum speedups irrelevant.

*Fundamental linearity vulnerability:*
The most critical issue is that the entire ABS framework operates linearly over $F_2$. The encryption $|c chevron.r = M times.o ("Pad"(m) xor "PRG"(K_2)) xor "PRG"(K_3)$ is an affine function of the plaintext. With $O(n)$ known plaintext-ciphertext pairs, an attacker can set up a system of linear equations over $F_2$ and solve for $M$ and the PRG outputs using Gaussian elimination in $O(n^3)$ time. This is a well-known attack against linear ciphers and is the reason modern ciphers (AES, ChaCha20) incorporate nonlinear operations (S-boxes, modular addition).

*Key exchange protocol issues:*
In Algorithm 2, Alice sends $M_A^((0))$ on a public channel (line 4). Bob then computes and sends $|phi^((0)) chevron.r = M_B^((0)) times.o |psi_A^((0)) chevron.r$. An eavesdropper sees both $M_A^((0))$ and $|phi^((0)) chevron.r$. Without Bob's private state, recovery appears non-trivial, but the iterative updates (line 10) using a public function $f$ of previous public values may leak information progressively. The paper does not provide a rigorous analysis of this leakage across iterations.

== Experimental Assessment

The experimental evaluation has several critical deficiencies:

*Implausible benchmark numbers:*
- ABS-256 is claimed to achieve 1,200,000 ops/s. For 256-bit matrix operations over $F_2$, each operation involves at minimum a $256 times 256$ matrix-vector multiplication (65,536 AND + XOR operations). At 1.2M ops/s, this implies ~78 billion bit operations per second, which is implausible for a single-threaded implementation on standard hardware.
- RSA-2048 at 500,000 ops/s is unrealistically high for key exchange operations. OpenSSL benchmarks typically show RSA-2048 sign at ~1,000 ops/s and verify at ~30,000 ops/s.
- Kyber-768 at 320,000 ops/s significantly underestimates known performance. The CRYSTALS-Kyber reference implementation achieves millions of encapsulations per second.

*Missing experimental methodology:*
- No hardware specifications (CPU model, clock speed, cache sizes).
- No software details (compiler version, optimization flags, library versions).
- No statistical analysis (confidence intervals, number of trials, warm-up procedures).
- No source code or reproducibility artifacts.

*Misleading security test interpretation:*
The NIST Statistical Tests, Dieharder, and TestU01 BigCrush suites test for statistical randomness of output sequences, not cryptographic security. A linear feedback shift register (LFSR) can pass these tests while being trivially breakable. Passing these suites does not validate the security claims made in the paper.

*Missing comparisons:*
No comparison with NIST PQC standards (CRYSTALS-Kyber, CRYSTALS-Dilithium, SPHINCS+) using standardized benchmarks (e.g., SUPERCOP). The comparison with RSA-2048 is misleading since RSA is not a post-quantum algorithm.

== Writing Quality Assessment

The writing quality has several issues:

*Formatting and typographical errors:*
- The title contains a missing space: "BasedSecurity" should be "Based Security."
- Figure reference in Section VII is broken: "shown in 2" should be "shown in Fig. 2."
- Table II contains HTML entities: "¡ 80 bits\*" should be "< 80 bits\*" and similarly in Table III.

*Misleading notation:*
The use of Dirac (bra-ket) notation ($|psi chevron.r$, $|s chevron.r_B$, $|c chevron.r$) for classical binary vectors is inappropriate and misleading. This notation is standard in quantum mechanics and its use here falsely implies quantum properties. Standard vector notation ($bold(s)$, $bold(c)$, $bold(psi)$) would be more appropriate and honest.

*Hyperbolic language:*
The paper repeatedly uses grandiose claims without adequate justification: "revolutionary alternative," "unprecedented security capabilities," "paradigm shift in cryptographic design." Such language is inappropriate in a technical paper, especially when the underlying claims are not substantiated.

*IoT relevance:*
Despite targeting IEEE IoT Journal, the paper barely mentions IoT. There is no discussion of:
- Resource constraints of IoT devices (memory, compute, energy).
- Communication overhead and protocol integration.
- Deployment scenarios or threat models specific to IoT.
- Comparison with lightweight cryptography standards (NIST LWC competition winners like Ascon).

*Reference quality:*
Only 12 references for a paper making broad claims about cryptography, quantum computing, physical layer security, and IoT is insufficient. Key references are missing: NIST PQC standards, lightweight cryptography for IoT, and foundational works on linear cryptanalysis of stream/block ciphers.


