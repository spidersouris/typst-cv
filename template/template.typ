#import "../cv.typ": *

#let cvdata = yaml("template.yml")

#let uservars = (
  authorname: [Doyen, E.], // full last name, first initial; as shown in bibliography
  // used to highlight name in author lists
  headingfont: "Libertinus Serif",
  bodyfont: "Libertinus Serif",
  fontsize: 10pt, // 10pt, 11pt, 12pt
  linespacing: 6pt,
  sectionspacing: 0pt,
  showAddress: false, // true/false show address in contact info
  showNumber: false, // true/false show phone number in contact info
  showTitle: true, // true/false show title in heading
  headingsmallcaps: true, // true/false use small caps for headings
  sendnote: false, // set to false to have sideways endnote
  institutionalEmail: true, // set to true to show institutional email
  githubStarIcon: "assets/github-star.svg", // path to GitHub star icon
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
    paper: "us-letter", // a4, us-letter
    numbering: "1 / 1", // you can comment out or remove this line to remove numbering
    number-align: center, // left, center, right
    margin: 1.25cm, // 1.25cm, 1.87cm, 2.5cm
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
#cvprojects(cvdata, uservars, title: "Programming Projects")
#cvpublications(cvdata, uservars)
#cvtalks(cvdata, uservars)
#cvawards(cvdata)
#cvschools(cvdata, uservars)
#cvteaching(cvdata)
#cvskills(cvdata)
