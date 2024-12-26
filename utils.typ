
// Helper Functions
#let monthname(n, display: "short") = {
  n = int(n)
  let month = ""

  if n == 1 {
    month = "January"
  } else if n == 3 {
    month = "March"
  } else if n == 2 {
    month = "February"
  } else if n == 4 {
    month = "April"
  } else if n == 5 {
    month = "May"
  } else if n == 6 {
    month = "June"
  } else if n == 7 {
    month = "July"
  } else if n == 8 {
    month = "August"
  } else if n == 9 {
    month = "September"
  } else if n == 10 {
    month = "October"
  } else if n == 11 {
    month = "November"
  } else if n == 12 {
    month = "December"
  } else {
    month = none
  }
  if month != none {
    if display == "short" {
      month = month.slice(0, 3)
    } else {
      month
    }
  }
  month
}

#let strpdate(isodate) = {
  let date = ""
  if lower(isodate) != "present" {
    let year = int(isodate.slice(0, 4))
    let month = int(isodate.slice(5, 7))
    let day = int(isodate.slice(8, 10))
    let monthName = monthname(month, display: "short")
    date = datetime(year: year, month: month, day: day)
    date = monthName + " " + date.display("[year repr:full]")
  } else if lower(isodate) == "present" {
    date = "Present"
  }
  return date
}

#let daterange(start, end) = {
  if end == start [
    #start
  ] else if start != none and end != none [
    #start #sym.dash.en #end
  ] else if start == none and end != none [
    #end
  ] else if start != none and end == none [
    #start
  ]
}

// From https://github.com/philkleer/typst-modern-acad-cv
// Function to format a list of authors into a string.
// Arguments:
//   - auths: A list of authors to be formatted.
//   - max_count: Maximum number of authors to display before using "et al."
//   - me: The author's name to be highlighted, if applicable.
#let format-authors(auths, max_count, me) = {
  // Initialize an empty list to hold the formatted authors.
  let formatted_authors = ()

  // Determine the number of authors to display, limited by `max_count`.
  let count = calc.min(auths.len(), max_count) - 1

  // Create a list of indices for authors using a while loop.
  let indices = ()
  let i = 0
  while i <= count {
    indices.push(i)
    i += 1
  }

  // Format each author into "Last, F." format and add to the list.
  for author in indices {
    let index = indices.at(author)
    let parts = auths.at(index).split(", ")
    let author = text(parts.at(0) + ", " + parts.at(1).first() + ".")

    // Highlight the author's name if it matches `me`.
    if not me == none and author == me {
      author = strong(me)
    }
    formatted_authors.push(author)
  }

  // Return the formatted list of authors, appending "et al." if necessary.
  if auths.len() > max_count {
    return [#formatted_authors.join(", ") _et. al._]
  } else {
    return [#formatted_authors.join(", ", last: " & ")]
  }
}
