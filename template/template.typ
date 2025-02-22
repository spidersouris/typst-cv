#import "../cv.typ": *

#let cvdata = yaml("template.yml")

#let uservars = (
  authorname: [Doyen, E.], // array; full last name, first initial; as shown in bibliography
  // used to highlight name in author lists
  headingfont: "Linux Libertine",
  bodyfont: "Linux Libertine",
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

#let customrules(doc) = {
  // add custom document style rules here
  set page(
    paper: "us-letter",
    numbering: "1 / 1",
    number-align: center,
    margin: 1.25cm,
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
#cvteaching(cvdata)
#cvskills(cvdata)
