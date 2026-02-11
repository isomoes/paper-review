#import "@preview/basic-document-props:0.1.0": simple-page

// Document configuration
#let document-author = "isomo"

// Document setup
#set document(
  title: "Review: S-Box Generation Using DNA Encoding and Non-Associative LA-Field Operations for RGB Image Security Applications",
  author: document-author,
  date: datetime.today(),
)

// Page setup
#set page(
  numbering: "1",
  number-align: center,
)

// Heading styles
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
    [*Paper Title:*],
    [S-Box Generation Using DNA Encoding and Non-Associative LA-Field Operations for RGB Image Security Applications],

    [*Manuscript ID:*], [VLSIJ-D-26-00165],
    [*Journal/Conference:*], [Integration, the VLSI Journal],
  )
])

#v(1em)

// This section is for the author response.
= Review Summary

This manuscript proposes a novel S-box construction method combining DNA encoding with non-associative LA-field operations, and applies the resulting S-box to an RGB image encryption scheme. The claimed contributions include achieving optimal nonlinearity (112, matching AES), chaos-independence, and competitive security metrics. While the topic is relevant and the combination of DNA encoding with non-associative algebra is somewhat novel, the paper suffers from #redt[significant weaknesses in theoretical rigor, experimental methodology, and writing quality] that prevent it from meeting the publication standard. #redt[Recommendation: Reject.]

+ #redt[The security proof for the S-box is incomplete] --- the paper only reports standard metrics (NL, SAC, BIC, LP, DP) without providing any formal proof or analysis of why the LA-field structure inherently improves security over associative alternatives. The claim of "non-associativity adds algebraic complexity" is asserted but never substantiated.

+ #redt[The key space analysis is flawed.] The authors claim a key space involving $87381!$, which is astronomically large and physically meaningless. The actual effective key space depends on the independent parameters ($alpha$, $beta$, LFT coefficients, DNA rules), not on permutation counts of codons that are deterministically derived from the key.

+ #redt[The encryption algorithm lacks formal security analysis.] No semantic security argument, no indistinguishability analysis, and no formal threat model is defined. The security evaluation relies entirely on statistical tests on two test images (Lena and House), which is insufficient.

+ #oranget[The comparison is unfair and incomplete.] The paper compares against a narrow set of DNA/algebra-based schemes but ignores well-established image encryption methods (e.g., AES-CTR on pixel data, modern chaos-based schemes with proven security). The S-box matching AES metrics does not imply the overall scheme matches AES security.

+ #oranget[Writing quality needs substantial improvement.] Multiple typos ("utillizes", "envisaged", "representaion"), inconsistent notation, and grammatical errors throughout. Several formulas lack proper definition of variables.

+ #oranget[The experimental evaluation is limited to only two 256×256 images], which is insufficient to draw general conclusions about the scheme's effectiveness.

+ The DNA encoding adds complexity but its actual security contribution beyond key space expansion is unclear. The paper does not analyze whether DNA encoding provides any advantage over simpler byte-level transformations with equivalent key space.

+ The noise robustness analysis (Section 11) only shows qualitative visual results without quantitative comparison against baseline methods under identical noise conditions.

// This section is for the editor and supports the review above.
= Detailed Review

== Innovation Assessment

The paper combines two existing ideas --- DNA encoding and non-associative LA-field algebra --- for S-box construction. The use of LA-field operations in place of standard Galois field arithmetic for the affine transformation step is the primary novelty. However, the novelty is incremental:

- LA-field-based S-box design has been explored by the same research group in prior work (references [8] and [9] in the manuscript). The current contribution extends this by adding DNA encoding as an intermediate representation, but the fundamental algebraic approach remains similar.

- DNA encoding for cryptographic purposes is well-established in the literature. The paper does not introduce new DNA operations; it uses standard encoding rules (Table 1) and codon mappings (Table 2).

- The "chaos-independent" claim is presented as a contribution, but removing chaos does not inherently improve security --- it merely changes the source of nonlinearity. The paper does not demonstrate that chaos-independence provides any concrete advantage (e.g., faster computation, provable security properties).

#score-box("Innovation", "4")

== Technical Quality Assessment

The technical presentation has several concerning issues:

*S-box Construction:*
- The affine transformation $x |-> x alpha + beta$ over $"GF"(2^8)$ is well-known. Performing it via DNA-encoded LA-field component-wise operations is an implementation choice, not a fundamental improvement. The paper does not prove that this approach yields better S-boxes than direct GF($2^8$) computation.
- The LFT mapping $g(t) = (a t + b)/(c t + d)$ is a standard technique from the AES literature. The specific parameter choices ($a=101, b=56, c=11, d=19$) are given without justification for why these values are optimal or how they were selected.
- The claim that nonlinearity 112 is "optimal" needs qualification --- 112 is the maximum for 8-bit S-boxes, matching AES, but this is achieved by many constructions. The paper should clarify what advantage the proposed method offers beyond matching this known bound.

*Encryption Scheme:*
- The permutation $m = (i times 5) mod 8$ for bit shuffling (Step 2 of the algorithm) is a trivial linear operation that provides minimal diffusion. This is a weak component.
- The codon permutation $(i times 29131) mod 87381$ is a simple modular multiplication. The security of this permutation depends entirely on the choice of multiplier, but no analysis of the permutation's cycle structure or diffusion properties is provided.
- The sub-matrix multiplication by the S-box (Step 9) is described vaguely. Matrix multiplication over what field? How does multiplying a $16 times 16$ sub-matrix by an $16 times 16$ S-box work when the S-box is presented as a $16 times 16$ lookup table? This operation needs rigorous definition.

*Key Space:*
- The claimed key space of $65536 times 16776960 times 87381! times (8^2)^2 times 8! times 6$ is problematic. The term $87381!$ represents all permutations of codons, but the actual permutation used is deterministically generated from a single multiplier parameter. The effective key space from the codon permutation is at most the number of valid multipliers coprime to 87381, not $87381!$.

#score-box("Technical Quality", "3")

== Experimental Assessment

The experimental evaluation has notable limitations:

- *Test set size:* Only two images (Lena and House) at $256 times 256$ resolution are used. Modern image encryption papers typically test on diverse image sets including different resolutions, content types (medical, satellite, natural), and standard benchmarks.

- *Statistical significance:* No confidence intervals or statistical tests are reported for NPCR/UACI values. Single-run results on two images cannot establish statistical reliability.

- *Comparison scope:* The comparison in Table 5 includes mostly older or niche methods. Missing comparisons with recent well-cited image encryption schemes (2023--2025) weaken the evaluation.

- *Noise analysis:* Section 11 provides only visual inspection of decrypted noisy images. Table 12 reports PSNR/SSIM for noisy decryption but does not compare against other schemes under identical noise conditions.

- *Computational efficiency:* No runtime or throughput measurements are provided. The claim of "computational efficiency" in the abstract is unsupported by any timing data.

- *The "optimal values" column in Table 11* is unclear --- where do these optimal values come from? Are they theoretical bounds or results from another method? This needs clarification.

#score-box("Experimental Quality", "3")

== Writing Quality Assessment

The manuscript requires significant editing:

- Multiple spelling errors: "utillizes" (appears twice), "representaion", "envisaged" used incorrectly.
- Grammatical issues throughout, e.g., "the senders is able to" (Section 1), "S-boxes havebeen" (missing space in abstract).
- Inconsistent mathematical notation: sometimes $"GF"(2^8)$, sometimes $"GF"(28)$.
- The introduction (Section 1) is overly broad, spending too much space on general cryptography background rather than focusing on the specific problem and contributions.
- Section 2 (Non-associative Algebraic Framework) is too brief --- it lists definitions as bullet points without sufficient mathematical rigor. The LA-field properties that are actually used in the S-box construction should be stated as formal definitions or propositions.
- Several tables lack proper captions or have captions that do not adequately describe the content.
- Figure quality appears adequate but figure references in the text are sometimes inconsistent.

#score-box("Writing Quality", "4")
