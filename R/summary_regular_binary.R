#' summary_regular_binary function
#' This function outputs the summary of regular model and final risk score values of each individual in the target dataset using pre-generated Polygenic Risk Scores (PRSs) of all the individuals. Note that the input used in this function can be generated by using PRS_binary function.
#' @param Bphe_target Phenotype file containing family ID, individual ID and phenotype of the target dataset as columns, without heading
#' @param Bcov_target Covariate file containing family ID, individual ID, standardized covariate, square of standardized covariate, and/or confounders of the target dataset as columns, without heading
#' @param add_score PRSs generated using additive SNP effects of GWAS/GWEIS summary statistics
#' @param gxe_score PRSs generated using interaction SNP effects of GWEIS summary statistics
#' @param Model Specify the model number (0: y = PRS_trd + E + confounders, 1: y = PRS_trd + E + PRS_trd x E + confounders, 2: y = PRS_add + E + PRS_add x E + confounders, 3: y = PRS_add + E + PRS_gxe x E + confounders, 4: y = PRS_add + E + PRS_gxe + PRS_gxe x E + confounders, 5: y = PRS_add + E + E^2 + PRS_gxe + PRS_gxe x E + confounders, where y is the outcome variable, E is the covariate of interest, PRS_trd and PRS_add are the polygenic risk scores computed using additive SNP effects of GWAS and GWEIS summary statistics respectively, and PRS_gxe is the polygenic risk scores computed using GxE interaction SNP effects of GWEIS summary statistics.)
#' @keywords regression summary risk scores
#' @export 
#' @importFrom stats binomial fitted.values glm lm na.omit sd
#' @importFrom utils read.table write.table
#' @return This function will output
#' \item{Bsummary}{the summary of the fitted model}
#' \item{Individual_risk_values}{the estimated risk values of individuals in the target sample}
#' @examples \dontrun{ 
#' a <- GWAS_binary(plink_path, DummyData, Bphe_discovery, Bcov_discovery)
#' trd <- a[c("ID", "A1", "OR")]
#' b <- GWEIS_binary(plink_path, DummyData, Bphe_discovery, Bcov_discovery)
#' add <- b[c("ID", "A1", "ADD_OR")]
#' gxe <- b[c("ID", "A1", "INTERACTION_OR")]
#' p <- PRS_binary(plink_path, DummyData, summary_input = trd)
#' q <- PRS_binary(plink_path, DummyData, summary_input = add)
#' r <- PRS_binary(plink_path, DummyData, summary_input = gxe)
#' summary_regular_binary(Bphe_target, Bcov_target, 
#'                             add_score = p,
#'                             Model = 0)
#' summary_regular_binary(Bphe_target, Bcov_target, 
#'                             add_score = p,
#'                             Model = 1)
#' summary_regular_binary(Bphe_target, Bcov_target, 
#'                             add_score = q,
#'                             Model = 2)
#' summary_regular_binary(Bphe_target, Bcov_target, 
#'                             add_score = q, 
#'                             gxe_score = r, 
#'                             Model = 3) 
#' summary_regular_binary(Bphe_target, Bcov_target, 
#'                             add_score = q, 
#'                             gxe_score = r, 
#'                             Model = 4) 
#' x <- summary_regular_binary(Bphe_target, Bcov_target, 
#'                             add_score = q, 
#'                             gxe_score = r, 
#'                             Model = 5) 
#' sink("Bsummary.txt") #to create a file in the working directory
#' print(x$summary) #to write the output
#' sink() #to save the output
#' sink("Individual_risk_values.txt") #to create a file in the working directory
#' write.table(x$risk.values, sep = " ", row.names = FALSE, col.names = FALSE, 
#' quote = FALSE) #to write the output
#' sink() #to save the output
#' x$summary #to obtain the model summary output
#' x$risk.values #to obtain the predicted risk values of target individuals
#' }
summary_regular_binary <- function(Bphe_target, Bcov_target, add_score = NULL, gxe_score = NULL, Model){
  os_name <- Sys.info()["sysname"]
   if (startsWith(os_name, "Win")) {
     slash <- paste0("\\")
   } else {
     slash <- paste0("/")
   }  
  cov_file <- read.table(Bcov_target)
  n_confounders = ncol(cov_file) - 4
  fam=read.table(Bphe_target, header=F) 
  colnames(fam) <- c("FID", "IID", "PHENOTYPE")
  dat=read.table(Bcov_target, header=F)
  colnames(dat)[1] <- "FID"
  colnames(dat)[2] <- "IID"
  df=merge(fam, dat, by = "IID", sort=F)
  df=na.omit(df)
  if(!is.null(add_score)){
    sink(paste0(tempdir(), slash, "add_score"))
    write.table(add_score, sep = " ", row.names = FALSE, quote = FALSE)
    sink()
    prs1_all=read.table(paste0(tempdir(), slash, "add_score"), header=T)
    prs1=merge(fam, prs1_all, by = "FID", sort=F)
    m1 <- match(dat$IID, prs1$IID.x)
    ps1=prs1$PRS
   if(sd(na.omit(ps1)) != 0){
    ps1=scale(prs1$PRS)
   }
    out = fam$PHENOTYPE[m1]
    cov=dat$V3[m1]
   if(sd(na.omit(cov)) != 0){
    cov=scale(dat$V3[m1])
   }
    xv1=scale(prs1$PRS*cov)
   cov2=dat$V4[m1]
   if(sd(na.omit(cov2)) != 0){
    cov2=scale(dat$V4[m1])
   }
  }
  if(!is.null(gxe_score)){
    sink(paste0(tempdir(), slash, "gxe_score"))
    write.table(gxe_score, sep = " ", row.names = FALSE, quote = FALSE)
    sink()
    prs2_all=read.table(paste0(tempdir(), slash, "gxe_score"), header=T)
    prs2=merge(fam, prs2_all, by = "FID", sort=F)
    m1 <- match(dat$IID, prs2$IID.x)
    ps2=prs2$PRS
   if(sd(na.omit(ps2)) != 0){
    ps2=scale(prs2$PRS)
   }
    out = fam$PHENOTYPE[m1]
    cov=dat$V3[m1]
   if(sd(na.omit(cov)) != 0){
    cov=scale(dat$V3[m1])
   }
    xv2=scale(prs2$PRS*cov)
   cov2=dat$V4[m1]
   if(sd(na.omit(cov2)) != 0){
    cov2=scale(cov^2)
   }
  }
  if(Model == 0){
    if(n_confounders == 0){
      df_new <- as.data.frame(cbind(out, cov, cov2, ps1, ps2))
      colnames(df_new)[1] <- "out"
      colnames(df_new)[2] <- "E"
      colnames(df_new)[3] <- "E squared"
      colnames(df_new)[4] <- "PRS_trd/add"
      colnames(df_new)[5] <- "PRS_gxe"
      m = glm(out ~., data = df_new, family = binomial(link = logit))
      m_fit <- fitted.values(m)
    }else{
      conf_var <- matrix(ncol = n_confounders, nrow = nrow(dat))
      for (k in 1:n_confounders) {
        conf_var[, k] <- as.numeric(dat[, k+4])
      }
      conf_var <- conf_var[m1,]
      df_new <- as.data.frame(cbind(out, cov, cov2, ps1, ps2, conf_var))
      colnames(df_new)[1] <- "out"
      colnames(df_new)[2] <- "E"
      colnames(df_new)[3] <- "E squared"
      colnames(df_new)[4] <- "PRS_trd/add"
      colnames(df_new)[5] <- "PRS_gxe"
      for(b in 1:n_confounders){
	colnames(df_new)[5+b] <- paste0("Confounder ", b)
      }
      m = glm(out ~., data = df_new, family = binomial(link = logit))
      m_fit <- fitted.values(m)
    }
    s <- summary(m)
    out1 <- s$coefficients
    colnames(out1) <- c("Coefficient", "Std.Error", "Test.Statistic", "pvalue")
    out1 <- as.matrix(out1)
    out2 <- cbind(df$FID.x, df$IID, m_fit)
    colnames(out2) <- c("FID", "IID", "Risk.Values")
    out2 <- as.matrix(out2)
    out_all <- list(out1, out2)
    names(out_all) <- c("summary", "risk.values")
  }
  if(Model == 1){
    if(n_confounders == 0){
      df_new <- as.data.frame(cbind(out, cov, ps1, xv1))
      colnames(df_new)[1] <- "out"
      colnames(df_new)[2] <- "E"
      colnames(df_new)[3] <- "PRS_trd"
      colnames(df_new)[4] <- "PRS_trd x E"
      m = glm(out ~., data = df_new, family = binomial(link = logit))
      m_fit <- fitted.values(m)
    }else{
      conf_var <- matrix(ncol = n_confounders, nrow = nrow(dat))
      for (k in 1:n_confounders) {
        conf_var[, k] <- as.numeric(dat[, k+4])
      }
      conf_var <- conf_var[m1,]
      df_new <- as.data.frame(cbind(out, cov, ps1, xv1, conf_var))
      colnames(df_new)[1] <- "out"
      colnames(df_new)[2] <- "E"
      colnames(df_new)[3] <- "PRS_trd"
      colnames(df_new)[4] <- "PRS_trd x E"
      for(b in 1:n_confounders){
	colnames(df_new)[4+b] <- paste0("Confounder ", b)
      }
      m = glm(out ~., data = df_new, family = binomial(link = logit))
      m_fit <- fitted.values(m)
    }
    s <- summary(m)
    out1 <- s$coefficients
    colnames(out1) <- c("Coefficient", "Std.Error", "Test.Statistic", "pvalue")
    out1 <- as.matrix(out1)
    out2 <- cbind(df$FID.x, df$IID, m_fit)
    colnames(out2) <- c("FID", "IID", "Risk.Values")
    out2 <- as.matrix(out2)
    out_all <- list(out1, out2)
    names(out_all) <- c("summary", "risk.values")
  }
  if(Model == 2){
    if(n_confounders == 0){
      df_new <- as.data.frame(cbind(out, cov, ps1, xv1))
      colnames(df_new)[1] <- "out"
      colnames(df_new)[2] <- "E"
      colnames(df_new)[3] <- "PRS_add"
      colnames(df_new)[4] <- "PRS_add x E"
      m = glm(out ~., data = df_new, family = binomial(link = logit))
      m_fit <- fitted.values(m)
    }else{
      conf_var <- matrix(ncol = n_confounders, nrow = nrow(dat))
      for (k in 1:n_confounders) {
        conf_var[, k] <- as.numeric(dat[, k+4])
      }
      conf_var <- conf_var[m1,]
      df_new <- as.data.frame(cbind(out, cov, ps1, xv1, conf_var))
      colnames(df_new)[1] <- "out"
      colnames(df_new)[2] <- "E"
      colnames(df_new)[3] <- "PRS_add"
      colnames(df_new)[4] <- "PRS_add x E"
      for(b in 1:n_confounders){
	colnames(df_new)[4+b] <- paste0("Confounder ", b)
      }
      m = glm(out ~., data = df_new, family = binomial(link = logit))
      m_fit <- fitted.values(m)
    }
    s <- summary(m)
    out1 <- s$coefficients
    colnames(out1) <- c("Coefficient", "Std.Error", "Test.Statistic", "pvalue")
    out1 <- as.matrix(out1)
    out2 <- cbind(df$FID.x, df$IID, m_fit)
    colnames(out2) <- c("FID", "IID", "Risk.Values")
    out2 <- as.matrix(out2)
    out_all <- list(out1, out2)
    names(out_all) <- c("summary", "risk.values")
  }
  if(Model == 3){
    if(n_confounders == 0){
      df_new <- as.data.frame(cbind(out, cov, ps1, xv2))
      colnames(df_new)[1] <- "out"
      colnames(df_new)[2] <- "E"
      colnames(df_new)[3] <- "PRS_add"
      colnames(df_new)[4] <- "PRS_gxe x E"
      m = glm(out ~., data = df_new, family = binomial(link = logit))
      m_fit <- fitted.values(m)
    }else{
      conf_var <- matrix(ncol = n_confounders, nrow = nrow(dat))
      for (k in 1:n_confounders) {
        conf_var[, k] <- as.numeric(dat[, k+4])
      }
      conf_var <- conf_var[m1,]
      df_new <- as.data.frame(cbind(out, cov, ps1, xv2, conf_var))
      colnames(df_new)[1] <- "out"
      colnames(df_new)[2] <- "E"
      colnames(df_new)[3] <- "PRS_add"
      colnames(df_new)[4] <- "PRS_gxe x E"
      for(b in 1:n_confounders){
	colnames(df_new)[4+b] <- paste0("Confounder ", b)
      }
      m = glm(out ~., data = df_new, family = binomial(link = logit))
      m_fit <- fitted.values(m)
    }
    s <- summary(m)
    out1 <- s$coefficients
    colnames(out1) <- c("Coefficient", "Std.Error", "Test.Statistic", "pvalue")
    out1 <- as.matrix(out1)
    out2 <- cbind(df$FID.x, df$IID, m_fit)
    colnames(out2) <- c("FID", "IID", "Risk.Values")
    out2 <- as.matrix(out2)
    out_all <- list(out1, out2)
    names(out_all) <- c("summary", "risk.values")
  }
  if(Model == 4){
    if(n_confounders == 0){
      df_new <- as.data.frame(cbind(out, cov, ps1, ps2, xv2))
      colnames(df_new)[1] <- "out"
      colnames(df_new)[2] <- "E"
      colnames(df_new)[3] <- "PRS_add"
      colnames(df_new)[4] <- "PRS_gxe"
      colnames(df_new)[5] <- "PRS_gxe x E"
      m = glm(out ~., data = df_new, family = binomial(link = logit))
      m_fit <- fitted.values(m)
    }else{
      conf_var <- matrix(ncol = n_confounders, nrow = nrow(dat))
      for (k in 1:n_confounders) {
        conf_var[, k] <- as.numeric(dat[, k+4])
      }
      conf_var <- conf_var[m1,]
      df_new <- as.data.frame(cbind(out, cov, ps1, ps2, xv2, conf_var))
      colnames(df_new)[1] <- "out"
      colnames(df_new)[2] <- "E"
      colnames(df_new)[3] <- "PRS_add"
      colnames(df_new)[4] <- "PRS_gxe"
      colnames(df_new)[5] <- "PRS_gxe x E"
      for(b in 1:n_confounders){
	colnames(df_new)[5+b] <- paste0("Confounder ", b)
      }
      m = glm(out ~., data = df_new, family = binomial(link = logit))
      m_fit <- fitted.values(m)
    }
    s <- summary(m)
    out1 <- s$coefficients
    colnames(out1) <- c("Coefficient", "Std.Error", "Test.Statistic", "pvalue")
    out1 <- as.matrix(out1)
    out2 <- cbind(df$FID.x, df$IID, m_fit)
    colnames(out2) <- c("FID", "IID", "Risk.Values")
    out2 <- as.matrix(out2)
    out_all <- list(out1, out2)
    names(out_all) <- c("summary", "risk.values")
  }
  if(Model == 5){
    if(n_confounders == 0){
      df_new <- as.data.frame(cbind(out, cov, cov2, ps1, ps2, xv2))
      colnames(df_new)[1] <- "out"
      colnames(df_new)[2] <- "E"
      colnames(df_new)[3] <- "E squared"
      colnames(df_new)[4] <- "PRS_add"
      colnames(df_new)[5] <- "PRS_gxe"
      colnames(df_new)[6] <- "PRS_gxe x E"
      m = glm(out ~., data = df_new, family = binomial(link = logit))
      m_fit <- fitted.values(m)
    }else{
      conf_var <- matrix(ncol = n_confounders, nrow = nrow(dat))
      for (k in 1:n_confounders) {
        conf_var[, k] <- as.numeric(dat[, k+4])
      }
      conf_var <- conf_var[m1,]
      df_new <- as.data.frame(cbind(out, cov, cov2, ps1, ps2, xv2, conf_var))
      colnames(df_new)[1] <- "out"
      colnames(df_new)[2] <- "E"
      colnames(df_new)[3] <- "E squared"
      colnames(df_new)[4] <- "PRS_add"
      colnames(df_new)[5] <- "PRS_gxe"
      colnames(df_new)[6] <- "PRS_gxe x E"
      for(b in 1:n_confounders){
	colnames(df_new)[6+b] <- paste0("Confounder ", b)
      }
      m = glm(out ~., data = df_new, family = binomial(link = logit))
      m_fit <- fitted.values(m)
    }
    s <- summary(m)
    out1 <- s$coefficients
    colnames(out1) <- c("Coefficient", "Std.Error", "Test.Statistic", "pvalue")
    out1 <- as.matrix(out1)
    out2 <- cbind(df$FID.x, df$IID, m_fit)
    colnames(out2) <- c("FID", "IID", "Risk.Values")
    out2 <- as.matrix(out2)
    out_all <- list(out1, out2)
    names(out_all) <- c("summary", "risk.values")
  }
  return(out_all)
}