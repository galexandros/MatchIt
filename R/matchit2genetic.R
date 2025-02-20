#' Genetic Matching
#' @name method_genetic
#' @aliases method_genetic
#' @usage NULL
#'
#' @description
#' In [matchit()], setting `method = "genetic"` performs genetic matching.
#' Genetic matching is a form of nearest neighbor matching where distances are
#' computed as the generalized Mahalanobis distance, which is a generalization
#' of the Mahalanobis distance with a scaling factor for each covariate that
#' represents the importance of that covariate to the distance. A genetic
#' algorithm is used to select the scaling factors. The scaling factors are
#' chosen as those which maximize a criterion related to covariate balance,
#' which can be chosen, but which by default is the smallest p-value in
#' covariate balance tests among the covariates. This method relies on and is a
#' wrapper for \pkgfun{Matching}{GenMatch} and \pkgfun{Matching}{Match}, which use
#' \pkgfun{rgenoud}{genoud} to perform the optimization using the genetic
#' algorithm.
#'
#' This page details the allowable arguments with `method = "genetic"`.
#' See [matchit()] for an explanation of what each argument means in a general
#' context and how it can be specified.
#'
#' Below is how `matchit()` is used for genetic matching:
#' \preformatted{
#' matchit(formula,
#'         data = NULL,
#'         method = "genetic",
#'         distance = "glm",
#'         link = "logit",
#'         distance.options = list(),
#'         estimand = "ATT",
#'         exact = NULL,
#'         mahvars = NULL,
#'         antiexact = NULL,
#'         discard = "none",
#'         reestimate = FALSE,
#'         s.weights = NULL,
#'         replace = FALSE,
#'         m.order = NULL,
#'         caliper = NULL,
#'         ratio = 1,
#'         verbose = FALSE,
#'         ...) }
#'
#' @param formula a two-sided [formula] object containing the treatment and
#' covariates to be used in creating the distance measure used in the matching.
#' This formula will be supplied to the functions that estimate the distance
#' measure and is used to determine the covariates whose balance is to be
#' optimized.
#' @param data a data frame containing the variables named in `formula`.
#' If not found in `data`, the variables will be sought in the
#' environment.
#' @param method set here to `"genetic"`.
#' @param distance the distance measure to be used. See [`distance`]
#' for allowable options. When set to a method of estimating propensity scores
#' or a numeric vector of distance values, the distance measure is included
#' with the covariates in `formula` to be supplied to the generalized
#' Mahalanobis distance matrix unless `mahvars` is specified. Otherwise,
#' only the covariates in `formula` are supplied to the generalized
#' Mahalanobis distance matrix to have their scaling factors chosen.
#' `distance` *cannot* be supplied as a distance matrix. Supplying
#' any method of computing a distance matrix (e.g., `"mahalanobis"`) has
#' the same effect of omitting propensity score but does not affect how the
#' distance between units is computed otherwise.
#' @param link when `distance` is specified as a method of estimating
#' propensity scores, an additional argument controlling the link function used
#' in estimating the distance measure. See [`distance`] for allowable
#' options with each option.
#' @param distance.options a named list containing additional arguments
#' supplied to the function that estimates the distance measure as determined
#' by the argument to `distance`.
#' @param estimand a string containing the desired estimand. Allowable options
#' include `"ATT"` and `"ATC"`. See Details.
#' @param exact for which variables exact matching should take place.
#' @param mahvars when a distance corresponds to a propensity score (e.g., for
#' caliper matching or to discard units for common support), which covariates
#' should be supplied to the generalized Mahalanobis distance matrix for
#' matching. If unspecified, all variables in `formula` will be supplied
#' to the distance matrix. Use `mahvars` to only supply a subset. Even if
#' `mahvars` is specified, balance will be optimized on all covariates in
#' `formula`. See Details.
#' @param antiexact for which variables ant-exact matching should take place.
#' Anti-exact matching is processed using the `restrict` argument to
#' `Matching::GenMatch()` and `Matching::Match()`.
#' @param discard a string containing a method for discarding units outside a
#' region of common support. Only allowed when `distance` corresponds to a
#' propensity score.
#' @param reestimate if `discard` is not `"none"`, whether to
#' re-estimate the propensity score in the remaining sample prior to matching.
#' @param s.weights the variable containing sampling weights to be incorporated
#' into propensity score models and balance statistics. These are also supplied
#' to `GenMatch()` for use in computing the balance t-test p-values in the
#' process of matching.
#' @param replace whether matching should be done with replacement.
#' @param m.order the order that the matching takes place. The default is
#' `"largest"` when `distance` corresponds to a propensity score and
#' `"data"` otherwise. See [matchit()] for allowable options.
#' @param caliper the width(s) of the caliper(s) used for caliper matching. See
#' Details and Examples.
#' @param std.caliper `logical`; when calipers are specified, whether they
#' are in standard deviation units (`TRUE`) or raw units (`FALSE`).
#' @param ratio how many control units should be matched to each treated unit
#' for k:1 matching. Should be a single integer value.
#' @param verbose `logical`; whether information about the matching
#' process should be printed to the console. When `TRUE`, output from
#' `GenMatch()` with `print.level = 2` will be displayed. Default is
#' `FALSE` for no printing other than warnings.
#' @param \dots additional arguments passed to \pkgfun{Matching}{GenMatch}.
#' Potentially useful options include `pop.size`, `max.generations`,
#' and `fit.func`. If `pop.size` is not specified, a warning from
#' *Matching* will be thrown reminding you to change it. Note that the
#' `ties` and `CommonSupport` arguments are set to `FALSE` and
#' cannot be changed. If `distance.tolerance` is not specified, it is set
#' to 0, whereas the default in *Matching* is 1e-5.
#'
#' @section Outputs:
#' All outputs described in [matchit()] are returned with
#' `method = "genetic"`. When `replace = TRUE`, the `subclass`
#' component is omitted. When `include.obj = TRUE` in the call to
#' `matchit()`, the output of the call to \pkgfun{Matching}{GenMatch} will be
#' included in the output.
#'
#' @details
#' In genetic matching, covariates play three roles: 1) as the variables on
#' which balance is optimized, 2) as the variables in the generalized
#' Mahalanobis distance between units, and 3) in estimating the propensity
#' score. Variables supplied to `formula` are always used for role (1), as
#' the variables on which balance is optimized. When `distance`
#' corresponds to a propensity score, the covariates are also used to estimate
#' the propensity score (unless it is supplied). When `mahvars` is
#' specified, the named variables will form the covariates that go into the
#' distance matrix. Otherwise, the variables in `formula` along with the
#' propensity score will go into the distance matrix. This leads to three ways
#' to use `distance` and `mahvars` to perform the matching:
#'
#' \enumerate{
#' \item{When `distance` corresponds to a propensity score and `mahvars`
#' *is not* specified, the covariates in `formula` along with the
#' propensity score are used to form the generalized Mahalanobis distance
#' matrix. This is the default and most typical use of `method =
#' "genetic"` in `matchit()`.
#' }
#' \item{When `distance` corresponds to a propensity score and `mahvars`
#' *is* specified, the covariates in `mahvars` are used to form the
#' generalized Mahalanobis distance matrix. The covariates in `formula`
#' are used to estimate the propensity score and have their balance optimized
#' by the genetic algorithm. The propensity score is not included in the
#' generalized Mahalanobis distance matrix.
#' }
#' \item{When `distance` is a method of computing a distance matrix
#' (e.g.,`"mahalanobis"`), no propensity score is estimated, and the
#' covariates in `formula` are used to form the generalized Mahalanobis
#' distance matrix. Which specific method is supplied has no bearing on how the
#' distance matrix is computed; it simply serves as a signal to omit estimation
#' of a propensity score.
#' }
#' }
#'
#' When a caliper is specified, any variables mentioned in `caliper`,
#' possibly including the propensity score, will be added to the matching
#' variables used to form the generalized Mahalanobis distance matrix. This is
#' because *Matching* doesn't allow for the separation of caliper
#' variables and matching variables in genetic matching.
#'
#' ## Estimand
#'
#' The `estimand` argument controls whether control
#' units are selected to be matched with treated units (`estimand =
#' "ATT"`) or treated units are selected to be matched with control units
#' (`estimand = "ATC"`). The "focal" group (e.g., the treated units for
#' the ATT) is typically made to be the smaller treatment group, and a warning
#' will be thrown if it is not set that way unless `replace = TRUE`.
#' Setting `estimand = "ATC"` is equivalent to swapping all treated and
#' control labels for the treatment variable. When `estimand = "ATC"`, the
#' default `m.order` is `"smallest"`, and the `match.matrix`
#' component of the output will have the names of the control units as the
#' rownames and be filled with the names of the matched treated units (opposite
#' to when `estimand = "ATT"`). Note that the argument supplied to
#' `estimand` doesn't necessarily correspond to the estimand actually
#' targeted; it is merely a switch to trigger which treatment group is
#' considered "focal". Note that while `GenMatch()` and `Match()`
#' support the ATE as an estimand, `matchit()` only supports the ATT and
#' ATC for genetic matching.
#'
#' @seealso [matchit()] for a detailed explanation of the inputs and outputs of
#' a call to `matchit()`.
#'
#' \pkgfun{Matching}{GenMatch} and \pkgfun{Matching}{Match}, which do the work.
#'
#' @references In a manuscript, be sure to cite the following papers if using
#' `matchit()` with `method = "genetic"`:
#'
#' Diamond, A., & Sekhon, J. S. (2013). Genetic matching for estimating causal
#' effects: A general multivariate matching method for achieving balance in
#' observational studies. Review of Economics and Statistics, 95(3), 932–945. \doi{10.1162/REST_a_00318}
#'
#' Sekhon, J. S. (2011). Multivariate and Propensity Score Matching Software
#' with Automated Balance Optimization: The Matching package for R. Journal of
#' Statistical Software, 42(1), 1–52. \doi{10.18637/jss.v042.i07}
#'
#' For example, a sentence might read:
#'
#' *Genetic matching was performed using the MatchIt package (Ho, Imai,
#' King, & Stuart, 2011) in R, which calls functions from the Matching package
#' (Diamond & Sekhon, 2013; Sekhon, 2011).*
#'
#' @examplesIf all(sapply(c("Matching", "rgenoud"), requireNamespace, quietly = TRUE))
#' data("lalonde")
#'
#' # 1:1 genetic matching with PS as a covariate
#' m.out1 <- matchit(treat ~ age + educ + race + nodegree +
#'                     married + re74 + re75, data = lalonde,
#'                   method = "genetic",
#'                   pop.size = 10) #use much larger pop.size
#' m.out1
#' summary(m.out1)
#'
#' # 2:1 genetic matching with replacement without PS
#' m.out2 <- matchit(treat ~ age + educ + race + nodegree +
#'                     married + re74 + re75, data = lalonde,
#'                   method = "genetic", replace = TRUE,
#'                   ratio = 2, distance = "mahalanobis",
#'                   pop.size = 10) #use much larger pop.size
#' m.out2
#' summary(m.out2, un = FALSE)
#'
#' # 1:1 genetic matching on just age, educ, re74, and re75
#' # within calipers on PS and educ; other variables are
#' # used to estimate PS
#' m.out3 <- matchit(treat ~ age + educ + race + nodegree +
#'                     married + re74 + re75, data = lalonde,
#'                   method = "genetic",
#'                   mahvars = ~ age + educ + re74 + re75,
#'                   caliper = c(.05, educ = 2),
#'                   std.caliper = c(TRUE, FALSE),
#'                   pop.size = 10) #use much larger pop.size
#' m.out3
#' summary(m.out3, un = FALSE)
NULL

matchit2genetic <- function(treat, data, distance, discarded,
                            ratio = 1, s.weights = NULL, replace = FALSE, m.order = NULL,
                            caliper = NULL, mahvars = NULL, exact = NULL,
                            formula = NULL, estimand = "ATT", verbose = FALSE,
                            is.full.mahalanobis, use.genetic = TRUE,
                            antiexact = NULL, ...) {

  check.package(c("Matching", "rgenoud"))

  if (verbose) cat("Genetic matching... \n")

  A <- list(...)

  estimand <- toupper(estimand)
  estimand <- match_arg(estimand, c("ATT", "ATC"))
  if (estimand == "ATC") {
    tc <- c("control", "treated")
    focal <- 0
  }
  else {
    tc <- c("treated", "control")
    focal <- 1
  }

  if (!replace) {
    if (sum(!discarded & treat != focal) < sum(!discarded & treat == focal)) {
      warning(sprintf("Fewer %s units than %s units; not all %s units will get a match.",
                      tc[2], tc[1], tc[1]), immediate. = TRUE, call. = FALSE)
    }
    else if (sum(!discarded & treat != focal) < sum(!discarded & treat == focal)*ratio) {
      stop(sprintf("Not enough %s units for %s matches for each %s unit.",
                   tc[2], ratio, tc[1]), call. = FALSE)
    }
  }

  treat <- setNames(as.integer(treat == focal), names(treat))

  n.obs <- length(treat)
  n1 <- sum(treat == 1)

  if (is.null(names(treat))) names(treat) <- seq_len(n.obs)

  m.order <- {
    if (is.null(distance)) match_arg(m.order, c("data", "random"))
    else if (!is.null(m.order)) match_arg(m.order, c("largest", "smallest", "random", "data"))
    else if (estimand == "ATC") "smallest"
    else "largest"
  }

  ord <- switch(m.order,
                "largest" = order(distance, decreasing = TRUE),
                "smallest" = order(distance),
                "random" = sample.int(n.obs),
                "data" = seq_len(n.obs))
  ord <- ord[!ord %in% which(discarded)]

  #Create X (matching variables) and covs_to_balance
  covs_to_balance <- get.covs.matrix(formula, data = data)
  if (!is.null(mahvars)) {
    X <- get.covs.matrix.for.dist(mahvars, data = data)
  }
  else if (is.full.mahalanobis) {
    X <- covs_to_balance
  }
  else {
    X <- cbind(covs_to_balance, distance)
  }

  if (ncol(covs_to_balance) == 0) {
    stop("Covariates must be specified in the input formula to use genetic matching.", call. = FALSE)
  }

  #Process exact; exact.log will be supplied to GenMatch() and Match()
  if (!is.null(exact)) {
    #Add covariates in exact not in X to X
    ex <- as.integer(factor(exactify(model.frame(exact, data = data), names(treat), sep = ", ", include_vars = TRUE)))

    cc <- intersect(ex[treat==1], ex[treat==0])
    if (length(cc) == 0) stop("No matches were found.", call. = FALSE)

    X <- cbind(X, ex)

    exact.log <- c(rep(FALSE, ncol(X) - 1), TRUE)
  }
  else exact.log <- ex <- NULL

  #Process caliper; cal will be supplied to GenMatch() and Match()
  if (!is.null(caliper)) {
    #Add covariates in caliper other than distance (cov.cals) not in X to X
    cov.cals <- setdiff(names(caliper), "")
    if (length(cov.cals) > 0 && any(!cov.cals %in% colnames(X))) {
      calcovs <- get.covs.matrix(reformulate(cov.cals[!cov.cals %in% colnames(X)]), data = data)
      X <- cbind(X, calcovs)

      #Expand exact.log for newly added covariates
      if (!is.null(exact.log)) exact.log <- c(exact.log, rep(FALSE, ncol(calcovs)))
    }
    else cov.cals <- NULL

    #Matching::Match multiplies calipers by pop SD, so we need to divide by pop SD to unstandardize
    pop.sd <- function(x) sqrt(sum((x-mean(x))^2)/length(x))
    caliper <- caliper / vapply(names(caliper), function(x) {
      if (x == "") pop.sd(distance[!discarded])
      else pop.sd(X[!discarded, x])
    }, numeric(1L))

    #cal needs one value per variable in X
    cal <- setNames(rep(Inf, ncol(X)), colnames(X))

    #First put covariate calipers into cal
    if (length(cov.cals) > 0) {
      cal[intersect(cov.cals, names(cal))] <- caliper[intersect(cov.cals, names(cal))]
    }

    #Then put distance caliper into cal
    if ("" %in% names(caliper)) {
      dist.cal <- caliper[names(caliper) == ""]
      if (!is.null(mahvars)) {
        #If mahvars specified, distance is not yet in X, so add it to X
        X <- cbind(X, distance)
        cal <- c(cal, dist.cal)

        #Expand exact.log for newly added distance
        if (!is.null(exact.log)) exact.log <- c(exact.log, FALSE)
      }
      else {
        #Otherwise, distance is in X at the specified index
        cal[ncol(covs_to_balance) + 1] <- dist.cal
      }
    }
    else dist.cal <- NULL

  }
  else {
    cal <- dist.cal <- cov.cals <- NULL
  }

  #Reorder data according to m.order since Match matches in order of data;
  #ord already excludes discarded units

  treat_ <- treat[ord]
  covs_to_balance <- covs_to_balance[ord,,drop = FALSE]
  X <- X[ord,,drop = FALSE]
  if (!is.null(s.weights)) s.weights <- s.weights[ord]

  if (!is.null(antiexact)) {
    antiexactcovs <- model.frame(antiexact, data)[ord,,drop = FALSE]
    antiexact_restrict <- cbind(do.call("rbind", lapply(seq_len(ncol(antiexactcovs)), function(i) {
      unique.vals <- unique(antiexactcovs[,i])
      do.call("rbind", lapply(unique.vals, function(u) {
        t(combn(which(antiexactcovs[,i] == u), 2))
      }))
    })), -1)
    if (!is.null(A[["restrict"]])) A[["restrict"]] <- rbind(A[["restrict"]], antiexact_restrict)
    else A[["restrict"]] <- antiexact_restrict
  }
  else {
    antiexactcovs <- NULL
  }

  if (is.null(A[["distance.tolerance"]])) {
    A[["distance.tolerance"]] <- 0
  }

  if (use.genetic) {
    withCallingHandlers({
      g.out <- do.call(Matching::GenMatch,
                       c(list(Tr = treat_, X = X, BalanceMatrix = covs_to_balance,
                              M = ratio, exact = exact.log, caliper = cal,
                              replace = replace, estimand = "ATT", ties = FALSE,
                              CommonSupport = FALSE, verbose = verbose,
                              weights = s.weights, print.level = 2*verbose),
                         A[names(A) %in% names(formals(Matching::GenMatch))]))
    },
    warning = function(w) {
      if (!startsWith(conditionMessage(w), "replace==FALSE, but there are more (weighted) treated obs than control obs.")) {
        warning(paste0("(from Matching) ", conditionMessage(w)), call. = FALSE, immediate. = TRUE)
      }
      invokeRestart("muffleWarning")
    },
    error = function(e) {
      stop(paste0("(from Matching) ", conditionMessage(e)), call. = FALSE)
    })
  }
  else {
    #For debugging
    g.out <- NULL
  }

  lab <- names(treat)
  lab1 <- names(treat[treat == 1])

  lab_ <- names(treat_)

  ind_ <- seq_along(treat)[ord]

  # if (!isFALSE(A$use.Match)) {
  withCallingHandlers({
    m.out <- Matching::Match(Tr = treat_, X = X,
                             M = ratio, exact = exact.log, caliper = cal,
                             replace = replace, estimand = "ATT", ties = FALSE,
                             weights = s.weights, CommonSupport = FALSE,
                             distance.tolerance = A[["distance.tolerance"]], Weight = 3,
                             Weight.matrix = if (use.genetic) g.out
                             else if (is.null(s.weights)) generalized_inverse(cor(X))
                             else generalized_inverse(cov.wt(X, s.weights, cor = TRUE)$cor),
                             restrict = A[["restrict"]], version = "fast")
  },
  warning = function(w) {
    if (!startsWith(conditionMessage(w), "replace==FALSE, but there are more (weighted) treated obs than control obs.")) {
      warning(paste0("(from Matching) ", conditionMessage(w)), call. = FALSE, immediate. = TRUE)
    }
    invokeRestart("muffleWarning")
  },
  error = function(e) {
    stop(paste0("(from Matching) ", conditionMessage(e)), call. = FALSE)
  })

  #Note: must use character match.matrix because of re-ordering treat into treat_
  mm <- matrix(NA_integer_, nrow = n1, ncol = max(table(m.out$index.treated)),
               dimnames = list(lab1, NULL))

  unique.matched.focal <- unique(m.out$index.treated, nmax = n1)

  ind1__ <- match(lab_, lab1)
  for (i in unique.matched.focal) {
    matched.units <- ind_[m.out$index.control[m.out$index.treated == i]]
    mm[ind1__[i], seq_along(matched.units)] <- matched.units
  }

  # }
  # else {
  #   #Use nn_match() instead of Match()
  #   ord1 <- ord[ord %in% which(treat == 1)]
  #   if (!is.null(cov.cals)) calcovs <- get.covs.matrix(reformulate(cov.cals), data = data)
  #   else calcovs <- NULL
  #
  #   if (is.null(g.out)) MWM <- generalized_inverse(cov(X))
  #   else MWM <- g.out$Weight.matrix %*% diag(1/apply(X, 2, var))
  #
  #   if (isFALSE(A$fast)) {
  #     mm <- nn_match(treat, ord1, ratio, replace, discarded, distance, ex, dist.cal,
  #                    cov.cals, calcovs, X, MWM)
  #   }
  #   else {
  #     mm <- nn_matchC(treat, ord1, ratio, replace, discarded, distance, ex, dist.cal,
  #                     cov.cals, calcovs, X, MWM)
  #   }
  #
  #   mm[] <- names(treat)[mm]
  #   dimnames(mm) <- list(lab1, seq_len(ratio))
  # }

  if (verbose) cat("Calculating matching weights... ")

  if (replace) {
    psclass <- NULL
  }
  else {
    psclass <- mm2subclass(mm, treat)
  }

  res <- list(match.matrix = nummm2charmm(mm, treat),
              subclass = psclass,
              weights = weights.matrix(mm, treat),
              obj = g.out)

  if (verbose) cat("Done.\n")

  class(res) <- "matchit"
  return(res)
}
