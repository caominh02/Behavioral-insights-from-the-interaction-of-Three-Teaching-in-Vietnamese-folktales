Preparation for Bayesian analysis using bayesvl package

1) Download and install R from the website:
https://cran.r-project.org/

2) Download and install RStudio from the website:
https://posit.co/download/rstudio-desktop/

3) (If you use Windows) download and install Rtools from the website:
https://cran.r-project.org/bin/windows/Rtools/

4) Install package of bayesVL from Github:

We have two ways.

The first way, run RStudio and type command:

install.packages(c("code", "devtools", "loo", "ggplot2"))
devtools::install_github("sshpa/bayesvl")

The second way, you can download package from Github with link:
https://github.com/sshpa/bayesvl. After that, you can extract zip folder and following code snippet into command line

install.packages(c("coda","devtools","loo","ggplot2"))
library(devtools)
source <- devtools:::source_pkg("C:/ [Type the location of the bayesvl folder
here]")
install(source)

5) You can install some packages in RStudio if it tells you that you are missing some other required packages.