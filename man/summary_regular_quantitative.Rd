% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/summary_regular_quantitative.R
\name{summary_regular_quantitative}
\alias{summary_regular_quantitative}
\title{summary_regular_quantitative function
This function outputs the summary of regular model and final risk score values of each individual in the target dataset using pre-generated Polygenic Risk Scores (PRSs) of all the individuals. Note that the input used in this function can be generated by using PRS_quantitative function.}
\usage{
summary_regular_quantitative(
  Qphe_target,
  Qcov_target,
  add_score = NULL,
  gxe_score = NULL,
  Model
)
}
\arguments{
\item{Qphe_target}{Phenotype file containing family ID, individual ID and phenotype of the target dataset as columns, without heading}

\item{Qcov_target}{Covariate file containing family ID, individual ID, standardized covariate, square of standardized covariate, and/or confounders of the target dataset as columns, without heading}

\item{add_score}{PRSs generated using additive SNP effects of GWAS/GWEIS summary statistics}

\item{gxe_score}{PRSs generated using interaction SNP effects of GWEIS summary statistics}

\item{Model}{Specify the model number (0: y = PRS_trd + E + confounders, 1: y = PRS_trd + E + PRS_trd x E + confounders, 2: y = PRS_add + E + PRS_add x E + confounders, 3: y = PRS_add + E + PRS_gxe x E + confounders, 4: y = PRS_add + E + PRS_gxe + PRS_gxe x E + confounders, where y is the outcome variable, E is the covariate of interest, PRS_trd and PRS_add are the polygenic risk scores computed using additive SNP effects of GWAS and GWEIS summary statistics respectively, and PRS_gxe is the polygenic risk scores computed using GxE interaction SNP effects of GWEIS summary statistics.)}
}
\value{
This function will output
\item{Qsummary.txt}{the summary of the fitted model}
\item{Individual_risk_values.txt}{the estimated risk values of individuals in the target sample}
}
\description{
summary_regular_quantitative function
This function outputs the summary of regular model and final risk score values of each individual in the target dataset using pre-generated Polygenic Risk Scores (PRSs) of all the individuals. Note that the input used in this function can be generated by using PRS_quantitative function.
}
\examples{
\dontrun{
a <- GWAS_quantitative(plink_path, DummyData, Qphe_discovery, Qcov_discovery)
trd <- a[c("ID", "A1", "BETA")]
b <- GWEIS_quantitative(plink_path, DummyData, Qphe_discovery, Qcov_discovery)
add <- b[c("ID", "A1", "ADD_BETA")]
gxe <- b[c("ID", "A1", "INTERACTION_BETA")]
p <- PRS_quantitative(plink_path, DummyData, summary_input = trd)
q <- PRS_quantitative(plink_path, DummyData, summary_input = add)
r <- PRS_quantitative(plink_path, DummyData, summary_input = gxe)
summary_regular_quantitative(Qphe_target, Qcov_target, 
                            add_score = p,
                            Model = 0)
summary_regular_quantitative(Qphe_target, Qcov_target, 
                            add_score = p,
                            Model = 1)
summary_regular_quantitative(Qphe_target, Qcov_target, 
                            add_score = q,
                            Model = 2)
summary_regular_quantitative(Qphe_target, Qcov_target, 
                            add_score = q, 
                            gxe_score = r, 
                            Model = 3) 
x <- summary_regular_quantitative(Qphe_target, Qcov_target, 
                            add_score = q, 
                            gxe_score = r, 
                            Model = 4) 
sink("Qsummary.txt") #to create a file in the working directory
print(x$summary) #to write the output
sink() #to save the output
sink("Individual_risk_values.txt") #to create a file in the working directory
write.table(x$risk.values, sep = " ", row.names = FALSE, col.names = FALSE, 
quote = FALSE) #to write the output
sink() #to save the output
x$summary #to obtain the model summary output
x$risk.values #to obtain the predicted risk values of target individuals 
}
}
\keyword{regression}
\keyword{risk}
\keyword{scores}
\keyword{summary}
