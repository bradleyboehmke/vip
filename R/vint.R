#' Interaction Effects
#'
#' Compute the strength of interaction effects.
#'
#' @param object A fitted model object (e.g., a \code{"randomForest"} object).
#'
#' @param pred.var Character string giving the names of the predictor variables
#' of interest. Should be of length two.
#'
#' @param progress Character string giving the name of the progress bar to use
#' while constructing the interaction statistics. See
#' \code{\link[plyr]{create_progress_bar}} for details. Default is
#' \code{"none"}.
#'
#' @param parallel Logical indicating whether or not to run \code{partial} in
#' parallel using a backend provided by the \code{foreach} package. Default is
#' \code{FALSE}.
#'
#' @param paropts List containing additional options to be passed onto
#' \code{\link[foreach]{foreach}} when \code{parallel = TRUE}.
#'
#' @param ... Additional optional arguments to be passed onto
#' \code{\link[pdp]{partial}}.
#'
#' @details
#' Coming soon!
#'
#' @note
#' Coming soon!
#'
#' @export
vint <- function(object, pred.var, progress = "none", parallel = FALSE,
                 paropts = NULL, ...) {
  if (!is.character(pred.var) || (length(pred.var) < 2)) {
    stop("'pred.var' with length >= 2.")
  }
  all.pairs <- utils::combn(pred.var, m = 2)
  ints <- plyr::aaply(all.pairs, .margins = 2, .progress = progress,
                      .parallel = parallel, .paropts = paropts,
                      .fun = function(x) {
                        pd <- pdp::partial(object, pred.var = x, ...)
                        mean(c(stats::sd(tapply(pd$yhat, INDEX = pd[[x[1L]]],
                                                FUN = stats::sd)),
                               stats::sd(tapply(pd$yhat, INDEX = pd[[x[2L]]],
                                                FUN = stats::sd))))
                      })
  ints <- data.frame("Variables" = paste0(all.pairs[1L, ], "*", all.pairs[2L, ]),
                     "Interaction" = ints)
  ints <- ints[order(ints["Interaction"], decreasing = TRUE), ]
  tibble::as.tibble(ints)
}
