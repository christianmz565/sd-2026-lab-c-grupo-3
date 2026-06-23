#import "/lib.typ": code-block, code-block-config, summarize-name, unsa-report

#let members = (
  "Bedregal Perez Daniel",
  "Jara Mamani Mariel Alisson",
  "Mestas Zegarra Christian Raul",
  "Noa Camino Yenaro Joel",
  "Sequeiros Condori Luis Gustavo",
)

#show: unsa-report.with(
  course_name: "Sistemas Distribuidos",
  lab_title: "Replicación de datos en Sistemas Distribuidos",
  lab_number: "10",
  instructor_name: "Mg. Maribel Molina Barriga",
  members: members,
  members_abbr_list: members.map(name => summarize-name(name, separator: ",")).join(" - "),
)

// Configure components
#code-block-config(lang: "python", prefix: "#")

#set image(width: 78%)
#set list(indent: 2pt)
#show raw.where(block: false): it => box(inset: (x: 0.5pt))[#it]
#show figure: set block(breakable: true)
#set table.header(repeat: false)

#include "sections/1-resultados.typ"
#v(0.5em)
#include "sections/2-cuestionario.typ"
#v(0.5em)
#include "sections/3-conclusiones.typ"
#v(0.5em)
#include "sections/4-referencias.typ"
