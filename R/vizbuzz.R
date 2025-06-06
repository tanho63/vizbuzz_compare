#' Vizbuzz Compare
#'
#' # fuzz = relative color distance (value between 0 and 100) to be considered
#' similar in the filling algorithm
#' see https://imagemagick.org/script/command-line-options.php#fuzz
#' Change this, re-Knit the file and see what it does in the comparison image
#'
#' @param path_to_original_image original image (url, local file path or whatever)
#' @param path_to_replicate_image replicated image (url, local file path or whatever)
#' @param fuzz acceptable colour distance between 0-100
#'
#'
#' @export
vizbuzz_compare <- function(path_to_original_image, path_to_replicate_image, fuzz = 10){
  original <- magick::image_read(path_to_original_image)
  orig_info <- magick::image_info(original)

  if (orig_info$width > 1200 || orig_info$height > 1200) {
    cli::cli_inform("Original image is too large, resizing to max 1200x1200")
    original <- magick::image_resize(
      original,
      geometry = magick::geometry_size_pixels(
        width = 1200,
        height = 1200,
        preserve_aspect = TRUE
      )
    )
    orig_info <- magick::image_info(original)
  }

  replicate <- magick::image_resize(
    magick::image_read(path_to_replicate_image),
    geometry = magick::geometry_size_pixels(
      width = orig_info$width,
      height = orig_info$height,
      preserve_aspect = FALSE
    ))

  ae <- magick::image_compare_dist(original, replicate, metric = "AE", fuzz = fuzz)$distortion
  similarity <- 1 - ae / (orig_info$width * orig_info$height)
  sim_string <- paste(scales::percent(similarity, accuracy = 0.1), "of pixels of the resized image are similar.")

  image_comparison <- magick::image_compare(original, replicate, metric = "AE", fuzz = fuzz)

  out <- structure(
    list(
      image_comparison = image_comparison,
      sim_string = sim_string,
      original = original,
      replicate = replicate,
      similarity = similarity
    ),
    class = c("vizbuzz_output")
  )
  return(out)
}

#' @export
#' @keywords internal
print.vizbuzz_output <- function(x,...){
  cat("<VizBuzz Output>",sep = "\n")
  cat(x$sim_string,sep = "\n")
  str(x,max.level = 1)
}
