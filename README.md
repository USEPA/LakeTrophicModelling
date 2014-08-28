LakeTrophicModelling
====================

This repository contains all the materials needed to reproduce Hollister *et al.* (2014) Modeling Lake Trophic State: A Data Mining Approach.  These materials are presented as an R Package which contains code used for analyses, code used to develop figures, raw data used for all analysese, and a package vignette that contains the accepted, unformatted version of the manuscript.

#Install the Package
To install the package and gain access to the materials do the following:

```
install.packages("devtools")
library("devtools")
install_github("LakeTrophicModelling","USEPA")
library("LakeTrophicModelling")
```

All the data used in this manuscript are available via:

```
data(LakeTrophicModelling_data)
```

And the manuscript vignette can be read via:

```
vignette("LakeTrophicModelling",package="LakeTrophicModelling")
```

#EPA Disclaimer
The United States Environmental Protection Agency (EPA) GitHub project code is provided on an "as is" basis and the user assumes responsibility for its use.  EPA has relinquished control of the information and no longer has responsibility to protect the integrity , confidentiality, or availability of the information.  Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by EPA.  The EPA seal and logo shall not be used in any manner to imply endorsement of any commercial product or activity by EPA or the United States Government.

#Thanks
The inspiration for housing this manuscript entierly within a package came from @rmflight.  He has two blog posts about this concept.  [First post](http://rmflight.github.io/posts/2014/07/analyses_as_packages.html) lays out the idea and the [second post](http://rmflight.github.io/posts/2014/07/vignetteAnalysis.html) details the steps to do it.
