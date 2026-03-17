#import "@preview/basic-document-props:0.1.0": simple-page

// Chinese font configuration
// #set text(
//   font: (
//     "Source Han Serif SC",
//     "Source Han Sans SC",
//   ),
//   lang: "zh",
//   region: "cn",
// )

// Document configuration
#let document-author = "isomo"

// Document setup
#set document(
  title: "Hardware-Efficient Round-Based AES via Composite-Field Circuit-Architecture Co-Design",
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
    [*Paper Title:*], [Hardware-Efficient Round-Based AES via Composite-Field Circuit-Architecture Co-Design],
    [*Manuscript ID:*], [TC-2025-11-1117],
    [*Journal/Conference:*], [IEEE Transactions on Computers],
  )
])

#v(1em)

= Review Summary

This manuscript presents a round-based AES architecture based on a unified composite-field datapath in "GF((2^4)^2)", with optimized isomorphic mappings, a composite-field inversion design, and integration of affine-related transformations with MixColumns/InvMixColumns. The topic is relevant to hardware security and computer architecture, and the reported synthesis results indicate that the implementation is competitive in area, throughput, and efficiency. However, the current version still has several substantive weaknesses in novelty positioning, reproducibility, and experimental rigor. In particular, the paper does not clearly separate new contributions from inherited techniques, the optimization flow is insufficiently specified for reproduction, and the evaluation relies heavily on cross-paper comparisons with limited implementation-depth evidence. #purplet([Recommendation: Major Revision.])

The main issues are as follows: (1) the novelty claim should be sharpened against prior composite-field AES implementations, especially [34]-[37]; (2) the mapping and inversion optimization flow should be described more precisely, with explicit selection criteria and stronger reproducibility support; (3) the implementation boundary and verification methodology should be clarified, including whether key schedule and control logic are consistently included; (4) the experimental section should provide stronger fairness discussion, incremental ablation evidence, and ideally more implementation-oriented validation; and (5) the writing and presentation should be tightened, including clearer prior-work positioning and removal of the manuscript-ID placeholder.


= Detailed Review

== Innovation Assessment

#score-box("Innovation Score", "6", max-score: 10)

The paper presents a competent engineering optimization of a round-based AES core using composite-field arithmetic in "GF((2^4)^2)". #bluet([The main idea of keeping the intermediate datapath in the composite field, optimizing the isomorphic mapping, and merging affine-related transformations with MixColumns/InvMixColumns is technically meaningful and relevant for hardware AES design.])

That said, #oranget([the overall novelty appears moderate rather than high.]) The paper is positioned as a circuit-architecture co-design, but many building blocks are extensions or recombinations of already known directions: composite-field S-box design, mapping optimization, and area-throughput trade-offs for round-based AES architectures have all been studied in prior work. #purplet([Relative to the cited recent works, the manuscript seems to contribute a better integrated implementation rather than a fundamentally new AES architecture or new arithmetic theory.])

#purplet([The authors should therefore sharpen the novelty claim and explicitly separate what is new from what is inherited.]) In particular, it would help to quantify the incremental benefit of each proposed ingredient: the optimized mapping, the inversion design, and the affine/MixColumns integration. #purplet([Without such ablation-style evidence, it is difficult to judge whether the improvement mainly comes from a genuinely new idea or from a favorable aggregation of known optimizations.])


== Technical Quality Assessment

#score-box("Technical Quality Score", "7", max-score: 10)

The manuscript is generally technically sound, and the architectural flow is coherent. #bluet([The datapath description is understandable, the composite-field background is adequate, and the implementation target is appropriate for this type of work.]) The paper also gives algebraic expressions for the inversion structure and explains how the architecture reuses the same transformation pair for both encryption and decryption.

#purplet([However, the technical presentation still leaves several reproducibility and rigor gaps.]) First, the search process for the irreducible polynomial, primitive elements, and the coefficients $alpha$ and $beta$ is described only at a high level. #purplet([The objective function, search constraints, and the exact criterion used to declare one mapping pair as optimal should be stated more explicitly.]) Second, #oranget([Algorithms 1 and 2 are too abstract to support full reproduction; they read more like conceptual summaries than implementable algorithms.])

#purplet([Third, the manuscript should clarify the verification methodology.]) It is not clear whether the RTL was validated against standard AES test vectors for both encryption and decryption across AES-128 and AES-256, and whether the reported area includes the full key schedule and control logic in a consistent manner across all comparisons. #purplet([Because the paper claims architectural superiority across multiple metrics, these implementation-boundary details are important.])

#oranget([Finally, some claims are stronger than the supporting analysis.]) For example, the paper states that the integrated matrix design improves XOR utilization and reduces complexity, but there is no detailed gate-level or module-level breakdown showing where the savings arise. #purplet([A per-module area/timing breakdown would make the technical argument much stronger.])


== Experimental Assessment

#score-box("Experimental Score", "6", max-score: 10)

The experimental section shows useful synthesis data and compares the proposed design with several prior AES implementations. #bluet([Reporting area, latency, maximum frequency, throughput, power, efficiency, and PL product is appropriate, and it is positive that the authors include both AES-128 and AES-256 as well as results across different cell libraries.])

#purplet([The main concern is fairness and completeness of the evaluation.]) Most comparisons are cross-paper comparisons, and the referenced works may differ in synthesis scripts, constraints, included modules, operating assumptions, and optimization goals. #purplet([Even when the same library is used, comparison across independently reported numbers is not fully controlled.]) The paper would be much stronger if the authors re-implemented at least one representative baseline under the same synthesis flow, or at minimum discussed the comparability limitations more carefully.

#purplet([The second issue is that the evaluation is still limited to pre-layout synthesis style evidence.]) There is no post-layout result, no discussion of routing impact, no PVT sensitivity analysis, and no energy-per-bit metric. Since the claimed contribution is a hardware-efficient AES architecture, #oranget([the lack of deeper implementation evidence weakens the practical significance of the conclusions.]) In addition, power is reported at 100 MHz while throughput is reported at the maximum frequency, which makes cross-metric interpretation less direct. #purplet([A normalized energy or power-efficiency comparison at matched conditions would be more convincing.])

#purplet([The manuscript also needs stronger evidence for the contribution of each optimization stage.]) A table showing the baseline round-based AES core and the incremental effect of each proposed technique on area, timing, and power would substantially improve the experimental credibility.


== Writing Quality Assessment

#score-box("Writing Quality Score", "6", max-score: 10)

#oranget([The manuscript is readable and follows a standard hardware-paper structure, but the writing quality needs improvement before publication.]) The paper contains many long sentences, repeated statements, and several awkward expressions that reduce precision. Some sections read as if they are expanding obvious AES background rather than focusing on the specific technical contribution.

#purplet([There are also presentation issues that should be corrected carefully.]) #purplet([The extracted manuscript shows a visible placeholder line for the manuscript ID, which should not remain in a submission-ready version.]) Some notation is introduced inconsistently, and several symbols and equations would benefit from clearer definitions immediately before use. The use of lemmas, corollaries, and remarks feels somewhat formalistic in places; in several cases these items simply restate implementation facts rather than proving a nontrivial result.

#purplet([The related-work discussion should also be sharpened.]) At present, the manuscript tends to describe prior work in a broad and sometimes selective way, but the exact distinction from [34]-[37] is not made crisply enough. #oranget([The paper would benefit from a more direct statement of: (1) what each prior work already optimized, (2) what is still missing there, and (3) what new measurable advantage this manuscript provides.])


= Specific Revision Suggestions

== Major Issues

+ *Clarify the true novelty:* Explicitly distinguish the genuinely new parts from the inherited composite-field AES techniques. A concise contribution-to-prior-work map would help.

+ *Improve reproducibility of the optimization flow:* Expand Algorithms 1 and 2, define the optimization objective precisely, and explain how the final mapping pair, irreducible polynomial, and coefficient set are selected.

+ *Strengthen comparison fairness:* Clarify whether the reported area includes key expansion, control logic, and both encryption/decryption datapaths in every case. If possible, re-synthesize one or more representative baselines under the same design flow.

+ *Add incremental evidence:* Provide an ablation table showing the impact of each proposed technique on area, latency, power, and efficiency.

+ *Deepen implementation validation:* Include stronger verification details and, if available, post-layout or at least more implementation-oriented evidence beyond logic synthesis.


== Minor Issues

+ *Manuscript formatting:* Remove the visible manuscript-ID placeholder and carefully proofread figure/table formatting.

+ *Notation consistency:* Define all symbols immediately before use and keep field notation and variable naming consistent throughout the paper.

+ *Equation presentation:* Some derivations are dense and difficult to follow; intermediate explanations should be added around key equations.

+ *Prior-work positioning:* Tighten the discussion of [34]-[37] and explain more concretely why the proposed design is not merely a tuned reimplementation.

+ *Metric consistency:* Since power is measured at 100 MHz while throughput is measured at maximum frequency, add a matched-condition comparison or an energy-per-bit metric.


= Review Comments

== Comments to Authors

This manuscript presents a round-based AES hardware architecture built around a unified "GF((2^4)^2)" datapath, optimized isomorphic mappings, a composite-field inversion structure, and an integrated treatment of affine-related transformations with MixColumns/InvMixColumns. #bluet([The topic fits Transactions on Computers, and the paper contains a meaningful engineering contribution with solid synthesis-oriented results.])

#purplet([My main reservation is that the current version does not yet make a sufficiently strong case for *how much* of the reported gain comes from genuinely new ideas versus a careful integration of known composite-field optimization techniques.]) The manuscript also relies heavily on cross-paper synthesis comparisons, which are useful but not fully controlled. #oranget([For this reason, I view the work as promising but not yet ready in its current form.])

The most important revisions are as follows:

1. Please sharpen the novelty statement and explicitly identify what is new relative to the most relevant prior AES hardware papers, especially [34]-[37].

2. Please make the mapping/inversion optimization flow more reproducible. The current algorithms are too abstract, and the selection criteria for the final configuration are not precise enough.

3. Please clarify the implementation boundary of the reported hardware cost. In particular, state clearly whether key schedule, controller overhead, and dual-mode support are included consistently in all reported results.

4. Please provide ablation-style evidence showing the separate contribution of each proposed optimization. This would greatly strengthen the paper.

5. Please improve the evaluation discussion by addressing fairness limitations of cross-paper comparisons and, if possible, adding stronger implementation evidence or normalized efficiency metrics.

6. Please revise the writing for precision and conciseness. Several parts of the manuscript are verbose, and the distinction between mathematical result and engineering observation should be clearer.

#purplet([Overall, I recommend *major revision*.]) #oranget([The paper has a solid implementation direction and potentially publishable value, but it needs clearer positioning, stronger reproducibility, and more convincing evaluation support before it can be accepted.])

== Confidential Comments to Editor

#oranget([The manuscript is relevant to TC and reports a respectable hardware implementation result, but I do not think the current version establishes sufficiently high novelty or sufficiently rigorous experimental support for acceptance yet.]) #purplet([The contribution looks closer to an incremental but competent integration of known composite-field AES optimization ideas than to a clearly new architectural concept.]) #purplet([I recommend *major revision* rather than rejection because the work appears technically credible and could become publishable if the authors substantially improve the novelty positioning, reproducibility, and evaluation rigor.])

// Bibliography section
// #bibliography("../references.bib", style: "apa")
