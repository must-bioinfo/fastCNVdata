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
  url <- "https://github.com/must-bioinfo/fastCNVdata/releases/download/v1.0.4/HDBreast.rda"
  cache_path <- file.path(rappdirs::user_cache_dir("fastCNVdata"), "HDBreast.rda")

  # Function to check remote modification time
  remote_lastmod <- function(url) {
    h <- curl::curl_fetch_memory(url, handle = curl::new_handle(nobody = TRUE))
    ts <- h$headers[grep("last-modified", names(h$headers), ignore.case = TRUE)]
    if (length(ts) == 0) return(NA)
    as.POSIXct(ts, format = "%a, %d %b %Y %H:%M:%S", tz = "GMT")
  }

  # Determine if we need to download
  remote_time <- remote_lastmod(url)
  local_time  <- if (file.exists(cache_path)) file.info(cache_path)$mtime else NA

  need_download <- !cache ||
    !file.exists(cache_path) ||
    (!is.na(remote_time) && remote_time > local_time)

  if (need_download) {
    message("Downloading HDBreast.rda (~800MB)...")
    dir.create(dirname(cache_path), recursive = TRUE, showWarnings = FALSE)
    curl::curl_download(url, destfile = cache_path, mode = "wb")
  }

  # Load file (retry if corrupted)
  env <- new.env()
  tryCatch(
    load(cache_path, envir = env),
    error = function(e) {
      message("Load failed → redownloading.")
      unlink(cache_path)
      curl::curl_download(url, destfile = cache_path, mode = "wb")
      load(cache_path, envir = env)
    }
  )

  if (!exists("HDBreast", envir = env))
    stop("HDBreast object not found in loaded file.")

  env$HDBreast
}
