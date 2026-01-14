#' Load the HDBreast dataset (downloaded if needed)
#'
#' Downloads the HDBreast dataset from GitHub Releases (∼800MB), caches it locally,
#' and returns it as an R object.
#'
#' @param cache Logical. If TRUE (default), caches the dataset in a user-specific directory.
#'
#' @return A data.frame or list containing the HDBreast dataset.
#'
#'
#' @export

load_HDBreast <- function(cache = TRUE) {
  url <- "https://github.com/must-bioinfo/fastCNVdata/releases/download/v1.1.0/HDBreast.rda"

  cache_dir  <- rappdirs::user_cache_dir("fastCNVdata")
  cache_path <- file.path(cache_dir, "HDBreast.rda")
  url_path   <- paste0(cache_path, ".url")

  # Load previous URL if present
  old_url <- if (file.exists(url_path)) readLines(url_path) else NA

  # Should download?
  need_download <- !cache ||
    !file.exists(cache_path) ||
    is.na(old_url) ||
    old_url != url

  if (need_download) {
    message("Downloading HDBreast.rda (~800MB)...")
    dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
    curl::curl_download(url, destfile = cache_path, mode = "wb")
    writeLines(url, url_path)
  }

  # Load dataset
  env <- new.env()
  tryCatch(
    load(cache_path, envir = env),
    error = function(e) {
      message("Load failed → redownloading.")
      unlink(cache_path)
      curl::curl_download(url, destfile = cache_path, mode = "wb")
      writeLines(url, url_path)
      load(cache_path, envir = env)
    }
  )

  if (!exists("HDBreast", envir = env))
    stop("HDBreast object not found in loaded file.")

  env$HDBreast
}

