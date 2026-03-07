#import "@preview/basic-document-props:0.1.0": simple-page

#let document-author = "isomo"

#set document(
  title: "Review Report for E260091",
  author: document-author,
  date: datetime.today(),
)

#set page(
  numbering: "1",
  number-align: center,
)

#set heading(numbering: "1.1.1.")
#show heading.where(level: 1): set text(size: 16pt, weight: "bold")
#show heading.where(level: 2): set text(size: 14pt, weight: "bold")
#show heading.where(level: 3): set text(size: 12pt, weight: "bold")

// Replace the template body with manuscript-specific content.
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

#rect(width: 100%, stroke: 1pt, inset: 10pt, fill: luma(245), [
  #text(weight: "bold", size: 14pt)[Paper Information]

  #grid(
    columns: (auto, 1fr),
    gutter: 1em,
    [*Paper Title:*], [A Lightweight and Area-Efficient FPGA Implementation of the CRYSTALS-Dilithium Accelerator],
    [*Manuscript ID:*], [E260091],
    [*Journal/Conference:*], [Chinese Journal of Electronics],
  )
])

#v(1em)

= Review Summary

The manuscript presents an FPGA-based ML-DSA accelerator for low-altitude IoT scenarios, with emphasis on a memory-efficient MI-NTT architecture and a LUT-based modular multiplier. The topic is timely, and the reported latency, area, and power results suggest that the design may be practically useful for resource-constrained post-quantum security deployments.

At the same time, the current manuscript still has several presentation and consistency issues that weaken its technical clarity. In particular, some table and figure references are inconsistent, several charts appear not to be properly cited in the main text, and one experimental result in Table 1 is not sufficiently explained. I therefore recommend *minor revision*.

1. The table numbering is inconsistent. For example, the text refers to *Table I* and *Table II*, while the visible table labels in the manuscript are *Table 1* and *Table 2*. Please unify the numbering style throughout the manuscript.
2. Some figures/charts do not seem to be correctly referenced in the text, or the reference numbers are mismatched. For instance, the discussion around memory usage/access frequency and power analysis refers to *Fig. 12* and *Fig. 13*, while the corresponding visible labels are *Figure 9* and *Figure 10*. Please carefully check all figure cross-references.
3. In Table 1, one Barrett-based result appears to use fewer hardware resources than another method, but its operating frequency is also the lowest. Please explain this phenomenon more clearly and discuss the trade-off between resource usage, critical path, and achievable frequency.
4. More generally, the manuscript would benefit from another full proofreading pass to improve consistency of captions, cross-references, and notation.

= Detailed Review

== Innovation Assessment

The paper addresses an important implementation problem for ML-DSA accelerators in constrained IoT settings. The combination of a memory-efficient NTT architecture and a LUT-based modular multiplier is potentially useful, and the emphasis on lightweight deployment is meaningful for FPGA-based post-quantum designs. From this perspective, the work has application value.

That said, the novelty should be communicated more precisely. Some claims are currently mixed with implementation benefits and system-level motivation, so the manuscript would be stronger if the authors explicitly separate: (1) what is structurally new in MI-NTT, (2) what is new in the LUT-based reduction method, and (3) what is mainly an engineering integration contribution.

== Technical Quality Assessment

The overall architecture is reasonable, and the paper provides implementation data on a real platform. The design choices appear technically plausible. However, the manuscript still leaves at least one important result insufficiently explained. In Table 1, the Barrett-based method shows relatively low resource usage but also the lowest frequency. This is not necessarily contradictory, but the reason should be analyzed explicitly. For example, the authors should clarify whether the longer critical path, carry propagation, control complexity, or routing pressure dominates the frequency limitation.

It would also help if the authors explain more carefully how the proposed multiplier compares under the same pipeline depth and timing constraints, so that readers can better understand whether the benefit comes mainly from arithmetic simplification, improved pipelining, or more favorable resource mapping.

== Experimental Assessment

The reported experiments cover latency, area, ATP, and power, which is a good basis for evaluation. The comparative tables are useful. However, the presentation of the experimental section needs correction before the results can be read confidently.

The most obvious issue is the mismatch between in-text references and the actual labels of tables/figures. For example, the text mentions *Table II*, *Table III*, *Fig. 12*, and *Fig. 13*, but the displayed labels appear as *Table 1*, *Table 2*, *Figure 9*, and *Figure 10*. This creates unnecessary confusion and makes it difficult for readers to verify the claims.

Please check whether all figures are cited exactly once in the proper location and whether every citation points to the correct object. If some charts are inserted but never referenced, they should either be cited in the discussion or removed.

== Writing Quality Assessment

The manuscript is generally readable, and the motivation is easy to follow. However, the writing quality is reduced by reference inconsistencies and caption-number mismatches. These issues are editorial in nature, but they affect the perceived rigor of the paper.

I suggest a careful revision of the full manuscript for consistency in numbering style, figure/table citations, and terminology. After these issues are corrected and the Table 1 phenomenon is explained more clearly, the paper will be much easier to assess and significantly stronger in presentation.
