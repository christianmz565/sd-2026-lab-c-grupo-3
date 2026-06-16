#import "/lib.typ": code-block, code-block-config, unsa-report

#show: unsa-report.with(
  course_name: "Sistemas Distribuidos",
  lab_title: "Microservicios y Docker",
  lab_number: "09",
  instructor_name: "Mg. Maribel Molina Barriga",
  members: (
    "Bedregal Perez Daniel",
    "Jara Mamani Mariel Alisson",
    "Mestas Zegarra Christian Raul",
    "Noa Camino Yenaro Joel",
    "Sequeiros Condori Luis Gustavo",
  ),
)

#code-block-config(lang: "python")
#set image(width: 78%)
#set list(indent: 2pt)
#show raw.where(block: false): it => box(inset: (x: 0.5pt))[#it]

#include "sections/1-resultados.typ"
#v(0.5em)
#include "sections/2-cuestionario.typ"
#v(0.5em)
#include "sections/3-conclusiones.typ"
#v(0.5em)
#include "sections/4-referencias.typ"
