#' Load the HDBreast dataset (downloaded if needed)
#'
#' Downloads the HDBreast dataset from GitHub Releases (∼770MB), caches it locally,
#' and returns it as an R object.
#'
#' @param cache Logical. If TRUE (default), caches the dataset in a user-specific directory.
#'
#' @return A data.frame or list containing the HDBreast dataset.
#'
#' @examples
#' \dontrun{
#'   HDB <- load_HDBreast()
#'   str(HDB)
#' }
#' @export
#'

load_HDBreast <- function(cache = TRUE) {
  url <- "https://github.com/must-bioinfo/fastCNVdata/releases/download/v1.0.1/HDBreast.rda"
  cache_path <- file.path(rappdirs::user_cache_dir("fastCNVdata"), "HDBreast.rda")

  if (!cache || !file.exists(cache_path)) {
    message("Downloading HDBreast.rda (~800MB)...")
    dir.create(dirname(cache_path), recursive = TRUE, showWarnings = FALSE)
    download.file(url, cache_path, mode = "wb", quiet = FALSE)
  }

  env <- new.env()
  load(cache_path, envir = env)

  if (!exists("HDBreast", envir = env)) {
    stop("HDBreast object not found in loaded file.")
  }

  env$HDBreast
}
