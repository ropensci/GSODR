if (requireNamespace("spelling", quietly = TRUE))
  spelling::spell_check_test(vignettes = TRUE, error = FALSE,
                             skip_if_offline = TRUE)
