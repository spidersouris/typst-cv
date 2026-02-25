#import "../cv.typ": *

#let cvdata = yaml("template.yml")

#let uservars = (
  authorname: [Doyen, E.], // array; full last name, first initial; as shown in bibliography
  // used to highlight name in author lists
  headingfont: "Libertinus Serif",
  bodyfont: "Libertinus Serif",
  fontsize: 10pt, // length
  linespacing: 6pt, // length
  sectionspacing: 0pt, // length
  showAddress: false, // bool
  showNumber: false, // bool
  showTitle: true, // bool
  headingsmallcaps: true, // bool
  sendnote: false, // bool
  institutionalEmail: false, // bool
  githubStarIcon: "assets/github-star.svg", // str
)

// setrules and showrules can be overridden by re-declaring it here
// #let setrules(doc) = {
//      // add custom document style rules here
//
//      doc
// }

#let footertext = {
  context [
    #align(
      center,
      if counter(page).get() != (1,) { text(size: 0.93em, fill: luma(30%))[Enzo Doyen] } else { h(4.65em) } + h(1fr) + counter(page).display("1 / 1", both: true) + h(1fr) + text(size: 0.93em, fill: luma(30%))[Last updated: #datetime.today().display()],
    ),
  ]
}

#let customrules(doc) = {
  set page(
    paper: "us-letter",
    margin: 1.25cm,
    footer: footertext,
  )

  set list(indent: 1em) // indent bullet list for legibility

  doc
}

#let cvinit(doc) = {
  doc = setrules(uservars, doc)
  doc = showrules(uservars, doc)
  doc = customrules(doc)

  doc
}

// each section body can be overridden by re-declaring it here
// #let cveducation = []

// ========================================================================== //

#show: doc => cvinit(doc)

#cvheading(cvdata, uservars)
#cveducation(cvdata)
#cvwork(cvdata)
#cvprojects(cvdata, uservars, title: "Featured Programming Projects")
#cvpublications(cvdata, uservars)
#cvtalks(cvdata, uservars)
#cvawards(cvdata)
#cvschools(cvdata, uservars)
#cvvolunteering(cvdata, uservars)
//#cvreviewing(cvdata) //! temporarily switch teaching and reviewing to avoid large blank space on p. 2; undo when more content
#cvteaching(cvdata)
#cvreviewing(cvdata)
#cvskills(cvdata)
