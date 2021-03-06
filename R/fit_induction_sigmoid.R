#' Fit induction curve data with a sigmoid
#' 
#' This function takes raw data from a calibration curve experiment (yeast expressing pHluorin, flow cytometry data) and does all processing steps to construct a calibration curve that maps fluorescence ratio to pH. Takes *raw* (untransformed) FITC and BV510 channels as inputs!
#' @param df Dataframe or dataframe subset with columns "timepoint", "med.red", "shock.pH.f", and "treatment" (last two are grouping variables if a dataframe subset)
#' @param start.list Edit the starting fitting parameters; default is list(a=120, b=0.05, c=120, d=1) (keep this form but change numbers)
#' @param x.cutoff maximum timepoint to consider in fitting; default is "none" (fits on all timepoints)
#' @export
#' @return dataframe with columns "treatment", "shock.pH.f", "timepoint", and "med.red" for plotting



fit_induction_sigmoid <- function(df, start.list = c(a=120, b=0.05, c=120, d=1), x.cutoff = "none", extend.to.zero = F) {
  # To-do list:
  # 1. return all grouping columns of input dataframe as columns of output dataframe
  # 2. return fitting parameters for each group
  # 3. return goodness-of-fit for each group
  # 4. really sensitive to starting values; means hs/mock samples can't be fit in the same group. Fix?
  
  xe = filter(df, timepoint < x.cutoff)$timepoint
  ye = filter(df, timepoint < x.cutoff)$med.red
  
  fitmodel <- nls(ye~a/(1 + exp(-b * (xe-c))) + d, start=start.list)
  params = coef(fitmodel)
  
  if(extend.to.zero) {
    xt <- seq(0, max(xe), by = 0.5)
    yt <- sigmoid(params, xt)
  }
  else{
    xt <- seq(min(xe), max(xe), by = 0.5)
    yt <- sigmoid(params, xt)
  }

  
  setNames(data.frame(xt, yt), c("timepoint", "med.red")) %>% mutate(shock.pH.f = unique(df$shock.pH.f), treatment = unique(df$treatment))
}

