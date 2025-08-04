#import "utils.typ"
#import "@preview/fontawesome:0.5.0": *
#import "@preview/use-academicons:0.1.0": *

// set rules
#let setrules(uservars, doc) = {
  set text(
    font: uservars.bodyfont,
    size: uservars.fontsize,
    hyphenate: false,
  )

  set list(spacing: uservars.linespacing)

  set par(
    leading: uservars.linespacing,
    justify: true,
  )

  doc
}

// show rules
#let showrules(uservars, doc) = {
  // Uppercase section headings
  show heading.where(level: 2): it => block(width: 100%)[
    #v(uservars.sectionspacing)
    #set align(left)
    #set text(font: uservars.headingfont, size: 1em, weight: "bold")
    #if (uservars.at("headingsmallcaps", default: false)) {
      smallcaps(it.body)
    } else {
      upper(it.body)
    }
    #v(-0.75em) #line(length: 100%, stroke: 1pt + black) // draw a line
  ]

  // Name title/heading
  show heading.where(level: 1): it => block(width: 100%)[
    #set text(font: uservars.headingfont, size: 1.5em, weight: "bold")
    #if (uservars.at("headingsmallcaps", default: false)) {
      smallcaps(it.body)
    } else {
      upper(it.body)
    }
    #v(2pt)
  ]

  // left align teaching table
  show figure: set align(left)

  doc
}

// Set page layout
#let cvinit(doc) = {
  doc = setrules(doc)
  doc = showrules(doc)

  doc
}

// Job titles
#let jobtitletext(info, uservars) = {
  if uservars.showTitle {
    block(width: 100%)[
      *#info.personal.titles.join("  /  ")*
      #v(-4pt)
    ]
  } else {
    none
  }
}

// Address
#let addresstext(info, uservars) = {
  if uservars.showAddress {
    // Filter out empty address fields
    let address = info
      .personal
      .location
      .pairs()
      .filter(it => (
        it.at(1) != none and str(it.at(1)) != ""
      ))
    // Join non-empty address fields with commas
    let location = address.map(it => str(it.at(1))).join(", ")

    block(width: 100%)[
      #location
      #v(-4pt)
    ]
  } else {
    none
  }
}

#let contacttext(info, uservars) = block(width: 100%)[
  #show link: underline
  #let profiles = (
    if uservars.institutionalEmail {
      box(
        fa-icon("envelope-open")
          + " "
          + link(
            "mailto:" + info.personal.institutional-email,
          )[#info.personal.institutional-email],
      )
    } else {
      box(
        fa-icon("envelope-open")
          + " "
          + link("mailto:" + info.personal.email)[#info.personal.email],
      )
    },
    if uservars.showNumber {
      box(link("tel:" + info.personal.phone))
    } else {
      none
    },
    if info.personal.url != none {
      box(
        fa-icon("globe")
          + " "
          + link(info.personal.url)[#(
              info.personal.url.split("//").at(1)
            )],
      )
    },
  ).filter(it => it != none) // Filter out none elements from the profile array

  #if info.personal.profiles.len() > 0 {
    for profile in info.personal.profiles {
      profiles.push(
        box(
          fa-icon(profile.icon)
            + " "
            + link(profile.url)[#(
                profile.url.split("//").at(1)
              )],
        ),
      )
    }
  }

  #set text(
    font: uservars.bodyfont,
    weight: "medium",
    size: uservars.fontsize * 1,
  )
  #pad(x: 6em)[
    #profiles.join([#sym.space.en])
  ]
]

#let cvheading(info, uservars) = {
  align(center)[
    = #info.personal.name
    #jobtitletext(info, uservars)
    #addresstext(info, uservars)
    #contacttext(info, uservars)
  ]
}

#let cvwork(info, title: "Work Experience", isbreakable: true) = {
  if info.work != none {
    block(breakable: isbreakable)[
      == #title

      #for w in info.work {
        // Create a block layout for each work entry
        for p in w.positions {
          block(width: 100%, breakable: isbreakable)[
            *#p.position* #h(1fr) *#w.location* \
          ]
          block(width: 100%, breakable: isbreakable, above: 0.6em)[
            // Parse ISO date strings into datetime objects
            #let start = utils.strpdate(p.startDate)
            #let end = utils.strpdate(p.endDate)
            // Line 2: Position and Date Range
            #text(
              style: "italic",
              weight: 0,
            )[
              #if utils._is(w.img) [
                #box(image(w.img), height: 9pt)
              ] *#link(w.url)[#w.organization]*] #h(1fr)
            #utils.daterange(start, end) \
            // Highlights or Description
            #show link: underline
            #if utils._is(p.highlights) {
              for hi in p.highlights [
                - #eval(hi, mode: "markup") #if (
                    p.position == "Adjunct Lecturer"
                  ) {
                    [See #link(<teaching>)[Teaching Responsibilities] for details.]
                  }
              ]
            }
          ]
        }
      }
    ]
  }
}

#let cvvolunteering(
  info,
  uservars,
  title: "Volunteer Experience",
  isbreakable: true,
) = {
  if info.volunteering != none {
    block(breakable: isbreakable)[
      == #title

      #for v in info.volunteering {
        // Create a block layout for each volunteering entry
        block(width: 100%, breakable: isbreakable)[
          *#v.title* #if utils._is(v.url) {
            link(v.url)[ #fa-icon("external-link", size: uservars.fontsize * 0.8)]
          } #h(1fr) *#v.location* \
        ]
        block(width: 100%, breakable: isbreakable, above: 0.6em)[
          // Highlights or Description
          #show link: underline
          #if utils._is(v.highlights) {
            for hi in v.highlights [
              - #eval(hi, mode: "markup")
            ]
          }
        ]
      }
    ]
  }
}

#let cveducation(info, title: "Education", isbreakable: true) = {
  if info.education != none {
    block(breakable: isbreakable)[
      == #title

      #for edu in info.education {
        let start = utils.strpdate(edu.startDate)
        let end = utils.strpdate(edu.endDate)

        let edu-items = ""
        if utils._is(edu.honors) {
          edu-items = edu-items + "- *Honors*: " + edu.honors.join(", ") + "\n"
        }
        if utils._is(edu.courses) {
          edu-items = (
            edu-items + "- *Courses*: " + edu.courses.join(", ") + "\n"
          )
        }
        if utils._is(edu.highlights) {
          for hi in edu.highlights {
            edu-items = edu-items + "- " + hi + "\n"
          }
          edu-items = edu-items.trim("\n")
        }

        // Create a block layout for each education entry
        block(width: 100%, breakable: isbreakable)[
          // Line 1: Institution and Location
          *#edu.title* #h(1fr) *#edu.location* \
          // Line 2: Degree and Date
          #if utils._is(edu.img) [
            #box(
              image(edu.img),
              height: 9pt,
            )
          ]
          #link(edu.url)[#text(style: "italic")[#edu.institution]] #h(1fr)
          #utils.daterange(start, end) \
          #eval(edu-items, mode: "markup")
        ]
      }
    ]
  }
}

#let cvaffiliations(
  info,
  title: "Leadership and Activities",
  isbreakable: true,
) = {
  if utils._is(info.affiliations) {
    block(breakable: isbreakable)[
      == #title

      #for org in info.affiliations {
        // Parse ISO date strings into datetime objects
        let start = utils.strpdate(org.startDate)
        let end = utils.strpdate(org.endDate)

        // Create a block layout for each affiliation entry
        block(width: 100%, breakable: isbreakable)[
          // Line 1: Organization and Location
          #if utils._is(org.url) [
            *#link(org.url)[#org.organization]* #h(1fr) *#org.location* \
          ] else [
            *#org.organization* #h(1fr) *#org.location* \
          ]
          // Line 2: Position and Date
          #text(style: "italic")[#org.position] #h(1fr)
          #utils.daterange(start, end) \
          // Highlights or Description
          #if utils._is(org.highlights) {
            for hi in org.highlights [
              - #eval(hi, mode: "markup")
            ]
          } else {}
        ]
      }
    ]
  }
}

#let cvprojects(info, uservars, title: "Projects", isbreakable: true) = {
  show link: underline

  let create_project_entry = (project, start, end) => {
    if (
      utils._is(project.url) and utils._is(project.github)
    ) [
      *#project.name | #link(project.url) | #fa-icon("github") #link("https://github.com/" + project.github)[#project.github] #if project.github-stars != none {
        box(
          image(uservars.githubStarIcon),
          height: 7pt,
        ) + " " + str(project.github-stars)
      }* #h(1fr) #utils.daterange(start, end)
    ] else if utils._is(project.github) [
      *#project.name | #fa-icon("github") #link("https://github.com/" + project.github)[#project.github] #if project.github-stars != none {
        box(
          image(uservars.githubStarIcon),
          height: 7pt,
        ) + " " + str(project.github-stars)
      }* #h(1fr) #utils.daterange(start, end)
    ] else if utils._is(project.url) [
      *#link(project.url)[#project.name | #link(project.url)]* #h(1fr) #utils.daterange(
        start,
        end,
      )
    ] else [
      *#project.name* #h(1fr) #utils.daterange(start, end)
    ]
  }

  if utils._is(info.projects) {
    block(breakable: isbreakable)[
      == #title

      #for project in info.projects {
        // Parse ISO date strings into datetime objects
        let start = utils.strpdate(project.startDate)
        let end = if utils._is(project.endDate) {
          utils.strpdate(project.endDate)
        } else {
          start
        }
        // Create a block layout for each project entry
        block(width: 100%, breakable: isbreakable)[
          // Line 1: Project Name
          #create_project_entry(project, start, end)
          // Summary or Description
          #for hi in project.highlights [
            - #eval(hi, mode: "markup")
          ]
        ]
      }
    ]
  }
}

#let cvawards(info, title: "Honors and Awards", isbreakable: false) = {
  if utils._is(info.awards) {
    block(breakable: isbreakable)[
      == #title

      #for award in info.awards {
        // Parse ISO date strings into datetime objects
        let date = utils.strpdate(award.date)
        // Create a block layout for each award entry
        block(width: 100%, breakable: isbreakable)[
          // Line 1: Award Title and Location
          #if utils._is(award.url) [
            *#link(award.url)[#award.title]* #h(1fr) *#award.location* \
          ] else [
            *#award.title* #h(1fr) *#award.location* \
          ]
          // Line 2: Subtext and Date
          #eval(award.subtext, mode: "markup") #h(1fr) #date \
          // Summary or Description
          #if award.highlights != none {
            for hi in award.highlights [
              - #eval(hi, mode: "markup")
            ]
          } else {}
        ]
      }
    ]
  }
}

#let cvcertificates(
  info,
  title: "Licenses and Certifications",
  isbreakable: true,
) = {
  if utils._is(info.certificates) {
    block(breakable: isbreakable)[
      == #title

      #for cert in info.certificates {
        // Parse ISO date strings into datetime objects
        let date = utils.strpdate(cert.date)
        // Create a block layout for each certificate entry
        block(width: 100%, breakable: isbreakable)[
          // Line 1: Certificate Name and ID (if applicable)
          #if cert.url != none [
            *#link(cert.url)[#cert.name]* #h(1fr)
          ] else [
            *#cert.name* #h(1fr)
          ]
          #if "id" in cert.keys() and cert.id != none and cert.id.len() > 0 [
            ID: #raw(cert.id)
          ]
          \
          // Line 2: Subtext and Date
          #eval(cert.subtext, mode: "markup") #h(1fr) #date \
        ]
      }
    ]
  }
}

#let cvtalks(
  info,
  uservars,
  title: "Talks and Presentations",
  isbreakable: false,
) = {
  if utils._is(info.talks) {
    block(breakable: isbreakable)[
      == #title

      #for talk in info.talks {
        // Parse ISO date strings into datetime objects
        let date = utils.strpdate(talk.date)

        let authors = utils.format-authors(
          talk.authors,
          talk.authors.len(),
          uservars.authorname,
        )

        // Create a block layout for each talk entry
        block(width: 100%, breakable: isbreakable)[
          // Line 1: Talk Title and Location
          *#talk.name*
          #if utils._is(talk.english) {
            text(style: "italic", [(#talk.english)])
          } #h(1fr) *#talk.location* \
          // Line 2: Event and Date
          #talk.conference-intro
          #text(style: "italic")[#talk.conference (#authors)
            #if utils._is(talk.url) {
              link(
                talk.url,
              )[ #fa-icon("external-link", size: uservars.fontsize * 0.8)]
            }] #h(1fr) #date \
        ]
      }
    ]
  }
}

#let cvschools(
  info,
  uservars,
  title: "Schools",
  isbreakable: true,
) = {
  if utils._is(info.schools) {
    block(breakable: isbreakable)[
      == #title
      #for school in info.schools {
        // Parse ISO date strings into datetime objects
        let date = utils.strpdate(school.date)

        // Create a block layout for each school entry
        block(width: 100%, breakable: isbreakable)[
          // Line 1: school Title and Location
          *#school.name*
          #if utils._is(school.url) {
            link(school.url)[ #fa-icon("external-link", size: uservars.fontsize * 0.8)]
          } #h(1fr) *#school.location* \
          // Line 2: Event and Date
          #text(style: "italic")[#school.affiliation] #h(1fr) #date \
          #if utils._is(school.highlights) [
            #for hi in school.highlights [
              - #eval(hi, mode: "markup")
            ]
          ]
        ]
      }
    ]
  }
}

#let cvteaching(
  info,
  title: "Teaching Responsibilities",
  engparenthesis: false,
  isbreakable: true,
) = {
  if utils._is(info.teaching) {
    block(breakable: isbreakable)[
      == #title
      #figure(supplement: none, gap: 0em, table(
        columns: (1fr, 1fr, auto, auto),
        stroke: none,
        table.header([Course Name], [Institution], [Level], [Dates]),
        table.hline(),
        ..for (name, english, fullresp, position, level, semester) in (
          info.teaching
        ) {
          (
            if fullresp { sym.penta.stroked } else { sym.circle.nested }
              + " "
              + if engparenthesis {
                name + linebreak() + text(style: "italic")[(#english)]
              } else { english + linebreak() + text(style: "italic")[(#name)] },
            position,
            level,
            semester,
          )
        },
      )) <teaching>
      #align(
        right,
      )[#sym.penta.stroked Full responsibility | #sym.circle.nested Partial responsibility]
    ]
  }
}

#let cvpublications(
  info,
  uservars,
  title: "Research and Publications",
  isbreakable: true,
) = {
  show link: underline

  let create_publication = (pub, authors) => {
    if pub.type == "app" {
      block(width: 100%, breakable: isbreakable, spacing: 0.6em)[
        #text(style: "italic")[#authors] (#pub.year). #pub.name (v#pub.version).
        #if utils._is(pub.doi) {
          [#ai-icon("depsy") #link("https://doi.org/" + pub.doi)[#pub.doi]]
        }
      ]
    } else if pub.type == "poster" or pub.type == "conference" {
      block(width: 100%, breakable: isbreakable, spacing: 0.6em)[
        #text(style: "italic")[#authors] (#pub.year). #pub.name. #text(style: "italic")[#pub.conference]. #pub.location.
        #if utils._is(pub.doi) {
          [#ai-icon("depsy") #link("https://doi.org/" + pub.doi)[#pub.doi]]
        }
      ]
    } else if pub.type == "thesis" {
      block(width: 100%, breakable: isbreakable, spacing: 0.6em)[
        #text(style: "italic")[#authors] (#pub.year). #pub.name. #pub.university. #if utils._is(pub.url) {
          // don't show underline for this type of external link icon
          show underline: it => it.body
          link(pub.url)[ #fa-icon("external-link", size: uservars.fontsize * 0.8)]
        }
      ]
    } else if pub.type == "preprint" {
      block(width: 100%, breakable: isbreakable, spacing: 0.6em)[
        #text(style: "italic")[#authors] (#pub.year). #pub.name.
        #if utils._is(pub.doi) {
          [#ai-icon("depsy") #link("https://doi.org/" + pub.doi)[#pub.doi]]
        }
      ]
    } else {
      block(width: 100%, breakable: isbreakable, spacing: 0.6em)[
        #text(style: "italic")[#authors] (#pub.year). #pub.name. #text(style: "italic")[#pub.journal]. #pub.volume. #pub.pages.
        #if utils._is(pub.doi) {
          [#ai-icon("depsy") #link("https://doi.org/" + pub.doi)[#pub.doi]]
        }
      ]
    }
  }

  if utils._is(info.publications) {
    block(breakable: isbreakable)[
      == #title

      #for pub in info.publications {
        let authors = utils.format-authors(
          pub.authors,
          pub.authors.len(),
          uservars.authorname,
        )

        create_publication(pub, authors)
      }
    ]
  }
}

#let cvskills(
  info,
  title: "Skills",
  isbreakable: true,
) = {
  if (
    utils._is(info.skills)
      or utils._is(info.interests)
      or utils._is(info.languages)
  ) {
    block(breakable: isbreakable)[
      == #title

      #if utils._is(info.skills) [
        #for group in info.skills [
          - *#group.category*: #group.skills.join(", ")
        ]
      ]
      #if utils._is(info.interests) [
        - *Interests*: #info.interests.join(", ")
      ]
      #if utils._is(info.languages) [
        #let langs = ()
        #for lang in info.languages {
          langs.push([#lang.language (#lang.fluency)])
        }
        - *Languages*: #langs.join(", ")
      ]
    ]
  }
}

#let cvreferences(info, title: "References", isbreakable: true) = {
  if utils._is(info.references) {
    block(breakable: isbreakable)[
      == #title

      #for ref in info.references {
        block(width: 100%, breakable: isbreakable)[
          #if utils._is(ref.url) [
            - *#link(ref.url)[#ref.name]*: "#ref.reference"
          ] else [
            - *#ref.name*: "#ref.reference"
          ]
        ]
      }
    ]
  } else {}
}
